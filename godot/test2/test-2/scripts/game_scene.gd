extends Control

const DESIGN_SIZE := Vector2(2048.0, 1152.0)
const MP3_BOARD_RECT := Rect2(Vector2(732.0, 137.0), Vector2(875.0, 835.0))
const CHANGPIAN_BOARD_RECT := Rect2(Vector2(898.0, 130.0), Vector2(845.0, 845.0))
const CIDAI_BOARD_RECT := Rect2(Vector2(762.0, 146.0), Vector2(1108.0, 820.0))

@onready var board_panel: Control = $BoardPanel
@onready var board: GameBoard = %GameBoard
@onready var story_mask: TextureRect = %StoryMask
@onready var letter_text: RichTextLabel = %LetterText
@onready var level_name_label: Label = %LevelName
@onready var to_fill_label: Label = %ToFill
@onready var spectrum: SpectrumView = %SpectrumView
@onready var tick_timer: Timer = %TickTimer
@onready var status_label: Label = %StatusLabel
@onready var turret_action_track: TurretActionTrack = %TurretActionTrack
@onready var play_button: Button = $PlayButton
@onready var reset_button: Button = $ResetButton
@onready var help_button: Button = $HelpButton
@onready var step_button: Button = $StepButton
@onready var duck_button: Button = $DuckButton
@onready var prev_level_button: Button = %PrevLevelButton
@onready var next_level_nav_button: Button = %NextLevelNavButton
@onready var home_button: Button = %HomeButton
@onready var win_overlay: ColorRect = $WinOverlay
@onready var win_hint: Label = %WinHint
@onready var guide_overlay: ColorRect = $GuideOverlay
@onready var guide_card: PanelContainer = $GuideOverlay/GuideCard
@onready var guide_vbox: VBoxContainer = $GuideOverlay/GuideCard/GuideVBox
@onready var guide_title: Label = $GuideOverlay/GuideCard/GuideVBox/GuideTitle
@onready var guide_text: RichTextLabel = %GuideText
@onready var guide_ok_button: Button = $GuideOverlay/GuideCard/GuideVBox/GuideOkButton
@onready var pipe_editor: PipeEditorLayer = $PipeEditorLayer
@onready var sound_fx: SoundFx = $SoundFx

var logic := GameLogic.new()
var levels: Array = []
var current_level_idx: int = 0
var playing: bool = false
var shown_guides := {}
var current_mask_name := ""
var _last_total_hits := 0
var _solution_apply_button: Button
var _guide_mode := "guide"

func _ready() -> void:
	_ensure_solution_preview_buttons()
	_apply_terminal_popup_styles()
	resized.connect(_layout_board_panel)
	levels = LevelData.all_levels()
	board.logic = logic
	board.pipe_clicked.connect(_on_board_pipe_clicked)
	pipe_editor.pipe_script_applied.connect(_on_pipe_script_applied)
	_bind_all_icon_button_fx()
	_layout_board_panel()
	_load_level(GameProgress.requested_level)

func _load_level(idx: int) -> void:
	current_level_idx = clampi(idx, 0, levels.size() - 1)
	var level: Dictionary = levels[current_level_idx]
	logic.load_level(level)
	board.grid_cols = logic.cols
	board.grid_rows = logic.rows
	letter_text.text = "%s\n\n%s" % [level.get("letter_title", ""), level.get("letter_body", "")]
	_apply_story_mask(String(level.get("mask", "")))
	_refresh_level_info()
	status_label.text = "状态：就绪"
	tick_timer.wait_time = float(level.get("tick_rate_ms", 500.0)) / 1000.0
	playing = false
	tick_timer.stop()
	win_overlay.visible = false
	board.set_step_feedback({}, tick_timer.wait_time)
	board.queue_redraw()
	_refresh_turret_action_track()
	_last_total_hits = _total_hits()
	_update_level_nav_buttons()
	_show_guide_if_needed()

func _on_play_button_pressed() -> void:
	playing = not playing
	if playing:
		pipe_editor.close_editor()
		tick_timer.start()
		status_label.text = "状态：运行中"
	else:
		tick_timer.stop()
		status_label.text = "状态：暂停"

