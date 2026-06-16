import SwiftUI

@MainActor
final class DashboardStore: ObservableObject {
    @Published var weather: Weather?
    @Published var news: [NewsItem] = []
    @Published var videos: [VideoItem] = []
    @Published var prs: [PullRequest] = []
    @Published var now = Date()

    private var clock: Timer?
    private var refresh: Timer?

    func start() {
        Task { await refreshAll() }
        clock = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.now = Date() }
        }
        refresh = Timer.scheduledTimer(withTimeInterval: AppSettings.refreshInterval, repeats: true) { [weak self] _ in
            Task { await self?.refreshAll() }
        }
    }

    /// Re-fetch immediately (e.g. after settings change).
    func reload() {
        Task { await refreshAll() }
    }

    func refreshAll() async {
        async let w = WeatherService.fetch(latitude: AppSettings.latitude, longitude: AppSettings.longitude)
        async let n = NewsService.fetch()
        async let v = YouTubeService.fetch(channelIDs: AppSettings.youtubeChannelIDs)
        async let p = GitHubService.fetchOpenPRs(username: AppSettings.githubUsername, token: AppSettings.githubToken)
        let (weather, news, videos, prs) = await (w, n, v, p)
        if let weather { self.weather = weather }
        if !news.isEmpty { self.news = news }
        if !videos.isEmpty { self.videos = videos }
        self.prs = prs
    }
}
