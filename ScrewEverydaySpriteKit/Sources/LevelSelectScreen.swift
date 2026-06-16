import SwiftUI

/// 关卡选择界面，展示关卡列表、章节进度、当前关卡信息等内容
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
