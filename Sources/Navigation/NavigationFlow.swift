//
//  NavigationFlow.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 8/4/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

/// A collection of navigations to perform. Often times this is in response to
/// receiving a deeplink.
public typealias NavigationFlow<Screen: NavigationScreen> = [Navigation<Screen>]

public extension NavigationFlow {
    func screens<Screen>() -> [Screen] where Element == Navigation<Screen>, Screen: NavigationScreen {
        self.map(\.screen)
    }
    
    func methods<Screen>() -> [Navigation<Screen>.Method] where Element == Navigation<Screen>, Screen: NavigationScreen {
        self.map(\.method)
    }
    
    func uniqueMethods<Screen>() -> Set<Navigation<Screen>.Method> where Element == Navigation<Screen>, Screen: NavigationScreen {
        Set(self.map(\.method))
    }
    
    func hasOnlyPushMethods<Screen>() -> Bool where Element == Navigation<Screen>, Screen: NavigationScreen {
        let uniqueMethods = uniqueMethods()
        return uniqueMethods.count == 1 && uniqueMethods.contains(.push)
    }
    
    func firstNonPushMethodIndex<Screen>() -> Int? where Element == Navigation<Screen> {
        methods().firstIndex(where: { $0 != .push })
    }
}
