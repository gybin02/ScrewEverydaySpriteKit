# 首页 Mock UI 落地实现流程

## 概述

从一张 mockup 设计图出发，使用 `yueban-image-to-code` 工具完成切图，再接入 SwiftUI 代码实现首页视觉还原。

## 工具

- **yueban-image-to-code**：https://github.com/SemineChen/yueban-image-to-code
- 脚本位于 `tools/yueban-image-to-code/scripts/`
- 依赖：Python 3 + Pillow

## 流程

### 1. 准备 mockup 图

将目标设计图放入 `art/` 目录，例如 `art/mockup_story_lawn_blueprint.png`。

### 2. 分析图片尺寸

```bash
python3 -c "
from PIL import Image
img = Image.open('art/mockup_xxx.png')
w, h = img.size
scale = 750 / w
print(f'原始: {w}x{h}, scale: {scale:.4f}, 目标: 750x{round(h*scale)}')
"
```

### 3. 识别可交互元素

只切出需要独立响应点击的控件（按钮、入口），背景和纯装饰元素不切。

### 4. 定位 bbox

对不确定位置的元素，先用大区域截取定位：

```bash
python3 tools/yueban-image-to-code/scripts/extract_png_asset.py \
  source.png qa/area_check.png \
  --x X --y Y --width W --height H --remove-bg none
```

查看截取结果后精确调整坐标。

### 5. 创建 manifest（可选）

如果元素较多，可创建 `layers.manifest.json` 并用 bbox 预览脚本批量验证：

```bash
python3 tools/yueban-image-to-code/scripts/preview_bboxes.py \
  source.png layers.manifest.json qa/bbox-preview.png
```

### 6. 导出切图

```bash
python3 tools/yueban-image-to-code/scripts/extract_png_asset.py \
  source.png Resources/Images/btn_xxx.png \
  --x X --y Y --width W --height H \
  --remove-bg floodfill
```

- 纯色/简单背景：用 `--remove-bg floodfill`
- 复杂背景（草地、场景）：floodfill 效果有限，但叠加在同一背景上使用无影响

### 7. 添加到项目

将 PNG 放入 `ScrewEverydaySpriteKit/Resources/Images/`，代码中直接使用：

```swift
Image(uiImage: .bundled("btn_xxx"))
    .resizable()
    .scaledToFit()
    .frame(height: 70)
```

不需要创建 imageset，`UIImage.bundled(_:)` 会从 Bundle 路径加载。

### 8. 接入 SwiftUI

用 `Button` 包裹图片按钮，替换原有控件：

```swift
Button(action: { /* 导航逻辑 */ }) {
    Image(uiImage: .bundled("btn_start"))
        .resizable()
        .scaledToFit()
        .frame(height: 70)
}
```

### 9. 验证

```bash
xcodegen generate
xcodebuild -project ... -destination '...' build
xcrun simctl install DEVICE_ID path/to/app
xcrun simctl launch DEVICE_ID BUNDLE_ID
```

## 目录结构

```
art/
├── mockup_xxx.png              # 设计稿原图
├── slicing/
│   ├── layers.manifest.json    # bbox 标注
│   ├── qa/                     # 预览验证图
│   └── assets/images/          # 切图产物（中间产物）

ScrewEverydaySpriteKit/
├── Resources/Images/           # 最终图片资源（被 Bundle 加载）
│   ├── btn_start.png
│   ├── btn_shop.png
│   └── ...
└── Sources/
    └── UIImage+Bundled.swift   # 图片加载 helper
```

## 注意事项

- AppIcon 仍然走 `Assets.xcassets`，只需一张 1024×1024
- 其他所有图片走 `Resources/Images/` + `UIImage.bundled()`
- 复杂背景 mockup 的切图不要期望完美去背，用整张图做背景 + 按钮叠加的方式实现
- 切图坐标基于原图像素，不是缩放后的 750px 坐标
