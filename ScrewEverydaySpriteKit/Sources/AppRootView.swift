import SwiftUI

enum AppRoute: Equatable {
    case home
    case levels
    case collection
    case game(LevelDescriptor)
    case settlement(SettlementState)
}

struct AppRootView: View {
    @StateObject private var progressStore = ProgressStore()
    @State private var route: AppRoute = .home

    var body: some View {
        ZStack {
            switch route {
            case .home:
                FalHomeScreen(
                    progressStore: progressStore,
                    onPlay: { route = .game(progressStore.currentLevel) },
                    onLevels: { route = .levels },
                    onCollection: { route = .collection }
                )
            case .levels:
                LevelSelectScreen(
                    progressStore: progressStore,
                    onBack: { route = .home },
                    onStart: { route = .game($0) }
                )
            case .collection:
                CollectionScreen(
                    progressStore: progressStore,
                    onBack: { route = .home }
                )
            case .game(let level):
                GameView(
                    level: level,
                    progressStore: progressStore,
                    onExit: { route = .home },
                    onFinish: { summary in
                        let settlement = progressStore.apply(summary: summary)
                        route = .settlement(settlement)
                    }
                )
            case .settlement(let settlement):
                SettlementScreen(
                    settlement: settlement,
                    onHome: { route = .home },
                    onLevels: { route = .levels },
                    onNext: { level in route = .game(level) }
                )
            }
        }
        .preferredColorScheme(.dark)
    }
}

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

struct LevelSelectScreen: View {
    @ObservedObject var progressStore: ProgressStore
    let onBack: () -> Void
    let onStart: (LevelDescriptor) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        ScreenBackground {
            VStack(spacing: 18) {
                TopBar(title: "level_title".localized, subtitle: "level_chapter_info".localizedFormat(progressStore.currentLevel.title.localized), onBack: onBack)

                ChapterProgressCard(progressStore: progressStore)

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(LevelCatalog.levels) { level in
                            LevelNode(
                                level: level,
                                isCompleted: progressStore.isCompleted(level),
                                isUnlocked: progressStore.isUnlocked(level),
                                isCurrent: progressStore.currentLevel.id == level.id
                            ) {
                                if progressStore.isUnlocked(level) {
                                    onStart(level)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }

                CurrentLevelCard(level: progressStore.currentLevel) {
                    onStart(progressStore.currentLevel)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 18)
        }
    }
}

struct CollectionScreen: View {
    @ObservedObject var progressStore: ProgressStore
    let onBack: () -> Void
    @State private var selectedDetail: CollectionDetailState?

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: 3)

    var body: some View {
        ScreenBackground {
            VStack(spacing: 18) {
                TopBar(title: "collection_title".localized, subtitle: "collection_desc".localized, onBack: onBack)

                Text("collection_count".localizedFormat(progressStore.state.unlockedCollections.count, CollectionCatalog.items.count))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)

                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(CollectionCatalog.items) { item in
                        let unlocked = progressStore.state.unlockedCollections.contains(item.name)
                        Button {
                            selectedDetail = CollectionDetailState(item: item, unlocked: unlocked)
                        } label: {
                            CollectionItemCard(item: item, unlocked: unlocked)
                        }
                        .buttonStyle(.plain)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 18)
            .padding(.bottom, 24)
            .sheet(item: $selectedDetail) { detail in
                CollectionDetailSheet(detail: detail)
                    .presentationDetents([.medium, .large])
                    .presentationCornerRadius(28)
            }
        }
    }
}

struct CollectionDetailState: Identifiable {
    let item: CollectionItem
    let unlocked: Bool

    var id: String { item.name }
}

struct SettlementScreen: View {
    let settlement: SettlementState
    let onHome: () -> Void
    let onLevels: () -> Void
    let onNext: (LevelDescriptor) -> Void

