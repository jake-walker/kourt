//
//  Generator.swift
//  kourt-app
//
//  Created by Jake Walker on 19/02/2026.
//

import Foundation

#if !os(Android)
import SkipScript

enum GeneratorError: Error {
    case jsContextFailed
    case jsLoadError
    case conversionFailed
    case failed(String?)
}

func generateMatchesJs(count: Int, players: [UUID], courtCount: Int = 1, teamSize: Int = 1) throws -> [[Match]] {
    let ctx = JSContext()
    
    guard let bundlePath = Bundle.module.path(forResource: "gen-bundle", ofType: "js"),
          let bundleContent = try? String(contentsOfFile: bundlePath, encoding: .utf8)
    else {
        throw GeneratorError.jsLoadError
    }
    
    let _ = ctx.evaluateScript(bundleContent)
    let funcRef = ctx.objectForKeyedSubscript("generateMatches")
    
    guard let inputJson = try InputSchema(count: count, courtCount: courtCount, players: players.map(\.uuidString), teamSize: teamSize).jsonString()
    else {
        throw GeneratorError.conversionFailed
    }
    
    let resultJson = try funcRef.call(withArguments: [
        JSValue(string: inputJson, in: ctx)
    ])
    
    let result = try OutputSchema(resultJson.toString())
    
    return result.map { $0.map { Match(court: $0.court, teamA: $0.teamA.map { UUID(uuidString: $0)! }, teamB: $0.teamB.map { UUID(uuidString: $0)! }) } }
}
#else
func generateMatchesJs(count: Int, players: [UUID], courtCount: Int = 1, teamSize: Int = 1) throws -> [[Match]] {
    return []
}
#endif
