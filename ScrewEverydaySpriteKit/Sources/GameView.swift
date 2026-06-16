import SpriteKit
import SwiftUI

struct GameView: View {
    let level: LevelDescriptor
    @ObservedObject var progressStore: ProgressStore
    let onExit: () -> Void
    let onFinish: (GameRunSummary) -> Void

    @State private var scene: GameScene
    @State private var isPausePresented = false
    @State private var isExitConfirmPresented = false
    
    init(level: LevelDescriptor, progressStore: ProgressStore, onExit: @escaping () -> Void, onFinish: @escaping (GameRunSummary) -> Void) {
        self.level = level
        self.progressStore = progressStore
        self.onExit = onExit
        self.onFinish = onFinish
        _scene = State(initialValue: GameScene(level: level, onFinish: onFinish))
    }

    var body: some View {
        ZStack {
            // 游戏场景
            SpriteView(scene: scene)
                .ignoresSafeArea()
            
            // 外层 UI 控制
            VStack {
                // 顶部控制条
                HStack(spacing: 12) {
                    // 返回按钮
                    Button {
                        scene.isPaused = true
                        isExitConfirmPresented = true
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.34))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1))
                    }
                    Spacer()
                    
                    // 当前金币数（提示买道具）
                    HStack(spacing: 6) {
                        AssetIcon("icon_coin", size: 18)
                        Text("\(progressStore.state.coins)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .padding(.horizontal, 12)
                    .frame(height: 32)
                    .background(Color.black.opacity(0.35))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.white.opacity(0.15), lineWidth: 1))
                    
                    // 暂停按钮
                    Button {
                        scene.isPaused = true
                        isPausePresented = true
                    } label: {
                        Image(systemName: "pause.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.black.opacity(0.34))
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1))
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                
                Spacer()
                
                // 底部道具快捷购买区
                HStack(spacing: 24) {
                    // 撤销道具 (金币-20)
                    ItemButton(
                        title: "btn_undo".localized,
                        cost: 20,
                        iconName: "arrow.uturn.backward.circle.fill",
                        currentCoins: progressStore.state.coins
                    ) {
                        if progressStore.buyItem(cost: 20) {
                            let success = scene.useUndoItem()
                            if !success {
                                // 如果没成功（比如备选区为空），退回金币
                                progressStore.refundItem(cost: 20)
                            }
                        }
                    }
                    
                    // 移出备选道具 (金币-50)
                    ItemButton(
                        title: "btn_clear_buffer".localized,
                        cost: 50,
                        iconName: "trash.circle.fill",
                        currentCoins: progressStore.state.coins
                    ) {
                        if progressStore.buyItem(cost: 50) {
                            let success = scene.useClearBufferItem()
                            if !success {
                                // 如果没成功，退回金币
                                progressStore.refundItem(cost: 50)
                            }
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 28)
            }
            
            // 暂停弹窗
            if isPausePresented {
                GameOverlayFrame(title: "game_paused".localized) {
                    VStack(spacing: 14) {
                        Button("btn_resume".localized) {
                            scene.isPaused = false
                            isPausePresented = false
                        }
                        .buttonStyle(OverlayMenuButtonStyle(isPrimary: true))
                        
                        Button("btn_retry".localized) {
                            // 重新实例化 GameScene 以重玩
                            scene = GameScene(level: level, onFinish: onFinish)
                            scene.isPaused = false
                            isPausePresented = false
                        }
                        .buttonStyle(OverlayMenuButtonStyle(isPrimary: false))
                        
                        Button("btn_home".localized) {
                            onExit()
                        }
                        .buttonStyle(OverlayMenuButtonStyle(isPrimary: false))
                    }
                }
            }
            
            // 退出确认弹窗
            if isExitConfirmPresented {
                GameOverlayFrame(title: "exit_confirm_title".localized) {
                    VStack(spacing: 14) {
                        Text("exit_confirm_desc".localized)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundStyle(Color.white.opacity(0.65))
                            .padding(.bottom, 6)
                        
                        Button("btn_confirm_exit".localized) {
                            onExit()
                        }
                        .buttonStyle(OverlayMenuButtonStyle(isPrimary: true))
                        
                        Button("btn_confirm_cancel".localized) {
                            scene.isPaused = false
                            isExitConfirmPresented = false
                        }
                        .buttonStyle(OverlayMenuButtonStyle(isPrimary: false))
                    }
                }
            }
            
            // 调试过关悬浮按钮
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        scene.cheatWin()
                    } label: {
                        Text("测试过关")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .frame(height: 32)
                            .background(Color.red.opacity(0.85))
                            .clipShape(Capsule())
                            .overlay(Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1))
                            .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)
                    }
                    .padding(.trailing, 16)
                    .padding(.bottom, 120)
                }
            }
        }
        .statusBarHidden(true)
    }
}

// 道具快捷购买按钮组件
struct ItemButton: View {
    let title: String
    let cost: Int
    let iconName: String
    let currentCoins: Int
    let action: () -> Void
    
    private var isEnabled: Bool {
        currentCoins >= cost
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                HStack(spacing: 6) {
                    Image(systemName: iconName)
                        .font(.system(size: 18))
                    Text(title)
                        .font(.system(size: 14, weight: .bold))
                }
                
                HStack(spacing: 4) {
                    AssetIcon("icon_coin", size: 14)
                    Text("\(cost)")
                        .font(.system(size: 11, weight: .heavy))
                }
                .foregroundStyle(isEnabled ? Color(hex: 0xF7C948) : .white.opacity(0.35))
            }
            .foregroundStyle(isEnabled ? .white : .white.opacity(0.35))
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(hex: 0x2A2D44).opacity(isEnabled ? 0.92 : 0.45))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isEnabled ? Color(hex: 0xF4A261).opacity(0.65) : Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
        }
        .disabled(!isEnabled)
    }
}

// 通用浮层容器
struct GameOverlayFrame<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.72)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text(title)
                    .font(.system(size: 26, weight: .black))
                    .foregroundStyle(.white)
                
                content
            }
            .padding(24)
            .frame(width: 300)
            .background(Color(hex: 0x1A1D2D))
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color(hex: 0x8F95B8).opacity(0.35), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.45), radius: 16, x: 0, y: 8)
        }
    }
}

// 浮层按钮风格
struct OverlayMenuButtonStyle: ButtonStyle {
    let isPrimary: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(isPrimary ? Color(hex: 0x222639) : .white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(
                isPrimary ? 
                Color(hex: 0xF4A261).opacity(configuration.isPressed ? 0.8 : 1.0) :
                Color(hex: 0x2A2D44).opacity(configuration.isPressed ? 0.8 : 1.0)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(isPrimary ? Color.white.opacity(0.15) : Color(hex: 0x8F95B8).opacity(0.25), lineWidth: 1)
            )
    }
}
