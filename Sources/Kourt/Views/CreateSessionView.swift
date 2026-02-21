//
//  CreateSessionView.swift
//  kourt-app
//
//  Created by Jake Walker on 19/02/2026.
//

import SwiftUI

struct CreateSessionView: View {
    @Environment(ViewModel.self) var viewModel: ViewModel
    @Environment(\.dismiss) var dismiss
    @State var session: Session = .init()

    var requiredPlayers: Int {
        session.courts * (session.teamSize * 2)
    }

    var validSession: Bool {
        session.players.count >= requiredPlayers
            && session.courts > 0
            && session.players.allSatisfy { !$0.name.isEmpty }
    }

    private func deletePlayer(at offsets: IndexSet) {
        session.players.remove(atOffsets: offsets)
    }

    private func createSession() {
        viewModel.sessions.append(session)
        viewModel.currentSessionID = session.id
        viewModel.navigationPath = NavigationPath([AppDestination.session(session.id)])
        dismiss()
    }

    var body: some View {
        Form {
            Section(header: Text("Details")) {
                Picker("Courts", selection: $session.courts) {
                    ForEach(1 ..< 11) { number in
                        Text("\(number)").tag(number)
                    }
                }
                Picker("Team Size", selection: $session.teamSize) {
                    Text("Singles").tag(1)
                    Text("Doubles").tag(2)
                }
            }

            Section(
                header: Text("Players"),
                footer: Text("At least \(inflect(requiredPlayers, singular: "player", plural: "players")) are needed for this session."),
            ) {
                ForEach($session.players.indices, id: \.self) { idx in
                    TextField("Player \(idx + 1) Name", text: $session.players[idx].name)
                    #if os(Android)
                        .textFieldStyle(.plain)
                    #endif
                }
                .onDelete(perform: deletePlayer)

                Button("Add Player", systemImage: "plus") {
                    session.players.append(.init(name: ""))
                }
            }

            #if os(Android)
                Section {
                    Button("Create Session", systemImage: "checkmark", action: createSession)
                        .disabled(!validSession)
                    Button("Cancel", systemImage: "xmark") {
                        dismiss()
                    }
                }
            #endif
        }
        .navigationTitle("New Session")
        #if !os(Android)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: createSession) {
                        Label("Create Session", systemImage: "checkmark")
                    }
                    .disabled(!validSession)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", systemImage: "xmark", role: .cancel) {
                        dismiss()
                    }
                }
            }
        #endif
    }
}

#if !os(Android)
    #Preview {
        NavigationView {
            CreateSessionView()
                .environment(ViewModel())
        }
    }
#endif
