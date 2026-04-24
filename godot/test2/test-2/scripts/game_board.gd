extends Control
class_name GameBoard

@export var cell_size: int = 56
@export var grid_cols: int = 10
@export var grid_rows: int = 10

var logic: GameLogic

func _ready() -> void:
	custom_minimum_size = Vector2(grid_cols * cell_size, grid_rows * cell_size)

func _draw() -> void:
	var bg := Color(0.02, 0.07, 0.04, 0.95)
	draw_rect(Rect2(Vector2.ZERO, size), bg, true)
	_draw_grid()
	if logic == null:
		return
	_draw_targets()
	_draw_pipes()
	_draw_turrets()
	_draw_bullets()

func _draw_grid() -> void:
	var c := Color(0.2, 0.8, 0.4, 0.20)
	for x in range(grid_cols + 1):
		draw_line(Vector2(x * cell_size, 0), Vector2(x * cell_size, grid_rows * cell_size), c, 1.0)
	for y in range(grid_rows + 1):
		draw_line(Vector2(0, y * cell_size), Vector2(grid_cols * cell_size, y * cell_size), c, 1.0)

func _draw_turrets() -> void:
	for t in logic.turrets:
		var center := Vector2((int(t["col"]) + 0.5) * cell_size, (int(t["row"]) + 0.5) * cell_size)
		draw_circle(center, cell_size * 0.24, Color(0.45, 1.0, 0.55))
		var dir_idx := int(t["dir"])
		var dir_vec: Vector2 = Vector2(GameLogic.DIR_VEC[dir_idx].x, GameLogic.DIR_VEC[dir_idx].y)
		draw_line(center, center + dir_vec * cell_size * 0.35, Color(0.8, 1, 0.8), 3.0)

func _draw_targets() -> void:
	for t in logic.targets:
		var center := Vector2((int(t["col"]) + 0.5) * cell_size, (int(t["row"]) + 0.5) * cell_size)
		draw_arc(center, cell_size * 0.27, 0, TAU, 32, Color(0.2, 0.95, 0.55), 2.0)
		draw_arc(center, cell_size * 0.13, 0, TAU, 24, Color(0.2, 0.95, 0.55), 2.0)

func _draw_bullets() -> void:
	for b in logic.bullets:
		var center := Vector2((int(b["col"]) + 0.5) * cell_size, (int(b["row"]) + 0.5) * cell_size)
		draw_circle(center, cell_size * 0.10, Color(0.9, 1.0, 0.55))

func _draw_pipes() -> void:
	for p in logic.pipes:
		var center := Vector2((int(p["col"]) + 0.5) * cell_size, (int(p["row"]) + 0.5) * cell_size)
		var half := cell_size * 0.35
		var col := Color(0.18, 0.95, 0.45)
		match String(p["shape"]):
			"I":
				_draw_rot_line(center, Vector2(0, -half), Vector2(0, half), int(p["rotation"]), col)
			"L":
				_draw_rot_line(center, Vector2(0, -half), Vector2.ZERO, int(p["rotation"]), col)
				_draw_rot_line(center, Vector2.ZERO, Vector2(half, 0), int(p["rotation"]), col)
			"T":
				_draw_rot_line(center, Vector2(-half, 0), Vector2(half, 0), int(p["rotation"]), col)
				_draw_rot_line(center, Vector2.ZERO, Vector2(0, half), int(p["rotation"]), col)
			"+":
				_draw_rot_line(center, Vector2(0, -half), Vector2(0, half), int(p["rotation"]), col)
				_draw_rot_line(center, Vector2(-half, 0), Vector2(half, 0), int(p["rotation"]), col)

func _draw_rot_line(center: Vector2, p1: Vector2, p2: Vector2, deg: int, col: Color) -> void:
	var rad := deg_to_rad(float(deg))
	draw_line(center + p1.rotated(rad), center + p2.rotated(rad), col, 8.0)
