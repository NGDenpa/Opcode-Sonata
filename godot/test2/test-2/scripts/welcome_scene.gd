extends Control

const BODY_FONT := preload("res://font/little-pixel.ttf")
const TITLE_FONT := preload("res://font/pixel-highscore.ttf")
const PLAYLIST_TRACKS := [
	{
		"level_idx": 5,
		"title": "CANON",
		"path": "res://ui/clavier-music-pachelbelx27s-canon-canon-in-d-307319.mp3"
	},
	{
		"level_idx": 6,
		"title": "SPRING",
		"path": "res://ui/Violin Concerto in E major, RV 269 'Spring' - I. Allegro.mp3"
	},
	{
		"level_idx": 7,
		"title": "SERENADE",
		"path": "res://ui/Mozart - Serenade in G major.mp3"
	},
	{
		"level_idx": 8,
		"title": "SWAN LAKE",
		"path": "res://ui/lorenzobuczek-swan-lake-147751.mp3"
	},
	{
		"level_idx": 9,
		"title": "MILITARY MARCH",
		"path": "res://ui/Marche militaire in D, D. 733 no. 1 (2 hands version).mp3"
	}
]

@onready var playlist_button: TextureButton = $playList
@onready var sound_fx: SoundFx = $SoundFx

var _level_overlay: ColorRect
var _level_grid: GridContainer
var _playlist_overlay: ColorRect
var _playlist_box: VBoxContainer
var _music_player: AudioStreamPlayer
var _tracks: Array[Dictionary] = []
var _playlist_file_count := 0


func _ready() -> void:
	_music_player = AudioStreamPlayer.new()
	add_child(_music_player)
	if not sound_fx:
		sound_fx = SoundFx.new()
		add_child(sound_fx)
	playlist_button.pressed.connect(_on_playlist_pressed)
	_load_playlist_tracks_from_list()
	_build_level_select()
	_build_playlist()


func _on_start_button_pressed() -> void:
	sound_fx.play_ui_click()
	_show_level_select()


func _start_level(level_idx: int) -> void:
	if not GameProgress.can_open(level_idx):
		return
	if sound_fx:
		sound_fx.play_ui_click()
	GameProgress.request_level(level_idx)
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")


func _on_credits_pressed():
	sound_fx.play_ui_click()
	get_tree().change_scene_to_file("res://scenes/credits.tscn")


func _on_playlist_pressed() -> void:
	sound_fx.play_ui_click()
	_show_playlist()


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
	title.text = "SELECT LEVEL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.66, 1.0, 0.64, 1.0))
	title.add_theme_font_override("font", TITLE_FONT)
	title.add_theme_font_size_override("font_size", 24)
	box.add_child(title)

	_level_grid = GridContainer.new()
	_level_grid.columns = 4
	_level_grid.add_theme_constant_override("h_separation", 8)
	_level_grid.add_theme_constant_override("v_separation", 8)
	box.add_child(_level_grid)

	var close_btn := Button.new()
	close_btn.text = "BACK"
	_style_terminal_button(close_btn)
	close_btn.pressed.connect(func() -> void:
		if sound_fx:
			sound_fx.play_ui_click()
		_level_overlay.visible = false
	)
	box.add_child(close_btn)


func _build_playlist() -> void:
	_playlist_overlay = ColorRect.new()
	_playlist_overlay.visible = false
	_playlist_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_playlist_overlay.color = Color(0.0, 0.03, 0.01, 0.72)
	add_child(_playlist_overlay)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(460, 380)
	card.set_anchors_preset(Control.PRESET_CENTER)
	card.offset_left = -230
	card.offset_top = -190
	card.offset_right = 230
	card.offset_bottom = 190
	card.add_theme_stylebox_override("panel", _terminal_panel_style())
	_playlist_overlay.add_child(card)

	_playlist_box = VBoxContainer.new()
	_playlist_box.add_theme_constant_override("separation", 10)
	card.add_child(_playlist_box)

	var title := Label.new()
	title.text = "PLAYLIST"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.66, 1.0, 0.64, 1.0))
	title.add_theme_font_override("font", TITLE_FONT)
	title.add_theme_font_size_override("font_size", 24)
	_playlist_box.add_child(title)

	var close_btn := Button.new()
	close_btn.text = "BACK"
	_style_terminal_button(close_btn)
	close_btn.pressed.connect(func() -> void:
		if sound_fx:
			sound_fx.play_ui_click()
		_playlist_overlay.visible = false
	)
	_playlist_box.add_child(close_btn)


