//
//  Navigation.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 7/10/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

/// The representation of a navigation to a specific screen.
public final class Navigation<Screen: NavigationScreen>: Equatable, Hashable {
    public typealias Method = NavigationMethod
    
    /// The specific screen that should be navigated to.
    public let screen: Screen
    
    /// The specific method of navigation to use to reach the designated screen.
    public let method: Method
    
    /// The closure to execute with the navigation in undone
    public let onDismiss: NavigationDismiss
    
    public init(
        screen: Screen,
        method: Method = .push,
        onDismiss: @escaping NavigationDismiss = { }
    ) {
        self.screen = screen
        self.method = method
        self.onDismiss = onDismiss
    }
    
    deinit {
        if [Method.fullScreenModal, Method.sheetModal].contains(method) {
            Task {
                await WindowRedraw.force()
            }
        }
        
        onDismiss()
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(screen)
        hasher.combine(method)
    }
    
    public static func == (lhs: Navigation<Screen>, rhs: Navigation<Screen>) -> Bool {
        lhs.screen == rhs.screen && lhs.method == rhs.method
    }
}
