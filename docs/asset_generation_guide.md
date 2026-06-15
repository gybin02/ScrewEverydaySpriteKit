# 游戏 UI 素材生成指南

## 场景1：全部控件合并生成（推荐）

**一次生成所有控件在同一张图上，白底、位置与原图一致，可直接用于裁剪。**

```bash
fal-image \
  -i 'mockup.png' \
  -s portrait_9_19 \
  -o 'asset_all.png' \
  "Keep all UI control elements in exact same position and size as the reference image: [列举控件位置描述]. Remove all background scenery, decorations, character, and replace with pure white background. Maintain cute clay 3D style for all elements. 9:16 portrait layout."
```

### 本项目实际使用的提示语

```
Keep all UI control elements in exact same position and size as the reference image: top-left life bar, top-right coin bar, left-side Daily/Rank/Pets icon buttons, right-side Shop/Settings icon buttons, bottom PLAY button. Remove all background scenery, decorations, character, and replace with pure white background. Maintain cute clay 3D style for all elements. 9:16 portrait layout.
```

### 优化后的通用提示语模板

适用于任意游戏主界面 mockup，只需替换 `[控件列表]`：

```
Preserve all interactive UI controls from the reference image at their exact same positions and sizes: [控件列表]. 
Replace everything else (background, scenery, characters, decorations) with a solid pure white background. 
Keep the original art style of each UI element unchanged. Same aspect ratio as input image.
```

**示例替换：**
- 横版游戏：`top HUD bar, left skill buttons, right joystick area, center boss health bar`
- 竖版休闲：`top-left life bar, top-right coin bar, side icon buttons, bottom main action button`

### 关键提示语要点

| 要点 | 说明 |
|------|------|
| `exact same position and size` | 锁定控件位置不变 |
| `Replace everything else with pure white` | 比 "white background" 更精确，强调替换而非添加 |
| `Keep the original art style unchanged` | 防止模型改变控件风格 |
| `Same aspect ratio as input image` | 保持画布比例，避免裁切 |

---

## 场景2：生成纯背景图（去除控件）

与方式二互补，生成只保留背景场景、去除所有控件的图。两张图叠加即为完整效果图。

```bash
fal-image \
  -i 'mockup.png' \
  -s portrait_9_19 \
  -o 'bg_output.png' \
  "Remove all interactive UI controls ([控件列表]) from the reference image. Fill the removed areas naturally with the surrounding background. Keep everything else (background, scenery, characters, decorations) unchanged. Same aspect ratio as input image."
```

### 通用提示语模板

```
Remove all interactive UI controls ([控件列表]) from the reference image. 
Fill the removed areas naturally with the surrounding background. 
Keep everything else (background, scenery, characters, decorations) unchanged. 
Same aspect ratio as input image.
```

### 关键提示语要点

| 要点 | 说明 |
|------|------|
| `Remove all interactive UI controls` | 明确移除对象是控件 |
| `Fill the removed areas naturally` | 用周围背景自然填充，避免白块 |
| `Keep everything else unchanged` | 保留场景完整性 |

### 素材分层结构

```
mockup.png          → 完整效果图（参考用）
asset_all.png       → 白底 + 全部控件（方式二）
bg.png              → 纯背景无控件（方式三）
asset_all + bg      → 叠加还原完整效果
```

---

## 工具说明

```
fal-image [-i INPUT] [-s SIZE] [-o OUTPUT] PROMPT

SIZE 预设：
  square_hd       1:1 高清
  portrait_9_19   9:19 竖版（接近9:16）
  portrait_16_9   16:9 横版
  landscape_4_3   4:3 横版
  WxH             自定义尺寸
```

> 费用约 $0.01/张（quality=low）
