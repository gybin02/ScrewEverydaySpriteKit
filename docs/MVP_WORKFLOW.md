# 从单屏游戏界面到可玩 MVP 流程

本文档记录 `ScrewEverydaySpriteKit` 这次从“只有一个 SpriteKit 游戏界面”扩展为“可连续游玩的 MVP”的落地流程。后续其它小游戏如果已经有核心玩法页，也可以按这个流程补齐 App 闭环。

## 1. MVP 目标定义

单屏游戏界面只证明“这一局能玩”。可玩 MVP 需要证明“玩家能持续进入、推进、获得反馈、保存进度并继续玩”。

本次 MVP 范围：

- 首页：承载主题、继续游戏、关卡入口、图鉴入口、今日目标。
- 关卡页：展示章节进度、关卡节点、当前关卡奖励。
- 游戏页：复用原 SpriteKit 玩法页，增加外层返回按钮。
- 结算页：展示胜负、用时、步数、获得奖励、下一目标。
- 收藏图鉴：轻量展示长期收集目标。
- 本地存档：保存关卡、奖励、图鉴和今日进度。
- 固定关卡：用固定 seed 替代完全随机入口，保证可重复验证。

暂不做：

- 广告、内购、登录、云存档。
- 复杂经济系统。
- 真实素材图包。
- ~~设置页、暂停页、道具系统。~~ ✅ 已在后续迭代中实现（见 `EXPERIENCE_AND_AUDIO.md`）。

## 2. 保持玩法核心边界

已有 SpriteKit 游戏页不直接承担 App 路由、关卡进度和奖励发放。它只负责一局游戏：

- 根据关卡 seed 生成一局。
- 处理触摸、动画、胜负判定。
- 记录步数和用时。
- 在胜利或失败时回传 `GameRunSummary`。

外层 SwiftUI 负责：

- 页面切换。
- 关卡选择。
- 结算奖励。
- 存档更新。
- 首页和图鉴展示。

这样做的好处：

- SpriteKit 场景不会和菜单、奖励、存档耦合。
- 结算页可以独立迭代。
- 后续接入 App Store 截图和素材更方便。

## 3. 新增数据模型

最小需要 4 类模型：

### 3.1 关卡描述

```swift
struct LevelDescriptor {
    let id: Int
    let seed: UInt32
    let chapter: Int
    let title: String
    let difficulty: Int
    let rewardCoins: Int
    let repairValue: Int
    let collectionName: String?
}
```

用途：

- 关卡页显示。
- 游戏页固定 seed。
- 结算页奖励展示。
- 图鉴解锁来源。

### 3.2 关卡表

```swift
enum LevelCatalog {
    static let levels: [LevelDescriptor] = ...
}
```

第一版可以直接在代码里生成 60 关：

- 每 20 关一个章节。
- 每 10 关给一个图鉴零件。
- 每关有金币和修理值奖励。
- seed 使用固定公式生成，保证每关可复现。

### 3.3 单局结果

```swift
struct GameRunSummary {
    let level: LevelDescriptor
    let didWin: Bool
    let moves: Int
    let duration: TimeInterval
    let remainingScrews: Int
}
```

用途：

- 结算页展示。
- 存档奖励计算。
- 后续做数据埋点或难度分析。

### 3.4 本地存档

```swift
struct GameProgressState: Codable {
    var highestUnlockedLevel: Int
    var completedLevels: [Int]
    var coins: Int
    var repairValue: Int
    var unlockedCollections: [String]
    var dailyCompleted: Int
}
```

第一版用 `UserDefaults` 足够。等数据复杂后再考虑文件存档或数据库。

## 4. 页面路由

新增 SwiftUI 根页面，用 enum 管理路由：

```swift
enum AppRoute {
    case home
    case levels
    case collection
    case game(LevelDescriptor)
    case settlement(SettlementState)
}
```

入口从直接展示 `GameView()` 改成：

```swift
WindowGroup {
    AppRootView()
}
```

页面跳转原则：

- 首页 `继续` -> 当前最高解锁关卡。
- 首页 `关卡` -> 关卡页。
- 首页 `图鉴` -> 图鉴页。
- 关卡页 `开始` -> 游戏页。
- 游戏页胜负 -> 结算页。
- 结算页 `下一关/再试一次` -> 游戏页。
- 结算页 `首页/关卡` -> 对应页面。

## 5. 首页设计

首页必须回答 3 个问题：

- 这是什么游戏？
- 我现在应该点哪里？
- 继续玩能得到什么？

本次首页结构：

- 顶部资源：修理值、金币。
- 标题：`打个螺丝`。
- 副标题：`修好今天的机器塔`。
- 主题视觉：程序化机器塔。
- 主按钮：`继续第 N 关`。
- 次按钮：`关卡`、`图鉴`。
- 今日目标：`今日修理进度 x/5`。

主题故事保持短：

```text
螺丝小镇的机器塔每天都会松动。
玩家是新来的修理师，需要把散落在木板机关里的彩色螺丝拧回工具箱。
```

## 6. 关卡页设计

关卡页必须让玩家知道：

