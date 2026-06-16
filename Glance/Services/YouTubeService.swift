import Foundation

enum YouTubeService {
    static func fetch(channelIDs: [String]) async -> [VideoItem] {
        guard !channelIDs.isEmpty else { return [] }
        var all: [VideoItem] = []
        await withTaskGroup(of: [VideoItem].self) { group in
            for id in channelIDs { group.addTask { await fetchChannel(id) } }
            for await items in group { all.append(contentsOf: items) }
        }
        return Array(all.sorted { $0.published > $1.published }.prefix(12))
    }

    private static func fetchChannel(_ channelID: String) async -> [VideoItem] {
        let url = URL(string: "https://www.youtube.com/feeds/videos.xml?channel_id=\(channelID)")!
        guard let (data, _) = try? await URLSession.shared.data(from: url) else { return [] }
        return AtomParser().parse(data)
    }
}

/// Minimal Atom feed parser for YouTube channel feeds.
private final class AtomParser: NSObject, XMLParserDelegate {
    private var items: [VideoItem] = []
    private var current: [String: String] = [:]
    private var feedChannel = ""
    private var element = ""
    private var inEntry = false
    private let fmt = ISO8601DateFormatter()

    func parse(_ data: Data) -> [VideoItem] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return items
    }

    func parser(_ parser: XMLParser, didStartElement el: String, namespaceURI: String?,
                qualifiedName qn: String?, attributes: [String: String] = [:]) {
        element = el
        if el == "entry" { inEntry = true; current = [:] }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let s = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !s.isEmpty else { return }
        switch element {
        case "title": current["title", default: ""] += s
        case "yt:videoId": current["videoId", default: ""] += s
        case "published": current["published", default: ""] += s
        case "name":
            if inEntry { current["channel", default: ""] += s } else { feedChannel += s }
        default: break
        }
    }

    func parser(_ parser: XMLParser, didEndElement el: String, namespaceURI: String?,
                qualifiedName qn: String?) {
        if el == "entry" {
            inEntry = false
            if let vid = current["videoId"], !vid.isEmpty, let title = current["title"] {
                let published = fmt.date(from: current["published"] ?? "") ?? Date.distantPast
                items.append(VideoItem(id: vid, title: title,
                                       channel: current["channel"] ?? feedChannel,
                                       published: published))
            }
        }
        element = ""
    }
}
