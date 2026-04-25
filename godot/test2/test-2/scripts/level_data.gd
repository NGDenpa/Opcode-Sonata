extends RefCounted
class_name LevelData

static func all_levels() -> Array:
	return [
		{
			"name": "1",
			"bpm": 100.0,
			"tick_rate_ms": 500.0,
			"letter_title": "维修委托 #01：小熊不唱歌了",
			"letter_body": "维修工你好：\n\n先确认最基础的脉冲。炮台动作里的 1 会发射，- 会停一拍。让脉冲填满右侧的洞。\n\n—— 小雨（7岁）",
			"mask": "tutorial",
			"cols": 10,
			"rows": 10,
			"board_rect": {"x": 873.0, "y": 137.0, "width": 875.0, "height": 835.0},
			"spectrum_rect": {"x": 873.0, "y": 840.0, "width": 875.0, "height": 76.0},
			"turrets": [{"col": 1, "row": 5, "dir": 1, "loop": "1-1-"}],
			"pipes": [
				{"col": 4, "row": 5, "shape": "I", "rotation": 90, "loop": "-,-,-,-"},
				{"col": 5, "row": 5, "shape": "I", "rotation": 90, "loop": "-,-,-,-"}
			],
			"targets": [{"col": 8, "row": 5, "required": 2}]
		},

		{
			"name": "2",
			"bpm": 95.0,
			"tick_rate_ms": 540.0,
			"letter_title": "维修委托 #02：卡住的磁带",
			"letter_body": "这盘磁带里录着妈妈年轻时唱的歌，但现在只有杂音。先从一枚固定弯管开始：脉冲会沿磁带仓向下转向。",
			"mask": "tutorial",
			"cols": 14,
			"rows": 10,
			"board_rect": {"x": 873.0, "y": 137.0, "width": 875.0, "height": 835.0},
			"spectrum_rect": {"x": 873.0, "y": 840.0, "width": 875.0, "height": 76.0},
			"turrets": [{"col": 2, "row": 2, "dir": 1, "loop": "1---"}],
			"pipes": [
				{"col": 9, "row": 2, "shape": "L", "rotation": 180, "loop": "-,-,-,-"}
			],
			"targets": [{"col": 9, "row": 7, "required": 2}]
		},
		{
			"name": "3",
			"bpm": 90.0,
			"tick_rate_ms": 600.0,
			"letter_title": "维修委托 #04：节拍播放器",
			"letter_body": "直线管道和L型管道角度不对，点击他们更改脚本吧.基本的操作手册可以点击问号查看.值得注意的是，你的所有脚本会循环进行！如果你想保证每一轮脚本都稳步运行，你需要保证它们在脚本结束时，回到了它们初始的位置",
			"mask": "tutorial",
			"board_rect": {"x": 873.0, "y": 137.0, "width": 875.0, "height": 835.0},
			"spectrum_rect": {"x": 873.0, "y": 840.0, "width": 875.0, "height": 76.0},
			"turrets": [{"col": 1, "row": 5, "dir": 1, "loop": "1---"}],
			"pipes": [
				{"col": 3, "row": 5, "shape": "I", "rotation": 0, "loop": "-,-,-,-"},
				{"col": 4, "row": 5, "shape": "L", "rotation": 90, "loop": "-,-,-,-"}
			],
			"targets": [{"col": 4, "row": 8, "required": 2}]
		},
		{
			"name": "4",
			"bpm": 90.0,
			"tick_rate_ms": 500.0,
			"letter_title": "维修委托 #05：被折返的磁带",
			"letter_body": "这次脉冲需要先向下，再横向穿过磁带仓。两个固定弯管会组成一条折线路径。",
			"mask": "tutorial",
			"cols": 14,
			"rows": 10,
			"board_rect": {"x": 873.0, "y": 137.0, "width": 875.0, "height": 835.0},
			"spectrum_rect": {"x": 873.0, "y": 840.0, "width": 875.0, "height": 76.0},
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
			"name": "5",
			"bpm": 105.0,
			"tick_rate_ms": 480.0,
			"letter_title": "维修委托 #06：双声道失衡",
			"letter_body": "唱片机有两个声道失衡。每一行炮台动作对应一个炮台，两个故障点都要被填满。",
			"mask": "tutorial",
			"cols": 14,
			"rows": 10,
			"board_rect": {"x": 873.0, "y": 137.0, "width": 875.0, "height": 835.0},
			"spectrum_rect": {"x": 873.0, "y": 840.0, "width": 875.0, "height": 76.0},
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
			"name": "6",
			"bpm": 180.0,
			"tick_rate_ms": 500.0,
			"letter_title": "维修委托 #6：忽亮忽灭的 MP3",
			"letter_body": "Hi, I have a stereo system that was given to me as a gift, and I’d like to check if it can be repaired. I used to play some music on it from time to time, but it hasn’t been used much recently. Now it doesn’t power on at all, so I think there might be an issue with it. I’m not sure if it’s worth fixing, but I’d like to ask first. Thanks.",
			"mask": "yinxiang",
			"cols": 10,
			"rows": 10,
			"board_rect": {"x": 900.0, "y": 130.0, "width": 875.0, "height": 835.0},
			"spectrum_rect": {"x": 873.0, "y": 490.0, "width": 875.0, "height": 76.0},
			"turrets": [
				{"col": 4, "row": 3, "dir": 2, "loop": "11--"},
				{"col": 5, "row": 3, "dir": 2, "loop": "--11"},
				
				{"col": 6, "row": 4, "dir": 3, "loop": "--11"},
				{"col": 6, "row": 5, "dir": 3, "loop": "11--"},
				],
			"pipes": [
				{"col": 4, "row": 4, "shape": "L", "rotation": 270, "loop": "-,-,-,-"},

				{"col": 4, "row": 6, "shape": "L", "rotation": 180, "loop": "-,-,-,-"},
				{"col": 3, "row": 5, "shape": "L", "rotation": 180, "loop": "-,-,-,-"},

				{"col": 5, "row": 5, "shape": "L", "rotation": 90, "loop": "-,-,-,-"}
			],
			"targets": [
				{"col": 3, "row": 4, "required": 16},
				#{"col": 2, "row": 6, "required": 32},
				{"col": 5, "row": 6, "required": 16},
				#{"col": 3, "row": 7, "required": 32}
			]
		},
		{
			"name": "7",
			"bpm": 114.0,
			"tick_rate_ms": 450.0,
			"letter_title": "维修委托 #7：分流器过载",
			"letter_body": "Hi, I’d like to repair a pair of speakers that have been in my family for years. My parents bought them a long time ago, and we used to play some classical-style music on weekends. Now one speaker has no sound at all, while the other still works a bit. I’d like to see if they can be fixed and used together again as a proper pair. Thank you.",
			"mask": "laba",
			"cols": 13,
			"rows": 11,
			"board_rect": {"x": 900.0, "y": 100.0, "width": 1000.0, "height": 900.0},
			"spectrum_rect": {"x": 890.0, "y": 477.0, "width": 989.0, "height": 76.0},
			"turrets": [{"col": 1, "row": 5, "dir": 1, "loop": "11111111"}],
			"pipes": [
				{"col": 3, "row": 3, "shape": "L", "rotation": 90, "loop": "-,-,-,-,-,-,-,-"},
				{"col": 3, "row": 5, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-,-,-"},
				{"col": 3, "row": 7, "shape": "L", "rotation": 0, "loop": "-,-,-,-,-,-,-,-"},
				
				{"col": 6, "row": 2, "shape": "L", "rotation": 90, "loop": "-,-,-,-,-,-,-,-"},
				{"col": 6, "row": 3, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-,-,-"},
				{"col": 6, "row": 4, "shape": "L", "rotation": 0, "loop": "-,-,-,-,-,-,-,-"},
				
				{"col": 8, "row": 6, "shape": "L", "rotation": 90, "loop": "-,-,-,-,-,-,-,-"},
				{"col": 8, "row": 7, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-,-,-"},
				{"col": 8, "row": 8, "shape": "L", "rotation": 0, "loop": "-,-,-,-,-,-,-,-"},
			],
			"solution_loops": ["R,-,-,L,-,-"],
			"targets": [
				{"col": 10, "row": 2, "required": 4},
				{"col": 10, "row": 4, "required": 4},
				{"col": 10, "row": 6, "required": 4},
				{"col": 10, "row": 8, "required": 4}
			]
		},
		{
			"name": "8",
			"bpm": 110.0,
			"tick_rate_ms": 470.0,
			"letter_title": "维修委托 #8：左右声道错拍",
			"letter_body": "Hello, I have a cassette tape I’d like to repair. A friend and I recorded it years ago. We lost touch over time, and I recently found the tape again. When I tried to play it, it got stuck and the sound was distorted. I’m wondering if it can be fixed so I can listen to it properly again. Thanks in advance.",
			"mask": "cidai",
			"cols": 14,
			"rows": 10,
			"spectrum_rect": {"x": 893.0, "y": 490.0, "width": 875.0, "height": 76.0},
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
			"name": "9",
			"bpm": 108.0,
			"tick_rate_ms": 480.0,
			"letter_title": "维修委托 #9：延迟校准",
			"letter_body": "Hi, I have an old MP3 player from my student days that I’d like to fix. It has a lot of music I used to listen to back then stored on it. Now it won’t turn on, and I can’t access any of the files inside. I’d like to know if it’s possible to repair it or at least recover the music from it. I’d really appreciate your help.",
			"mask": "mp3",
			"spectrum_rect": {"x": 735.0, "y": 846.0, "width": 875.0, "height": 76.0},
			"turrets": [{"col": 1, "row": 3, "dir": 1, "loop": "1--1--"}],
			"pipes": [
				{"col": 5, "row": 3, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-"},
				{"col": 5, "row": 6, "shape": "L", "rotation": 270, "loop": "-,-,-,-,-,-"}
			],
			"solution_loops": ["-,-,-,-,-,-", "R,-,-,L,-,-"],
			"targets": [{"col": 9, "row": 6, "required": 2}]
		},
		{
			"name": "10",
			"bpm": 112.0,
			"tick_rate_ms": 455.0,
			"letter_title": "维修委托 #10：交叉声道分流",
			"letter_body": "Hello, I’d like to repair an old radio from my home. When I was younger, my family and I used to listen to it in the evenings, and it often played calm, quiet music. Now when I turn it on, it mostly produces static, and tuning doesn’t work properly anymore. I was hoping you could take a look and let me know if it can be repaired. Thank you for your time.",
			"mask": "radio",
			"cols": 14,
			"rows": 10,
			"board_rect": {"x": 809.0, "y": 171.0, "width": 1025.0, "height": 805.0},
			"spectrum_rect": {"x": 905.0, "y": 798.0, "width": 843.0, "height": 76.0},
			"turrets": [
				{"col": 1, "row": 5, "dir": 1, "loop": "111111"},
				{"col": 5, "row": 3, "dir": 2, "loop": "--1--1"}
			],
			"pipes": [
				{"col": 5, "row": 5, "shape": "+", "rotation": 0, "loop": "-,-,-,-,-,-"},
				{"col": 8, "row": 5, "shape": "L", "rotation": 180, "loop": "-,-,-,-,-,-"}
			],
			"solution_loops": ["-,-,-,-,-,-", "R,-,-,L,-,-"],
			"targets": [
				{"col": 5, "row": 8, "required": 2},
				{"col": 8, "row": 3, "required": 2},
				{"col": 8, "row": 8, "required": 2}
			]
		},
	]
