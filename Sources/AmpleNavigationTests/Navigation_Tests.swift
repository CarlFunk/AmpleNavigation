//
//  Navigation_Tests.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 10/3/25.
//  Copyright © 2025 Carl Funk. All rights reserved.
//

@testable import AmpleNavigation
import Testing

@Suite("Navigation")
struct Navigation_Tests {
    @Test
    func testInitializerWithDefaultArguments() async throws {
        let navigation = Navigation<TestScreen>(screen: .home)
        
        #expect(navigation.screen == .home)
        #expect(navigation.method == .push)
    }
    
    @Test
    func testInitializerWithArguments() async throws {
        var onDismissOutput: String = ""
        let navigation = Navigation<TestScreen>(screen: .home, method: .modal, onDismiss: { onDismissOutput = "DISMISSED" })
        
        navigation.onDismiss()
        
        #expect(navigation.screen == .home)
        #expect(navigation.method == .modal)
        #expect(onDismissOutput == "DISMISSED")
    }
    
    @Test
    func testHashableConformance() async throws {
        let screen: TestScreen = .cart
        let method: Navigation<TestScreen>.Method = .sheet
        let navigation = Navigation<TestScreen>(screen: screen, method: method)
        
        var hasher = Hasher()
        hasher.combine(screen)
        hasher.combine(method)
        
        #expect(navigation.hashValue == hasher.finalize())
    }
    
    @Test
    func testEquatableConformance() async throws {
        let navigation = Navigation<TestScreen>(screen: .home, method: .sheet)
        
        #expect(navigation == Navigation<TestScreen>(screen: .home, method: .sheet))
        #expect(navigation != Navigation<TestScreen>(screen: .cart, method: .sheet))
        #expect(navigation != Navigation<TestScreen>(screen: .home, method: .push))
    }
    
    @Test
    func testMethodHashableConformance() async throws {
        let method = Navigation<TestScreen>.Method.modal
        
        var matchingHasher = Hasher()
        matchingHasher.combine(Navigation<TestScreen>.Method.modal)
        
        var nonMatchingHasher = Hasher()
        nonMatchingHasher.combine(Navigation<TestScreen>.Method.push)
        
        #expect(method.hashValue == matchingHasher.finalize())
        #expect(method.hashValue != nonMatchingHasher.finalize())
    }
    
    @Test
    func testMethodEquatableConformance() async throws {
        let method = Navigation<TestScreen>.Method.modal
        
        #expect(method == .modal)
        #expect(method != .push)
        #expect(method != .sheet)
    }
}
