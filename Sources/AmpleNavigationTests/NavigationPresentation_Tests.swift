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
    let coordinator = NavigationCoordinator<TestScreen>()
    let modalNavigation = Navigation<TestScreen>(screen: .cart, method: .modal)
    let sheetNavigation = Navigation<TestScreen>(screen: .cart, method: .sheet)
    
    @Test
    func testInitialization() async throws {
        let presentation = NavigationPresentation(navigation: sheetNavigation, coordinator: coordinator)
        
        #expect(presentation.navigation == sheetNavigation)
        #expect(presentation.coordinator === coordinator)
    }
    
    @Test
    func testIsSheet() async throws {
        let presentation = NavigationPresentation(navigation: sheetNavigation, coordinator: coordinator)
        
        #expect(presentation.isModal == false)
        #expect(presentation.isSheet == true)
    }
    
    @Test
    func testIsModal() async throws {
        let presentation = NavigationPresentation(navigation: modalNavigation, coordinator: coordinator)
        
        #expect(presentation.isModal == true)
        #expect(presentation.isSheet == false)
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
