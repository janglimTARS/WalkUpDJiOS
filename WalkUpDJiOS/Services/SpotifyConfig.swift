import Foundation

/// Replace these placeholders with values from your Spotify Developer Dashboard.
enum SpotifyConfig {
    static let clientID = "YOUR_SPOTIFY_CLIENT_ID"
    static let redirectURI = "walkupdjios://spotify-login-callback"

    static var redirectURL: URL {
        guard let url = URL(string: redirectURI) else {
            preconditionFailure("Invalid Spotify redirect URI")
        }
        return url
    }

    static var isConfigured: Bool {
        clientID != "YOUR_SPOTIFY_CLIENT_ID" && !clientID.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
