//
//  ConditionalSafeAreaViewModifier.swift
//  kourt-app
//
//  Created by Jake Walker on 23/02/2026.
//

import SwiftUI

struct ConditionalSafeAreaViewModifier: ViewModifier {
    let safeAreaContent: AnyView

    init(@ViewBuilder safeAreaContent: () -> some View) {
        self.safeAreaContent = AnyView(safeAreaContent())
    }

    func body(content: Content) -> some View {
        #if !os(Android)
            if #available(iOS 26.0, *) {
                AnyView(content.safeAreaBar(edge: .bottom) {
                    safeAreaContent
                        .padding()
                })
            } else {
                AnyView(content.safeAreaInset(edge: .bottom) {
                    safeAreaContent
                        .padding()
                        .background(.ultraThinMaterial)
                })
            }
        #else
            AnyView(content)
        #endif
    }
}

extension View {
    func conditionalSafeArea(@ViewBuilder _ safeAreaContent: () -> some View) -> some View {
        modifier(ConditionalSafeAreaViewModifier(safeAreaContent: safeAreaContent))
    }
}
