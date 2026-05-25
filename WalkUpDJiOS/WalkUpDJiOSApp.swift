import SwiftUI

@main
struct WalkUpDJiOSApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    SpotifyAppRemoteController.shared.handleOpenURL(url)
                }
        }
    }
}
