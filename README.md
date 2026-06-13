# ScrewEverydaySpriteKit

`day-01-screw` 的 iOS 原生 SpriteKit 移植版。这个目录是独立 iOS 项目，后续开发只看这里就能了解当前规则、实现结构和进度。

## 项目状态

- 已完成 SwiftUI + SpriteKit iOS 工程。
- 已完成核心玩法闭环：固定 seed 关卡、工具箱、备选区、螺丝级遮挡、消除补箱、备选区回流、胜负结算。
- 已完成 App 外围闭环：首页、关卡页、游戏页、结算页、轻量收藏图鉴、本地进度存档。
- 游戏页使用 SpriteKit 程序绘制；首页主视觉、全局背景、按钮图标、图鉴零件、正式 AppIcon 和 Launch Screen 已接入 AI 生成图片资产。
- 统一视觉规范见 `design.md`，图片替换流程见 `IMAGE_REPLACEMENT_WORKFLOW.md`。
- 已在 iPhone 17 Simulator 上 build/run 通过，并截图确认首页、关卡页和游戏页正常。

## 参考来源

原 JS 项目位于同级目录：

`../minigame-everyday/day-01-screw`

关键参考文件：

- `js/scene/GameScene.js`：玩法主流程、渲染、动画
- `js/core/config.js`：颜色、容量、尺寸常量
- `js/core/levelData.js`：随机关卡生成
- `../minigame-everyday/articles/01-day-screw.md`：复刻过程和最终规则说明
- `../minigame-everyday/agents.md`：本次移植任务记录
- `ASSET_PROMPTS.md`：AI 图片资产生成 prompt 和用途记录

## 游戏规则

### 一句话玩法

玩家点击板子上未被遮挡的螺丝。螺丝按颜色进入顶部同色工具箱，工具箱收满 3 颗后消除并补新颜色。没有同色工具箱时，螺丝进入中间 5 格备选区。备选区满 5 后再进入一颗即失败；所有工具箱和螺丝处理完即胜利。

### 关卡生成

- 基准逻辑画布：`720 x 1280`
- 颜色：7 种
- 每种颜色：9 颗螺丝
- 总螺丝数：63
- 板子数：21
- 每块板：严格 3 颗螺丝
- 主游戏区：7 行 x 3 列基础网格
- 板子形状：从 5 种宽高随机选择，并带位置抖动
- z 值：后生成的板子 z 更高，会遮挡下层螺丝

### 顶部工具箱

- 固定 4 个槽位。
- 每个工具箱有一个目标颜色和 3 个孔。
- 点击同色螺丝时，螺丝飞入当前工具箱的下一个空孔。
- 工具箱收满 3 颗后：
  - 如果补给池还有颜色，当前工具箱换成新颜色，计数归零。
  - 如果补给池为空，当前工具箱永久移除。
- 新颜色出现后会触发备选区回流。

### 备选区

- 位于工具箱和游戏区之间。
- UI 是一个圆角矩形框和 5 个圆洞。
- 点击的螺丝没有可用同色工具箱时进入备选区。
- 进入前先判断容量：已有 5 颗时再塞入一颗直接失败。
- 工具箱换新颜色后，自动扫描备选区：
  - 找到第一个能匹配任意工具箱颜色的螺丝。
  - 该螺丝飞入工具箱。
  - 剩余备选螺丝左对齐。
  - 如果工具箱再次满 3，会继续消除、补箱、扫描，形成链式回流。

### 遮挡规则

遮挡按螺丝粒度计算，不按整块板计算。

对每颗板上螺丝：

1. 找出所有未移除、z 更高的板。
2. 用螺丝圆形和上层板矩形做相交检测。
3. 只要任意上层板覆盖到螺丝圆，即该螺丝不可点击。
4. 被遮挡螺丝置灰显示。

### 胜负

- 失败：备选区已有 5 颗时，再有螺丝需要进入备选区。
- 胜利：所有螺丝都已被处理，工具箱全部消除，备选区为空。
- 结果弹层出现后，SwiftUI 外层进入结算页，展示奖励、今日进度和下一关入口。

## 实现结构

```text
ScrewEverydaySpriteKit/
├── project.yml
├── ScrewEverydaySpriteKit.xcodeproj/
└── ScrewEverydaySpriteKit/
    └── Sources/
        ├── ScrewEverydaySpriteKitApp.swift
        ├── AppRootView.swift
        ├── AppModels.swift
        ├── ProgressStore.swift
        ├── GameView.swift
        ├── GameModels.swift
        ├── LevelGenerator.swift
        └── GameScene.swift
```

