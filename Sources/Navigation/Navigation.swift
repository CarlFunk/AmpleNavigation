//
//  Navigation.swift
//  Navigation
//
//  Created by Carl Funk on 7/10/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

import SwiftUI

/// The representation of a navigation to a specific screen.
public struct Navigation<Screen: NavigationScreen>: Hashable {
    
    /// Navigation methods for use.
    public enum Method: Equatable, Hashable {
        
        /// Forward navigation.
        case push
        
        /// Modal navigation that can be edited to display over a portion of the screen.
        case sheet(detents: Set<PresentationDetent> = [.large], showsDragIndicator: Bool = false, onDismiss: (() -> Void)? = nil)
        
        /// Full screen modal navigation
        case modal
        
        public static func == (lhs: Navigation<Screen>.Method, rhs: Navigation<Screen>.Method) -> Bool {
            switch (lhs, rhs) {
            case (.push, .push):
                return true
            case (.sheet, .sheet):
                return true
            case (.modal, .modal):
                return true
            default:
                return false
            }
        }
        
        public func hash(into hasher: inout Hasher) {
            switch self {
            case .push:
                hasher.combine("push")
            case .sheet:
                hasher.combine("sheet")
            case .modal:
                hasher.combine("modal")
            }
        }
    }
    
    /// The specific screen that should be navigated to.
    public var screen: Screen
    
    /// The specific method of navigation to use to reach the designated screen.
    public var method: Method
    
    public init(
        screen: Screen,
        method: Method = .push
    ) {
        self.screen = screen
        self.method = method
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(screen)
        hasher.combine(method.hashValue)
    }
}
