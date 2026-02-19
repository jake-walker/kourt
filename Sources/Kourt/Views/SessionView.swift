//
//  SessionView.swift
//  kourt-app
//
//  Created by Jake Walker on 19/02/2026.
//

import SwiftUI

struct MatchItem : View {
    let sessionPlayers: [Player]
    let match: Match
    let index: Int
    
    private var title: String {
        let teamA = match.teamA.map { id in
            sessionPlayers.first(where: { $0.id == id })?.name ?? "Unknown"
        }
        let teamB = match.teamB.map { id in
            sessionPlayers.first(where: { $0.id == id })?.name ?? "Unknown"
        }
        
        return "\(teamA.joined(separator: " and ")) vs. \(teamB.joined(separator: " and "))"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Match \(index+1)")
            Text(title)
        }
    }
}

struct SessionView : View {
    @Environment(ViewModel.self) var viewModel: ViewModel
    
    var body: some View {
        if let session = viewModel.currentSession {
            List {
                Section("Matches (\(session.matches.count))") {
                    ForEach(session.matches.indices) { index in
                        MatchItem(sessionPlayers: session.players, match: session.matches[index], index: index)
                    }
                }
            }
            .navigationTitle(session.id.uuidString)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Add Matches", systemImage: "plus") {
                        // generate matches
                        let matches = try? generateMatchesJs(count: 40, players: session.players.map(\.id), courtCount: session.courts, teamSize: session.teamSize)
                        
                        viewModel.currentSession?.matchGroups = matches ?? []
                    }
                }
            }
        } else {
            Text("No session")
        }
    }
}

#if !os(Android)
#Preview {
    let viewModel = ViewModel()
    viewModel.currentSessionID = viewModel.sessions.first?.id
    
    return NavigationView {
        SessionView()
            .environment(viewModel)
    }
}
#endif
