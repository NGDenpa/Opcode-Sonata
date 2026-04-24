# MachineLoop 项目速览（快速上手）

## 项目定位

这是一个基于浏览器的游戏原型（demo），当前以 `prototype` 目录为核心实现，目标是快速验证玩法循环与关卡节奏。

## 技术栈

- 语言：JavaScript、HTML、CSS
- 框架：无（非 React/Vue，未使用 Phaser/Pixi/Three）
- 渲染：HTML5 Canvas 2D
- 音频：Web Audio API（程序化音效）
- 构建：无构建工具（无 `package.json`，无 bundler）

## 目录结构（关键）

- `prototype/`
  - `index.html`：页面结构、按钮 UI、脚本加载入口
  - `engine.js`：游戏核心规则（Tick、实体行为、碰撞、胜负判定）
  - `levels.js`：关卡数据（炮台/管道/目标/节奏参数）
  - `main.js`：初始化、输入处理、渲染循环、音效、关卡切换
- `GDD.md`：玩法与设计目标
- `TECH_SPEC.md`：技术方案与模块设计
- `ROADMAP.md`：开发阶段与里程碑
- `ASSET_LIST.md`：资源清单与占位规划

## 运行方式

当前项目没有 npm 脚本，采用静态页面方式运行：

1. 直接在浏览器打开 `prototype/index.html`
2. 或者使用任意静态服务器指向 `prototype/` 目录

## 核心代码入口

- 游戏初始化：`prototype/main.js`（`DOMContentLoaded`）
- 逻辑推进（Tick）：`prototype/engine.js`（`Game.stepTick`）
- 逻辑循环：`prototype/engine.js`（`Game.play`）
- 渲染循环：`prototype/main.js`（`renderLoop` + `requestAnimationFrame`）
- 关卡加载：`prototype/levels.js` + `prototype/main.js`（`loadLevel`）
- 输入处理：`prototype/main.js`（键盘与鼠标）

## 推荐阅读顺序（30 分钟快速熟悉）

1. `prototype/index.html`：先看页面结构和脚本加载顺序
2. `prototype/main.js`：看 UI 如何驱动引擎与渲染
3. `prototype/engine.js`：深入理解核心规则和状态流转
4. `prototype/levels.js`：理解玩法参数和关卡构成
5. `GDD.md` + `TECH_SPEC.md`：补齐设计目标与架构意图

## 当前观察（工程化层面）

- 文档较完整，但偏设计说明，缺少统一工程入口（例如 `README.md`）
- 运行简单，适合快速迭代玩法
- 后续若扩展体量，建议补充：
  - 统一启动说明
  - 目录与命名约定
  - 调参说明（关卡字段字典）

