# AI 图片资产生成记录

本文档记录 `ScrewEverydaySpriteKit` 当前使用本地 `fal-image` 生成的 UI 图片资产，便于后续复现、替换和统一风格。

## 生成工具

```bash
/Users/yd-sz-dn0588/Library/Python/3.10/bin/fal-image
```

工具参数：

- 首页主视觉：`-q medium -s portrait_4_3`
- 图鉴零件：`-q low -s square_hd`
- 模型服务：fal.ai GPT Image 2

## 风格约束

统一风格：

- 休闲益智手游风格。
- 3D 软质感、圆润边缘、轻微高光。
- 深蓝背景，匹配游戏主色 `#2D3142`。
- 主题围绕“螺丝小镇”“机器塔修理”“工坊零件”。
- 不生成文字、字母、水印。

## 资产列表

### 正式 App 图标主图

路径：

```text
ios/ScrewEverydaySpriteKit/ScrewEverydaySpriteKit/Sources/Assets.xcassets/app_icon_master.imageset/app_icon_master.png
```

Prompt：

```text
Formal mobile game app icon, cute screw town machine tower icon, centered strong silhouette, rounded square composition, bold readable shapes, brass pipes, colorful screws, warm window glow, polished cartoon 3D style, dark navy background, no text, no letters, no watermark
```

用途：

- 作为正式 AppIcon 的母图，再缩放成各个 iPhone 图标尺寸。

### 启动页主图

路径：

```text
ios/ScrewEverydaySpriteKit/ScrewEverydaySpriteKit/Sources/Assets.xcassets/launch_screen_art.imageset/launch_screen_art.png
```

Prompt：

```text
Mobile game launch screen illustration, cute screw town machine tower centered vertically with lots of breathing room, soft dark blue workshop background, subtle warm lights, rounded 3D toy style, clean composition for splash screen, no text, no letters, no watermark
```

用途：

- 启动页 `LaunchScreen.storyboard` 内使用。

### 全局工坊背景

路径：

```text
ios/ScrewEverydaySpriteKit/ScrewEverydaySpriteKit/Sources/Assets.xcassets/app_background.imageset/app_background.png
```

Prompt：

```text
Cute cartoon mobile game background, cozy screw town repair workshop interior at night, soft dark blue and purple walls, tiny brass pipes, wooden shelves, blurred machine parts, warm little lamps, polished casual puzzle game style, vertical phone background, no text, no letters, no watermark, leave center area calm for UI readability
```

用途：

- SwiftUI 首页、关卡页、图鉴页和结算页的全局氛围背景。
- 当前在代码中叠加模糊和深色遮罩，保证文字与按钮可读。

### ~~首页机器塔~~（已弃用，首页改用 mockup 设计图）

路径：

```text
ios/ScrewEverydaySpriteKit/ScrewEverydaySpriteKit/Sources/Assets.xcassets/home_machine_tower.imageset/home_machine_tower.png
```

Prompt：

```text
Stylized mobile game illustration, cozy screw town machine tower made from wooden planks, colorful screws, small gears, brass pipes, soft workshop glow, whimsical repair adventure story, centered composition, full object visible, rounded friendly shapes, polished casual puzzle game art, dark blue background matching #2D3142, no text, no letters, no watermark
```

用途：

- 首页主题视觉。
- 强化“修理机器塔”的故事性。

### 铜齿轮

路径：

```text
ios/ScrewEverydaySpriteKit/ScrewEverydaySpriteKit/Sources/Assets.xcassets/part_copper_gear.imageset/part_copper_gear.png
```

Prompt：

```text
Single collectible item icon for a mobile puzzle game: antique copper gear from a screw town machine tower, stylized 3D casual game asset, centered, full object visible, soft bevels, warm highlights, dark blue circular vignette background matching #2D3142, no text, no letters, no watermark
```

### 星形螺丝

路径：

```text
ios/ScrewEverydaySpriteKit/ScrewEverydaySpriteKit/Sources/Assets.xcassets/part_star_screw.imageset/part_star_screw.png
```

Prompt：

```text
Single collectible item icon for a mobile puzzle game: shiny star-shaped screw with colorful enamel edge, magical repair machine part, stylized 3D casual game asset, centered, full object visible, soft bevels, dark blue circular vignette background matching #2D3142, no text, no letters, no watermark
```

### 压力表

路径：

