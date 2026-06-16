import SwiftUI

/// 设置界面，提供音乐、音效开关，以及隐私政策、服务条款等链接
struct SettingsView: View {
    @Binding var isPresented: Bool
    @StateObject private var audio = AudioManager.shared
    
    var body: some View {
        ZStack {
            Color(hex: 0x1A1D2D).ignoresSafeArea()
            
            VStack(spacing: 20) {
                HStack {
                    Text("setting_title".localized)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(Color.white.opacity(0.5))
                    }
                }
                .padding(.bottom, 10)
                
                VStack(spacing: 16) {
                    Toggle(isOn: $audio.isMusicEnabled) {
                        HStack(spacing: 12) {
                            Image(systemName: "music.note")
                                .foregroundStyle(Color(hex: 0xF4A261))
                            Text("setting_bgm".localized)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .tint(Color(hex: 0x2A9D8F))
                    
                    Toggle(isOn: $audio.isSoundEnabled) {
                        HStack(spacing: 12) {
                            Image(systemName: "speaker.wave.3.fill")
                                .foregroundStyle(Color(hex: 0xF4A261))
                            Text("setting_sfx".localized)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .tint(Color(hex: 0x2A9D8F))
                }
                .padding(16)
                .background(Color(hex: 0x2A2D44))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(hex: 0x8F95B8).opacity(0.2), lineWidth: 1)
                )
                
                VStack(spacing: 14) {
                    Link(destination: URL(string: "https://www.google.com")!) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                            Text("setting_privacy".localized)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 12))
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.8))
                    }
                    
                    Divider().background(Color.white.opacity(0.1))
                    
                    Link(destination: URL(string: "https://www.google.com")!) {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                            Text("setting_terms".localized)
                            Spacer()
                            Image(systemName: "chevron.right").font(.system(size: 12))
                        }
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.8))
                    }
                }
                .padding(16)
                .background(Color(hex: 0x2A2D44))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(hex: 0x8F95B8).opacity(0.2), lineWidth: 1)
                )
                
                Text("\("game_title".localized) MVP v1.0.0")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.35))
                    .padding(.top, 10)
            }
            .padding(24)
        }
    }
}
