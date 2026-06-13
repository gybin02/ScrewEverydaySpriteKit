import SpriteKit
import UIKit

final class GameScene: SKScene {
    private let levelDescriptor: LevelDescriptor
    private let onFinish: (GameRunSummary) -> Void

    private var level: Level!
    private var boards: [Board] = []
    private var boxes: [ToolBox] = []
    private var buffer: [Screw] = []
    private var colorPoolIndex = 0
    private var totalScrews = 0
    private var removedCount = 0
    private var gameStatus: GameStatus = .playing
    private var isBusy = false
    private var moveCount = 0
    private var startedAt = Date()
    private var didReportResult = false

    private var uiScale: CGFloat = 1
    private var offsetX: CGFloat = 0
    private var offsetY: CGFloat = 0
    private var bufferHoleCenters: [CGPoint] = []
    private var bufferHoleRadius: CGFloat = 0

    private let hudLayer = SKNode()
    private let boxLayer = SKNode()
    private let bufferLayer = SKNode()
    private let boardLayer = SKNode()
    private let screwLayer = SKNode()
    private let overlayLayer = SKNode()

    private let titleLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
    private let statusLabel = SKLabelNode(fontNamed: "AvenirNext-Medium")
    private var screwByNodeName: [String: Screw] = [:]

    private enum GameStatus {
        case playing
        case win
        case lose
    }

    init(level: LevelDescriptor, onFinish: @escaping (GameRunSummary) -> Void) {
        self.levelDescriptor = level
        self.onFinish = onFinish
        super.init(size: .zero)
        scaleMode = .resizeFill
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        backgroundColor = UIColor(hex: 0x2d3142)
        scaleMode = .resizeFill
        setupLayers()
        startNewGame()
        AudioManager.shared.playBGM()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        guard size.width > 0, size.height > 0, level != nil else { return }
        rebuildSceneForCurrentState()
    }

    private func setupLayers() {
        removeAllChildren()
        [hudLayer, boxLayer, bufferLayer, boardLayer, screwLayer, overlayLayer].forEach { layer in
            layer.removeFromParent()
            addChild(layer)
        }
        hudLayer.zPosition = 10
        boxLayer.zPosition = 20
        bufferLayer.zPosition = 15
        boardLayer.zPosition = 1
        screwLayer.zPosition = 30
        overlayLayer.zPosition = 10_000
    }

    private func startNewGame() {
        gameStatus = .playing
        isBusy = false
        moveCount = 0
        didReportResult = false
        startedAt = Date()
        level = LevelGenerator.generate(levelId: levelDescriptor.id, seed: levelDescriptor.seed)
        resetState()
        rebuildSceneForCurrentState()
        playEntranceAnimation()
    }

    private func resetState() {
        boards = level.boards.map { generated in
            let screws = generated.screws.enumerated().map { index, screw in
                Screw(
                    id: "\(generated.id)_s\(index)",
                    color: screw.color,
                    offset: screw.offset,
                    boardId: generated.id
                )
            }
            return Board(
                id: generated.id,
                position: generated.position,
                size: generated.size,
                z: generated.z,
                screws: screws
            )
        }
        boxes = level.initialBoxColors.enumerated().map { index, color in
            ToolBox(slotIndex: index, color: color)
        }
        buffer = []
        colorPoolIndex = 0
        totalScrews = boards.reduce(0) { $0 + $1.screws.count }
        removedCount = 0
        screwByNodeName = [:]
    }

    private func rebuildSceneForCurrentState() {
        configureScale()
        hudLayer.removeAllChildren()
        boxLayer.removeAllChildren()
        bufferLayer.removeAllChildren()
        boardLayer.removeAllChildren()
        screwLayer.removeAllChildren()
        overlayLayer.removeAllChildren()
        screwByNodeName = [:]

        buildHUD()
        buildTopBoxes()
        buildBuffer()
        redrawBoards()
        buildScrews()
        recomputeOcclusion()
        refreshHUD()
    }

    private func configureScale() {
        uiScale = min(size.width / GameConstants.logicalWidth, size.height / GameConstants.logicalHeight)
        offsetX = (size.width - GameConstants.logicalWidth * uiScale) / 2
        offsetY = (size.height - GameConstants.logicalHeight * uiScale) / 2
    }

