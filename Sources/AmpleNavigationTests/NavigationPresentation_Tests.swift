//
//  NavigationPresentation_Tests.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 10/3/25.
//  Copyright © 2025 Carl Funk. All rights reserved.
//

@testable import AmpleNavigation
import Foundation
import Testing

@MainActor
@Suite("Navigation Presentation")
struct NavigationPresentation_Tests {
    let coordinator = NavigationCoordinator<TestScreen>(root: .home)
    let modalNavigation = Navigation<TestScreen>(screen: .cart, method: .fullScreenModal)
    let sheetNavigation = Navigation<TestScreen>(screen: .cart, method: .sheetModal)
    
    @Test
    func testInitialization() async throws {
        let presentation = NavigationPresentation(navigation: sheetNavigation, coordinator: coordinator)
        
        #expect(presentation.navigation == sheetNavigation)
        #expect(presentation.coordinator === coordinator)
    }
    
    @Test
    func testIsSheet() async throws {
        let presentation = NavigationPresentation(navigation: sheetNavigation, coordinator: coordinator)
        
        #expect(presentation.isFullScreenModal == false)
        #expect(presentation.isSheetModal == true)
    }
    
    @Test
    func testIsModal() async throws {
        let presentation = NavigationPresentation(navigation: modalNavigation, coordinator: coordinator)
        
        #expect(presentation.isFullScreenModal == true)
        #expect(presentation.isSheetModal == false)
    }
    
    @Test
    func testEquatableConformance() async throws {
        let id = UUID()
        let presentation = NavigationPresentation(id: id, navigation: sheetNavigation, coordinator: coordinator)
        let otherPresentation = NavigationPresentation(id: id, navigation: sheetNavigation, coordinator: coordinator)
        
        #expect(presentation == otherPresentation)
    }
    
    @Test
    func testEquatableConformanceWithDifferingIds() async throws {
        let presentation = NavigationPresentation(navigation: sheetNavigation, coordinator: coordinator)
        let otherPresentation = NavigationPresentation(navigation: sheetNavigation, coordinator: coordinator)
        
        #expect(presentation != otherPresentation)
    }
}
