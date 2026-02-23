//
//  AndroidFab.swift
//  kourt-app
//
//  Created by Jake Walker on 20/02/2026.
//
// swiftformat:disable unusedArguments,docComments

import SwiftUI

// SKIP @bridge
public enum FabIcon {
    case add, forward
}

#if SKIP
    import androidx.compose.material.icons.__
    import androidx.compose.material.icons.filled.__
    import androidx.compose.material.icons.outlined.__
    import androidx.compose.ui.graphics.vector.ImageVector

    struct FabComposer: ContentComposer {
        let action: () -> Void
        let icon: FabIcon

        var androidIcon: androidx.compose.ui.graphics.vector.ImageVector {
            switch icon {
            case .add:
                Icons.Filled.Add
            case .forward:
                Icons.Outlined.ArrowForward
            }
        }

        init(action: @escaping () -> Void, icon: FabIcon) {
            self.action = action
            self.icon = icon
        }

        @Composable func Compose(context: ComposeContext) {
            androidx.compose.material3.FloatingActionButton(onClick: action) {
                androidx.compose.material3.Icon(androidIcon, "Add Session")
            }
        }
    }
#endif

struct AndroidFab: View {
    let onClick: () -> Void
    let icon: FabIcon

    var body: some View {
        #if os(Android)
            ComposeView {
                FabComposer(action: onClick, icon: icon)
            }
        #else
            EmptyView()
        #endif
    }
}
