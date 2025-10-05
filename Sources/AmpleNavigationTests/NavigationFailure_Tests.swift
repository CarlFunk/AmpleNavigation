//
//  NavigationFailure_Tests.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 10/3/25.
//  Copyright © 2025 Carl Funk. All rights reserved.
//

@testable import AmpleNavigation
import Testing

@Suite("Navigation Failure")
struct NavigationFailure_Tests {
    @Test
    func testAllCases() async throws {
        let allErrors = Set<NavigationFailure>([
            NavigationFailure.emptyNavigationFlow,
            NavigationFailure.notCurrentlyNavigating,
            NavigationFailure.notCurrentlyPresenting,
            NavigationFailure.screenNotFound
        ])
        
        let allCases = Set(NavigationFailure.allCases)
        
        #expect(allCases == allErrors)
    }
}
