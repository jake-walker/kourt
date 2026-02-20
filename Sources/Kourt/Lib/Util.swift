//
//  Util.swift
//  kourt-app
//
//  Created by Jake Walker on 20/02/2026.
//

import Foundation

func prettyJoinStrings(_ strings: [String]) -> String {
    var stringsCopy = strings
    switch stringsCopy.count {
    case 0:
        return ""
    case 1:
        return stringsCopy[0]
    default:
        let lastItem = stringsCopy.removeLast()
        return "\(stringsCopy.joined(separator: ", ")) and \(lastItem)"
    }
}

func inflect(_ count: Int, singular: String, plural: String) -> String {
    return count == 1 ? "\(count) \(singular)" : "\(count) \(plural)"
}