```text
ios/ScrewEverydaySpriteKit/ScrewEverydaySpriteKit/Sources/Assets.xcassets/part_pressure_gauge.imageset/part_pressure_gauge.png
```

Prompt：

```text
Single collectible item icon for a mobile puzzle game: brass pressure gauge with tiny bolts and a simple needle, from a whimsical machine tower, stylized 3D casual game asset, centered, full object visible, soft bevels, dark blue circular vignette background matching #2D3142, no text, no numbers, no letters, no watermark
```

### 飞艇桨叶

路径：

```text
ios/ScrewEverydaySpriteKit/ScrewEverydaySpriteKit/Sources/Assets.xcassets/part_airship_propeller.imageset/part_airship_propeller.png
```

Prompt：

```text
Single collectible item icon for a mobile puzzle game: small brass and wood airship propeller with screws, whimsical repair adventure machine part, stylized 3D casual game asset, centered, full object visible, soft bevels, dark blue circular vignette background matching #2D3142, no text, no letters, no watermark
```

### 蓝钢扳手

路径：

```text
ios/ScrewEverydaySpriteKit/ScrewEverydaySpriteKit/Sources/Assets.xcassets/part_blue_wrench.imageset/part_blue_wrench.png
```

Prompt：

```text
Single collectible item icon for a mobile puzzle game: blue steel wrench with tiny screw emblem, charming repair workshop collectible, stylized 3D casual game asset, centered, full object visible, soft bevels, dark blue circular vignette background matching #2D3142, no text, no letters, no watermark
```

### 核心轴承

路径：

```text
ios/ScrewEverydaySpriteKit/ScrewEverydaySpriteKit/Sources/Assets.xcassets/part_core_bearing.imageset/part_core_bearing.png
```

Prompt：

```text
Single collectible item icon for a mobile puzzle game: glowing core bearing with brass ring, small bolts, turquoise energy center, final machine tower part, stylized 3D casual game asset, centered, full object visible, soft bevels, dark blue circular vignette background matching #2D3142, no text, no letters, no watermark
```

### 临时 App 图标

路径：

```text
ios/ScrewEverydaySpriteKit/ScrewEverydaySpriteKit/Sources/Assets.xcassets/AppIcon.appiconset/app_icon_1024.png
```

说明：

- 当前临时复用 `part_core_bearing.png`。
- 用途是让 asset catalog 有合法 `AppIcon`，保证工程能编译。
- 发布前需要单独生成正式 App 图标。

## UI 图标资产

以下图标统一使用 `-q low -s square` 生成，风格均为圆润 3D 卡通手游 UI 图标，深蓝背景，无文字、无字母、无水印。

| 资产 | 用途 | Prompt 摘要 |
| --- | --- | --- |
| `icon_play` | 继续/下一关按钮 | 橙色播放三角按钮、螺丝细节 |
| `icon_levels` | 关卡入口 | 折叠关卡地图、路径和小螺丝 |
| `icon_collection` | 图鉴入口 | 零件图鉴盒、黄铜锁扣 |
| `icon_home` | 首页入口 | 螺丝小镇小屋、齿轮屋顶 |
| `icon_gift` | 奖励、奖励关、今日进度 | 工具箱礼物宝箱 |
| `icon_repair` | 修理值资源 | 黄铜螺母里的蓝绿色修理能量 |
| `icon_coin` | 金币资源 | 带螺丝头浮雕的金币 |
| `icon_back` | 返回按钮 | 蓝色珐琅返回箭头、小螺丝 |
| `icon_success` | 胜利结算 | 绿色勾、修好机器徽章 |
| `icon_fail` | 失败结算 | 红色松动螺丝警告徽章 |
| `icon_lock` | 未解锁关卡、图鉴角标 | 黄铜锁和螺丝孔 |
| `icon_check` | 已通关关卡 | 木质螺丝令牌上的绿色勾 |
| `icon_tool` | 当前/可玩普通关卡 | 螺丝刀和螺丝交叉徽章 |

## 页面 Mockup（Cute Clay 风格）

以下 mockup 统一使用 `-s portrait_9_19` 生成（608 × 1284），风格为 cute clay 3D 软质感黏土手游风。

### 胜利结算页 Mockup

路径：

```text
art/mockup_settlement_victory.png
```

Prompt：

