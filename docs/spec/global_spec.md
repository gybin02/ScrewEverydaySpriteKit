# 游戏 UI 全局规格规范 (global_spec)

本文档描述 `ScrewEverydaySpriteKit` 全局界面结构、坐标缩放规范、场景图层定义、当前实现状态以及运行验收记录。

---

## 1. 页面总览与架构

* **应用结构**：SwiftUI App Shell + `SpriteView` + 单个 `GameScene`。
* **页面组织**：
  * 主菜单/关卡选择/图鉴/结算由 SwiftUI 提供；
  * 主游戏关卡渲染、胜利/失败半透明覆盖层由 SpriteKit 场景内独立完成。
* **适配基准**：逻辑画布固定为 `720 × 1280`，在不同物理设备上根据比率等比缩放，采用水平居中与垂直居中。
* **屏幕方向**：仅支持竖屏（Portrait）。
* **安全区域**：`GameView` 视图使用 `.ignoresSafeArea()` 和 `.statusBarHidden(true)`，游戏关卡全屏铺满展示。
* **背景设计**：采用 AI 生成的卡通工坊背景 `app_background`，叠加模糊和深色遮罩；场景基础色调为深蓝灰 `#2D3142`。

---

## 2. 坐标与缩放转换规范

所有布局常量均基于**左上角为原点**的逻辑坐标系：

```swift
uiScale = min(sceneWidth / 720, sceneHeight / 1280)
offsetX = (sceneWidth - 720 * uiScale) / 2
offsetY = (sceneHeight - 1280 * uiScale) / 2

// 转换为 SpriteKit 绝对屏幕坐标
screenX = offsetX + logicalX * uiScale
screenY = sceneHeight - (offsetY + logicalY * uiScale)
```

设计和验收时优先使用逻辑坐标描述位置，实际屏幕物理位置由 `screenPoint(x:y:)` 转换。

---

## 3. 场景图层 (Layers & zPosition)

SpriteKit 场景中包含以下图层结构，必须严密指定 `zPosition` 避免渲染穿透或遮挡混乱：

| 图层 ID | zPosition | 作用与覆盖内容 |
| :--- | :---: | :--- |
| `boardLayer` | `1` | 木板本体、木板阴影和纹理高光 |
| `hudLayer` | `10` | 标题与实时状态文本 |
| `bufferLayer` | `15` | 备选区标签、框体、5 个空洞 |
| `boxLayer` | `20` | 顶部 4 个工具箱及箱内孔位 |
| `screwLayer` | `30` | 板上螺丝、备选区螺丝、飞行动画中的螺丝 |
| `overlayLayer` | `10000` | 胜利/失败/暂停半透明遮罩和文案 |

> [!NOTE]
> 螺丝节点会按其所属木板的 `z + 100` 排序，确保上层木板上的螺丝视觉上也高于下层木板上的螺丝。

---

## 4. 当前实现状态和仍未实现项

* **已实现功能**：
  * 首页、关卡页、胜利/失败后的 SwiftUI 结算页。
  * 轻量收藏图鉴页与本地存档（金币、进度、零件解锁等）。
  * 全局背景、按钮、 Launch Screen 资源。
  * 音效与触觉反馈系统（BGM、消除、胜利音效 + Taptic 振动）。
  * 游戏内暂停、退出防误触确认。
  * 道具系统：撤销（20 金币）和清空备选区（50 金币）。
  * 动态难度梯度曲线及多语言本地化。
  * 游戏内测试过关（Cheat）跳关机制。
* **仍未实现项**：
  * 收藏图鉴当前是轻量版，尚未实现图鉴详情的故事解锁页。

---

## 5. 运行验收记录

* **验收日期**：2026-06-13 / 2026-06-16 (新增跳关测试)
* **测试设备**：`iPhone 17`，`iOS 26.2` 模拟器。
* **验收结果**：构建运行通过，首页、关卡页、游戏页及测试通关与跳关流程运行正常。
