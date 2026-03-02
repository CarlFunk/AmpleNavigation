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
        case sheetModal
        case fullScreenModal
        case none
    }
    
    internal let value: InternalValue
    
    internal init(value: InternalValue) {
        self.value = value
    }
    
    /// Forward navigation.
    public static let push = NavigationMethod(value: .push)
    
    /// Modal navigation that can be edited to display over a portion of the screen.
    public static let sheetModal = NavigationMethod(value: .sheetModal)
    
    /// Full Screen modal navigation
    public static let fullScreenModal = NavigationMethod(value: .fullScreenModal)
    
    /// Root navigation
    internal static let none = NavigationMethod(value: .none)
}
