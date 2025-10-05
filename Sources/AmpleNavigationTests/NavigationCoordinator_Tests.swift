//
//  NavigationCoordinator_Tests.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 10/3/25.
//  Copyright © 2025 Carl Funk. All rights reserved.
//

@testable import AmpleNavigation
import Testing

@MainActor
@Suite("Navigation Coordinator")
struct NavigationCoordinator_Tests {
    
    @Test("Verify initializer with default arguments")
    func testInitialization() async throws {
        let coordinator = NavigationCoordinator<TestScreen>()
        
        #expect(coordinator.parent == nil)
        #expect(coordinator.settings == NavigationSettings())
        #expect(coordinator.pushPresentation == [])
        #expect(coordinator.presentPresentation == nil)
        
        #expect(coordinator.isPushing == false)
        #expect(coordinator.isPresenting == false)
    }
    
    @Test("Verify initializer with parent argument")
    func testInitializationWithParent() async throws {
        let parentCoordinator = NavigationCoordinator<TestScreen>()
        let coordinator = NavigationCoordinator<TestScreen>(parent: parentCoordinator)
        
        #expect(coordinator.parent === parentCoordinator)
        #expect(coordinator.settings == NavigationSettings())
        #expect(coordinator.pushPresentation == [])
        #expect(coordinator.presentPresentation == nil)
        
        #expect(coordinator.isPushing == false)
        #expect(coordinator.isPresenting == false)
    }
    
    @Test("Verify initializer with settings argument")
    func testInitializationWithSettings() async throws {
        let settings = NavigationSettings(speed: .slow)
        let coordinator = NavigationCoordinator<TestScreen>(settings: settings)
        
        #expect(coordinator.parent == nil)
        #expect(coordinator.settings == settings)
        #expect(coordinator.pushPresentation == [])
        #expect(coordinator.presentPresentation == nil)
        
        #expect(coordinator.isPushing == false)
        #expect(coordinator.isPresenting == false)
    }
    
    @Test
    func testSinglePushNavigation() async throws {
        let navigation = Navigation<TestScreen>(screen: .productList, method: .push)
        let coordinator = NavigationCoordinator<TestScreen>()
        
        try await coordinator.navigate(to: navigation)
        
        #expect(coordinator.parent == nil)
        #expect(coordinator.childCoordinator() == nil)
        #expect(coordinator.isPushing == true)
        #expect(coordinator.isPushing(screen: navigation.screen) == true)
        #expect(coordinator.isPresenting == false)
    }
    
    @Test
    func testSingleModalNavigation() async throws {
        let navigation = Navigation<TestScreen>(screen: .productList, method: .modal)
        let coordinator = NavigationCoordinator<TestScreen>()
        
        try await coordinator.navigate(to: navigation)
        
        #expect(coordinator.parent == nil)
        #expect(coordinator.childCoordinator() != nil)
        #expect(coordinator.isPushing == false)
        #expect(coordinator.isPresenting == true)
        #expect(coordinator.isPresenting(screen: navigation.screen) == true)
    }
    
    @Test
    func testSingleSheetNavigation() async throws {
        let navigation = Navigation<TestScreen>(screen: .productList, method: .sheet)
        let coordinator = NavigationCoordinator<TestScreen>()
        
        try await coordinator.navigate(to: navigation)
        
        #expect(coordinator.parent == nil)
        #expect(coordinator.childCoordinator() != nil)
        #expect(coordinator.isPushing == false)
        #expect(coordinator.isPresenting == true)
        #expect(coordinator.isPresenting(screen: navigation.screen))
    }
    
    @Test
    func testMultiPushNavigation() async throws {
        let firstNavigation = Navigation<TestScreen>(screen: .productList, method: .push)
        let secondNavigation = Navigation<TestScreen>(screen: .productDetail(id: "1"), method: .push)
        let navigations = [firstNavigation, secondNavigation]
        let coordinator = NavigationCoordinator<TestScreen>()
        
        try await coordinator.navigate(to: firstNavigation)
        try await coordinator.navigate(to: secondNavigation)
        
        #expect(coordinator.parent == nil)
        #expect(coordinator.childCoordinator() == nil)
        #expect(coordinator.isPushing == true)
        #expect(coordinator.pushPresentation.count == navigations.count)
        #expect(coordinator.pushPresentation.map { $0.screen } == navigations.map { $0.screen })
        #expect(coordinator.isPushing(screen: firstNavigation.screen))
        #expect(coordinator.isPushing(screen: secondNavigation.screen))
        #expect(coordinator.isPresenting == false)
    }
    
    @Test
    func testMultiModalNavigation() async throws {
        let firstNavigation = Navigation<TestScreen>(screen: .productList, method: .modal)
        let secondNavigation = Navigation<TestScreen>(screen: .productDetail(id: "1"), method: .modal)
        let coordinator = NavigationCoordinator<TestScreen>()
        
        try await coordinator.navigate(to: firstNavigation)
        try await coordinator.navigate(to: secondNavigation)
        
        let secondCoordinator = coordinator.childCoordinator()!
        
        #expect(coordinator.parent == nil)
        #expect(coordinator.childCoordinator() === secondCoordinator)
        #expect(coordinator.isPushing == false)
        #expect(coordinator.isPresenting == true)
        #expect(coordinator.isPresenting(screen: secondNavigation.screen))
        #expect(coordinator.presentPresentation != nil)
        
        #expect(secondCoordinator.parent === coordinator)
        #expect(secondCoordinator.childCoordinator() == nil)
        #expect(secondCoordinator.isPushing == false)
        #expect(secondCoordinator.isPresenting == false)
        #expect(secondCoordinator.presentPresentation == nil)
    }
    
