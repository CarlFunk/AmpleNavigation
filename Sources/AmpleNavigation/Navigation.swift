//
//  Navigation.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 7/10/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

/// The representation of a navigation to a specific screen.
public final class Navigation<Screen: NavigationScreen>: Equatable, Hashable {
    
    /// Navigation methods for use.
    public enum Method: Equatable, Hashable {
        /// Forward navigation.
        case push
        
        /// Modal navigation that can be edited to display over a portion of the screen.
        case sheet
        
        /// Full screen modal navigation
        case modal
    }
    
    /// The specific screen that should be navigated to.
    public var screen: Screen
    
    /// The specific method of navigation to use to reach the designated screen.
    public var method: Method
    
    /// The closure to execute with the navigation in undone
    public var onDismiss: NavigationDismiss
    
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
        if [Method.modal, Method.sheet].contains(method) {
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
