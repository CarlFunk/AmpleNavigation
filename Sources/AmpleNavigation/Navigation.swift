//
//  Navigation.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 7/10/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

import SwiftUI

/// The representation of a navigation to a specific screen.
public struct Navigation<Screen: NavigationScreen>: Hashable, Sendable {
    
    /// Navigation methods for use.
    public enum Method: Equatable, Hashable, Sendable {
        
        public struct SheetConfiguration: Equatable, Hashable, Sendable {
            public let detents: Set<PresentationDetent>
            public let showsDragIndicator: Bool
            
            public init(
                detents: Set<PresentationDetent> = [.large],
                showsDragIndicator: Bool = false
            ) {
                self.detents = detents
                self.showsDragIndicator = showsDragIndicator
            }
        }
        
        /// Forward navigation.
        case push
        
        /// Modal navigation that can be edited to display over a portion of the screen.
        case sheet(configuration: SheetConfiguration, onDismiss: (@Sendable () -> Void)? = nil)
        
        /// Full screen modal navigation
        case modal
        
        public static func == (lhs: Navigation<Screen>.Method, rhs: Navigation<Screen>.Method) -> Bool {
            switch (lhs, rhs) {
            case (.push, .push):
                return true
            case (.sheet(let lhsConfiguration, _), .sheet(let rhsConfiguration, _)):
                return lhsConfiguration == rhsConfiguration
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
