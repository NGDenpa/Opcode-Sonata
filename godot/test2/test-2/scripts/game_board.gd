extends Control
class_name GameBoard

signal pipe_clicked(pipe: Dictionary, shift_pressed: bool, click_global: Vector2)

@export var cell_size: int = 56
@export var grid_cols: int = 10
@export var grid_rows: int = 10

var logic: GameLogic
var _step_feedback := {}
var _feedback_life := 0.0
var _pipe_anim_elapsed := 0.0
var _pipe_anim_duration := 0.0
var _bullet_anim_elapsed := 0.0
var _bullet_anim_duration := 0.0

func _ready() -> void:
	custom_minimum_size = Vector2(0, 0)
	resized.connect(_on_resized)
	set_process(false)

func _process(delta: float) -> void:
	_feedback_life = maxf(0.0, _feedback_life - delta * 2.6)
	_pipe_anim_elapsed = minf(_pipe_anim_elapsed + delta, _pipe_anim_duration)
	_bullet_anim_elapsed = minf(_bullet_anim_elapsed + delta, _bullet_anim_duration)
	if _feedback_life <= 0.0 and not _is_pipe_animating() and not _is_bullet_animating():
		set_process(false)
	queue_redraw()

func _on_resized() -> void:
	queue_redraw()

func set_step_feedback(feedback: Dictionary, tick_duration: float = 0.5) -> void:
	_step_feedback = feedback.duplicate(true)
	_feedback_life = 1.0
	_pipe_anim_elapsed = 0.0
	_bullet_anim_elapsed = 0.0
	_pipe_anim_duration = maxf(0.01, tick_duration * 0.20)
	_bullet_anim_duration = maxf(0.01, tick_duration * 0.35)
	set_process(true)
	queue_redraw()

func _draw() -> void:
	var cell := _effective_cell_size()
	if cell <= 1.0:
		return
	var origin := _board_origin(cell)
	_draw_grid(cell, origin)
	if logic == null:
		return
	_draw_targets(cell, origin)
	_draw_pipe_feedback(cell, origin)
	_draw_pipes(cell, origin)
	_draw_bullet_trails(cell, origin)
	_draw_turrets(cell, origin)
	_draw_turret_feedback(cell, origin)
	_draw_bullets(cell, origin)

func _draw_grid(cell: float, origin: Vector2) -> void:
	var c := Color(0.25, 0.95, 0.45, 0.55)
	for x in range(grid_cols + 1):
		draw_line(
			origin + Vector2(x * cell, 0),
			origin + Vector2(x * cell, grid_rows * cell),
			c,
			1.0
		)
	for y in range(grid_rows + 1):
		draw_line(
			origin + Vector2(0, y * cell),
			origin + Vector2(grid_cols * cell, y * cell),
			c,
			1.0
		)

func _draw_turrets(cell: float, origin: Vector2) -> void:
	for i in range(logic.turrets.size()):
		var t: Dictionary = logic.turrets[i]
		var center := origin + Vector2((int(t["col"]) + 0.5) * cell, (int(t["row"]) + 0.5) * cell)
		draw_circle(center, cell * 0.24, Color(0.45, 1.0, 0.55))
		var dir_idx := int(t["dir"])
		var dir_vec: Vector2 = Vector2(GameLogic.DIR_VEC[dir_idx].x, GameLogic.DIR_VEC[dir_idx].y)
		draw_line(center, center + dir_vec * cell * 0.35, Color(0.8, 1, 0.8), maxf(2.0, cell * 0.06))
		var label := str(i + 1)
		var label_size := int(maxf(10.0, cell * 0.28))
		draw_circle(center, cell * 0.16, Color(0.0, 0.07, 0.025, 0.72))
		draw_string(
			ThemeDB.fallback_font,
			center + Vector2(-cell * 0.12, cell * 0.09),
			label,
			HORIZONTAL_ALIGNMENT_CENTER,
			cell * 0.24,
			label_size,
			Color(0.86, 1.0, 0.72, 0.96)
		)

