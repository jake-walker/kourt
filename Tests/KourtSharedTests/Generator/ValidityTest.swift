//
//  ValidityTest.swift
//  kourt-app
//
//  Created by Jake Walker on 26/02/2026.
//

@testable import KourtShared
import Testing

struct GeneratorValidityTest {
    @Test("No player appears twice in the same round")
    func roundDuplicates() throws {
        let session = SampleData.multiCourtDoublesSession
        let matches = try session.generateNext()

        for match in matches {
            #expect(match.teamA.intersection(match.teamB).isEmpty)
        }
    }

    @Test("Correct number of players per team", arguments: [(SampleData.singlesSession, 1), (SampleData.doublesSession, 2)])
    func correctPlayersPerTeam(_ session: Session, expectedTeamSize: Int) throws {
        let matches = try session.generateNext()

        for match in matches {
            #expect(match.teamA.count == expectedTeamSize)
            #expect(match.teamB.count == expectedTeamSize)
        }
    }

    @Test("Court numbers are within valid range")
    func validCourtNumbers() throws {
        let session = SampleData.multiCourtDoublesSession
        let matches = try session.generateNext()

        for match in matches {
            #expect(match.court >= 0 && match.court < session.courts)
        }
    }

    @Test("No empty match groups", arguments: SampleData.allValidSessions)
    func noEmptyMatchGroups(_ session: Session) throws {
        let matches = try session.generateNext()
        #expect(!matches.isEmpty)
    }

    @Test("No empty matches", arguments: [SampleData.minimalSinglesSession, SampleData.minimalDoublesSession])
    func noEmptyMatches(_ session: Session) throws {
        let matches = try session.generateNext()

        for match in matches {
            #expect(!match.teamA.isEmpty && !match.teamB.isEmpty)
        }
    }

    @Test("All players in matches exist in the session")
    func allPlayersExistInSession() throws {
        let session = SampleData.doublesSession
        let matches = try session.generateNext()

        for match in matches {
            for playerId in match.teamA.union(match.teamB) {
                #expect(session.players.first { $0.id == playerId } != nil)
            }
        }
    }
}
