class_name BrambleCompleteAssetLibrary
extends RefCounted

const INVENTORY_PATH := "res://data/complete_asset_inventory.json"
var inventory: Dictionary = {}

func load_inventory() -> bool:
	var f := FileAccess.open(INVENTORY_PATH, FileAccess.READ)
	if f == null:
		push_error("BRAMBLE complete asset inventory missing.")
		return false
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("BRAMBLE complete asset inventory invalid.")
		return false
	inventory = parsed
	return true

func files_for_source(source_id: String) -> Array[String]:
	var result: Array[String] = []
	for entry in inventory.get("files", []):
		if String(entry.get("source", "")) == source_id:
			result.append("res://" + String(entry.get("path", "")).trim_prefix("assets/"))
	return result

func all_png_paths() -> Array[String]:
	var result: Array[String] = []
	for entry in inventory.get("files", []):
		result.append("res://" + String(entry.get("path", "")).trim_prefix("assets/"))
	return result