    private func screenPoint(x: CGFloat, y: CGFloat) -> CGPoint {
        CGPoint(
            x: offsetX + x * uiScale,
            y: size.height - (offsetY + y * uiScale)
        )
    }

    private func scaled(_ value: CGFloat) -> CGFloat {
        value * uiScale
    }

    private func buildHUD() {
        titleLabel.text = "game_scene_title".localizedFormat(levelDescriptor.id)
        titleLabel.fontSize = scaled(32)
        titleLabel.fontColor = .white
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = screenPoint(x: GameConstants.logicalWidth / 2, y: 50)
        hudLayer.addChild(titleLabel)

        statusLabel.fontSize = scaled(19)
        statusLabel.fontColor = UIColor(white: 0.82, alpha: 1)
        statusLabel.horizontalAlignmentMode = .center
        statusLabel.verticalAlignmentMode = .center
        statusLabel.numberOfLines = 2
        statusLabel.position = screenPoint(x: GameConstants.logicalWidth / 2, y: 92)
        hudLayer.addChild(statusLabel)
    }

    private func refreshHUD() {
        let remaining = totalScrews - removedCount
        let poolRemaining = max(0, level.colorPool.count - colorPoolIndex)
        let boxText = boxes.compactMap { box -> String? in
            guard let color = box.color else { return nil }
            return "\(color):\(box.count)"
        }.joined(separator: ",")
        statusLabel.text = "game_scene_hud".localizedFormat(remaining, totalScrews, buffer.count, level.bufferCapacity, boxes.count, poolRemaining) + "\n[\(boxText)]"
    }

    private func buildTopBoxes() {
        let boxWidth: CGFloat = 140
        let boxHeight: CGFloat = 90
        let gap: CGFloat = 16
        let totalWidth = CGFloat(level.topBoxCount) * boxWidth + CGFloat(level.topBoxCount - 1) * gap
        let startX = (GameConstants.logicalWidth - totalWidth) / 2
        let y: CGFloat = 170

        for box in boxes {
            let cx = startX + CGFloat(box.slotIndex) * (boxWidth + gap) + boxWidth / 2
            box.center = screenPoint(x: cx, y: y)
            box.size = CGSize(width: scaled(boxWidth), height: scaled(boxHeight))
            box.holeCenters = (0..<GameConstants.boxSlotCapacity).map { index in
                let t = CGFloat(index + 1) / CGFloat(GameConstants.boxSlotCapacity + 1)
                let hx = box.center.x - box.size.width / 2 + box.size.width * t
                let hy = box.center.y - scaled(8)
                return CGPoint(x: hx, y: hy)
            }
        }
        redrawBoxes()
    }

    private func redrawBoxes() {
        boxLayer.removeAllChildren()
        for box in boxes where !box.removed {
            guard let colorIndex = box.color else { continue }
            let node = SKNode()
            node.position = box.center
            let color = GameConstants.palette[colorIndex]
            let rect = CGRect(
                x: -box.size.width / 2,
                y: -box.size.height / 2,
                width: box.size.width,
                height: box.size.height - scaled(10)
            )
            let body = SKShapeNode(rect: rect, cornerRadius: scaled(12))
            body.fillColor = color
            body.strokeColor = UIColor.black.withAlphaComponent(0.35)
            body.lineWidth = scaled(2)
            node.addChild(body)

            let gloss = SKShapeNode(rect: CGRect(x: rect.minX, y: rect.maxY - scaled(14), width: rect.width, height: scaled(14)), cornerRadius: scaled(8))
            gloss.fillColor = UIColor.white.withAlphaComponent(0.18)
            gloss.strokeColor = .clear
            node.addChild(gloss)

            let handle = SKShapeNode(rect: CGRect(x: -scaled(25), y: box.size.height / 2 - scaled(18), width: scaled(50), height: scaled(20)), cornerRadius: scaled(8))
            handle.fillColor = UIColor(hex: 0x222639)
            handle.strokeColor = .clear
            node.addChild(handle)

            for index in 0..<GameConstants.boxSlotCapacity {
                let holePosition = CGPoint(x: box.holeCenters[index].x - box.center.x, y: box.holeCenters[index].y - box.center.y)
                let hole = makeHoleNode(radius: scaled(14), filledColor: index < box.count ? color : nil)
                hole.position = holePosition
                node.addChild(hole)
            }
            boxLayer.addChild(node)
        }
    }

