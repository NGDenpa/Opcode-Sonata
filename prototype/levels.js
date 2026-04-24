// ============================================================
// LEVELS DEFINITION
// ============================================================

const LEVELS = [
  // 1) 基础：直线射击
  {
    name: "教程 1 - 直线射击",
    theme: "cassette",
    objectName: "磁带",
    letterTitle: "维修委托 #01：小熊不唱歌了",
    letterBody: "维修工你好：\n\n我的小熊以前一按肚子就会唱歌，今天突然一点声音都没有了 :(\n我把它最喜欢的磁带也一起放在盒子里了。\n\n可以请你帮我把声音线路修好吗？\n—— 小雨（7岁）",
    guideSteps: [
      "欢迎上岗，维修工。我是你的搭档“阿洛”，之后会陪你熟悉工作台。",
      "这关目标很简单：把洞填满就算修好。你看到的绿色圆圈，就是需要修复的洞。",
      "底部是 MACHINE LOOP：炮台节奏里 1=发射，-=等待。先按默认脚本试着播放。"
    ],
    cols: 10,
    rows: 10,
    bpm: 100,
    tickRate: 500,
    turrets: [
      { col: 1, row: 5, dir: DIR.RIGHT, loop: "1---" }
    ],
    pipes: [],
    targets: [
      { col: 8, row: 5, required: 5 }
    ]
  },

  // 2) 基础：单个弯管
  {
    name: "教程 2 - 静态弯管",
    theme: "record",
    objectName: "唱片机",
    letterTitle: "维修委托 #02：爷爷的唱片机",
    letterBody: "维修工你好：\n\n这是爷爷留下来的老唱片机，最近唱到一半就断音。\n我想在他生日那天，再听一次那首老歌。\n\n拜托你了。\n—— 阿川",
    guideSteps: [
      "做得好。第二关开始会出现水管，子弹必须沿管道走。",
      "这一关是静态弯管教学：你可以点击水管看脚本，先不用改，只观察路径。",
      "记住：每关都有主题物件和信件故事。先读信，再开始维修会更有代入感。"
    ],
    cols: 10,
    rows: 10,
    bpm: 100,
    tickRate: 500,
    turrets: [
      { col: 1, row: 2, dir: DIR.RIGHT, loop: "1---" }
    ],
    pipes: [
      { col: 6, row: 2, shape: 'L', rotation: 0, loop: "-" }
    ],
    targets: [
      { col: 6, row: 7, required: 5 }
    ]
  },

  // 3) 基础：双弯静态导流
  {
    name: "教程 3 - 双弯导流",
    cols: 10,
    rows: 10,
    bpm: 95,
    tickRate: 560,
    turrets: [
      { col: 1, row: 3, dir: DIR.RIGHT, loop: "1---" }
    ],
    pipes: [
      { col: 4, row: 3, shape: 'L', rotation: 180, loop: "-,-,-,-" },
      { col: 4, row: 6, shape: 'L', rotation: 270, loop: "-,-,-,-" }
    ],
    targets: [
      { col: 8, row: 6, required: 6 }
    ]
  },

  // 4) 基础：单旋转时序
  {
    name: "教程 4 - 旋转水管",
    cols: 10,
    rows: 10,
    bpm: 90,
    tickRate: 600,
    turrets: [
      { col: 1, row: 5, dir: DIR.RIGHT, loop: "1-1-" }
    ],
    pipes: [
      { col: 4, row: 5, shape: 'I', rotation: 90, loop: "-,-,-,-" },
      { col: 6, row: 5, shape: 'L', rotation: 180, loop: "R,-,-,-" }
    ],
    targets: [
      { col: 6, row: 8, required: 8 }
    ]
  },

  // 5) 进阶：十字中继
  {
    name: "教程 5 - 十字中继",
    cols: 10,
    rows: 10,
    bpm: 110,
    tickRate: 440,
    turrets: [
      { col: 1, row: 5, dir: DIR.RIGHT, loop: "1-1---" }
    ],
    pipes: [
      { col: 3, row: 5, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-" },
      { col: 4, row: 5, shape: '+', rotation: 0, loop: "-,-,-,-,-,-" },
      { col: 5, row: 5, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-" }
    ],
    targets: [
      { col: 8, row: 5, required: 8 }
    ]
  },

  // 6) 进阶：复杂静态管道
  {
    name: "教程 6 - 复杂管道",
    cols: 10,
    rows: 10,
    bpm: 120,
    tickRate: 400,
    turrets: [
      { col: 1, row: 3, dir: DIR.RIGHT, loop: "1---1---" }
    ],
    pipes: [
      { col: 4, row: 3, shape: 'L', rotation: 0, loop: "-,-,-,-" },
      { col: 4, row: 6, shape: 'L', rotation: 270, loop: "-,-,-,-" },
      { col: 8, row: 6, shape: 'L', rotation: 180, loop: "-,-,-,-" }
    ],
    targets: [
      { col: 8, row: 2, required: 10 }
    ]
  },

  // 7) 进阶：单炮台双靶子
  {
    name: "教程 7 - 双炮台双目标",
    cols: 10,
    rows: 10,
    bpm: 118,
    tickRate: 390,
    turrets: [
      { col: 1, row: 3, dir: DIR.RIGHT, loop: "1---1---" },
      { col: 1, row: 7, dir: DIR.RIGHT, loop: "1-1-----" }
    ],
    pipes: [
      { col: 4, row: 3, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-,-,-" },
      { col: 5, row: 3, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-,-,-" },
      { col: 4, row: 7, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-,-,-" },
      { col: 5, row: 7, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-,-,-" }
    ],
    targets: [
      { col: 8, row: 3, required: 8 },
      { col: 8, row: 7, required: 6 }
    ]
  },

  // 8) 挑战：全连通岔路
  {
    name: "挑战 - 全连通岔路",
    cols: 10,
    rows: 10,
    bpm: 130,
    tickRate: 360,
    turrets: [
      { col: 1, row: 4, dir: DIR.RIGHT, loop: "1-1-1-1---" }
    ],
    // 全部管子互相连通，且在 (5,4) 与 (6,6) 存在岔路
    pipes: [
      { col: 3, row: 4, shape: 'I', rotation: 90, loop: "-" },
      { col: 4, row: 4, shape: 'I', rotation: 90, loop: "-" },
      { col: 5, row: 4, shape: 'T', rotation: 180, loop: "-" },
      { col: 5, row: 5, shape: 'I', rotation: 0, loop: "-" },
      { col: 5, row: 6, shape: 'L', rotation: 0, loop: "-" },
      { col: 6, row: 6, shape: '+', rotation: 0, loop: "-" },
      { col: 6, row: 5, shape: 'I', rotation: 0, loop: "-" },
      { col: 6, row: 4, shape: 'L', rotation: 180, loop: "-" },
      { col: 7, row: 6, shape: 'I', rotation: 90, loop: "-" },
      { col: 8, row: 6, shape: 'L', rotation: 180, loop: "-" }
    ],
    targets: [
      { col: 9, row: 4, required: 14 }
    ]
  },

  // 9) 挑战：多炮台多靶子
  {
    name: "挑战 - 多炮台多靶子",
    cols: 10,
    rows: 10,
    bpm: 122,
    tickRate: 380,
    turrets: [
      { col: 1, row: 3, dir: DIR.RIGHT, loop: "1---1---" },
      { col: 1, row: 7, dir: DIR.RIGHT, loop: "1-1-----" }
    ],
    pipes: [
      { col: 4, row: 3, shape: 'L', rotation: 180, loop: "-,-,-,-,-,-,-,-" },
      { col: 4, row: 4, shape: 'I', rotation: 0, loop: "-,-,-,-,-,-,-,-" },
      { col: 4, row: 5, shape: 'I', rotation: 0, loop: "-,-,-,-,-,-,-,-" },
      { col: 4, row: 6, shape: 'L', rotation: 270, loop: "-,-,-,-,-,-,-,-" },
      { col: 5, row: 6, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-,-,-" },
      { col: 6, row: 6, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-,-,-" },
      { col: 7, row: 6, shape: 'L', rotation: 180, loop: "-,-,-,-,-,-,-,-" },
      { col: 7, row: 5, shape: 'I', rotation: 0, loop: "-,-,-,-,-,-,-,-" },
      { col: 7, row: 4, shape: 'L', rotation: 90, loop: "-,-,-,-,-,-,-,-" },
      { col: 4, row: 7, shape: 'L', rotation: 0, loop: "-,-,-,-,-,-,-,-" },
      { col: 5, row: 7, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-,-,-" },
      { col: 6, row: 7, shape: 'L', rotation: 180, loop: "-,-,-,-,-,-,-,-" }
    ],
    targets: [
      { col: 8, row: 4, required: 8 },
      { col: 7, row: 8, required: 8 }
    ]
  },

  // 10) 终章：双炮台时序门
  {
    name: "挑战 - 双炮台时序门",
    cols: 10,
    rows: 10,
    bpm: 125,
    tickRate: 360,
    turrets: [
      { col: 1, row: 3, dir: DIR.RIGHT, loop: "1---1---" },
      { col: 1, row: 7, dir: DIR.RIGHT, loop: "1-1-1---" }
    ],
    pipes: [
      { col: 3, row: 3, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-,-,-" },
      { col: 4, row: 3, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-,-,-" },
      { col: 5, row: 3, shape: 'T', rotation: 180, loop: "R,-,-,-,L,-,-,-" }, // 时序门
      { col: 6, row: 3, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-,-,-" },
      { col: 7, row: 3, shape: 'L', rotation: 180, loop: "-,-,-,-,-,-,-,-" },
      { col: 7, row: 2, shape: 'L', rotation: 90, loop: "-,-,-,-,-,-,-,-" },

      { col: 3, row: 7, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-,-,-" },
      { col: 4, row: 7, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-,-,-" },
      { col: 5, row: 7, shape: 'L', rotation: 180, loop: "-,-,-,-,-,-,-,-" },
      { col: 5, row: 6, shape: 'I', rotation: 0, loop: "-,-,-,-,-,-,-,-" },
      { col: 5, row: 5, shape: 'I', rotation: 0, loop: "-,-,-,-,-,-,-,-" },
      { col: 5, row: 4, shape: 'I', rotation: 0, loop: "-,-,-,-,-,-,-,-" },
      { col: 6, row: 7, shape: 'I', rotation: 90, loop: "-,-,-,-,-,-,-,-" },
      { col: 7, row: 7, shape: 'L', rotation: 180, loop: "-,-,-,-,-,-,-,-" }
    ],
    targets: [
      { col: 8, row: 2, required: 10 },
      { col: 8, row: 8, required: 10 }
    ]
  }
];
