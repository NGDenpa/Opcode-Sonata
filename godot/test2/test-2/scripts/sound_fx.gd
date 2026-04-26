extends Node
class_name SoundFx

const MIX_RATE := 44100.0
const TAU_F := PI * 2.0

@export var enabled := true
@export_range(0.0, 1.0) var volume := 0.75

var _player: AudioStreamPlayer
var _music_player: AudioStreamPlayer
var _playback: AudioStreamGeneratorPlayback
var _tones: Array[Dictionary] = []
var _phrase_tokens: PackedStringArray = []
var _hit_note_idx := 0
var _loop_note_idx := 0
var _loop_timer: Timer
var _phrase_beat_duration := 0.5
var _music_track_path := ""


func _ready() -> void:
	var generator := AudioStreamGenerator.new()
	generator.mix_rate = MIX_RATE
	generator.buffer_length = 0.12

	_player = AudioStreamPlayer.new()
	_player.stream = generator
	_player.volume_db = -6.0
	add_child(_player)
	_player.play()
	_playback = _player.get_stream_playback() as AudioStreamGeneratorPlayback
	_music_player = AudioStreamPlayer.new()
	_music_player.volume_db = -4.0
	add_child(_music_player)
	_loop_timer = Timer.new()
	_loop_timer.one_shot = false
	_loop_timer.timeout.connect(_on_loop_timer_timeout)
	add_child(_loop_timer)
	set_process(true)


func play_fire() -> void:
	play_tone(720.0, 0.05, "square", 0.035, 480.0)


func play_ui_click() -> void:
	play_tone(880.0, 0.04, "square", 0.025, 1320.0)
	play_tone(1100.0, 0.03, "square", 0.015, 1760.0)




func play_hit() -> void:
	play_tone(520.0, 0.09, "triangle", 0.055, 900.0)


func play_rotate() -> void:
	play_tone(300.0, 0.04, "square", 0.035, 240.0)


func play_win() -> void:
	play_tone(440.0, 0.08, "triangle", 0.045, 660.0)
	await get_tree().create_timer(0.09).timeout
	play_tone(660.0, 0.10, "triangle", 0.055, 990.0)
	await get_tree().create_timer(0.11).timeout
	play_tone(990.0, 0.14, "triangle", 0.065, 1320.0)


func stop_transient_tones() -> void:
	_tones.clear()


func play_tone(freq: float, duration: float, wave: String, tone_volume: float, slide_to: float = -1.0) -> void:
	if not enabled:
		return
	_tones.append({
		"freq": freq,
		"start_freq": freq,
		"end_freq": slide_to if slide_to > 0.0 else freq,
		"duration": maxf(0.01, duration),
		"elapsed": 0.0,
		"phase": 0.0,
		"wave": wave,
		"volume": tone_volume * volume
	})


func configure_phrase(phrase: String, beat_duration: float) -> void:
	_phrase_tokens = _parse_phrase(phrase)
	_phrase_beat_duration = maxf(0.08, beat_duration)
	_hit_note_idx = 0
	_loop_note_idx = 0
	stop_phrase_loop()


func configure_music_track(path: String) -> void:
	_music_track_path = path
	if _music_player != null:
		_music_player.stop()
		_music_player.stream = null


func clear_phrase() -> void:
	_phrase_tokens = []
	_hit_note_idx = 0
	_loop_note_idx = 0
	_music_track_path = ""
	stop_phrase_loop()


func has_phrase() -> bool:
	return not _phrase_tokens.is_empty()


func play_phrase_hit_note() -> bool:
	if _phrase_tokens.is_empty():
		return false
	_play_phrase_token(_phrase_tokens[_hit_note_idx])
	_hit_note_idx = (_hit_note_idx + 1) % _phrase_tokens.size()
	return true


func start_phrase_loop() -> void:
	if _start_music_track_loop():
		return
	if _phrase_tokens.is_empty() or _loop_timer == null:
		return
	_loop_note_idx = 0
	_loop_timer.wait_time = _phrase_beat_duration
	_loop_timer.start()
	_on_loop_timer_timeout()


