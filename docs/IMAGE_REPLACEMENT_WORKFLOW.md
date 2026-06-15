# 打个螺丝图片替换流程

本文档记录当前 `ScrewEverydaySpriteKit` 从“程序化 UI”逐步替换为“AI 图片 UI”的具体流程。目标是让后续新增或替换素材时，有一套固定、可复用的操作方法。

## 1. 目标

把界面从偏工程化的样式，统一调整为更像卡通可爱手游的视觉语言：

- 首页要有主题故事感。
- 按钮、资源条、结算图标尽量使用图片，不用系统 SF Symbols。
- 图鉴页要由图片主导，而不是纯文本列表。
- 背景图要提供氛围，但不能压住正文和按钮。

## 2. 适用范围

适用于以下页面元素：

- 首页背景和主视觉。
- 关卡页状态图标和当前关卡图标。
- 图鉴页零件图和未解锁状态。
- 结算页胜利、失败、奖励图标。
- 资源条图标、按钮图标、返回按钮图标。
- 临时 App 图标和商店截图素材。

## 3. 当前资产结构

图片资产统一放在：

```text
ios/ScrewEverydaySpriteKit/ScrewEverydaySpriteKit/Sources/Assets.xcassets/
```

命名规范：

- 背景：`app_background`
- 首页主视觉：mockup 设计图切图（见 `MOCKUP_UI_WORKFLOW.md`）
- 图标：`icon_*`
- 图鉴零件：`part_*`

示例：

- `icon_play`
- `icon_levels`
- `icon_collection`
- `part_copper_gear`

## 4. 生成工具

当前使用本地 `fal-image`：

```bash
/Users/yd-sz-dn0588/Library/Python/3.10/bin/fal-image
```

常用参数：

- 背景图：`-q low|medium -s portrait_4_3`
- UI 图标：`-q low -s square`
- 图鉴零件：`-q low -s square_hd`

## 5. 生成原则

### 5.1 风格统一

所有素材要满足：

- 卡通、圆润、可爱。
- 3D 软质感，轻微高光。
- 深蓝或暗色背景，和游戏主色调一致。
- 不要写文字、数字、品牌字样。
- 不要出现水印。

### 5.2 先图标，后主视觉

优先顺序：

1. 按钮和状态图标。
2. 首页主视觉。
3. 图鉴零件。
4. 背景图。
5. App 图标和商店图。

这样可以先把界面的识别性做出来，再处理氛围。

### 5.3 背景图的边界

背景图只负责氛围，不负责信息表达。落地时必须再叠加：

- 深色遮罩。
- 模糊。
- 文字层。
- 卡片层。

否则容易出现首页和背景抢注意力的问题。

## 6. 替换流程

### 6.1 生成图片

用 `fal-image` 生成后，把输出直接写进 `Assets.xcassets/.../*.png`。

### 6.2 补 `Contents.json`

每个 `.imageset` 或 `.appiconset` 目录都要有自己的 `Contents.json`。

### 6.3 接入代码

SwiftUI 页面统一通过：

```swift
Image("asset_name")
```

接入。

不要把 UI 图标继续写成 `Image(systemName:)`，除非它只是临时调试。

### 6.4 约束布局

图片接入后要重新检查：

- 文案是否被顶出安全区。
- 图片是否压住按钮文字。
- 图鉴图标是否太暗或太小。
- 背景是否抢内容。

### 6.5 复查截图

每次替换完主要图后，都要至少看三张图：

- 首页。
- 关卡页。
- 图鉴页。

必要时再看结算页。

## 7. 页面映射

### 7.1 首页

替换目标：

- 背景图：`app_background`
- 主视觉：mockup 设计图切图
- 播放按钮：`icon_play`
- 关卡按钮：`icon_levels`
- 图鉴按钮：`icon_collection`
- 资源条：`icon_repair`、`icon_coin`

### 7.2 关卡页

替换目标：

- 返回：`icon_back`
- 当前关/已通关：`icon_tool`、`icon_check`
- 未解锁：`icon_lock`
- 奖励关：`icon_gift`

### 7.3 图鉴页

替换目标：

- 已解锁零件：`part_*`
- 未解锁零件：同一张 `part_*` 的暗色剪影 + 小锁角标

### 7.4 结算页

替换目标：

- 成功：`icon_success`
- 失败：`icon_fail`
- 奖励：`icon_gift`
- 金币：`icon_coin`
- 修理值：`icon_repair`
- 下一关：`icon_play`

## 8. 当前代码入口

相关实现集中在：

- [AppRootView.swift](/Users/yd-sz-dn0588/Downloads/game/jsGame/ios/ScrewEverydaySpriteKit/ScrewEverydaySpriteKit/Sources/AppRootView.swift)
- [ASSET_PROMPTS.md](/Users/yd-sz-dn0588/Downloads/game/jsGame/ios/ScrewEverydaySpriteKit/ASSET_PROMPTS.md)

`AppRootView.swift` 负责页面和图标替换，`ASSET_PROMPTS.md` 负责记录每张图的 prompt。

## 9. 验证步骤

每次替换图片后都按这个顺序跑：

1. `xcodegen generate`
2. `build_sim`
3. `build_run_sim`
4. `screenshot`
5. 目检首页、关卡页、图鉴页

如果图片改动较大，还要检查：

- 首页标题是否被背景干扰。
- 按钮图标是否清晰。
- 图鉴零件是否仍能辨识。
- 结算页图标是否过大或过小。

## 10. 迭代建议

后续继续做图片优化时，建议按这个顺序：

1. 先统一所有按钮图标风格。
2. 再优化首页背景和主视觉。
3. 再丰富图鉴零件故事。
4. 最后补 App 图标、启动图和商店素材。

如果要换一版风格，先一次性生成整套，再整体替换，不要只换单个图标，否则视觉会散。
