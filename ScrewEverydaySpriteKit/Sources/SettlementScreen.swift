import SwiftUI
/// 结算界面，展示关卡完成结果、奖励信息、下一关预览等内容
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
