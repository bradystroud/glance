import Foundation

struct GeoResult: Identifiable, Decodable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let country: String?
    let admin1: String?            // state / region

    var subtitle: String {
        [admin1, country].compactMap { $0 }.joined(separator: ", ")
    }
    var displayName: String {
        [name, country].compactMap { $0 }.joined(separator: ", ")
    }
}

/// City search via Open-Meteo's free geocoding API (no key).
enum GeocodingService {
    static func search(_ query: String) async -> [GeoResult] {
        let q = query.trimmingCharacters(in: .whitespaces)
        guard q.count >= 2 else { return [] }

        var c = URLComponents(string: "https://geocoding-api.open-meteo.com/v1/search")!
        c.queryItems = [
            .init(name: "name", value: q),
            .init(name: "count", value: "10"),
            .init(name: "language", value: "en"),
            .init(name: "format", value: "json"),
        ]
        guard let url = c.url,
              let (data, _) = try? await URLSession.shared.data(from: url) else { return [] }

        struct Response: Decodable { let results: [GeoResult]? }
        return (try? JSONDecoder().decode(Response.self, from: data))?.results ?? []
    }
}
