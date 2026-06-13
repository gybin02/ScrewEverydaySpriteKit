import CoreGraphics
import Foundation

final class SeededRandom {
    private var state: UInt32

    init(seed: UInt32) {
        self.state = seed
    }

    func next() -> Double {
        state &+= 0x6D2B79F5
        var t = state
        t = (t ^ (t >> 15)) &* (1 | t)
        t = (t &+ ((t ^ (t >> 7)) &* (61 | t))) ^ t
        return Double(t ^ (t >> 14)) / (Double(UInt32.max) + 1.0)
    }
}

enum LevelGenerator {
    private static let playTop: CGFloat = 400
    private static let playBottom: CGFloat = 1240
    private static let playLeft: CGFloat = 50
    private static let playRight: CGFloat = 670

    static func generate(levelId: Int, seed inputSeed: UInt32? = nil) -> Level {
        let seed = inputSeed ?? UInt32(Date().timeIntervalSince1970.truncatingRemainder(dividingBy: Double(UInt32.max)))
        let random = SeededRandom(seed: seed)

        // --- 动态难度曲线算法 ---
        let levelTotalColors: Int
        let levelGroupsPerColor: Int
        let topBoxCount: Int
        let bufferCapacity: Int

        // 1. 颜色数设计 (palette 共有 7 种颜色)
        if levelId <= 3 {
            levelTotalColors = 3
        } else if levelId <= 10 {
            levelTotalColors = 4
        } else if levelId <= 20 {
            levelTotalColors = 5
        } else if levelId <= 40 {
            levelTotalColors = 6
        } else {
            levelTotalColors = 7
        }

        // 2. 每个颜色拥有的组数 (每组包含 3 个相同颜色的螺丝，总螺丝数 = 颜色数 * 组数 * 3)
        if levelId <= 5 {
            levelGroupsPerColor = 2  // 前5关为新手引导，总共 18/24 颗螺丝
        } else if levelId <= 25 {
            levelGroupsPerColor = 3  // 中期难度，总共 36/45 颗螺丝
        } else if levelId <= 45 {
            levelGroupsPerColor = 4  // 进阶难度，总共 60/72 颗螺丝
        } else {
            levelGroupsPerColor = 5  // 高难挑战，总数极多，重叠复杂
        }

        // 3. 顶部工具箱数量 (默认 4)
        if levelId <= 35 {
            topBoxCount = 4
        } else {
            topBoxCount = 3  // 高难关：只有 3 个工具箱，容易爆箱，需要谨慎规划
        }

        // 4. 备选区容量 (4..7)
        if levelId <= 5 {
            bufferCapacity = 7  // 新手期：7格备选，容错率极高
        } else if levelId <= 15 {
            bufferCapacity = 6
        } else if levelId <= 35 {
            bufferCapacity = 5
        } else {
            bufferCapacity = 4  // 高难关：仅 4 格备选，逻辑性极强
        }
        // -------------------------

        let allColors = Array(0..<GameConstants.palette.count)
        let levelColors = pick(allColors, count: levelTotalColors, random: random)

        var screwPool: [Int] = []
        for color in levelColors {
            for _ in 0..<(levelGroupsPerColor * 3) {
                screwPool.append(color)
            }
        }

        let screws = shuffle(screwPool, random: random)
        let boardCount = screws.count / GameConstants.screwsPerBoard
        let rows = 7
        let cols = 3
        let cellWidth = (playRight - playLeft) / CGFloat(cols)
        let cellHeight = (playBottom - playTop) / CGFloat(rows)

        var cells: [(row: Int, col: Int)] = []
        for row in 0..<rows {
            for col in 0..<cols {
                cells.append((row, col))
            }
        }

        let cellOrder = shuffle(cells, random: random)
        var boards: [GeneratedBoard] = []

        for index in 0..<boardCount {
            let cell = cellOrder[index % cellOrder.count]
            let shape = GameConstants.boardShapes[Int(random.next() * Double(GameConstants.boardShapes.count))]
            let cx = playLeft + CGFloat(cell.col) * cellWidth + cellWidth / 2 + CGFloat(random.next() - 0.5) * (cellWidth * 0.4)
            let cy = playTop + CGFloat(cell.row) * cellHeight + cellHeight / 2 + CGFloat(random.next() - 0.5) * (cellHeight * 0.35)
            let triplet = Array(screws[(index * GameConstants.screwsPerBoard)..<((index + 1) * GameConstants.screwsPerBoard)])
            let generatedScrews = layoutScrews(on: shape, colors: triplet, random: random)
            boards.append(GeneratedBoard(
                id: "b\(index)",
                position: CGPoint(x: cx, y: cy),
                size: shape,
                z: index,
                screws: generatedScrews
            ))
        }

        var fullSequence: [Int] = []
        for color in levelColors {
            for _ in 0..<levelGroupsPerColor {
                fullSequence.append(color)
            }
        }

        var boxSequence = shuffle(fullSequence, random: random)
        for _ in 0..<200 {
            let head = boxSequence.prefix(topBoxCount)
            if Set(head).count == topBoxCount { break }
            boxSequence = shuffle(fullSequence, random: random)
        }

        return Level(
            boards: boards,
            initialBoxColors: Array(boxSequence.prefix(topBoxCount)),
            colorPool: Array(boxSequence.dropFirst(topBoxCount)),
            levelColors: levelColors,
            seed: seed,
            topBoxCount: topBoxCount,
            bufferCapacity: bufferCapacity
        )
    }

    private static func pick<T>(_ array: [T], count: Int, random: SeededRandom) -> [T] {
        var source = array
        var output: [T] = []
        while output.count < count && !source.isEmpty {
            let index = Int(random.next() * Double(source.count))
            output.append(source.remove(at: index))
        }
        return output
    }

    private static func shuffle<T>(_ array: [T], random: SeededRandom) -> [T] {
        var result = array
        guard result.count > 1 else { return result }
        for index in stride(from: result.count - 1, through: 1, by: -1) {
            let swapIndex = Int(random.next() * Double(index + 1))
            result.swapAt(index, swapIndex)
        }
        return result
    }

    private static func layoutScrews(on boardSize: CGSize, colors: [Int], random: SeededRandom) -> [GeneratedScrew] {
        var output: [GeneratedScrew] = []
        let margin = GameConstants.screwRadius + 10
        let usableWidth = boardSize.width - margin * 2

        for index in colors.indices {
            let t = colors.count == 1 ? 0.5 : CGFloat(index) / CGFloat(colors.count - 1)
            let baseX = -usableWidth / 2 + t * usableWidth
            var offset = CGPoint.zero
            var tries = 0
            while tries < 30 {
                offset = CGPoint(
                    x: baseX + CGFloat(random.next() - 0.5) * 12,
                    y: CGFloat(random.next() - 0.5) * (boardSize.height * 0.4)
                )
                let ok = output.allSatisfy { screw in
                    hypot(screw.offset.x - offset.x, screw.offset.y - offset.y) >= GameConstants.screwMinDistance
                }
                if ok { break }
                tries += 1
            }
            output.append(GeneratedScrew(color: colors[index], offset: offset))
        }
        return output
    }
}
