import SwiftUI

struct ContentView: View {
    @StateObject private var spotify = SpotifyAppRemoteController.shared
    @State private var roster = PlayerWalkUp.sampleRoster
    @State private var selectedPlayer = PlayerWalkUp.sampleRoster[0]
    @State private var startMSText = String(PlayerWalkUp.sampleRoster[0].startMS)

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                connectionCard
                rosterList
                controls
                Spacer(minLength: 0)
            }
            .padding()
            .navigationTitle("Walk-Up DJ")
            .onChange(of: selectedPlayer) { _, newValue in
                startMSText = String(newValue.startMS)
            }
        }
    }

    private var connectionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Online Spotify Mode")
                .font(.headline)
            Text("State: \(spotify.connectionState.label)")
                .font(.subheadline)
            Text(spotify.statusMessage)
                .font(.caption)
                .foregroundStyle(.secondary)
            Button("Connect Spotify") {
                spotify.connect()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    private var rosterList: some View {
        List(roster) { player in
            Button {
                selectedPlayer = player
            } label: {
                HStack {
                    Text("#\(player.number)")
                        .font(.headline.monospacedDigit())
                        .frame(width: 44, alignment: .leading)
                    VStack(alignment: .leading) {
                        Text(player.playerName)
                            .font(.headline)
                        Text("\(player.songTitle) — \(player.artist)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if player == selectedPlayer {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
            }
            .buttonStyle(.plain)
        }
        .listStyle(.plain)
        .frame(minHeight: 220)
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack {
                Text("start_ms")
                TextField("Start offset", text: $startMSText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
            }

            HStack {
                Button("Play 12s Walk-Up") {
                    spotify.playWalkUp(for: selectedPlayer, startMS: Int(startMSText) ?? selectedPlayer.startMS)
                }
                .buttonStyle(.borderedProminent)

                Button("Stop", role: .destructive) {
                    spotify.stop()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

#Preview {
    ContentView()
}