func _draw_targets(cell: float, origin: Vector2) -> void:
	for t in logic.targets:
		var center := origin + Vector2((int(t["col"]) + 0.5) * cell, (int(t["row"]) + 0.5) * cell)
		var remaining: int = maxi(0, int(t["required"]) - int(t["hits"]))
		draw_arc(center, cell * 0.27, 0, TAU, 32, Color(0.2, 0.95, 0.55), maxf(1.5, cell * 0.04))
		draw_arc(center, cell * 0.13, 0, TAU, 24, Color(0.2, 0.95, 0.55), maxf(1.2, cell * 0.03))
		draw_circle(center, cell * 0.20, Color(0.0, 0.06, 0.025, 0.78))
		draw_string(
			ThemeDB.fallback_font,
			center + Vector2(-cell * 0.23, cell * 0.11),
			str(remaining),
			HORIZONTAL_ALIGNMENT_CENTER,
			cell * 0.46,
			int(maxf(12.0, cell * 0.28)),
			Color(0.72, 1.0, 0.64, 0.95)
		)

func _draw_bullets(cell: float, origin: Vector2) -> void:
	if _is_bullet_animating():
		return
	for b in logic.bullets:
		var center := origin + Vector2((int(b["col"]) + 0.5) * cell, (int(b["row"]) + 0.5) * cell)
		draw_circle(center, cell * 0.18, Color(0.85, 1.0, 0.24, 0.18))
		draw_circle(center, cell * 0.10, Color(0.9, 1.0, 0.55))

func _draw_pipes(cell: float, origin: Vector2) -> void:
	for p in logic.pipes:
		var center := origin + Vector2((int(p["col"]) + 0.5) * cell, (int(p["row"]) + 0.5) * cell)
		var half := cell * 0.35
		var col := Color(0.18, 0.95, 0.45)
		var rotation := _pipe_display_rotation(p)
		match String(p["shape"]):
			"I":
				_draw_rot_line(center, Vector2(0, -half), Vector2(0, half), rotation, col, cell)
			"L":
				_draw_rot_line(center, Vector2(0, -half), Vector2.ZERO, rotation, col, cell)
				_draw_rot_line(center, Vector2.ZERO, Vector2(half, 0), rotation, col, cell)
			"T":
				_draw_rot_line(center, Vector2(-half, 0), Vector2(half, 0), rotation, col, cell)
				_draw_rot_line(center, Vector2.ZERO, Vector2(0, half), rotation, col, cell)
			"+":
				_draw_rot_line(center, Vector2(0, -half), Vector2(0, half), rotation, col, cell)
				_draw_rot_line(center, Vector2(-half, 0), Vector2(half, 0), rotation, col, cell)

func _draw_rot_line(center: Vector2, p1: Vector2, p2: Vector2, deg: float, col: Color, cell: float) -> void:
	var rad := deg_to_rad(deg)
	draw_line(center + p1.rotated(rad), center + p2.rotated(rad), col, maxf(3.0, cell * 0.15))

func _draw_turret_feedback(cell: float, origin: Vector2) -> void:
	if _feedback_life <= 0.0 or not _step_feedback.has("fired_turrets"):
		return
	for t in _step_feedback["fired_turrets"]:
		var center := origin + Vector2((int(t["col"]) + 0.5) * cell, (int(t["row"]) + 0.5) * cell)
		var alpha := 0.55 * _feedback_life
		draw_arc(center, cell * (0.28 + (1.0 - _feedback_life) * 0.32), 0, TAU, 32, Color(0.8, 1.0, 0.42, alpha), maxf(2.0, cell * 0.05))
		draw_circle(center, cell * 0.30, Color(0.55, 1.0, 0.28, 0.14 * _feedback_life))

func _draw_pipe_feedback(cell: float, origin: Vector2) -> void:
	if _feedback_life <= 0.0 or not _step_feedback.has("rotated_pipes"):
		return
	for p in _step_feedback["rotated_pipes"]:
		var top_left := origin + Vector2(int(p["col"]) * cell, int(p["row"]) * cell)
		var rect := Rect2(top_left + Vector2(cell * 0.12, cell * 0.12), Vector2(cell * 0.76, cell * 0.76))
		draw_rect(rect.grow((1.0 - _feedback_life) * cell * 0.08), Color(0.38, 1.0, 0.52, 0.18 * _feedback_life), false, maxf(2.0, cell * 0.04))
		var marker := "R" if int(p.get("delta", 0)) > 0 else "L"
		draw_string(ThemeDB.fallback_font, rect.position + Vector2(4, 13), marker, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(0.65, 1.0, 0.65, 0.82 * _feedback_life))

