//
//  LiveActivityManager.swift
//  kourt-app
//
//  Created by Jake Walker on 20/02/2026.
//

#if !os(Android)
    import ActivityKit
    import Combine
    import Foundation
    import KourtShared

    actor LiveActivityManager {
        static let shared = LiveActivityManager()

        private nonisolated(unsafe) var currentActivity: Activity<KourtWidgetAttributes>?

        private static let defaultActivityState: KourtWidgetAttributes.ContentState = .init(groupIndex: 0, currentMatchGroup: [], nextMatchGroup: [])

        static func convertMatch(_ match: Match, players: [Player]) -> ActivityMatchItem {
            .init(
                id: match.id,
                court: match.court,
                teamA: match.teamAPlayers(from: players).map(\.name),
                teamB: match.teamBPlayers(from: players).map(\.name),
            )
        }

        static func generateActivityState(from session: Session) -> KourtWidgetAttributes.ContentState {
            .init(
                groupIndex: session.currentIndex,
                currentMatchGroup: (session.currentMatches ?? [])
                    .map { Self.convertMatch($0, players: session.players) },
                nextMatchGroup: session.nextMatches
                    .map { Self.convertMatch($0, players: session.players) },
            )
        }

        func startOrUpdate(_ session: Session) async throws {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                return
            }

            if let currentActivity {
                if currentActivity.attributes.sessionId == session.id {
                    logger.debug("Updating existing live activity")
                    await currentActivity.update(ActivityContent(state: Self.generateActivityState(from: session), staleDate: Date().addingTimeInterval(60 * 60)))
                } else {
                    logger.debug("Recreating live activity as current is not this session")
                    await endActivity()
                    try await start(session)
                }
            } else {
                logger.debug("Creating new live activity")
                try await start(session)
            }
        }

        private func start(_ session: Session) async throws {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                return
            }

            let attributes = KourtWidgetAttributes(sessionId: session.id, sessionDate: session.date)

            currentActivity = try? Activity.request(
                attributes: attributes,
                content: ActivityContent(state: Self.generateActivityState(from: session), staleDate: Date().addingTimeInterval(60 * 60)),
                pushType: nil,
            )
        }

        private func endActivity() async {
            guard ActivityAuthorizationInfo().areActivitiesEnabled,
                  let currentActivity
            else {
                return
            }

            await currentActivity.end(.init(state: Self.defaultActivityState, staleDate: Date()), dismissalPolicy: .immediate)
            self.currentActivity = nil
        }

        func endAllActivities() async {
            guard ActivityAuthorizationInfo().areActivitiesEnabled else {
                return
            }

            logger.debug("Ending all live activities")

            for activity in Activity<KourtWidgetAttributes>.activities {
                await activity.end(.init(state: Self.defaultActivityState, staleDate: Date()), dismissalPolicy: .immediate)
            }

            currentActivity = nil
        }
    }
#endif
