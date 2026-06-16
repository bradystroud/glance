import SwiftUI

enum DashScene: Int, CaseIterable {
    case photos, weather, news, youtube, prs
}

struct ContentView: View {
    @StateObject private var store = DashboardStore()
    @StateObject private var photos = PhotoService()
    @StateObject private var nowPlaying = NowPlayingService()
    @State private var scene: DashScene = .photos
    @State private var rotator: Timer?
    @State private var cycleStart = Date()   // start of the current dashboard cycle
    @State private var showSettings = false

    var body: some View {
        ZStack {
            Theme.bg.ignoresSafeArea()
            VStack(spacing: 20) {
                HeaderBar(now: store.now, weather: store.weather)
                Group {
                    switch scene {
                    case .photos:  PhotosScene(photos: photos)
                    case .weather: WeatherScene(weather: store.weather)
                    case .news:    NewsScene(items: store.news)
                    case .youtube: YouTubeScene(videos: store.videos)
                    case .prs:     PRsScene(prs: store.prs)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(.opacity)
                .id(scene)
                SceneDots(active: scene, available: activeScenes())
            }
            .padding(28)
        }
        // Left / right edges rotate dashboards. Top / bottom (photo scene only) rotate photos.
        .overlay {
            HStack(spacing: 0) {
                edgeZone { prevDashboard() }
                if scene == .photos {
                    VStack(spacing: 0) {
                        fillZone { prevPhoto() }   // top
                        fillZone { nextPhoto() }   // bottom
                    }
                } else {
                    Spacer(minLength: 0)
                }
                edgeZone { nextDashboard() }
            }
            .ignoresSafeArea()
        }
        // Soothing countdown to the next dashboard rotation.
        .overlay {
            VStack(spacing: 0) {
                Spacer(minLength: 0)
                RotationProgressBar(cycleStart: cycleStart, duration: AppSettings.sceneDuration)
                    .padding(.horizontal, -24)   // run a touch past both screen edges
            }
            .ignoresSafeArea()                   // full-screen layer → bar pins to true bottom
        }
        // Now Playing sits on top so its controls always win the tap.
        .overlay(alignment: .bottomTrailing) {
            NowPlayingWidget(np: nowPlaying)
                .padding(.trailing, 28)
                .padding(.bottom, 56)   // clear of the progress bar
        }
        // Subtle settings button (above the tap zones so it wins its own taps).
        .overlay(alignment: .bottomLeading) {
            Button { showSettings = true } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundStyle(Theme.secondary)
                    .padding(12)
                    .background(.ultraThinMaterial, in: Circle())
            }
            .buttonStyle(.plain)
            .opacity(0.55)
            .padding(.leading, 24)
            .padding(.bottom, 48)
        }
        .sheet(isPresented: $showSettings, onDismiss: applySettings) {
            SettingsView()
        }
        // Hardware arrow keys (Magic Keyboard) mirror the touch zones.
        .background {
            KeyCommands(onLeft: prevDashboard, onRight: nextDashboard,
                        onUp: prevPhoto, onDown: nextPhoto)
        }
        .onAppear {
            UIApplication.shared.isIdleTimerDisabled = true   // keep the screen awake
            store.start()
            photos.requestAccess()
            nowPlaying.start()
            let scenes = activeScenes()
            if !scenes.contains(scene) { scene = scenes.first ?? .photos }
            startRotation()
        }
        .onDisappear {
            UIApplication.shared.isIdleTimerDisabled = false
            rotator?.invalidate()
        }
    }

    // MARK: Navigation

    private func nextDashboard() { step(+1); startRotation() }
    private func prevDashboard() { step(-1); startRotation() }

    private func nextPhoto() {
        guard scene == .photos else { return }
        photos.advance(); startRotation()
    }
    private func prevPhoto() {
        guard scene == .photos else { return }
        photos.retreat(); startRotation()
    }

    private func step(_ direction: Int) {
        let scenes = activeScenes()
        guard !scenes.isEmpty else { return }
        let idx = scenes.firstIndex(of: scene) ?? 0
        withAnimation(.easeInOut(duration: 1.2)) {
            scene = scenes[(idx + direction + scenes.count) % scenes.count]
        }
    }

    private func startRotation() {
        rotator?.invalidate()
        restartCountdown()
        rotator = Timer.scheduledTimer(withTimeInterval: AppSettings.sceneDuration, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.4)) { step(+1) }
            restartCountdown()
        }
    }

    /// Re-apply settings after the sheet closes: validate current page, restart timing, refetch.
    private func applySettings() {
        let scenes = activeScenes()
        if !scenes.contains(scene) { scene = scenes.first ?? .photos }
        startRotation()
        store.reload()
    }

    /// Reset the cycle clock; the wave bar drains itself from this timestamp.
    private func restartCountdown() {
        cycleStart = Date()
    }

    /// Full-height strip down a screen edge.
    private func edgeZone(action: @escaping () -> Void) -> some View {
        Color.clear
            .frame(width: 110)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
    }

    /// Fills whatever space it's given (used for the top/bottom photo zones).
    private func fillZone(action: @escaping () -> Void) -> some View {
        Color.clear
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onTapGesture(perform: action)
    }

    /// Skip scenes that currently have nothing to show.
    private func activeScenes() -> [DashScene] {
        DashScene.allCases.filter { s in
            switch s {
            case .photos:  return AppSettings.showPhotos
            case .weather: return AppSettings.showWeather
            case .news:    return AppSettings.showNews && !store.news.isEmpty
            case .youtube: return AppSettings.showYouTube && !store.videos.isEmpty
            case .prs:     return AppSettings.showPRs && !store.prs.isEmpty
            }
        }
    }
}

