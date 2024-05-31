//
//  NavigationCoordinatorTests.swift
//  NavigationTests
//
//  Created by Carl Funk on 5/30/24.
//  Copyright © 2024 Carl Funk. All rights reserved.
//

@testable import Navigation
import XCTest

final class NavigationCoordinatorTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitialization() throws {
        let coordinator = NavigationCoordinator<TestScreen>()
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertFalse(coordinator.hasNavigation)
        XCTAssertFalse(coordinator.isPresenting)
    }
    
    func testInitializationWithParent() throws {
        let rootCoordinator = NavigationCoordinator<TestScreen>()
        let coordinator = NavigationCoordinator<TestScreen>(parent: rootCoordinator)
        
        XCTAssertNotNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertFalse(coordinator.hasNavigation)
        XCTAssertFalse(coordinator.isPresenting)
    }
    
    func testSinglePushNavigation() throws {
        let navigation = Navigation<TestScreen>(screen: .productList, method: .push)
        let coordinator = NavigationCoordinator<TestScreen>()
        
        coordinator.navigate(to: navigation)
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertTrue(coordinator.hasNavigation)
        XCTAssertTrue(coordinator.hasNavigation(navigation.screen))
        XCTAssertFalse(coordinator.isPresenting)
    }
    
    func testSingleModalNavigation() throws {
        let navigation = Navigation<TestScreen>(screen: .productList, method: .modal)
        let coordinator = NavigationCoordinator<TestScreen>()
        
        coordinator.navigate(to: navigation)
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertFalse(coordinator.hasNavigation)
        XCTAssertTrue(coordinator.isPresenting)
        XCTAssertTrue(coordinator.isPresenting(navigation.screen))
    }
    
    func testSingleSheetNavigation() throws {
        let navigation = Navigation<TestScreen>(screen: .productList, method: .sheet())
        let coordinator = NavigationCoordinator<TestScreen>()
        
        coordinator.navigate(to: navigation)
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertFalse(coordinator.hasNavigation)
        XCTAssertTrue(coordinator.isPresenting)
        XCTAssertTrue(coordinator.isPresenting(navigation.screen))
    }
    
    func testMultiPushNavigation() throws {
        let firstNavigation = Navigation<TestScreen>(screen: .productList, method: .push)
        let secondNavigation = Navigation<TestScreen>(screen: .productDetail(id: "1"), method: .push)
        let navigations = [firstNavigation, secondNavigation]
        let coordinator = NavigationCoordinator<TestScreen>()
        
        coordinator.navigate(to: firstNavigation)
        coordinator.navigate(to: secondNavigation)
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertTrue(coordinator.hasNavigation)
        XCTAssertTrue(coordinator.navigations.count == navigations.count)
        XCTAssertTrue(coordinator.navigations.map { $0.screen } == navigations.map { $0.screen })
        XCTAssertTrue(coordinator.hasNavigation(firstNavigation.screen))
        XCTAssertTrue(coordinator.hasNavigation(secondNavigation.screen))
        XCTAssertFalse(coordinator.isPresenting)
    }
    
    func testMultiModalNavigation() throws {
        let firstNavigation = Navigation<TestScreen>(screen: .productList, method: .modal)
        let secondNavigation = Navigation<TestScreen>(screen: .productDetail(id: "1"), method: .modal)
        let coordinator = NavigationCoordinator<TestScreen>()
        
        coordinator.navigate(to: firstNavigation)
        coordinator.navigate(to: secondNavigation)
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertFalse(coordinator.hasNavigation)
        XCTAssertTrue(coordinator.isPresenting)
        XCTAssertTrue(coordinator.isPresenting(secondNavigation.screen))
        XCTAssertNotNil(coordinator.modalPresentation)
    }
    
    func testMultiSheetNavigation() throws {
        let firstNavigation = Navigation<TestScreen>(screen: .productList, method: .sheet())
        let secondNavigation = Navigation<TestScreen>(screen: .productDetail(id: "1"), method: .sheet())
        let coordinator = NavigationCoordinator<TestScreen>()
        
        coordinator.navigate(to: firstNavigation)
        coordinator.navigate(to: secondNavigation)
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertFalse(coordinator.hasNavigation)
        XCTAssertTrue(coordinator.isPresenting)
        XCTAssertTrue(coordinator.isPresenting(secondNavigation.screen))
        XCTAssertNotNil(coordinator.sheetPresentation)
    }
    
    func testFlowPushNavigation() throws {
        let flow = NavigationFlow<TestScreen>(
            navigations: [
                Navigation(screen: .cart, method: .push),
                Navigation(screen: .checkout, method: .push),
                Navigation(screen: .checkoutConfirmation, method: .push)
            ])
        let coordinator = NavigationCoordinator<TestScreen>()
        
        coordinator.navigate(to: flow)
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertTrue(coordinator.hasNavigation)
        XCTAssertTrue(coordinator.navigations.count == flow.navigations.count)
        XCTAssertTrue(coordinator.navigations.screens() == flow.screens)
        XCTAssertTrue(coordinator.hasNavigation(flow.navigations[0].screen))
        XCTAssertTrue(coordinator.hasNavigation(flow.navigations[1].screen))
        XCTAssertTrue(coordinator.hasNavigation(flow.navigations[2].screen))
        XCTAssertFalse(coordinator.isPresenting)
    }
    
    func testFlowModalNavigation() throws {
        let flow = NavigationFlow<TestScreen>(
            navigations: [
                Navigation(screen: .cart, method: .modal),
                Navigation(screen: .checkout, method: .modal),
                Navigation(screen: .checkoutConfirmation, method: .modal)
            ])
        let coordinator = NavigationCoordinator<TestScreen>()
        
        coordinator.navigate(to: flow)
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertFalse(coordinator.hasNavigation)
        XCTAssertTrue(coordinator.isPresenting)
        XCTAssertTrue(coordinator.isPresenting(flow.navigations[0].screen))
        XCTAssertNotNil(coordinator.modalPresentation)
        XCTAssertTrue(coordinator.modalPresentation!.remainingFlow!.screens == Array(flow.screens[1...2]))
    }
    
    func testFlowSheetNavigation() throws {
        let flow = NavigationFlow<TestScreen>(
            navigations: [
                Navigation(screen: .cart, method: .sheet()),
                Navigation(screen: .checkout, method: .sheet()),
                Navigation(screen: .checkoutConfirmation, method: .sheet())
            ])
        let coordinator = NavigationCoordinator<TestScreen>()
        
        coordinator.navigate(to: flow)
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertFalse(coordinator.hasNavigation)
        XCTAssertTrue(coordinator.isPresenting)
        XCTAssertTrue(coordinator.isPresenting(flow.navigations[0].screen))
        XCTAssertNotNil(coordinator.sheetPresentation)
        XCTAssertTrue(coordinator.sheetPresentation!.remainingFlow!.screens == Array(flow.screens[1...2]))
    }
}
