import Foundation

struct NewsItem: Identifiable {
    let id: String
    let title: String
    let url: String?
    let points: Int
    let author: String
    let commentsURL: String
}

struct VideoItem: Identifiable {
    let id: String          // YouTube videoId
    let title: String
    let channel: String
    let published: Date
    var thumbnailURL: URL { URL(string: "https://i.ytimg.com/vi/\(id)/maxresdefault.jpg")! }   // 1280×720 16:9
    var fallbackThumbnailURL: URL { URL(string: "https://i.ytimg.com/vi/\(id)/hqdefault.jpg")! }
    var watchURL: URL { URL(string: "https://www.youtube.com/watch?v=\(id)")! }
}

struct Channel: Identifiable, Hashable {
    let id: String      // "UC…"
    var name: String
}

struct PullRequest: Identifiable {
    let id: Int
    let title: String
    let number: Int
    let repo: String
    let url: String
    let draft: Bool
    let updatedAt: Date
}

struct Weather {
    let temperature: Double
    let apparent: Double
    let code: Int
    let humidity: Int
    let windSpeed: Double
    let high: Double
    let low: Double
    let sunrise: Date?
    let sunset: Date?
    let uvIndex: Double
    let precipChance: Int
    let hourly: [HourForecast]
    let daily: [DayForecast]

    var symbol: String { WeatherCode.symbol(code) }
    var summary: String { WeatherCode.describe(code) }
}

struct HourForecast: Identifiable {
    let id: Int
    let date: Date
    let temp: Double
    let code: Int
    var symbol: String { WeatherCode.symbol(code) }
}

struct DayForecast: Identifiable {
    let id: Int
    let date: Date
    let high: Double
    let low: Double
    let code: Int
    var symbol: String { WeatherCode.symbol(code) }
}

/// Maps WMO weather codes to SF Symbols + text.
enum WeatherCode {
    static func symbol(_ code: Int) -> String {
        switch code {
        case 0: return "sun.max.fill"
        case 1, 2: return "cloud.sun.fill"
        case 3: return "cloud.fill"
        case 45, 48: return "cloud.fog.fill"
        case 51...57: return "cloud.drizzle.fill"
        case 61...67, 80...82: return "cloud.rain.fill"
        case 71...77, 85, 86: return "cloud.snow.fill"
        case 95...99: return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }
    static func describe(_ code: Int) -> String {
        switch code {
        case 0: return "Clear"
        case 1: return "Mainly clear"
        case 2: return "Partly cloudy"
        case 3: return "Overcast"
        case 45, 48: return "Fog"
        case 51...57: return "Drizzle"
        case 61...67: return "Rain"
        case 71...77: return "Snow"
        case 80...82: return "Showers"
        case 85, 86: return "Snow showers"
        case 95...99: return "Thunderstorm"
        default: return "—"
        }
    }
}
