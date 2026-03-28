//
//  SessionAnalytics.swift
//  kourt-app
//
//  Created by Jake Walker on 05/03/2026.
//

public struct SessionAnalytics {
    let session: Session

    public init(session: Session) {
        self.session = session
    }

    // MARK: - Per player

    /// The number of times each player has won a match
    public var winsByPlayer: [Player.ID: Int] {
        var counts = Dictionary(uniqueKeysWithValues: session.players.map { ($0.id, 0) })

        for matchGroup in session.matchGroups {
            for match in matchGroup {
                guard let winningPlayers = match.winningTeam else { continue }

                for player in winningPlayers {
                    counts[player, default: 0] += 1
                }
            }
        }

        return counts
    }

    /// The number of times each player has played a match
    public var matchesByPlayer: [Player.ID: Int] {
        var counts = Dictionary(uniqueKeysWithValues: session.players.map { ($0.id, 0) })

        for matchGroup in session.matchGroups {
            for match in matchGroup {
                for player in match.teamA.union(match.teamB) {
                    counts[player, default: 0] += 1
                }
            }
        }

        return counts
    }

    /// The percentage of wins that each player achieved
    public var winRateByPlayer: [Player.ID: Double] {
        var rates: [Player.ID: Double] = [:]
        for player in session.players {
            let wins = winsByPlayer[player.id] ?? 0
            let matches = matchesByPlayer[player.id] ?? 0
            guard matches > 0 else { continue }
            rates[player.id] = Double(wins) / Double(matches)
        }
        return rates
    }

    /// The best number of matches in a row where a player was unbeaten
    public var bestWinStreakByPlayer: [Player.ID: Int] {
        var bestStreaks: [Player.ID: Int] = Dictionary(uniqueKeysWithValues: session.players.map { ($0.id, 0) })

        for player in session.players {
            var currentStreak = 0
            var bestStreak = 0

            for matchGroup in session.matchGroups {
                for match in matchGroup {
                    let allPlayers = match.teamA.union(match.teamB)
                    guard allPlayers.contains(player.id) else { continue }

                    if let winners = match.winningTeam, winners.contains(player.id) {
                        currentStreak += 1
                        bestStreak = max(bestStreak, currentStreak)
                    } else {
                        currentStreak = 0
                    }
                }
            }
            bestStreaks[player.id] = bestStreak
        }

        return bestStreaks
    }

    // MARK: - Per team

    /// The number of times each team has won a match
    public var winsByTeam: [Set<Player.ID>: Int] {
        var counts: [Set<Player.ID>: Int] = [:]

        for matchGroup in session.matchGroups {
            for match in matchGroup {
                guard let winners = match.winningTeam else { continue }
                counts[winners, default: 0] += 1
            }
        }

        return counts
    }

    /// The number of matches each team played
    public var matchesByTeam: [Set<Player.ID>: Int] {
        var counts: [Set<Player.ID>: Int] = [:]

        for matchGroup in session.matchGroups {
            for match in matchGroup {
                counts[match.teamA, default: 0] += 1
                counts[match.teamB, default: 0] += 1
            }
        }

        return counts
    }

    /// The win rate for each team
    public var winRateByTeam: [Set<Player.ID>: Double] {
        var rates: [Set<Player.ID>: Double] = [:]
        for team in matchesByTeam.keys {
            let wins = winsByTeam[team] ?? 0
            let matches = matchesByTeam[team] ?? 0
            guard matches > 0 else { continue }
            rates[team] = Double(wins) / Double(matches)
        }
        return rates
    }

    /// The teams who did not lose any matches
    public var unbeatenTeams: Set<Set<Player.ID>> {
        var unbeaten: Set<Set<Player.ID>> = []

        for team in matchesByTeam.keys {
            let wins = winsByTeam[team] ?? 0
            let matches = matchesByTeam[team] ?? 0
            if matches > 0, wins == matches {
                unbeaten.insert(team)
            }
        }

        return unbeaten
    }
}

#if !os(Android)
    import Playgrounds

    #Playground {
        var session = Session(
            players: [.init(name: "A"), .init(name: "B"), .init(name: "C"), .init(name: "D")],
        )

        session.advance(by: 10)

        for i in 0 ..< session.matchGroups.count {
            let randomTeam = Team.allCases.randomElement()!
            session.matchGroups[i][0].winner = randomTeam
        }

        var analytics = SessionAnalytics(session: session)

        _ = analytics.winsByPlayer
        _ = analytics.matchesByPlayer
        _ = analytics.winRateByPlayer
        _ = analytics.bestWinStreakByPlayer
        _ = analytics.winsByTeam
        _ = analytics.matchesByTeam
        _ = analytics.winRateByTeam
        _ = analytics.unbeatenTeams
    }
#endif
