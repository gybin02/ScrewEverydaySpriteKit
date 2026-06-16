#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
AI 生成 UI 素材大图切分工具
功能：
1. 自动移除边缘连通的浅色（接近纯白）背景为透明。
2. 对边缘像素进行高亮检测，动态降低 Alpha 并修复 RGB 以防止白边毛刺。
3. 通过连通域分析（Connected Component Labeling），提取所有独立的 UI 元素。
4. 过滤微小噪点，采用显著实体像素收缩 Bounding Box 范围，确保定位无偏移。
5. 将元素导出为独立的透明背景 PNG 图片，同时生成布局规格数据文件。
"""

import os
import sys
import argparse
from collections import deque

try:
    from PIL import Image
    import numpy as np
except ImportError:
    print("错误: 缺少依赖库，请先安装 Pillow 和 numpy：")
    print("pip3 install pillow numpy")
    sys.exit(1)


def flood_fill_remove_bg(img, threshold=245):
    """
    使用广度优先搜索 (BFS) 将与图片四边缘连通的、亮度高于 threshold 的像素转为透明背景。
    """
    img = img.convert('RGBA')
    w, h = img.size
    pixels = img.load()

    visited = np.zeros((w, h), dtype=bool)
    queue = deque()

    # 判断是否为需要去除的极浅底色
    def is_bg_color(color):
        r, g, b, a = color
        return r >= threshold and g >= threshold and b >= threshold

    # 1. 将四周边缘的背景像素入队
    for x in range(w):
        for y in [0, h - 1]:
            if is_bg_color(pixels[x, y]) and not visited[x][y]:
                queue.append((x, y))
                visited[x][y] = True
    for y in range(h):
        for x in [0, w - 1]:
            if is_bg_color(pixels[x, y]) and not visited[x][y]:
                queue.append((x, y))
                visited[x][y] = True

    # 2. 广度优先搜索扩散，消除相连的背景
    removed_count = 0
    while queue:
        cx, cy = queue.popleft()
        pixels[cx, cy] = (0, 0, 0, 0)  # 设为透明
        removed_count += 1
        
        for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
            nx, ny = cx + dx, cy + dy
            if 0 <= nx < w and 0 <= ny < h and not visited[nx][ny]:
                if is_bg_color(pixels[nx, ny]):
                    visited[nx][ny] = True
                    queue.append((nx, ny))

    print(f"[信息] 背景过滤：共移除了 {removed_count} 个背景像素。")
    return img


def optimize_edges(img, threshold=245, lower_bound=170):
    """
    边缘去毛刺与防白边处理：
    对于与透明区域相邻的、亮度较高的过渡像素，通过动态调整其 Alpha 通道并结合内侧真实像素颜色进行膨胀填充。
    """
    img = img.convert('RGBA')
    w, h = img.size
    pixels = img.load()

    # 1. 识别边界（与完全透明的像素相邻的非透明像素）
    boundary = np.zeros((w, h), dtype=bool)
    for y in range(h):
        for x in range(w):
            if pixels[x, y][3] > 0:
                for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1)]:
                    nx, ny = x + dx, y + dy
                    if nx < 0 or nx >= w or ny < 0 or ny >= h or pixels[nx, ny][3] == 0:
                        boundary[x, y] = True
                        break

    # 2. 边缘羽化与防溢色修正
    for y in range(h):
        for x in range(w):
            # 对边界像素以及它外围紧邻的过渡像素做处理
            if pixels[x, y][3] > 0 and (boundary[x, y] or 
               (x > 0 and boundary[x-1, y]) or (x < w-1 and boundary[x+1, y]) or
               (y > 0 and boundary[x, y-1]) or (y < h-1 and boundary[x, y+1])):
                
                r, g, b, a = pixels[x, y]
                min_val = min(r, g, b)
                
                if min_val >= lower_bound:
                    # 动态羽化 Alpha：颜色越接近底色(白色)，越降低其不透明度
                    factor = (threshold - min_val) / (threshold - lower_bound)
                    factor = max(0.0, min(1.0, factor))
                    # 基于指数曲线强化边缘收敛度，避免淡虚的白边撑大 bbox
                    factor = factor ** 1.5 
                    new_a = int(a * factor)

                    # 在 5x5 邻域内搜寻非白色的内侧材质像素
                    found_colors = []
                    for dy in range(-2, 3):
                        for dx in range(-2, 3):
                            nx, ny = x + dx, y + dy
                            if 0 <= nx < w and 0 <= ny < h and pixels[nx, ny][3] > 0:
                                nr, ng, nb, na = pixels[nx, ny]
                                if min(nr, ng, nb) < lower_bound:
                                    found_colors.append((nr, ng, nb))
                    
                    if found_colors:
                        # 采用邻近内侧真实材质色的平均值
                        avg_r = int(sum(c[0] for c in found_colors) / len(found_colors))
                        avg_g = int(sum(c[1] for c in found_colors) / len(found_colors))
                        avg_b = int(sum(c[2] for c in found_colors) / len(found_colors))
                        pixels[x, y] = (avg_r, avg_g, avg_b, new_a)
                    else:
                        # 兜底：使白边色泽变暗，减弱其在高对比度背景下的发光白边
                        pixels[x, y] = (int(r * factor), int(g * factor), int(b * factor), new_a)

    print("[信息] 边缘去白优化：边缘防发光与半透明羽化处理完成。")
    return img


def find_connected_components(img, min_area=50):
    """
    对去背景后的图片进行连通域分析，识别出所有不透明像素块。
    """
    w, h = img.size
    pixels = img.load()
    visited = np.zeros((w, h), dtype=bool)
    components = []

    # 8-连通域 BFS
    for y in range(h):
        for x in range(w):
            r, g, b, a = pixels[x, y]
            # Alpha 大于 15 时视为实体连通，过滤掉细微浮尘
            if a > 15 and not visited[x, y]:
                queue = deque([(x, y)])
                visited[x, y] = True
                
                pts = []
                solid_pts = [] # 记录明显不透明的实体点，用作 bbox 收缩
                
                while queue:
                    cx, cy = queue.popleft()
                    pts.append((cx, cy))
                    
                    # 只有透明度大于 35 的较清晰实体像素才参与 Bounding Box 统计，防淡白边缘拉偏坐标
                    if pixels[cx, cy][3] > 35:
                        solid_pts.append((cx, cy))
                    
                    # 检查 8 个方向
                    for dx, dy in [(-1, 0), (1, 0), (0, -1), (0, 1), 
                                   (-1, -1), (-1, 1), (1, -1), (1, 1)]:
                        nx, ny = cx + dx, cy + dy
                        if 0 <= nx < w and 0 <= ny < h and not visited[nx][ny]:
                            if pixels[nx, ny][3] > 15:
                                visited[nx, ny] = True
                                queue.append((nx, ny))
                
                if len(pts) >= min_area:
                    # 如果检测到明显实体，使用实体像素范围建立 Bounding Box，否则兜底使用完整连通区域
                    target_pts = solid_pts if len(solid_pts) > 5 else pts
                    xs = [p[0] for p in target_pts]
                    ys = [p[1] for p in target_pts]
                    min_x, max_x = min(xs), max(xs)
                    min_y, max_y = min(ys), max(ys)
                    
                    components.append({
                        'bbox': (min_x, min_y, max_x, max_y),
                        'pts': pts
                    })
                    
    return components


def main():
    parser = argparse.ArgumentParser(description="AI 生成 UI 界面大图自动切图与定位分析工具")
    parser.add_argument("-i", "--input", required=True, help="输入图片路径 (例如: art/asset_all_fal.png)")
    parser.add_argument("-o", "--output-dir", default="art/spec", help="切图输出目录 (默认: art/spec)")
    parser.add_argument("-t", "--threshold", type=int, default=245, help="浅色背景过滤阈值，范围 0-255 (默认: 245)")
    parser.add_argument("-l", "--lower-bound", type=int, default=170, help="边缘去色羽化起点阈值 (默认: 170)")
    parser.add_argument("-a", "--min-area", type=int, default=50, help="最小过滤像素面积 (默认: 50)")
    parser.add_argument("--game-layout", action="store_true", help="是否应用 ScrewEveryday 专属 UI 分类命名规则")

    args = parser.parse_args()

    if not os.path.exists(args.input):
        print(f"错误: 输入图片不存在: {args.input}")
        sys.exit(1)

    os.makedirs(args.output_dir, exist_ok=True)

    print(f"[开始] 处理图片: {args.input}")
    original_img = Image.open(args.input)
    w, h = original_img.size
    print(f"[信息] 原始尺寸: {w} × {h}")

    # 1. 过滤背景
    transparent_img = flood_fill_remove_bg(original_img, threshold=args.threshold)

    # 2. 边缘防发光与半透明羽化去白边
    optimized_img = optimize_edges(transparent_img, threshold=args.threshold, lower_bound=args.lower_bound)

    # 3. 提取组件 (使用优化后收拢的 bbox)
    components = find_connected_components(optimized_img, min_area=args.min_area)
    print(f"[信息] 检测到 {len(components)} 个有效的独立 UI 组件。")

    # 4. 命名与分类
    layout_data = []

    if args.game_layout:
        left_btns = []
        right_btns = []
        
        for comp in components:
            bbox = comp['bbox']
            cw = bbox[2] - bbox[0] + 1
            ch = bbox[3] - bbox[1] + 1
            cx = bbox[0] + cw / 2.0
            cy = bbox[1] + ch / 2.0
            
            comp['cw'] = cw
            comp['ch'] = ch
            comp['cx'] = cx
            comp['cy'] = cy
            
            if cy < 150:
                if cx < 300:
                    comp['name'] = 'life_bar.png'
                else:
                    comp['name'] = 'coin_bar.png'
            elif cy > 1000:
                comp['name'] = 'play_btn.png'
            else:
                if cx < 200:
                    left_btns.append(comp)
                elif cx > 400:
                    right_btns.append(comp)
                    
        # 左侧悬浮按钮按 y 排序
        left_btns.sort(key=lambda c: c['cy'])
        left_names = ['daily_btn.png', 'rank_btn.png', 'pets_btn.png']
        for idx, comp in enumerate(left_btns):
            if idx < len(left_names):
                comp['name'] = left_names[idx]
                
        # 右侧悬浮按钮按 y 排序
        right_btns.sort(key=lambda c: c['cy'])
        right_names = ['shop_btn.png', 'settings_btn.png']
        for idx, comp in enumerate(right_btns):
            if idx < len(right_names):
                comp['name'] = right_names[idx]
    else:
        components.sort(key=lambda c: (c['bbox'][1], c['bbox'][0]))
        for idx, comp in enumerate(components):
            bbox = comp['bbox']
            comp['cw'] = bbox[2] - bbox[0] + 1
            comp['ch'] = bbox[3] - bbox[1] + 1
            comp['name'] = f"element_{idx:02d}.png"

    # 5. 裁剪输出与记录数据
    layout_data.append(f"# UI 切图坐标与空间数据描述 (输入: {os.path.basename(args.input)})")
    layout_data.append(f"* 画布基准分辨率: {w} × {h}")
    layout_data.append("| 组件名称 | 导出文件名 | 宽度 (px) | 高度 (px) | 绝对坐标 (x1, y1) -> (x2, y2) | 中心点 (x, y) |")
    layout_data.append("| :--- | :--- | :--- | :--- | :--- | :--- |")

    pixels = optimized_img.load()
    for comp in components:
        if 'name' not in comp:
            bbox = comp['bbox']
            comp['name'] = f"element_{bbox[0]}_{bbox[1]}.png"
            
        name = comp['name']
        bbox = comp['bbox']
        cw, ch = comp['cw'], comp['ch']
        cx = bbox[0] + cw / 2.0
        cy = bbox[1] + ch / 2.0
        
        # 裁剪包含完整 pts 的区域并保存 (但输出图片的范围限制在收拢的 bbox 内)
        # 为确保切出的子图内不溢出，我们创建一个和 bbox 一样大像素区
        sub_img = Image.new('RGBA', (cw, ch), (0, 0, 0, 0))
        sub_pixels = sub_img.load()
        
        for px, py in comp['pts']:
            # 只有像素点落在 bbox 范围内才会被裁剪进去
            if bbox[0] <= px <= bbox[2] and bbox[1] <= py <= bbox[3]:
                sub_pixels[px - bbox[0], py - bbox[1]] = pixels[px, py]
            
        dest_path = os.path.join(args.output_dir, name)
        sub_img.save(dest_path)
        print(f"[成功] 保存素材: {name} | 尺寸: {cw}x{ch} | 坐标: ({bbox[0]},{bbox[1]})")
        
        readable_title = name.replace(".png", "").replace("_", " ").title()
        layout_data.append(f"| {readable_title} | `{name}` | {cw} | {ch} | `({bbox[0]}, {bbox[1]})` -> `({bbox[2]}, {bbox[3]})` | `({cx:.1f}, {cy:.1f})` |")

    txt_dest = os.path.join(args.output_dir, "layout_report.txt")
    with open(txt_dest, "w", encoding="utf-8") as f:
        f.write("\n".join(layout_data))
    
    print(f"[成功] 处理完成！共生成 {len(components)} 个素材。")
    print(f"[成功] 空间布局规格已写入文件: {txt_dest}")

if __name__ == "__main__":
    main()
