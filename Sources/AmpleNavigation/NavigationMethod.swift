//
//  NavigationMethod.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 10/5/25.
//  Copyright © 2025 Carl Funk. All rights reserved.
//

import Foundation

public struct NavigationMethod: Equatable, Hashable, Sendable {
    internal enum InternalValue: Equatable, Hashable {
        case push
        case sheet
        case modal
        case none
    }
    
    internal let value: InternalValue
    
    internal init(value: InternalValue) {
        self.value = value
    }
    
    /// Forward navigation.
    public static let push = NavigationMethod(value: .push)
    
    /// Modal navigation that can be edited to display over a portion of the screen.
    public static let sheet = NavigationMethod(value: .sheet)
    
    /// Full screen modal navigation
    public static let modal = NavigationMethod(value: .modal)
    
    /// Root navigation
    internal static let none = NavigationMethod(value: .none)
}