    private func buildBuffer() {
        let holeRadius: CGFloat = 36
        let gap: CGFloat = 26
        let totalHolesWidth = CGFloat(level.bufferCapacity) * holeRadius * 2 + CGFloat(level.bufferCapacity - 1) * gap
        let rectPadX: CGFloat = 28
        let rectPadY: CGFloat = 22
        let rectWidth = totalHolesWidth + rectPadX * 2
        let rectHeight = holeRadius * 2 + rectPadY * 2
        let cy: CGFloat = 310
        let startCx = (GameConstants.logicalWidth - totalHolesWidth) / 2 + holeRadius

        bufferHoleCenters = (0..<level.bufferCapacity).map { index in
            screenPoint(x: startCx + CGFloat(index) * (holeRadius * 2 + gap), y: cy)
        }
        bufferHoleRadius = scaled(holeRadius)

        let label = SKLabelNode(fontNamed: "AvenirNext-Medium")
        label.text = "game_scene_buffer_label".localizedFormat(level.bufferCapacity)
        label.fontSize = scaled(20)
        label.fontColor = UIColor(white: 0.72, alpha: 1)
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.position = screenPoint(x: GameConstants.logicalWidth / 2, y: cy - rectHeight / 2 - 24)
        bufferLayer.addChild(label)

        let center = screenPoint(x: GameConstants.logicalWidth / 2, y: cy)
        let frame = SKShapeNode(
            rect: CGRect(x: -scaled(rectWidth) / 2, y: -scaled(rectHeight) / 2, width: scaled(rectWidth), height: scaled(rectHeight)),
            cornerRadius: scaled(20)
        )
        frame.position = center
        frame.fillColor = UIColor(hex: 0x2a2d44)
        frame.strokeColor = UIColor(hex: 0x6a6e8e)
        frame.lineWidth = scaled(2)
        bufferLayer.addChild(frame)

        for center in bufferHoleCenters {
            let hole = makeHoleNode(radius: bufferHoleRadius, filledColor: nil)
            hole.position = center
            bufferLayer.addChild(hole)
        }
    }

    private func redrawBoards() {
        boardLayer.removeAllChildren()
        let woodColors = [
            UIColor(hex: 0xa0826d),
            UIColor(hex: 0x8b6f5a),
            UIColor(hex: 0xb89576),
            UIColor(hex: 0x9c7a5e),
            UIColor(hex: 0xc4a37e)
        ]

        for board in boards.filter({ !$0.removed }).sorted(by: { $0.z < $1.z }) {
            let center = screenPoint(x: board.position.x, y: board.position.y)
            let node = SKNode()
            node.position = center
            node.zPosition = CGFloat(board.z)

            let rect = CGRect(
                x: -scaled(board.size.width) / 2,
                y: -scaled(board.size.height) / 2,
                width: scaled(board.size.width),
                height: scaled(board.size.height)
            )
            let shadow = SKShapeNode(rect: rect.offsetBy(dx: scaled(4), dy: -scaled(6)), cornerRadius: scaled(GameConstants.boardRadius))
            shadow.fillColor = UIColor.black.withAlphaComponent(0.35)
            shadow.strokeColor = .clear
            node.addChild(shadow)

            let body = SKShapeNode(rect: rect, cornerRadius: scaled(GameConstants.boardRadius))
            body.fillColor = woodColors[board.z % woodColors.count]
            body.strokeColor = UIColor.black.withAlphaComponent(0.4)
            body.lineWidth = scaled(2)
            node.addChild(body)

            let highlight = SKShapeNode(rect: CGRect(x: rect.minX, y: rect.maxY - scaled(10), width: rect.width, height: scaled(10)), cornerRadius: scaled(7))
            highlight.fillColor = UIColor.white.withAlphaComponent(0.14)
            highlight.strokeColor = .clear
            node.addChild(highlight)

            let grainPath = CGMutablePath()
            grainPath.move(to: CGPoint(x: rect.minX + scaled(10), y: 0))
            grainPath.addLine(to: CGPoint(x: rect.maxX - scaled(10), y: 0))
            let grain = SKShapeNode(path: grainPath)
            grain.strokeColor = UIColor.black.withAlphaComponent(0.18)
            grain.lineWidth = scaled(1)
            node.addChild(grain)

            boardLayer.addChild(node)
        }
    }

