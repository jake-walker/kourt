//
//  AnalyticsCard.swift
//  kourt-app
//
//  Created by Jake Walker on 05/03/2026.
//

import SwiftUI

struct AnalyticsCard<Content: View>: View {
    let title: String
    @ViewBuilder let content: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            VStack(spacing: 8) {
                content()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.regularMaterial)
        .clipShape(.rect(cornerRadius: 16))
    }
}

#if !os(Android)
    #Preview {
        AnalyticsCard(title: "Test Card") {
            Text("Some content here...")
        }
    }
#endif