func _on_reset_button_pressed() -> void:
	logic.reset()
	playing = false
	tick_timer.stop()
	status_label.text = "状态：已重置"
	board.queue_redraw()
	board.set_step_feedback({}, tick_timer.wait_time)
	_refresh_turret_action_track()
	_refresh_level_info()
	_last_total_hits = 0

func _on_step_button_pressed() -> void:
	pipe_editor.close_editor()
	_step_logic()
	playing = false
	tick_timer.stop()

func _on_tick_timer_timeout() -> void:
	_step_logic()

func _step_logic() -> void:
	logic.step_tick()
	spectrum.kick()
	board.set_step_feedback(logic.last_step_feedback, tick_timer.wait_time)
	_play_step_sounds()
	if logic.is_win():
		playing = false
		tick_timer.stop()
		status_label.text = "状态：修复完成 ✓"
		GameProgress.unlock(current_level_idx + 1)
		sound_fx.play_win()
		_show_win_overlay()
	_refresh_turret_action_track()
	_refresh_level_info()
	_update_level_nav_buttons()
	board.queue_redraw()

func _show_win_overlay() -> void:
	win_overlay.visible = true
	var tick_line := "用时：%d Tick" % logic.tick
	if current_level_idx < levels.size() - 1:
		win_hint.text = "%s\n是否进入下一关？" % tick_line
	else:
		win_hint.text = "%s\n已是最后一关，是否重玩？" % tick_line

func _on_replay_button_pressed() -> void:
	_load_level(current_level_idx)

func _on_next_level_button_pressed() -> void:
	if current_level_idx < levels.size() - 1 and GameProgress.can_open(current_level_idx + 1):
		_load_level(current_level_idx + 1)
	else:
		_load_level(current_level_idx)


func _on_prev_level_button_pressed() -> void:
	if current_level_idx <= 0:
		return
	_load_level(current_level_idx - 1)


func _on_next_level_nav_button_pressed() -> void:
	var next_idx := current_level_idx + 1
	if next_idx >= levels.size():
		return
	if not GameProgress.can_open(next_idx):
		status_label.text = "状态：下一关尚未解锁"
		return
	_load_level(next_idx)


func _on_home_button_pressed() -> void:
	playing = false
	tick_timer.stop()
	pipe_editor.close_editor()
	GameProgress.request_level(current_level_idx)
	get_tree().change_scene_to_file("res://scenes/welcome_scene.tscn")

func _show_guide_if_needed() -> void:
	if shown_guides.has(current_level_idx):
		return
	var level: Dictionary = levels[current_level_idx]
	var guide_body := String(level.get("guide_text", ""))
	if guide_body.strip_edges().is_empty():
		return
	var level_name := String(levels[current_level_idx].get("name", ""))
	_guide_mode = "guide"
	guide_title.text = String(level.get("guide_title", "维修指引"))
	guide_text.text = guide_body
	guide_ok_button.text = "知道了"
	if _solution_apply_button != null:
		_solution_apply_button.visible = false
	guide_overlay.visible = true
	shown_guides[current_level_idx] = true
	status_label.text = "状态：引导中 - %s" % level_name

func _on_guide_ok_button_pressed() -> void:
	guide_overlay.visible = false
	if _guide_mode == "solution":
		status_label.text = "状态：已退出解法预览"
	else:
		status_label.text = "状态：就绪"
	_guide_mode = "guide"


func _on_help_button_pressed() -> void:
	_guide_mode = "guide"
	guide_title.text = "指令说明"
	guide_text.text = "指令说明\n\n炮台动作：\n1 = 发射一个脉冲\n- = 静默一拍\n\n导线脚本：\nR = 顺时针旋转 90°\nL = 逆时针旋转 90°\n- = 保持不动\n\n操作：\n点击弯管 = 打开导线脚本编辑\nShift + 点击弯管 = 手动逆时针旋转\nN = 单步执行一个 Tick"
	guide_ok_button.text = "知道了"
	if _solution_apply_button != null:
		_solution_apply_button.visible = false
	guide_overlay.visible = true
	status_label.text = "状态：查看指令说明"


func _on_duck_button_pressed() -> void:
	_show_solution_preview()


