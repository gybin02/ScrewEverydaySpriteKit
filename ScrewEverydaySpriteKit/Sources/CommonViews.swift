import SwiftUI

struct ScreenBackground<Content: View>: View {
    var bgImageName: String = "app_background"
    var blurRadius: CGFloat = 10
    var overlayOpacity: Double = 0.78
    @ViewBuilder let content: Content

    var body: some View {
        GeometryReader { proxy in
            ZStack {
                Image(uiImage: .bundled(bgImageName))
                    .resizable()
                    .scaledToFill()
                    .frame(width: proxy.size.width, height: proxy.size.height)
                    .blur(radius: blurRadius)
                    .clipped()
                    .ignoresSafeArea()

                Color(hex: 0x171B2A, alpha: overlayOpacity)
                    .ignoresSafeArea()

                content
                    .frame(width: proxy.size.width, height: proxy.size.height)
            }
        }
    }
}

struct ResourceBar: View {
    @ObservedObject var progressStore: ProgressStore

    var body: some View {
        HStack {
            ResourcePill(assetName: "icon_repair", text: "\(progressStore.state.repairValue)")
            Spacer()
            ResourcePill(assetName: "icon_coin", text: "\(progressStore.state.coins)")
        }
    }
}

struct ResourcePill: View {
    let assetName: String
    let text: String

    var body: some View {
        HStack(spacing: 8) {
            AssetIcon(assetName, size: 24)
            Text(text)
                .fontWeight(.bold)
        }
        .font(.system(size: 15))
        .foregroundStyle(.white)
        .padding(.horizontal, 14)
        .frame(height: 38)
        .background(Color(hex: 0x2A2D44))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(hex: 0x8F95B8).opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.24), radius: 8, x: 0, y: 4)
    }
}

struct StoryHeroView: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(hex: 0x24283B))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(Color(hex: 0x8F95B8).opacity(0.35), lineWidth: 1)
                )

            Image("home_machine_tower")
                .resizable()
                .scaledToFit()
                .padding(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    LinearGradient(
                        colors: [.clear, Color.black.opacity(0.18)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                )

            VStack(alignment: .leading, spacing: 4) {
                Text("story_hero_title".localized)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(Color.white.opacity(0.9))
                Text("story_hero_desc".localized)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.76))
                    .lineLimit(2)
            }
            .padding(12)
            .background(Color.black.opacity(0.22))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
        }
    }
}

struct SecondaryNavButton: View {
    let title: String
    let assetName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                AssetIcon(assetName, size: 28)
                Text(title)
            }
            .font(.system(size: 17, weight: .bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(Color(hex: 0x2A2D44))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(Color(hex: 0x8F95B8).opacity(0.35), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.24), radius: 8, x: 0, y: 4)
        }
    }
}

/// 首页的日常目标进度卡片，展示当前完成的日常目标数量和总目标数量，以及一个小图标和描述文本
struct DailyGoalCard: View {
    let completed: Int
    let goal: Int
    let text: String

    private var progress: CGFloat {
        guard goal > 0 else { return 0 }
        return CGFloat(min(goal, completed)) / CGFloat(goal)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                AssetIcon("icon_gift", size: 28)
                Text("daily_goal_progress".localizedFormat(min(completed, goal), goal))
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundStyle(.white)

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: 0x14162A))
                    Capsule()
                        .fill(Color(hex: 0x2A9D8F))
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 12)

            Text(text)
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.72))
        }
        .padding(16)
        .background(Color(hex: 0x2A2D44))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(hex: 0x8F95B8).opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.24), radius: 10, x: 0, y: 5)
    }
}

struct TopBar: View {
    let title: String
    let subtitle: String
    let onBack: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button(action: onBack) {
                AssetIcon("icon_back", size: 34)
                    .frame(width: 42, height: 42)
                    .background(Color(hex: 0x2A2D44))
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color(hex: 0x8F95B8).opacity(0.35), lineWidth: 1))
                    .shadow(color: .black.opacity(0.24), radius: 8, x: 0, y: 4)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 28, weight: .heavy))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.64))
            }
            Spacer()
        }
    }
}

struct AssetIcon: View {
    let name: String
    let size: CGFloat

    init(_ name: String, size: CGFloat) {
        self.name = name
        self.size = size
    }

    var body: some View {
        Image(uiImage: .bundled(name))
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 19, weight: .heavy))
            .foregroundStyle(Color(hex: 0x222639))
            .frame(maxWidth: .infinity)
            .frame(height: 58)
            .background(Color(hex: 0xF4A261).opacity(configuration.isPressed ? 0.82 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.white.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.28), radius: 12, x: 0, y: 6)
    }
}

extension Color {
    init(hex: UInt32, alpha: Double = 1) {
        let red = Double((hex >> 16) & 0xff) / 255
        let green = Double((hex >> 8) & 0xff) / 255
        let blue = Double(hex & 0xff) / 255
        self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
}

/// 首页底部的迷你日常目标进度条，展示当前完成的日常目标数量和总目标数量，以及一个小图标
struct MiniDailyGoalBar: View {
    @ObservedObject var progressStore: ProgressStore
    
    private var progress: CGFloat {
        let completed = progressStore.state.dailyCompleted
        let goal = progressStore.dailyGoalCount
        guard goal > 0 else { return 0 }
        return CGFloat(min(goal, completed)) / CGFloat(goal)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            AssetIcon("icon_gift", size: 22)
            
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color(hex: 0x14162A))
                    Capsule()
                        .fill(Color(hex: 0x2A9D8F))
                        .frame(width: proxy.size.width * progress)
                }
            }
            .frame(height: 8)
            
            Text("\(progressStore.state.dailyCompleted)/\(progressStore.dailyGoalCount)")
                .font(.system(size: 12, weight: .black))
                .foregroundStyle(Color.white.opacity(0.78))
        }
        .frame(height: 28)
        .padding(.horizontal, 14)
        .background(Color(hex: 0x2A2D44).opacity(0.68))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .stroke(Color(hex: 0x8F95B8).opacity(0.2), lineWidth: 1)
        )
    }
}

struct HomeBottomNavButton: View {
    let title: String
    let assetName: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                AssetIcon(assetName, size: 24)
                Text(title)
            }
            .font(.system(size: 16, weight: .black))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color(hex: 0x2A2D44))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(hex: 0x8F95B8).opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.18), radius: 6, x: 0, y: 3)
        }
    }
}
