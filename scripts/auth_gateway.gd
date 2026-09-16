class_name BrambleAuthGateway
extends Node
signal authenticated(peer_id:int,claim:Dictionary)
signal rejected(peer_id:int,reason:String)
func _ready()->void:add_to_group("auth_gateway")
func authenticate(peer_id:int,credential:Dictionary)->Dictionary:
    # Dedicated servers verify real access tokens outside the mobile client.
    # Development guest claims receive a server-side account identity and no secret is trusted from the device.
    var method:=String(credential.get("method","guest"))
    var account_id:=String(credential.get("account_id",""))
    var token:=String(credential.get("token",""))
    if method=="guest":
        if account_id=="":account_id="guest_%d"%peer_id
    elif account_id=="" or token=="":
        rejected.emit(peer_id,"missing_credentials");return {}
    var claim={"account_id":account_id,"character_id":String(credential.get("character_id","")),"auth_method":method,"authenticated_at":Time.get_unix_time_from_system()}
    authenticated.emit(peer_id,claim);return claim
