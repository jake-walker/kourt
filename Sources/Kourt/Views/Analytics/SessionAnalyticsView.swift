//
//  SessionAnalyticsView.swift
//  kourt-app
//
//  Created by Jake Walker on 05/03/2026.
//

import KourtShared
import SwiftUI

struct SessionAnalyticsView: View {
    let session: Session
    @State var selectedTab: AnalyticsTab = .players

    private var analytics: SessionAnalytics {
        SessionAnalytics(session: session)
    }

    enum AnalyticsTab {
        case players, team
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Picker("Analytics", selection: $selectedTab) {
                    Text("Players").tag(AnalyticsTab.players)
                    Text("Pairs").tag(AnalyticsTab.team)
                }
                .pickerStyle(.segmented)

                switch selectedTab {
                case .players:
                    PlayerAnalyticsView(analytics: analytics, session: session)
                case .team:
                    TeamAnalyticsView(analytics: analytics, session: session)
                }
            }
            .padding()
        }
        .navigationTitle("Session Analytics")
    }
}

#if !os(Android)
    #if DEBUG
        extension Session {
            static var sampleAnalyticsSession: Session {
                var session = Session(players: [
                    .init(name: "Alice"),
                    .init(name: "Bob"),
                    .init(name: "Charlie"),
                    .init(name: "Denise"),
                    .init(name: "Ellie"),
                ], courts: 1, teamSize: 2)

                session.advance(by: 10)

                for i in 0 ..< session.matchGroups.count {
                    session.matchGroups[i][0].winner = Team.allCases.randomElement()!
                }

                return session
            }
        }
    #endif

    #Preview {
        NavigationStack {
            SessionAnalyticsView(session: Session.sampleAnalyticsSession)
        }
    }
#endif
