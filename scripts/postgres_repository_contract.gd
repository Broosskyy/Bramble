class_name BramblePostgresRepositoryContract
extends Node
# Dedicated-server boundary only. This node never opens a database connection in mobile/client builds.
const REQUIRED_OPERATIONS:= ["get_character","find_for_account","save_character","record_transaction","append_outbox","flush","health","save_item_instance","load_item_instances","save_trade_session","lock_character_transaction"]
const CHARACTER_COLUMNS:= ["character_id","account_id","state_json","version","created_at","updated_at"]
func adapter_name()->String:return "postgresql-dedicated-contract-v11.8"
func is_runtime_adapter()->bool:return false
func can_activate()->bool:return DisplayServer.get_name()=="headless" or "--bramble-server" in OS.get_cmdline_args()
func connection_source()->String:return "server_environment_only"
func required_environment()->Array[String]:return ["BRAMBLE_DATABASE_URL"]
func health()->Dictionary:return {"ok":true,"adapter":adapter_name(),"runtime":false,"dedicated_only":true,"can_activate":can_activate()}
