extends Control
class_name ScanlineBackground

@export var speed := 56.0
@export var vertical_spacing := 46.0
@export var horizontal_spacing := 38.0

var _lines: Array[Dictionary] = []
var _vertical_spawn := 0.0
var _horizontal_spawn := 0.0
var _seeded := false
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_rng.randomize()
	set_process(true)


func _process(delta: float) -> void:
	if size.x <= 1.0 or size.y <= 1.0:
		return
	if not _seeded:
		_seed_initial_lines()
	_vertical_spawn += speed * delta
	_horizontal_spawn += speed * delta
	while _vertical_spawn >= vertical_spacing:
		_vertical_spawn -= vertical_spacing
		_spawn_vertical_line()
	while _horizontal_spawn >= horizontal_spacing:
		_horizontal_spawn -= horizontal_spacing
		_spawn_horizontal_line()
	_update_lines(delta)
	queue_redraw()


func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.0, 0.012, 0.004, 1.0), true)
	_draw_crt_scanlines()
	_draw_generated_lines()
	_draw_vignette()


func _draw_crt_scanlines() -> void:
	var y := 0.0
	while y < size.y:
		draw_line(Vector2(0.0, y), Vector2(size.x, y), Color(0.05, 0.18, 0.07, 0.10), 1.0)
		y += 4.0


func _seed_initial_lines() -> void:
	_seeded = true
	var x := 0.0
	while x < size.x:
		_spawn_vertical_line(x)
		x += vertical_spacing
	var y := 0.0
	while y < size.y:
		_spawn_horizontal_line(y)
		y += horizontal_spacing


func _spawn_vertical_line(start_pos: float = -1.0) -> void:
	var line_width := _rng.randf_range(1.4, 5.0)
	_lines.append({
		"type": "v",
		"pos": start_pos if start_pos >= 0.0 else -line_width,
		"speed": speed * _rng.randf_range(0.82, 1.28),
		"base_width": line_width,
		"phase": _rng.randf_range(0.0, TAU),
		"alpha": _rng.randf_range(0.22, 0.56)
	})


func _spawn_horizontal_line(start_pos: float = -1.0) -> void:
	var line_width := _rng.randf_range(1.0, 4.2)
	_lines.append({
		"type": "h",
		"pos": start_pos if start_pos >= 0.0 else -line_width,
		"speed": speed * _rng.randf_range(0.70, 1.10),
		"base_width": line_width,
		"phase": _rng.randf_range(0.0, TAU),
		"alpha": _rng.randf_range(0.10, 0.32)
	})


func _update_lines(delta: float) -> void:
	var alive: Array[Dictionary] = []
	for line in _lines:
		var line_type := String(line["type"])
		var pos := float(line["pos"]) + float(line["speed"]) * delta
		line["pos"] = pos
		var limit := size.x if line_type == "v" else size.y
		if pos <= limit + float(line["base_width"]) * 2.0:
			alive.append(line)
	_lines = alive


func _draw_generated_lines() -> void:
	var t := Time.get_ticks_msec() * 0.0014
	for line in _lines:
		var line_type := String(line["type"])
		var wave := (sin(t + float(line["phase"])) + 1.0) * 0.5
		var line_width := float(line["base_width"]) * lerpf(0.55, 1.65, wave)
		var alpha := float(line["alpha"]) * lerpf(0.55, 1.12, wave)
		var pos := float(line["pos"])
		if line_type == "v":
			draw_rect(Rect2(Vector2(pos, 0.0), Vector2(line_width, size.y)), Color(0.11, 0.9, 0.18, alpha), true)
			draw_rect(Rect2(Vector2(pos - line_width, 0.0), Vector2(line_width * 3.0, size.y)), Color(0.18, 1.0, 0.26, alpha * 0.16), true)
		else:
			draw_rect(Rect2(Vector2(0.0, pos), Vector2(size.x, line_width)), Color(0.12, 0.85, 0.18, alpha), true)
			draw_rect(Rect2(Vector2(0.0, pos - line_width), Vector2(size.x, line_width * 3.0)), Color(0.18, 1.0, 0.26, alpha * 0.12), true)


func _draw_vignette() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, 42.0)), Color(0.0, 0.0, 0.0, 0.18), true)
	draw_rect(Rect2(Vector2(0.0, size.y - 42.0), Vector2(size.x, 42.0)), Color(0.0, 0.0, 0.0, 0.22), true)
