class_name BrambleShopCatalogService
extends Node
const PATH := "res://data/content/shops.json"
var shops:Dictionary={}
func _ready()->void:
    add_to_group("shop_catalog_service");_load()
func _load()->void:
    if not FileAccess.file_exists(PATH):return
    var parsed=JSON.parse_string(FileAccess.get_file_as_string(PATH))
    if parsed is Dictionary:shops=parsed
func get_shop(shop_id:String)->Dictionary:return shops.get(shop_id,{}).duplicate(true)
func quote(shop_id:String,item_id:String,mode:String)->Dictionary:
    var shop:=get_shop(shop_id)
    if shop.is_empty() or not bool(shop.get("enabled",false)):return {"ok":false,"reason":"shop_unavailable"}
    if not item_id in shop.get("items",[]):return {"ok":false,"reason":"item_not_stocked"}
    var db:=get_tree().get_first_node_in_group("content_db") as BrambleContentDB
    if db==null:return {"ok":false,"reason":"catalog_unavailable"}
    var item:=db.item_data(item_id);var meta:Dictionary=item.get("shop",{})
    if not bool(meta.get("enabled",false)):return {"ok":false,"reason":"item_shop_disabled"}
    var key:="buy_price" if mode=="buy" else "sell_price";var base:=int(meta.get(key,-1))
    if base<0:return {"ok":false,"reason":"price_missing"}
    var mult:=float(shop.get("buy_multiplier" if mode=="buy" else "sell_multiplier",1.0))
    return {"ok":true,"shop_id":shop_id,"item_id":item_id,"price":maxi(0,roundi(base*mult)),"currency":String(shop.get("currency","gold")),"source":"server_shop_catalog"}
