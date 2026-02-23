// Licensed under the GNU General Public License v3.0 or later
// SPDX-License-Identifier: GPL-3.0-or-later

import SwiftUI

enum HomeTab: String, CaseIterable, Identifiable {
    case sessions, roster

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .sessions: "Sessions"
        case .roster: "My Players"
        }
    }

    var icon: String {
        switch self {
        case .sessions: "list.bullet"
        #if !os(Android)
            case .roster: "person.2"
        #else
            case .roster: "person"
        #endif
        }
    }
}

enum AppDestination: Hashable {
    case session(Session.ID)
    case newSession
    case settings
}

struct ContentView: View {
    @State var viewModel = ViewModel()
    @State var selectedTab: HomeTab = .sessions

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack(path: $viewModel.navigationPath) {
                SessionListView()
                    .navigationDestination(for: AppDestination.self) { destination in
                        switch destination {
                        case .session:
                            SessionView()
                                .toolbar(.hidden, for: .tabBar)
                        case .newSession:
                            CreateSessionView()
                                .toolbar(.hidden, for: .tabBar)
                        case .settings:
                            SettingsView()
                                .toolbar(.hidden, for: .tabBar)
                        }
                    }
            }
            .tabItem {
                Label(HomeTab.sessions.title, systemImage: HomeTab.sessions.icon)
            }
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    Button("Settings", systemImage: "gearshape") {
                        viewModel.navigationPath.append(AppDestination.settings)
                    }
                }
            }
            .tag(HomeTab.sessions)

            NavigationStack {
                RosterView()
            }
            .tabItem {
                Label(HomeTab.roster.title, systemImage: HomeTab.roster.icon)
            }
            .tag(HomeTab.roster)
        }
        .environment(viewModel)
    }
}

#if !os(Android)
    #Preview {
        ContentView()
    }
#endif