struct HeaderBar: View {
    let now: Date
    let weather: Weather?

    var body: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text(now, format: .dateTime.hour().minute())
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .monospacedDigit()
                Text(now.formatted(.dateTime.weekday(.wide).day().month(.wide)))
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Theme.secondary)
            }
            Spacer()
            if let w = weather {
                HStack(spacing: 14) {
                    Image(systemName: w.symbol)
                        .symbolRenderingMode(.multicolor)
                        .font(.system(size: 44))
                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(Int(w.temperature.rounded()))°")
                            .font(.system(size: 44, weight: .semibold, design: .rounded))
                        Text("H:\(Int(w.high.rounded()))°  L:\(Int(w.low.rounded()))°")
                            .font(.callout)
                            .foregroundStyle(Theme.secondary)
                    }
                }
            }
        }
        .foregroundStyle(Theme.primary)
    }
}

struct SceneDots: View {
    let active: DashScene
    let available: [DashScene]
    var body: some View {
        HStack(spacing: 8) {
            ForEach(available, id: \.rawValue) { s in
                Circle()
                    .fill(s == active ? Theme.primary : Theme.stroke)
                    .frame(width: 8, height: 8)
            }
        }
    }
}

/// Flowing wave that drains over a dashboard cycle.
struct RotationProgressBar: View {
    let cycleStart: Date
    let duration: TimeInterval

    /// Soothing left-to-right gradient revealed as the wave fills.
    static let waveColors: [Color] = [
        Color(red: 0.36, green: 0.84, blue: 0.80),   // teal
        Color(red: 0.39, green: 0.71, blue: 1.00),   // blue
        Color(red: 0.60, green: 0.52, blue: 0.96),   // soft violet
    ]

    var body: some View {
        TimelineView(.animation) { context in
            let elapsed = context.date.timeIntervalSince(cycleStart)
            let progress = max(0, min(1, elapsed / duration))   // fills forward to next rotation
            let phase = context.date.timeIntervalSinceReferenceDate * 1.4   // gentle flow speed

            Canvas { ctx, size in
                // everything below only paints the elapsed portion (no track background)
                let fillWidth = size.width * progress
                ctx.clip(to: Path(CGRect(x: 0, y: 0, width: fillWidth, height: size.height)))

                // back ripple (fainter, offset phase) + front wave for depth
                ctx.fill(wave(size: size, phase: phase + 1.1, amplitude: 5, wavelength: 32),
                         with: .linearGradient(
                            Gradient(colors: [Self.waveColors.first!.opacity(0.3),
                                              Self.waveColors.last!.opacity(0.3)]),
                            startPoint: .zero, endPoint: CGPoint(x: size.width, y: 0)))
                ctx.fill(wave(size: size, phase: phase, amplitude: 7, wavelength: 44),
                         with: .linearGradient(
                            Gradient(colors: Self.waveColors),
                            startPoint: .zero, endPoint: CGPoint(x: size.width, y: 0)))
            }
        }
        .frame(height: 32)
    }

    /// Sine waveform filled down to the bottom edge.
    private func wave(size: CGSize, phase: Double, amplitude: Double, wavelength: Double) -> Path {
        var p = Path()
        let midY = Double(size.height) * 0.5
        let w = Double(size.width)
        p.move(to: CGPoint(x: 0, y: Double(size.height)))
        var x = 0.0
        while x <= w {
            let y = midY + amplitude * sin(phase + x / wavelength)
            p.addLine(to: CGPoint(x: x, y: y))
            x += 2
        }
        p.addLine(to: CGPoint(x: w, y: Double(size.height)))
        p.closeSubpath()
        return p
    }
}
