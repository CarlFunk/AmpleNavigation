//
//  NavigationFlow.swift
//  Navigation
//
//  Created by Carl Funk on 8/4/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

/// A collection of navigations to perform. Often times this is in response to
/// receiving a deeplink.
public class NavigationFlow<Screen: NavigationScreen> {
    /// A list of navigations to perform in order.
    public let navigations: [Navigation<Screen>]
    
    public init(navigations: [Navigation<Screen>]) {
        self.navigations = navigations
    }
    
    public var screens: [Screen] {
        navigations.map(\.screen)
    }
}
