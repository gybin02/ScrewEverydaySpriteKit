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
