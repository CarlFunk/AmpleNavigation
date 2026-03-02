//
//  NavigationDelay_Tests.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 10/3/25.
//  Copyright © 2025 Carl Funk. All rights reserved.
//

@testable import AmpleNavigation
import Testing

@Suite("Navigation Delay")
struct NavigationDelay_Tests {
    @Test
    func verifyTime() async throws {
        #expect(NavigationDelay().time == 0.625)
    }
    
    @Test
    func testPerform() async throws {
        await NavigationDelay(time: 0.625).perform()
        
        #expect(true)
    }
}