func _ensure_solution_preview_buttons() -> void:
	if _solution_apply_button != null:
		return
	var button_row := HBoxContainer.new()
	button_row.name = "SolutionButtons"
	button_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_theme_constant_override("separation", 8)
	guide_vbox.remove_child(guide_ok_button)
	guide_vbox.add_child(button_row)
	_solution_apply_button = Button.new()
	_solution_apply_button.name = "ApplySolutionButton"
	_solution_apply_button.text = "确定"
	_solution_apply_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_solution_apply_button.pressed.connect(_on_apply_solution_button_pressed)
	button_row.add_child(_solution_apply_button)
	guide_ok_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button_row.add_child(guide_ok_button)
	_solution_apply_button.visible = false


func _show_solution_preview() -> void:
	var entries: Array[Dictionary] = _solution_loop_entries()
	_guide_mode = "solution"
	guide_title.text = "关卡解法"
	guide_ok_button.text = "退出解法预览"
	if _solution_apply_button != null:
		_solution_apply_button.visible = true
		_solution_apply_button.disabled = entries.is_empty()
	if entries.is_empty():
		guide_text.text = "当前关卡没有可应用的解法。\n\n全为 - 的空脚本会被忽略。"
	else:
		var lines: PackedStringArray = ["将应用以下非空导线脚本："]
		for entry in entries:
			lines.append(
				"P%d (%s @ %d,%d): %s" % [
					int(entry["index"]) + 1,
					String(entry["shape"]),
					int(entry["col"]),
					int(entry["row"]),
					String(entry["loop"])
				]
			)
		lines.append("\n点击“确定”会把这些脚本写入当前关卡。")
		guide_text.text = "\n".join(lines)
	guide_overlay.visible = true
	status_label.text = "状态：解法预览"


func _on_apply_solution_button_pressed() -> void:
	if not _can_edit_pipes():
		status_label.text = "状态：运行后不可应用解法，请重置后再试"
		return
	var entries: Array[Dictionary] = _solution_loop_entries()
	if entries.is_empty():
		status_label.text = "状态：当前关卡没有可应用的解法"
		return
	for entry in entries:
		var err := logic.set_pipe_loop_by_id(int(entry["index"]), String(entry["loop"]))
		if err != "":
			status_label.text = "状态：%s" % err
			return
	guide_overlay.visible = false
	_guide_mode = "guide"
	board.queue_redraw()
	_refresh_turret_action_track()
	status_label.text = "状态：已应用关卡解法"


func _solution_loop_entries() -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	if levels.is_empty() or current_level_idx < 0 or current_level_idx >= levels.size():
		return entries
	var level: Dictionary = levels[current_level_idx]
	var solution_loops := level.get("solution_loops", []) as Array
	var pipe_defs := level.get("pipes", []) as Array
	for i in range(mini(solution_loops.size(), pipe_defs.size())):
		var loop_text := String(solution_loops[i])
		if _is_empty_solution_loop(loop_text):
			continue
		var pipe_def := pipe_defs[i] as Dictionary
		entries.append({
			"index": i,
			"loop": loop_text,
			"shape": String(pipe_def.get("shape", "?")),
			"col": int(pipe_def.get("col", 0)),
			"row": int(pipe_def.get("row", 0))
		})
	return entries


func _is_empty_solution_loop(loop_text: String) -> bool:
	var clean := loop_text.strip_edges()
	if clean.is_empty():
		return true
	for token in clean.split(","):
		if token.strip_edges() != "-":
			return false
	return true


func _on_board_pipe_clicked(pipe: Dictionary, shift_pressed: bool, click_global: Vector2) -> void:
	if not _can_edit_pipes():
		pipe_editor.close_editor()
		status_label.text = "状态：运行后不可编辑，请重置后再调整导线"
		return
	if shift_pressed:
		logic.rotate_pipe_at(int(pipe["col"]), int(pipe["row"]), -90)
		status_label.text = "状态：已手动旋转导线"
		sound_fx.play_rotate()
		board.set_step_feedback({
			"fired_turrets": [],
			"rotated_pipes": [{
				"id": int(pipe["id"]),
				"col": int(pipe["col"]),
				"row": int(pipe["row"]),
				"delta": -90
			}],
			"bullet_trails": []
		}, tick_timer.wait_time)
		board.queue_redraw()
		return
	pipe_editor.open_for(pipe, logic.unified_loop_length(), click_global)


