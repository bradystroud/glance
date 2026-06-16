import SwiftUI

struct LocationPickerView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("latitude")  private var latitude = Config.defaultLatitude
    @AppStorage("longitude") private var longitude = Config.defaultLongitude
    @AppStorage("placeName") private var placeName = Config.defaultPlaceName

    @State private var query = ""
    @State private var results: [GeoResult] = []
    @State private var searching = false

    var body: some View {
        List {
            Section {
                LabeledContent("Current", value: placeName)
            }
            if !results.isEmpty {
                Section("Results") {
                    ForEach(results) { r in
                        Button { select(r) } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(r.name).foregroundStyle(.primary)
                                if !r.subtitle.isEmpty {
                                    Text(r.subtitle).font(.caption).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            } else if query.count >= 2 && !searching {
                Section { Text("No matches").foregroundStyle(.secondary) }
            }
        }
        .searchable(text: $query, prompt: "Search for a city")
        .task(id: query) {
            results = []
            guard query.trimmingCharacters(in: .whitespaces).count >= 2 else { return }
            searching = true
            try? await Task.sleep(for: .milliseconds(300))   // debounce
            if Task.isCancelled { return }
            results = await GeocodingService.search(query)
            searching = false
        }
        .navigationTitle("Weather location")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func select(_ r: GeoResult) {
        latitude = r.latitude
        longitude = r.longitude
        placeName = r.displayName
        dismiss()
    }
}
