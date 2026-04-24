// ============================================================
// MACHINE LOOP ENGINE
// ============================================================

// ============================================================
// DIRECTIONS
// ============================================================
const DIR = { UP: 0, RIGHT: 1, DOWN: 2, LEFT: 3 };
const DIR_VEC = [[0, -1], [1, 0], [0, 1], [-1, 0]];

// Pipe routing: given shape, rotation, and entry direction, return exit direction or null (blocked)
function getPipeExit(shape, rotation, entryDir) {
  // Rotate entry direction into local (pipe's own) space
  const steps = Math.floor(((rotation % 360) + 360) % 360 / 90);
  const localEntry = (entryDir - steps + 4) % 4;
  let localExit = null;

  switch (shape) {
    case 'I':
      // Connects UP<->DOWN and RIGHT<->LEFT when rotated
      if (localEntry === 0) localExit = 2;
      else if (localEntry === 2) localExit = 0;
      else if (localEntry === 1) localExit = 3;
      else if (localEntry === 3) localExit = 1;
      break;
    case 'L':
      // At rot=0: opens UP(0) and RIGHT(1) - visual matches ┘ shape
      if (localEntry === 0) localExit = 1;
      else if (localEntry === 1) localExit = 0;
      break;
    case 'T':
      // At rot=0: opens LEFT(3), RIGHT(1), DOWN(2). UP is closed.
      if (localEntry === 3) localExit = 1;
      else if (localEntry === 1) localExit = 3;
      // Entering from the stem (DOWN at rot=0) is ambiguous for a single bullet.
      // Treat as blocked to avoid unrealistic forced turns inside the junction.
      break;
    case '+':
      // All 4 directions pass straight through
      localExit = (localEntry + 2) % 4;
      break;
  }

  if (localExit === null) return null;
  return (localExit + steps) % 4;
}

// ============================================================
// LOOP PARSER
// ============================================================
class LoopParser {
  // "1---1-" => [true, false, false, false, true, false]
  static parseTurret(script) {
    const clean = (script || '').replace(/\s/g, '');
    if (!clean) return [false];
    return clean.split('').map(c => c === '1');
  }

  // "R,L,-,R" => [90, -90, 0, 90]
  static parsePipe(script) {
    const clean = (script || '-').replace(/\s/g, '');
    return clean.split(',').map(t => t === 'R' ? 90 : t === 'L' ? -90 : 0);
  }
}

// ============================================================
// ENTITIES
// ============================================================
class Turret {
  constructor(col, row, dir, loopScript) {
    this.col = col;
    this.row = row;
    this.dir = dir;
    this.loopScript = loopScript;
    this.loop = LoopParser.parseTurret(loopScript);
    this.idx = 0;
    this.flash = 0;
  }

  tick(game) {
    const fire = this.loop[this.idx % this.loop.length];
    this.idx++;
    if (fire) {
      game.spawnBullet(this.col, this.row, this.dir);
      this.flash = 6;
    }
    if (this.flash > 0) this.flash--;
  }

  setLoop(script) {
    this.loopScript = script;
    this.loop = LoopParser.parseTurret(script);
    this.idx = 0;
  }
}

class Pipe {
  constructor(col, row, shape, rotation, loopScript, id) {
    this.col = col;
    this.row = row;
    this.shape = shape;
    this.rotation = ((rotation % 360) + 360) % 360;
    this.loopScript = loopScript;
    this.loop = LoopParser.parsePipe(loopScript);
    this.idx = 0;
    this.id = id;
  }

  tick() {
    const delta = this.loop[this.idx % this.loop.length];
    this.idx++;
    if (delta !== 0) {
      this.rotation = ((this.rotation + delta) % 360 + 360) % 360;
    }
  }

  tryPass(entryDir) {
    return getPipeExit(this.shape, this.rotation, entryDir);
  }

  manualRotate(delta) {
    this.rotation = ((this.rotation + delta) % 360 + 360) % 360;
  }

  setLoop(script) {
    this.loopScript = script;
    this.loop = LoopParser.parsePipe(script);
    this.idx = 0;
  }
}

class Bullet {
  constructor(col, row, dir) {
    this.col = col;
    this.row = row;
    this.dir = dir;
    this.alive = true;
  }

