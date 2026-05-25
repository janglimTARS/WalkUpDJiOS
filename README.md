# WalkUpDJiOS

Minimal SwiftUI iOS app for **Walk-Up DJ online Spotify mode**.

This repo is intentionally small and secret-free. It demonstrates the app structure and UI for controlling the installed Spotify app using the Spotify iOS SDK / App Remote flow:

1. Authorize with Spotify.
2. Connect to the installed Spotify app via App Remote.
3. Play a selected Spotify track URI.
4. Seek to a configured walk-up start offset (`start_ms`).
5. Stop automatically after 12 seconds.

## Requirements

- macOS on Apple Silicon or Intel with Xcode installed.
- iOS 16+ target device or simulator for UI development.
- The Spotify iOS app installed on the physical iPhone for real App Remote playback.
- A Spotify Premium account is generally required for reliable App Remote playback control.
- A Spotify Developer app with:
  - Client ID
  - Redirect URI, for example: `walkupdjios://spotify-login-callback`

## Clone and open

```bash
git clone https://github.com/janglimTARS/WalkUpDJiOS.git
cd WalkUpDJiOS
open WalkUpDJiOS.xcodeproj
```

## Configure Spotify placeholders

Edit `WalkUpDJiOS/Services/SpotifyConfig.swift`:

```swift
static let clientID = "YOUR_SPOTIFY_CLIENT_ID"
static let redirectURI = "walkupdjios://spotify-login-callback"
```

Also add the same redirect URI in the Spotify Developer Dashboard for your app.

## Spotify SDK note

The current repo compiles as a clean SwiftUI prototype without vendoring the Spotify iOS SDK or secrets. `SpotifyAppRemoteController` is written as a documented adapter boundary with mock behavior so the UI can be built immediately.

To enable real playback:

1. Add the Spotify iOS SDK to the Xcode project.
2. Replace the marked TODO sections in `SpotifyAppRemoteController.swift` with `SPTSessionManager` and `SPTAppRemote` calls.
3. Add any required URL schemes / Info.plist entries required by the SDK version you use.
4. Test on a physical iPhone with Spotify installed and logged into Premium.

## App flow

- Select a player from the sample roster.
- Tap **Connect Spotify**.
- Edit `start_ms` if needed.
- Tap **Play 12s Walk-Up**.
- Tap **Stop** to stop early.

## Repository contents

- `WalkUpDJiOS.xcodeproj`: minimal Xcode project.
- `WalkUpDJiOS/WalkUpDJiOSApp.swift`: app entry point.
- `WalkUpDJiOS/Views/ContentView.swift`: simple roster/player UI.
- `WalkUpDJiOS/Models/PlayerWalkUp.swift`: sample data model.
- `WalkUpDJiOS/Services/SpotifyAppRemoteController.swift`: online Spotify control adapter placeholder.
- `WalkUpDJiOS/Services/SpotifyConfig.swift`: placeholder config.
