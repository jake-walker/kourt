//
//  PlayerAnalyticsView.swift
//  kourt-app
//
//  Created by Jake Walker on 05/03/2026.
//

import Charts
import KourtShared
import SwiftUI

struct PlayerAnalyticsView: View {
    let analytics: SessionAnalytics
    let session: Session

    var sortedPlayers: [Player] {
        session.players.sorted {
            (analytics.winsByPlayer[$0.id] ?? 0) > (analytics.winsByPlayer[$1.id] ?? 0)
        }
    }

    var streaks: [(Player, Int)] {
        session.players
            .compactMap { player -> (Player, Int)? in
                let streak = analytics.bestWinStreakByPlayer[player.id] ?? 0
                return streak > 0 ? (player, streak) : nil
            }
            .sorted { $0.1 > $1.1 }
    }

    var body: some View {
        VStack(spacing: 24) {
            AnalyticsCard(title: "Wins") {
                Chart(session.players) { player in
                    BarMark(
                        x: .value("Player", player.name),
                        y: .value("Wins", analytics.winsByPlayer[player.id] ?? 0),
                    )
                    .foregroundStyle(Color.accentColor)
                }
                .frame(height: 200)
            }

            AnalyticsCard(title: "Matches Played") {
                Chart(session.players) { player in
                    BarMark(
                        x: .value("Player", player.name),
                        y: .value("Matches", analytics.matchesByPlayer[player.id] ?? 0),
                    )
                    .foregroundStyle(.secondary)
                }
                .frame(height: 200)
            }

            AnalyticsCard(title: "Leaderboard") {
                ForEach(Array(sortedPlayers.prefix(5).enumerated()), id: \.offset) { index, player in
                    HStack {
                        Text(index == 0 ? "🥇" : index == 1 ? "🥈" : index == 2 ? "🥉" : "\(index + 1).")
                            .frame(width: 28, alignment: .leading)

                        Text(player.name)

                        Spacer()

                        VStack(alignment: .trailing, spacing: 2) {
                            Text("\(analytics.winsByPlayer[player.id] ?? 0)W / \(analytics.matchesByPlayer[player.id] ?? 0)P")
                                .font(.subheadline)
                            Text("\(String(format: "%.0f", (analytics.winRateByPlayer[player.id] ?? 0) * 100))%")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 2)
                    }

                    if index < min(4, sortedPlayers.count - 1) {
                        Divider()
                    }
                }
            }

            AnalyticsCard(title: "Best Win Streaks") {
                if streaks.isEmpty {
                    Text("No wins recorded yet")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                } else {
                    VStack {
                        ForEach(Array(streaks.prefix(5).enumerated()), id: \.offset) { index, entry in
                            HStack {
                                Text(entry.0.name)
                                Spacer()
                                HStack {
                                    ForEach(0 ..< min(entry.1, 5), id: \.self) { _ in
                                        Image(systemName: "flame.fill")
                                            .foregroundStyle(.orange)
                                            .font(.caption)
                                    }

                                    if entry.1 > 5 {
                                        Text("+\(entry.1 - 5)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            .padding(.vertical, 2)

                            if index < min(4, streaks.count - 1) {
                                Divider()
                            }
                        }
                    }
                }
            }
        }
    }
}

#if !os(Android)
    #Preview {
        ScrollView {
            PlayerAnalyticsView(analytics: SessionAnalytics(session: Session.sampleAnalyticsSession), session: Session.sampleAnalyticsSession)
        }
    }
#endif
