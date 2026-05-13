//
//  Models+Generate.swift
//  kourt-app
//
//  Created by Jake Walker on 26/02/2026.
//

import Algorithms
import Foundation

public enum GeneratorError: Error {
    case matchHasDuplicatePlayers(teamA: Set<Player.ID>, teamB: Set<Player.ID>)
    case noNextPlayersFound(excluding: Set<Player.ID>)
    case noPlayerCombinationFound(for: Player.ID, excluding: Set<Player.ID>)
    case invalidPlayerCombination(for: Player.ID, combination: Set<Player.ID>)
}

private struct CandidateMatch {
    let teamA: Set<UUID>
    let teamB: Set<UUID>
    let score: Int
}

private struct MatchSignature: Hashable {
    let teams: Set<Set<UUID>>

    init(teamA: Set<UUID>, teamB: Set<UUID>) {
        teams = [teamA, teamB]
    }
}

extension Session {
    var playerCounter: [UUID: Int] {
        let initialCounter = activePlayers.reduce(into: [UUID: Int]()) { counter, player in
            counter[player.id] = 0
        }

        return matches.reduce(into: initialCounter) { counter, match in
            for player in match.teamA.union(match.teamB) {
                counter[player, default: 0] += 1
            }
        }
    }

    var playerComboCounter: [Set<UUID>: Int] {
        let initialCombos = activePlayers.map(\.id).combinations(ofCount: teamSize)
            .reduce(into: [Set<UUID>: Int]()) { counter, combo in
                counter[Set(combo)] = 0
            }

        return matches.reduce(into: initialCombos) { counter, match in
            counter[Set(match.teamA), default: 0] += 1
            counter[Set(match.teamB), default: 0] += 1
        }
    }

    var opponentCounter: [Set<UUID>: Int] {
        let playerIds = activePlayers.map(\.id)
        let initialOpponents = playerIds.combinations(ofCount: 2)
            .reduce(into: [Set<UUID>: Int]()) { counter, pair in
                counter[Set(pair)] = 0
            }

        return matches.reduce(into: initialOpponents) { counter, match in
            for playerA in match.teamA {
                for playerB in match.teamB {
                    counter[[playerA, playerB], default: 0] += 1
                }
            }
        }
    }

    private func adjustedPlayerCount(for playerId: Player.ID) -> Int {
        playerCounter[playerId, default: 0] + playerMatchCountAdjustments[playerId, default: 0]
    }

    private var matchCounter: [MatchSignature: Int] {
        matches.reduce(into: [MatchSignature: Int]()) { counter, match in
            counter[MatchSignature(teamA: match.teamA, teamB: match.teamB), default: 0] += 1
        }
    }

    private var previousMatchSignatures: Set<MatchSignature> {
        guard let previousGroup = matchGroups.last else {
            return []
        }

        return Set(previousGroup.map { MatchSignature(teamA: $0.teamA, teamB: $0.teamB) })
    }

    private var previousTeamSignatures: Set<Set<UUID>> {
        guard let previousGroup = matchGroups.last else {
            return []
        }

        return previousGroup.reduce(into: Set<Set<UUID>>()) { teams, match in
            teams.insert(match.teamA)
            teams.insert(match.teamB)
        }
    }

    private func candidateScore(teamA: Set<UUID>, teamB: Set<UUID>) -> Int {
        let matchPlayers = teamA.union(teamB)
        let signature = MatchSignature(teamA: teamA, teamB: teamB)

        var score = 0

        // Keep players' total games balanced. This is deliberately the largest normal weight
        // so sit-outs are corrected before optimizing partners and opponents.
        score += matchPlayers
            .map { adjustedPlayerCount(for: $0) }
            .reduce(0, +) * 10000

        score += playerComboCounter[teamA, default: 0] * 1000
        score += playerComboCounter[teamB, default: 0] * 1000

        for playerA in teamA {
            for playerB in teamB {
                score += opponentCounter[[playerA, playerB], default: 0] * 250
            }
        }

        score += matchCounter[signature, default: 0] * 100_000

        if previousTeamSignatures.contains(teamA) {
            score += 1_000_000
        }

        if previousTeamSignatures.contains(teamB) {
            score += 1_000_000
        }

        if previousMatchSignatures.contains(signature) {
            score += 1_000_000
        }

        return (score * 100) + Int.random(in: 0 ..< 100)
    }

    private func getCandidateMatches(excluding: Set<UUID> = []) -> [CandidateMatch] {
        let availablePlayers = activePlayers.map(\.id).filter { !excluding.contains($0) }

        if teamSize == 1 {
            return availablePlayers.combinations(ofCount: 2).map { combo in
                let teamA = Set(arrayLiteral: combo[0])
                let teamB = Set(arrayLiteral: combo[1])

                return CandidateMatch(
                    teamA: teamA,
                    teamB: teamB,
                    score: candidateScore(teamA: teamA, teamB: teamB),
                )
            }
        }

        let teams = availablePlayers.combinations(ofCount: teamSize).map(Set.init)
        var candidates: [CandidateMatch] = []

        for teamAIndex in teams.indices {
            let teamA = teams[teamAIndex]

            for teamB in teams[(teamAIndex + 1)...] {
                if !teamA.isDisjoint(with: teamB) {
                    continue
                }

                candidates.append(
                    CandidateMatch(
                        teamA: teamA,
                        teamB: teamB,
                        score: candidateScore(teamA: teamA, teamB: teamB),
                    ),
                )
            }
        }

        return candidates
    }

    private func getNextMatch(court: Int, excluding: Set<UUID> = []) throws -> Match {
        guard let candidate = getCandidateMatches(excluding: excluding).min(by: { $0.score < $1.score }) else {
            throw GeneratorError.noNextPlayersFound(excluding: excluding)
        }

        return Match(court: court, teamA: candidate.teamA, teamB: candidate.teamB)
    }

    func generateNext() throws -> [Match] {
        var matches: [Match] = []
        var usedPlayers: Set<UUID> = []

        for i in 0 ..< courts {
            let match = try getNextMatch(court: i, excluding: usedPlayers)

            usedPlayers.formUnion(match.teamA)
            usedPlayers.formUnion(match.teamB)
            matches.append(match)
        }

        return matches
    }

    // MARK: - Navigation

    public mutating func advance(by steps: Int = 1) {
        let targetIndex = currentIndex + steps

        // generate groups ahead until we have at least one beyond the target
        while matchGroups.count <= targetIndex + 1 {
            if let next = try? generateNext() {
                matchGroups.append(next)
            } else {
                break
            }
        }

        currentIndex = min(targetIndex, matchGroups.count - 1)
    }

    public mutating func goBack(by steps: Int = 1) {
        currentIndex = max(0, currentIndex - steps)
    }

    public mutating func ensureReady() {
        while matchGroups.count <= currentIndex + 1 {
            if let next = try? generateNext() {
                matchGroups.append(next)
            } else {
                break
            }
        }
    }
}
