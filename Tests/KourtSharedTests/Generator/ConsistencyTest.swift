//
//  ConsistencyTest.swift
//  kourt-app
//
//  Created by Jake Walker on 26/02/2026.
//

import KourtShared
import Testing

struct GeneratorConsistencyTest {
    @Test("Players sitting out are prioritised")
    func sitOutPlayersPrioritised() throws {
        var session = SampleData.sitOutSession
        // add match without player 5
        session.matchGroups.append([
            .init(court: 0, teamA: [SampleData.fivePlayers[0].id, SampleData.fivePlayers[1].id], teamB: [SampleData.fivePlayers[2].id, SampleData.fivePlayers[3].id]),
        ])

        // player 5 should be included in the next game
        let nextMatch = try #require(session.generateNext().first)
        #expect(nextMatch.teamA.union(nextMatch.teamB).contains(SampleData.fivePlayers[4].id))

        // add match without player 1
        session.matchGroups.append([
            .init(court: 0, teamA: [SampleData.fivePlayers[1].id, SampleData.fivePlayers[2].id], teamB: [SampleData.fivePlayers[3].id, SampleData.fivePlayers[4].id]),
        ])

        // player 1 should be included in the next game
        let nextMatch1 = try #require(session.generateNext().first)
        #expect(nextMatch1.teamA.union(nextMatch.teamB).contains(SampleData.fivePlayers[0].id))
    }
}
