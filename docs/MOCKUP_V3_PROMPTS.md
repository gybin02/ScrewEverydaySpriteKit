# Mockup V3 系列生成记录

基于 `art/mockup_home_2d_playful_v3.png` 首页设计风格，使用 `-i` 输入图参数保持全套界面风格统一。

## 生成工具

```bash
/Users/yd-sz-dn0588/Library/Python/3.10/bin/fal-image -i art/mockup_home_2d_playful_v3.png -s portrait_9_19 -o OUTPUT PROMPT
```

- 尺寸预设：`portrait_9_19`（608 × 1284）
- 参考图：`art/mockup_home_2d_playful_v3.png`
- 模型：fal.ai GPT Image 2/edit

## 风格定义

2D flat cartoon style, bold outlines, bright saturated colors, dark navy starry background, mainstream casual puzzle game aesthetic (Candy Crush / Homescapes 级别), cute emoji faces on machine parts, glossy buttons, floating screws/gears/sparkles particles.

---

## 1. 首页（参考源图）

路径：`art/mockup_home_2d_playful_v3.png`

```text
Mobile casual puzzle game home screen mockup, 2D flat cartoon style with bold outlines and bright saturated colors, similar to Candy Crush or Homescapes style. Dark navy starry background. Top bar: pink heart life bar on left with plus button, gold coin counter on right with plus button. Center: a big fun cartoon machine tower made of colorful screws, gears, pipes with cute emoji faces, radiating warm light. Large decorative game title banner above the tower with ribbon and screw ornaments. Bottom: oversized glossy orange rounded rectangle PLAY button with white arrow, two square icon buttons on sides for levels and collection. Cheerful confetti, floating screws, gear particles, star sparkles. Mainstream casual mobile game aesthetic. Vertical phone layout 9:19, no watermark
```

---

## 2. 游戏主界面

路径：`art/mockup_gameplay_v3.png`

```text
Mobile casual puzzle game gameplay screen, same 2D flat cartoon art style as the reference image with bold outlines and bright saturated colors. Dark navy starry background. TOP HUD: back arrow button top-left, level number and title center, gold coin counter top-right. TOOLBOX ROW: 4 colorful rounded rectangular toolboxes in a row (red, orange, teal, purple borders), each with 3 circular holes and a cute handle on top. BUFFER ZONE: dark rounded rectangle bar with 5 circular empty holes, small arrow label. MAIN GAME AREA: overlapping wooden planks arranged in rows, each plank has wood grain texture with 3 colorful cross-head screws (red, orange, yellow, teal, blue, purple, pink). Some lower screws are dimmed/blocked by upper planks. Warm workshop glow at bottom. Same cheerful particle effects: floating mini screws, gear sparkles. Vertical phone layout 9:19, no watermark
```

---

## 3. 胜利结算界面

路径：`art/mockup_victory_v3.png`

```text
Mobile casual puzzle game victory settlement screen, same 2D flat cartoon art style as the reference image with bold outlines and bright saturated colors. Dark navy starry background. TOP: large golden trophy with cute screw decorations and emoji face, sparkle rays behind it. BANNER: green ribbon banner with VICTORY text, confetti and stars exploding. MIDDLE: beige rounded card panel showing stats - clock icon with time, screw icon with count, shoe icon with steps, each row with colorful badge. REWARD ROW: gold coin icon with +10 text and coin stack. BOTTOM: huge glossy orange NEXT LEVEL button with arrow, smaller dark BACK button below. Floating celebratory screws, gears, confetti particles. Same cheerful mainstream casual game aesthetic. Vertical phone layout 9:19, no watermark
```

---

## 4. 失败结算界面

路径：`art/mockup_failure_v3.png`

```text
Mobile casual puzzle game failure screen, same 2D flat cartoon art style as the reference image with bold outlines and bright saturated colors. Dark navy starry background. TOP: large sad broken screw character with worried emoji face, red warning triangle badge, cracks and loose bolts falling. BANNER: red ribbon banner with FAILED text, small explosion marks. MIDDLE: beige rounded card panel showing failure reason - overflowing bucket icon with colorful screws spilling out, warning text area. BOTTOM: huge glossy orange RETRY button with refresh arrow icon, smaller dark HOME button below. Moody but still colorful and encouraging atmosphere, dimmed floating screws and gears. Same mainstream casual game aesthetic. Vertical phone layout 9:19, no watermark
```

---

## 5. 通用 UI 素材大图（品红背景，用于切图）

路径：`art/mockup_ui_assets_v3.png`

```text
UI asset sheet for a mobile casual puzzle game, same 2D flat cartoon art style as the reference image with bold outlines and bright saturated colors. Solid pure magenta (#FF00FF) background. Neatly arranged game UI controls with generous spacing: ROW 1: round blue back-arrow button, round red X close button, round green checkmark button, each with bold outline and screw decoration. ROW 2: large wide glossy orange rounded rectangle button, large wide green rounded rectangle button with white arrow. ROW 3: large ornate blue popup dialog frame with golden title ribbon on top, decorative corner screws and gear ornaments, same style as reference. ROW 4: small icons - golden star, silver gear, bronze screw, yellow sparkle, red ribbon banner, pink heart. ROW 5: horizontal green stamina bar with heart icon, horizontal gold coin counter bar with coin icon. All elements flat on magenta background, no shadows, sharp outlines. Vertical layout 9:19, no watermark
```

用途：品红色 `#FF00FF` 背景便于 chroma key 去底切图，切出透明 PNG 作为通用控件。

---

## 6. 弹窗界面（奖励/成就弹窗）

路径：`art/mockup_popup_v3.png`

```text
Mobile casual puzzle game popup dialog screen, same 2D flat cartoon art style as the reference image with bold outlines and bright saturated colors. Dark navy starry background with semi-transparent black overlay. CENTER: large blue rounded rectangle popup panel with golden title ribbon banner on top saying REWARD, decorative screws on corners, gear ornaments. Inside panel: achievement cup icon glowing, reward items row showing gold coins and a collectible gear part with sparkles. Bottom of panel: large glossy green CLAIM button with checkmark, small X close button top-right corner. Behind popup: dimmed game scene barely visible. Celebratory confetti and star particles around popup. Same mainstream casual game aesthetic. Vertical phone layout 9:19, no watermark
```

---

## 资产总览

| 文件 | 用途 |
| --- | --- |
| `art/mockup_home_2d_playful_v3.png` | 首页（风格源图） |
| `art/mockup_gameplay_v3.png` | 游戏主界面 |
| `art/mockup_victory_v3.png` | 胜利结算 |
| `art/mockup_failure_v3.png` | 失败结算 |
| `art/mockup_ui_assets_v3.png` | 通用控件素材（品红背景切图用） |
| `art/mockup_popup_v3.png` | 弹窗/奖励界面 |
