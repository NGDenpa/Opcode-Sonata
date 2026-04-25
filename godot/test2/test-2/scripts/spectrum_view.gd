extends Control
class_name SpectrumView

@export var bar_count: int = 28
var pulse: float = 0.0
var _values: PackedFloat32Array = PackedFloat32Array()

func _ready() -> void:
	_values.resize(bar_count)
	for i in range(bar_count):
		_values[i] = 0.15

func kick() -> void:
	pulse = 1.0

func _process(delta: float) -> void:
	pulse = maxf(0.0, pulse - delta * 2.2)
	for i in range(bar_count):
		var base := 0.15 + 0.08 * sin((Time.get_ticks_msec() * 0.004) + i * 0.37)
		var boost := pulse * (0.25 + randf() * 0.65)
		_values[i] = clampf(base + boost, 0.05, 1.0)
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.02, 0.08, 0.04, 0.16), true)
	var gap := 3.0
	var bw := (size.x - gap * float(bar_count + 1)) / float(bar_count)
	var center_y := size.y * 0.5
	draw_line(Vector2(0.0, center_y), Vector2(size.x, center_y), Color(0.45, 1.0, 0.5, 0.08), 1.0)
	for i in range(bar_count):
		var h := _values[i] * (size.y - 10.0)
		var x := gap + i * (bw + gap)
		var y := center_y - h * 0.5
		draw_rect(Rect2(x, y, bw, h), Color(0.45, 1.0, 0.5, 0.20 + pulse * 0.22), true)
