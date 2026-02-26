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

extension Session {
    var playerCounter: [UUID: Int] {
        let initialCounter = players.reduce(into: [UUID: Int]()) { counter, player in
            counter[player.id] = 0
        }

        return matches.reduce(into: initialCounter) { counter, match in
            for player in match.teamA.union(match.teamB) {
                counter[player, default: 0] += 1
            }
        }
    }

    var playerComboCounter: [Set<UUID>: Int] {
        let initialCombos = players.map(\.id).combinations(ofCount: teamSize)
            .reduce(into: [Set<UUID>: Int]()) { counter, combo in
                counter[Set(combo)] = 0
            }

        return matches.reduce(into: initialCombos) { counter, match in
            counter[Set(match.teamA), default: 0] += 1
            counter[Set(match.teamB), default: 0] += 1
        }
    }

    private func getNextPlayer(excluding: Set<UUID> = []) throws -> UUID {
        var candidates =
            playerCounter
                .filter { !excluding.contains($0.key) }

        // add random values for tie-breaking
        for (k, v) in candidates {
            candidates[k] = (v * 100) + Int.random(in: 0 ..< 100)
        }

        let sorted = candidates.sorted { $0.value < $1.value }
            .map(\.key)

        guard let result = sorted.first else {
            throw GeneratorError.noNextPlayersFound(excluding: excluding)
        }

        return result
    }

    private func getComboWeight(for combo: Set<UUID>) -> Int {
        var weight = 0

        weight += playerComboCounter[combo, default: 0]
        weight += combo.map { self.playerCounter[$0, default: 0] }
            .reduce(0, +)

        // add a random number to tie-break
        weight *= 100
        weight += Int.random(in: 0 ..< 100)

        return weight
    }

    private func getNextCombo(for player: UUID, excluding: Set<UUID> = [], teammates: Bool = false)
        throws -> UUID
    {
        var candidates =
            playerComboCounter
                .filter { $0.key.isDisjoint(with: excluding) }

        for key in candidates.keys {
            candidates[key] = getComboWeight(for: key)
        }

        if teammates {
            candidates = candidates.filter { !$0.key.contains(player) }
        } else {
            candidates = candidates.filter { $0.key.contains(player) }
        }

        let sorted = candidates.sorted { $0.value < $1.value }

        guard let firstCandidate = sorted.first else {
            throw GeneratorError.noPlayerCombinationFound(for: player, excluding: excluding)
        }

        guard let filteredCandidate = firstCandidate.key.filter({ $0 != player }).first else {
            throw GeneratorError.invalidPlayerCombination(
                for: player, combination: firstCandidate.key,
            )
        }

        return filteredCandidate
    }

    private func getNextTeam(excluding: Set<UUID> = [], teammates: Bool = false) throws -> Set<UUID> {
        let player1 = try getNextPlayer(excluding: excluding)
        let player2 = try getNextCombo(for: player1, excluding: excluding, teammates: teammates)

        return Set([player1, player2])
    }

    private func getNextDoublesMatch(court: Int, excluding: Set<UUID> = []) throws -> Match {
        let teamA = try getNextTeam(excluding: excluding)
        let teamB = try getNextTeam(excluding: excluding.union(teamA))

        if !teamA.isDisjoint(with: teamB) {
            throw GeneratorError.matchHasDuplicatePlayers(teamA: teamA, teamB: teamB)
        }

        return Match(court: court, teamA: teamA, teamB: teamB)
    }

    private func getNextSinglesMatch(court: Int, excluding: Set<UUID> = []) throws -> Match {
        let players = try getNextTeam(excluding: excluding, teammates: true)

        let playersArray = Array(players)

        return Match(
            court: court, teamA: Set(arrayLiteral: playersArray[0]),
            teamB: Set(arrayLiteral: playersArray[1]),
        )
    }

    public func generateNext() throws -> [Match] {
        var matches: [Match] = []
        var usedPlayers: Set<UUID> = []

        for i in 0 ..< courts {
            let match =
                try
                    (teamSize == 1
                        ? getNextSinglesMatch(court: i, excluding: usedPlayers)
                        : getNextDoublesMatch(court: i, excluding: usedPlayers))

            usedPlayers.formUnion(match.teamA)
            usedPlayers.formUnion(match.teamB)
            matches.append(match)
        }

        return matches
    }
}