func _draw_bullet_trails(cell: float, origin: Vector2) -> void:
	if _feedback_life <= 0.0 or not _step_feedback.has("bullet_trails"):
		return
	var progress := _motion_progress(_anim_ratio(_bullet_anim_elapsed, _bullet_anim_duration))
	for trail in _step_feedback["bullet_trails"]:
		var from_pos: Vector2i = trail["from"]
		var to_pos: Vector2i = trail["to"]
		var a := origin + Vector2((from_pos.x + 0.5) * cell, (from_pos.y + 0.5) * cell)
		var b := origin + Vector2((to_pos.x + 0.5) * cell, (to_pos.y + 0.5) * cell)
		var head := a.lerp(b, progress)
		draw_line(a, head, Color(0.9, 1.0, 0.28, 0.42 * _feedback_life), maxf(2.0, cell * 0.08))
		draw_circle(head, cell * 0.18, Color(0.9, 1.0, 0.32, 0.20 * _feedback_life))
		draw_circle(head, cell * 0.10, Color(0.9, 1.0, 0.55, 0.95))

func _effective_cell_size() -> float:
	var pad := 10.0
	var avail_w := maxf(10.0, size.x - pad * 2.0)
	var avail_h := maxf(10.0, size.y - pad * 2.0)
	return floor(min(avail_w / float(grid_cols), avail_h / float(grid_rows)))

func _board_origin(cell: float) -> Vector2:
	var board_w := cell * float(grid_cols)
	var board_h := cell * float(grid_rows)
	return Vector2((size.x - board_w) * 0.5, (size.y - board_h) * 0.5)


func _pipe_display_rotation(pipe: Dictionary) -> float:
	var current := float(pipe["rotation"])
	if not _is_pipe_animating() or not _step_feedback.has("rotated_pipes"):
		return current
	for rotated in _step_feedback["rotated_pipes"]:
		if int(rotated.get("id", -1)) == int(pipe.get("id", -2)):
			var delta := float(rotated.get("delta", 0))
			var start := current - delta
			return start + delta * _motion_progress(_anim_ratio(_pipe_anim_elapsed, _pipe_anim_duration))
	return current


func _is_pipe_animating() -> bool:
	return _step_feedback.has("rotated_pipes") and not _step_feedback["rotated_pipes"].is_empty() and _pipe_anim_elapsed < _pipe_anim_duration


func _is_bullet_animating() -> bool:
	return _step_feedback.has("bullet_trails") and not _step_feedback["bullet_trails"].is_empty() and _bullet_anim_elapsed < _bullet_anim_duration


func _anim_ratio(elapsed: float, duration: float) -> float:
	if duration <= 0.0:
		return 1.0
	return clampf(elapsed / duration, 0.0, 1.0)


func _motion_progress(t: float) -> float:
	if t <= 0.7:
		return t
	var u := (t - 0.7) / 0.3
	return 0.7 + 0.3 * (-u * u * u + u * u + u)


func grid_pos_from_local(local_pos: Vector2) -> Vector2i:
	var cell := _effective_cell_size()
	if cell <= 1.0:
		return Vector2i(-1, -1)
	var origin := _board_origin(cell)
	var rel := local_pos - origin
	if rel.x < 0.0 or rel.y < 0.0:
		return Vector2i(-1, -1)
	var cx := int(floor(rel.x / cell))
	var cy := int(floor(rel.y / cell))
	if cx < 0 or cy < 0 or cx >= grid_cols or cy >= grid_rows:
		return Vector2i(-1, -1)
	return Vector2i(cx, cy)


func _gui_input(event: InputEvent) -> void:
	if logic == null:
		return
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			var g := grid_pos_from_local(mb.position)
			if g.x < 0:
				return
			var pipe := logic.get_pipe_at(g.x, g.y)
			if pipe.is_empty():
				return
			accept_event()
			pipe_clicked.emit(pipe, mb.shift_pressed, mb.global_position)
