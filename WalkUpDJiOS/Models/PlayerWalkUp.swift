import Foundation

struct PlayerWalkUp: Identifiable, Equatable {
    let id = UUID()
    var playerName: String
    var number: String
    var spotifyTrackURI: String
    var songTitle: String
    var artist: String
    var startMS: Int

    static let sampleRoster: [PlayerWalkUp] = [
        PlayerWalkUp(
            playerName: "Maya Torres",
            number: "7",
            spotifyTrackURI: "spotify:track:4cOdK2wGLETKBW3PvgPWqT",
            songTitle: "Never Gonna Give You Up",
            artist: "Rick Astley",
            startMS: 42000
        ),
        PlayerWalkUp(
            playerName: "Jack Anglim",
            number: "23",
            spotifyTrackURI: "spotify:track:0VjIjW4GlUZAMYd2vXMi3b",
            songTitle: "Blinding Lights",
            artist: "The Weeknd",
            startMS: 64000
        ),
        PlayerWalkUp(
            playerName: "Sam Rivera",
            number: "12",
            spotifyTrackURI: "spotify:track:3n3Ppam7vgaVa1iaRUc9Lp",
            songTitle: "Mr. Brightside",
            artist: "The Killers",
            startMS: 18000
        )
    ]
}
