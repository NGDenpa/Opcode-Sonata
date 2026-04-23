// ============================================================
// MAIN - UI glue for Machine Loop prototype
// ============================================================

// 节拍可视化器
let beatVisualizer = null;
let beatBars = [];
const BARS_COUNT = 32;
let beatJumpFramesRemaining = 0; // 跳动效果剩余帧数（按帧递减）
let beatPattern = Array(BARS_COUNT).fill(0.5); // 当前“跳动帧”随机波形数组
let beatPatternKey = 'default'; // 每个音对应不同风格 key

let game;
let canvas, ctx;
let currentLevelIdx = 0;
let audioCtx = null;
let lastBulletCount = 0;
let lastHitCount = 0;
let sfxEnabled = true;
let sfxVolume = 0.7;
const LEVEL_SOLUTIONS = {
  0: [
    "教程 1 解法：",
    "1) 直接播放即可，炮台向右直射目标。",
    "2) 若命中不足，检查炮台 loop 是否包含足够多的 1。"
  ].join('\n'),
  1: [
    "教程 2 解法：",
    "1) 保持弯管朝向默认即可。",
    "2) 连续播放，子弹会从水平转入垂直并命中目标。"
  ].join('\n'),
  2: [
    "教程 3 解法：",
    "1) 关键是弯管转到与子弹到达时刻对齐。",
    "2) 推荐先单步观察 4 个 tick 的循环，再播放。"
  ].join('\n'),
  3: [
    "挑战 - 复杂管道（示例）",
    "1) 先让三段 L 形成连续导流链。",
    "2) 炮台节奏建议保留默认，优先通过手动旋转打通主路。",
    "3) 稳定命中后再微调 loop。"
  ].join('\n'),
  4: [
    "挑战 - 相邻全类型管网（示例）",
    "1) 让 + 节点作为中继，不要在早期把流向分散到 T 的侧路。",
    "2) 先保证一条主通路命中，再利用分支补量。"
  ].join('\n'),
  5: [
    "挑战 - 全连通岔路（示例）",
    "1) 岔路多，先锁定一条最短主路。",
    "2) 用 N 单步观察分叉口，把误导分支暂时封住。",
    "3) 主路稳定后再打开副路补命中。"
  ].join('\n'),
  6: [
    "挑战 - 真假岔路（示例）",
    "1) 中心 T 管会转向，注意它在 4 tick 循环中的时序。",
    "2) 子弹到达分叉点时若开向假路会被吃弹。",
    "3) 先降低发射密度或单步，找到安全节拍后再加速。"
  ].join('\n')
};
const LEVEL_PIPE_PRESETS = {
  0: [],
  1: ["-"],
  2: ["R,-,-,-"],
  3: ["-,-,-,-", "-,-,-,-", "-,-,-,-"],
  4: ["-", "-", "-", "-", "-", "-"],
  5: ["-", "-", "-", "-", "-", "-", "-", "-", "-", "-"],
  6: ["-", "-", "R,-,-,-", "-", "-", "-", "-", "-", "-", "-"]
};

function ensureAudio() {
  if (!audioCtx) {
    const Ctx = window.AudioContext || window.webkitAudioContext;
    if (!Ctx) return null;
    audioCtx = new Ctx();
  }
  if (audioCtx.state === 'suspended') audioCtx.resume();
  return audioCtx;
}

function playTone(freq, duration = 0.08, type = 'sine', volume = 0.06, slideTo = null) {
  if (!sfxEnabled) return;
  const ctx = ensureAudio();
  if (!ctx) return;
  const now = ctx.currentTime;
  const osc = ctx.createOscillator();
  const gain = ctx.createGain();

  osc.type = type;
  osc.frequency.setValueAtTime(freq, now);
  if (slideTo !== null) {
    osc.frequency.exponentialRampToValueAtTime(Math.max(20, slideTo), now + duration);
  }

  gain.gain.setValueAtTime(0.0001, now);
  gain.gain.exponentialRampToValueAtTime(Math.max(0.0001, volume * sfxVolume), now + 0.01);
  gain.gain.exponentialRampToValueAtTime(0.0001, now + duration);

  osc.connect(gain);
  gain.connect(ctx.destination);
  osc.start(now);
  osc.stop(now + duration + 0.01);
}

