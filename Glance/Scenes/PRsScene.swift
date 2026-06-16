import SwiftUI

struct PRsScene: View {
    let prs: [PullRequest]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("My open PRs", systemImage: "arrow.triangle.pull")
                .font(.title2.weight(.bold))
                .foregroundStyle(Theme.accent)
            ForEach(prs.prefix(8)) { pr in
                HStack(spacing: 14) {
                    Image(systemName: pr.draft ? "circle.dashed" : "arrow.triangle.pull")
                        .foregroundStyle(pr.draft ? Theme.secondary : Theme.accent)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pr.title)
                            .font(.title3.weight(.medium))
                            .lineLimit(1)
                        Text("\(pr.repo) #\(pr.number)")
                            .font(.caption)
                            .foregroundStyle(Theme.secondary)
                    }
                    Spacer()
                    Text(pr.updatedAt, format: .relative(presentation: .named))
                        .font(.caption)
                        .foregroundStyle(Theme.secondary)
                }
                .padding(.vertical, 4)
                Divider().overlay(Theme.stroke)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .foregroundStyle(Theme.primary)
    }
}
