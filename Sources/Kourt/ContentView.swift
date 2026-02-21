// Licensed under the GNU General Public License v3.0 or later
// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

enum ContentTab: String, Hashable {
    case welcome, home, settings
}

enum AppDestination: Hashable {
    case session(Session.ID)
    case newSession
    case settings
}

struct ContentView: View {
    @State var viewModel = ViewModel()

    var body: some View {
        NavigationStack(path: $viewModel.navigationPath) {
            SessionListView()
                .toolbar {
                    ToolbarItem(placement: .secondaryAction) {
                        Button("Settings", systemImage: "gearshape") {
                            viewModel.navigationPath.append(AppDestination.settings)
                        }
                    }
                }
                .navigationDestination(for: AppDestination.self) { destination in
                    switch destination {
                    case .session:
                        SessionView()
                    case .newSession:
                        CreateSessionView()
                    case .settings:
                        SettingsView()
                    }
                }
        }
        .environment(viewModel)
    }
}

#if !os(Android)
    #Preview {
        ContentView()
    }
#endif
