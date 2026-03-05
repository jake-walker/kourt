//
//  SessionView.swift
//  kourt-app
//
//  Created by Jake Walker on 19/02/2026.
//

import KourtShared
import SwiftUI

enum Team {
    case teamA, teamB

    var title: String {
        switch self {
        case .teamA: "Team A"
        case .teamB: "Team B"
        }
    }
}

struct PlayerListView: View {
    let players: [Player]
    let team: Team
    let compact: Bool

    var body: some View {
        Group {
            if !compact {
                HStack {
                    if team == .teamB {
                        Text(team.title)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 8) {
                        ForEach(players, id: \.id) { player in
                            Text(player.name)
                                .font(.system(size: 28))
                                .fontWeight(.semibold)
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)
                                .transition(.opacity)
                                .frame(maxWidth: .infinity, alignment: team == .teamA ? .leading : .trailing)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: team == .teamA ? .leading : .trailing)

                    if team == .teamA {
                        Text(team.title)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                VStack(spacing: 8) {
                    Text(team.title)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.bottom, 4)
                        .frame(maxWidth: .infinity, alignment: team == .teamA ? .leading : .trailing)

                    ForEach(players, id: \.id) { player in
                        Text(player.name)
                            .font(.system(size: 28))
                            .fontWeight(.semibold)
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                            .transition(.opacity)
                            .frame(maxWidth: .infinity, alignment: team == .teamA ? .leading : .trailing)
                    }
                }
            }
        }
    }
}

struct MatchView: View {
    let match: Match
    let sessionPlayers: [Player]
    let compact: Bool

    var body: some View {
        Group {
            if !compact {
                VStack {
                    PlayerListView(players: match.teamAPlayers(from: sessionPlayers), team: .teamA, compact: compact)
                        .frame(maxWidth: .infinity)

                    LabelledDivider(label: "vs.", orientation: .horizontal)

                    PlayerListView(players: match.teamBPlayers(from: sessionPlayers), team: .teamB, compact: compact)
                        .frame(maxWidth: .infinity)
                }
            } else {
                HStack {
                    PlayerListView(players: match.teamAPlayers(from: sessionPlayers), team: .teamA, compact: compact)
                        .frame(maxWidth: .infinity)

                    LabelledDivider(label: "vs.", orientation: .vertical)

                    PlayerListView(players: match.teamBPlayers(from: sessionPlayers), team: .teamB, compact: compact)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(28)
        #if !os(Android)
            .background(.regularMaterial)
        #else
            .background(Color.gray.opacity(0.1))
        #endif
            .clipShape(.rect(cornerRadius: 16))
    }
}

struct CurrentMatch: View {
    @Environment(ViewModel.self) var viewModel: ViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            if let session = viewModel.currentSession,
               let currentGroup = session.currentMatches
            {
                ForEach(Array(currentGroup.enumerated()), id: \.offset) { _, match in
                    if session.courts > 1 {
                        Text("Court \(match.court + 1)")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.foreground)
                    }

                    MatchView(match: match, sessionPlayers: session.players, compact: session.courts > 1)
                        .frame(maxWidth: .infinity)
                }
            }
        }
    }
}

struct MatchItem: View {
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
                    Text("Match \(index + 1)")

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

struct MatchHistoryView: View {
    @Environment(ViewModel.self) var viewModel: ViewModel
    let session: Session

    var body: some View {
        List {
            ForEach(session.matchGroups.indices, id: \.self) { groupIdx in
                ForEach(session.matchGroups[groupIdx], id: \.id) { match in
                    MatchItem(
                        sessionPlayers: session.players,
                        match: match,
                        index: groupIdx,
                        showCourt: session.courts > 1,
                        isCurrent: session.currentIndex == groupIdx,
                    )
                    .onTapGesture {
                        withAnimation {
                            viewModel.currentSession?.currentIndex = groupIdx
                        }
                    }
                }
            }
        }
    }
}

struct BenchView: View {
    let bench: [Player]

    var body: some View {
        Text("**Resting:** \(prettyJoinStrings(bench.map(\.name)))")
            .multilineTextAlignment(.leading)
            .foregroundStyle(.secondary)
            .font(.system(size: 18))
            .padding(.horizontal)
            .padding(.bottom, 8)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SessionView: View {
    @Environment(ViewModel.self) var viewModel: ViewModel

    @State var showingHistory = false

    private func nextMatch() {
        withAnimation {
            viewModel.currentSession?.advance()
        }
    }

    var nextButton: some View {
        Button(action: nextMatch) {
            Label("Next", systemImage: "arrow.forward")
                .frame(maxWidth: .infinity)
                .padding(8)
        }
    }

    var body: some View {
        if let session = viewModel.currentSession {
            ZStack(alignment: .bottomTrailing) {
                ScrollView {
                    Text("Match \(session.currentIndex + 1)")
                        .font(.title)
                        .nonAndroidMonospacedDigit()
                        .nonAndroidContentTransition(.numericText())
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .padding(.horizontal)
                    CurrentMatch()
                        .environment(viewModel)
                        .padding()

                    if !session.currentBench.isEmpty {
                        BenchView(bench: session.currentBench)
                    }
                }

                #if os(Android)
                    AndroidFab(onClick: nextMatch, icon: .forward)
                        .padding()
                        .accessibilityLabel(Text("Next"))
                #endif
            }
            .sheet(isPresented: $showingHistory) {
                NavigationStack {
                    MatchHistoryView(session: session)
                        .environment(viewModel)
                        .navigationTitle("Match History")
                    #if !os(Android)
                        .presentationDetents([.medium, .large])
                        .presentationBackgroundInteraction(.enabled)
                    #endif
                }
            }
            .navigationTitle("\(session.typeSummary) Session")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(
                        "History",
                        systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                    ) {
                        showingHistory.toggle()
                    }
                    .accessibilityLabel("History")
                }

                #if !os(Android)
                    if #available(iOS 26.0, *) {
                        ToolbarSpacer(.flexible, placement: .primaryAction)
                    }
                #endif

                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: session.shareText)
                }
            }
            .onAppear {
                viewModel.currentSession?.ensureReady()

                #if !os(Android)
                    Task {
                        do {
                            try await LiveActivityManager.shared.startOrUpdate(session)
                        } catch {
                            logger.warning(
                                "Failed to update live activity: \(error.localizedDescription)",
                            )
                        }
                    }
                #endif
            }
            #if !os(Android)
            .conditionalSafeArea {
                if #available(iOS 26.0, *) {
                    nextButton
                        .buttonStyle(.glassProminent)
                        .frame(maxWidth: .infinity)
                } else {
                    nextButton
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                }
            }
            .onChange(of: viewModel.currentSession) { _, session in
                guard let session else { return }

                Task {
                    do {
                        try await LiveActivityManager.shared.startOrUpdate(session)
                    } catch {
                        logger.warning(
                            "Failed to update live activity: \(error.localizedDescription)",
                        )
                    }
                }
            }
            .onDisappear {
                Task {
                    await LiveActivityManager.shared.endAllActivities()
                }
            }
            #endif
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