func _show_level_select() -> void:
	for child in _level_grid.get_children():
		child.queue_free()
	var levels := LevelData.all_levels()
	for i in range(levels.size()):
		var btn := Button.new()
		btn.text = "%02d" % [i + 1]
		btn.custom_minimum_size = Vector2(92, 58)
		_style_terminal_button(btn)
		btn.disabled = not GameProgress.can_open(i)
		var idx := i
		btn.pressed.connect(func() -> void: _start_level(idx))
		_level_grid.add_child(btn)
	_level_overlay.visible = true


func _show_playlist() -> void:
	_load_playlist_tracks_from_list()
	for i in range(_playlist_box.get_child_count() - 1, 1, -1):
		_playlist_box.get_child(i).queue_free()
	var unlocked := _unlocked_playlist_count()
	if _playlist_file_count <= 0:
		_playlist_box.add_child(_playlist_message("NO AUDIO FILES FOUND"))
	elif unlocked <= 0:
		_playlist_box.add_child(_playlist_message("UNLOCK LEVEL 7 TO OPEN PLAYLIST"))
	else:
		for i in range(_tracks.size()):
			var track: Dictionary = _tracks[i]
			var btn := Button.new()
			btn.text = "LV.%02d  %s" % [int(track["level_idx"]) + 1, String(track["title"])]
			btn.custom_minimum_size = Vector2(0, 42)
			_style_terminal_button(btn)
			var path := String(track["path"])
			btn.pressed.connect(func() -> void:
				if sound_fx:
					sound_fx.play_ui_click()
				_play_track(path)
			)
			_playlist_box.add_child(btn)
	_playlist_overlay.visible = true


func _playlist_message(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_override("font", BODY_FONT)
	label.add_theme_color_override("font_color", Color(0.72, 1.0, 0.68, 0.9))
	label.add_theme_font_size_override("font_size", 16)
	return label


func _load_playlist_tracks_from_list() -> void:
	_tracks.clear()
	_playlist_file_count = 0
	for track in PLAYLIST_TRACKS:
		var path := String(track["path"])
		if ResourceLoader.exists(path):
			_playlist_file_count += 1
			_tracks.append({
				"level_idx": int(track["level_idx"]),
				"title": String(track["title"]),
				"path": path
			})
	_tracks.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return int(a["level_idx"]) < int(b["level_idx"])
	)
	_tracks = _tracks.filter(func(track: Dictionary) -> bool:
		return int(track["level_idx"]) >= 0 and GameProgress.can_open(int(track["level_idx"]))
	)


func _unlocked_playlist_count() -> int:
	return _tracks.size()


func _play_track(path: String) -> void:
	var stream := load(path) as AudioStream
	if stream == null:
		return
	_music_player.stop()
	_music_player.stream = stream
	_music_player.play()


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


func _style_terminal_button(button: Button) -> void:
	button.add_theme_stylebox_override("normal", _terminal_button_style(Color(0.02, 0.13, 0.05, 0.94), Color(0.25, 0.9, 0.36, 0.66)))
	button.add_theme_stylebox_override("hover", _terminal_button_style(Color(0.04, 0.22, 0.08, 0.96), Color(0.58, 1.0, 0.56, 0.86)))
	button.add_theme_stylebox_override("pressed", _terminal_button_style(Color(0.42, 1.0, 0.44, 0.92), Color(0.82, 1.0, 0.76, 1.0)))
	button.add_theme_stylebox_override("disabled", _terminal_button_style(Color(0.02, 0.08, 0.04, 0.55), Color(0.16, 0.42, 0.18, 0.45)))
	button.add_theme_font_override("font", BODY_FONT)
	button.add_theme_color_override("font_color", Color(0.72, 1.0, 0.68, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.92, 1.0, 0.78, 1.0))
	button.add_theme_color_override("font_pressed_color", Color(0.02, 0.12, 0.04, 1.0))
	button.add_theme_color_override("font_disabled_color", Color(0.38, 0.58, 0.38, 0.72))


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
