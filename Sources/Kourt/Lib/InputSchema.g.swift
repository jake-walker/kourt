// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let inputSchema = try InputSchema(json)

import Foundation

// MARK: - InputSchema
struct InputSchema: Codable {
    let count, courtCount: Int
    let players: [String]
    let teamSize: Int
}

// MARK: InputSchema convenience initializers and mutators

extension InputSchema {
    init(data: Data) throws {
        self = try newJSONDecoder().decode(InputSchema.self, from: data)
    }

    init(_ json: String, using encoding: String.Encoding = .utf8) throws {
        guard let data = json.data(using: encoding) else {
            throw NSError(domain: "JSONDecoding", code: 0, userInfo: nil)
        }
        try self.init(data: data)
    }

    init(fromURL url: URL) throws {
        try self.init(data: try Data(contentsOf: url))
    }

    func with(
        count: Int? = nil,
        courtCount: Int? = nil,
        players: [String]? = nil,
        teamSize: Int? = nil
    ) -> InputSchema {
        return InputSchema(
            count: count ?? self.count,
            courtCount: courtCount ?? self.courtCount,
            players: players ?? self.players,
            teamSize: teamSize ?? self.teamSize
        )
    }

    func jsonData() throws -> Data {
        return try newJSONEncoder().encode(self)
    }

    func jsonString(encoding: String.Encoding = .utf8) throws -> String? {
        return String(data: try self.jsonData(), encoding: encoding)
    }
}
