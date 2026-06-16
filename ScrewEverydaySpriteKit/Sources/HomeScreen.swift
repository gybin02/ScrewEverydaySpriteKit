import SwiftUI

/// 使用 SwiftUI 标准流式弹性布局的全新首页，消除复杂的绝对像素计算，实现完美的自适应排版
struct HomeScreen: View {
    @ObservedObject var progressStore: ProgressStore
    let onPlay: () -> Void
    let onLevels: () -> Void
    let onCollection: () -> Void

    @State private var isSettingPresented = false
    @State private var isPlayButtonAnimating = false

    var body: some View {
        ZStack {
            // 1. 背景底图直接忽略安全区域，等比裁剪铺满全屏
            Image(uiImage: .bundled("bg_cute_clay"))
                .resizable()
                .aspectRatio(contentMode: .fill)
                .ignoresSafeArea()

            // 2. 交互控件层，在安全区 (Safe Area) 内进行标准弹性排版
            VStack(spacing: 0) {
                
                // 2.1 顶部状态栏
                HStack(alignment: .center) {
                    // 体力条 (设计尺寸 178 × 63，此处缩放为标准点尺寸宽 130，高 46)
                    ZStack {
                        Image(uiImage: .bundled("life_bar"))
                            .resizable()
                            .scaledToFit()
                        
                        // 实时的体力数字
                        Text("\(progressStore.state.repairValue)")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                            .offset(x: -42, y: -0.5)
                        
                        // 实时的状态文本 (例如 Full 或 倒计时)
                        Text(progressStore.state.repairValue >= 5 ? "Full" : "15:00")
                            .font(.system(size: 11, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: 0x572408))
                            .offset(x: 6, y: -0.5)
                    }
                    .frame(width: 130, height: 46)

                    Spacer()

                    // 金币条 (设计尺寸 166 × 60，此处缩放为宽 122，高 44)
                    ZStack {
                        Image(uiImage: .bundled("coin_bar"))
                            .resizable()
                            .scaledToFit()
                        
                        // 实时金币数
                        Text("\(progressStore.state.coins)")
                            .font(.system(size: 14, weight: .black, design: .rounded))
                            .foregroundColor(Color(hex: 0x572408))
                            .offset(x: 4, y: -0.5)
                    }
                    .frame(width: 122, height: 44)
                }
                .padding(.horizontal, 16)
                .padding(.top, 8)

                Spacer() // 弹性占位，自动推开顶部状态栏和下方按钮区

                // 2.2 下部操作与悬浮按钮区
                VStack(spacing: 16) {
                    
                    // 悬浮按钮组并排排列
                    HStack(alignment: .bottom) {
                        
                        // 左侧按钮列 (Daily, Rank, Pets)
                        VStack(spacing: 12) {
                            Button(action: {
                                print("点击了每日任务")
                            }) {
                                Image(uiImage: .bundled("daily_btn"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 58, height: 74)
                            }
                            
                            Button(action: {
                                print("点击了排行榜")
                            }) {
                                Image(uiImage: .bundled("rank_btn"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 58, height: 72)
                            }
                            
                            Button(action: onCollection) {
                                Image(uiImage: .bundled("pets_btn"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 58, height: 71)
                            }
                        }
                        .padding(.leading, 16)

                        Spacer()

                        // 右侧按钮列 (Shop, Settings)
                        VStack(spacing: 12) {
                            Button(action: onLevels) {
                                Image(uiImage: .bundled("shop_btn"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 58, height: 74)
                            }
                            
                            Button(action: {
                                isSettingPresented = true
                            }) {
                                Image(uiImage: .bundled("settings_btn"))
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 58, height: 76)
                            }
                        }
                        .padding(.trailing, 16)
                    }

                    // 2.3 开始游戏主按钮 (PLAY)
                    Button(action: onPlay) {
                        Image(uiImage: .bundled("play_btn"))
                            .resizable()
                            .scaledToFit()
                            .frame(width: 220, height: 102)
                    }
                    .scaleEffect(isPlayButtonAnimating ? 1.04 : 1.0)
                    .animation(
                        .easeInOut(duration: 0.95).repeatForever(autoreverses: true),
                        value: isPlayButtonAnimating
                    )
                    .padding(.bottom, 12)
                }
            }
        }
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

