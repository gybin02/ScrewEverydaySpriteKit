#!/usr/bin/env python3
"""Locate assets on a target design image using local Multi-scale Normalized Cross-Correlation (NCC).

This version runs NCC over all three color channels (RGB) to preserve color edge information (preventing
shadow/grass mix-up), supports fixing the scale (to keep symmetry), and applies a built-in Y-offset
compensation to prevent vertical alignment from shifting upwards due to bottom shadows/3D bases.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
import numpy as np

# 移除原先硬编码的 Y 轴微调补偿，因为遮罩匹配已经足够精准
Y_OFFSET_COMPENSATION = {}

def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Locate assets using Multi-channel Masked NCC.")
    parser.add_argument("source", help="Target design image (e.g. balanced mock)")
    parser.add_argument("manifest", help="Path to layers.manifest.json")
    parser.add_argument(
        "--scale-min", type=float, default=1.00, help="Minimum scale factor to search (default: 1.00)"
    )
    parser.add_argument(
        "--scale-max", type=float, default=1.00, help="Maximum scale factor to search (default: 1.00)"
    )
    parser.add_argument(
        "--scale-step", type=float, default=0.02, help="Scale search step (default: 0.02)"
    )
    parser.add_argument(
        "--pad-x", type=int, default=30, help="Horizontal search neighborhood padding (default: 30)"
    )
    parser.add_argument(
        "--pad-y", type=int, default=120, help="Vertical search neighborhood padding (default: 120)"
    )
    return parser.parse_args()

def norm_cross_correlation_rgba_masked(candidate: np.ndarray, template_rgb: np.ndarray, mask: np.ndarray) -> float:
    # 三通道 RGB 分别计算 NCC 并求均值，只统计 mask 为 True（非透明）的像素，排除背景干扰
    scores = []
    n_pixels = np.sum(mask)
    if n_pixels < 4:
        return 0.0
        
    for c in range(3):
        cand_c = candidate[:, :, c][mask]
        temp_c = template_rgb[:, :, c][mask]
        
        mean_c = np.mean(cand_c)
        mean_t = np.mean(temp_c)
        
        c_zero = cand_c - mean_c
        t_zero = temp_c - mean_t
        
        num = np.sum(c_zero * t_zero)
        den = np.sqrt(np.sum(c_zero ** 2) * np.sum(t_zero ** 2))
        
        if den > 0:
            scores.append(num / den)
        else:
            scores.append(0.0)
            
    return float(np.mean(scores))

def search_single_asset(
    source_rgb: np.ndarray,
    template_path: Path,
    orig_bbox: dict,
    scale_min: float,
    scale_max: float,
    scale_step: float,
    pad_x: int,
    pad_y: int,
) -> tuple[int, int, int, int, float, float]:
    try:
        from PIL import Image
    except ImportError:
        print("Missing dependency: install Pillow.", file=sys.stderr)
        sys.exit(2)

    if not template_path.exists():
        raise FileNotFoundError(f"Template asset not found: {template_path}")
    
    # 读入为 RGBA，提取 Alpha 通道作为 Mask
    temp_img = Image.open(template_path).convert("RGBA")
    
    lh, lw, _ = source_rgb.shape
    
    best_score = -1.0
    best_x, best_y = 0, 0
    best_w, best_h = temp_img.size
    best_scale = 1.0
    
    x_orig = orig_bbox["x"]
    y_orig = orig_bbox["y"]
    w_orig = orig_bbox["width"]
    h_orig = orig_bbox["height"]
    
    x_start = max(0, x_orig - pad_x)
    x_end = min(lw, x_orig + w_orig + pad_x)
    y_start = max(0, y_orig - pad_y)
    y_end = min(lh, y_orig + h_orig + pad_y)
    
    scales = np.arange(scale_min, scale_max + 1e-5, scale_step)
    for scale in scales:
        tw = int(round(w_orig * scale))
        th = int(round(h_orig * scale))
        
        if tw <= 0 or th <= 0 or tw > (x_end - x_start) or th > (y_end - y_start):
            continue
            
        resized_temp = temp_img.resize((tw, th), Image.Resampling.BILINEAR)
        temp_arr = np.array(resized_temp, dtype=np.float32)
        
        # 拆分 RGB 和 Alpha 蒙版
        temp_rgb = temp_arr[:, :, :3]
        temp_alpha = temp_arr[:, :, 3]
        mask = temp_alpha > 50  # 过滤掉几乎完全透明的像素
        
        for y in range(y_start, y_end - th + 1):
            for x in range(x_start, x_end - tw + 1):
                candidate_arr = source_rgb[y:y+th, x:x+tw]
                score = norm_cross_correlation_rgba_masked(candidate_arr, temp_rgb, mask)
                
                if score > best_score:
                    best_score = score
                    best_x = x
                    best_y = y
                    best_w = tw
                    best_h = th
                    best_scale = scale
                    
    return best_x, best_y, best_w, best_h, best_scale, best_score

def main() -> int:
    args = parse_args()
    
    try:
        from PIL import Image
    except ImportError:
        print("Missing dependency: install Pillow.", file=sys.stderr)
        return 2
        
    source_path = Path(args.source)
    manifest_path = Path(args.manifest)
    
    if not source_path.exists():
        print(f"Source image not found: {source_path}", file=sys.stderr)
        return 1
    if not manifest_path.exists():
        print(f"Manifest not found: {manifest_path}", file=sys.stderr)
        return 1
        
    # 读取大图并转为 RGB
    source_img = Image.open(source_path).convert("RGB")
    source_rgb = np.array(source_img, dtype=np.float32)
    
    data = json.loads(manifest_path.read_text(encoding="utf-8"))
    if not isinstance(data, list):
        print("Manifest must be a JSON list.", file=sys.stderr)
        return 1
        
    print(f"🔍 开始在 {source_path.name} 上定位图层资产 (三通道 RGB-NCC 算法)...")
    
    updated = 0
    for entry in data:
        if entry.get("type") != "bitmap":
            continue
            
        layer_id = entry.get("id")
        asset_rel_path = entry.get("asset")
        orig_bbox = entry.get("source_bbox")
        
        if not asset_rel_path or not orig_bbox:
            continue
            
        template_path = Path(asset_rel_path)
        
        try:
            x, y, w, h, scale, score = search_single_asset(
                source_rgb,
                template_path,
                orig_bbox,
                args.scale_min,
                args.scale_max,
                args.scale_step,
                args.pad_x,
                args.pad_y,
            )
            
            # 应用内置的垂直偏移量补偿，拉回垂直方向偏上的误差
            comp_y = Y_OFFSET_COMPENSATION.get(layer_id, 0)
            y_final = y + comp_y
            
            # 边界限制
            y_final = max(0, min(source_rgb.shape[0] - h, y_final))
            
            # 回写更新
            entry["source_bbox"] = {
                "x": x,
                "y": y_final,
                "width": w,
                "height": h
            }
            entry["transparent_required"] = True
            
            print(f"✅ 定位成功 [{layer_id}]: x={x}, y={y_final} (原始y={y}, 补偿=+{comp_y}), w={w}, h={h} (匹配度={score:.3f})")
            updated += 1
        except Exception as e:
            print(f"❌ 定位失败 [{layer_id}]: {e}", file=sys.stderr)
            
    if updated > 0:
        manifest_path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
        print(f"🎉 成功更新 {updated} 个图层的定位数据至 {manifest_path.name}。")
        return 0
    else:
        print("未定位到任何有效图层。", file=sys.stderr)
        return 1

if __name__ == "__main__":
    raise SystemExit(main())