    private func buildScrews() {
        for board in boards {
            for screw in board.screws {
                let point = screwPoint(screw, board: board)
                let node = makeScrewNode(colorIndex: screw.color, enabled: screw.unlocked)
                node.position = point
                node.name = "screw:\(screw.id)"
                node.zPosition = CGFloat(board.z) + 100
                screw.node = node
                screwByNodeName[node.name ?? ""] = screw
                screwLayer.addChild(node)
            }
        }

        for screw in buffer {
            guard let slot = screw.bufferSlot, slot < bufferHoleCenters.count else { continue }
            let node = makeScrewNode(colorIndex: screw.color, enabled: false)
            node.position = bufferHoleCenters[slot]
            node.setScale(0.9)
            screw.node = node
            screwLayer.addChild(node)
        }
    }

    private func makeScrewNode(colorIndex: Int, enabled: Bool) -> SKNode {
        let root = SKNode()
        let radius = scaled(GameConstants.screwRadius)
        let alpha: CGFloat = enabled ? 1 : 0.4
        let color = GameConstants.palette[colorIndex].withAlphaComponent(alpha)

        let shadow = SKShapeNode(circleOfRadius: radius)
        shadow.position = CGPoint(x: scaled(2), y: -scaled(3))
        shadow.fillColor = UIColor.black.withAlphaComponent(enabled ? 0.3 : 0.12)
        shadow.strokeColor = .clear
        root.addChild(shadow)

        let outer = SKShapeNode(circleOfRadius: radius)
        outer.fillColor = color
        outer.strokeColor = UIColor.white.withAlphaComponent(enabled ? 0.8 : 0.25)
        outer.lineWidth = scaled(2)
        root.addChild(outer)

        let innerDark = SKShapeNode(circleOfRadius: radius * 0.7)
        innerDark.fillColor = UIColor.black.withAlphaComponent(enabled ? 0.18 : 0.08)
        innerDark.strokeColor = .clear
        root.addChild(innerDark)

        let inner = SKShapeNode(circleOfRadius: radius * 0.6)
        inner.fillColor = color
        inner.strokeColor = .clear
        root.addChild(inner)

        let path = CGMutablePath()
        path.move(to: CGPoint(x: -radius * 0.45, y: 0))
        path.addLine(to: CGPoint(x: radius * 0.45, y: 0))
        path.move(to: CGPoint(x: 0, y: -radius * 0.45))
        path.addLine(to: CGPoint(x: 0, y: radius * 0.45))
        let cross = SKShapeNode(path: path)
        cross.strokeColor = UIColor.black.withAlphaComponent(enabled ? 0.85 : 0.3)
        cross.lineWidth = max(2, radius * 0.14)
        cross.lineCap = .round
        root.addChild(cross)

        let glint = SKShapeNode(circleOfRadius: radius * 0.13)
        glint.position = CGPoint(x: -radius * 0.35, y: radius * 0.35)
        glint.fillColor = UIColor.white.withAlphaComponent(enabled ? 0.55 : 0.18)
        glint.strokeColor = .clear
        root.addChild(glint)
        return root
    }

