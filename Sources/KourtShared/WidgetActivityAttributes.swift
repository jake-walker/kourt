#if !os(Android) && !os(macOS)
    import ActivityKit
    import Foundation

    public struct ActivityMatchItem: Identifiable, Codable, Hashable, Sendable {
        public let id: UUID
        public let court: Int
        public let teamA: [String]
        public let teamB: [String]

        public init(id: UUID, court: Int, teamA: [String], teamB: [String]) {
            self.id = id
            self.court = court
            self.teamA = teamA
            self.teamB = teamB
        }
    }

    public struct KourtWidgetAttributes: ActivityAttributes {
        public struct ContentState: Codable, Hashable, Sendable {
            public let groupIndex: Int
            public let preferredCourt: Int?
            public let nextPreferredCourt: Int?
            public let currentMatchGroup: [ActivityMatchItem]
            public let nextMatchGroup: [ActivityMatchItem]

            public var currentPreferredItem: ActivityMatchItem? {
                if let preferredCourt,
                   let item = currentMatchGroup.first(where: { $0.court == preferredCourt })
                {
                    return item
                }

                return currentMatchGroup.first
            }

            public var nextPreferredItem: ActivityMatchItem? {
                if let nextPreferredCourt,
                   let item = nextMatchGroup.first(where: { $0.court == nextPreferredCourt })
                {
                    return item
                }

                return nextMatchGroup.first
            }

            public init(groupIndex: Int, preferredCourt: Int? = nil, nextPreferredCourt: Int? = nil, currentMatchGroup: [ActivityMatchItem], nextMatchGroup: [ActivityMatchItem]) {
                self.groupIndex = groupIndex
                self.preferredCourt = preferredCourt
                self.nextPreferredCourt = nextPreferredCourt
                self.currentMatchGroup = currentMatchGroup
                self.nextMatchGroup = nextMatchGroup
            }
        }

        public let sessionId: UUID
        public let sessionDate: Date

        public init(sessionId: UUID, sessionDate: Date) {
            self.sessionId = sessionId
            self.sessionDate = sessionDate
        }
    }
#endif
