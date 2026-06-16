import SwiftUI

/// 收藏界面，展示已解锁的收藏品列表，以及每个收藏品的详细信息
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
