import Foundation
import SwiftUI

@MainActor
final class SpotifyAppRemoteController: ObservableObject {
    enum ConnectionState: Equatable {
        case disconnected
        case connecting
        case connected
        case error(String)

        var label: String {
            switch self {
            case .disconnected: return "Disconnected"
            case .connecting: return "Connecting…"
            case .connected: return "Connected"
            case .error(let message): return "Error: \(message)"
            }
        }
    }

    @Published private(set) var connectionState: ConnectionState = .disconnected
    @Published private(set) var nowPlaying: PlayerWalkUp?
    @Published private(set) var statusMessage = "Ready"

    private var stopTask: Task<Void, Never>?

    /// Placeholder for Spotify auth + App Remote connection.
    ///
    /// Real implementation outline:
    /// - Configure SPTConfiguration(clientID:redirectURL:)
    /// - Use SPTSessionManager to authorize requested scopes.
    /// - Configure SPTAppRemote.connectionParameters.accessToken.
    /// - Call appRemote.connect() when the Spotify app is available.
    func connect() {
        guard SpotifyConfig.clientID != "YOUR_SPOTIFY_CLIENT_ID" else {
            connectionState = .error("Set SpotifyConfig.clientID first")
            statusMessage = "Add your Spotify Client ID and Redirect URI."
            return
        }

        connectionState = .connecting
        statusMessage = "Mock connected. Add Spotify SDK for real playback."

        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 350_000_000)
            connectionState = .connected
        }
    }

    /// Play a track URI, seek to the configured offset, and stop after 12 seconds.
    ///
    /// Real App Remote implementation outline:
    /// ```swift
    /// appRemote.playerAPI?.play(trackURI) { _, error in ... }
    /// appRemote.playerAPI?.seek(toPosition: startMS) { _, error in ... }
    /// DispatchQueue.main.asyncAfter(deadline: .now() + 12) { appRemote.playerAPI?.pause(nil) }
    /// ```
    func playWalkUp(for player: PlayerWalkUp, startMS: Int) {
        stopTask?.cancel()
        nowPlaying = player
        statusMessage = "Mock playing \(player.songTitle) at \(startMS) ms for 12 seconds."

        stopTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 12_000_000_000)
            await self?.stop()
        }
    }

    func stop() {
        stopTask?.cancel()
        stopTask = nil
        if let nowPlaying {
            statusMessage = "Stopped \(nowPlaying.playerName)'s walk-up."
        } else {
            statusMessage = "Stopped."
        }
        nowPlaying = nil
    }
}
