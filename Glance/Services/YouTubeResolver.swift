import Foundation

/// Turns a pasted channel URL, @handle, or raw "UC…" ID into a (channelID, name) pair.
enum YouTubeResolver {
    static func resolve(_ input: String) async -> Channel? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        var channelID = directID(trimmed)
        if channelID == nil { channelID = await scrapeID(trimmed) }
        guard let id = channelID, let name = await channelName(id) else { return nil }
        return Channel(id: id, name: name)
    }

    /// A bare UC… id, or a /channel/UC… URL.
    private static func directID(_ s: String) -> String? {
        firstMatch(#"UC[A-Za-z0-9_-]{22}"#, in: s, group: 0)
    }

    /// Fetch a handle/custom URL's HTML and pull the canonical channelId out.
    private static func scrapeID(_ input: String) async -> String? {
        var urlString = input
        if !input.lowercased().hasPrefix("http") {
            let handle = input.hasPrefix("@") ? input : "@\(input)"
            urlString = "https://www.youtube.com/\(handle)"
        }
        guard let url = URL(string: urlString),
              let (data, _) = try? await URLSession.shared.data(from: url),
              let html = String(data: data, encoding: .utf8) else { return nil }
        return firstMatch(#"(?:channelId|externalId)":"(UC[A-Za-z0-9_-]{22})"#, in: html, group: 1)
    }

    /// The channel's display name is the feed's first <title>.
    private static func channelName(_ id: String) async -> String? {
        let url = URL(string: "https://www.youtube.com/feeds/videos.xml?channel_id=\(id)")!
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let xml = String(data: data, encoding: .utf8),
              let raw = firstMatch(#"<title>([^<]*)</title>"#, in: xml, group: 1) else { return nil }
        let name = decodeEntities(raw)
        return name.isEmpty ? nil : name
    }

    private static func firstMatch(_ pattern: String, in text: String, group: Int) -> String? {
        guard let re = try? NSRegularExpression(pattern: pattern) else { return nil }
        let range = NSRange(text.startIndex..., in: text)
        guard let m = re.firstMatch(in: text, range: range),
              m.numberOfRanges > group,
              let r = Range(m.range(at: group), in: text) else { return nil }
        return String(text[r])
    }

    private static func decodeEntities(_ s: String) -> String {
        s.replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#39;", with: "'")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
