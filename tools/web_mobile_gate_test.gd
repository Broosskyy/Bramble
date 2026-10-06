extends SceneTree

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var inset := BrambleWebPlatformService.calculate_logical_safe_insets(
		Vector2(720, 1280),
		Vector2(1080, 1920),
		Rect2i(0, 72, 1080, 1776)
	)
	_assert_close(inset.x, 0.0, "left inset")
	_assert_close(inset.y, 48.0, "top inset")
	_assert_close(inset.z, 0.0, "right inset")
	_assert_close(inset.w, 48.0, "bottom inset")

	var empty := BrambleWebPlatformService.calculate_logical_safe_insets(
		Vector2(1280, 720), Vector2.ZERO, Rect2i()
	)
	if empty != Vector4.ZERO:
		_fail("invalid physical size must yield zero safe insets")

	var main_scene := load("res://scenes/main.tscn") as PackedScene
	if main_scene == null:
		_fail("main scene failed to load")
	var root := main_scene.instantiate()
	if root.get_node_or_null("WebPlatformService") == null:
		root.free()
		_fail("main scene has no WebPlatformService")
	root.free()

	print("WEB_MOBILE_GATE_TEST=PASS")
	quit(0)

func _assert_close(actual: float, expected: float, label: String) -> void:
	if not is_equal_approx(actual, expected):
		_fail("%s expected %.2f, got %.2f" % [label, expected, actual])

func _fail(message: String) -> void:
	push_error("WEB_MOBILE_GATE_TEST=FAIL: %s" % message)
	quit(1)

