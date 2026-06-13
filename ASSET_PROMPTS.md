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

### 首页机器塔

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
