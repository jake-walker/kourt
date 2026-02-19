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
    @State var session: Session = Session()
    
    var body: some View {
        Form {
            Section(header: Text("Session")) {
//                Picker("Courts", selection: $session.courts) {
//                    ForEach(1..<11) { number in
//                        Text("\(number)").tag(number)
//                    }
//                }
                Picker("Team Size", selection: $session.teamSize) {
                    Text("Singles").tag(1)
                    Text("Doubles").tag(2)
                }
            }
            
            Section(header: Text("Players")) {
                ForEach($session.players) { $player in
                    HStack {
                        TextField("Player Name", text: $player.name)
                        Spacer()
                        Button(role: .destructive) {
                            session.players.removeAll { $0.id == player.id }
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                }
                
                Button("Add Player", systemImage: "plus") {
                    session.players.append(.init(name: ""))
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                Button(action: {
                    viewModel.sessions.append(session)
                    viewModel.currentSessionID = session.id
                    viewModel.navigationPath = NavigationPath([AppDestination.session(session.id)])
                }) {
                    Label("Create Session", systemImage: "checkmark")
                }
            }
        }
    }
}

#if !os(Android)
#Preview {
    CreateSessionView()
        .environment(ViewModel())
}
#endif
