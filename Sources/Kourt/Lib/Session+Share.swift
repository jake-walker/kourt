//
//  Session+Share.swift
//  kourt-app
//
//  Created by Jake Walker on 22/02/2026.
//

import KourtShared
#if !os(Android)
    import Playgrounds
#endif

extension Session {
    var shareText: String {
        let header = "\(typeSummary) Session - \(date.formatted(.dateTime.day().month(.abbreviated).year()))"
        let showCourts = courts > 1
        var lines: [String] = []

        for court in 0 ..< courts {
            let matches = matches.filter { $0.court == court }

            if showCourts {
                lines.append("Court \(court + 1):")
            }

            for (i, match) in matches.enumerated() {
                let teamA = match.teamAPlayers(from: players).map(\.name).joined(separator: " & ")
                let teamB = match.teamBPlayers(from: players).map(\.name).joined(separator: " & ")
                lines.append("\(i + 1). \(teamA) vs \(teamB)")
            }
        }

        return header + "\n\n" + lines.joined(separator: "\n")
    }
}

#if !os(Android)
    #Playground {
        var session = Session(
            players: [.init(name: "A"), .init(name: "B"), .init(name: "C"), .init(name: "D")],
        )

        for _ in 0 ..< 5 {
            try session.matchGroups.append(session.generateNext())
        }

        print(session.shareText)
    }
#endif
