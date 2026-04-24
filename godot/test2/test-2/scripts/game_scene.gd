extends Control

@onready var board: GameBoard = %GameBoard
@onready var letter_text: RichTextLabel = %LetterText
@onready var level_name_label: Label = %LevelName
@onready var title_label: Label = %TitleLabel
@onready var spectrum: SpectrumView = %SpectrumView
@onready var tick_timer: Timer = %TickTimer
@onready var status_label: Label = %StatusLabel

var logic := GameLogic.new()
var levels: Array = []
var current_level_idx: int = 0
var playing: bool = false

func _ready() -> void:
	levels = LevelData.all_levels()
	board.logic = logic
	_load_level(0)

func _load_level(idx: int) -> void:
	current_level_idx = clampi(idx, 0, levels.size() - 1)
	var level: Dictionary = levels[current_level_idx]
	logic.load_level(level)
	letter_text.text = "%s\n\n%s" % [level.get("letter_title", ""), level.get("letter_body", "")]
	level_name_label.text = "当前关卡：%s" % level.get("name", "")
	status_label.text = "状态：就绪"
	tick_timer.wait_time = float(level.get("tick_rate_ms", 500.0)) / 1000.0
	playing = false
	tick_timer.stop()
	board.queue_redraw()

func _on_play_button_pressed() -> void:
	playing = not playing
	if playing:
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

func _on_step_button_pressed() -> void:
	_step_logic()
	playing = false
	tick_timer.stop()

func _on_tick_timer_timeout() -> void:
	_step_logic()

func _step_logic() -> void:
	logic.step_tick()
	spectrum.kick()
	if logic.is_win():
		playing = false
		tick_timer.stop()
		status_label.text = "状态：修复完成 ✓"
	board.queue_redraw()
