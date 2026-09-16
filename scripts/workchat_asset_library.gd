class_name BrambleWorkchatAssetLibrary
extends RefCounted

const INDEX_PATH := "res://data/all_workchat_asset_inventory.json"
var data: Dictionary = {}

func load_index() -> bool:
	var f := FileAccess.open(INDEX_PATH, FileAccess.READ)
	if f == null:
		push_error("Missing all_workchat_asset_inventory.json")
		return false
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return false
	data = parsed
	return true

func assets_by_category(category: String) -> Array[String]:
	var result: Array[String] = []
	for entry in data.get("assets", []):
		if String(entry.get("category", "")) == category:
			result.append("res://" + String(entry["file"]))
	return result