  tick(game) {
    if (!this.alive) return;

    const [dx, dy] = DIR_VEC[this.dir];
    const nc = this.col + dx;
    const nr = this.row + dy;

    // Out of bounds
    if (nc < 0 || nc >= game.cols || nr < 0 || nr >= game.rows) {
      this.alive = false;
      return;
    }

    // Check pipe
    const pipe = game.getPipeAt(nc, nr);
    if (pipe) {
      // Entry side is opposite to movement direction:
      // moving RIGHT means entering from LEFT side of the next cell.
      const entryDir = (this.dir + 2) % 4;
      const exitDir = pipe.tryPass(entryDir);
      if (exitDir === null) {
        this.alive = false;
        return;
      }
      this.col = nc;
      this.row = nr;
      this.dir = exitDir;
    } else {
      this.col = nc;
      this.row = nr;
    }

    // Check target
    const target = game.getTargetAt(this.col, this.row);
    if (target) {
      target.hit();
      this.alive = false;
    }
  }
}

class Target {
  constructor(col, row, required) {
    this.col = col;
    this.row = row;
    this.required = required;
    this.hits = 0;
    this.flash = 0;
  }

  hit() {
    this.hits++;
    this.flash = 10;
  }

  tick() {
    if (this.flash > 0) this.flash--;
  }

  get done() { return this.hits >= this.required; }
}

// ============================================================
// GAME
// ============================================================
class Game {
  constructor(cols, rows) {
    this.cols = cols;
    this.rows = rows;
    this.cellSize = 50;
    this.tick = 0;
    this.playing = false;
    this.tickRate = 500;
    this.turrets = [];
    this.pipes = [];
    this.bullets = [];
    this.targets = [];
    this._timer = null;
    this.onWin = null;
    this.onChange = null;
    // 音乐节拍系统
    this.bpm = 120; // 默认每分钟节拍数
    this.beatInterval = 60000 / this.bpm; // 每拍的毫秒数
    this.beatCounter = 0; // 节拍计数器
    this.subBeatCounter = 0; // 子节拍计数器（用于4分音符等）
    this.beatsPerMeasure = 4; // 每小节的拍数
  }

  loadLevel(level) {
    this.stop();
    // Keep gameplay grid fixed at 10x10.
    this.cols = 10;
    this.rows = 10;
    // 从关卡配置中加载 BPM，否则使用默认值
    this.bpm = level.bpm || 120;
    this.beatInterval = 60000 / this.bpm;
    // 如果关卡指定了 tickRate，则使用它，否则基于 BPM 计算（默认4分音符为一个 tick）
    this.tickRate = level.tickRate || (this.beatInterval / 4);
    this.tick = 0;
    this.beatCounter = 0;
    this.subBeatCounter = 0;
    this.bullets = [];
    this.turrets = (level.turrets || []).map(t => new Turret(t.col, t.row, t.dir, t.loop));
    this.pipes   = (level.pipes   || []).map((p, i) => new Pipe(p.col, p.row, p.shape, p.rotation || 0, p.loop || '-', i));
    this.targets = (level.targets || []).map(t => new Target(t.col, t.row, t.required || 5));
    if (this.onChange) this.onChange();
  }

  spawnBullet(col, row, dir) {
    this.bullets.push(new Bullet(col, row, dir));
  }

  getPipeAt(col, row) {
    return this.pipes.find(p => p.col === col && p.row === row) || null;
  }

  getTargetAt(col, row) {
    return this.targets.find(t => t.col === col && t.row === row) || null;
  }

  stepTick() {
    this.pipes.forEach(p => p.tick());
    this.turrets.forEach(t => t.tick(this));
    this.bullets.forEach(b => b.tick(this));
    this.targets.forEach(t => t.tick());
    this.bullets = this.bullets.filter(b => b.alive);
    this.tick++;

    // 更新节拍计数器
    this.subBeatCounter++;
    // 每4个 tick 为一个节拍（默认4分音符）
    if (this.subBeatCounter % 4 === 0) {
      this.beatCounter++;
    }

    if (this.targets.length > 0 && this.targets.every(t => t.done)) {
      this.stop();
      if (this.onWin) this.onWin(this.tick);
    }

    if (this.onChange) this.onChange();
  }

  play() {
    if (this.playing) return;
    this.playing = true;
    const loop = () => {
      this.stepTick();
      if (this.playing) this._timer = setTimeout(loop, this.tickRate);
    };
    this._timer = setTimeout(loop, this.tickRate);
  }

  stop() {
    this.playing = false;
    if (this._timer) { clearTimeout(this._timer); this._timer = null; }
  }

  toggle() {
    if (this.playing) this.stop(); else this.play();
  }

  reset() {
    this.stop();
    this.tick = 0;
    this.beatCounter = 0;
    this.subBeatCounter = 0;
    this.bullets = [];
    this.turrets.forEach(t => { t.idx = 0; t.flash = 0; });
    this.pipes.forEach(p => p.idx = 0);
    this.targets.forEach(t => { t.hits = 0; t.flash = 0; });
    if (this.onChange) this.onChange();
  }
}
