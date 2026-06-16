import MediaPlayer
import SwiftUI
import UIKit

/// Reads (and controls) playback from the system Music player — i.e. the Apple Music app.
/// Note: this is Apple Music only; iOS has no public API to read Spotify/Podcasts playback.
@MainActor
final class NowPlayingService: ObservableObject {
    @Published var title: String?
    @Published var artist: String?
    @Published var artwork: UIImage?
    @Published var isPlaying = false

    private let player = MPMusicPlayerController.systemMusicPlayer
    private var observing = false

    var hasTrack: Bool { title != nil }

    func start() {
        MPMediaLibrary.requestAuthorization { [weak self] status in
            Task { @MainActor in
                guard status == .authorized else { return }
                self?.activate()
            }
        }
    }

    private func activate() {
        guard !observing else { return }
        observing = true
        player.beginGeneratingPlaybackNotifications()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(refresh),
                       name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
        nc.addObserver(self, selector: #selector(refresh),
                       name: .MPMusicPlayerControllerPlaybackStateDidChange, object: player)
        refresh()
    }

    @objc private func refresh() {
        Task { @MainActor in
            let item = player.nowPlayingItem
            withAnimation(.easeInOut(duration: 0.7)) {
                title = item?.title
                artist = item?.artist
                artwork = item?.artwork?.image(at: CGSize(width: 120, height: 120))
                isPlaying = (player.playbackState == .playing)
            }
        }
    }

    func playPause() { isPlaying ? player.pause() : player.play() }
    func next() { player.skipToNextItem() }
    func previous() { player.skipToPreviousItem() }
}
