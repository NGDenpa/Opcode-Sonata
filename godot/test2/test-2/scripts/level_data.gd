extends RefCounted
class_name LevelData

static func all_levels() -> Array:
	return [
		{
			"name": "教程 1 - 直线射击",
			"bpm": 100.0,
			"tick_rate_ms": 500.0,
			"letter_title": "维修委托 #01：小熊不唱歌了",
			"letter_body": "维修工你好：\n\n我的小熊以前一按肚子就会唱歌，今天突然一点声音都没有了 :(\n可以请你帮我把声音线路修好吗？\n\n—— 小雨（7岁）",
			"turrets": [{"col": 1, "row": 5, "dir": 1, "loop": "1---"}],
			"pipes": [],
			"targets": [{"col": 8, "row": 5, "required": 5}]
		},
		{
			"name": "教程 2 - 静态弯管",
			"bpm": 100.0,
			"tick_rate_ms": 500.0,
			"letter_title": "维修委托 #02：爷爷的唱片机",
			"letter_body": "维修工你好：\n\n这是爷爷留下来的老唱片机，最近唱到一半就断音。\n我想在他生日那天，再听一次那首老歌。\n\n—— 阿川",
			"turrets": [{"col": 1, "row": 2, "dir": 1, "loop": "1---"}],
			"pipes": [{"col": 6, "row": 2, "shape": "L", "rotation": 0, "loop": "-"}],
			"targets": [{"col": 6, "row": 7, "required": 5}]
		},
		{
			"name": "教程 3 - 双弯导流",
			"bpm": 95.0,
			"tick_rate_ms": 560.0,
			"letter_title": "维修委托 #03：旧收音机",
			"letter_body": "这台旧收音机有时有声，有时无声。请把两处转向线路都打通。",
			"turrets": [{"col": 1, "row": 3, "dir": 1, "loop": "1---"}],
			"pipes": [
				{"col": 4, "row": 3, "shape": "L", "rotation": 180, "loop": "-,-,-,-"},
				{"col": 4, "row": 6, "shape": "L", "rotation": 270, "loop": "-,-,-,-"}
			],
			"targets": [{"col": 8, "row": 6, "required": 6}]
		},
		{
			"name": "教程 4 - 旋转水管",
			"bpm": 90.0,
			"tick_rate_ms": 600.0,
			"letter_title": "维修委托 #04：节拍播放器",
			"letter_body": "它会按节拍亮灯，但转向模块卡住了。请让时序对齐。",
			"turrets": [{"col": 1, "row": 5, "dir": 1, "loop": "1-1-"}],
			"pipes": [
				{"col": 4, "row": 5, "shape": "I", "rotation": 90, "loop": "-,-,-,-"},
				{"col": 6, "row": 5, "shape": "L", "rotation": 180, "loop": "R,-,-,-"}
			],
			"targets": [{"col": 6, "row": 8, "required": 8}]
		}
	]