```text
Mobile casual puzzle game victory settlement screen mockup, cute clay 3D soft texture style, rounded edges. Dark navy blue background (#2D3142). Top area: golden trophy icon with cute screws decoration, large green text VICTORY banner with ribbon. Middle area: stats card panel showing time, screws count, steps with cute icon badges, golden coins reward +10 with shiny coin icon. Bottom area: large orange rounded NEXT LEVEL button with play arrow icon, smaller dark BACK TO LEVELS button below. Decorative elements: tiny gears, confetti particles, star sparkles around trophy. Warm workshop glow atmosphere. No real text, use scribble placeholders for text areas. Polished hand-drawn mobile game UI, vertical phone layout, no watermark
```

用途：

- 胜利结算页的整体视觉参考与布局定位基准。

### 失败结算页 Mockup

路径：

```text
art/mockup_settlement_failure.png
```

Prompt：

```text
Mobile casual puzzle game failure settlement screen mockup, cute clay 3D soft texture style, rounded edges. Dark navy blue background (#2D3142). Top area: sad broken screw icon with red warning badge, large red FAILED text banner. Middle area: failure reason card showing buffer area full warning with cute worried face icon. Bottom area: large orange rounded RETRY button with refresh arrow icon as primary action, smaller dark BACK HOME button below. Decorative elements: loose screws falling, tiny sad gears. Moody but still cute atmosphere, encouraging to retry. No real text, use scribble placeholders. Polished hand-drawn mobile game UI, vertical phone layout, no watermark
```

用途：

- 失败结算页的整体视觉参考与布局定位基准。

### 游戏主界面 Mockup

路径：

```text
art/mockup_gameplay.png
```

Prompt：

```text
Mobile casual puzzle game main gameplay screen mockup, cute clay 3D soft texture style, rounded edges. Dark navy blue background (#2D3142). Layout from top to bottom: TOP HUD: small back arrow button top-left, level title center, coin counter top-right. TOOLBOX ROW: 4 cute rounded rectangular toolboxes in a row, each with 3 circular screw holes, colored borders (red, orange, teal, purple), with small handle on top. BUFFER ZONE: horizontal rounded rectangle panel with 5 empty circular holes in a row, labeled buffer area. MAIN GAME AREA: 7 rows of overlapping wooden planks with cute wood grain texture, each plank has 3 colorful screws (red, orange, yellow, teal, blue, purple, pink), some screws dimmed showing they are blocked by upper planks. Warm cozy workshop atmosphere, slight depth shadows on planks. Polished hand-drawn mobile game UI, vertical phone layout, no real text use scribble placeholders, no watermark
```

用途：

- 游戏主界面的整体视觉参考，用于指导 SpriteKit 场景的美术还原。

## 通用 UI 控件素材大图

### 控件素材合集（品红背景，用于切图）

路径：

```text
art/ui_controls_asset_sheet.png
```

Prompt：

```text
UI asset sheet for a cute clay 3D casual puzzle mobile game. Solid pure magenta (#FF00FF) background. Neatly arranged game UI controls with generous spacing between each element: TOP ROW: a round blue back arrow button with screw decoration, a round red close X button, a round green checkmark button. SECOND ROW: a large wide orange rounded rectangle CONFIRM/OK button with glossy highlight, a large wide green rounded rectangle PLAY/NEXT button with arrow icon. THIRD ROW: a large ornate blue rounded rectangle popup dialog background frame with decorative corner screws and gear ornaments, golden title banner ribbon on top. FOURTH ROW: small decorative elements - golden star, silver gear, bronze screw, sparkle effect, ribbon banner. FIFTH ROW: a horizontal stamina bar with green fill, a coin counter pill shape with gold coin icon. All elements in cute clay 3D soft texture style with rounded edges. No shadows on background, flat arrangement, sharp outlines on each element. Each control is clearly separated. No text, no watermark
```

用途：

- 通用 UI 控件素材源图。品红色背景便于 chroma key 去底切图。
- 包含：返回按钮、关闭按钮、确认按钮、确定/下一步长按钮、弹窗背景框、装饰元素（星星/齿轮/螺丝/闪光/缎带）、体力条、金币条。
- 切出的透明 PNG 可用于结算页、游戏页、弹窗等所有界面的通用控件。

## 首页 Mockup 备选方案（2D 卡通风格）

以下 3 套首页 mockup 统一使用 `-s portrait_9_19` 生成（608 × 1284），用于对比选择首页视觉方向。

### 方案 A：活泼明快 (Playful)

路径：

```text
art/mockup_home_2d_playful.png
```

