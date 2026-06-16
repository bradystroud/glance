import SwiftUI

struct PhotosScene: View {
    @ObservedObject var photos: PhotoService
    @State private var timer: Timer?

    var body: some View {
        GeometryReader { geo in
            content(in: geo.size)
                .frame(width: geo.size.width, height: geo.size.height)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        }
        .onAppear {
            photos.advance()   // fresh page each time the scene comes round
            timer = Timer.scheduledTimer(withTimeInterval: AppSettings.photoDuration, repeats: true) { _ in
                Task { @MainActor in photos.advance() }
            }
        }
        .onDisappear { timer?.invalidate() }
    }

    @ViewBuilder
    private func content(in size: CGSize) -> some View {
        if !photos.images.isEmpty {
            let spacing: CGFloat = 6
            let count = CGFloat(photos.images.count)
            let cellWidth = (size.width - spacing * (count - 1)) / count
            HStack(spacing: spacing) {
                ForEach(Array(photos.images.enumerated()), id: \.offset) { _, img in
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(width: cellWidth, height: size.height)   // exact — can't overflow
                        .clipped()
                }
            }
            .id(photos.token)              // changing id + crossfade = smooth transition
            .transition(.opacity)
        } else if !photos.authorized {
            ContentUnavailableView("Photo access needed",
                systemImage: "photo.on.rectangle",
                description: Text("Allow photo access so Glance can show your library."))
                .frame(width: size.width, height: size.height)
        } else {
            ProgressView()
                .tint(Theme.secondary)
                .frame(width: size.width, height: size.height)
        }
    }
}
