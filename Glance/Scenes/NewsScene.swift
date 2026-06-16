import SwiftUI

struct NewsScene: View {
    let items: [NewsItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("Hacker News", systemImage: "newspaper.fill")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.accent)
            ForEach(items.prefix(7)) { item in
                Link(destination: item.link) {
                    HStack(alignment: .top, spacing: 16) {
                        Text("\(item.points)")
                            .font(.headline.monospacedDigit())
                            .foregroundStyle(Theme.accent)
                            .frame(width: 56, alignment: .trailing)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.title)
                                .font(.title3.weight(.medium))
                                .lineLimit(2)
                            if let host = item.host {
                                Text(host).font(.caption).foregroundStyle(Theme.secondary)
                            }
                        }
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(Theme.secondary)
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                Divider().overlay(Theme.stroke)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .foregroundStyle(Theme.primary)
    }
}

private extension NewsItem {
    var host: String? {
        guard let s = url, let h = URL(string: s)?.host else { return nil }
        return h.replacingOccurrences(of: "www.", with: "")
    }

    /// Open the article if it has one, otherwise the HN comments page.
    var link: URL {
        if let s = url, let u = URL(string: s) { return u }
        return URL(string: commentsURL) ?? URL(string: "https://news.ycombinator.com")!
    }
}
