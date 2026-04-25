extends RefCounted
class_name LevelData

static func all_levels() -> Array:
	return [
		{
			"name": "教程 1 - 脉冲与洞",
			"bpm": 100.0,
			"tick_rate_ms": 500.0,
			"letter_title": "维修委托 #01：小熊不唱歌了",
			"letter_body": "维修工你好：\n\n先确认最基础的脉冲。炮台动作里的 1 会发射，- 会停一拍。让脉冲填满右侧的洞。\n\n—— 小雨（7岁）",
			"turrets": [{"col": 1, "row": 5, "dir": 1, "loop": "1---"}],
			"pipes": [],
			"targets": [{"col": 8, "row": 5, "required": 2}]
		},
		{
			"name": "教程 2 - 节拍密度",
			"bpm": 100.0,
			"tick_rate_ms": 500.0,
			"letter_title": "维修委托 #02：爷爷的唱片机",
			"letter_body": "维修工你好：\n\n这台唱片机不是线路断了，而是节拍太疏。观察炮台动作轨道：1 越多，脉冲越密。\n\n—— 阿川",
			"turrets": [{"col": 1, "row": 5, "dir": 1, "loop": "1-1-"}],
			"pipes": [],
			"targets": [{"col": 8, "row": 5, "required": 4}]
		},
		{
			"name": "教程 3 - 认识弯管",
			"bpm": 95.0,
			"tick_rate_ms": 540.0,
			"letter_title": "维修委托 #03：旧收音机",
			"letter_body": "这台旧收音机的脉冲需要拐弯。弯管会把进入的脉冲转到另一个方向，先观察路径。",
			"turrets": [{"col": 1, "row": 2, "dir": 1, "loop": "1---"}],
			"pipes": [
				{"col": 6, "row": 2, "shape": "L", "rotation": 180, "loop": "-,-,-,-"}
			],
			"targets": [{"col": 6, "row": 7, "required": 2}]
		},
		{
			"name": "教程 4 - R 会旋转",
			"bpm": 90.0,
			"tick_rate_ms": 600.0,
			"letter_title": "维修委托 #04：节拍播放器",
			"letter_body": "这个模块需要在脉冲到达前转到正确角度。导线脚本中的 R 表示顺时针转 90°。",
			"turrets": [{"col": 1, "row": 5, "dir": 1, "loop": "1---"}],
			"pipes": [
				{"col": 4, "row": 5, "shape": "L", "rotation": 90, "loop": "R,-,-,-"}
			],
			"targets": [{"col": 4, "row": 8, "required": 1}]
		},
		{
			"name": "教程 5 - 编辑导线脚本",
			"bpm": 90.0,
			"tick_rate_ms": 600.0,
			"letter_title": "维修委托 #05：卡住的转向器",
			"letter_body": "现在轮到你改脚本：点击弯管，第一行填 R，点应用。也可以先按 ? 查看 R/L/- 的含义。",
			"turrets": [{"col": 1, "row": 5, "dir": 1, "loop": "1---"}],
			"pipes": [
				{"col": 4, "row": 5, "shape": "L", "rotation": 90, "loop": "-,-,-,-"}
			],
			"targets": [{"col": 4, "row": 8, "required": 1}]
		},
		{
			"name": "教程 6 - 双炮台双故障",
			"bpm": 105.0,
			"tick_rate_ms": 480.0,
			"letter_title": "维修委托 #06：双声道失衡",
			"letter_body": "最后把两个声道都修好。每一行炮台动作对应一个炮台，两个洞都需要被填满。",
			"turrets": [
				{"col": 1, "row": 3, "dir": 1, "loop": "1---"},
				{"col": 1, "row": 6, "dir": 1, "loop": "-1--"}
			],
			"pipes": [],
			"targets": [
				{"col": 8, "row": 3, "required": 2},
				{"col": 8, "row": 6, "required": 2}
			]
		}
	]
