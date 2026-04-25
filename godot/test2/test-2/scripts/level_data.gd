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
			"mask": "mp3",
			"turrets": [{"col": 1, "row": 5, "dir": 1, "loop": "1-1-"}],
			"pipes": [
				{"col": 4, "row": 5, "shape": "I", "rotation": 90, "loop": "-,-,-,-"},
				{"col": 5, "row": 5, "shape": "I", "rotation": 90, "loop": "-,-,-,-"}
			],
			"targets": [{"col": 8, "row": 5, "required": 2}]
		},

		{
			"name": "教程 2 - 磁带单弯",
			"bpm": 95.0,
			"tick_rate_ms": 540.0,
			"letter_title": "维修委托 #02：卡住的磁带",
			"letter_body": "这盘磁带里录着妈妈年轻时唱的歌，但现在只有杂音。先从一枚固定弯管开始：脉冲会沿磁带仓向下转向。",
			"mask": "mp3",
			"cols": 14,
			"rows": 10,
			"turrets": [{"col": 2, "row": 2, "dir": 1, "loop": "1---"}],
			"pipes": [
				{"col": 9, "row": 2, "shape": "L", "rotation": 180, "loop": "-,-,-,-"}
			],
			"targets": [{"col": 9, "row": 7, "required": 2}]
		},
		{
			"name": "教程 3 - 到达前旋转",
			"bpm": 90.0,
			"tick_rate_ms": 600.0,
			"letter_title": "维修委托 #04：节拍播放器",
			"letter_body": "直线管道和L型管道角度不对，点击他们更改脚本吧.基本的操作手册可以点击问号查看.值得注意的是，你的所有脚本会循环进行！如果你想保证每一轮脚本都稳步运行，你需要保证它们在脚本结束时，回到了它们初始的位置",
			"mask": "mp3",
			"turrets": [{"col": 1, "row": 5, "dir": 1, "loop": "1---"}],
			"pipes": [
				{"col": 3, "row": 5, "shape": "I", "rotation": 0, "loop": "-,-,-,-"},
				{"col": 4, "row": 5, "shape": "L", "rotation": 90, "loop": "-,-,-,-"}
			],
			"targets": [{"col": 4, "row": 8, "required": 2}]
		},
		{
			"name": "教程 4 - 磁带双弯",
			"bpm": 90.0,
			"tick_rate_ms": 500.0,
			"letter_title": "维修委托 #05：被折返的磁带",
			"letter_body": "这次脉冲需要先向下，再横向穿过磁带仓。两个固定弯管会组成一条折线路径。",
			"mask": "mp3",
			"cols": 14,
			"rows": 10,
			"turrets": [
				{"col": 3, "row": 5, "dir": 1, "loop": "-1-1-1-1"},
				{"col": 5, "row": 3, "dir": 2, "loop": "1-1-1-1-"},
			],
			"pipes": [
				{"col": 5, "row": 5, "shape": "I", "rotation": 180, "loop": "-,-,-,-,-,-,-"},
			],
			"targets": [
				{"col": 7, "row": 5, "required": 16},
				{"col": 5, "row": 7, "required": 16}
				]
		},
		{
			"name": "教程 5 - 双声道同步",
			"bpm": 105.0,
			"tick_rate_ms": 480.0,
			"letter_title": "维修委托 #06：双声道失衡",
			"letter_body": "唱片机有两个声道失衡。每一行炮台动作对应一个炮台，两个故障点都要被填满。",
			"mask": "mp3",
			"turrets": [
				{"col": 2, "row": 5, "dir": 1, "loop": "11111111"},
			],
			"pipes": [
				{"col": 8, "row": 5, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-,-,-"},
			],
			"targets": [
				{"col": 8, "row": 2, "required": 16},
				{"col": 8, "row": 8, "required": 16}
			]
		},
		{
			"name": "教程 6 - LR 交替分流",
			"bpm": 180.0,
			"tick_rate_ms": 500.0,
			"letter_title": "维修委托 #07：忽亮忽灭的 MP3",
			"letter_body": "最后这个 MP3 需要把连续脉冲分流到两个故障点。弯管会按 R,L,R,L 来回摆动，让子弹轮流进入两个洞。",
			"mask": "mp3",
			"turrets": [
				{"col": 4, "row": 3, "dir": 2, "loop": "11--11--"},
				{"col": 5, "row": 3, "dir": 2, "loop": "--11--11"},
				{"col": 6, "row": 4, "dir": 3, "loop": "--11--11"},
				{"col": 6, "row": 5, "dir": 3, "loop": "11--11--"},
				],
			"pipes": [
				{"col": 4, "row": 4, "shape": "L", "rotation": 270, "loop": "-,-,-,-,-,-,-,-"},
				#{"col": 4, "row": 5, "shape": "L", "rotation": 180, "loop": "R,L,R,L"},
				{"col": 4, "row": 6, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-,-,-"},
				{"col": 3, "row": 5, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-,-,-"},
				#{"col": 3, "row": 6, "shape": "L", "rotation": 180, "loop": "R,L,R,L"},
				#{"col": 5, "row": 4, "shape": "L", "rotation": 180, "loop": "R,L,R,L"},
				{"col": 5, "row": 5, "shape": "L", "rotation": 90, "loop": "-,-,-,-,-,-,-,-"}
			],
			"targets": [
				{"col": 3, "row": 4, "required": 16},
				{"col": 2, "row": 6, "required": 32},
				{"col": 5, "row": 6, "required": 16},
				{"col": 3, "row": 7, "required": 32}
			]
		},
		{
			"name": "进阶 7 - 六拍分流",
			"bpm": 114.0,
			"tick_rate_ms": 450.0,
			"letter_title": "维修委托 #08：分流器过载",
			"letter_body": "这个 MP3 会连续吐出脉冲。你需要给唯一的弯管写 6 拍脚本，让连续脉冲被分成上下两路。",
			"mask": "mp3",
			"turrets": [{"col": 1, "row": 5, "dir": 1, "loop": "111111"}],
			"pipes": [
				{"col": 5, "row": 5, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-"}
			],
			"solution_loops": ["R,-,-,L,-,-"],
			"targets": [
				{"col": 5, "row": 2, "required": 3},
				{"col": 5, "row": 8, "required": 3}
			]
		},
		{
			"name": "进阶 8 - 错拍双分流",
			"bpm": 110.0,
			"tick_rate_ms": 470.0,
			"letter_title": "维修委托 #09：左右声道错拍",
			"letter_body": "两个炮台分别用 8 拍文本错开供给。两枚弯管都需要你写脚本，让到达时刻和分流方向对齐。",
			"mask": "mp3",
			"cols": 14,
			"rows": 10,
			"turrets": [
				{"col": 2, "row": 3, "dir": 1, "loop": "11--11--"},
				{"col": 2, "row": 6, "dir": 1, "loop": "--11--11"}
			],
			"pipes": [
				{"col": 6, "row": 3, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-,-,-"},
				{"col": 9, "row": 6, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-,-,-"}
			],
			"solution_loops": ["R,L,-,-,R,L,-,-", "R,L,-,-,R,L,-,-"],
			"targets": [
				{"col": 6, "row": 1, "required": 2},
				{"col": 6, "row": 8, "required": 2},
				{"col": 9, "row": 3, "required": 2},
				{"col": 9, "row": 8, "required": 2}
			]
		},
		{
			"name": "进阶 9 - 两段延迟",
			"bpm": 108.0,
			"tick_rate_ms": 480.0,
			"letter_title": "维修委托 #10：延迟校准",
			"letter_body": "脉冲先被固定弯管下转，再经过第二枚可编程弯管。你只需要设计第二段的 6 拍脚本。",
			"mask": "mp3",
			"turrets": [{"col": 1, "row": 3, "dir": 1, "loop": "1--1--"}],
			"pipes": [
				{"col": 5, "row": 3, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-"},
				{"col": 5, "row": 6, "shape": "L", "rotation": 270, "loop": "-,-,-,-,-,-"}
			],
			"solution_loops": ["-,-,-,-,-,-", "R,-,-,L,-,-"],
			"targets": [{"col": 9, "row": 6, "required": 2}]
		},
		{
			"name": "进阶 10 - 十字与分流",
			"bpm": 112.0,
			"tick_rate_ms": 455.0,
			"letter_title": "维修委托 #11：交叉声道分流",
			"letter_body": "纵向炮台穿过 + 导线修复下方故障；横向连续炮台需要被右侧弯管分流。只要设计右侧弯管脚本。",
			"mask": "mp3",
			"turrets": [
				{"col": 1, "row": 5, "dir": 1, "loop": "111111"},
				{"col": 5, "row": 1, "dir": 2, "loop": "--1--1"}
			],
			"pipes": [
				{"col": 5, "row": 5, "shape": "+", "rotation": 0, "loop": "-,-,-,-,-,-"},
				{"col": 8, "row": 5, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-"}
			],
			"solution_loops": ["-,-,-,-,-,-", "R,-,-,L,-,-"],
			"targets": [
				{"col": 5, "row": 8, "required": 2},
				{"col": 8, "row": 2, "required": 2},
				{"col": 8, "row": 8, "required": 2}
			]
		},
		{
			"name": "进阶 11 - 八拍终检",
			"bpm": 120.0,
			"tick_rate_ms": 420.0,
			"letter_title": "维修委托 #12：双分流终检",
			"letter_body": "终检使用 8 拍炮台文本。两组连续脉冲同时进入两枚分流器，你需要为两枚弯管都写出 8 拍脚本。",
			"mask": "mp3",
			"cols": 14,
			"rows": 10,
			"turrets": [
				{"col": 2, "row": 3, "dir": 1, "loop": "11111111"},
				{"col": 2, "row": 6, "dir": 1, "loop": "11111111"}
			],
			"pipes": [
				{"col": 6, "row": 3, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-,-,-"},
				{"col": 9, "row": 6, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-,-,-"}
			],
			"solution_loops": ["R,L,R,L,R,L,R,L", "R,L,R,L,R,L,R,L"],
			"targets": [
				{"col": 6, "row": 1, "required": 3},
				{"col": 6, "row": 8, "required": 3},
				{"col": 9, "row": 1, "required": 3},
				{"col": 9, "row": 8, "required": 3}
			]
		}
	]