func stop_phrase_loop() -> void:
	if _loop_timer != null:
		_loop_timer.stop()
	if _music_player != null:
		_music_player.stop()


func _start_music_track_loop() -> bool:
	if _music_track_path.is_empty() or _music_player == null:
		return false
	if not ResourceLoader.exists(_music_track_path):
		return false
	var stream := load(_music_track_path) as AudioStream
	if stream == null:
		return false
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	elif stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	elif stream is AudioStreamWAV:
		(stream as AudioStreamWAV).loop_mode = AudioStreamWAV.LOOP_FORWARD
	_music_player.stream = stream
	_music_player.play()
	return true


func _on_loop_timer_timeout() -> void:
	if _phrase_tokens.is_empty():
		stop_phrase_loop()
		return
	_play_phrase_token(_phrase_tokens[_loop_note_idx])
	_loop_note_idx = (_loop_note_idx + 1) % _phrase_tokens.size()


func _play_phrase_token(token: String) -> void:
	var clean := token.strip_edges().to_upper()
	if clean == "-" or clean.is_empty():
		return
	var freq := _note_frequency(clean)
	if freq <= 0.0:
		return
	play_tone(freq, _phrase_beat_duration * 0.76, "triangle", 0.075)


func _parse_phrase(phrase: String) -> PackedStringArray:
	var tokens: PackedStringArray = []
	for token in phrase.split(" ", false):
		var clean := token.strip_edges()
		if not clean.is_empty():
			tokens.append(clean)
	return tokens


func _note_frequency(note: String) -> float:
	var octave_shift := 0
	while note.ends_with("*"):
		octave_shift += 1
		note = note.substr(0, note.length() - 1)
	var semitone := 0
	match note:
		"C":
			semitone = -9
		"C#":
			semitone = -8
		"D":
			semitone = -7
		"D#":
			semitone = -6
		"E":
			semitone = -5
		"F":
			semitone = -4
		"F#":
			semitone = -3
		"G":
			semitone = -2
		"G#":
			semitone = -1
		"A":
			semitone = 0
		"A#":
			semitone = 1
		"B":
			semitone = 2
		_:
			return 0.0
	return 440.0 * pow(2.0, float(semitone + octave_shift * 12) / 12.0)


func _process(_delta: float) -> void:
	if _playback == null:
		return
	var frames := _playback.get_frames_available()
	for i in range(frames):
		var sample := _mix_next_sample()
		_playback.push_frame(Vector2(sample, sample))
	_tones = _tones.filter(func(tone: Dictionary) -> bool:
		return float(tone["elapsed"]) < float(tone["duration"])
	)


func _mix_next_sample() -> float:
	if _tones.is_empty():
		return 0.0
	var dt := 1.0 / MIX_RATE
	var sample := 0.0
	for tone in _tones:
		var elapsed := float(tone["elapsed"])
		var duration := float(tone["duration"])
		if elapsed >= duration:
			continue
		var progress := elapsed / duration
		var freq := lerpf(float(tone["start_freq"]), float(tone["end_freq"]), progress)
		var phase := float(tone["phase"]) + freq * TAU_F * dt
		var amp := _envelope(progress) * float(tone["volume"])
		sample += _wave_sample(String(tone["wave"]), phase) * amp
		tone["phase"] = fmod(phase, TAU_F)
		tone["elapsed"] = elapsed + dt
	return clampf(sample, -0.7, 0.7)


func _envelope(progress: float) -> float:
	var attack := smoothstep(0.0, 0.16, progress)
	var release := 1.0 - smoothstep(0.72, 1.0, progress)
	return attack * release


func _wave_sample(wave: String, phase: float) -> float:
	match wave:
		"square":
			return 1.0 if sin(phase) >= 0.0 else -1.0
		"triangle":
			return asin(sin(phase)) * (2.0 / PI)
		_:
			return sin(phase)
