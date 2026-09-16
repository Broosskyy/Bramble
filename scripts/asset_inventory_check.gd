extends Node

func _ready() -> void:
	var lib := BrambleCompleteAssetLibrary.new()
	if not lib.load_inventory():
		return
	print("BRAMBLE complete asset package loaded.")
	print("PNG files: ", lib.inventory.get("total_png_files_in_project", 0))
	print("Unique PNG content: ", lib.inventory.get("unique_png_content_hashes", 0))
	print("Sources: ", lib.inventory.get("counts_by_source", {}))
