import SwiftUI

/// 采用 asset_all_fal 交互控件切图的全新首页，采用 750 x 1342 逻辑画布整包等比缩放方案，完美实现像素级对齐
struct FalHomeScreen: View {
    @ObservedObject var progressStore: ProgressStore
    let onPlay: () -> Void
    let onLevels: () -> Void
    let onCollection: () -> Void

    @State private var isSettingPresented = false
    @State private var isPlayButtonAnimating = false

    // 设计稿原始尺寸，对应 1.79 的背景图纵横比 (和物理尺寸 608x1088 完全一致)
    private let designWidth: CGFloat = 750
    private let designHeight: CGFloat = 1342

    var body: some View {
        GeometryReader { geo in
            // 计算等比填充缩放比，确保铺满整个屏幕
            let scaleX = geo.size.width / designWidth
            let scaleY = geo.size.height / designHeight
            let scale = max(scaleX, scaleY)

            ZStack {
                // 750 × 1342 绝对设计坐标系画布
                ZStack(alignment: .topLeading) {
                    // 1. 背景大图，刚好填满画布大小
                    Image(uiImage: .bundled("mockup_cute_clay"))
                        .resizable()
                        .frame(width: designWidth, height: designHeight)

                    // 2. 交互控件叠加层，完全采用底图原始设计稿像素坐标，免去繁琐的 scale 偏移

                    // 图层: stamina_bar (体力条)
                    // 尺寸: 284 × 99，位置 (0, 0)
                    ZStack {
                        Image(uiImage: .bundled("stamina_bar_fal"))
                            .resizable()
                            .scaledToFit()
                        Text("\(progressStore.state.repairValue)")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .offset(x: 24, y: 0)
                    }
                    .frame(width: 284, height: 99)
                    .offset(x: 0, y: 0)
                    .zIndex(10)

                    // 图层: coin_bar (金币条)
                    // 尺寸: 257 × 99，位置 (493, 0)
                    ZStack {
                        Image(uiImage: .bundled("coin_bar_fal"))
                            .resizable()
                            .scaledToFit()
                        Text("\(progressStore.state.coins)")
                            .font(.system(size: 20, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .offset(x: 24, y: 0)
                    }
                    .frame(width: 257, height: 99)
                    .offset(x: 493, y: 0)
                    .zIndex(11)

                    // 图层: daily_btn (每日签到)
                    // 尺寸: 130 × 191，位置 (6, 475)
                    Button(action: {
                        print("点击了每日任务 daily_btn_fal")
                    }) {
                        Image(uiImage: .bundled("daily_btn_fal"))
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 130, height: 191)
                    .offset(x: 6, y: 475)
                    .zIndex(12)

                    // 图层: rank_btn (排行榜)
                    // 尺寸: 130 × 191，位置 (6, 648)
                    Button(action: {
                        print("点击了排行榜 rank_btn_fal")
                    }) {
                        Image(uiImage: .bundled("rank_btn_fal"))
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 130, height: 191)
                    .offset(x: 6, y: 648)
                    .zIndex(13)

                    // 图层: pets_btn (宠物/图鉴)
                    // 尺寸: 130 × 185，位置 (6, 814)
                    Button(action: onCollection) {
                        Image(uiImage: .bundled("pets_btn_fal"))
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 130, height: 185)
                    .offset(x: 6, y: 814)
                    .zIndex(14)

                    // 图层: shop_btn (商店按钮/关卡选择)
                    // 尺寸: 133 × 210，位置 (617, 654)
                    Button(action: onLevels) {
                        Image(uiImage: .bundled("shop_btn_fal"))
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 133, height: 210)
                    .offset(x: 617, y: 654)
                    .zIndex(15)

                    // 图层: settings_btn (设置按钮)
                    // 尺寸: 133 × 197，位置 (617, 839)
                    Button(action: {
                        isSettingPresented = true
                    }) {
                        Image(uiImage: .bundled("settings_btn_fal"))
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 133, height: 197)
                    .offset(x: 617, y: 839)
                    .zIndex(16)

                    // 图层: play_btn (开始游戏按钮)
                    // 尺寸: 407 × 222，位置 (173, 1086)
                    Button(action: onPlay) {
                        Image(uiImage: .bundled("play_btn_fal"))
                            .resizable()
                            .scaledToFit()
                    }
                    .frame(width: 407, height: 222)
                    .offset(x: 173, y: 1086)
                    .scaleEffect(isPlayButtonAnimating ? 1.03 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.95).repeatForever(autoreverses: true),
                        value: isPlayButtonAnimating
                    )
                    .zIndex(17)
                }
                .frame(width: designWidth, height: designHeight)
                .scaleEffect(scale) // 统一等比缩放，锁定物理相对位置
            }
            .frame(width: geo.size.width, height: geo.size.height)
            .clipped() // 剪切溢出边界的部分
        }
        .ignoresSafeArea()
        .onAppear {
            isPlayButtonAnimating = true
        }
        .sheet(isPresented: $isSettingPresented) {
            SettingsView(isPresented: $isSettingPresented)
                .presentationDetents([.medium])
                .presentationCornerRadius(24)
        }
    }
}
