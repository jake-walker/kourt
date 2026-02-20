//
//  AndroidFab.swift
//  kourt-app
//
//  Created by Jake Walker on 20/02/2026.
//

import SwiftUI

#if SKIP
import androidx.compose.material.icons.__
import androidx.compose.material.icons.filled.__

struct FabComposer: ContentComposer {
    let action: () -> Void
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
    @Composable func Compose(context: ComposeContext) {
        androidx.compose.material3.FloatingActionButton(onClick: action) {
            androidx.compose.material3.Icon(Icons.Filled.Add, "Add Session")
        }
    }
}
#endif

struct AndroidFab: View {
    let onClick: () -> Void
    
    var body: some View {
        #if os(Android)
        ComposeView {
            FabComposer(action: onClick)
        }
        #else
        EmptyView()
        #endif
    }
}
