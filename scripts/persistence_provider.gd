class_name BramblePersistenceProvider
extends Node
# V11.2 contract. Runtime remains local-first/mobile-friendly; dedicated servers can swap adapters.
func get_character(_character_id:String)->Dictionary:return {}
func find_for_account(_account_id:String)->Dictionary:return {}
func save_character(_state:Dictionary)->void:pass
func flush()->void:pass
func health()->Dictionary:return {"ok":false,"adapter":"abstract"}
