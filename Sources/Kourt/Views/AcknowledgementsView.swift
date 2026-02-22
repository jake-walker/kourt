//
//  AcknowledgementsView.swift
//  kourt-app
//
//  Created by Jake Walker on 22/02/2026.
//

import SwiftUI

struct AcknowledgementView: View {
    let license: LicensesPlugin.License

    var body: some View {
        ScrollView {
            Text(license.licenseText ?? "No license found")
                .font(.caption)
                .monospaced()
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(license.name)
    }
}

struct AcknowledgementsView: View {
    var body: some View {
        List {
            Section {
                ForEach(LicensesPlugin.licenses) { license in
                    NavigationLink(destination: AcknowledgementView(license: license)) {
                        Text(license.name)
                    }
                }
            } header: {
                Text("This app is built with the help of the following open source libraries.")
                    .font(.caption)
            }
        }
        .navigationTitle("Acknowledgements")
    }
}

#if !os(Android)
    #Preview {
        NavigationView {
            AcknowledgementsView()
        }
    }
#endif
