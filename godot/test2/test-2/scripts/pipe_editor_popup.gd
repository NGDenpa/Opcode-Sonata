extends CanvasLayer
class_name PipeEditorLayer

const BODY_FONT := preload("res://font/little-pixel.ttf")

signal pipe_script_applied(pipe_id: int, script_csv: String)

var _dim: ColorRect
var _panel: PanelContainer
var _scroll: ScrollContainer
var _lines_box: VBoxContainer
var _title: Label
var _hint: Label
var _dragging := false
var _pipe_id := -1
var _open_tween: Tween


func _ready() -> void:
	layer = 40
	visible = false
	_build_ui()


func _input(event: InputEvent) -> void:
	if not visible or not _dragging:
		return
	if event is InputEventMouseMotion:
		_panel.position += (event as InputEventMouseMotion).relative
		_clamp_panel()
	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and not mb.pressed:
			_dragging = false


func open_for(pipe: Dictionary, row_count: int, click_global: Vector2) -> void:
	_pipe_id = int(pipe.get("id", -1))
	while _lines_box.get_child_count() > 0:
		_lines_box.get_child(0).free()
	var script_str := String(pipe.get("loop_script", ""))
	var parts := script_str.split(",")
	for i in row_count:
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		var lab := Label.new()
		lab.text = "%d" % (i + 1)
		lab.custom_minimum_size.x = 22
		_style_label(lab, 12, Color(0.5, 1.0, 0.58, 0.82))
		var le := LineEdit.new()
		le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		le.custom_minimum_size = Vector2(0, 28)
		le.max_length = 8
		le.placeholder_text = "slp"
		_style_line_edit(le)
		var ch := ""
		if i < parts.size():
			ch = parts[i].strip_edges().to_upper()
		le.text = _internal_token_to_asm(ch)
		row.add_child(lab)
		row.add_child(le)
		_lines_box.add_child(row)
	_resize_for_rows(row_count)
	_title.text = "PIPE SCRIPT (ID %d)" % _pipe_id
	_hint.text = "Assembly input: rot R / rot L / slp. Apply compiles it into the pipe loop."
	_panel.position = click_global + Vector2(12, 12)
	visible = true
	call_deferred("_clamp_panel")
	call_deferred("_play_open_anim")


func close_editor() -> void:
	if _open_tween != null:
		_open_tween.kill()
		_open_tween = null
	visible = false
	_dragging = false


func _build_ui() -> void:
	_dim = ColorRect.new()
	_dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	_dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_dim.color = Color(0.0, 0.035, 0.012, 0.56)
	_dim.gui_input.connect(_on_dim_gui_input)
	add_child(_dim)

	_panel = PanelContainer.new()
	_panel.custom_minimum_size = Vector2(292, 214)
	_panel.mouse_filter = Control.MOUSE_FILTER_STOP
	_panel.add_theme_stylebox_override("panel", _terminal_panel_style())
	add_child(_panel)

	var outer := VBoxContainer.new()
	outer.add_theme_constant_override("separation", 9)
	_panel.add_child(outer)

	var header := HBoxContainer.new()
	header.custom_minimum_size = Vector2(0, 32)
	header.mouse_filter = Control.MOUSE_FILTER_STOP
	header.gui_input.connect(_on_header_gui_input)
	var drag_lbl := Label.new()
	drag_lbl.text = "::"
	_style_label(drag_lbl, 14, Color(0.5, 1.0, 0.56, 0.88))
	_title = Label.new()
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_title.text = "PIPE SCRIPT"
	_style_label(_title, 16, Color(0.66, 1.0, 0.64, 1.0))
	var close_btn := Button.new()
	close_btn.text = "X"
	close_btn.custom_minimum_size = Vector2(36, 28)
	_style_button(close_btn)
	close_btn.pressed.connect(close_editor)
	header.add_child(drag_lbl)
	header.add_child(_title)
	header.add_child(close_btn)
	outer.add_child(header)

	_hint = Label.new()
	_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_style_label(_hint, 12, Color(0.35, 0.95, 0.46, 0.72))
	outer.add_child(_hint)

	_scroll = ScrollContainer.new()
	_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_scroll.custom_minimum_size = Vector2(0, 118)
	_lines_box = VBoxContainer.new()
	_lines_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_lines_box.add_theme_constant_override("separation", 4)
	_scroll.add_child(_lines_box)
	outer.add_child(_scroll)

	var apply_btn := Button.new()
	apply_btn.text = "APPLY"
	apply_btn.custom_minimum_size = Vector2(0, 32)
	_style_button(apply_btn)
	apply_btn.pressed.connect(_on_apply_pressed)
	outer.add_child(apply_btn)


func _on_dim_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			close_editor()


func _on_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
			_dragging = true


func _on_apply_pressed() -> void:
	var tokens: PackedStringArray = []
	for row in _lines_box.get_children():
		if row is HBoxContainer:
			for c in (row as HBoxContainer).get_children():
				if c is LineEdit:
					tokens.append(_asm_to_internal_token((c as LineEdit).text))
					break
	var csv := ""
	for i in range(tokens.size()):
		if i > 0:
			csv += ","
		csv += tokens[i]
	pipe_script_applied.emit(_pipe_id, csv)
	close_editor()


