//
//  RosterChangeTest.swift
//  kourt-app
//
//  Created by Jake Walker on 13/05/2026.
//

import Foundation
@testable import KourtShared
import Testing

struct GeneratorRosterChangeTest {
    @Test("Disabled players are excluded from generated matches")
    func disabledPlayersAreExcluded() throws {
        var session = SampleData.sitOutSession
        let disabledPlayer = SampleData.fivePlayers[4]

        session.disablePlayer(withId: disabledPlayer.id)

        for _ in 0 ..< 20 {
            let nextMatches = try session.generateNext()

            for match in nextMatches {
                #expect(!match.teamA.contains(disabledPlayer.id))
                #expect(!match.teamB.contains(disabledPlayer.id))
            }

            session.matchGroups.append(nextMatches)
        }
    }

    @Test("Disabling a player removes generated future matches containing them")
    func disablingPlayerInvalidatesFutureMatches() {
        var session = SampleData.sitOutSession
        let disabledPlayer = SampleData.fivePlayers[4]

        session.matchGroups = [
            [
                .init(
                    court: 0,
                    teamA: [SampleData.fivePlayers[0].id, SampleData.fivePlayers[1].id],
                    teamB: [SampleData.fivePlayers[2].id, SampleData.fivePlayers[3].id],
                ),
            ],
            [
                .init(
                    court: 0,
                    teamA: [disabledPlayer.id, SampleData.fivePlayers[0].id],
                    teamB: [SampleData.fivePlayers[1].id, SampleData.fivePlayers[2].id],
                ),
            ],
        ]
        session.currentIndex = 0

        session.disablePlayer(withId: disabledPlayer.id)

        #expect(session.matchGroups.count == 1)
        #expect(session.matchGroups[0].first?.teamA.contains(disabledPlayer.id) == false)
        #expect(session.disabledPlayerIDs.contains(disabledPlayer.id))
    }

    @Test("Adding a player removes generated future matches")
    func addingPlayerInvalidatesFutureMatches() {
        var session = SampleData.sitOutSession

        session.matchGroups = [
            [
                .init(
                    court: 0,
                    teamA: [SampleData.fivePlayers[0].id, SampleData.fivePlayers[1].id],
                    teamB: [SampleData.fivePlayers[2].id, SampleData.fivePlayers[3].id],
                ),
            ],
            [
                .init(
                    court: 0,
                    teamA: [SampleData.fivePlayers[1].id, SampleData.fivePlayers[2].id],
                    teamB: [SampleData.fivePlayers[3].id, SampleData.fivePlayers[4].id],
                ),
            ],
        ]
        session.currentIndex = 0

        let addedPlayer = session.addPlayer(name: "Late Player")

        #expect(session.matchGroups.count == 1)
        #expect(session.players.contains(addedPlayer))
    }

    @Test("Disabling a player in one session does not disable them in a new session")
    func disabledPlayersAreSessionScoped() {
        let roster = SampleData.fivePlayers

        var firstSession = Session(players: roster, courts: 1, teamSize: 2)
        let secondSession = Session(players: roster, courts: 1, teamSize: 2)

        firstSession.disablePlayer(withId: roster[0].id)

        #expect(firstSession.activePlayers.count == 4)
        #expect(secondSession.activePlayers.count == 5)
        #expect(firstSession.inactivePlayers == [roster[0]])
        #expect(secondSession.inactivePlayers.isEmpty)
    }

    @Test("Re-enabled players do not get forced into every match")
    func reenabledPlayersDoNotCatchUpAggressively() throws {
        var session = SampleData.doublesSession
        let temporarilyDisabledPlayer = SampleData.eightPlayers[0]

        for _ in 0 ..< 8 {
            let nextMatches = try session.generateNext()
            session.matchGroups.append(nextMatches)
            session.currentIndex = session.matchGroups.count - 1
        }

        session.disablePlayer(withId: temporarilyDisabledPlayer.id)

        for _ in 0 ..< 8 {
            let nextMatches = try session.generateNext()

            for match in nextMatches {
                #expect(!match.teamA.contains(temporarilyDisabledPlayer.id))
                #expect(!match.teamB.contains(temporarilyDisabledPlayer.id))
            }

            session.matchGroups.append(nextMatches)
            session.currentIndex = session.matchGroups.count - 1
        }

        session.enablePlayer(withId: temporarilyDisabledPlayer.id)

        var matchesAfterReenabling = 0
        var reenabledPlayerMatches = 0
        var firstMatchesAfterReenabling = 0
        var firstReenabledPlayerMatches = 0

        for _ in 0 ..< 10 {
            let nextMatches = try session.generateNext()

            for match in nextMatches {
                matchesAfterReenabling += 1

                if matchesAfterReenabling <= 4 {
                    firstMatchesAfterReenabling += 1
                }

                if match.teamA.contains(temporarilyDisabledPlayer.id) || match.teamB.contains(temporarilyDisabledPlayer.id) {
                    reenabledPlayerMatches += 1

                    if matchesAfterReenabling <= 4 {
                        firstReenabledPlayerMatches += 1
                    }
                }
            }

            session.matchGroups.append(nextMatches)
        }

        #expect(matchesAfterReenabling == 10)
        #expect(firstMatchesAfterReenabling == 4)
        #expect(firstReenabledPlayerMatches <= 2)
        #expect(reenabledPlayerMatches < matchesAfterReenabling)
        #expect(reenabledPlayerMatches <= 6)
    }

    @Test("Sessions decoded from older data default to no disabled players")
    func sessionDecodingDefaultsDisabledPlayers() throws {
        let data = try #require(
            """
            {
              "id": "00000000-0000-0000-0000-000000000001",
              "date": "2026-05-13T00:00:00Z",
              "players": [
                {
                  "id": "00000000-0000-0000-0000-000000000002",
                  "name": "Alice"
                }
              ],
              "courts": 1,
              "teamSize": 1,
              "matchGroups": []
            }
            """.data(using: .utf8),
        )

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let session = try decoder.decode(Session.self, from: data)

        #expect(session.disabledPlayerIDs.isEmpty)
        #expect(session.playerMatchCountAdjustments.isEmpty)
        #expect(session.activePlayers.count == 1)
    }
}
