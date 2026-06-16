import SwiftUI

/// Compact "now playing" pill. Hidden when nothing is playing.
struct NowPlayingWidget: View {
    @ObservedObject var np: NowPlayingService

    var body: some View {
        if np.hasTrack {
            HStack(spacing: 12) {
                artwork
                VStack(alignment: .leading, spacing: 2) {
                    Text(np.title ?? "")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Theme.primary)
                        .lineLimit(1)
                    Text(np.artist ?? "")
                        .font(.caption)
                        .foregroundStyle(Theme.secondary)
                        .lineLimit(1)
                }
                .frame(width: 170, alignment: .leading)

                HStack(spacing: 18) {
                    control("backward.fill") { np.previous() }
                    control(np.isPlaying ? "pause.fill" : "play.fill") { np.playPause() }
                    control("forward.fill") { np.next() }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 14)
            .background(.regularMaterial, in: Capsule())   // opaque enough to read over photos
            .overlay(Capsule().strokeBorder(Theme.stroke))
            .shadow(color: .black.opacity(0.45), radius: 14, y: 6)
            .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    @ViewBuilder private var artwork: some View {
        ZStack {
            if let art = np.artwork {
                Image(uiImage: art)
                    .resizable()
                    .scaledToFill()
            } else {
                Theme.card
                Image(systemName: "music.note").foregroundStyle(Theme.secondary)
            }
        }
        .frame(width: 48, height: 48)
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .overlay(alignment: .bottomTrailing) {
            if np.isPlaying {
                EqualizerBars()
                    .padding(4)
            }
        }
    }

    private func control(_ icon: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(Theme.primary)
                .frame(width: 36, height: 36)
        }
        .buttonStyle(.plain)
    }
}

/// Three little bars that bounce while playing.
private struct EqualizerBars: View {
    @State private var animate = false
    private let heights: [CGFloat] = [6, 12, 8]

    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            ForEach(heights.indices, id: \.self) { i in
                Capsule()
                    .fill(Theme.accent)
                    .frame(width: 2.5, height: animate ? heights[i] : 3)
                    .animation(.easeInOut(duration: 0.8 + Double(i) * 0.2)
                        .repeatForever(autoreverses: true), value: animate)
            }
        }
        .padding(3)
        .background(.black.opacity(0.45), in: RoundedRectangle(cornerRadius: 4))
        .onAppear { animate = true }
    }
}