func _internal_token_to_asm(token: String) -> String:
	match token.strip_edges().to_upper():
		"R":
			return "rot R"
		"L":
			return "rot L"
		_:
			return "slp"


func _asm_to_internal_token(text: String) -> String:
	var clean := text.strip_edges().to_upper()
	if clean.is_empty() or clean == "SLP" or clean == "SLEEP" or clean == "-":
		return "-"
	if clean == "R" or clean == "ROT R" or clean == "ROTR":
		return "R"
	if clean == "L" or clean == "ROT L" or clean == "ROTL":
		return "L"
	return "-"


func _clamp_panel() -> void:
	var vp := get_viewport().get_visible_rect().size
	var sz := _panel.get_combined_minimum_size()
	if _panel.size.x > 0:
		sz = _panel.size
	sz.x = maxf(sz.x, _panel.custom_minimum_size.x)
	sz.y = maxf(sz.y, _panel.custom_minimum_size.y)
	_panel.position.x = clampf(_panel.position.x, 6.0, maxf(6.0, vp.x - sz.x - 6.0))
	_panel.position.y = clampf(_panel.position.y, 6.0, maxf(6.0, vp.y - sz.y - 6.0))


func _resize_for_rows(row_count: int) -> void:
	var vp := get_viewport().get_visible_rect().size
	var visible_rows := mini(row_count, 6)
	var scroll_h := clampf(float(visible_rows) * 34.0 + 6.0, 88.0, 210.0)
	_scroll.custom_minimum_size = Vector2(0, scroll_h)
	var panel_h := minf(vp.y - 24.0, 158.0 + scroll_h)
	_panel.custom_minimum_size = Vector2(340, panel_h)
	_panel.size = _panel.custom_minimum_size


func _play_open_anim() -> void:
	if _open_tween != null:
		_open_tween.kill()
	var panel_size := _panel.size
	if panel_size.x <= 1.0 or panel_size.y <= 1.0:
		panel_size = _panel.get_combined_minimum_size()
	_panel.pivot_offset = panel_size * 0.5
	_panel.scale = Vector2(0.72, 0.72)
	_panel.modulate = Color(1, 1, 1, 0.0)
	_open_tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_open_tween.tween_property(_panel, "scale", Vector2.ONE, 0.18)
	_open_tween.parallel().tween_property(_panel, "modulate", Color(1, 1, 1, 1), 0.14)


func _terminal_panel_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.015, 0.07, 0.03, 0.96)
	sb.border_color = Color(0.38, 1.0, 0.46, 0.82)
	sb.set_border_width_all(2)
	sb.corner_radius_top_left = 0
	sb.corner_radius_top_right = 0
	sb.corner_radius_bottom_left = 0
	sb.corner_radius_bottom_right = 0
	sb.shadow_color = Color(0.08, 0.45, 0.12, 0.32)
	sb.shadow_size = 10
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 12
	return sb


func _terminal_field_style(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(1)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 4
	sb.content_margin_bottom = 4
	return sb


func _style_label(label: Label, size_px: int, color: Color) -> void:
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_override("font", BODY_FONT)
	label.add_theme_font_size_override("font_size", size_px)


func _style_line_edit(line_edit: LineEdit) -> void:
	line_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
	line_edit.add_theme_color_override("font_color", Color(0.72, 1.0, 0.68, 1.0))
	line_edit.add_theme_color_override("caret_color", Color(0.85, 1.0, 0.75, 1.0))
	line_edit.add_theme_color_override("font_placeholder_color", Color(0.32, 0.7, 0.38, 0.7))
	line_edit.add_theme_font_override("font", BODY_FONT)
	line_edit.add_theme_font_size_override("font_size", 14)
	line_edit.add_theme_stylebox_override("normal", _terminal_field_style(Color(0.01, 0.11, 0.04, 0.9), Color(0.22, 0.9, 0.35, 0.62)))
	line_edit.add_theme_stylebox_override("focus", _terminal_field_style(Color(0.02, 0.16, 0.06, 0.94), Color(0.62, 1.0, 0.64, 0.92)))


func _style_button(button: Button) -> void:
	button.add_theme_color_override("font_color", Color(0.72, 1.0, 0.68, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.92, 1.0, 0.78, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.02, 0.12, 0.04, 1.0))
	button.add_theme_font_override("font", BODY_FONT)
	button.add_theme_font_size_override("font_size", 13)
	button.add_theme_stylebox_override("normal", _terminal_field_style(Color(0.02, 0.13, 0.05, 0.92), Color(0.25, 0.9, 0.36, 0.66)))
	button.add_theme_stylebox_override("hover", _terminal_field_style(Color(0.04, 0.22, 0.08, 0.96), Color(0.58, 1.0, 0.56, 0.86)))
	button.add_theme_stylebox_override("pressed", _terminal_field_style(Color(0.42, 1.0, 0.44, 0.92), Color(0.82, 1.0, 0.76, 1.0)))
