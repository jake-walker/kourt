//
//  SampleData.swift
//  kourt-app
//
//  Created by Jake Walker on 26/02/2026.
//

@testable import KourtShared

enum SampleData {
    // MARK: - Players

    static let twoPlayers: [Player] = [
        .init(id: .init(uuidString: "00000000-0000-0000-0000-000000000001")!, name: "Alice"),
        .init(id: .init(uuidString: "00000000-0000-0000-0000-000000000002")!, name: "Bob"),
    ]

    static let fourPlayers: [Player] = twoPlayers + [
        .init(id: .init(uuidString: "00000000-0000-0000-0000-000000000003")!, name: "Charlie"),
        .init(id: .init(uuidString: "00000000-0000-0000-0000-000000000004")!, name: "Diana"),
    ]

    static let eightPlayers: [Player] = fourPlayers + [
        .init(id: .init(uuidString: "00000000-0000-0000-0000-000000000005")!, name: "Eve"),
        .init(id: .init(uuidString: "00000000-0000-0000-0000-000000000006")!, name: "Frank"),
        .init(id: .init(uuidString: "00000000-0000-0000-0000-000000000007")!, name: "Grace"),
        .init(id: .init(uuidString: "00000000-0000-0000-0000-000000000008")!, name: "Henry"),
    ]

    static let fivePlayers: [Player] = fourPlayers + [
        .init(id: .init(uuidString: "00000000-0000-0000-0000-000000000005")!, name: "Eve"),
    ]

    // MARK: - Sessions

    static let minimalSinglesSession = Session(
        id: .init(uuidString: "00000000-0000-0000-0001-000000000001")!,
        players: twoPlayers,
        courts: 1,
        teamSize: 1,
    )

    static let minimalDoublesSession = Session(
        id: .init(uuidString: "00000000-0000-0000-0001-000000000002")!,
        players: fourPlayers,
        courts: 1,
        teamSize: 2,
    )

    static let singlesSession = Session(
        id: .init(uuidString: "00000000-0000-0000-0001-000000000003")!,
        players: eightPlayers,
        courts: 1,
        teamSize: 1,
    )

    static let doublesSession = Session(
        id: .init(uuidString: "00000000-0000-0000-0001-000000000004")!,
        players: eightPlayers,
        courts: 1,
        teamSize: 2,
    )

    static let multiCourtDoublesSession = Session(
        id: .init(uuidString: "00000000-0000-0000-0001-000000000005")!,
        players: eightPlayers,
        courts: 2,
        teamSize: 2,
    )

    static let sitOutSession = Session(
        id: .init(uuidString: "00000000-0000-0000-0001-000000000006")!,
        players: fivePlayers,
        courts: 1,
        teamSize: 2,
    )

    static let tooManyCourtsSession = Session(
        id: .init(uuidString: "00000000-0000-0000-0001-000000000007")!,
        players: fourPlayers,
        courts: 3,
        teamSize: 2,
    )

    static let allValidSessions: [Session] = [
        minimalSinglesSession,
        minimalDoublesSession,
        singlesSession,
        doublesSession,
        multiCourtDoublesSession,
        sitOutSession,
    ]
}
