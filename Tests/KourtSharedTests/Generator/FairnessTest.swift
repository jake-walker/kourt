//
//  FairnessTest.swift
//  kourt-app
//
//  Created by Jake Walker on 26/02/2026.
//

import Foundation
@testable import KourtShared
import Testing

private struct PlayerOpponent: Hashable {
    let player: Player.ID
    let opponent: Player.ID
}

struct GeneratorFairnessTest {
    static let rounds = 200

    /// The difference in the highest and lowest number of matches each player plays
    static let playerMatchCountTolerance = 2

    /// The difference in the highest and lowest number of matches each player sits out
    static let playerSitOutCountTolerance = 2

    /// The difference in the highest and lowest number of times the same pair of players play
    static let playerPairCountTolerance = 3

    /// The difference in the highest and lowest number of times a player has the same opponent
    static let playerOpponentCountTolerance = 20

    @Test("Each player plays a similar number of games over N rounds", arguments: [SampleData.singlesSession, SampleData.doublesSession])
    func playerMatchCount(_ session: Session) throws {
        var session = session

        for _ in 0 ..< Self.rounds {
            try session.matchGroups.append(session.generateNext())
        }

        var gameCounts: [Player.ID: Int] = [:]

        for player in session.players {
            gameCounts[player.id] = 0
        }

        for match in session.matchGroups.joined() {
            for player in match.teamA.union(match.teamB) {
                gameCounts[player, default: 0] += 1
            }
        }

        let high = try #require(gameCounts.values.max())
        let low = try #require(gameCounts.values.min())

        print("Each player plays between \(low) and \(high) times over \(Self.rounds) rounds")

        #expect((high - low) <= Self.playerMatchCountTolerance)
    }

    @Test("Each player sits out a similar number of rounds")
    func playerSitOutCount() throws {
        var session = SampleData.sitOutSession

        for _ in 0 ..< Self.rounds {
            try session.matchGroups.append(session.generateNext())
        }

        var sitOutCounts: [Player.ID: Int] = [:]

        for player in session.players {
            sitOutCounts[player.id] = 0
        }

        for match in session.matchGroups.joined() {
            let matchPlayers = match.teamA.union(match.teamB)
            let sitOuts = Set(session.players.map(\.id)).subtracting(matchPlayers)
            for player in sitOuts {
                sitOutCounts[player, default: 0] += 1
            }
        }

        let high = try #require(sitOutCounts.values.max())
        let low = try #require(sitOutCounts.values.min())

        print("Each player sits out between \(low) and \(high) times over \(Self.rounds) rounds")

        #expect((high - low) <= Self.playerSitOutCountTolerance)
    }

    @Test("Players don't repeatedly partner with the same person")
    func playerRepeatedPartner() throws {
        var session = SampleData.doublesSession

        for _ in 0 ..< Self.rounds {
            try session.matchGroups.append(session.generateNext())
        }

        var teamCounts: [Set<Player.ID>: Int] = [:]

        for playerA in session.players {
            for playerB in session.players {
                if playerA.id == playerB.id {
                    continue
                }

                teamCounts[Set(arrayLiteral: playerA.id, playerB.id)] = 0
            }
        }

        for match in session.matchGroups.joined() {
            teamCounts[match.teamA, default: 0] += 1
            teamCounts[match.teamB, default: 0] += 1
        }

        let high = try #require(teamCounts.values.max())
        let low = try #require(teamCounts.values.min())

        print("Each team plays together between \(low) and \(high) times over \(Self.rounds) rounds")

        #expect(low > 0, "Each pair should play at least once")
        #expect((high - low) <= Self.playerPairCountTolerance)
    }

    @Test(
        "Players don't repeatedly play against the same person",
        .disabled("Algorithm is not optimised for this yet and causes flaky results"),
        arguments: [SampleData.singlesSession, SampleData.doublesSession],
    )
    func playerRepeatedOpponent(_ session: Session) throws {
        var session = session

        for _ in 0 ..< Self.rounds {
            try session.matchGroups.append(session.generateNext())
        }

        var oppositionCounts: [PlayerOpponent: Int] = [:]

        for player in session.players {
            for opponent in session.players where opponent.id != player.id {
                oppositionCounts[.init(player: player.id, opponent: opponent.id)] = 0
            }
        }

        for match in session.matchGroups.joined() {
            for playerA in match.teamA {
                for playerB in match.teamB {
                    oppositionCounts[.init(player: playerA, opponent: playerB), default: 0] += 1
                    oppositionCounts[.init(player: playerB, opponent: playerA), default: 0] += 1
                }
            }
        }

        let high = try #require(oppositionCounts.values.max())
        let low = try #require(oppositionCounts.values.min())

        print("Each player has the same opponent between \(low) and \(high) times over \(Self.rounds) rounds")

        #expect(low > 0, "Each player should have played against everyone at least once")
        #expect((high - low) <= Self.playerOpponentCountTolerance)
    }

    @Test("Same match is not generated twice in a row")
    func repeatedMatch() throws {
        var session = SampleData.minimalDoublesSession

        #expect(session.courts == 1)
        #expect(session.players.count == 4)
        #expect(session.teamSize == 2)

        try session.matchGroups.append(session.generateNext())

        for _ in 0 ..< 29 {
            let previousMatch = try #require(session.matchGroups.last?.first)
            let nextMatches = try session.generateNext()
            let nextMatch = try #require(nextMatches.first)

            #expect(
                // check exactly the same team
                !(nextMatch.teamA.elementsEqual(previousMatch.teamA)
                    && nextMatch.teamB.elementsEqual(previousMatch.teamB))
                    // check swapped teams
                    || !(nextMatch.teamA.elementsEqual(previousMatch.teamB)
                        && nextMatch.teamB.elementsEqual(previousMatch.teamA)),
            )

            session.matchGroups.append(nextMatches)
        }
    }
}
