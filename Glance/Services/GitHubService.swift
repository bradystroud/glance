import Foundation

enum GitHubService {
    static func fetchOpenPRs(username: String, token: String) async -> [PullRequest] {
        guard !username.isEmpty else { return [] }
        var comp = URLComponents(string: "https://api.github.com/search/issues")!
        comp.queryItems = [
            .init(name: "q", value: "is:pr author:\(username) is:open"),
            .init(name: "sort", value: "updated"),
            .init(name: "order", value: "desc"),
            .init(name: "per_page", value: "15"),
        ]
        guard let url = comp.url else { return [] }

        var req = URLRequest(url: url)
        req.setValue("application/vnd.github+json", forHTTPHeaderField: "Accept")
        req.setValue("Glance-Dashboard", forHTTPHeaderField: "User-Agent") // GitHub requires a UA
        if !token.isEmpty {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        guard let (data, _) = try? await URLSession.shared.data(for: req),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let items = json["items"] as? [[String: Any]] else { return [] }

        let fmt = ISO8601DateFormatter()
        return items.compactMap { it in
            guard let id = it["id"] as? Int,
                  let title = it["title"] as? String,
                  let number = it["number"] as? Int,
                  let htmlURL = it["html_url"] as? String else { return nil }
            return PullRequest(
                id: id,
                title: title,
                number: number,
                repo: repoName(from: htmlURL),
                url: htmlURL,
                draft: it["draft"] as? Bool ?? false,
                updatedAt: fmt.date(from: it["updated_at"] as? String ?? "") ?? Date()
            )
        }
    }

    /// https://github.com/owner/repo/pull/123 -> "owner/repo"
    private static func repoName(from htmlURL: String) -> String {
        let parts = htmlURL
            .replacingOccurrences(of: "https://github.com/", with: "")
            .split(separator: "/")
        return parts.count >= 2 ? "\(parts[0])/\(parts[1])" : ""
    }
}
