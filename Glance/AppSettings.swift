import Foundation

/// Reads the live, user-editable settings from UserDefaults (written by SettingsView's
/// @AppStorage). Keys and defaults must match those in SettingsView.
enum AppSettings {
    private static var d: UserDefaults { .standard }

    // Pages
    static var showPhotos: Bool  { d.object(forKey: Keys.showPhotos)  as? Bool ?? true }
    static var showWeather: Bool { d.object(forKey: Keys.showWeather) as? Bool ?? true }
    static var showNews: Bool    { d.object(forKey: Keys.showNews)    as? Bool ?? true }
    static var showYouTube: Bool { d.object(forKey: Keys.showYouTube) as? Bool ?? true }
    static var showPRs: Bool     { d.object(forKey: Keys.showPRs)     as? Bool ?? true }

    // Weather
    static var latitude: Double  { d.object(forKey: Keys.latitude)  as? Double ?? Config.defaultLatitude }
    static var longitude: Double { d.object(forKey: Keys.longitude) as? Double ?? Config.defaultLongitude }
    static var placeName: String {
        let v = d.string(forKey: Keys.placeName) ?? ""
        return v.isEmpty ? Config.defaultPlaceName : v
    }

    // GitHub
    static var githubUsername: String {
        let v = d.string(forKey: Keys.githubUsername) ?? ""
        return v.isEmpty ? Config.defaultGithubUsername : v
    }
    static var githubToken: String { d.string(forKey: Keys.githubToken) ?? "" }

    // YouTube
    static var youtubeChannelsRaw: String { d.string(forKey: Keys.youtubeChannels) ?? Config.defaultYoutubeChannels }
    static var youtubeChannelIDs: [String] { Config.parseChannels(youtubeChannelsRaw) }

    // Timings
    static var sceneDuration: TimeInterval { let v = d.double(forKey: Keys.sceneDuration); return v > 0 ? v : Config.defaultSceneDuration }
    static var photoDuration: TimeInterval { let v = d.double(forKey: Keys.photoDuration); return v > 0 ? v : Config.defaultPhotoDuration }
    static var refreshInterval: TimeInterval {
        let m = d.double(forKey: Keys.refreshMinutes)
        return (m > 0 ? m : Config.defaultRefreshMinutes) * 60
    }

    enum Keys {
        static let showPhotos = "showPhotos"
        static let showWeather = "showWeather"
        static let showNews = "showNews"
        static let showYouTube = "showYouTube"
        static let showPRs = "showPRs"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let placeName = "placeName"
        static let githubUsername = "githubUsername"
        static let githubToken = "githubToken"
        static let youtubeChannels = "youtubeChannelsRaw"
        static let sceneDuration = "sceneDuration"
        static let photoDuration = "photoDuration"
        static let refreshMinutes = "refreshMinutes"
    }
}