    private func makeHoleNode(radius: CGFloat, filledColor: UIColor?) -> SKNode {
        let root = SKNode()
        let outer = SKShapeNode(circleOfRadius: radius)
        outer.fillColor = filledColor == nil ? UIColor(hex: 0x14162a) : .white
        outer.strokeColor = UIColor.black.withAlphaComponent(0.55)
        outer.lineWidth = scaled(2)
        root.addChild(outer)

        if let filledColor {
            let fill = SKShapeNode(circleOfRadius: radius - scaled(3))
            fill.fillColor = filledColor
            fill.strokeColor = .clear
            root.addChild(fill)

            let path = CGMutablePath()
            path.move(to: CGPoint(x: -radius * 0.45, y: 0))
            path.addLine(to: CGPoint(x: radius * 0.45, y: 0))
            path.move(to: CGPoint(x: 0, y: -radius * 0.45))
            path.addLine(to: CGPoint(x: 0, y: radius * 0.45))
            let cross = SKShapeNode(path: path)
            cross.strokeColor = UIColor.black.withAlphaComponent(0.6)
            cross.lineWidth = scaled(2)
            cross.lineCap = .round
            root.addChild(cross)
        } else {
            let innerShadow = SKShapeNode(circleOfRadius: radius - scaled(3))
            innerShadow.position = CGPoint(x: scaled(2), y: -scaled(2))
            innerShadow.fillColor = UIColor.black.withAlphaComponent(0.35)
            innerShadow.strokeColor = .clear
            root.addChild(innerShadow)
        }
        return root
    }

    private func playEntranceAnimation() {
        boardLayer.alpha = 0
        screwLayer.alpha = 0
        boardLayer.position.y = scaled(40)
        let fade = SKAction.fadeIn(withDuration: 0.28)
        boardLayer.run(fade)
        screwLayer.run(fade)
        boardLayer.run(SKAction.moveTo(y: 0, duration: 0.38))
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let point = touch.location(in: self)

        if gameStatus != .playing {
            return
        }
        guard !isBusy else { return }

        for node in nodes(at: point) {
            var current: SKNode? = node
            while let inspected = current {
                if let name = inspected.name, let screw = screwByNodeName[name] {
                    handleScrewTap(screw)
                    return
                }
                current = inspected.parent
            }
        }
    }

    private func handleScrewTap(_ screw: Screw) {
        guard gameStatus == .playing, screw.unlocked, let boardId = screw.boardId else { return }
        guard let board = boards.first(where: { $0.id == boardId && !$0.removed }) else { return }
        isBusy = true
        moveCount += 1
        AudioManager.shared.playSFX(named: "click", withExtension: "mp3")
        AudioManager.shared.triggerHaptic(style: .light)

        if let targetBox = boxes.first(where: { !$0.removed && $0.color == screw.color && $0.count < GameConstants.boxSlotCapacity }) {
            flyScrewToBox(screw, targetBox: targetBox, fromBoard: board)
        } else {
            if buffer.count >= level.bufferCapacity {
                screw.node?.run(.sequence([
                    .group([.fadeOut(withDuration: 0.22), .scale(to: 1.5, duration: 0.22)]),
                    .run { [weak self] in self?.endGame(.lose) }
                ]))
                return
            }
            flyScrewToBuffer(screw, fromBoard: board)
        }
    }

    private func flyScrewToBox(_ screw: Screw, targetBox: ToolBox, fromBoard: Board?) {
        guard let node = screw.node else {
            isBusy = false
            return
        }
        let holeIndex = targetBox.count
        let holeCenter = targetBox.holeCenters[holeIndex]
        node.run(.sequence([
            .group([
                .move(to: holeCenter, duration: 0.30),
                .scale(to: 0.55, duration: 0.30),
                .rotate(byAngle: .pi * 1.5, duration: 0.30)
            ]),
            .run { [weak self, weak node] in
                guard let self else { return }
                node?.removeFromParent()
                if let fromBoard {
                    self.removeScrewFromBoard(fromBoard, screw: screw)
                }
                targetBox.count += 1
                if targetBox.count >= GameConstants.boxSlotCapacity {
                    if let fromBoard {
                        self.afterRemoval(fromBoard)
                    }
                    self.dissolveBox(targetBox)
                } else {
                    self.redrawBoxes()
                    if let fromBoard {
                        self.afterRemoval(fromBoard)
                    }
                    self.isBusy = false
                }
            }
        ]))
    }

