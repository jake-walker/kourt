//
//  SessionListView.swift
//  kourt-app
//
//  Created by Jake Walker on 19/02/2026.
//

import SwiftUI

struct SessionListView : View {
    @Environment(ViewModel.self) var viewModel: ViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.sessions) { session in
                Button {
                    viewModel.currentSessionID = session.id
                    viewModel.navigationPath.append(AppDestination.session(session.id))
                } label: {
                    Text(session.id.uuidString)
                    Text(session.date.ISO8601Format())
                }
            }
        }
    }
}

#if !os(Android)
#Preview {
    SessionListView()
        .environment(ViewModel())
}
#endif
