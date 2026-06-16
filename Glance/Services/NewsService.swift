import Foundation

enum NewsService {
    static func fetch() async -> [NewsItem] {
        let url = URL(string: "https://hn.algolia.com/api/v1/search?tags=front_page&hitsPerPage=15")!
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let hits = json["hits"] as? [[String: Any]] else { return [] }

        return hits.compactMap { h in
            guard let id = h["objectID"] as? String,
                  let title = h["title"] as? String else { return nil }
            return NewsItem(
                id: id,
                title: title,
                url: h["url"] as? String,
                points: h["points"] as? Int ?? 0,
                author: h["author"] as? String ?? "",
                commentsURL: "https://news.ycombinator.com/item?id=\(id)"
            )
        }
    }
}