    private func flyScrewToBuffer(_ screw: Screw, fromBoard: Board) {
        guard let node = screw.node else {
            isBusy = false
            return
        }
        let slotIndex = buffer.count
        let target = bufferHoleCenters[slotIndex]
        node.run(.sequence([
            .group([
                .move(to: target, duration: 0.34),
                .scale(to: 0.9, duration: 0.34),
                .rotate(byAngle: .pi, duration: 0.34)
            ]),
            .run { [weak self] in
                guard let self else { return }
                screw.bufferSlot = slotIndex
                screw.boardId = nil
                screw.unlocked = false
                self.buffer.append(screw)
                self.removeScrewFromBoard(fromBoard, screw: screw)
                self.afterRemoval(fromBoard)
                self.isBusy = false
            }
        ]))
    }

    private func removeScrewFromBoard(_ board: Board, screw: Screw) {
        board.screws.removeAll { $0.id == screw.id }
        if let nodeName = screw.node?.name {
            screwByNodeName.removeValue(forKey: nodeName)
            screw.node?.name = nil
        }
        removedCount += 1
    }

    private func dissolveBox(_ box: ToolBox) {
        AudioManager.shared.playSFX(named: "match", withExtension: "wav")
        AudioManager.shared.triggerHaptic(style: .medium)

        let flash = SKShapeNode(rect: CGRect(x: -box.size.width / 2, y: -box.size.height / 2, width: box.size.width, height: box.size.height), cornerRadius: scaled(12))
        flash.position = box.center
        flash.fillColor = UIColor.white.withAlphaComponent(0.85)
        flash.strokeColor = .clear
        flash.zPosition = 200
        boxLayer.addChild(flash)
        flash.run(.sequence([
            .group([.fadeOut(withDuration: 0.26), .scale(to: 1.15, duration: 0.26)]),
            .removeFromParent()
        ]))
        // 添加粒子特效（使用 ComboButterfly 粒子）
        if let emitter = SKEmitterNode(fileNamed: "ComboButterfly.sks") {
            emitter.position = box.center
            boxLayer.addChild(emitter)
            emitter.run(SKAction.sequence([SKAction.wait(forDuration: 0.6), SKAction.removeFromParent()]))
        }

        if colorPoolIndex < level.colorPool.count {
            box.color = level.colorPool[colorPoolIndex]
            box.count = 0
            colorPoolIndex += 1
            redrawBoxes()
            afterPossibleBoxChange()
        } else {
            box.color = nil
            box.count = 0
            box.removed = true
            boxes.removeAll { $0 === box }
            redrawBoxes()
            afterPossibleBoxChange()
        }
    }

    private func afterPossibleBoxChange() {
        refreshHUD()
        flushBufferToBoxes()
    }

    private func flushBufferToBoxes() {
        guard gameStatus == .playing else { return }
        guard let match = firstBufferMatch() else {
            finalizeCascade()
            return
        }

        let screw = buffer.remove(at: match.bufferIndex)
        reflowBufferPositions()
        guard let node = screw.node else {
            finalizeCascade()
            return
        }

        let holeIndex = match.box.count
        let holeCenter = match.box.holeCenters[holeIndex]
        node.run(.sequence([
            .group([
                .move(to: holeCenter, duration: 0.32),
                .scale(to: 0.55, duration: 0.32),
                .rotate(byAngle: .pi * 1.5, duration: 0.32)
            ]),
            .run { [weak self, weak node] in
                guard let self else { return }
                node?.removeFromParent()
                match.box.count += 1
                if match.box.count >= GameConstants.boxSlotCapacity {
                    self.dissolveBox(match.box)
                } else {
                    self.redrawBoxes()
                    self.refreshHUD()
                    self.flushBufferToBoxes()
                }
            }
        ]))
    }

    private func firstBufferMatch() -> (bufferIndex: Int, box: ToolBox)? {
        for (index, screw) in buffer.enumerated() {
            if let box = boxes.first(where: { !$0.removed && $0.color == screw.color && $0.count < GameConstants.boxSlotCapacity }) {
                return (index, box)
            }
        }
        return nil
    }

