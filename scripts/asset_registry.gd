class_name BrambleAssetRegistry
extends RefCounted

const REGISTRY_PATH := "res://data/animation_registry_v4.json"
var data: Dictionary = {}

func load_registry() -> bool:
	var f := FileAccess.open(REGISTRY_PATH, FileAccess.READ)
	if f == null:
		push_error("BRAMBLE: animation registry missing: %s" % REGISTRY_PATH)
		return false
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_error("BRAMBLE: invalid animation registry.")
		return false
	data = parsed
	return true

func _res_path(file_path: String) -> String:
	if file_path.begins_with("res://"):
		return file_path
	# Registry paths are relative to project root and normally begin with assets/.
	return "res://" + file_path

func character_frames(gender: String, poses: Array[String]) -> Array[Texture2D]:
	var result: Array[Texture2D] = []
	for pose in poses:
		for e in data.get("characters", {}).get(gender, []):
			if String(e.get("pose", "")) == pose:
				var tex := load(_res_path(String(e.get("file", "")))) as Texture2D
				if tex != null:
					result.append(tex)
				break
	return result

func npc_frames(npc_id: String, poses: Array[String]) -> Array[Texture2D]:
	var result: Array[Texture2D] = []
	for pose in poses:
		for e in data.get("npcs", {}).get(npc_id, []):
			if String(e.get("pose", "")) == pose:
				var tex := load(_res_path(String(e.get("file", "")))) as Texture2D
				if tex != null:
					result.append(tex)
				break
	return result
