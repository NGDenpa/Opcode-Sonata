extends Node
class_name SoundFx

const MIX_RATE := 44100.0
const TAU_F := PI * 2.0

@export var enabled := true
@export_range(0.0, 1.0) var volume := 0.75

var _player: AudioStreamPlayer
var _playback: AudioStreamGeneratorPlayback
var _tones: Array[Dictionary] = []


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
	set_process(true)


func play_fire() -> void:
	play_tone(720.0, 0.05, "square", 0.035, 480.0)


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
