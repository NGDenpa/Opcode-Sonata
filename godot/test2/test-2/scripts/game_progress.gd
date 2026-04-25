extends RefCounted
class_name GameProgress

static var max_unlocked_level: int = 0
static var requested_level: int = 0


static func unlock(level_idx: int) -> void:
	max_unlocked_level = maxi(max_unlocked_level, level_idx)


static func can_open(level_idx: int) -> bool:
	if is_debug_enabled():
		return true
	return level_idx <= max_unlocked_level


static func request_level(level_idx: int) -> void:
	requested_level = maxi(0, level_idx)


static func is_debug_enabled() -> bool:
	return bool(ProjectSettings.get_setting("machine_loop/debug", false))
