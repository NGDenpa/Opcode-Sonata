// ============================================================
// LEVELS DEFINITION
// ============================================================

const LEVELS = [
  // Tutorial 1: 直线射击
  {
    name: "教程 1 - 直线射击",
    cols: 10,
    rows: 10,
    tickRate: 500,
    turrets: [
      { col: 1, row: 5, dir: DIR.RIGHT, loop: "1---" }
    ],
    pipes: [],
    targets: [
      { col: 8, row: 5, required: 5 }
    ]
  },

  // Tutorial 2: 单个弯管
  {
    name: "教程 2 - 静态弯管",
    cols: 10,
    rows: 10,
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

  // Tutorial 3: 旋转水管
  {
    name: "教程 3 - 旋转水管",
    cols: 10,
    rows: 10,
    tickRate: 600,
    turrets: [
      { col: 1, row: 5, dir: DIR.RIGHT, loop: "1-1-" }
    ],
    pipes: [
      { col: 5, row: 5, shape: 'L', rotation: 0, loop: "R,-,-,-" }
    ],
    targets: [
      { col: 5, row: 8, required: 8 }
    ]
  },

  // Challenge: 多个水管
  {
    name: "挑战 - 复杂管道",
    cols: 10,
    rows: 10,
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

  // Expert: 全类型相邻管网
  {
    name: "挑战 - 相邻全类型管网",
    cols: 10,
    rows: 10,
    tickRate: 380,
    turrets: [
      { col: 1, row: 5, dir: DIR.RIGHT, loop: "1-1-1---" }
    ],
    // 所有管子组成同一连通块，并包含 I / L / T / + 四种形状
    pipes: [
      { col: 3, row: 5, shape: 'I', rotation: 90,  loop: "-" },
      { col: 4, row: 5, shape: '+', rotation: 0,   loop: "-" },
      { col: 5, row: 5, shape: 'L', rotation: 180, loop: "-" },
      { col: 5, row: 6, shape: 'I', rotation: 0,   loop: "-" },
      { col: 5, row: 7, shape: 'L', rotation: 0,   loop: "-" },
      { col: 6, row: 7, shape: 'T', rotation: 0,   loop: "-" }
    ],
    targets: [
      { col: 9, row: 7, required: 12 }
    ]
  },

  // Expert+: 全连通岔路管网
  {
    name: "挑战 - 全连通岔路",
    cols: 10,
    rows: 10,
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

  // Expert++: 真假岔路（全连通）
  {
    name: "挑战 - 真假岔路",
    cols: 10,
    rows: 10,
    tickRate: 340,
    turrets: [
      { col: 1, row: 5, dir: DIR.RIGHT, loop: "1-1-1-1-1---" }
    ],
    // 全网连通：主路通目标；假路看似可达但会在末端吃弹
    pipes: [
      { col: 3, row: 5, shape: 'I', rotation: 90, loop: "-" },
      { col: 4, row: 5, shape: 'I', rotation: 90, loop: "-" },
      { col: 5, row: 5, shape: 'T', rotation: 180, loop: "R,-,-,-" },
      { col: 6, row: 5, shape: 'I', rotation: 90, loop: "-" },
      { col: 7, row: 5, shape: 'L', rotation: 180, loop: "-" },
      { col: 7, row: 6, shape: 'I', rotation: 0, loop: "-" },
      { col: 7, row: 7, shape: 'L', rotation: 270, loop: "-" },
      { col: 8, row: 7, shape: 'I', rotation: 90, loop: "-" },
      { col: 9, row: 7, shape: 'L', rotation: 180, loop: "-" },
      { col: 9, row: 6, shape: 'I', rotation: 0, loop: "-" }
    ],
    targets: [
      { col: 9, row: 4, required: 16 }
    ]
  },

  // Music: 7 hits melody C C G G A A G
  {
    name: "挑战 - 7发旋律",
    cols: 10,
    rows: 10,
    tickRate: 420,
    hitMelody: "CCGGAAG",
    hitOctave: 4,
    turrets: [
      { col: 1, row: 5, dir: DIR.RIGHT, loop: "1-1-1-1-1-1-1-" }
    ],
    pipes: [],
    targets: [
      { col: 8, row: 5, required: 7 }
    ]
  }
];
