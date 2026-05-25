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

This repo is wired for real online mode using the Spotify iOS SDK / App Remote API, while still compiling in a SDK-missing fallback state using `#if canImport(SpotifyiOS)`.

To enable real playback on your MacBook:

1. Download the latest Spotify iOS SDK release from `https://github.com/spotify/ios-sdk/releases`.
2. Add `SpotifyiOS.xcframework` to the Xcode project target: **General → Frameworks, Libraries, and Embedded Content**.
3. Set it to **Embed & Sign**.
4. Confirm `Info.plist` contains:
   - URL scheme: `walkupdjios`
   - `LSApplicationQueriesSchemes`: `spotify`
5. Edit `WalkUpDJiOS/Services/SpotifyConfig.swift` with your Spotify Client ID.
6. In the Spotify Developer Dashboard, add:
   - Bundle ID: `com.anglim.walkupdjios`
   - Redirect URI: `walkupdjios://spotify-login-callback`
7. Build to a physical iPhone with the Spotify app installed and logged into Premium.

The controller already calls:

- `SPTAppRemote.authorizeAndPlayURI(...)`
- `handleOpenURL(...)` to collect the access token
- `appRemote.connect()`
- `playerAPI.play(uri)`
- `playerAPI.seek(toPosition: start_ms)`
- `playerAPI.pause()` after 12 seconds

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
