import SwiftUI

struct HomeScreen: View {
    @ObservedObject var progressStore: ProgressStore
    let onPlay: () -> Void
    let onLevels: () -> Void
    let onCollection: () -> Void

    @State private var isSettingPresented = false
    @State private var isPlayButtonAnimating = false

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                // 背景大图
                Image(uiImage: .bundled("mockup_cute_clay"))
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geo.size.width, height: geo.size.height)
                    .clipped()
                    .overlay(
                        GeometryReader { imageGeo in
                            let scale = imageGeo.size.width / 750.0
                            ZStack(alignment: .topLeading) {
                                // 图层: start_button
                                Button(action: onPlay) {
                                    Image(uiImage: .bundled("btn_start"))
                                        .resizable()
                                        .scaledToFit()
                                }
                                .frame(width: CGFloat(382) * scale, height: CGFloat(191) * scale)
                                .offset(x: CGFloat(184) * scale, y: CGFloat(1005) * scale)
                                .scaleEffect(isPlayButtonAnimating ? 1.03 : 1.0)
                                .animation(
                                    .easeInOut(duration: 0.95).repeatForever(autoreverses: true),
                                    value: isPlayButtonAnimating
                                )
                                .zIndex(10)

                                // 图层: daily_button
                                Button(action: {
                                    print("点击了 daily_button")
                                }) {
                                    Image(uiImage: .bundled("btn_daily"))
                                        .resizable()
                                        .scaledToFit()
                                }
                                .frame(width: CGFloat(111) * scale, height: CGFloat(130) * scale)
                                .offset(x: CGFloat(20) * scale, y: CGFloat(592) * scale)
                                .zIndex(10)

                                // 图层: rank_button
                                Button(action: {
                                    print("点击了 rank_button")
                                }) {
                                    Image(uiImage: .bundled("btn_rank"))
                                        .resizable()
                                        .scaledToFit()
                                }
                                .frame(width: CGFloat(111) * scale, height: CGFloat(130) * scale)
                                .offset(x: CGFloat(20) * scale, y: CGFloat(725) * scale)
                                .zIndex(10)

                                // 图层: achievements_button (Pets)
                                Button(action: onCollection) {
                                    Image(uiImage: .bundled("btn_achievements"))
                                        .resizable()
                                        .scaledToFit()
                                }
                                .frame(width: CGFloat(111) * scale, height: CGFloat(130) * scale)
                                .offset(x: CGFloat(20) * scale, y: CGFloat(859) * scale)
                                .zIndex(10)

                                // 图层: shop_button
                                Button(action: onLevels) {
                                    Image(uiImage: .bundled("btn_shop"))
                                        .resizable()
                                        .scaledToFit()
                                }
                                .frame(width: CGFloat(111) * scale, height: CGFloat(148) * scale)
                                .offset(x: CGFloat(619) * scale, y: CGFloat(752) * scale)
                                .zIndex(10)

                                // 图层: settings_button
                                Button(action: { isSettingPresented = true }) {
                                    Image(uiImage: .bundled("btn_settings"))
                                        .resizable()
                                        .scaledToFit()
                                }
                                .frame(width: CGFloat(111) * scale, height: CGFloat(148) * scale)
                                .offset(x: CGFloat(619) * scale, y: CGFloat(896) * scale)
                                .zIndex(10)
                            }
                        }
                    )

                // 顶栏资源层 (叠加提供动态数值)
                HStack(spacing: 12) {
                    ResourcePill(assetName: "icon_repair", text: "\(progressStore.state.repairValue)")
                    Spacer()
                    ResourcePill(assetName: "icon_coin", text: "\(progressStore.state.coins)")
                }
                .padding(.horizontal, 24)
                .padding(.top, geo.safeAreaInsets.top > 0 ? geo.safeAreaInsets.top + 8 : 16)
                .frame(width: geo.size.width)
                .zIndex(20)
            }
            .ignoresSafeArea()
            .onAppear { isPlayButtonAnimating = true }
        }
        .sheet(isPresented: $isSettingPresented) {
            SettingsView(isPresented: $isSettingPresented)
                .presentationDetents([.medium])
                .presentationCornerRadius(24)
        }
    }
}
