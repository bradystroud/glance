import Foundation

/// Default values. Live values are read from `AppSettings` (UserDefaults) and
/// editable in the in-app Settings screen.
enum Config {
    // Weather location — default: Brisbane.
    static let defaultLatitude = -27.4698
    static let defaultLongitude = 153.0251

    // Weather place display name (paired with the default coords above)
    static let defaultPlaceName = "Brisbane"

    // GitHub
    static let defaultGithubUsername = "bradystroud"

    // Rotation timings
    static let defaultSceneDuration: TimeInterval = 30    // seconds each page is shown
    static let defaultPhotoDuration: TimeInterval = 18    // seconds per photo page
    static let defaultRefreshMinutes: Double = 10         // data re-fetch interval

    // YouTube channels — one ID per line ("UC…"); text after # is a label and is ignored.
    static let defaultYoutubeChannels = """
    UCsBjURrPoezykLs9EqgamOA  # Fireship
    UCbRP3c757lWg9M-U7TyEkXA  # Theo - t3.gg
    UCUyeluBRhGPCW4rPe_UvBZQ  # ThePrimeagen
    UCFbNIlppjAuEX4znoulh0Cw  # Web Dev Simplified
    UC8butISFwT-Wl7EV0hUK0BQ  # freeCodeCamp
    UC9x0AN7BWHpCDHSm9NiJFJQ  # NetworkChuck
    UC9-y-6csu5WGm29I7JiwpnA  # Computerphile
    UCbfYPyITQ-7l4upoX8nvctg  # Two Minute Papers
    UCZHmQk67mSJgfCCTn7xBfew  # Yannic Kilcher
    UCfzlCWGWYyIQ0aLC5w48gBQ  # sentdex
    UCSHZKyawb77ixDdsGog4iWA  # Lex Fridman
    UCBJycsmduvYEL83R_U4JriQ  # Marques Brownlee (MKBHD)
    UCYO_jab_esuFRV4b17AJtAw  # 3Blue1Brown
    UCcefcZRL2oaA_uBNeo5UOWg  # Y Combinator
    """

    /// Extract channel IDs from the stored text (ignores blank/comment lines and labels).
    static func parseChannels(_ raw: String) -> [String] {
        parseChannelList(raw).map(\.id)
    }

    /// Parse the stored "ID  # Name" lines into Channels.
    static func parseChannelList(_ raw: String) -> [Channel] {
        raw.split(separator: "\n").compactMap { line in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { return nil }
            let parts = trimmed.components(separatedBy: "#")
            let id = parts[0].trimmingCharacters(in: .whitespaces)
            guard id.hasPrefix("UC") else { return nil }
            let name = parts.count > 1 ? parts[1].trimmingCharacters(in: .whitespaces) : id
            return Channel(id: id, name: name.isEmpty ? id : name)
        }
    }

    /// Serialize Channels back to the stored "ID  # Name" format.
    static func serializeChannels(_ channels: [Channel]) -> String {
        channels.map { "\($0.id)  # \($0.name)" }.joined(separator: "\n")
    }
}
