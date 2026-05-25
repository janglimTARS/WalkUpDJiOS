import Foundation
import SwiftUI
#if canImport(SpotifyiOS)
import SpotifyiOS
#endif

@MainActor
final class SpotifyAppRemoteController: NSObject, ObservableObject {
    static let shared = SpotifyAppRemoteController()

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
    private var pendingPlayURI = ""
    private var lastRequestedStartMS = 0

    #if canImport(SpotifyiOS)
    private lazy var configuration = SPTConfiguration(
        clientID: SpotifyConfig.clientID,
        redirectURL: SpotifyConfig.redirectURL
    )

    private lazy var appRemote: SPTAppRemote = {
        let remote = SPTAppRemote(configuration: configuration, logLevel: .debug)
        remote.delegate = self
        return remote
    }()
    #endif

    func connect() {
        guard SpotifyConfig.isConfigured else {
            connectionState = .error("Set SpotifyConfig.clientID first")
            statusMessage = "Add your Spotify Client ID and Redirect URI."
            return
        }

        connectionState = .connecting
        statusMessage = "Opening Spotify authorization…"

        #if canImport(SpotifyiOS)
        if appRemote.isConnected {
            connectionState = .connected
            statusMessage = "Spotify connected."
            return
        }

        // authorizeAndPlayURI hands off to the installed Spotify app. Passing an
        // empty URI means "authorize/connect" without hijacking the current song.
        appRemote.authorizeAndPlayURI("")
        #else
        connectionState = .error("SpotifyiOS SDK missing")
        statusMessage = "Add SpotifyiOS.xcframework to enable real online mode."
        #endif
    }

    func handleOpenURL(_ url: URL) {
        #if canImport(SpotifyiOS)
        let parameters = appRemote.authorizationParameters(from: url)
        if let token = parameters?[SPTAppRemoteAccessTokenKey] {
            appRemote.connectionParameters.accessToken = token
            statusMessage = "Authorized. Connecting to Spotify app…"
            connectionState = .connecting
            appRemote.connect()
        } else if let error = parameters?[SPTAppRemoteErrorDescriptionKey] {
            connectionState = .error(error)
            statusMessage = error
        } else {
            statusMessage = "Returned from Spotify without token."
        }
        #else
        statusMessage = "Received callback, but SpotifyiOS SDK is not linked."
        #endif
    }

    func playWalkUp(for player: PlayerWalkUp, startMS: Int) {
        guard SpotifyConfig.isConfigured else {
            connectionState = .error("Set SpotifyConfig.clientID first")
            statusMessage = "Configure Spotify before playback."
            return
        }

        stopTask?.cancel()
        nowPlaying = player
        pendingPlayURI = player.spotifyTrackURI
        lastRequestedStartMS = max(0, startMS)

        #if canImport(SpotifyiOS)
        guard appRemote.isConnected else {
            statusMessage = "Connecting Spotify, then playing \(player.songTitle)…"
            connectionState = .connecting
            appRemote.authorizeAndPlayURI(player.spotifyTrackURI)
            return
        }

        playCurrentPendingURI()
        #else
        connectionState = .error("SpotifyiOS SDK missing")
        statusMessage = "Add SpotifyiOS.xcframework. The UI is wired; the SDK is the missing organ."
        #endif
    }

    func stop() {
        stopTask?.cancel()
        stopTask = nil

        #if canImport(SpotifyiOS)
        if appRemote.isConnected {
            appRemote.playerAPI?.pause { [weak self] _, error in
                Task { @MainActor in
                    if let error {
                        self?.statusMessage = "Stop failed: \(error.localizedDescription)"
                    }
                    self?.finishStoppedState()
                }
            }
            return
        }
        #endif

        finishStoppedState()
    }

    private func finishStoppedState() {
        if let nowPlaying {
            statusMessage = "Stopped \(nowPlaying.playerName)'s walk-up."
        } else {
            statusMessage = "Stopped."
        }
        nowPlaying = nil
    }

    #if canImport(SpotifyiOS)
    private func playCurrentPendingURI() {
        guard appRemote.isConnected, !pendingPlayURI.isEmpty else { return }
        let uri = pendingPlayURI
        let startMS = lastRequestedStartMS
        statusMessage = "Starting Spotify track…"

        appRemote.playerAPI?.play(uri) { [weak self] _, playError in
            Task { @MainActor in
                guard let self else { return }
                if let playError {
                    self.connectionState = .error(playError.localizedDescription)
                    self.statusMessage = "Play failed: \(playError.localizedDescription)"
                    return
                }

                self.appRemote.playerAPI?.seek(toPosition: startMS) { [weak self] _, seekError in
                    Task { @MainActor in
                        guard let self else { return }
                        if let seekError {
                            self.statusMessage = "Playing, but seek failed: \(seekError.localizedDescription)"
                        } else if let nowPlaying = self.nowPlaying {
                            self.statusMessage = "Playing \(nowPlaying.songTitle) at \(startMS) ms for 12 seconds."
                        }
                        self.scheduleAutoStop()
                    }
                }
            }
        }
    }

    private func scheduleAutoStop() {
        stopTask?.cancel()
        stopTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 12_000_000_000)
            await self?.stop()
        }
    }
    #endif
}

#if canImport(SpotifyiOS)
extension SpotifyAppRemoteController: SPTAppRemoteDelegate {
    nonisolated func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        Task { @MainActor in
            self.connectionState = .connected
            self.statusMessage = "Spotify connected."
            appRemote.playerAPI?.delegate = self
            appRemote.playerAPI?.subscribe(toPlayerState: { _, error in
                if let error { print("Spotify subscribe error: \(error.localizedDescription)") }
            })
            if !self.pendingPlayURI.isEmpty {
                self.playCurrentPendingURI()
            }
        }
    }

    nonisolated func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        Task { @MainActor in
            self.connectionState = .disconnected
            self.statusMessage = error?.localizedDescription ?? "Spotify disconnected."
        }
    }

    nonisolated func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        Task { @MainActor in
            self.connectionState = .error(error?.localizedDescription ?? "Connection failed")
            self.statusMessage = error?.localizedDescription ?? "Spotify connection failed. Open Spotify once, then retry."
        }
    }
}

extension SpotifyAppRemoteController: SPTAppRemotePlayerStateDelegate {
    nonisolated func playerStateDidChange(_ playerState: SPTAppRemotePlayerState) {
        Task { @MainActor in
            self.statusMessage = "Spotify: \(playerState.track.name) — \(playerState.track.artist.name)"
        }
    }
}
#endif
