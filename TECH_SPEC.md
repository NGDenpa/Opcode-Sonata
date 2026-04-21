# 技术规格文档

## 原型架构（HTML5）

### 核心模块

#### 1. TickEngine
```javascript
class TickEngine {
  currentTick = 0
  tickRate = 500ms  // 每tick间隔
  
  step() {
    // 执行一个tick的所有逻辑
  }
  
  play() / pause() / reset()
}
```

#### 2. Grid系统
```javascript
class Grid {
  width = 10
  height = 10
  cellSize = 50px
  
  worldToGrid(x, y)
  gridToWorld(col, row)
}
```

#### 3. Entity基类
```javascript
class Entity {
  position: {col, row}
  onTick()  // 每tick调用
}
```

#### 4. Turret（炮台）
```javascript
class Turret extends Entity {
  direction: Vector2
  loopScript: string  // "1---1---"
  loopIndex: number
  
  onTick() {
    if (shouldFire()) {
      spawnBullet()
    }
  }
}
```

#### 5. Pipe（水管）
```javascript
class Pipe extends Entity {
  rotation: 0/90/180/270
  shape: 'I' | 'L' | 'T' | '+'
  loopScript: string  // "R90,---,L90"
  
  onTick() {
    executeRotation()
  }
  
  canPass(bulletDir): boolean
  getExitDir(entryDir): Vector2
}
```

#### 6. Bullet（子弹）
```javascript
class Bullet extends Entity {
  direction: Vector2
  
  onTick() {
    move()
    checkCollision()
  }
}
```

#### 7. Target（目标）
```javascript
class Target extends Entity {
  hitCount = 0
  requiredHits = 10
  
  onHit() {
    hitCount++
    checkWin()
  }
}
```

#### 8. LoopParser
```javascript
class LoopParser {
  parse(script: string): Instruction[]
  
  // 炮台语言
  parseTurretLoop("1-1-") 
  // => [FIRE, WAIT, FIRE, WAIT]
  
  // 水管语言
  parsePipeLoop("R90,L90") 
  // => [ROTATE_CW_90, ROTATE_CCW_90]
}
```

## 碰撞检测算法

### 水管通过判定
```
1. 子弹进入水管格子
2. 检查子弹方向 vs 水管当前旋转角度
3. 查表判断是否有通路
4. 如果通过，计算出口方向
5. 如果碰壁，销毁子弹
```

### 通路查找表（L型水管示例）
```javascript
const L_PIPE_ROUTES = {
  0:   { UP: null,   DOWN: RIGHT, LEFT: null,  RIGHT: DOWN },
  90:  { UP: LEFT,   DOWN: null,  LEFT: UP,    RIGHT: null },
  180: { UP: RIGHT,  DOWN: null,  LEFT: DOWN,  RIGHT: UP   },
  270: { UP: null,   DOWN: LEFT,  LEFT: null,  RIGHT: UP   }
}
```

## 数据结构

### 关卡格式（JSON）
```json
{
  "name": "Level 1",
  "gridSize": [10, 10],
  "tickRate": 500,
  "winCondition": { "hits": 10 },
  
  "entities": [
    {
      "type": "turret",
      "pos": [0, 5],
      "dir": "right",
      "loop": "1---"
    },
    {
      "type": "pipe",
      "pos": [3, 5],
      "shape": "L",
      "rotation": 0,
      "loop": "---,R90,---,L90"
    },
    {
      "type": "target",
      "pos": [9, 5],
      "requiredHits": 10
    }
  ]
}
```

## 渲染层

### Canvas绘制顺序
```
1. 背景网格
2. 水管（带旋转动画）
3. 炮台
4. 子弹（带拖尾效果）
5. 目标（带命中计数）
6. UI（tick计数、暂停按钮）
```

### 动画插值
```javascript
// 水管旋转平滑过渡
currentRotation = lerp(
  lastRotation, 
  targetRotation, 
  tickProgress
)
```

## 移植到Godot

### 节点结构
```
Game (Node2D)
├── Grid (Node2D)
├── TickEngine (Node)
├── Entities (Node2D)
│   ├── Turrets (Node2D)
│   ├── Pipes (Node2D)
│   ├── Bullets (Node2D)
│   └── Targets (Node2D)
└── UI (CanvasLayer)
```

### 脚本映射
- JavaScript类 → GDScript类
- Canvas绘制 → Sprite2D节点
- JSON关卡 → Godot Resource

## 性能考虑
- 子弹池化（避免频繁创建销毁）
- 碰撞检测仅在子弹移动后
- 网格空间分区（大关卡优化）
