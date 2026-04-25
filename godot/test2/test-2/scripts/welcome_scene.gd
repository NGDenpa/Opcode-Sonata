extends Control

var _level_overlay: ColorRect
var _level_grid: GridContainer


func _ready() -> void:
	_build_level_select()


func _on_start_button_pressed() -> void:
	_show_level_select()


func _start_level(level_idx: int) -> void:
	if not GameProgress.can_open(level_idx):
		return
	GameProgress.request_level(level_idx)
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")


func like():
	get_tree().change_scene_to_file("res://scenes/credits.tscn")


func _build_level_select() -> void:
	_level_overlay = ColorRect.new()
	_level_overlay.visible = false
	_level_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_level_overlay.color = Color(0.0, 0.03, 0.01, 0.72)
	add_child(_level_overlay)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(420, 360)
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left = -210
	card.offset_top = -180
	card.offset_right = 210
	card.offset_bottom = 180
	card.add_theme_stylebox_override("panel", _terminal_panel_style())
	_level_overlay.add_child(card)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 10)
	card.add_child(box)

	var title := Label.new()
	title.text = "选择关卡"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.66, 1.0, 0.64, 1.0))
	title.add_theme_font_size_override("font_size", 24)
	box.add_child(title)

	_level_grid = GridContainer.new()
	_level_grid.columns = 4
	_level_grid.add_theme_constant_override("h_separation", 8)
	_level_grid.add_theme_constant_override("v_separation", 8)
	box.add_child(_level_grid)

	var close_btn := Button.new()
	close_btn.text = "返回"
	close_btn.pressed.connect(func() -> void: _level_overlay.visible = false)
	box.add_child(close_btn)


func _show_level_select() -> void:
	for child in _level_grid.get_children():
		child.queue_free()
	var levels := LevelData.all_levels()
	for i in range(levels.size()):
		var btn := Button.new()
		var name := String((levels[i] as Dictionary).get("name", "关卡 %d" % (i + 1)))
		btn.text = "%02d\n%s" % [i + 1, name]
		btn.custom_minimum_size = Vector2(92, 58)
		btn.disabled = not GameProgress.can_open(i)
		var idx := i
		btn.pressed.connect(func() -> void: _start_level(idx))
		_level_grid.add_child(btn)
	_level_overlay.visible = true


func _terminal_panel_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.015, 0.07, 0.03, 0.96)
	sb.border_color = Color(0.38, 1.0, 0.46, 0.82)
	sb.set_border_width_all(2)
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 12
	sb.content_margin_bottom = 14
	return sb
