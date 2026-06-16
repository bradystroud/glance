import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    // Keys & defaults must match AppSettings.
    @AppStorage("showPhotos")  private var showPhotos = true
    @AppStorage("showWeather") private var showWeather = true
    @AppStorage("showNews")    private var showNews = true
    @AppStorage("showYouTube") private var showYouTube = true
    @AppStorage("showPRs")     private var showPRs = true

    @AppStorage("placeName") private var placeName = Config.defaultPlaceName

    @AppStorage("githubUsername") private var githubUsername = Config.defaultGithubUsername
    @AppStorage("githubToken")    private var githubToken = ""

    @AppStorage("youtubeChannelsRaw") private var youtubeChannels = Config.defaultYoutubeChannels

    @AppStorage("sceneDuration")  private var sceneDuration = Config.defaultSceneDuration
    @AppStorage("photoDuration")  private var photoDuration = Config.defaultPhotoDuration
    @AppStorage("refreshMinutes") private var refreshMinutes = Config.defaultRefreshMinutes

    var body: some View {
        NavigationStack {
            Form {
                Section("Pages") {
                    Toggle("Photos", isOn: $showPhotos)
                    Toggle("Weather", isOn: $showWeather)
                    Toggle("Hacker News", isOn: $showNews)
                    Toggle("YouTube", isOn: $showYouTube)
                    Toggle("My open PRs", isOn: $showPRs)
                }

                Section("Weather") {
                    NavigationLink {
                        LocationPickerView()
                    } label: {
                        LabeledContent("Location", value: placeName)
                    }
                }

                Section("GitHub") {
                    TextField("Username", text: $githubUsername)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                    SecureField("Token (optional)", text: $githubToken)
                    Text("A read-only token raises rate limits and includes private PRs. Stored only on this device.")
                        .font(.footnote).foregroundStyle(.secondary)
                }

                Section("YouTube") {
                    NavigationLink {
                        ChannelSettingsView()
                    } label: {
                        LabeledContent("Channels", value: "\(Config.parseChannels(youtubeChannels).count)")
                    }
                }

                Section("Timing") {
                    Stepper("Page duration: \(Int(sceneDuration))s",
                            value: $sceneDuration, in: 5...180, step: 5)
                    Stepper("Photo duration: \(Int(photoDuration))s",
                            value: $photoDuration, in: 3...120, step: 1)
                    Stepper("Refresh data: every \(Int(refreshMinutes)) min",
                            value: $refreshMinutes, in: 1...60, step: 1)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