function playFireSound() {
  playTone(720, 0.05, 'square', 0.03, 480);
}

function playHitSound() {
  playTone(520, 0.09, 'triangle', 0.05, 900);
}

function playRotateSound() {
  playTone(300, 0.04, 'square', 0.025, 240);
}

function playWinSound() {
  playTone(440, 0.08, 'triangle', 0.04, 660);
  setTimeout(() => playTone(660, 0.1, 'triangle', 0.05, 990), 90);
  setTimeout(() => playTone(990, 0.14, 'triangle', 0.06, 1320), 200);
}

function xmur3(str) {
  let h = 1779033703 ^ str.length;
  for (let i = 0; i < str.length; i++) {
    h = Math.imul(h ^ str.charCodeAt(i), 3432918353);
    h = (h << 13) | (h >>> 19);
  }
  return function() {
    h = Math.imul(h ^ (h >>> 16), 2246822507);
    h = Math.imul(h ^ (h >>> 13), 3266489909);
    h ^= h >>> 16;
    return h >>> 0;
  };
}

function mulberry32(seed) {
  return function() {
    let t = seed += 0x6D2B79F5;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

function noteFreq(letter, octave = 4) {
  // Equal temperament, A4 = 440Hz
  // Semitone offsets from A within same octave:
  // C: -9, G: -2, A: 0
  const base = 440;
  const semitoneFromA = letter === 'C' ? -9 : letter === 'G' ? -2 : 0;
  const octaveShift = (octave - 4) * 12;
  const n = semitoneFromA + octaveShift;
  return base * Math.pow(2, n / 12);
}

function playHitMelodyNote(hitIndexZeroBased) {
  const level = LEVELS[currentLevelIdx];
  const melody = (level && level.hitMelody) ? String(level.hitMelody) : "";
  if (!melody) return false;
  const octave = Number.isFinite(level.hitOctave) ? level.hitOctave : 4;
  const ch = melody[hitIndexZeroBased % melody.length];
  if (ch !== 'C' && ch !== 'G' && ch !== 'A') return false;
  playTone(noteFreq(ch, octave), 0.14, 'sine', 0.055, null);
  return true;
}

window.addEventListener('DOMContentLoaded', () => {
  canvas = document.getElementById('canvas');
  ctx = canvas.getContext('2d');

  const sfxToggle = document.getElementById('sfx-toggle');
  const sfxVol = document.getElementById('sfx-volume');
  if (sfxToggle) {
    sfxEnabled = !!sfxToggle.checked;
    sfxToggle.addEventListener('change', () => {
      sfxEnabled = !!sfxToggle.checked;
      if (sfxEnabled) ensureAudio();
    });
  }
  if (sfxVol) {
    sfxVolume = Math.max(0, Math.min(1, parseInt(sfxVol.value, 10) / 100));
    sfxVol.addEventListener('input', () => {
      sfxVolume = Math.max(0, Math.min(1, parseInt(sfxVol.value, 10) / 100));
    });
  }

  // 初始化节拍可视化器
  initBeatVisualizer();

  game = new Game(12, 10);
  game.onWin = onWin;
  game.onChange = updateUI;

  buildLevelButtons();
  loadLevel(0);

  canvas.addEventListener('click', onCanvasClick);
  document.addEventListener('keydown', onKey);

  requestAnimationFrame(renderLoop);
});

// 初始化节拍可视化器
function initBeatVisualizer() {
  beatVisualizer = document.getElementById('beat-visualizer');
  if (!beatVisualizer) return;
  
  // 清空容器
  beatVisualizer.innerHTML = '';
  beatBars = [];
  
  // 创建条形元素
  for (let i = 0; i < BARS_COUNT; i++) {
    const bar = document.createElement('div');
    bar.style.width = `${(beatVisualizer.clientWidth - (BARS_COUNT - 1) * 2) / BARS_COUNT}px`;
    bar.style.height = '0px';
    bar.style.backgroundColor = '#f4a261';
    bar.style.borderRadius = '2px 2px 0 0';
    bar.style.transition = 'height 0.1s ease';
    beatVisualizer.appendChild(bar);
    beatBars.push(bar);
  }
}

// 更新节拍可视化器
function updateBeatVisualizer() {
  if (!beatVisualizer || !game) return;
  
  // 更新节拍显示
  document.getElementById('beat-display').textContent = `节拍: ${game.beatCounter}`;
  
  // 计算波形高度
  const baseHeight = 10;
  const maxHeight = beatVisualizer.clientHeight - 10;
  const jumping = beatJumpFramesRemaining > 0;
  
  // 创建波形效果
  for (let i = 0; i < BARS_COUNT; i++) {
    // 默认状态：黄色，高度统一且较矮
    let height = baseHeight;
    let color = '#f4a261'; // 黄色
    
    // 跳动效果：被触发时使用随机波形并变红（所有方块同步变红）
    if (jumping) {
      height = baseHeight + maxHeight * beatPattern[i];
      color = '#e94560';
    }
    
    beatBars[i].style.height = `${height}px`;
    beatBars[i].style.backgroundColor = color;
  }

  // 按帧递减，保证“触发后一帧回默认”
  if (beatJumpFramesRemaining > 0) beatJumpFramesRemaining--;
}

function clamp01(x) { return Math.max(0, Math.min(1, x)); }
function smoothstep(t) { return t * t * (3 - 2 * t); }

function shapeWaveform(style, i, n, rnd) {
  const x = i / (n - 1);
  switch (style) {
    case 0: { // noisy + center emphasis
      const center = 1 - Math.abs(2 * x - 1);
      return clamp01(0.2 + 0.8 * (0.35 * rnd() + 0.65 * center));
    }
    case 1: { // spikes
      const spike = (rnd() < 0.18) ? (0.85 + 0.15 * rnd()) : (0.18 + 0.22 * rnd());
      return clamp01(spike);
    }
    case 2: { // saw-ish
      const jitter = (rnd() - 0.5) * 0.18;
      return clamp01(0.2 + 0.8 * clamp01(x + jitter));
    }
    case 3: { // pulse bands
      const bands = 3 + Math.floor(rnd() * 5); // 3-7
      const phase = rnd();
      const s = Math.sin((x * bands + phase) * Math.PI * 2);
      const pulse = s > 0.45 ? 1 : s > 0.0 ? 0.65 : 0.25;
      return clamp01(pulse * (0.85 + 0.15 * rnd()));
    }
    case 4: { // symmetric hill
      const hill = smoothstep(1 - Math.abs(2 * x - 1));
      return clamp01(0.2 + 0.8 * (0.55 * hill + 0.45 * rnd()));
    }
    default: {
      return clamp01(0.2 + 0.8 * rnd());
    }
  }
}

// 触发跳动效果（任何音触发时调用）
function triggerBeatJump(key = 'default') {
  beatJumpFramesRemaining = 15; // 持续 15 帧
  beatPatternKey = String(key);

  const seedFn = xmur3(beatPatternKey + '|' + Date.now().toString(36));
  const rnd = mulberry32(seedFn());
  const style = seedFn() % 5; // 0-4：每个音会倾向不同风格

  for (let i = 0; i < BARS_COUNT; i++) {
    beatPattern[i] = shapeWaveform(style, i, BARS_COUNT, rnd);
  }
}

// ============================================================
// LEVEL
// ============================================================

// ============================================================
// LEVEL
// ============================================================
function buildLevelButtons() {
  const container = document.getElementById('level-select');
  container.innerHTML = '';
  LEVELS.forEach((lv, i) => {
    const btn = document.createElement('button');
    btn.className = 'level-btn';
    btn.textContent = lv.name;
    btn.onclick = () => loadLevel(i);
    container.appendChild(btn);
  });
}

function loadLevel(idx) {
  currentLevelIdx = idx;
  const level = LEVELS[idx];
  game.loadLevel(level);

  canvas.width  = game.cols * game.cellSize;
  canvas.height = game.rows * game.cellSize;

  // Sync turret editor
  document.getElementById('turret-loop').value = game.turrets[0]?.loopScript || '1---';

  // Rebuild pipe editors
  const container = document.getElementById('pipe-editors');
  container.innerHTML = '';
  game.pipes.forEach((pipe, i) => {
    const block = document.createElement('div');
    block.className = 'editor-block';
    block.innerHTML = `
      <div class="entity-label">
        <span class="dot" style="background:#0f3460;border:1px solid #4a90d9"></span>
        水管 ${i + 1} (${pipe.shape})
      </div>
      <textarea id="pipe-loop-${i}" rows="2">${pipe.loopScript}</textarea>
    `;
    container.appendChild(block);
  });

  // Highlight current level button
  document.querySelectorAll('.level-btn').forEach((btn, i) => {
    btn.classList.toggle('current', i === idx);
  });

  document.getElementById('win-overlay').classList.remove('show');
  document.getElementById('play-btn').textContent = '▶ 播放';
  document.getElementById('play-btn').classList.remove('active');
  document.getElementById('status').textContent = `已加载: ${level.name}`;

  // Sync tick rate slider
  const slider = document.getElementById('tick-rate');
  slider.value = game.tickRate;
  document.getElementById('rate-label').textContent = game.tickRate + 'ms';
  setSolutionText();
  lastBulletCount = game.bullets.length;
  lastHitCount = game.targets[0]?.hits || 0;

  updateUI();
}

// ============================================================
// SCRIPT APPLICATION
// ============================================================
function applyScripts() {
  ensureAudio();
  const turretScript = document.getElementById('turret-loop').value.trim();
  if (game.turrets[0]) game.turrets[0].setLoop(turretScript);

  game.pipes.forEach((pipe, i) => {
    const el = document.getElementById(`pipe-loop-${i}`);
    if (el) pipe.setLoop(el.value.trim());
  });

  // Reset state but keep layout
  game.tick = 0;
  game.bullets = [];
  game.turrets.forEach(t => t.idx = 0);
  game.pipes.forEach(p => p.idx = 0);
  game.targets.forEach(t => { t.hits = 0; t.flash = 0; });

  document.getElementById('status').textContent = '脚本已应用 ✓';
  setTimeout(() => {
    document.getElementById('status').textContent = '就绪';
  }, 1500);

  updateUI();
}

// ============================================================
// PLAYBACK CONTROLS
// ============================================================
function togglePlay() {
  ensureAudio();
  game.toggle();
  const btn = document.getElementById('play-btn');
  if (game.playing) {
    btn.textContent = '⏸ 暂停';
    btn.classList.add('active');
  } else {
    btn.textContent = '▶ 播放';
    btn.classList.remove('active');
  }
}

function stepOnce() {
  ensureAudio();
  if (game.playing) return;
  game.stepTick();
}

function resetGame() {
  game.stop();
  loadLevel(currentLevelIdx);
}

function onTickRateChange() {
  const val = parseInt(document.getElementById('tick-rate').value);
  game.tickRate = val;
  document.getElementById('rate-label').textContent = val + 'ms';
  // Restart timer if playing so new rate takes effect
  if (game.playing) {
    game.stop();
    game.play();
    document.getElementById('play-btn').textContent = '⏸ 暂停';
    document.getElementById('play-btn').classList.add('active');
  }
}

// ============================================================
// WIN
// ============================================================
function onWin(ticks) {
  playWinSound();
  document.getElementById('win-overlay').classList.add('show');
  document.getElementById('win-stats').textContent = `用时 ${ticks} 个 Tick`;
  document.getElementById('play-btn').textContent = '▶ 播放';
  document.getElementById('play-btn').classList.remove('active');
}

// ============================================================
// INPUT
// ============================================================
function onCanvasClick(e) {
  ensureAudio();
  const rect = canvas.getBoundingClientRect();
  const col = Math.floor((e.clientX - rect.left)  / game.cellSize);
  const row = Math.floor((e.clientY - rect.top)   / game.cellSize);
  const pipe = game.getPipeAt(col, row);
  if (pipe) {
    pipe.manualRotate(e.shiftKey ? -90 : 90);
    playRotateSound();
  }
}

function onKey(e) {
  ensureAudio();
  if (e.code === 'Space') { e.preventDefault(); togglePlay(); }
  if (e.code === 'KeyN')  { stepOnce(); }
  if (e.code === 'Escape') { closeSolution(); }
}

function setSolutionText() {
  const level = LEVELS[currentLevelIdx];
  const content = document.getElementById('solution-content');
  const title = document.getElementById('solution-title');
  if (!content || !title) return;

  const preset = LEVEL_PIPE_PRESETS[currentLevelIdx] || [];
  const presetLines = preset.length === 0
    ? ["可复制水管方案：本关无水管。"]
    : [
      "可复制水管方案（按 水管1~N 对应输入）：",
      ...preset.map((script, i) => `水管${i + 1}: ${script}`),
      "",
      "纯脚本块（逐行复制也可）：",
      ...preset
    ];

  title.textContent = `${level?.name || '当前关卡'} - 解法之一`;
  content.textContent = [
    LEVEL_SOLUTIONS[currentLevelIdx] || [
    "暂无预设解法。",
    "建议：",
    "1) 先单步观察子弹在分叉点的方向变化。",
    "2) 再按节拍调整炮台与旋转水管 loop。"
    ].join('\n'),
    "",
    "---",
    ...presetLines
  ].join('\n');
}

function openSolution() {
  setSolutionText();
  const overlay = document.getElementById('solution-overlay');
  if (overlay) overlay.classList.add('show');
}

function closeSolution(e) {
  if (e && e.target && e.target.id !== 'solution-overlay') return;
  const overlay = document.getElementById('solution-overlay');
  if (overlay) overlay.classList.remove('show');
}

function pipePresetText() {
  const preset = LEVEL_PIPE_PRESETS[currentLevelIdx] || [];
  if (preset.length === 0) return "本关无水管脚本方案。";
  return preset.map((script, i) => `水管${i + 1}: ${script}`).join('\n');
}

function copyPipePreset() {
  const text = pipePresetText();
  if (navigator.clipboard && navigator.clipboard.writeText) {
    navigator.clipboard.writeText(text).then(() => {
      document.getElementById('status').textContent = '已复制水管方案 ✓';
    }).catch(() => {
      document.getElementById('status').textContent = '复制失败，请手动复制';
    });
  } else {
    document.getElementById('status').textContent = '当前环境不支持剪贴板';
  }
  setTimeout(() => {
    document.getElementById('status').textContent = '就绪';
  }, 1500);
}

function fillPipePreset() {
  const preset = LEVEL_PIPE_PRESETS[currentLevelIdx] || [];
  if (preset.length === 0) {
    document.getElementById('status').textContent = '本关无水管可填入';
    setTimeout(() => {
      document.getElementById('status').textContent = '就绪';
    }, 1500);
    return;
  }

  preset.forEach((script, i) => {
    const el = document.getElementById(`pipe-loop-${i}`);
    if (el) el.value = script;
  });

  document.getElementById('status').textContent = '已填入水管方案 ✓';
  setTimeout(() => {
    document.getElementById('status').textContent = '就绪';
  }, 1500);
}

// ============================================================
// UI UPDATE
// ============================================================
function updateUI() {
  document.getElementById('tick-display').textContent = `Tick: ${game.tick}`;
  document.getElementById('stat-ticks').textContent   = game.tick;
  document.getElementById('stat-bullets').textContent = game.bullets.length;

  if (game.bullets.length > lastBulletCount) {
    playFireSound();
  }
  lastBulletCount = game.bullets.length;

  const target = game.targets[0];
  if (target) {
    document.getElementById('hit-display').textContent = `命中: ${target.hits} / ${target.required}`;
    if (target.hits > lastHitCount) {
      // 只有击中目标时波形图才动（并且每个音风格不同）
      triggerBeatJump(`hit:${target.hits}`);
      const ok = playHitMelodyNote(target.hits - 1);
      if (!ok) playHitSound();
    }
    lastHitCount = target.hits;
  }
}

// ============================================================
// RENDER LOOP
// ============================================================
function renderLoop() {
  render();
  // DOM 波形图按帧刷新，用于“一帧后回默认”的闪动效果
  updateBeatVisualizer();
  requestAnimationFrame(renderLoop);
}

function render() {
  const cs = game.cellSize;
  ctx.fillStyle = '#1a1a2e';
  ctx.fillRect(0, 0, canvas.width, canvas.height);

  drawGrid(cs);
  drawTargets(cs);
  drawPipes(cs);
  drawTurrets(cs);
  drawBullets(cs);
}

function drawGrid(cs) {
  ctx.strokeStyle = '#16213e';
  ctx.lineWidth = 1;
  for (let c = 0; c <= game.cols; c++) {
    ctx.beginPath(); ctx.moveTo(c * cs, 0); ctx.lineTo(c * cs, game.rows * cs); ctx.stroke();
  }
  for (let r = 0; r <= game.rows; r++) {
    ctx.beginPath(); ctx.moveTo(0, r * cs); ctx.lineTo(game.cols * cs, r * cs); ctx.stroke();
  }
}

function drawTargets(cs) {
  game.targets.forEach(t => {
    const x = t.col * cs + cs / 2;
    const y = t.row * cs + cs / 2;
    const flash = t.flash > 0;

    ctx.strokeStyle = flash ? '#fff' : '#2a9d8f';
    ctx.lineWidth = flash ? 3 : 2;
    ctx.beginPath(); ctx.arc(x, y, cs * 0.35, 0, Math.PI * 2); ctx.stroke();
    ctx.beginPath(); ctx.arc(x, y, cs * 0.18, 0, Math.PI * 2); ctx.stroke();

    ctx.fillStyle = flash ? '#fff' : '#2a9d8f';
    ctx.beginPath(); ctx.arc(x, y, cs * 0.07, 0, Math.PI * 2); ctx.fill();

    ctx.fillStyle = flash ? '#fff' : '#2a9d8f';
    ctx.font = 'bold 11px monospace';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'alphabetic';
    ctx.fillText(`${t.hits}/${t.required}`, x, y + cs * 0.48);
  });
}

function drawPipes(cs) {
  game.pipes.forEach(p => {
    const cx = p.col * cs + cs / 2;
    const cy = p.row * cs + cs / 2;

    // Cell background
    ctx.fillStyle = '#0d1b2a';
    ctx.fillRect(p.col * cs + 2, p.row * cs + 2, cs - 4, cs - 4);

    ctx.save();
    ctx.translate(cx, cy);
    // Routing logic: rot=0 means RIGHT+DOWN for L, LEFT+RIGHT+DOWN for T, UP+DOWN for I
    // Drawing base orientation matches routing base, then rotate by p.rotation
    ctx.rotate(p.rotation * Math.PI / 180);

    const strokeTube = (drawPath) => {
      // Outer wall
      ctx.strokeStyle = '#4a90d9';
      ctx.lineWidth = 18;
      ctx.lineCap = 'butt';
      ctx.lineJoin = 'round';
      drawPath();
      ctx.stroke();

      // Inner hollow core
      ctx.strokeStyle = '#0d1b2a';
      ctx.lineWidth = 9;
      ctx.lineCap = 'butt';
      ctx.lineJoin = 'round';
      drawPath();
      ctx.stroke();
    };

    const h = cs * 0.42;

    if (p.shape === 'I') {
      // rot=0: UP<->DOWN
      strokeTube(() => {
        ctx.beginPath();
        ctx.moveTo(0, -h);
        ctx.lineTo(0, h);
      });
    } else if (p.shape === 'L') {
      // rot=0: UP(-y) and RIGHT(+x) openings - ┘ shape
      strokeTube(() => {
        ctx.beginPath();
        ctx.moveTo(0, -h);
        ctx.lineTo(0, 0);
        ctx.lineTo(h, 0);
      });
    } else if (p.shape === 'T') {
      // rot=0: LEFT(-x), RIGHT(+x), DOWN(+y) openings
      strokeTube(() => {
        ctx.beginPath();
        ctx.moveTo(-h, 0);
        ctx.lineTo(h, 0);
        ctx.moveTo(0, 0);
        ctx.lineTo(0, h);
      });
    } else if (p.shape === '+') {
      strokeTube(() => {
        ctx.beginPath();
        ctx.moveTo(0, -h);
        ctx.lineTo(0, h);
        ctx.moveTo(-h, 0);
        ctx.lineTo(h, 0);
      });
    }

    ctx.restore();

    // Rotation label
    ctx.fillStyle = '#4a90d9';
    ctx.font = '9px monospace';
    ctx.textAlign = 'right';
    ctx.textBaseline = 'alphabetic';
    ctx.fillText(`${p.rotation}°`, p.col * cs + cs - 3, p.row * cs + cs - 3);
  });
}

function drawTurrets(cs) {
  game.turrets.forEach(t => {
    const cx = t.col * cs + cs / 2;
    const cy = t.row * cs + cs / 2;
    const flash = t.flash > 0;

    // Body
    ctx.fillStyle = flash ? '#ff8fa0' : '#e94560';
    ctx.fillRect(cx - cs * 0.28, cy - cs * 0.28, cs * 0.56, cs * 0.56);

    // Barrel
    ctx.save();
    ctx.translate(cx, cy);
    ctx.rotate(t.dir * Math.PI / 2);
    ctx.fillStyle = flash ? '#ffaaaa' : '#c0392b';
    ctx.fillRect(0, -cs * 0.1, cs * 0.38, cs * 0.2);
    ctx.restore();

    // Loop index
    const loopLen = t.loop.length;
    const curIdx  = (t.idx - 1 + loopLen) % loopLen;
    ctx.fillStyle = '#e94560';
    ctx.font = '9px monospace';
    ctx.textAlign = 'center';
    ctx.textBaseline = 'alphabetic';
    ctx.fillText(`${curIdx + 1}/${loopLen}`, cx, t.row * cs + cs - 3);
  });
}

function drawBullets(cs) {
  game.bullets.forEach(b => {
    const x = b.col * cs + cs / 2;
    const y = b.row * cs + cs / 2;

    // Glow
    ctx.fillStyle = 'rgba(244,162,97,0.25)';
    ctx.beginPath(); ctx.arc(x, y, cs * 0.22, 0, Math.PI * 2); ctx.fill();

    // Core
    ctx.fillStyle = '#f4a261';
    ctx.beginPath(); ctx.arc(x, y, cs * 0.13, 0, Math.PI * 2); ctx.fill();
  });
}
