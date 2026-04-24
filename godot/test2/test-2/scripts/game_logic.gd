extends RefCounted
class_name GameLogic

const DIR_UP := 0
const DIR_RIGHT := 1
const DIR_DOWN := 2
const DIR_LEFT := 3
const DIR_VEC := [Vector2i(0, -1), Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0)]

var cols: int = 10
var rows: int = 10
var tick: int = 0
var turrets: Array = []
var pipes: Array = []
var bullets: Array = []
var targets: Array = []

func load_level(level: Dictionary) -> void:
	tick = 0
	bullets.clear()
	turrets.clear()
	pipes.clear()
	targets.clear()
	for t in level.get("turrets", []):
		turrets.append({
			"col": int(t["col"]),
			"row": int(t["row"]),
			"dir": int(t["dir"]),
			"loop_script": String(t["loop"]),
			"loop": _parse_turret(String(t["loop"])),
			"idx": 0
		})
	for i in range(level.get("pipes", []).size()):
		var p: Dictionary = level.get("pipes", [])[i]
		pipes.append({
			"id": i,
			"col": int(p["col"]),
			"row": int(p["row"]),
			"shape": String(p["shape"]),
			"rotation": int(p["rotation"]) % 360,
			"loop_script": String(p["loop"]),
			"loop": _parse_pipe(String(p["loop"])),
			"idx": 0
		})
	for t in level.get("targets", []):
		targets.append({
			"col": int(t["col"]),
			"row": int(t["row"]),
			"required": int(t["required"]),
			"hits": 0
		})

func reset() -> void:
	tick = 0
	bullets.clear()
	for t in turrets:
		t["idx"] = 0
	for p in pipes:
		p["idx"] = 0
	for t in targets:
		t["hits"] = 0

func step_tick() -> void:
	for p in pipes:
		var loop: Array = p["loop"]
		var idx: int = int(p["idx"])
		var delta: int = int(loop[idx % loop.size()])
		p["idx"] = idx + 1
		p["rotation"] = (int(p["rotation"]) + delta + 360) % 360

	for t in turrets:
		var loop: Array = t["loop"]
		var idx: int = int(t["idx"])
		var fire: bool = bool(loop[idx % loop.size()])
		t["idx"] = idx + 1
		if fire:
			bullets.append({"col": int(t["col"]), "row": int(t["row"]), "dir": int(t["dir"]), "alive": true})

	for b in bullets:
		if not bool(b["alive"]):
			continue
		var v: Vector2i = DIR_VEC[int(b["dir"])]
		var nc := int(b["col"]) + v.x
		var nr := int(b["row"]) + v.y
		if nc < 0 or nc >= cols or nr < 0 or nr >= rows:
			b["alive"] = false
			continue
		var pipe := _get_pipe_at(nc, nr)
		if not pipe.is_empty():
			var entry: int = (int(b["dir"]) + 2) % 4
			var exit_dir: int = _get_pipe_exit(String(pipe["shape"]), int(pipe["rotation"]), entry)
			if exit_dir == -1:
				b["alive"] = false
				continue
			b["col"] = nc
			b["row"] = nr
			b["dir"] = exit_dir
		else:
			b["col"] = nc
			b["row"] = nr

		var target := _get_target_at(int(b["col"]), int(b["row"]))
		if not target.is_empty():
			target["hits"] = int(target["hits"]) + 1
			b["alive"] = false

	bullets = bullets.filter(func(item): return bool(item["alive"]))
	tick += 1

func is_win() -> bool:
	if targets.is_empty():
		return false
	for t in targets:
		if int(t["hits"]) < int(t["required"]):
			return false
	return true

func _get_pipe_at(col: int, row: int) -> Dictionary:
	for p in pipes:
		if int(p["col"]) == col and int(p["row"]) == row:
			return p
	return {}

func _get_target_at(col: int, row: int) -> Dictionary:
	for t in targets:
		if int(t["col"]) == col and int(t["row"]) == row:
			return t
	return {}

func _parse_turret(script: String) -> Array:
	var clean := script.strip_edges().replace(" ", "")
	if clean.is_empty():
		return [false]
	var arr: Array = []
	for c in clean:
		arr.append(c == "1")
	return arr

func _parse_pipe(script: String) -> Array:
	var clean := script.strip_edges().replace(" ", "")
	if clean.is_empty():
		return [0]
	var arr: Array = []
	for token in clean.split(","):
		if token == "R":
			arr.append(90)
		elif token == "L":
			arr.append(-90)
		else:
			arr.append(0)
	return arr

func _get_pipe_exit(shape: String, rotation: int, entry_dir: int) -> int:
	var steps := int(((rotation % 360) + 360) % 360 / 90)
	var local_entry := (entry_dir - steps + 4) % 4
	var local_exit := -1
	match shape:
		"I":
			if local_entry == 0: local_exit = 2
			elif local_entry == 2: local_exit = 0
			elif local_entry == 1: local_exit = 3
			elif local_entry == 3: local_exit = 1
		"L":
			if local_entry == 0: local_exit = 1
			elif local_entry == 1: local_exit = 0
		"T":
			if local_entry == 3: local_exit = 1
			elif local_entry == 1: local_exit = 3
		"+":
			local_exit = (local_entry + 2) % 4
	if local_exit == -1:
		return -1
	return (local_exit + steps) % 4
