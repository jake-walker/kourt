//
//  TeamAnalyticsView.swift
//  kourt-app
//
//  Created by Jake Walker on 05/03/2026.
//

import Charts
import KourtShared
import SwiftUI

struct TeamAnalyticsView: View {
    let analytics: SessionAnalytics
    let session: Session

    func playerNames(for ids: Set<Player.ID>) -> String {
        ids.compactMap { id in
            session.players.first { $0.id == id }?.name
        }
        .sorted()
        .joined(separator: " & ")
    }

    var sortedTeams: [(Set<Player.ID>, Int)] {
        analytics.winsByTeam
            .sorted { $0.value > $1.value }
    }

    var body: some View {
        VStack(spacing: 24) {
            AnalyticsCard(title: "Best Teams") {
                if sortedTeams.isEmpty {
                    Text("No wins recorded yet")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    ForEach(Array(sortedTeams.prefix(5).enumerated()), id: \.offset) { index, entry in
                        HStack {
                            Text(index == 0 ? "🥇" : index == 1 ? "🥈" : index == 2 ? "🥉" : "\(index + 1).")
                                .frame(width: 28, alignment: .leading)

                            Text(playerNames(for: entry.0))

                            Spacer()

                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(entry.1)W / \(analytics.matchesByTeam[entry.0] ?? 0)P")
                                    .font(.subheadline)
                                Text("\(String(format: "%.0f", (analytics.winRateByTeam[entry.0] ?? 0) * 100))%")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)

                        if index < min(4, sortedTeams.count - 1) {
                            Divider()
                        }
                    }
                }
            }

            if !analytics.unbeatenTeams.isEmpty {
                AnalyticsCard(title: "Unbeaten Teams") {
                    ForEach(Array(analytics.unbeatenTeams.enumerated()), id: \.offset) { index, team in
                        HStack {
                            Image(systemName: "shield.fill")
                                .foregroundStyle(.green)
                            Text(playerNames(for: team))
                            Spacer()
                            Text("\(analytics.matchesByTeam[team] ?? 0)P")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        }
                        .padding(.vertical, 2)

                        if index < analytics.unbeatenTeams.count - 1 {
                            Divider()
                        }
                    }
                }
            }

            AnalyticsCard(title: "Team Win Rates") {
                Chart(sortedTeams.prefix(5), id: \.0) { entry in
                    BarMark(
                        x: .value("Pair", playerNames(for: entry.0)),
                        y: .value("Win Rate", (analytics.winRateByTeam[entry.0] ?? 0) * 100),
                    )
                    .foregroundStyle(Color.accentColor)
                }
                .frame(height: 180)
            }
        }
    }
}

#if !os(Android)
    #Preview {
        ScrollView {
            TeamAnalyticsView(analytics: SessionAnalytics(session: Session.sampleAnalyticsSession), session: Session.sampleAnalyticsSession)
        }
    }
#endif
