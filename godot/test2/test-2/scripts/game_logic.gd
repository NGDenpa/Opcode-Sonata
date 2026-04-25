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
var last_step_feedback := {
	"fired_turrets": [],
	"rotated_pipes": [],
	"bullet_trails": []
}

func load_level(level: Dictionary) -> void:
	tick = 0
	bullets.clear()
	_clear_step_feedback()
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
			"initial_rotation": int(p["rotation"]) % 360,
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
	_clear_step_feedback()
	for t in turrets:
		t["idx"] = 0
	for p in pipes:
		p["idx"] = 0
		p["rotation"] = int(p.get("initial_rotation", p["rotation"])) % 360
	for t in targets:
		t["hits"] = 0

func step_tick() -> void:
	_clear_step_feedback()
	for p in pipes:
		var loop: Array = p["loop"]
		var idx: int = int(p["idx"])
		var delta: int = int(loop[idx % loop.size()])
		p["idx"] = idx + 1
		p["rotation"] = (int(p["rotation"]) + delta + 360) % 360
		if delta != 0:
			(last_step_feedback["rotated_pipes"] as Array).append({
				"id": int(p["id"]),
				"col": int(p["col"]),
				"row": int(p["row"]),
				"delta": delta
			})

	for i in range(turrets.size()):
		var t: Dictionary = turrets[i]
		var loop: Array = t["loop"]
		var idx: int = int(t["idx"])
		var fire: bool = bool(loop[idx % loop.size()])
		t["idx"] = idx + 1
		if fire:
			(last_step_feedback["fired_turrets"] as Array).append({
				"id": i + 1,
				"col": int(t["col"]),
				"row": int(t["row"])
			})
			bullets.append({"col": int(t["col"]), "row": int(t["row"]), "dir": int(t["dir"]), "alive": true})

	for b in bullets:
		if not bool(b["alive"]):
			continue
		var from_pos := Vector2i(int(b["col"]), int(b["row"]))
		var v: Vector2i = DIR_VEC[int(b["dir"])]
		var nc := int(b["col"]) + v.x
		var nr := int(b["row"]) + v.y
		if nc < 0 or nc >= cols or nr < 0 or nr >= rows:
			b["alive"] = false
			continue
		var pipe := get_pipe_at(nc, nr)
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
		(last_step_feedback["bullet_trails"] as Array).append({
			"from": from_pos,
			"to": Vector2i(int(b["col"]), int(b["row"])),
			"alive": bool(b["alive"])
		})

	bullets = bullets.filter(func(item): return bool(item["alive"]))
	tick += 1

func is_win() -> bool:
	if targets.is_empty():
		return false
	for t in targets:
		if int(t["hits"]) < int(t["required"]):
			return false
	return true

func get_pipe_at(col: int, row: int) -> Dictionary:
	for p in pipes:
		if int(p["col"]) == col and int(p["row"]) == row:
			return p
	return {}


func is_at_initial_state() -> bool:
	if tick != 0 or not bullets.is_empty():
		return false
	for t in turrets:
		if int(t["idx"]) != 0:
			return false
	for p in pipes:
		if int(p["idx"]) != 0:
			return false
		if int(p["rotation"]) != int(p.get("initial_rotation", p["rotation"])):
			return false
	for t in targets:
		if int(t["hits"]) != 0:
			return false
	return true


func turret_action_snapshot() -> Array:
	var snapshot := []
	for i in range(turrets.size()):
		var t: Dictionary = turrets[i]
		var script := String(t.get("loop_script", ""))
		var length := maxi(script.length(), 1)
		var idx := int(t.get("idx", 0))
		var active_idx := 0 if idx == 0 else (idx - 1 + length) % length
		var did_fire := false
		for fired in last_step_feedback["fired_turrets"]:
			if int(fired["id"]) == i + 1:
				did_fire = true
				break
		snapshot.append({
			"id": i + 1,
			"script": script,
			"active_idx": active_idx,
			"next_idx": idx % length,
			"did_fire": did_fire
		})
	return snapshot


func _clear_step_feedback() -> void:
	last_step_feedback = {
		"fired_turrets": [],
		"rotated_pipes": [],
		"bullet_trails": []
	}


func unified_loop_length() -> int:
	var m := 1
	for t in turrets:
		m = maxi(m, (t["loop"] as Array).size())
	return maxi(m, 4)


func set_pipe_loop_by_id(pipe_id: int, csv: String) -> String:
	var parts := csv.split(",")
	var tokens: Array[String] = []
	for p in parts:
		var t := p.strip_edges().to_upper()
		if t.is_empty():
			t = "-"
		if t != "R" and t != "L" and t != "-":
			return "无效：只允许 R / L / -"
		tokens.append(t)
	var need := unified_loop_length()
	while tokens.size() < need:
		tokens.append("-")
	while tokens.size() > need:
		tokens.pop_back()
	var joined := ""
	for i in range(tokens.size()):
		if i > 0:
			joined += ","
		joined += tokens[i]
	for p in pipes:
		if int(p["id"]) == pipe_id:
			p["loop_script"] = joined
			p["loop"] = _parse_pipe(joined)
			p["idx"] = 0
			return ""
	return "未找到导线"


func rotate_pipe_at(col: int, row: int, delta_deg: int) -> void:
	for p in pipes:
		if int(p["col"]) == col and int(p["row"]) == row:
			p["rotation"] = (int(p["rotation"]) + delta_deg + 360) % 360
			return

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
