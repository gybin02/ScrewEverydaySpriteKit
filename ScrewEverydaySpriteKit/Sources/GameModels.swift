import CoreGraphics
import SpriteKit
import UIKit

enum GameConstants {
    static let logicalWidth: CGFloat = 720
    static let logicalHeight: CGFloat = 1280
    static let boxSlotCapacity = 3
    static let topBoxCount = 4
    static let bufferCapacity = 5
    static let screwRadius: CGFloat = 24
    static let boardRadius: CGFloat = 16
    static let screwMinDistance: CGFloat = screwRadius * 2 + 8
    static let levelTotalColors = 7
    static let levelGroupsPerColor = 3
    static let screwsPerBoard = 3

    static let palette: [UIColor] = [
        UIColor(hex: 0xe63946),
        UIColor(hex: 0xf4a261),
        UIColor(hex: 0xe9c46a),
        UIColor(hex: 0x2a9d8f),
        UIColor(hex: 0x457b9d),
        UIColor(hex: 0x9b5de5),
        UIColor(hex: 0xf15bb5)
    ]

    static let boardShapes: [CGSize] = [
        CGSize(width: 240, height: 110),
        CGSize(width: 280, height: 100),
        CGSize(width: 220, height: 130),
        CGSize(width: 260, height: 110),
        CGSize(width: 300, height: 110)
    ]
}

final class Screw {
    let id: String
    let color: Int
    var offset: CGPoint
    var boardId: String?
    var unlocked = true
    var bufferSlot: Int?
    weak var node: SKNode?

    let originalBoardId: String
    let originalOffset: CGPoint

    init(id: String, color: Int, offset: CGPoint, boardId: String) {
        self.id = id
        self.color = color
        self.offset = offset
        self.boardId = boardId
        self.originalBoardId = boardId
        self.originalOffset = offset
    }
}

final class Board {
    let id: String
    let position: CGPoint
    let size: CGSize
    let z: Int
    var removed = false
    var screws: [Screw]

    init(id: String, position: CGPoint, size: CGSize, z: Int, screws: [Screw]) {
        self.id = id
        self.position = position
        self.size = size
        self.z = z
        self.screws = screws
    }
}

final class ToolBox {
    let slotIndex: Int
    var color: Int?
    var count = 0
    var removed = false
    var center = CGPoint.zero
    var size = CGSize.zero
    var holeCenters: [CGPoint] = []

    init(slotIndex: Int, color: Int) {
        self.slotIndex = slotIndex
        self.color = color
    }
}

struct Level {
    let boards: [GeneratedBoard]
    let initialBoxColors: [Int]
    let colorPool: [Int]
    let levelColors: [Int]
    let seed: UInt32
    let topBoxCount: Int
    let bufferCapacity: Int
}

struct GeneratedBoard {
    let id: String
    let position: CGPoint
    let size: CGSize
    let z: Int
    let screws: [GeneratedScrew]
}

struct GeneratedScrew {
    let color: Int
    let offset: CGPoint
}

extension UIColor {
    convenience init(hex: UInt32, alpha: CGFloat = 1) {
        let red = CGFloat((hex >> 16) & 0xff) / 255
        let green = CGFloat((hex >> 8) & 0xff) / 255
        let blue = CGFloat(hex & 0xff) / 255
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
