// Licensed under the GNU General Public License v3.0 or later
// SPDX-License-Identifier: GPL-3.0-or-later

import Foundation
import KourtShared
import Observation
import SkipFuse
import SwiftUI

/// The Observable ViewModel used by the application.
@Observable public class ViewModel {
    var navigationPath = NavigationPath()

    var sessions: [Session] = loadSessions() {
        didSet { saveSessions() }
    }

    var roster: [Player] = loadRoster() {
        didSet { saveRoster() }
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

    init() {}

    func clear() {
        sessions.removeAll()
    }

    func removeSession(id: Session.ID) {
        sessions.removeAll { $0.id == id }
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

private extension ViewModel {
    private static let savePath = URL.applicationSupportDirectory.appendingPathComponent("appdata.json")

    static func loadSessions() -> [Session] {
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
            logger.warning("failed to load data from \(savePath), using defaultItems: \(error)")
            return []
        }
    }

    func saveSessions() {
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

    private static let rosterSavePath = URL.applicationSupportDirectory.appendingPathComponent("rosterdata.json")

    static func loadRoster() -> [Player] {
        do {
            let start = Date.now
            let data = try Data(contentsOf: rosterSavePath)
            defer {
                let end = Date.now
                logger.info("loaded roster: \(data.count) bytes from \(rosterSavePath.path) in \(end.timeIntervalSince(start)) seconds")
            }
            return try JSONDecoder().decode([Player].self, from: data)
        } catch {
            // Initial launch or failed read
            logger.warning("failed to load roster from \(rosterSavePath), using empty: \(error)")
            return []
        }
    }

    func saveRoster() {
        do {
            let start = Date.now
            let data = try JSONEncoder().encode(roster)
            try FileManager.default.createDirectory(at: URL.applicationSupportDirectory, withIntermediateDirectories: true)
            try data.write(to: Self.rosterSavePath)
            let end = Date.now
            logger.info("saved roster: \(data.count) bytes to \(Self.rosterSavePath.path) in \(end.timeIntervalSince(start)) seconds")
        } catch {
            logger.error("error saving roster: \(error)")
        }
    }
}
