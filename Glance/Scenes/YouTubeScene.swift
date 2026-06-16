import SwiftUI

struct YouTubeScene: View {
    let videos: [VideoItem]
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 16), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("New on YouTube", systemImage: "play.rectangle.fill")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.accent)
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(videos.prefix(6)) { v in
                    Link(destination: v.watchURL) {
                        VStack(alignment: .leading, spacing: 8) {
                            thumbnail(for: v)
                            Text(v.title)
                                .font(.headline)
                                .lineLimit(2)
                                .foregroundStyle(Theme.primary)
                            Text(v.channel)
                                .font(.caption)
                                .foregroundStyle(Theme.secondary)
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    /// True 16:9 tile: maxres thumbnail, falling back to hqdefault when missing.
    private func thumbnail(for v: VideoItem) -> some View {
        Color.clear
            .aspectRatio(16.0 / 9.0, contentMode: .fit)
            .overlay {
                AsyncImage(url: v.thumbnailURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().scaledToFill()
                    case .failure:
                        AsyncImage(url: v.fallbackThumbnailURL) { fb in
                            if let image = fb.image {
                                image.resizable().scaledToFill()
                            } else {
                                Theme.card
                            }
                        }
                    default:
                        Theme.card
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay {
                Image(systemName: "play.circle.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(radius: 8)
            }
    }
}
