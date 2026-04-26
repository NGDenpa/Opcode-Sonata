extends Control
class_name TurretActionTrack

const TRACK_FONT := preload("res://font/little-pixel.ttf")

var _snapshot: Array = []
var _pulse := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process(false)


func set_snapshot(snapshot: Array) -> void:
	_snapshot = snapshot
	_pulse = 1.0
	set_process(true)
	queue_redraw()


func _process(delta: float) -> void:
	_pulse = maxf(0.0, _pulse - delta * 3.8)
	if _pulse <= 0.0:
		set_process(false)
	queue_redraw()


func _draw() -> void:
	var bg := Rect2(Vector2.ZERO, size)
	draw_rect(bg, Color(0.015, 0.055, 0.025, 0.86), true)
	draw_rect(bg, Color(0.20, 0.95, 0.38, 0.46), false, 1.0)
	_draw_scanlines(bg)
	if _snapshot.is_empty():
		draw_string(TRACK_FONT, Vector2(10, size.y * 0.5 + 5.0), "NO SIGNAL", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.28, 0.85, 0.38, 0.72))
		return
	var available_h := maxf(12.0, size.y - 10.0)
	var row_h := minf(30.0, available_h / float(maxi(_snapshot.size(), 1)))
	var content_h := row_h * float(_snapshot.size())
	var y := maxf(5.0, (size.y - content_h) * 0.5)
	for item in _snapshot:
		if y + row_h > size.y - 2.0:
			break
		_draw_turret_row(item, y, row_h)
		y += row_h


func _draw_scanlines(rect: Rect2) -> void:
	var y := rect.position.y + 4.0
	while y < rect.end.y:
		draw_line(Vector2(rect.position.x, y), Vector2(rect.end.x, y), Color(0.1, 0.35, 0.16, 0.16), 1.0)
		y += 6.0


func _draw_turret_row(item: Dictionary, y: float, row_h: float) -> void:
	var label := "T%d" % int(item.get("id", 0))
	var font_size := int(clampf(row_h * 0.45, 8.0, 13.0))
	draw_string(TRACK_FONT, Vector2(10, y + row_h * 0.58), label, HORIZONTAL_ALIGNMENT_LEFT, 34, font_size, Color(0.65, 1.0, 0.67))
	var script := String(item.get("script", ""))
	if script.is_empty():
		return
	var active_idx := int(item.get("active_idx", 0))
	var did_fire := bool(item.get("did_fire", false))
	var x := 48.0
	var gap := 2.0
	var cell_w := minf(24.0, maxf(5.0, (size.x - x - 8.0) / float(maxi(script.length(), 1))))
	var cell_h := clampf(row_h - 8.0, 7.0, 20.0)
	for i in range(script.length()):
		var action := script.substr(i, 1)
		var r := Rect2(Vector2(x + float(i) * cell_w, y + 1.0), Vector2(maxf(2.0, cell_w - gap), cell_h))
		var is_one := action == "1"
		var is_active := i == active_idx
		var fill := Color(0.03, 0.16, 0.07, 0.92)
		var border := Color(0.22, 0.9, 0.36, 0.42)
		if is_one:
			fill = Color(0.08, 0.36, 0.14, 0.92)
			border = Color(0.42, 1.0, 0.52, 0.72)
		if is_active:
			var glow := 0.55 + _pulse * 0.45
			fill = Color(0.14, 0.78, 0.25, 0.62 + _pulse * 0.22) if did_fire else Color(0.08, 0.38, 0.16, 0.72)
			border = Color(0.72, 1.0, 0.72, glow)
			draw_rect(r.grow(4.0 + _pulse * 4.0), Color(0.24, 1.0, 0.34, 0.10 + _pulse * 0.18), false, 2.0)
		draw_rect(r, fill, true)
		draw_rect(r, border, false, 1.0)
		if cell_w >= 9.0 and cell_h >= 10.0:
			draw_string(
				TRACK_FONT,
				Vector2(r.position.x + r.size.x * 0.5 - 4.0, r.position.y + cell_h * 0.72),
				action,
				HORIZONTAL_ALIGNMENT_LEFT,
				-1,
				int(mini(font_size, 12)),
				Color(0.78, 1.0, 0.75, 0.95) if is_one else Color(0.28, 0.7, 0.36, 0.8)
			)