    var body: some View {
        ScreenBackground {
            VStack(spacing: 18) {
                Spacer(minLength: 30)

                VStack(spacing: 8) {
                    AssetIcon(settlement.summary.didWin ? "icon_success" : "icon_fail", size: 72)
                    Text(settlement.summary.didWin ? "settlement_win".localized : "settlement_lose".localized)
                        .font(.system(size: 36, weight: .heavy))
                        .foregroundStyle(.white)
                    Text("settlement_summary".localizedFormat(settlement.summary.level.id, formatDuration(settlement.summary.duration), settlement.summary.moves))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.68))
                }

                RewardCard(settlement: settlement)

                DailyGoalCard(
                    completed: settlement.dailyCompleted,
                    goal: settlement.dailyGoal,
                    text: settlement.dailyCompleted >= settlement.dailyGoal ? "daily_goal_done".localized : "daily_goal_hint".localizedFormat(settlement.dailyGoal - settlement.dailyCompleted)
                )

                if let nextLevel = settlement.nextLevel {
                    NextRewardCard(level: nextLevel)
                }

                Spacer()

                if let nextLevel = settlement.nextLevel {
                    Button(settlement.summary.didWin ? "settlement_btn_next".localized : "settlement_btn_retry".localized) {
                        onNext(nextLevel)
                    }
                    .buttonStyle(PrimaryButtonStyle())
                }

                HStack(spacing: 12) {
                    SecondaryNavButton(title: "settlement_btn_levels".localized, assetName: "icon_levels", action: onLevels)
                    SecondaryNavButton(title: "settlement_btn_home".localized, assetName: "icon_home", action: onHome)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 18)
            .padding(.bottom, 24)
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let totalSeconds = max(0, Int(duration.rounded()))
        return String(format: "%02d:%02d", totalSeconds / 60, totalSeconds % 60)
    }
}

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

struct ChapterProgressCard: View {
    @ObservedObject var progressStore: ProgressStore

    private var chapterLevels: [LevelDescriptor] {
        LevelCatalog.levels.filter { $0.chapter == progressStore.currentLevel.chapter }
    }

    private var completedInChapter: Int {
        chapterLevels.filter { progressStore.isCompleted($0) }.count
    }

    var body: some View {
        DailyGoalCard(
            completed: completedInChapter,
            goal: chapterLevels.count,
            text: "\(progressStore.currentLevel.title) \(completedInChapter)/\(chapterLevels.count)"
        )
    }
}

struct LevelNode: View {
    let level: LevelDescriptor
    let isCompleted: Bool
    let isUnlocked: Bool
    let isCurrent: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                AssetIcon(iconAssetName, size: 34)
                Text("\(level.id)")
                    .font(.system(size: 17, weight: .heavy))
            }
            .foregroundStyle(isUnlocked ? .white : Color.white.opacity(0.34))
            .frame(maxWidth: .infinity)
            .frame(height: 76)
            .background(backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isCurrent ? Color(hex: 0xF4A261) : Color(hex: 0x8F95B8).opacity(0.35), lineWidth: isCurrent ? 2 : 1)
            )
            .shadow(color: .black.opacity(isCurrent ? 0.3 : 0.2), radius: isCurrent ? 12 : 8, x: 0, y: isCurrent ? 6 : 4)
        }
        .disabled(!isUnlocked)
    }

    private var iconAssetName: String {
        if isCompleted { return "icon_check" }
        if isUnlocked { return level.collectionName == nil ? "icon_tool" : "icon_gift" }
        return "icon_lock"
    }

    private var backgroundColor: Color {
        if isCompleted { return Color(hex: 0x2A9D8F).opacity(0.78) }
        if isUnlocked { return Color(hex: 0x2A2D44) }
        return Color(hex: 0x1A1D2D)
    }
}

struct CurrentLevelCard: View {
    let level: LevelDescriptor
    let onStart: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("\(level.displayName) · \(level.title.localized)")
                .font(.system(size: 18, weight: .heavy))
                .foregroundStyle(.white)
            Text("level_reward_info".localizedFormat(level.rewardCoins, level.repairValue))
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.72))
            if let collectionName = level.collectionName {
                Text("level_rare_part".localizedFormat(collectionName.localized))
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(Color(hex: 0xF4A261))
            }
            Button("level_start_btn".localized) {
                onStart()
            }
            .buttonStyle(PrimaryButtonStyle())
        }
        .padding(16)
        .background(Color(hex: 0x2A2D44))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(hex: 0x6A6E8E), lineWidth: 1)
        )
    }
}

struct CollectionItemCard: View {
    let item: CollectionItem
    let unlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Image(uiImage: .bundled(item.assetName))
                    .resizable()
                    .scaledToFit()
                    .padding(8)
                    .saturation(unlocked ? 1 : 0.42)
            .opacity(unlocked ? 1 : 0.62)
            .blur(radius: unlocked ? 0 : 0.2)

