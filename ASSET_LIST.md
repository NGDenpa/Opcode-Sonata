# 资产清单

## 美术资产

### 精灵图（Sprites）
- [ ] turret_base.png (32x32)
- [ ] turret_barrel.png (32x16, 可旋转)
- [ ] bullet.png (8x8)
- [ ] target.png (32x32, 3帧动画)

### 水管图集（Pipe Tileset）
- [ ] pipe_I.png (直管)
- [ ] pipe_L.png (弯管)
- [ ] pipe_T.png (三通)
- [ ] pipe_cross.png (十字)
- 每个4个旋转角度，或用代码旋转

### UI元素
- [ ] button_play.png
- [ ] button_pause.png
- [ ] button_reset.png
- [ ] button_step.png (单步调试)
- [ ] panel_code_editor.png (loop编辑器背景)

### 特效
- [ ] bullet_trail.png (拖尾粒子)
- [ ] hit_effect.png (命中特效, 4帧)
- [ ] explosion.png (子弹碰壁, 6帧)

### 背景
- [ ] grid_pattern.png (可平铺)
- [ ] background_gradient.png

## 音频资产

### 音效（SFX）
- [ ] turret_fire.wav (发射音)
- [ ] bullet_move.wav (子弹飞行, 循环)
- [ ] pipe_rotate.wav (水管旋转)
- [ ] target_hit.wav (命中目标)
- [ ] bullet_destroy.wav (碰壁爆炸)
- [ ] ui_click.wav (按钮点击)
- [ ] level_complete.wav (胜利音效)

### 音乐（BGM）
- [ ] bgm_menu.ogg (主菜单, 循环)
- [ ] bgm_gameplay.ogg (游戏中, 120 BPM, 与tick同步)
- [ ] bgm_victory.ogg (胜利画面)

## 字体
- [ ] font_mono.ttf (代码编辑器用等宽字体)
- [ ] font_ui.ttf (UI文字)

## 数据文件

### 关卡
- [ ] levels/tutorial_01.json (教程: 直线发射)
- [ ] levels/tutorial_02.json (教程: 单个弯管)
- [ ] levels/tutorial_03.json (教程: 水管旋转)
- [ ] levels/level_01.json (正式关卡)
- [ ] levels/level_02.json
- [ ] levels/level_03.json

### 配置
- [ ] config/game_settings.json (tick速率、音量等)
- [ ] config/pipe_routes.json (水管通路查找表)

## 制作工具推荐

### 像素美术
- Aseprite (付费, 最佳)
- Piskel (免费在线)
- GIMP (免费)

### 音效
- BFXR / SFXR (程序化生成)
- Audacity (编辑)
- Freesound.org (素材库)

### 音乐
- Bosca Ceoil (简单循环音乐)
- LMMS (免费DAW)
- Beepbox (在线芯片音乐)

## 资产规格

### 分辨率
- 游戏画布: 800x600
- 网格单元: 50x50 px
- 精灵: 32x32 或 64x64 (2倍分辨率备用)

### 色板（霓虹工业风）
```
背景: #1a1a2e
网格线: #16213e
炮台: #e94560
子弹: #f4a261
水管: #0f3460
目标: #2a9d8f
UI: #e0e0e0
```

### 音频格式
- SFX: WAV 44.1kHz 16bit
- BGM: OGG Vorbis (循环点标记)

## 外包/分工建议
- **程序**: 核心引擎 + loop解析器
- **美术**: 精灵图 + 动画
- **音频**: 音效 + BGM（可用生成工具快速制作）

## 最小可玩版本（MVP）
只需这些即可测试核心玩法:
- [x] 彩色方块代替精灵
- [x] 无音效
- [x] 3个测试关卡
- [ ] 基础UI（播放/暂停/重置）