    private func reflowBufferPositions() {
        for (index, screw) in buffer.enumerated() {
            screw.bufferSlot = index
            screw.node?.run(.move(to: bufferHoleCenters[index], duration: 0.22))
        }
    }

    private func afterRemoval(_ board: Board) {
        if board.screws.isEmpty && !board.removed {
            board.removed = true
            // 触发掉落动画后再移除节点
            if let node = boardLayer.children.first(where: { $0.position == screenPoint(x: board.position.x, y: board.position.y) }) {
                animateBoardFall(node)
            } else {
                redrawBoards()
            }
        }
        recomputeOcclusion()
        refreshHUD()
    }
private func animateBoardFall(_ node: SKNode) {
    // 动画: 让板块掉落并淡出
    let fallDistance = size.height + node.frame.height
    let fallAction = SKAction.moveBy(x: 0, y: -fallDistance, duration: 0.6)
    let fadeAction = SKAction.fadeOut(withDuration: 0.6)
    let group = SKAction.group([fallAction, fadeAction])
    node.run(SKAction.sequence([group, .removeFromParent()]))
    // 播放掉落音效
    AudioManager.shared.playSFX(named: "fall", withExtension: "wav")
}
    private func finalizeCascade() {
        refreshHUD()
        if boxes.isEmpty && removedCount >= totalScrews && buffer.isEmpty && gameStatus == .playing {
            endGame(.win)
        } else {
            isBusy = false
        }
    }

    private func recomputeOcclusion() {
        let liveBoards = boards.filter { !$0.removed }
        for board in liveBoards {
            for screw in board.screws {
                let screwLogical = CGPoint(x: board.position.x + screw.offset.x, y: board.position.y + screw.offset.y)
                var unlocked = true
                for other in liveBoards where other.id != board.id && other.z > board.z {
                    if isPoint(screwLogical, coveredBy: other) {
                        unlocked = false
                        break
                    }
                }
                if screw.unlocked != unlocked {
                    screw.unlocked = unlocked
                    if let node = screw.node {
                        let replacement = makeScrewNode(colorIndex: screw.color, enabled: unlocked)
                        replacement.position = node.position
                        replacement.zPosition = node.zPosition
                        replacement.name = node.name
                        replacement.xScale = node.xScale
                        replacement.yScale = node.yScale
                        replacement.zRotation = node.zRotation
                        node.removeFromParent()
                        screw.node = replacement
                        screwLayer.addChild(replacement)
                    }
                }
            }
        }
    }

    private func isPoint(_ point: CGPoint, coveredBy board: Board) -> Bool {
        let left = board.position.x - board.size.width / 2
        let right = board.position.x + board.size.width / 2
        let top = board.position.y - board.size.height / 2
        let bottom = board.position.y + board.size.height / 2
        let closestX = max(left, min(point.x, right))
        let closestY = max(top, min(point.y, bottom))
        let dx = point.x - closestX
        let dy = point.y - closestY
        return dx * dx + dy * dy < GameConstants.screwRadius * GameConstants.screwRadius
    }

    private func screwPoint(_ screw: Screw, board: Board) -> CGPoint {
        screenPoint(x: board.position.x + screw.offset.x, y: board.position.y + screw.offset.y)
    }

    private func endGame(_ result: GameStatus) {
        if result == .win {
            AudioManager.shared.playSFX(named: "win", withExtension: "wav")
            AudioManager.shared.triggerHaptic(style: .medium)
        } else {
            AudioManager.shared.playSFX(named: "lose", withExtension: "wav")
            AudioManager.shared.triggerHaptic(style: .heavy)
        }

        gameStatus = result
        isBusy = false
        overlayLayer.removeAllChildren()

        let dim = SKShapeNode(rect: CGRect(origin: .zero, size: size))
        dim.fillColor = UIColor.black.withAlphaComponent(0.72)
        dim.strokeColor = .clear
        dim.zPosition = 0
        overlayLayer.addChild(dim)

        let title = SKLabelNode(fontNamed: "AvenirNext-Bold")
        title.text = result == .win ? "game_scene_win_overlay".localized : "game_scene_lose_overlay".localized
        title.fontSize = scaled(72)
        title.fontColor = result == .win ? UIColor(hex: 0x2a9d8f) : UIColor(hex: 0xe63946)
        title.horizontalAlignmentMode = .center
        title.verticalAlignmentMode = .center
        title.position = CGPoint(x: size.width / 2, y: size.height / 2 + scaled(60))
        title.zPosition = 1
        overlayLayer.addChild(title)

        let tip = SKLabelNode(fontNamed: "AvenirNext-Medium")
        tip.text = result == .win ? "game_scene_win_tip".localized : "game_scene_lose_tip".localized
        tip.fontSize = scaled(28)
        tip.fontColor = .white
        tip.horizontalAlignmentMode = .center
        tip.verticalAlignmentMode = .center
        tip.position = CGPoint(x: size.width / 2, y: size.height / 2 - scaled(40))
        tip.zPosition = 1
        overlayLayer.addChild(tip)

        reportResultIfNeeded()
    }