    @Test
    func testMultiSheetNavigation() async throws {
        let firstNavigation = Navigation<TestScreen>(screen: .productList, method: .sheet)
        let secondNavigation = Navigation<TestScreen>(screen: .productDetail(id: "1"), method: .sheet)
        
        let coordinator = NavigationCoordinator<TestScreen>()
        try await coordinator.navigate(to: firstNavigation)
        try await coordinator.navigate(to: secondNavigation)
        
        #expect(coordinator.parent == nil)
        #expect(coordinator.childCoordinator() != nil)
        #expect(coordinator.isPushing == false)
        #expect(coordinator.isPresenting == true)
        #expect(coordinator.isPresenting(screen: secondNavigation.screen))
        #expect(coordinator.presentPresentation != nil)
    }
    
    @Test
    func testFlowPushNavigation() async throws {
        let flow: NavigationFlow<TestScreen> = [
            Navigation(screen: .cart, method: .push),
            Navigation(screen: .checkout, method: .push),
            Navigation(screen: .checkoutConfirmation, method: .push)
        ]
        
        let coordinator = NavigationCoordinator<TestScreen>()
        try await coordinator.navigate(to: flow)
        
        #expect(coordinator.parent == nil)
        #expect(coordinator.childCoordinator() == nil)
        #expect(coordinator.isPushing == true)
        #expect(coordinator.pushPresentation.count == flow.count)
        #expect(coordinator.pushPresentation.screens() == flow.screens())
        #expect(coordinator.isPushing(screen: flow[0].screen))
        #expect(coordinator.isPushing(screen: flow[1].screen))
        #expect(coordinator.isPushing(screen: flow[2].screen))
        #expect(coordinator.isPresenting == false)
    }
    
    @Test
    func testFlowModalNavigation() async throws {
        let flow: NavigationFlow<TestScreen> = [
            Navigation(screen: .cart, method: .modal),
            Navigation(screen: .checkout, method: .modal),
            Navigation(screen: .checkoutConfirmation, method: .modal)
        ]
        
        let coordinator = NavigationCoordinator<TestScreen>()
        try await coordinator.navigate(to: flow)
        
        #expect(coordinator.parent == nil)
        #expect(coordinator.childCoordinator() != nil)
        #expect(coordinator.isPushing == false)
        #expect(coordinator.isPresenting == true)
        #expect(coordinator.isPresenting(screen: flow[0].screen))
        #expect(coordinator.presentPresentation != nil)
        #expect(coordinator.presentPresentation?.coordinator.presentPresentation != nil)
    }
    
    @Test
    func testFlowSheetNavigation() async throws {
        let flow: NavigationFlow<TestScreen> = [
            Navigation(screen: .cart, method: .sheet),
            Navigation(screen: .checkout, method: .sheet),
            Navigation(screen: .checkoutConfirmation, method: .sheet)
        ]
        
        let coordinator = NavigationCoordinator<TestScreen>()
        try await coordinator.navigate(to: flow)
        
        #expect(coordinator.parent == nil)
        #expect(coordinator.childCoordinator() != nil)
        #expect(coordinator.isPushing == false)
        #expect(coordinator.isPresenting == true)
        #expect(coordinator.isPresenting(screen: flow[0].screen))
        #expect(coordinator.presentPresentation != nil)
    }
    
    @Test
    func testFlowVariedNavigation() async throws {
        let flow: NavigationFlow<TestScreen> = [
            Navigation(screen: .productList, method: .push),
            Navigation(screen: .productDetail(id: "1"), method: .sheet),
            Navigation(screen: .cart, method: .modal),
            Navigation(screen: .checkout, method: .push),
            Navigation(screen: .checkoutConfirmation, method: .push)
        ]
        
        var coordinator: NavigationCoordinator<TestScreen>!
        var secondCoordinator: NavigationCoordinator<TestScreen>!
        var thirdCoordinator: NavigationCoordinator<TestScreen>!
        
        coordinator = NavigationCoordinator<TestScreen>()
        try await coordinator.navigate(to: flow)
        secondCoordinator = coordinator.childCoordinator()!
        thirdCoordinator = secondCoordinator.childCoordinator()!
        
        #expect(coordinator.parent == nil)
        #expect(coordinator.childCoordinator() != nil)
        #expect(coordinator.isPushing == true)
        #expect(coordinator.isPushing(screen: flow[0].screen))
        #expect(coordinator.isPresenting == true)
        #expect(coordinator.isPresenting(screen: flow[1].screen))
        #expect(coordinator.presentPresentation != nil)
        
        #expect(secondCoordinator.parent != nil)
        #expect(secondCoordinator.childCoordinator() != nil)
        #expect(secondCoordinator.isPushing == false)
        #expect(secondCoordinator.isPresenting)
        #expect(secondCoordinator.isPresenting(screen: flow[2].screen))
        #expect(secondCoordinator.presentPresentation != nil)
        
        #expect(thirdCoordinator.parent != nil)
        #expect(thirdCoordinator.childCoordinator() == nil)
        #expect(thirdCoordinator.isPushing)
        #expect(thirdCoordinator.isPushing(screen: flow[3].screen))
        #expect(thirdCoordinator.isPushing(screen: flow[4].screen))
        #expect(thirdCoordinator.isPresenting == false)
    }
}
