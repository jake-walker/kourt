//
//  SessionListView.swift
//  kourt-app
//
//  Created by Jake Walker on 19/02/2026.
//

import SwiftUI

struct SessionListView : View {
    @Environment(ViewModel.self) var viewModel: ViewModel
    
    @State var isAdding = false
    @State var searchText = ""
    
    var filteredSessions: [Session] {
        if searchText.isEmpty {
            viewModel.sessions
                .sorted { $0.date > $1.date }
        } else {
            viewModel.sessions
                .filter { $0.date.formatted().localizedCaseInsensitiveContains(searchText) || $0.playerSummary.localizedCaseInsensitiveContains(searchText) }
                .sorted { $0.date > $1.date }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let toDelete = filteredSessions[index]
            viewModel.removeSession(id: toDelete.id)
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            List {
                ForEach(filteredSessions) { session in
                    Button(action: {
                        viewModel.currentSessionID = session.id
                        viewModel.navigationPath.append(AppDestination.session(session.id))
                    }) {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(session.date, format: .dateTime.day().month(.abbreviated).year().weekday().hour().minute())
                                    .lineLimit(1)
                                
                                Text(session.players.isEmpty ? "\(session.typeSummary) with no players" : "\(session.typeSummary) with \(session.playerSummary)")
                                    .lineLimit(2)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                }
                .onDelete(perform: delete)
            }
            .searchable(text: $searchText)
            
#if os(Android)
            AndroidFab(onClick: {
                isAdding = true
            })
            .padding()
#endif
        }
        .navigationTitle("Sessions")
        .toolbar {
#if !os(Android)
            ToolbarItem(placement: .primaryAction) {
                Button("Add Session", systemImage: "plus") {
                    isAdding = true
                }
            }
#endif
        }
        .sheet(isPresented: $isAdding) {
#if !os(Android)
            NavigationView {
                CreateSessionView()
            }
            .presentationDetents([.medium, .large])
#else
            CreateSessionView()
#endif
        }
    }
}

#if !os(Android)
#Preview {
    NavigationView {
        SessionListView()
            .environment(ViewModel())
    }
}
#endif
