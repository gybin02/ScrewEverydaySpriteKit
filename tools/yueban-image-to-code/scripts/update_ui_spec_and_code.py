#!/usr/bin/env python3
"""Update docs/ui-spec.md and generate SwiftUI code based on layers.manifest.json."""

import json
import sys
from pathlib import Path

def generate_markdown_table(data: list) -> str:
    table = [
        "| 图层 ID | 原始尺寸 (W x H) | 缩放后尺寸 (W x H) | 原始坐标 (X, Y) | 缩放后坐标 (X, Y) | zIndex |\n"
        "| :--- | :---: | :---: | :---: | :---: | :---: |"
    ]
    for item in data:
        layer_id = item.get("id", "N/A")
        s_bbox = item.get("source_bbox", {})
        sc_bbox = item.get("scaled_bbox", {})
        z_index = item.get("z_index", 0)
        
        sw, sh = s_bbox.get("width", 0), s_bbox.get("height", 0)
        scw, sch = sc_bbox.get("width", 0), sc_bbox.get("height", 0)
        sx, sy = s_bbox.get("x", 0), s_bbox.get("y", 0)
        scx, scy = sc_bbox.get("x", 0), sc_bbox.get("y", 0)
        
        table.append(
            f"| `{layer_id}` | {sw}x{sh} | {scw}x{sch} | ({sx}, {sy}) | ({scx}, {scy}) | {z_index} |"
        )
    return "\n".join(table)

def generate_swiftui_code(data: list) -> str:
    lines = [
        "// === 自动生成的 SwiftUI 叠加图层布局代码 ===",
        "// 适配基准设计稿尺寸: 750 x 1342",
        "GeometryReader { geo in",
        "    let scale = geo.size.width / 750.0",
        "    ZStack(alignment: .topLeading) {",
    ]
    
    # 第一个元素通常是 background
    bg_item = None
    other_items = []
    
    for item in data:
        if item.get("id") == "background":
            bg_item = item
        else:
            other_items.append(item)
            
    if bg_item:
        asset_name = Path(bg_item.get("asset", "")).stem
        lines.append(f"        // 背景大图")
        lines.append(f"        Image(uiImage: .bundled(\"{asset_name}\"))")
        lines.append(f"            .resizable()")
        lines.append(f"            .aspectRatio(contentMode: .fill)")
        lines.append(f"            .frame(width: geo.size.width, height: geo.size.height)")
        lines.append(f"            .clipped()")
        lines.append("")
        
    for item in other_items:
        layer_id = item.get("id")
        asset_name = Path(item.get("asset", "")).stem
        sc_bbox = item.get("scaled_bbox", {})
        scx = sc_bbox.get("x", 0)
        scy = sc_bbox.get("y", 0)
        scw = sc_bbox.get("width", 0)
        sch = sc_bbox.get("height", 0)
        z_index = item.get("z_index", 0)
        
        lines.append(f"        // 图层: {layer_id}")
        if "button" in layer_id:
            lines.append(f"        Button(action: {{")
            lines.append(f"            // 在此处绑定按钮点击事件")
            lines.append(f"            print(\"点击了 {layer_id}\")")
            lines.append(f"        }}) {{")
            lines.append(f"            Image(uiImage: .bundled(\"{asset_name}\"))")
            lines.append(f"                .resizable()")
            lines.append(f"                .scaledToFit()")
            lines.append(f"        }}")
        else:
            lines.append(f"        Image(uiImage: .bundled(\"{asset_name}\"))")
            lines.append(f"            .resizable()")
            lines.append(f"            .scaledToFit()")
            
        lines.append(f"        .frame(width: CGFloat({scw}) * scale, height: CGFloat({sch}) * scale)")
        lines.append(f"        .offset(x: CGFloat({scx}) * scale, y: CGFloat({scy}) * scale)")
        lines.append(f"        .zIndex({z_index})")
        lines.append("")
        
    lines.append("    }")
    lines.append("}")
    lines.append("// =========================================")
    return "\n".join(lines)

def main():
    project_root = Path(__file__).resolve().parents[3]
    manifest_path = project_root / "art/slicing/layers.manifest.json"
    ui_spec_path = project_root / "docs/ui-spec.md"
    
    if not manifest_path.exists():
        print(f"❌ 找不到 layers.manifest.json: {manifest_path}", file=sys.stderr)
        return 1
        
    try:
        data = json.loads(manifest_path.read_text(encoding="utf-8"))
    except Exception as e:
        print(f"❌ 解析 json 失败: {e}", file=sys.stderr)
        return 1
        
    # 生成 Markdown 数据
    md_table = generate_markdown_table(data)
    
    # 更新 docs/ui-spec.md
    if ui_spec_path.exists():
        content = ui_spec_path.read_text(encoding="utf-8")
        
        start_tag = "<!-- START AUTO GENERATED HOME LAYOUT -->"
        end_tag = "<!-- END AUTO GENERATED HOME LAYOUT -->"
        
        if start_tag in content and end_tag in content:
            print(f"🔄 正在更新 {ui_spec_path.name} 中的定位表格...")
            parts = content.split(start_tag)
            before = parts[0]
            after = parts[1].split(end_tag)[1]
            
            new_content = f"{before}{start_tag}\n\n{md_table}\n\n{end_tag}{after}"
            ui_spec_path.write_text(new_content, encoding="utf-8")
            print(f"✅ {ui_spec_path.name} 更新成功！")
        else:
            print(f"⚠️ {ui_spec_path.name} 中未找到自动生成标记，将在文档末尾追加内容。")
            new_content = (
                f"{content}\n\n## 10. 自动生成定位信息\n\n"
                f"{start_tag}\n\n{md_table}\n\n{end_tag}\n"
            )
            ui_spec_path.write_text(new_content, encoding="utf-8")
            print(f"✅ {ui_spec_path.name} 追加更新成功！")
    else:
        print(f"⚠️ 找不到 {ui_spec_path}，无法自动更新文档。")
        
    # 生成 SwiftUI 代码
    swift_code = generate_swiftui_code(data)
    print("\n" + swift_code)
    
    # 写入临时的代码预览文件，方便查看
    code_preview_path = project_root / "art/slicing/qa/swiftui_preview.swift.txt"
    code_preview_path.parent.mkdir(parents=True, exist_ok=True)
    code_preview_path.write_text(swift_code, encoding="utf-8")
    print(f"\n💾 SwiftUI 布局代码已同步保存至: {code_preview_path.name}")
    
    return 0

if __name__ == "__main__":
    sys.exit(main())
