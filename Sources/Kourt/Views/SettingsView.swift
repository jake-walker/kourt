//
//  SettingsView.swift
//  kourt-app
//
//  Created by Jake Walker on 19/02/2026.
//

import SwiftUI

struct SettingsView : View {
    var body: some View {
        List {
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
               let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                Text("Version \(version) (\(buildNumber))")
            }
        }
        .navigationTitle("Settings")
    }
}

#if !os(Android)
#Preview {
    NavigationView {
        SettingsView()
    }
}
#endif
