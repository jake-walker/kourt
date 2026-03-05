//
//  Models.swift
//  kourt-app
//
//  Created by Jake Walker on 26/02/2026.
//

import Foundation

public struct Session: Identifiable, Hashable, Codable, Sendable, CustomStringConvertible {
    public let id: UUID
    public var date: Date
    public var players: [Player]
    public var courts: Int
    public var teamSize: Int
    public var matchGroups: [[Match]]
    public var currentIndex: Int = 0

    public var description: String {
        var meta: [String] = [
            "\(players.count) players",
            "\(courts) court",
        ]

        if matchGroups.count > 0 {
            meta.append("\(matchGroups.count) matches")
        }

        return "\(typeSummary) Session (\(meta.joined(separator: ", ")))"
    }

    public var matches: [Match] {
        matchGroups.flatMap(\.self)
    }

    public var currentMatches: [Match]? {
        guard currentIndex >= 0, currentIndex < matchGroups.count else {
            return nil
        }

        return matchGroups[currentIndex]
    }

    public var currentBench: [Player] {
        guard let currentMatches else {
            return []
        }

        let matchPlayers = currentMatches
            .compactMap { $0.teamA.union($0.teamB) }
            .reduce(into: Set<UUID>()) { $0.formUnion($1) }

        return players.filter { !matchPlayers.contains($0.id) }
    }

    public var nextMatches: [Match]? {
        guard currentIndex + 1 < matchGroups.count else {
            return nil
        }

        return matchGroups[currentIndex + 1]
    }

    public var playerSummary: String {
        prettyJoinStrings(players.map(\.name))
    }

    public var typeSummary: String {
        switch teamSize {
        case 2:
            "Doubles"
        default:
            "Singles"
        }
    }

    public init(id: UUID = UUID(), date: Date = .now, players: [Player] = [], courts: Int = 1, teamSize: Int = 2) {
        self.id = id
        self.date = date
        self.courts = courts
        self.teamSize = teamSize
        self.players = players
        matchGroups = []
    }

    public func player(withId id: Player.ID) -> Player? {
        players.first(where: { $0.id == id })
    }
}

public struct Player: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public var name: String

    public init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

public struct Match: Identifiable, Hashable, Codable, Sendable {
    public let id: UUID
    public let court: Int
    public let teamA: Set<UUID>
    public let teamB: Set<UUID>

    public init(id: UUID = UUID(), court: Int, teamA: Set<UUID>, teamB: Set<UUID>) {
        self.id = id
        self.court = court
        self.teamA = teamA
        self.teamB = teamB
    }

    public func teamAPlayers(from sessionPlayers: [Player]) -> [Player] {
        teamA
            .map { id in sessionPlayers.first(where: { $0.id == id }) ?? Player(id: id, name: "Unknown") }
            .sorted { $0.name < $1.name }
    }

    public func teamBPlayers(from sessionPlayers: [Player]) -> [Player] {
        teamB
            .map { id in sessionPlayers.first(where: { $0.id == id }) ?? Player(id: id, name: "Unknown") }
            .sorted { $0.name < $1.name }
    }
}
