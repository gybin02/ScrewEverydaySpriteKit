import Foundation

struct LevelDescriptor: Identifiable, Hashable {
    let id: Int
    let seed: UInt32
    let chapter: Int
    let title: String
    let difficulty: Int
    let rewardCoins: Int
    let repairValue: Int
    let collectionName: String?
    let collectionAssetName: String?
    let collectionSourceLevelID: Int?

    var displayName: String {
        "level_display_name".localizedFormat(id)
    }
}

enum LevelCatalog {
    static let levels: [LevelDescriptor] = (1...60).map { index in
        let chapter = ((index - 1) / 20) + 1
        let title: String
        switch chapter {
        case 1:
            title = "chapter_1"
        case 2:
            title = "chapter_2"
        default:
            title = "chapter_3"
        }

        let collectionName: String?
        let collectionAssetName: String?
        let collectionSourceLevelID: Int?
        if index % 10 == 0 {
            let item = CollectionCatalog.items[(index / 10 - 1) % CollectionCatalog.items.count]
            collectionName = item.name
            collectionAssetName = item.assetName
            collectionSourceLevelID = item.sourceLevelID
        } else {
            collectionName = nil
            collectionAssetName = nil
            collectionSourceLevelID = nil
        }

        return LevelDescriptor(
            id: index,
            seed: UInt32(10_000 + index * 7919),
            chapter: chapter,
            title: title,
            difficulty: min(5, 1 + (index - 1) / 12),
            rewardCoins: 20 + index * 2,
            repairValue: 8 + index,
            collectionName: collectionName,
            collectionAssetName: collectionAssetName,
            collectionSourceLevelID: collectionSourceLevelID
        )
    }

    static func level(id: Int) -> LevelDescriptor {
        levels.first(where: { $0.id == id }) ?? levels[0]
    }
}

struct CollectionItem: Identifiable, Hashable {
    var id: String { name }
    let name: String
    let assetName: String
    let story: String
    let sourceLevelID: Int
}

enum CollectionCatalog {
    static let items: [CollectionItem] = [
        CollectionItem(name: "part_copper_gear", assetName: "part_copper_gear", story: "part_copper_gear_story", sourceLevelID: 10),
        CollectionItem(name: "part_star_screw", assetName: "part_star_screw", story: "part_star_screw_story", sourceLevelID: 20),
        CollectionItem(name: "part_pressure_gauge", assetName: "part_pressure_gauge", story: "part_pressure_gauge_story", sourceLevelID: 30),
        CollectionItem(name: "part_airship_propeller", assetName: "part_airship_propeller", story: "part_airship_propeller_story", sourceLevelID: 40),
        CollectionItem(name: "part_blue_wrench", assetName: "part_blue_wrench", story: "part_blue_wrench_story", sourceLevelID: 50),
        CollectionItem(name: "part_core_bearing", assetName: "part_core_bearing", story: "part_core_bearing_story", sourceLevelID: 60)
    ]

    static func item(named name: String) -> CollectionItem? {
        items.first { $0.name == name || $0.assetName == name || $0.name.localized == name }
    }
}

struct GameRunSummary: Equatable {
    let level: LevelDescriptor
    let didWin: Bool
    let moves: Int
    let duration: TimeInterval
    let remainingScrews: Int
}

struct SettlementReward: Equatable {
    let coins: Int
    let repairValue: Int
    let collectionName: String?
}

struct SettlementState: Equatable {
    let summary: GameRunSummary
    let reward: SettlementReward
    let dailyCompleted: Int
    let dailyGoal: Int
    let nextLevel: LevelDescriptor?
}

struct GameProgressState: Codable {
    var highestUnlockedLevel: Int
    var completedLevels: [Int]
    var coins: Int
    var repairValue: Int
    var unlockedCollections: [String]
    var dailyCompleted: Int

    static let initial = GameProgressState(
        highestUnlockedLevel: 1,
        completedLevels: [],
        coins: 0,
        repairValue: 0,
        unlockedCollections: [],
        dailyCompleted: 0
    )
}