    private func reportResultIfNeeded() {
        guard !didReportResult else { return }
        didReportResult = true
        let summary = GameRunSummary(
            level: levelDescriptor,
            didWin: gameStatus == .win,
            moves: moveCount,
            duration: Date().timeIntervalSince(startedAt),
            remainingScrews: max(0, totalScrews - removedCount)
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) { [onFinish] in
            onFinish(summary)
        }
    }

    // 道具 1：撤销 (将备选区的最后一个螺丝送回板子上)
    func useUndoItem() -> Bool {
        guard gameStatus == .playing, !isBusy else { return false }
        guard let screw = buffer.last else { return false }
        
        isBusy = true
        _ = buffer.popLast()
        
        // 重新规划备选区位置
        reflowBufferPositions()
        
        // 查找板子
        guard let board = boards.first(where: { $0.id == screw.originalBoardId }) else {
            isBusy = false
            return false
        }
        
        // 如果板子之前被隐去了，将其重新激活
        let boardWasRemoved = board.removed
        if boardWasRemoved {
            board.removed = false
            redrawBoards()
        }
        
        // 还原螺丝属性
        screw.boardId = screw.originalBoardId
        screw.offset = screw.originalOffset
        screw.bufferSlot = nil
        board.screws.append(screw)
        removedCount -= 1
        
        // 还原场景节点
        if let node = screw.node {
            let targetPoint = screwPoint(screw, board: board)
            
            // 播放飞回板子的动画
            node.run(.sequence([
                .group([
                    .move(to: targetPoint, duration: 0.32),
                    .scale(to: 1.0, duration: 0.32),
                    .rotate(byAngle: -.pi, duration: 0.32)
                ]),
                .run { [weak self, weak node, weak screw] in
                    guard let self, let node, let screw else { return }
                    // 重新加入节点名称词典，绑定事件
                    node.name = "screw:\(screw.id)"
                    node.zPosition = CGFloat(board.z) + 100
                    self.screwByNodeName[node.name ?? ""] = screw
                    
                    self.recomputeOcclusion()
                    self.refreshHUD()
                    self.isBusy = false
                }
            ]))
        } else {
            // 防御：若节点丢失，直接重构场景
            rebuildSceneForCurrentState()
            isBusy = false
        }
        
        return true
    }
    
    // 道具 2：清空备选区
    func useClearBufferItem() -> Bool {
        guard gameStatus == .playing, !isBusy else { return false }
        guard !buffer.isEmpty else { return false }
        
        isBusy = true
        
        // 取出所有备选区节点进行消除动画
        for screw in buffer {
            if let node = screw.node {
                let flash = SKShapeNode(circleOfRadius: scaled(GameConstants.screwRadius))
                flash.position = node.position
                flash.fillColor = .white
                flash.strokeColor = .clear
                flash.zPosition = 200
                bufferLayer.addChild(flash)
                
                flash.run(.sequence([
                    .group([.fadeOut(withDuration: 0.22), .scale(to: 1.3, duration: 0.22)]),
                    .removeFromParent()
                ]))
                node.removeFromParent()
            }
        }
        
        buffer.removeAll()
        refreshHUD()
        isBusy = false
        return true
    }
}
