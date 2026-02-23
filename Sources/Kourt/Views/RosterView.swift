//
//  RosterView.swift
//  kourt-app
//
//  Created by Jake Walker on 22/02/2026.
//

import Algorithms
import SwiftUI

struct RosterView: View {
    @Environment(ViewModel.self) var viewModel: ViewModel

    @State var showingAddPlayer: Bool = false
    @State var newPlayerName: String = ""

    var recentPlayers: [Player] {
        viewModel.sessions
            .suffix(2)
            .flatMap(\.players)
            .filter { player in
                !viewModel.roster.contains { $0.id == player.id || $0.name == player.name }
            }
            .uniqued(on: \.name)
    }

    private func addPlayer(_ name: String) {
        viewModel.roster.append(.init(name: name))
    }

    private func deletePlayer(at offsets: IndexSet) {
        viewModel.roster.remove(atOffsets: offsets)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if viewModel.roster.isEmpty, recentPlayers.isEmpty {
                EmptyStateView(
                    title: "No Players Yet",
                    label: "Add the people you regularly play with to quickly set up future sessions.",
                    actionText: "Add Player",
                    actionIcon: "plus",
                    action: {
                        showingAddPlayer = true
                    },
                )
            } else {
                List {
                    if !viewModel.roster.isEmpty {
                        Section("My Players") {
                            ForEach(viewModel.roster) { player in
                                Text(player.name)
                            }
                            .onDelete(perform: deletePlayer)
                        }
                    }

                    Section("Recent Players") {
                        ForEach(recentPlayers) { player in
                            Label(player.name, systemImage: "plus")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .onTapGesture {
                                    viewModel.roster.append(player)
                                }
                        }
                    }
                }
            }

            #if os(Android)
                AndroidFab(onClick: {
                    showingAddPlayer = true
                }, icon: .add)
                    .padding()
            #endif
        }
        #if !os(Android)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Player", systemImage: "plus") {
                    showingAddPlayer = true
                }
            }
        }
        #endif
        .alert("Add Player", isPresented: $showingAddPlayer) {
            TextField("Name", text: $newPlayerName)

            Button("Cancel", role: .cancel) {
                newPlayerName = ""
            }

            Button("Add") {
                addPlayer(newPlayerName)
                newPlayerName = ""
            }
        }
        .navigationTitle("My Players")
    }
}

#if !os(Android)
    #Preview {
        NavigationView {
            RosterView()
                .environment(ViewModel())
        }
    }
#endif
