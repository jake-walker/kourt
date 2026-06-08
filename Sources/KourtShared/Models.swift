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
    public var disabledPlayerIDs: Set<Player.ID>
    public var playerMatchCountAdjustments: [Player.ID: Int]

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

    public var activePlayers: [Player] {
        players.filter { !disabledPlayerIDs.contains($0.id) }
    }

    public var inactivePlayers: [Player] {
        players.filter { disabledPlayerIDs.contains($0.id) }
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

        return activePlayers.filter { !matchPlayers.contains($0.id) }
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
        disabledPlayerIDs = []
        playerMatchCountAdjustments = [:]
        matchGroups = []
    }

    public func player(withId id: Player.ID) -> Player? {
        players.first(where: { $0.id == id })
    }

    public mutating func addPlayer(_ player: Player) {
        let baseline = activePlayerBaselineMatchCount()
        players.append(player)
        disabledPlayerIDs.remove(player.id)
        setMatchCountAdjustment(for: player.id, baseline: baseline)
        invalidateFutureMatches()
    }

    @discardableResult
    public mutating func addPlayer(name: String) -> Player {
        let player = Player(name: name)
        addPlayer(player)
        return player
    }

    public mutating func enablePlayer(withId id: Player.ID) {
        setPlayer(withId: id, enabled: true)
    }

    public mutating func disablePlayer(withId id: Player.ID) {
        setPlayer(withId: id, enabled: false)
    }

    public mutating func setPlayer(withId id: Player.ID, enabled: Bool) {
        guard players.contains(where: { $0.id == id }) else {
            return
        }

        let wasDisabled = disabledPlayerIDs.contains(id)
        let baseline = activePlayerBaselineMatchCount()

        if enabled {
            disabledPlayerIDs.remove(id)
            if wasDisabled {
                setMatchCountAdjustment(for: id, baseline: baseline)
            }
        } else {
            disabledPlayerIDs.insert(id)
        }

        if enabled {
            invalidateFutureMatches()
        } else {
            invalidateFutureMatches(containing: [id])
        }
    }

    public mutating func invalidateFutureMatches() {
        let startIndex = currentIndex + 1

        guard startIndex >= 0, startIndex < matchGroups.count else {
            return
        }

        matchGroups.removeSubrange(startIndex...)
    }

    public mutating func invalidateFutureMatches(containing playerIds: Set<Player.ID>) {
        let startIndex = currentIndex + 1

        guard startIndex >= 0, startIndex < matchGroups.count else {
            return
        }

        guard let firstInvalidIndex = matchGroups[startIndex...].firstIndex(where: { matchGroup in
            matchGroup.contains { match in
                !match.teamA.union(match.teamB).isDisjoint(with: playerIds)
            }
        }) else {
            return
        }

        matchGroups.removeSubrange(firstInvalidIndex...)
    }

    private func matchCount(for playerId: Player.ID) -> Int {
        matches.reduce(into: 0) { count, match in
            if match.teamA.contains(playerId) || match.teamB.contains(playerId) {
                count += 1
            }
        }
    }

    private func adjustedMatchCount(for playerId: Player.ID) -> Int {
        matchCount(for: playerId) + playerMatchCountAdjustments[playerId, default: 0]
    }

    private func activePlayerBaselineMatchCount() -> Int {
        let counts = activePlayers.map { adjustedMatchCount(for: $0.id) }

        return counts.max() ?? 0
    }

    private mutating func setMatchCountAdjustment(for playerId: Player.ID, baseline: Int) {
        // Players who join or re-enter mid-session should not be treated as needing to
        // catch up on every missed round. Start them at the active roster's high-water mark.
        let adjustment = max(0, baseline - matchCount(for: playerId))

        if adjustment > 0 {
            playerMatchCountAdjustments[playerId] = adjustment
        } else {
            playerMatchCountAdjustments.removeValue(forKey: playerId)
        }
    }

    enum CodingKeys: String, CodingKey {
        case id
        case date
        case players
        case courts
        case teamSize
        case matchGroups
        case currentIndex
        case disabledPlayerIDs
        case playerMatchCountAdjustments
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        players = try container.decode([Player].self, forKey: .players)
        courts = try container.decode(Int.self, forKey: .courts)
        teamSize = try container.decode(Int.self, forKey: .teamSize)
        matchGroups = try container.decode([[Match]].self, forKey: .matchGroups)
        currentIndex = try container.decodeIfPresent(Int.self, forKey: .currentIndex) ?? 0
        disabledPlayerIDs = try container.decodeIfPresent(Set<Player.ID>.self, forKey: .disabledPlayerIDs) ?? []
        playerMatchCountAdjustments = try container.decodeIfPresent([Player.ID: Int].self, forKey: .playerMatchCountAdjustments) ?? [:]
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(players, forKey: .players)
        try container.encode(courts, forKey: .courts)
        try container.encode(teamSize, forKey: .teamSize)
        try container.encode(matchGroups, forKey: .matchGroups)
        try container.encode(currentIndex, forKey: .currentIndex)
        try container.encode(disabledPlayerIDs, forKey: .disabledPlayerIDs)
        try container.encode(playerMatchCountAdjustments, forKey: .playerMatchCountAdjustments)
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
