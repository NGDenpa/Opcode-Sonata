extends Control

@onready var board: GameBoard = %GameBoard
@onready var letter_text: RichTextLabel = %LetterText
@onready var level_name_label: Label = %LevelName
@onready var spectrum: SpectrumView = %SpectrumView
@onready var tick_timer: Timer = %TickTimer
@onready var status_label: Label = %StatusLabel
@onready var turret_action_track: TurretActionTrack = %TurretActionTrack
@onready var win_overlay: ColorRect = $WinOverlay
@onready var win_hint: Label = %WinHint
@onready var guide_overlay: ColorRect = $GuideOverlay
@onready var guide_card: PanelContainer = $GuideOverlay/GuideCard
@onready var guide_title: Label = $GuideOverlay/GuideCard/GuideVBox/GuideTitle
@onready var guide_text: RichTextLabel = %GuideText
@onready var guide_ok_button: Button = $GuideOverlay/GuideCard/GuideVBox/GuideOkButton
@onready var pipe_editor: PipeEditorLayer = $PipeEditorLayer

var logic := GameLogic.new()
var levels: Array = []
var current_level_idx: int = 0
var playing: bool = false
var shown_guides := {}

func _ready() -> void:
	_apply_terminal_popup_styles()
	levels = LevelData.all_levels()
	board.logic = logic
	board.pipe_clicked.connect(_on_board_pipe_clicked)
	pipe_editor.pipe_script_applied.connect(_on_pipe_script_applied)
	_load_level(0)

func _load_level(idx: int) -> void:
	current_level_idx = clampi(idx, 0, levels.size() - 1)
	var level: Dictionary = levels[current_level_idx]
	logic.load_level(level)
	letter_text.text = "%s\n\n%s" % [level.get("letter_title", ""), level.get("letter_body", "")]
	_refresh_level_info()
	status_label.text = "状态：就绪"
	tick_timer.wait_time = float(level.get("tick_rate_ms", 500.0)) / 1000.0
	playing = false
	tick_timer.stop()
	win_overlay.visible = false
	board.set_step_feedback({})
	board.queue_redraw()
	_refresh_turret_action_track()
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
	board.set_step_feedback({})
	_refresh_turret_action_track()
	_refresh_level_info()

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
	board.set_step_feedback(logic.last_step_feedback)
	if logic.is_win():
		playing = false
		tick_timer.stop()
		status_label.text = "状态：修复完成 ✓"
		_show_win_overlay()
	_refresh_turret_action_track()
	_refresh_level_info()
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
	if current_level_idx < levels.size() - 1:
		_load_level(current_level_idx + 1)
	else:
		_load_level(current_level_idx)

func _show_guide_if_needed() -> void:
	if current_level_idx > 5:
		return
	if shown_guides.has(current_level_idx):
		return
	var level_name := String(levels[current_level_idx].get("name", ""))
	var guide_lines: PackedStringArray = [
		"欢迎，维修工。\n\n目标是把洞的待填充数降到 0。炮台动作中的 1 会发射，- 会停一拍。可以按 N 单步观察。",
		"新认知：节拍密度。\n\n1-1- 比 1--- 更频繁发射。观察左侧炮台动作轨道的扫描框。",
		"新认知：弯管。\n\n脉冲进入弯管后会改变方向。先不用编辑，只观察路径如何拐弯。",
		"新认知：R 指令。\n\n导线脚本里的 R 会让弯管顺时针旋转 90°。本关已经填好脚本，观察它如何赶在脉冲到达前转向。",
		"新操作：编辑导线。\n\n点击弯管打开编辑窗，把第一行改成 R，再点应用。? 按钮可以随时查看 R / L / - 的含义。",
		"新挑战：多炮台多故障。\n\n动作轨道每行对应一个炮台。两个洞都要填满，注意它们的发射节拍不同。"
	]
	guide_title.text = "维修指引"
	guide_text.text = guide_lines[current_level_idx]
	guide_overlay.visible = true
	shown_guides[current_level_idx] = true
	status_label.text = "状态：引导中 - %s" % level_name

func _on_guide_ok_button_pressed() -> void:
	guide_overlay.visible = false
	status_label.text = "状态：就绪"


func _on_help_button_pressed() -> void:
	guide_title.text = "指令说明"
	guide_text.text = "指令说明\n\n炮台动作：\n1 = 发射一个脉冲\n- = 静默一拍\n\n导线脚本：\nR = 顺时针旋转 90°\nL = 逆时针旋转 90°\n- = 保持不动\n\n操作：\n点击弯管 = 打开导线脚本编辑\nShift + 点击弯管 = 手动逆时针旋转\nN = 单步执行一个 Tick"
	guide_overlay.visible = true
	status_label.text = "状态：查看指令说明"


func _on_board_pipe_clicked(pipe: Dictionary, shift_pressed: bool, click_global: Vector2) -> void:
	if not _can_edit_pipes():
		pipe_editor.close_editor()
		status_label.text = "状态：运行后不可编辑，请重置后再调整导线"
		return
	if shift_pressed:
		logic.rotate_pipe_at(int(pipe["col"]), int(pipe["row"]), -90)
		status_label.text = "状态：已手动旋转导线"
		board.set_step_feedback({
			"fired_turrets": [],
			"rotated_pipes": [{
				"id": int(pipe["id"]),
				"col": int(pipe["col"]),
				"row": int(pipe["row"]),
				"delta": -90
			}],
			"bullet_trails": []
		})
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
	level_name_label.text = "当前关卡：%s\n洞待填充：%d / %d" % [level_name, remaining, total_required]


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
	letter_text.add_theme_stylebox_override("normal", _terminal_text_style())
	letter_text.add_theme_color_override("default_color", Color(0.72, 1.0, 0.68, 0.94))
	letter_text.add_theme_font_size_override("normal_font_size", 14)


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
