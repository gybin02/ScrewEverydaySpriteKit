import Combine
import Foundation

final class ProgressStore: ObservableObject {
    @Published private(set) var state: GameProgressState

    private let storageKey = "screwEveryday.progress.v1"
    private let dailyGoal = 5

    init() {
        if
            let data = UserDefaults.standard.data(forKey: storageKey),
            let decoded = try? JSONDecoder().decode(GameProgressState.self, from: data)
        {
            state = decoded
        } else {
            state = .initial
        }
    }

    var currentLevel: LevelDescriptor {
        LevelCatalog.level(id: state.highestUnlockedLevel)
    }

    var dailyGoalCount: Int {
        dailyGoal
    }

    func isCompleted(_ level: LevelDescriptor) -> Bool {
        state.completedLevels.contains(level.id)
    }

    func isUnlocked(_ level: LevelDescriptor) -> Bool {
        level.id <= state.highestUnlockedLevel
    }

    func apply(summary: GameRunSummary) -> SettlementState {
        let reward: SettlementReward
        if summary.didWin {
            reward = SettlementReward(
                coins: summary.level.rewardCoins,
                repairValue: summary.level.repairValue,
                collectionName: summary.level.collectionName
            )
            state.coins += reward.coins
            state.repairValue += reward.repairValue
            state.dailyCompleted = min(dailyGoal, state.dailyCompleted + 1)

            if !state.completedLevels.contains(summary.level.id) {
                state.completedLevels.append(summary.level.id)
                state.completedLevels.sort()
            }
            if let collectionName = reward.collectionName, !state.unlockedCollections.contains(collectionName) {
                state.unlockedCollections.append(collectionName)
            }
            if summary.level.id >= state.highestUnlockedLevel {
                state.highestUnlockedLevel = min(LevelCatalog.levels.count, summary.level.id + 1)
            }
        } else {
            reward = SettlementReward(coins: 5, repairValue: 1, collectionName: nil)
            state.coins += reward.coins
            state.repairValue += reward.repairValue
        }

        save()
        return SettlementState(
            summary: summary,
            reward: reward,
            dailyCompleted: state.dailyCompleted,
            dailyGoal: dailyGoal,
            nextLevel: summary.didWin ? nextLevel(after: summary.level) : summary.level
        )
    }

    func buyItem(cost: Int) -> Bool {
        guard state.coins >= cost else { return false }
        state.coins -= cost
        save()
        return true
    }

    func refundItem(cost: Int) {
        state.coins += cost
        save()
    }

    private func nextLevel(after level: LevelDescriptor) -> LevelDescriptor? {
        let nextId = min(level.id + 1, LevelCatalog.levels.count)
        guard nextId != level.id || level.id < LevelCatalog.levels.count else { return nil }
        return LevelCatalog.level(id: nextId)
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }
}
