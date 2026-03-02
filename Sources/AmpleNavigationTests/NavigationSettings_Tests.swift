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
        
        #expect(settings.debug == false)
        #expect(settings.delay == 0.625)
        #expect(settings.speed == .quick)
    }
    
    @Test
    func testInitializationWithDebugArgument() async throws {
        let settings = NavigationSettings(debug: true)
        
        #expect(settings.debug == true)
    }
    
    @Test
    func testInitializationWithDelayArgument() async throws {
        let settings = NavigationSettings(delay: 0.25)
        
        #expect(settings.delay == 0.25)
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
