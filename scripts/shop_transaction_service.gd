class_name BrambleShopTransactionService
extends Node
signal purchase_result(peer_id:int,result:Dictionary)
func _ready()->void:add_to_group("shop_transaction_service")
func purchase(peer_id:int,item_id:String,qty:int,request_id:String,shop_id:String="village_general")->Dictionary:
    if request_id=="" or qty<=0:return _reject(peer_id,request_id,"invalid_purchase")
    var quote:=_shop_quote(shop_id,item_id,"buy")
    if not bool(quote.get("ok",false)):return _reject(peer_id,request_id,String(quote.get("reason","item_not_for_sale")))
    var economy:=get_tree().get_first_node_in_group("economy_transaction_service") as BrambleEconomyTransactionService
    if economy==null:return _reject(peer_id,request_id,"economy_unavailable")
    var price:=int(quote.get("price",0));var result:=economy.apply(peer_id,{"gold":-(price*qty),"add_items":[{"id":item_id,"qty":qty}]},"shop:buy:"+request_id)
    result.merge({"operation":"purchase","item_id":item_id,"qty":qty,"unit_price":price,"price_source":"server_shop_catalog","shop_id":shop_id},true)
    purchase_result.emit(peer_id,result);return result
func sell(peer_id:int,item_id:String,qty:int,request_id:String,shop_id:String="village_general")->Dictionary:
    if request_id=="" or qty<=0:return _reject(peer_id,request_id,"invalid_sale")
    var quote:=_shop_quote(shop_id,item_id,"sell")
    if not bool(quote.get("ok",false)):return _reject(peer_id,request_id,String(quote.get("reason","item_not_sellable")))
    var economy:=get_tree().get_first_node_in_group("economy_transaction_service") as BrambleEconomyTransactionService
    if economy==null:return _reject(peer_id,request_id,"economy_unavailable")
    var value:=int(quote.get("price",0));var result:=economy.apply(peer_id,{"gold":value*qty,"remove_items":[{"id":item_id,"qty":qty}]},"shop:sell:"+request_id)
    result.merge({"operation":"sell","item_id":item_id,"qty":qty,"unit_value":value,"price_source":"server_shop_catalog","shop_id":shop_id},true)
    purchase_result.emit(peer_id,result);return result
func quote(item_id:String)->Dictionary:
    var buy:=_quote(item_id,"buy_price");var sell:=_quote(item_id,"sell_price")
    return {"ok":bool(buy.get("ok",false)) or bool(sell.get("ok",false)),"item_id":item_id,"buy_price":int(buy.get("price",0)),"sell_price":int(sell.get("price",0)),"currency":"gold","source":"server_catalog"}
func _quote(item_id:String,key:String)->Dictionary:
    var db:=get_tree().get_first_node_in_group("content_db") as BrambleContentDB
    if db==null:return {"ok":false,"reason":"catalog_unavailable"}
    var item:=db.item_data(item_id);if item.is_empty():return {"ok":false,"reason":"unknown_item"}
    var shop:Dictionary=item.get("shop",{})
    if not bool(shop.get("enabled",false)):return {"ok":false,"reason":"shop_disabled"}
    var price:=int(shop.get(key,-1));if price<0:return {"ok":false,"reason":"price_missing"}
    return {"ok":true,"price":price}
func _reject(peer_id:int,request_id:String,reason:String)->Dictionary:
    var r={"ok":false,"transaction_id":request_id,"reason":reason};purchase_result.emit(peer_id,r);return r

func _shop_quote(shop_id:String,item_id:String,mode:String)->Dictionary:
    var catalog:=get_tree().get_first_node_in_group("shop_catalog_service") as BrambleShopCatalogService
    if catalog:return catalog.quote(shop_id,item_id,mode)
    return _quote(item_id,"buy_price" if mode=="buy" else "sell_price")
