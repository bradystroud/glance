import SwiftUI

struct ChannelSettingsView: View {
    @AppStorage("youtubeChannelsRaw") private var raw = Config.defaultYoutubeChannels

    @State private var newInput = ""
    @State private var adding = false
    @State private var error: String?

    private var channels: [Channel] { Config.parseChannelList(raw) }

    var body: some View {
        List {
            Section("Add channel") {
                HStack {
                    TextField("Channel link, @handle, or UC… ID", text: $newInput)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .onSubmit { Task { await add() } }
                    if adding {
                        ProgressView()
                    } else {
                        Button("Add") { Task { await add() } }
                            .disabled(newInput.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                if let error {
                    Text(error).font(.caption).foregroundStyle(.red)
                }
                Text("Paste a channel link, @handle, or a UC… ID — the name is looked up automatically.")
                    .font(.footnote).foregroundStyle(.secondary)
            }

            Section(channels.isEmpty ? "" : "\(channels.count) channels") {
                if channels.isEmpty {
                    Text("No channels yet").foregroundStyle(.secondary)
                }
                ForEach(channels) { ch in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(ch.name)
                        Text(ch.id).font(.caption.monospaced()).foregroundStyle(.secondary)
                    }
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
        }
        .navigationTitle("YouTube channels")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar { EditButton() }
    }

    private func add() async {
        let input = newInput.trimmingCharacters(in: .whitespaces)
        guard !input.isEmpty, !adding else { return }
        adding = true
        error = nil
        defer { adding = false }

        guard let resolved = await YouTubeResolver.resolve(input) else {
            error = "Couldn't find that channel. Try the channel URL or its UC… ID."
            return
        }
        var list = channels
        guard !list.contains(where: { $0.id == resolved.id }) else {
            error = "“\(resolved.name)” is already in the list."
            newInput = ""
            return
        }
        list.append(resolved)
        raw = Config.serializeChannels(list)
        newInput = ""
    }

    private func delete(_ offsets: IndexSet) {
        var list = channels
        list.remove(atOffsets: offsets)
        raw = Config.serializeChannels(list)
    }

    private func move(_ offsets: IndexSet, to destination: Int) {
        var list = channels
        list.move(fromOffsets: offsets, toOffset: destination)
        raw = Config.serializeChannels(list)
    }
}
