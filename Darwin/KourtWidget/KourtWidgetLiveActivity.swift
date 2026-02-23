//
//  KourtWidgetLiveActivity.swift
//  KourtWidget
//
//  Created by Jake Walker on 20/02/2026.
//

import ActivityKit
import KourtShared
import SwiftUI
import WidgetKit

struct MatchView: View {
    let match: ActivityMatchItem

    private func teamStack(_ team: [String]) -> some View {
        VStack {
            ForEach(team, id: \.self) { name in
                Text(name)
                    .lineLimit(1)
                    .multilineTextAlignment(.center)
                    .font(.body.bold())
            }
        }
    }

    var body: some View {
        HStack {
            teamStack(match.teamA)
                .frame(maxWidth: .infinity)

            Text("vs.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            teamStack(match.teamB)
                .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

struct NextUpView: View {
    let match: ActivityMatchItem

    var body: some View {
        Text("**Next Up:** \(match.teamA.joined(separator: " & ")) vs. \(match.teamB.joined(separator: " & "))")
            .lineLimit(2)
            .fixedSize(horizontal: false, vertical: true)
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }
}

struct MatchHeading: View {
    let groupIndex: Int
    let courtIndex: Int?
    let showCourt: Bool

    var body: some View {
        HStack {
            Text("Match \(groupIndex + 1)")

            Spacer()

            if showCourt,
               let courtIndex
            {
                Text("Court \(courtIndex + 1)")
            }
        }
        .font(.subheadline)
    }
}

struct MainActivityView: View {
    let context: ActivityViewContext<KourtWidgetAttributes>
    @Environment(\.activityFamily) var family

    private var mediumFamily: some View {
        VStack(alignment: .leading, spacing: 8) {
            MatchHeading(groupIndex: context.state.groupIndex, courtIndex: context.state.currentPreferredItem?.court, showCourt: context.state.currentMatchGroup.count > 1)

            if let current = context.state.currentPreferredItem {
                MatchView(match: current)
            } else {
                Text("No match. Open the app to get started")
                    .fixedSize(horizontal: false, vertical: true)
                    .font(.body.italic())
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing], 32)
            }

            if let nextUp = context.state.nextPreferredItem {
                NextUpView(match: nextUp)
            }
        }
    }

    private var smallFamily: some View {
        VStack(alignment: .leading, spacing: 8) {
            MatchHeading(groupIndex: context.state.groupIndex, courtIndex: context.state.currentPreferredItem?.court, showCourt: context.state.currentMatchGroup.count > 1)

            if let current = context.state.currentPreferredItem {
                MatchView(match: current)
            } else {
                Text("No match")
                    .font(.body.italic())
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    var body: some View {
        switch family {
        case .small:
            smallFamily
                .padding()
                .activityBackgroundTint(.accent)
                .colorScheme(.light)
                .activitySystemActionForegroundColor(.white)
        case .medium:
            mediumFamily
                .padding()
        @unknown default:
            mediumFamily
                .padding()
        }
    }
}

struct KourtWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: KourtWidgetAttributes.self) { context in
            MainActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Match \(context.state.groupIndex + 1)")
                        .font(.subheadline)
                        .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.currentMatchGroup.count > 1,
                       let court = context.state.currentPreferredItem?.court
                    {
                        Text("Court \(court + 1)")
                            .font(.subheadline)
                            .padding(.trailing, 8)
                    } else {
                        EmptyView()
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 8) {
                        if let current = context.state.currentPreferredItem {
                            MatchView(match: current)
                        } else {
                            Text("No match. Open the app to get started")
                                .fixedSize(horizontal: false, vertical: true)
                                .font(.body.italic())
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .padding([.leading, .trailing], 32)
                        }

                        if let nextUp = context.state.nextPreferredItem {
                            NextUpView(match: nextUp)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(8)
                }
            } compactLeading: {
                Image(systemName: "sportscourt")
                    .foregroundStyle(.accent)
            } compactTrailing: {
                Text("\(context.state.groupIndex + 1)")
            } minimal: {
                Image(systemName: "sportscourt")
                    .foregroundStyle(.accent)
            }
            .keylineTint(.accent)
        }
        .supplementalActivityFamilies([.small, .medium])
    }
}

private extension KourtWidgetAttributes {
    static var preview: KourtWidgetAttributes {
        KourtWidgetAttributes(sessionId: .init(), sessionDate: .now)
    }
}

private extension KourtWidgetAttributes.ContentState {
    static var main: KourtWidgetAttributes.ContentState {
        KourtWidgetAttributes.ContentState(
            groupIndex: 5,
            preferredCourt: 0,
            nextPreferredCourt: 0,
            currentMatchGroup: [
                .init(id: .init(), court: 0, teamA: ["Giles", "Doug"], teamB: ["Abraham", "Albert"]),
                .init(id: .init(), court: 1, teamA: ["Eric", "Desmond"], teamB: ["Benjamin", "Richard"]),
            ],
            nextMatchGroup: [
                .init(id: .init(), court: 0, teamA: ["Eleanor", "Nathaneal"], teamB: ["Ursula", "Russell"]),
            ],
        )
    }

    static var singleCourt: KourtWidgetAttributes.ContentState {
        KourtWidgetAttributes.ContentState(
            groupIndex: 5,
            preferredCourt: 0,
            nextPreferredCourt: 0,
            currentMatchGroup: [
                .init(id: .init(), court: 0, teamA: ["Giles", "Doug"], teamB: ["Abraham", "Albert"]),
            ],
            nextMatchGroup: [
                .init(id: .init(), court: 0, teamA: ["Eleanor"], teamB: ["Ursula"]),
            ],
        )
    }

    static var empty: KourtWidgetAttributes.ContentState {
        KourtWidgetAttributes.ContentState(
            groupIndex: 0,
            preferredCourt: 0,
            nextPreferredCourt: 0,
            currentMatchGroup: [],
            nextMatchGroup: [],
        )
    }
}

#Preview("Notification", as: .content, using: KourtWidgetAttributes.preview) {
    KourtWidgetLiveActivity()
} contentStates: {
    KourtWidgetAttributes.ContentState.main
    KourtWidgetAttributes.ContentState.singleCourt
    KourtWidgetAttributes.ContentState.empty
}
