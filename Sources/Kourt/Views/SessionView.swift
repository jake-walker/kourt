//
//  SessionView.swift
//  kourt-app
//
//  Created by Jake Walker on 19/02/2026.
//

import SwiftUI

struct CurrentMatch: View {
    @Environment(ViewModel.self) var viewModel: ViewModel
    
    private func nextMatch() {
        guard let currentSession = viewModel.currentSession else {
            return
        }
        
        if currentSession.currentIndex < currentSession.matchGroups.count - 1 {
            viewModel.currentSession?.currentIndex += 1
            return
        }
        
        guard let nextMatches = viewModel.currentSession?.nextMatches() else {
            return
        }
        
        viewModel.currentSession?.matchGroups.append(nextMatches)
        viewModel.currentSession?.currentIndex += 1
    }
    
    var nextButton: some View {
        Button(action: nextMatch) {
            Label("Next", systemImage: "arrow.forward")
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(8)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            if let session = viewModel.currentSession,
               let currentGroup = session.currentMatches {
                ForEach(Array(currentGroup.enumerated()), id: \.element.id) { index, match in
                    if index > 0 {
                        Divider()
                            .padding([.top, .bottom], 8)
                    }
                    
                    if session.courts > 1 {
                        Text("Court \(match.court+1):")
                            .font(.headline)
                    }
                    
                    HStack {
                        VStack(spacing: 8) {
                            ForEach(match.teamAPlayers(from: session.players), id: \.id) { player in
                                Text(player.name)
                                    .font(.system(size: 24))
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        
                        Text("vs.")
                            .padding()
                        
                        VStack(spacing: 8) {
                            ForEach(match.teamBPlayers(from: session.players), id: \.id) { player in
                                Text(player.name)
                                    .font(.system(size: 24))
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            
            #if !os(Android)
            if #available(iOS 26.0, *) {
                nextButton
                    .buttonStyle(.glassProminent)
                    .frame(maxWidth: .infinity)
            } else {
                nextButton
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
            }
            #else
            nextButton
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
            #endif
        }
    }
}

struct MatchItem : View {
    let sessionPlayers: [Player]
    let match: Match
    let index: Int
    let showCourt: Bool
    let isCurrent: Bool
    
    private var title: String {
        let teamA = match.teamAPlayers(from: sessionPlayers).map(\.name)
        let teamB = match.teamBPlayers(from: sessionPlayers).map(\.name)
        
        return "\(teamA.joined(separator: " and ")) vs. \(teamB.joined(separator: " and "))"
    }
    
    var body: some View {
        HStack {
            if isCurrent {
                Image(systemName: "play.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundStyle(.green)
                    .frame(width: 18, height: 18)
                    .padding(.trailing, 4)
            } else {
                Rectangle()
                    .fill(.clear)
                    .frame(width: 18, height: 18)
                    .padding(.trailing, 4)
            }
            
            VStack(alignment: .leading) {
                Text(title)
                HStack {
                    Text("Match \(index+1)")
                    
                    if showCourt {
                        Text("Court \(match.court + 1)")
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
        }
    }
}

struct SessionView : View {
    @Environment(ViewModel.self) var viewModel: ViewModel
    
    var body: some View {
        if let session = viewModel.currentSession {
            List {
                Section {
                    CurrentMatch()
                        .environment(viewModel)
                        .frame(maxWidth: .infinity)
                        .padding()
                } header: {
                    HStack {
                        Text(session.date, format: .dateTime.day().month(.abbreviated).year().weekday().hour().minute())
                        Text(inflect(session.players.count, singular: "player", plural: "players"))
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                    
                if !session.matches.isEmpty {
                    Section("Matches") {
                        ForEach(session.matchGroups.indices, id: \.self) { groupIdx in
                            ForEach(session.matchGroups[groupIdx], id: \.id) { match in
                                MatchItem(
                                    sessionPlayers: session.players,
                                    match: match,
                                    index: groupIdx,
                                    showCourt: session.courts > 1,
                                    isCurrent: session.currentIndex == groupIdx
                                )
                                .onTapGesture {
                                    viewModel.currentSession?.currentIndex = groupIdx
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("\(session.typeSummary) Session")
            .onAppear {
                if session.matchGroups.isEmpty {
                    guard let nextMatches = viewModel.currentSession?.nextMatches() else {
                        return
                    }
                    
                    viewModel.currentSession?.matchGroups.append(nextMatches)
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