                if !unlocked {
                    AssetIcon("icon_lock", size: 20)
                        .opacity(0.9)
                        .offset(x: 24, y: -24)
                }
            }
            .frame(width: 68, height: 68)
            Text(unlocked ? item.name.localized : "collection_locked_name".localized)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(unlocked ? .white : Color.white.opacity(0.42))
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(unlocked ? item.story.localized : "collection_locked_desc".localized)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(Color.white.opacity(unlocked ? 0.58 : 0.32))
                .lineLimit(1)
                .minimumScaleFactor(0.72)
            Text("collection_locked_source".localizedFormat(item.sourceLevelID))
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(Color.white.opacity(unlocked ? 0.42 : 0.22))
        }
        .frame(maxWidth: .infinity)
        .frame(height: 146)
        .background(Color(hex: unlocked ? 0x2A2D44 : 0x1A1D2D))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(unlocked ? Color(hex: 0xF4A261) : Color(hex: 0x8F95B8).opacity(0.28), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.24), radius: 8, x: 0, y: 4)
    }
}

struct CollectionDetailSheet: View {
    let detail: CollectionDetailState

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: 0x2A2D44), Color(hex: 0x14162A)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                HStack(spacing: 14) {
                    Image(detail.item.assetName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 88, height: 88)
                        .padding(10)
                        .background(Color.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .stroke(Color(hex: 0x8F95B8).opacity(0.28), lineWidth: 1)
                        )

                    VStack(alignment: .leading, spacing: 6) {
                        Text(detail.item.name.localized)
                            .font(.system(size: 28, weight: .heavy))
                            .foregroundStyle(.white)
                        Text("collection_locked_source".localizedFormat(detail.item.sourceLevelID))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.66))
                        Text(detail.unlocked ? "part_unlock_status".localized : "part_lock_status".localized)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(Color(hex: 0xF4A261))
                    }

                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("part_story_title".localized)
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(.white)
                    Text(detail.item.story.localized)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.74))
                        .lineSpacing(4)
                }
                .padding(16)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    Text("part_source_title".localized)
                        .font(.system(size: 16, weight: .heavy))
                        .foregroundStyle(.white)
                    Text("part_source_desc".localizedFormat(detail.item.sourceLevelID))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.white.opacity(0.68))
                        .lineSpacing(4)
                }
                .padding(16)
                .background(Color.white.opacity(0.04))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                Spacer(minLength: 0)
            }
            .padding(20)
        }
    }
}

struct RewardCard: View {
    let settlement: SettlementState

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("reward_title".localized)
                .font(.system(size: 20, weight: .heavy))
                .foregroundStyle(.white)
            HStack(spacing: 12) {
                RewardPill(assetName: "icon_coin", title: "reward_coin".localized, value: "+\(settlement.reward.coins)")
                RewardPill(assetName: "icon_repair", title: "reward_repair".localized, value: "+\(settlement.reward.repairValue)")
            }
            if let collectionName = settlement.reward.collectionName,
               let item = CollectionCatalog.item(named: collectionName) {
                HStack(spacing: 10) {
                    Image(uiImage: .bundled(item.assetName))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("reward_part_unlocked".localized)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.white.opacity(0.64))
                        Text(collectionName.localized)
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundStyle(.white)
                    }
                    Spacer()
                }
                .padding(12)
                .background(Color(hex: 0x14162A))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            if let collectionName = settlement.reward.collectionName {
                Text(CollectionCatalog.item(named: collectionName)?.story.localized ?? "reward_part_default_story".localized)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.72))
                    .padding(.top, 2)
            }
        }
        .padding(18)
        .background(Color(hex: 0x2A2D44))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color(hex: 0x8F95B8).opacity(0.35), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.28), radius: 12, x: 0, y: 6)
    }
}

struct RewardPill: View {
    let assetName: String
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            AssetIcon(assetName, size: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.62))
                Text(value)
                    .font(.system(size: 18, weight: .heavy))
                    .foregroundStyle(.white)
            }
            Spacer()
        }
        .padding(12)
        .background(Color(hex: 0x14162A))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 1)
        )
    }
}

struct NextRewardCard: View {
    let level: LevelDescriptor

    var body: some View {
        HStack(spacing: 12) {
            AssetIcon(level.collectionName == nil ? "icon_play" : "icon_gift", size: 34)
            VStack(alignment: .leading, spacing: 4) {
                Text("next_target_title".localizedFormat(level.id))
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(.white)
                Text(level.collectionName.map { "next_target_part_preview".localizedFormat($0.localized) } ?? "next_target_coin_preview".localizedFormat(level.rewardCoins))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.68))
                Text("next_target_preview_hint".localizedFormat(level.collectionSourceLevelID ?? level.id))
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.48))
            }
            Spacer()
        }
        .padding(16)
        .background(Color(hex: 0x24283B))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color(hex: 0x8F95B8).opacity(0.28), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.22), radius: 10, x: 0, y: 5)
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
