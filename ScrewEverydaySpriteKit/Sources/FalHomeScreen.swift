import SwiftUI

/// 采用 asset_all_fal 交互控件切图的全新首页
struct FalHomeScreen: View {
    @ObservedObject var progressStore: ProgressStore
    let onPlay: () -> Void
    let onLevels: () -> Void
    let onCollection: () -> Void

    @State private var isSettingPresented = false
    @State private var isPlayButtonAnimating = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                // 1. 背景大图，延续 mockup_cute_clay 风格
                Image(uiImage: .bundled("mockup_cute_clay"))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()

                // 2. 交互控件叠加层 (设计基准: 750 x 1342)
                GeometryReader { innerGeo in
                    let scale = innerGeo.size.width / 750.0

                    ZStack(alignment: .topLeading) {
                        // 图层: stamina_bar (修理值/体力)
                        ZStack {
                            Image(uiImage: .bundled("stamina_bar_fal"))
                                .resizable()
                                .scaledToFit()
                            Text("\(progressStore.state.repairValue)")
                                .font(.system(size: 20 * scale, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .offset(x: 24 * scale, y: 0)
                        }
                        .frame(width: CGFloat(284) * scale, height: CGFloat(99) * scale)
                        .offset(x: CGFloat(0) * scale, y: CGFloat(0) * scale)
                        .zIndex(10)

                        // 图层: coin_bar (金币数)
                        ZStack {
                            Image(uiImage: .bundled("coin_bar_fal"))
                                .resizable()
                                .scaledToFit()
                            Text("\(progressStore.state.coins)")
                                .font(.system(size: 20 * scale, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .offset(x: 24 * scale, y: 0)
                        }
                        .frame(width: CGFloat(257) * scale, height: CGFloat(99) * scale)
                        .offset(x: CGFloat(493) * scale, y: CGFloat(0) * scale)
                        .zIndex(11)

                        // 图层: daily_btn (每日任务)
                        Button(action: {
                            print("点击了每日任务 daily_btn_fal")
                        }) {
                            Image(uiImage: .bundled("daily_btn_fal"))
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(width: CGFloat(130) * scale, height: CGFloat(191) * scale)
                        .offset(x: CGFloat(6) * scale, y: CGFloat(475) * scale)
                        .zIndex(12)

                        // 图层: rank_btn (排行榜)
                        Button(action: {
                            print("点击了排行榜 rank_btn_fal")
                        }) {
                            Image(uiImage: .bundled("rank_btn_fal"))
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(width: CGFloat(130) * scale, height: CGFloat(191) * scale)
                        .offset(x: CGFloat(6) * scale, y: CGFloat(648) * scale)
                        .zIndex(13)

                        // 图层: pets_btn (收藏/宠物图鉴)
                        Button(action: onCollection) {
                            Image(uiImage: .bundled("pets_btn_fal"))
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(width: CGFloat(130) * scale, height: CGFloat(185) * scale)
                        .offset(x: CGFloat(6) * scale, y: CGFloat(814) * scale)
                        .zIndex(14)

                        // 图层: shop_btn (关卡列表/商店)
                        Button(action: onLevels) {
                            Image(uiImage: .bundled("shop_btn_fal"))
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(width: CGFloat(133) * scale, height: CGFloat(210) * scale)
                        .offset(x: CGFloat(617) * scale, y: CGFloat(654) * scale)
                        .zIndex(15)

                        // 图层: settings_btn (设置)
                        Button(action: {
                            isSettingPresented = true
                        }) {
                            Image(uiImage: .bundled("settings_btn_fal"))
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(width: CGFloat(133) * scale, height: CGFloat(197) * scale)
                        .offset(x: CGFloat(617) * scale, y: CGFloat(839) * scale)
                        .zIndex(16)

                        // 图层: play_btn (开始修理主按钮)
                        Button(action: onPlay) {
                            Image(uiImage: .bundled("play_btn_fal"))
                                .resizable()
                                .scaledToFit()
                        }
                        .frame(width: CGFloat(407) * scale, height: CGFloat(222) * scale)
                        .offset(x: CGFloat(173) * scale, y: CGFloat(1086) * scale)
                        .scaleEffect(isPlayButtonAnimating ? 1.03 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.95).repeatForever(autoreverses: true),
                            value: isPlayButtonAnimating
                        )
                        .zIndex(17)
                    }
                }
            }
            .ignoresSafeArea()
            .onAppear {
                isPlayButtonAnimating = true
            }
        }
        .sheet(isPresented: $isSettingPresented) {
            SettingsView(isPresented: $isSettingPresented)
                .presentationDetents([.medium])
                .presentationCornerRadius(24)
        }
    }
}
