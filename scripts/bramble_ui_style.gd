class_name BrambleUiStyle
extends RefCounted

const GOLD := Color("#d9b765")
const GOLD_BRIGHT := Color("#f4d88a")
const INK := Color("#f5ead2")
const MUTED := Color("#b9ad96")
const PANEL := Color(0.055, 0.05, 0.045, 0.94)
const PANEL_SOFT := Color(0.075, 0.068, 0.058, 0.90)
const SELECTED := Color("#e8bd57")
const HP := Color("#d95555")
const MP := Color("#4f91cf")
const XP := Color("#75b75b")
const POSITIVE := Color("#79d786")
const NEGATIVE := Color("#ef7373")

const TOUCH_MIN := 48.0

static func panel(radius := 14, border := 2, alpha := 0.94) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(PANEL.r, PANEL.g, PANEL.b, alpha)
	style.border_color = GOLD
	style.set_border_width_all(border)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0, 0, 0, 0.45)
	style.shadow_size = 8
	return style

static func inset(radius := 10, selected := false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.09, 0.08, 0.065, 0.94)
	style.border_color = GOLD_BRIGHT if selected else Color(0.46, 0.38, 0.24, 1.0)
	style.set_border_width_all(3 if selected else 1)
	style.set_corner_radius_all(radius)
	return style

static func button(selected := false, disabled := false) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.24, 0.18, 0.10, 0.92) if selected else Color(0.10, 0.085, 0.065, 0.94)
	if disabled:
		style.bg_color = Color(0.07, 0.065, 0.06, 0.80)
	style.border_color = GOLD_BRIGHT if selected else Color(0.62, 0.49, 0.26, 1.0)
	style.set_border_width_all(3 if selected else 2)
	style.set_corner_radius_all(12)
	style.shadow_color = Color(0, 0, 0, 0.32)
	style.shadow_size = 4
	return style

static func progress(fill_color: Color, height := 14.0) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(120, height)
	bar.show_percentage = false
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.025, 0.025, 0.025, 0.9)
	bg.border_color = Color(0.58, 0.46, 0.25, 0.85)
	bg.set_border_width_all(1)
	bg.set_corner_radius_all(int(height * 0.5))
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.set_corner_radius_all(int(height * 0.5))
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)
	return bar

static func label(text: String, font_size := 16, color := INK) -> Label:
	var out := Label.new()
	out.text = text
	out.add_theme_font_size_override("font_size", font_size)
	out.add_theme_color_override("font_color", color)
	out.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
	out.add_theme_constant_override("shadow_offset_x", 1)
	out.add_theme_constant_override("shadow_offset_y", 1)
	return out

static func apply_button(control: Button, selected := false) -> void:
	control.custom_minimum_size.y = maxf(control.custom_minimum_size.y, TOUCH_MIN)
	control.add_theme_font_size_override("font_size", 15)
	control.add_theme_color_override("font_color", INK)
	control.add_theme_color_override("font_hover_color", GOLD_BRIGHT)
	control.add_theme_stylebox_override("normal", button(selected))
	control.add_theme_stylebox_override("hover", button(true))
	control.add_theme_stylebox_override("pressed", button(true))
	control.add_theme_stylebox_override("disabled", button(selected, true))

static func texture(path: String) -> Texture2D:
	return BrambleWorldPresentationConfig.game_tex(path)
