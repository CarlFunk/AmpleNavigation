//
//  NavigationCoordinatorTests.swift
//  AmpleNavigationTests
//
//  Created by Carl Funk on 5/30/24.
//  Copyright © 2024 Carl Funk. All rights reserved.
//

@testable import AmpleNavigation
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
        XCTAssertTrue(coordinator.hasNavigation(screen: navigation.screen))
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
        XCTAssertTrue(coordinator.isPresenting(screen: navigation.screen))
    }
    
    func testSingleSheetNavigation() throws {
        let navigation = Navigation<TestScreen>(screen: .productList, method: .sheet())
        let coordinator = NavigationCoordinator<TestScreen>()
        
        coordinator.navigate(to: navigation)
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertFalse(coordinator.hasNavigation)
        XCTAssertTrue(coordinator.isPresenting)
        XCTAssertTrue(coordinator.isPresenting(screen: navigation.screen))
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
        XCTAssertTrue(coordinator.hasNavigation(screen: firstNavigation.screen))
        XCTAssertTrue(coordinator.hasNavigation(screen: secondNavigation.screen))
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
        XCTAssertTrue(coordinator.isPresenting(screen: secondNavigation.screen))
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
        XCTAssertTrue(coordinator.isPresenting(screen: secondNavigation.screen))
        XCTAssertNotNil(coordinator.sheetPresentation)
    }
    
    func testFlowPushNavigation() throws {
        let flow: NavigationFlow<TestScreen> = [
            Navigation(screen: .cart, method: .push),
            Navigation(screen: .checkout, method: .push),
            Navigation(screen: .checkoutConfirmation, method: .push)
        ]
        let coordinatorNavigated = XCTestExpectation(description: "Coordinator navigated")
        let coordinator = NavigationCoordinator<TestScreen>()
        
        coordinator.navigate(to: flow) { _ in
            coordinatorNavigated.fulfill()
        }
        
        wait(for: [coordinatorNavigated], timeout: 5)
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertTrue(coordinator.hasNavigation)
        XCTAssertTrue(coordinator.navigations.count == flow.count)
        XCTAssertTrue(coordinator.navigations.screens() == flow.screens())
        XCTAssertTrue(coordinator.hasNavigation(screen: flow[0].screen))
        XCTAssertTrue(coordinator.hasNavigation(screen: flow[1].screen))
        XCTAssertTrue(coordinator.hasNavigation(screen: flow[2].screen))
        XCTAssertFalse(coordinator.isPresenting)
    }
    
    func testFlowModalNavigation() throws {
        let flow: NavigationFlow<TestScreen> = [
            Navigation(screen: .cart, method: .modal),
            Navigation(screen: .checkout, method: .modal),
            Navigation(screen: .checkoutConfirmation, method: .modal)
        ]
        let coordinatorNavigated = XCTestExpectation(description: "Coordinator navigated")
        let coordinator = NavigationCoordinator<TestScreen>()
        
        coordinator.navigate(to: flow) { _ in
            coordinatorNavigated.fulfill()
        }
        
        wait(for: [coordinatorNavigated], timeout: 5)
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertFalse(coordinator.hasNavigation)
        XCTAssertTrue(coordinator.isPresenting)
        XCTAssertTrue(coordinator.isPresenting(screen: flow[0].screen))
        XCTAssertNotNil(coordinator.modalPresentation)
        XCTAssertTrue(coordinator.modalPresentation!.remainingFlow!.screens() == Array(flow.screens()[1...2]))
    }
    
    func testFlowSheetNavigation() throws {
        let flow: NavigationFlow<TestScreen> = [
            Navigation(screen: .cart, method: .sheet()),
            Navigation(screen: .checkout, method: .sheet()),
            Navigation(screen: .checkoutConfirmation, method: .sheet())
        ]
        let coordinatorNavigated = XCTestExpectation(description: "Coordinator navigated")
        let coordinator = NavigationCoordinator<TestScreen>()
        
        coordinator.navigate(to: flow) { _ in
            coordinatorNavigated.fulfill()
        }
        
        wait(for: [coordinatorNavigated], timeout: 5)
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNil(coordinator.child)
        XCTAssertFalse(coordinator.hasNavigation)
        XCTAssertTrue(coordinator.isPresenting)
        XCTAssertTrue(coordinator.isPresenting(screen: flow[0].screen))
        XCTAssertNotNil(coordinator.sheetPresentation)
        XCTAssertTrue(coordinator.sheetPresentation!.remainingFlow!.screens() == Array(flow.screens()[1...2]))
    }
    
    func testFlowVariedNavigation() throws {
        let flow: NavigationFlow<TestScreen> = [
            Navigation(screen: .productList, method: .push),
            Navigation(screen: .productDetail(id: "1"), method: .sheet()),
            Navigation(screen: .cart, method: .modal),
            Navigation(screen: .checkout, method: .push),
            Navigation(screen: .checkoutConfirmation, method: .push)
        ]
        
        let coordinatorNavigated = XCTestExpectation(description: "Coordinator navigated")
        let secondCoordinatorNavigated = XCTestExpectation(description: "Second Coordinator navigated")
        let thirdCoordinatorNavigated = XCTestExpectation(description: "Third Coordinator navigated")
        
        var coordinator: NavigationCoordinator<TestScreen>!
        var secondCoordinator: NavigationCoordinator<TestScreen>!
        var thirdCoordinator: NavigationCoordinator<TestScreen>!
        
        coordinator = NavigationCoordinator<TestScreen>()
        coordinator.navigate(to: flow) { _ in
            coordinatorNavigated.fulfill()
            secondCoordinator = coordinator.nextCoordinator(navigationFlow: coordinator.sheetPresentation?.remainingFlow) { _ in
                secondCoordinatorNavigated.fulfill()
                thirdCoordinator = secondCoordinator.nextCoordinator(navigationFlow: secondCoordinator.modalPresentation?.remainingFlow) { _ in
                    thirdCoordinatorNavigated.fulfill()
                }
            }
        }
        
        wait(for: [coordinatorNavigated, secondCoordinatorNavigated, thirdCoordinatorNavigated], timeout: 5)
        
        XCTAssertNil(coordinator.parent)
        XCTAssertNotNil(coordinator.child)
        XCTAssertTrue(coordinator.hasNavigation)
        XCTAssertTrue(coordinator.hasNavigation(screen: flow[0].screen))
        XCTAssertTrue(coordinator.isPresenting)
        XCTAssertTrue(coordinator.isPresenting(screen: flow[1].screen))
        XCTAssertNotNil(coordinator.sheetPresentation)
        
        XCTAssertNotNil(secondCoordinator.parent)
        XCTAssertNotNil(secondCoordinator.child)
        XCTAssertFalse(secondCoordinator.hasNavigation)
        XCTAssertTrue(secondCoordinator.isPresenting)
        XCTAssertTrue(secondCoordinator.isPresenting(screen: flow[2].screen))
        XCTAssertNotNil(secondCoordinator.modalPresentation)
        
        XCTAssertNotNil(thirdCoordinator.parent)
        XCTAssertNil(thirdCoordinator.child)
        XCTAssertTrue(thirdCoordinator.hasNavigation)
        XCTAssertTrue(thirdCoordinator.hasNavigation(screen: flow[3].screen))
        XCTAssertTrue(thirdCoordinator.hasNavigation(screen: flow[4].screen))
        XCTAssertFalse(thirdCoordinator.isPresenting)
    }
}
