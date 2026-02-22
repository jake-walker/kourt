//
//  SettingsView.swift
//  kourt-app
//
//  Created by Jake Walker on 19/02/2026.
//

import SwiftUI

struct SettingsView: View {
    let licenseUrl = URL(string: "https://github.com/jake-walker/kourt/blob/main/LICENSE.txt")!
    let repoUrl = URL(string: "https://github.com/jake-walker/kourt")!

    var body: some View {
        List {
            Section {
                if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
                {
                    Text("Version \(version) (\(buildNumber))")
                }

                Link(destination: repoUrl) {
                    Text("View on GitHub")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)

                Link(destination: licenseUrl) {
                    Text("Licensed under GNU GPL v3.0")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)

                NavigationLink(destination: AcknowledgementsView()) {
                    Text("Acknowledgements")
                }
            } header: {
                Text("About")
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
