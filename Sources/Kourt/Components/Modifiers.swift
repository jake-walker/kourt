//
//  Modifiers.swift
//  kourt-app
//
//  Created by Jake Walker on 25/02/2026.
//

import SwiftUI

struct NonAndroidMonospacedDigit: ViewModifier {
    func body(content: Content) -> some View {
        #if !os(Android)
            AnyView(content.monospacedDigit())
        #else
            AnyView(content)
        #endif
    }
}

struct NonAndroidContentTransition: ViewModifier {
    let contentTransition: ContentTransition

    func body(content: Content) -> some View {
        #if !os(Android)
            AnyView(content.contentTransition(contentTransition))
        #else
            AnyView(content)
        #endif
    }
}

extension View {
    func nonAndroidMonospacedDigit() -> some View {
        modifier(NonAndroidMonospacedDigit())
    }

    func nonAndroidContentTransition(_ transition: ContentTransition) -> some View {
        modifier(NonAndroidContentTransition(contentTransition: transition))
    }
}
