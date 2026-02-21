//
//  Generator.swift
//  kourt-app
//
//  Created by Jake Walker on 19/02/2026.
//

import Algorithms
import Foundation

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

    private func getNextPlayer(excluding: Set<UUID> = []) -> UUID? {
        let candidates = playerCounter
            .filter { !excluding.contains($0.key) }

        let sorted = candidates.sorted { $0.value < $1.value }
            .map(\.key)

        return sorted.first
    }

    private func getComboWeight(for combo: Set<UUID>) -> Int {
        var weight = 0

        weight += playerComboCounter[combo, default: 0]
        weight += combo.map { self.playerCounter[$0, default: 0] }
            .reduce(0, +)

        return weight
    }

    private func getNextCombo(for player: UUID, excluding: Set<UUID> = []) -> UUID? {
        var candidates = playerComboCounter
            .filter { $0.key.isDisjoint(with: excluding) }

        for key in candidates.keys {
            candidates[key] = getComboWeight(for: key)
        }

        candidates = candidates.filter { $0.key.contains(player) }

        let sorted = candidates.sorted { $0.value < $1.value }

        return sorted.first?.key.filter { $0 != player }.first
    }

    private func getNextTeam(excluding: Set<UUID> = []) -> Set<UUID>? {
        guard let player1 = getNextPlayer(excluding: excluding),
              let player2 = getNextCombo(for: player1, excluding: excluding)
        else {
            return nil
        }

        return Set([player1, player2])
    }

    private func getNextDoublesMatch(court: Int, excluding: Set<UUID> = []) -> Match? {
        guard let teamA = getNextTeam(excluding: excluding),
              let teamB = getNextTeam(excluding: excluding.union(teamA))
        else {
            return nil
        }

        if !teamA.isDisjoint(with: teamB) {
            print("Generate fail: player is in both teams (teamA=\(teamA), teamB=\(teamB))")
            return nil
        }

        return Match(court: court, teamA: teamA, teamB: teamB)
    }

    private func getNextSinglesMatch(court: Int, excluding: Set<UUID> = []) -> Match? {
        guard let players = getNextTeam(excluding: excluding) else {
            return nil
        }

        let playersArray = Array(players)

        return Match(court: court, teamA: Set(arrayLiteral: playersArray[0]), teamB: Set(arrayLiteral: playersArray[1]))
    }

    func generateNext() -> [Match] {
        var matches: [Match] = []
        var usedPlayers: Set<UUID> = []

        for i in 0 ..< courts {
            if let match = teamSize == 1 ? getNextSinglesMatch(court: i, excluding: usedPlayers) : getNextDoublesMatch(court: i, excluding: usedPlayers) {
                usedPlayers.formUnion(match.teamA)
                usedPlayers.formUnion(match.teamB)
                matches.append(match)
            }
        }

        return matches
    }
}
