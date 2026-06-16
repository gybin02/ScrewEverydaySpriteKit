import SwiftUI

/// 采用标准 UI 元素切图的全新首页，基于 9:19 干净背景图与双重安全自适应像素对齐算法
struct HomeScreen: View {
    @ObservedObject var progressStore: ProgressStore
    let onPlay: () -> Void
    let onLevels: () -> Void
    let onCollection: () -> Void

    @State private var isSettingPresented = false
    @State private var isPlayButtonAnimating = false

    // 辅助计算屏幕适配的缩放与偏置参数
    private func getLayoutMetrics(w: CGFloat, h: CGFloat) -> (scale: CGFloat, xOffset: CGFloat, yOffset: CGFloat) {
        let srcW: CGFloat = 608.0
        let srcH: CGFloat = 1280.0
        let srcRatio = srcW / srcH
        let screenRatio = w / h

        if screenRatio > srcRatio {
            // 屏幕比较宽（如 iPad），按宽度拉伸，上下裁剪
            let scale = w / srcW
            return (scale, 0, (h - srcH * scale) / 2.0)
        } else {
            // 屏幕比较长（如 iPhone 17），按高度拉伸，左右裁剪
            let scale = h / srcH
            return (scale, (w - srcW * scale) / 2.0, 0)
        }
    }

    var body: some View {
        GeometryReader { geo in
            let W = geo.size.width
            let H = geo.size.height
            let safeArea = geo.safeAreaInsets

            // 调用辅助函数获取计算结果
            let metrics = getLayoutMetrics(w: W, h: H)
            let scale = metrics.scale
            let xOffset = metrics.xOffset
            let yOffset = metrics.yOffset

            // 计算防刘海与边缘裁剪的安全坐标
            let topBarY = max(safeArea.top + 6, yOffset + 25 * scale)
            let leftBtnX = max(16, xOffset + 16 * scale)
            let rightBtnWidth: CGFloat = 88.0 * scale
            let rightBtnX = min(W - rightBtnWidth - 16, xOffset + 505 * scale)

            ZStack(alignment: .topLeading) {
                // 背景图采用 Aspect Fill 填充整个屏幕
                Image(uiImage: .bundled("bg_cute_clay"))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: W, height: H)
                    .clipped()

                // 体力条 (设计尺寸 178 × 63，位置 18, 25)
                ZStack {
                    Image(uiImage: .bundled("life_bar"))
                        .resizable()
                        .scaledToFit()
                    
                    // 实时的体力数字
                    Text("\(progressStore.state.repairValue)")
                        .font(.system(size: 14 * scale, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .offset(x: -57 * scale, y: -1 * scale)
                    
                    // 实时的状态文本 (例如 Full 或 倒计时)
                    Text(progressStore.state.repairValue >= 5 ? "Full" : "15:00")
                        .font(.system(size: 12 * scale, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: 0x572408))
                        .offset(x: 9 * scale, y: -1 * scale)
                }
                .frame(width: 178 * scale, height: 63 * scale)
                .position(x: (leftBtnX + 178 * scale / 2.0), y: topBarY + 63 * scale / 2.0)

                // 金币条 (设计尺寸 166 × 60，位置 428, 28)
                // 底部与体力条对齐
                ZStack {
                    Image(uiImage: .bundled("coin_bar"))
                        .resizable()
                        .scaledToFit()
                    
                    // 实时金币数
                    Text("\(progressStore.state.coins)")
                        .font(.system(size: 14 * scale, weight: .black, design: .rounded))
                        .foregroundColor(Color(hex: 0x572408))
                        .offset(x: 5 * scale, y: -1 * scale)
                }
                .frame(width: 166 * scale, height: 60 * scale)
                .position(
                    x: min(W - 166 * scale / 2.0 - 16, xOffset + (428 + 83) * scale),
                    y: topBarY + 63 * scale - 60 * scale / 2.0
                )

                // 每日签到 (设计尺寸 89 × 114，位置 16, 647)
                Button(action: {
                    print("点击了每日任务 daily_btn")
                }) {
                    Image(uiImage: .bundled("daily_btn"))
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 89 * scale, height: 114 * scale)
                .position(x: leftBtnX + 89 * scale / 2.0, y: yOffset + (647 + 114 / 2.0) * scale)

                // 排行榜 (设计尺寸 89 × 110，位置 16, 773)
                Button(action: {
                    print("点击了排行榜 rank_btn")
                }) {
                    Image(uiImage: .bundled("rank_btn"))
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 89 * scale, height: 110 * scale)
                .position(x: leftBtnX + 89 * scale / 2.0, y: yOffset + (773 + 110 / 2.0) * scale)

                // 宠物/图鉴按钮 (设计尺寸 89 × 109，位置 16, 898)
                Button(action: onCollection) {
                    Image(uiImage: .bundled("pets_btn"))
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 89 * scale, height: 109 * scale)
                .position(x: leftBtnX + 89 * scale / 2.0, y: yOffset + (898 + 109 / 2.0) * scale)

                // 商店按钮 (设计尺寸 88 × 114，位置 505, 806)
                Button(action: onLevels) {
                    Image(uiImage: .bundled("shop_btn"))
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 88 * scale, height: 114 * scale)
                .position(x: rightBtnX + rightBtnWidth / 2.0, y: yOffset + (806 + 114 / 2.0) * scale)

                // 设置按钮 (设计尺寸 88 × 116，位置 505, 931)
                Button(action: {
                    isSettingPresented = true
                }) {
                    Image(uiImage: .bundled("settings_btn"))
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 88 * scale, height: 116 * scale)
                .position(x: rightBtnX + rightBtnWidth / 2.0, y: yOffset + (931 + 116 / 2.0) * scale)

                // 开始游戏 (设计尺寸 325 × 150，位置 142, 1048)
                // 确保在安全区内，不被 Home Indicator 阻挡
                Button(action: onPlay) {
                    Image(uiImage: .bundled("play_btn"))
                        .resizable()
                        .scaledToFit()
                }
                .frame(width: 325 * scale, height: 150 * scale)
                .scaleEffect(isPlayButtonAnimating ? 1.04 : 1.0)
                .animation(
                    .easeInOut(duration: 0.95).repeatForever(autoreverses: true),
                    value: isPlayButtonAnimating
                )
                .position(
                    x: W / 2.0,
                    y: min(H - safeArea.bottom - 150 * scale / 2.0 - 10, yOffset + (1048 + 150 / 2.0) * scale)
                )
            }
            .onAppear {
                isPlayButtonAnimating = true
            }
        }
        .ignoresSafeArea()
        .sheet(isPresented: $isSettingPresented) {
            SettingsView(isPresented: $isSettingPresented)
                .presentationDetents([.medium])
                .presentationCornerRadius(24)
        }
    }
}
