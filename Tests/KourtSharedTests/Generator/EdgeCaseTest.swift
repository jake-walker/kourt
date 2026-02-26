//
//  EdgeCaseTest.swift
//  kourt-app
//
//  Created by Jake Walker on 26/02/2026.
//

import KourtShared
import Testing

struct GeneratorEdgeCaseTest {
    @Test("Minimum viable players for singles on one court (2 players)")
    func minimumSinglesPlayers() throws {
        let session = SampleData.minimalSinglesSession
        let matches = try session.generateNext()

        #expect(matches.count == 1)
    }

    @Test("Minimum viable players for doubles on one court (4 players)")
    func minimumDoublesPlayers() throws {
        let session = SampleData.minimalSinglesSession
        let matches = try session.generateNext()

        #expect(matches.count == 1)
    }

    @Test("Exactly enough players to fill all courts with no one sitting out")
    func exactPlayers() throws {
        let session = SampleData.multiCourtDoublesSession
        let matches = try session.generateNext()

        #expect(matches.count == 2)

        for match in matches {
            #expect(match.teamA.count == 2)
            #expect(match.teamB.count == 2)
        }
    }

    @Test("One more player than needed (someone always sits out)")
    func moreThanNeededPlayers() throws {
        let session = SampleData.sitOutSession
        let matches = try session.generateNext()

        #expect(matches.count == 1)

        #expect(matches.first?.teamA.count == 2)
        #expect(matches.first?.teamB.count == 2)

        let match = try #require(matches.first)
        let matchPlayers = match.teamA.union(match.teamB)
        let sitOuts = Set(session.players.map(\.id)).subtracting(matchPlayers)

        #expect(sitOuts.count == 1)
    }

    @Test("Single player")
    func singlePlayer() throws {
        let session = Session(players: [.init(name: "Test")], courts: 1, teamSize: 1)

        #expect(throws: GeneratorError.self) {
            _ = try session.generateNext()
        }
    }

    @Test("More courts than can be filled")
    func tooManyCourts() throws {
        let session = SampleData.tooManyCourtsSession

        #expect(throws: GeneratorError.self) {
            _ = try session.generateNext()
        }
    }
}
