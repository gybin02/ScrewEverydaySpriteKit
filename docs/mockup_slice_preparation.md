# Mockup 设计图切图准备指南 (mockup_slice_preparation)

本指南为 **AI 绘图生成 UI 素材**到**切图处理**的前置准备阶段提供了系统化的架构指导。其核心目标是定义规范的提示词模板、图层分离架构以及防毛刺标准，确保生成的素材可直接用于高精度自动裁剪与代码级像素还原。

---

## 1. 分层解耦设计架构 (Decoupled Asset Architecture)

为了实现 UI 元素在不同屏幕尺寸下的自由缩放、自适应布局以及无损还原，本项目采用**“控件层 + 背景层”**的分层解耦资产架构：

```
+-------------------------------------------------------------+
|                     mockup.png (完整效果图)                   |
+-------------------------------------------------------------+
                               |
                               v (AI 分层生成)
           +-------------------+-------------------+
           |                                       |
           v                                       v
+-----------------------------+         +-----------------------------+
|    asset_all.png (控件大图)  |         |      bg.png (纯背景图)       |
|  - 纯单色/品红色背景           |         |  - 移除所有交互控件和主视觉图          |
|  - 控件尺寸与相对位置无偏差  |         |  - 画面自然填充补全          |
+-----------------------------+         +-----------------------------+
           |                                       |
           v (自动高精度切除底色)                   |
+-----------------------------+                   |
| 独立透明素材 (play_btn 等)  |                   |
+-----------------------------+                   |
           |                                       |
           +-------------------+-------------------+
                               |
                               v (代码层像素级叠加还原)
+-------------------------------------------------------------+
|                    最终渲染 UI (SwiftUI/HTML)                |
+-------------------------------------------------------------+
```

* **Mockup 效果图**：作为整体视觉参考与布局定位的设计基准。
* **控件大图 (asset_all.png)**：将所有交互组件（按钮、状态条等）以原始比例与相对位置，画在品洋红色背景上，作为裁剪脚本的输入源。
* **纯背景图 (bg.png)**：剔除全部交互组件，并用 AI 算法将挖空区域补齐，作为游戏主界面的底层底图。

---

## 2. AI 绘图提示词架构规范 (AI Prompt Specification)

为了保证 AI 生成的“控件大图”和“纯背景图”在位置与比例上与原 Mockup 严密重合，且生成的边缘利落、无发光毛刺，必须遵循如下提示词模板及术语标准：

### 2.1 控件大图 (asset_all.png) 生成规范
#### A. 通用提示词架构模板
```
Preserve all interactive UI controls from the reference image at their exact same positions and sizes: [列举关键控件及其方位]. 
Replace everything else (background, scenery, characters, decorations) with a solid pure magenta (#FF00FF) background (or pure lime green #00FF00). 
Ensure no shadows, flat 2d asset, and sharp outline. 
Keep the original art style of each UI element unchanged. Same aspect ratio as input image.
```
* **示例替换（主界面）**：`top-left life bar, top-right coin bar, side icon buttons, bottom main PLAY button`

#### B. 核心控制术语说明与防毛刺标准
| 控制术语 | 架构层作用 | 防毛刺/防偏差原理解析 |
| :--- | :--- | :--- |
| `exact same position and size` | 锁定控件的相对空间坐标 | 避免控件产生大小或位移形变，保障切图坐标与背景图精准重合 |
| `solid pure magenta (#FF00FF) background` | **背景颜色锁**：使用高对比度纯洋红（或纯绿幕 `#00FF00`）作为背景色 | 洋红色与 UI 元素（多为暖色粘土风）互补，提供最大色彩对比度，使切图工具能 100% 滤净边缘，**避免产生淡白色毛刺** |
| `no shadows, flat 2d asset, sharp outline` | **阴影与发光剥离**：禁止 AI 生成软阴影或渐变高光 | 模糊阴影会向外扩散并与背景底色混合，撑大元素的真实 Bounding Box 导致定位偏移；**阴影需由前端或 iOS 代码层动态渲染** |
| `Keep the original art style unchanged` | 约束模型锁死材质与美术风格 | 规避按钮被模型自行二次重绘，产生扁平化或风格漂移 |
| `Same aspect ratio as input image` | 锁死画布宽高比例 | 避免大图被自动裁切、横屏横置或被强行加黑边 |

---

### 2.2 纯背景图 (bg.png) 生成规范
#### A. 通用提示词架构模板
```
Remove all interactive UI controls ([列举需移去的控件名称]) from the reference image. 
Fill the removed areas naturally with the surrounding background scenery. 
Keep everything else (background, scenery, characters, decorations) unchanged. Same aspect ratio as input image.
```

#### B. 核心控制术语说明
| 控制术语 | 架构层作用 | 规避的异常 |
| :--- | :--- | :--- |
| `Remove all interactive UI controls` | 明确指定被擦除的对象仅限交互组件 | 误删了背景里的非交互装饰或主要场景特征 |
| `Fill the removed areas naturally` | 引导模型采用纹理向内膨胀填充算法 | 按钮扣去后留白、留空或者生成逻辑不通的奇怪物件 |

---


## 4. 工具链调用与生成预设 (Toolchain & Resolution Presets)

在生成和切图准备中，使用 `fal-image` 工具，并匹配相应的尺寸参数：

```bash
fal-image [-i INPUT_MOCKUP] [-s SIZE_PRESET] [-o OUTPUT_PATH] PROMPT
```

### 尺寸预设规范 (Resolution Presets)
* **竖屏全面屏 (接近 9:16)**：`portrait_9_19` (常用于移动端主界面，对应物理尺寸 608 × 1280 左右)。
* **横屏设备 (16:9)**：`portrait_16_9`。
* **平板与传统比例 (4:3)**：`landscape_4_3`。