Prompt：

```text
Mobile casual puzzle game home screen mockup, 2D flat cartoon style with bold outlines and vibrant colors. Dark navy background. Top bar: heart stamina icon with pink bar on left, golden coin counter on right. Center: a large cheerful cartoon screw town machine tower illustration with colorful gears, pipes, and funny face bolts, warm golden glow behind it. Title area: bubbly game logo banner with screw and gear decorations. Bottom: huge bright orange START button with bouncy shape, two smaller side buttons for LEVELS (map icon) and COLLECTION (book icon). Floating decorative screws, stars, and tiny gears scattered around. Fun playful energy, inviting to tap. Vertical phone layout 9:19, no real text use wavy scribble placeholders, no watermark
```

风格关键词：高饱和糖果色、拟人化螺丝角色、气泡标题框、活泼弹跳感。

### 方案 B：温馨手绘 (Cozy)

路径：

```text
art/mockup_home_2d_cozy.png
```

Prompt：

```text
Mobile casual puzzle game home screen mockup, 2D hand-drawn cartoon style with soft pastel colors and warm lighting. Cozy dark blue workshop background with wooden shelves. Top bar: cute heart life counter left, shiny coin counter right with subtle glow. Center: adorable 2D illustrated repair workshop scene with a quirky machine tower made of mismatched parts, tiny helper character peeking out, tools hanging on wall hooks. Middle: playful game title ribbon with gear ornaments. Bottom: large rounded green PLAY button with wrench icon, flanked by circular level-select and collection buttons. Scattered cute stickers: mini screws, nuts, sparkles. Warm homey feeling. Vertical phone layout 9:19, no real text use scribble placeholders, no watermark
```

风格关键词：暖色调工坊、手绘质感、可爱修理工角色、缝线按钮、居家温馨感。

### 方案 C：漫画爆裂 (Pop Art)

路径：

```text
art/mockup_home_2d_pop.png
```

Prompt：

```text
Mobile casual puzzle game home screen mockup, 2D pop art cartoon style with high contrast, thick black outlines, comic halftone dots, and saturated candy colors. Deep purple-blue background with radial burst pattern. Top bar: neon pink stamina bar left, glowing gold coin badge right. Center: explosive comic-style machine tower bursting with colorful screws flying outward, dynamic action lines, POW-style energy bursts. Title: bold chunky comic font style banner with metallic screw border. Bottom: massive yellow-orange PLAY button with speed lines and arrow, side buttons styled as comic panels for levels and collection. Electric fun arcade energy. Vertical phone layout 9:19, no real text use scribble placeholders, no watermark
```

风格关键词：波普放射线、漫画半调网点、爆炸动态感、粗描边、街机能量。

### 方案 A-v2：活泼明快（无涂鸦占位）

路径：

```text
art/mockup_home_2d_playful_v2.png
```

Prompt：

```text
Mobile casual puzzle game home screen mockup, 2D flat cartoon style with bold outlines and vibrant colors. Dark navy background. Top bar: heart stamina icon with pink bar on left, golden coin counter on right. Center: a large cheerful cartoon screw town machine tower illustration with colorful gears, pipes, and funny face bolts, warm golden glow behind it. Title area: bubbly game logo banner with screw and gear decorations. Bottom: huge bright orange START button with bouncy shape, two smaller side buttons for LEVELS (map icon) and COLLECTION (book icon). Floating decorative screws, stars, and tiny gears scattered around. Fun playful energy, inviting to tap. Vertical phone layout 9:19, no watermark
```

### 方案 A-v3：Candy Crush / Homescapes 风格

路径：

```text
art/mockup_home_2d_playful_v3.png
```

Prompt：

```text
Mobile casual puzzle game home screen mockup, 2D flat cartoon style with bold outlines and bright saturated colors, similar to Candy Crush or Homescapes style. Dark navy starry background. Top bar: pink heart life bar on left with plus button, gold coin counter on right with plus button. Center: a big fun cartoon machine tower made of colorful screws, gears, pipes with cute emoji faces, radiating warm light. Large decorative game title banner above the tower with ribbon and screw ornaments. Bottom: oversized glossy orange rounded rectangle PLAY button with white arrow, two square icon buttons on sides for levels and collection. Cheerful confetti, floating screws, gear particles, star sparkles. Mainstream casual mobile game aesthetic. Vertical phone layout 9:19, no watermark
```
