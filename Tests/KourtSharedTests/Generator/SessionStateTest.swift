//
//  SessionStateTest.swift
//  kourt-app
//
//  Created by Jake Walker on 26/02/2026.
//

import KourtShared
import Testing

struct GeneratorSessionStateTest {
    @Test("Session currentIndex starts at 0")
    func currentIndexStartsAtZero() {
        let session = SampleData.minimalSinglesSession

        #expect(session.currentIndex == 0)
    }
}
