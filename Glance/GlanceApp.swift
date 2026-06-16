import SwiftUI

@main
struct GlanceApp: App {
    @AppStorage("appearance") private var appearance = Appearance.system.rawValue

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(Appearance(rawValue: appearance)?.colorScheme)
                .statusBarHidden(true)
        }
    }
}
