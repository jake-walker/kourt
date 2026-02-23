//
//  EmptyStateView.swift
//  kourt-app
//
//  Created by Jake Walker on 22/02/2026.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let label: String?
    let actionText: String?
    let actionIcon: String?
    @MainActor var action: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Text(title)
                .font(.body.bold())
                .multilineTextAlignment(.center)

            if let label {
                Text(label)
                    .font(.body)
                    .multilineTextAlignment(.center)
            }

            if let actionText, let actionIcon {
                Button(action: action) {
                    Label(actionText, systemImage: actionIcon)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.horizontal, 32)
        .padding(.vertical, 64)
        .frame(maxHeight: .infinity, alignment: .center)
    }
}

#if !os(Android)
    #Preview {
        EmptyStateView(
            title: "No Sessions",
            label: "Add a session to get started. Lorem ipsum dolor sit amet.",
            actionText: "Add session",
            actionIcon: "plus",
            action: {},
        )
        .background(.yellow)
    }
#endif
