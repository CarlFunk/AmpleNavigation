//
//  NavigationSettings_Tests.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 10/3/25.
//  Copyright © 2025 Carl Funk. All rights reserved.
//

@testable import AmpleNavigation
import Testing

@Suite("Navigation Settings")
struct NavigationSettings_Tests {
    @Test
    func testInitializationWithDefaultArguments() async throws {
        let settings = NavigationSettings()
        
        #expect(settings.speed == .quick)
    }
    
    @Test
    func testInitializationWithSpeedArgument() async throws {
        let settings = NavigationSettings(speed: .slow)
        
        #expect(settings.speed == .slow)
    }
    
    @Test
    func testEquatableConformance() async throws {
        let settings = NavigationSettings(speed: .slow)
        
        #expect(settings == NavigationSettings(speed: .slow))
        #expect(settings != NavigationSettings(speed: .quick))
    }
    
    @Test
    func testSpeedEquatableConformance() async throws {
        let speed = NavigationSettings.Speed.slow
        
        #expect(speed == .slow)
        #expect(speed != .quick)
    }
}