- 当前在哪个章节。
- 哪些关卡已完成。
- 当前能玩哪一关。
- 下一关奖励是什么。

本次关卡页结构：

- 顶栏：返回、标题、章节名。
- 章节进度：例如 `松动的工坊 0/20`。
- 关卡节点网格：4 列。
- 当前关卡卡片：关卡名、奖励、开始按钮。

节点状态：

- 已通关：彩色状态。
- 当前关：高亮描边。
- 未解锁：锁图标、灰色。
- 奖励关：礼物图标。

## 7. 游戏页改造

原 `GameScene` 需要做 4 个改造：

### 7.1 注入关卡

```swift
init(level: LevelDescriptor, onFinish: @escaping (GameRunSummary) -> Void)
```

### 7.2 固定 seed

```swift
level = LevelGenerator.generate(seed: levelDescriptor.seed)
```

### 7.3 记录单局数据

- `moveCount`：每次有效点击螺丝加 1。
- `startedAt`：开局时间。
- `remainingScrews`：结算时剩余螺丝数。

### 7.4 胜负回调

胜利或失败后不再点击重开，而是延迟回传外层：

```swift
onFinish(summary)
```

SpriteKit 内仍可以短暂显示遮罩和提示，例如：

- `正在结算奖励...`
- `正在整理失败原因...`

## 8. 结算页设计

结算页必须承担“反馈”和“继续”的任务。

胜利结算展示：

- `修理完成!`
- 第几关、用时、步数。
- 金币奖励。
- 修理值奖励。
- 图鉴零件奖励。
- 今日进度条。
- 下一目标。
- `下一关`、`关卡`、`首页`。

失败结算展示：

- `备选区满了`。
- 失败原因。
- 少量保底奖励。
- 今日进度或鼓励目标。
- `再试一次`、`关卡`、`首页`。

第一版失败也可以给少量保底奖励，减少挫败感。

## 9. 收藏图鉴设计

如果目标是让玩家继续完成更多关卡，建议保留图鉴。

第一版不要做复杂养成，只做轻量长期目标：

- 6 个机器零件。
- 每 10 关解锁 1 个。
- 未解锁显示问号。
- 已解锁显示零件名和图标。

当前图鉴不是图片素材，而是 SwiftUI + SF Symbols 程序绘制：

- 未解锁：`questionmark`
- 已解锁：`gearshape.2.fill`
- 卡片：`RoundedRectangle`

后续如果要提高品质，再用 AI 生成真实零件图标。

## 10. 素材策略

MVP 阶段优先程序化绘制：

- SwiftUI：按钮、卡片、图鉴、首页机器塔。
- SpriteKit：木板、螺丝、工具箱、备选区。
- SF Symbols：返回、播放、地图、图鉴、礼物、锁、齿轮等图标。

原因：

- 不阻塞玩法闭环。
- 不增加素材尺寸和版权问题。
- 容易适配不同屏幕。
- 方便 App Store 截图前快速调整。

需要 AI 素材时再生成：

- App 图标。
- 首页主视觉。
- 图鉴零件图标。
- 商店截图背景。
- 宣传图。

如果使用本地 `fal-image`，生成后要记录：

- prompt。
- 输出路径。
- 尺寸。
- 是否需要透明背景。
- 接入位置。

## 11. 验证流程

每次从单屏改成 MVP 后至少验证：

### 11.1 生成工程

```bash
xcodegen generate
```

### 11.2 编译

```bash
xcodebuild \
  -project ScrewEverydaySpriteKit.xcodeproj \
  -scheme ScrewEverydaySpriteKit \
  -destination 'generic/platform=iOS Simulator' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

### 11.3 模拟器运行

使用 XcodeBuildMCP：

- `session_show_defaults`
- `list_sims`
- `session_set_defaults`
- `build_run_sim`
- `screenshot`
- `snapshot_ui`

### 11.4 页面检查

必须检查：

- 首页首屏非空，主按钮可见。
- 关卡页当前关可点，未解锁关不可点。
- 游戏页能从关卡页进入。
- 游戏页返回按钮可回首页。
- 图鉴页能打开，未解锁状态正常。
- 结算页能通过胜负回调进入。
- 文本没有明显重叠。
- 刘海和安全区没有遮挡主控件。

## 12. 发布前剩余清单

完成 MVP 后，距离 App Store 发布还需要：

- 真机测试。
- ~~音效和触觉反馈。~~ ✅ 已完成。
- ~~App 图标。~~ ✅ 已完成（临时复用核心轴承图片，正式版待替换）。
- ~~启动画面。~~ ✅ 已完成。
- App Store 截图。
- 隐私政策。
- 年龄分级。
- 崩溃和长时间游玩测试。
- ~~关卡难度曲线校准。~~ ✅ 已完成（动态难度梯度曲线）。
- 如接入广告、统计或内购，需要补隐私清单和审核说明。

第一版发布建议保持：

- 无登录。
- 无广告。
- 无内购。
- 本地单机。
- 固定关卡。
- 本地存档。

这样审核风险最低，也更适合先验证玩法。
