// Licensed under the GNU General Public License v3.0 or later
// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import Observation
import SkipFuse
import SwiftUI

/// The Observable ViewModel used by the application.
@Observable public class ViewModel {
    var navigationPath = NavigationPath()
    
    var sessions: [Session] = loadSessions() {
        didSet { saveSessions() }
    }
    
    var currentSessionID: Session.ID?
    
    var currentSession: Session? {
        get {
            guard let id = currentSessionID else { return nil }
            return sessions.first { $0.id == id }
        }
        set {
            guard let newValue else { return }
            if let index = sessions.firstIndex(where: { $0.id == newValue.id }) {
                sessions[index] = newValue
            }
        }
    }
    
    init() {
    }
    
    func clear() {
        sessions.removeAll()
    }
    
//    func isUpdated(_ item: Item) -> Bool {
//        item != items.first { i in
//            i.id == item.id
//        }
//    }
//    
//    func save(item: Item) {
//        items = items.map { i in
//            i.id == item.id ? item : i
//        }
//    }
}

struct Session : Identifiable, Hashable, Codable {
    let id: UUID
    var date: Date
    var players: [Player]
    var courts: Int
    var teamSize: Int
    var matchGroups: [[Match]]
    
    var matches: [Match] {
        return matchGroups.flatMap { $0 }
    }

    init(id: UUID = UUID(), date: Date = .now, players: [Player] = [], courts: Int = 1, teamSize: Int = 2) {
        self.id = id
        self.date = date
        self.courts = courts
        self.teamSize = teamSize
        self.players = players
        self.matchGroups = []
    }
}

struct Player: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    
    init(id: UUID = UUID(), name: String) {
        self.id = id
        self.name = name
    }
}

struct Match : Identifiable, Hashable, Codable {
    let id: UUID
    let court: Int
    let teamA: [UUID]
    let teamB: [UUID]
    
    init(id: UUID = UUID(), court: Int, teamA: [UUID], teamB: [UUID]) {
        self.id = id
        self.court = court
        self.teamA = teamA
        self.teamB = teamB
    }
}

extension ViewModel {
    private static let savePath = URL.applicationSupportDirectory.appendingPathComponent("appdata.json")

    fileprivate static func loadSessions() -> [Session] {
        do {
            let start = Date.now
            let data = try Data(contentsOf: savePath)
            defer {
                let end = Date.now
                logger.info("loaded \(data.count) bytes from \(Self.savePath.path) in \(end.timeIntervalSince(start)) seconds")
            }
            return try JSONDecoder().decode([Session].self, from: data)
        } catch {
            // perhaps the first launch, or the data could not be read
            logger.warning("failed to load data from \(Self.savePath), using defaultItems: \(error)")
            return []
        }
    }

    fileprivate func saveSessions() {
        do {
            let start = Date.now
            let data = try JSONEncoder().encode(sessions)
            try FileManager.default.createDirectory(at: URL.applicationSupportDirectory, withIntermediateDirectories: true)
            try data.write(to: Self.savePath)
            let end = Date.now
            logger.info("saved \(data.count) bytes to \(Self.savePath.path) in \(end.timeIntervalSince(start)) seconds")
        } catch {
            logger.error("error saving data: \(error)")
        }
    }
}