### 文件职责

- `ScrewEverydaySpriteKitApp.swift`
  - SwiftUI app 入口。
- `AppRootView.swift`
  - 首页、关卡页、结算页、轻量图鉴页和页面路由。
- `AppModels.swift`
  - 固定关卡表、结算结果、奖励和存档数据结构。
- `ProgressStore.swift`
  - 基于 `UserDefaults` 的本地进度存档。
- `GameView.swift`
  - 创建并展示 `GameScene`，叠加返回按钮，并接收单局结算回调。
- `GameModels.swift`
  - 游戏常量、颜色、板子、螺丝、工具箱、关卡数据结构。
- `LevelGenerator.swift`
  - 迁移 JS 版随机数、颜色池、板子布局、螺丝排布、工具箱补给序列，支持固定 seed。
- `GameScene.swift`
  - SpriteKit 场景、坐标缩放、UI 绘制、触摸处理、动画、遮挡重算、胜负逻辑和单局结果回调。

## 关键实现说明

### 坐标系统

JS 版使用左上角为原点的逻辑坐标。SpriteKit 使用左下角为原点。

`GameScene.screenPoint(x:y:)` 负责转换：

- x：按 `uiScale` 缩放后加水平 offset
- y：按 `uiScale` 缩放后从屏幕高度反向换算

场景会根据真实设备尺寸在 `720 x 1280` 逻辑画布上等比缩放。

### 输入锁

`isBusy` 用来在螺丝飞行动画、补箱、备选区回流期间锁定输入，避免多次点击破坏状态。

### 节点与数据关系

玩法状态以 Swift 数据模型为准，SpriteKit 节点只负责视觉和交互。

- `Screw.node` 弱引用当前螺丝节点。
- 可点击螺丝通过节点名 `screw:<id>` 反查 `Screw`。
- 螺丝进入工具箱后节点会移除。
- 螺丝进入备选区后继续保留节点，但脱离原板子归属。

### 遮挡刷新时机

以下情况会重算遮挡：

- 螺丝从板子上移除后。
- 板子因为没有螺丝而移除后。
- 工具箱刚好被填满时，也会先刷新板子状态，再进入补箱和备选区回流流程。

## 构建与运行

需要本机安装 Xcode 和 XcodeGen。

生成工程：

```bash
xcodegen generate
```

命令行编译：

```bash
xcodebuild \
  -project ScrewEverydaySpriteKit.xcodeproj \
  -scheme ScrewEverydaySpriteKit \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath ./DerivedData \
  CODE_SIGNING_ALLOWED=NO \
  build
```

也可以直接用 Xcode 打开：

```text
ScrewEverydaySpriteKit.xcodeproj
```

## 当前验收记录

- `xcodegen generate`：通过
- `xcodebuild ... build`：通过
- XcodeBuildMCP `build_run_sim`：通过
- 模拟器：`iPhone 17`, `iOS 26.2`
- Bundle ID：`com.minigameeveryday.screw.spritekit`
- 截图检查：
  - 首页正常显示主题、资源、机器塔、继续按钮、关卡和图鉴入口、今日进度。
  - 关卡页正常显示章节进度、60 个关卡节点和当前关卡奖励卡片。
  - 游戏页正常显示返回按钮、标题、状态、4 个工具箱、5 个备选洞、21 块板和 63 颗螺丝。

## 后续开发建议

1. 增加音效：点击、入箱、消除、失败。
2. 增加关卡 seed 显示和固定 seed 调试入口。
3. 抽出纯逻辑层测试：关卡生成、遮挡判定、备选区回流。
4. 优化工具箱消除和补箱动画，目前以功能完整为主。
5. 增加难度层级：颜色数、板子密度、遮挡强度、备选区容量。
6. 引入真实美术资源前，先保持程序绘制版本作为可靠基线。
7. 发布前重新生成正式 App 图标，当前 AppIcon 是临时复用核心轴承图片。
8. 补齐 App Store 发布素材：启动图、商店截图、隐私政策和年龄分级。

## 已知限制

- 当前没有音效和触觉反馈。
- 当前没有暂停、撤销或道具。
- 当前关卡难度主要来自固定 seed，尚未按关卡号动态调整生成参数。
- 当前收藏图鉴是轻量版本，只记录部分关卡奖励零件，没有详情故事页。
- 当前胜利条件绑定到完整处理所有螺丝、工具箱清空和备选区清空，和 JS 最终版的“工具箱清空判胜”相比更严格。
- `DerivedData/` 是本地构建产物，不应提交。