func _on_pipe_script_applied(pipe_id: int, script_csv: String) -> void:
	if not _can_edit_pipes():
		status_label.text = "状态：运行后不可编辑，请重置后再调整导线"
		return
	var err := logic.set_pipe_loop_by_id(pipe_id, script_csv)
	if err != "":
		status_label.text = "状态：%s" % err
	else:
		status_label.text = "状态：导线脚本已更新"
	board.queue_redraw()
	_refresh_turret_action_track()


func _refresh_turret_action_track() -> void:
	turret_action_track.set_snapshot(logic.turret_action_snapshot())


func _apply_story_mask(mask_name: String) -> void:
	current_mask_name = mask_name
	if mask_name.is_empty():
		story_mask.texture = null
		story_mask.visible = false
		_layout_board_panel()
		return
	var path := "res://ui/%s.png" % mask_name
	var texture := load(path) as Texture2D
	story_mask.texture = texture
	story_mask.visible = texture != null
	_layout_board_panel()


func _layout_board_panel() -> void:
	var scale := Vector2(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	var design_rect: Rect2 = _board_rect_for_current_level()
	board_panel.position = design_rect.position * scale
	board_panel.size = design_rect.size * scale
	_layout_spectrum_view(design_rect, scale)


func _layout_spectrum_view(board_rect: Rect2, scale: Vector2) -> void:
	var spectrum_rect: Rect2 = _spectrum_rect_for_current_level(board_rect)
	spectrum.anchor_left = 0.0
	spectrum.anchor_top = 0.0
	spectrum.anchor_right = 0.0
	spectrum.anchor_bottom = 0.0
	spectrum.position = (spectrum_rect.position - board_rect.position) * scale
	spectrum.size = spectrum_rect.size * scale


func _spectrum_rect_for_current_level(board_rect: Rect2) -> Rect2:
	var fallback := Rect2(
		board_rect.position + Vector2(0.0, board_rect.size.y - 92.0),
		Vector2(board_rect.size.x, 76.0)
	)
	if levels.is_empty() or current_level_idx < 0 or current_level_idx >= levels.size():
		return fallback
	var level: Dictionary = levels[current_level_idx]
	if not level.has("spectrum_rect"):
		return fallback
	return _rect_from_level_info(level["spectrum_rect"], fallback)


func _board_rect_for_current_level() -> Rect2:
	var fallback := _board_rect_for_mask(current_mask_name)
	if levels.is_empty() or current_level_idx < 0 or current_level_idx >= levels.size():
		return fallback
	var level: Dictionary = levels[current_level_idx]
	if not level.has("board_rect"):
		return fallback
	return _rect_from_level_info(level["board_rect"], fallback)


func _rect_from_level_info(value: Variant, fallback: Rect2) -> Rect2:
	if value is Dictionary:
		var rect_info := value as Dictionary
		return Rect2(
			Vector2(
				float(rect_info.get("x", fallback.position.x)),
				float(rect_info.get("y", fallback.position.y))
			),
			Vector2(
				float(rect_info.get("width", fallback.size.x)),
				float(rect_info.get("height", fallback.size.y))
			)
		)
	if value is Array:
		var rect_values := value as Array
		if rect_values.size() >= 4:
			return Rect2(
				Vector2(float(rect_values[0]), float(rect_values[1])),
				Vector2(float(rect_values[2]), float(rect_values[3]))
			)
	return fallback


func _board_rect_for_mask(mask_name: String) -> Rect2:
	match mask_name:
		"changpian":
			return CHANGPIAN_BOARD_RECT
		"mp3":
			return MP3_BOARD_RECT
		"cidai":
			return CIDAI_BOARD_RECT
		_:
			return MP3_BOARD_RECT


func _can_edit_pipes() -> bool:
	return not playing and logic.is_at_initial_state()


func _refresh_level_info() -> void:
	var total_required := 0
	var total_hits := 0
	for t in logic.targets:
		total_required += int(t["required"])
		total_hits += int(t["hits"])
	var remaining: int = maxi(0, total_required - total_hits)
	var level_name := String(levels[current_level_idx].get("name", ""))
	level_name_label.text = "当前关卡：%s" % [level_name]
	to_fill_label.text = "洞待填充：%d / %d" % [remaining, total_required]


func _level_grid_info_text() -> String:
	var mask_name := current_mask_name
	if mask_name.is_empty():
		mask_name = String(levels[current_level_idx].get("mask", ""))
	var board_rect: Rect2 = _board_rect_for_current_level()
	var cols: int = logic.cols
	var rows: int = logic.rows
	var grid_cell: float = floorf(minf(board_rect.size.x / float(cols), board_rect.size.y / float(rows)))
	var grid_size := Vector2(grid_cell * float(cols), grid_cell * float(rows))
	var grid_pos := board_rect.position + (board_rect.size - grid_size) * 0.5
	var grid_end := grid_pos + grid_size
	var window_end := board_rect.position + board_rect.size
	var spectrum_rect: Rect2 = _spectrum_rect_for_current_level(board_rect)
	var spectrum_end := spectrum_rect.position + spectrum_rect.size
	return "蒙版：%s\n窗口：%s - %s (%s)\n网格：%d x %d，单格 %.0fpx\n网格位置：%s - %s (%s)\n频谱：%s - %s (%s)" % [
		mask_name,
		_format_vec2(board_rect.position),
		_format_vec2(window_end),
		_format_vec2(board_rect.size),
		cols,
		rows,
		grid_cell,
		_format_vec2(grid_pos),
		_format_vec2(grid_end),
		_format_vec2(grid_size),
		_format_vec2(spectrum_rect.position),
		_format_vec2(spectrum_end),
		_format_vec2(spectrum_rect.size)
	]


func _format_vec2(value: Vector2) -> String:
	return "%.0f,%.0f" % [value.x, value.y]


func _update_level_nav_buttons() -> void:
	prev_level_button.disabled = current_level_idx <= 0
	var next_idx := current_level_idx + 1
	next_level_nav_button.disabled = next_idx >= levels.size() or not GameProgress.can_open(next_idx)
	_apply_icon_button_fx(prev_level_button, false, false)
	_apply_icon_button_fx(next_level_nav_button, false, false)


func _bind_all_icon_button_fx() -> void:
	for button in [
		play_button,
		reset_button,
		help_button,
		step_button,
		duck_button,
		prev_level_button,
		next_level_nav_button,
		home_button
	]:
		_bind_icon_button_fx(button)
		_apply_icon_button_fx(button, false, false)


func _bind_icon_button_fx(button: Button) -> void:
	button.mouse_entered.connect(func() -> void:
		_apply_icon_button_fx(button, true, button.button_pressed)
	)
	button.mouse_exited.connect(func() -> void:
		_apply_icon_button_fx(button, false, button.button_pressed)
	)
	button.button_down.connect(func() -> void:
		_apply_icon_button_fx(button, button.is_hovered(), true)
	)
	button.button_up.connect(func() -> void:
		_apply_icon_button_fx(button, button.is_hovered(), false)
	)


func _apply_icon_button_fx(button: Button, hovered: bool, pressed: bool) -> void:
	var targets := _button_fx_targets(button)
	if button == duck_button:
		button.self_modulate = Color.WHITE if hovered else Color(0.34, 1.0, 0.36, 1.0)
	if button.disabled:
		if button == duck_button:
			button.self_modulate = Color(0.18, 0.35, 0.18, 0.42)
		for target in targets:
			target.self_modulate = Color(0.18, 0.35, 0.18, 0.42)
			target.scale = Vector2.ONE
		return
	if pressed:
		for target in targets:
			target.self_modulate = Color(0.45, 0.95, 0.32, 0.78)
			target.scale = Vector2(0.90, 0.90)
	elif hovered:
		for target in targets:
			target.self_modulate = Color(0.75, 1.0, 0.52, 1.0)
			target.scale = Vector2(1.10, 1.10)
	else:
		for target in targets:
			target.self_modulate = Color(0.10, 0.67, 0.04, 1.0)
			target.scale = Vector2.ONE


func _button_fx_targets(button: Button) -> Array[CanvasItem]:
	var targets: Array[CanvasItem] = []
	var icon := button.get_node_or_null("Icon") as CanvasItem
	if icon != null:
		targets.append(icon)
	var label := button.get_node_or_null("Label") as CanvasItem
	if label != null:
		targets.append(label)
	if targets.is_empty():
		targets.append(button)
	return targets


func _play_step_sounds() -> void:
	if not (logic.last_step_feedback["fired_turrets"] as Array).is_empty():
		sound_fx.play_fire()
	if not (logic.last_step_feedback["rotated_pipes"] as Array).is_empty():
		sound_fx.play_rotate()
	var total_hits := _total_hits()
	if total_hits > _last_total_hits:
		for i in range(total_hits - _last_total_hits):
			sound_fx.play_hit()
	_last_total_hits = total_hits


func _total_hits() -> int:
	var total := 0
	for t in logic.targets:
		total += int(t["hits"])
	return total


func _apply_terminal_popup_styles() -> void:
	guide_overlay.color = Color(0.0, 0.035, 0.012, 0.58)
	guide_card.add_theme_stylebox_override("panel", _terminal_panel_style())
	guide_title.add_theme_color_override("font_color", Color(0.66, 1.0, 0.64, 1.0))
	guide_title.add_theme_font_size_override("font_size", 22)
	guide_text.add_theme_stylebox_override("normal", _terminal_text_style())
	guide_text.add_theme_color_override("default_color", Color(0.72, 1.0, 0.68, 0.96))
	guide_text.add_theme_font_size_override("normal_font_size", 15)
	guide_ok_button.add_theme_stylebox_override("normal", _terminal_button_style(Color(0.02, 0.13, 0.05, 0.94), Color(0.25, 0.9, 0.36, 0.66)))
	guide_ok_button.add_theme_stylebox_override("hover", _terminal_button_style(Color(0.04, 0.22, 0.08, 0.96), Color(0.58, 1.0, 0.56, 0.86)))
	guide_ok_button.add_theme_stylebox_override("pressed", _terminal_button_style(Color(0.42, 1.0, 0.44, 0.92), Color(0.82, 1.0, 0.76, 1.0)))
	guide_ok_button.add_theme_color_override("font_color", Color(0.72, 1.0, 0.68, 1.0))
	guide_ok_button.add_theme_color_override("font_hover_color", Color(0.92, 1.0, 0.78, 1.0))
	guide_ok_button.add_theme_color_override("font_pressed_color", Color(0.02, 0.12, 0.04, 1.0))
	if _solution_apply_button != null:
		_solution_apply_button.add_theme_stylebox_override("normal", _terminal_button_style(Color(0.02, 0.13, 0.05, 0.94), Color(0.25, 0.9, 0.36, 0.66)))
		_solution_apply_button.add_theme_stylebox_override("hover", _terminal_button_style(Color(0.04, 0.22, 0.08, 0.96), Color(0.58, 1.0, 0.56, 0.86)))
		_solution_apply_button.add_theme_stylebox_override("pressed", _terminal_button_style(Color(0.42, 1.0, 0.44, 0.92), Color(0.82, 1.0, 0.76, 1.0)))
		_solution_apply_button.add_theme_stylebox_override("disabled", _terminal_button_style(Color(0.02, 0.08, 0.04, 0.55), Color(0.16, 0.42, 0.18, 0.45)))
		_solution_apply_button.add_theme_color_override("font_color", Color(0.72, 1.0, 0.68, 1.0))
		_solution_apply_button.add_theme_color_override("font_hover_color", Color(0.92, 1.0, 0.78, 1.0))
		_solution_apply_button.add_theme_color_override("font_pressed_color", Color(0.02, 0.12, 0.04, 1.0))
		_solution_apply_button.add_theme_color_override("font_disabled_color", Color(0.38, 0.58, 0.38, 0.72))
	letter_text.add_theme_stylebox_override("normal", _terminal_text_style())
	letter_text.add_theme_color_override("default_color", Color(0.72, 1.0, 0.68, 0.94))
	letter_text.add_theme_font_size_override("normal_font_size", 8)


func _terminal_panel_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.015, 0.07, 0.03, 0.96)
	sb.border_color = Color(0.38, 1.0, 0.46, 0.82)
	sb.set_border_width_all(2)
	sb.shadow_color = Color(0.08, 0.45, 0.12, 0.32)
	sb.shadow_size = 12
	sb.content_margin_left = 14
	sb.content_margin_right = 14
	sb.content_margin_top = 12
	sb.content_margin_bottom = 14
	return sb


func _terminal_text_style() -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color(0.01, 0.085, 0.035, 0.88)
	sb.border_color = Color(0.22, 0.9, 0.35, 0.45)
	sb.set_border_width_all(1)
	sb.content_margin_left = 10
	sb.content_margin_right = 10
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	return sb


func _terminal_button_style(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(1)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 5
	sb.content_margin_bottom = 5
	return sb
