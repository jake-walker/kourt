//
//  LabelledDivider.swift
//  kourt-app
//
//  Created by Jake Walker on 27/02/2026.
//

import SwiftUI

enum Orientation {
    case horizontal, vertical
}

struct LabelledDivider: View {
    let label: String
    let orientation: Orientation

    var body: some View {
        if orientation == .horizontal {
            HStack(spacing: 16) {
                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.secondary.quaternary)

                Text(label)
                    .foregroundStyle(.secondary)

                Rectangle()
                    .frame(height: 1)
                    .foregroundStyle(.secondary.quaternary)
            }
        } else {
            VStack(spacing: 8) {
                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(.secondary.quaternary)

                Text(label)
                    .foregroundStyle(.secondary)

                Rectangle()
                    .frame(width: 1)
                    .foregroundStyle(.secondary.quaternary)
            }
        }
    }
}

#if !os(Android)
    #Preview {
        VStack {
            LabelledDivider(label: "Test", orientation: .horizontal)
            LabelledDivider(label: "Test", orientation: .vertical)
        }
    }
#endif
