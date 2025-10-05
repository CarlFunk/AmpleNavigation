//
//  NavigationFlow_Tests.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 10/3/25.
//  Copyright © 2025 Carl Funk. All rights reserved.
//

@testable import AmpleNavigation
import Testing

@MainActor
@Suite("Navigation Flow")
struct NavigationFlow_Tests {
    let emptyFlow = [Navigation<TestScreen>]()
    
    let mixedFlow = [
        Navigation<TestScreen>(screen: .home, method: .push),
        Navigation<TestScreen>(screen: .productList, method: .push),
        Navigation<TestScreen>(screen: .productDetail(id: "1234"), method: .sheet),
        Navigation<TestScreen>(screen: .cart, method: .modal)
    ]
    
    let pushOnlyFlow = [
        Navigation<TestScreen>(screen: .home, method: .push),
        Navigation<TestScreen>(screen: .productList, method: .push),
        Navigation<TestScreen>(screen: .productDetail(id: "1234"), method: .push),
        Navigation<TestScreen>(screen: .cart, method: .push)
    ]
    
    @Test
    func testScreens() async throws {
        #expect(emptyFlow.screens() == [])
        #expect(mixedFlow.screens() == [.home, .productList, .productDetail(id: "1234"), .cart])
        #expect(pushOnlyFlow.screens() == [.home, .productList, .productDetail(id: "1234"), .cart])
    }
    
    @Test
    func testMethods() async throws {
        #expect(emptyFlow.methods() == [])
        #expect(mixedFlow.methods() == [.push, .push, .sheet, .modal])
        #expect(pushOnlyFlow.methods() == [.push, .push, .push, .push])
    }
    
    @Test
    func testUniqueMethods() async throws {
        #expect(emptyFlow.uniqueMethods() == [])
        #expect(mixedFlow.uniqueMethods() == [.push, .sheet, .modal])
        #expect(pushOnlyFlow.uniqueMethods() == [.push])
    }
    
    @Test
    func testHasOnlyPushMethods() async throws {
        #expect(emptyFlow.hasOnlyPushMethods() == false)
        #expect(mixedFlow.hasOnlyPushMethods() == false)
        #expect(pushOnlyFlow.hasOnlyPushMethods() == true)
    }
    
    @Test
    func testFirstNonPushMethodIndex() async throws {
        #expect(emptyFlow.firstNonPushMethodIndex() == nil)
        #expect(mixedFlow.firstNonPushMethodIndex() == 2)
        #expect(pushOnlyFlow.firstNonPushMethodIndex() == nil)
    }
}
