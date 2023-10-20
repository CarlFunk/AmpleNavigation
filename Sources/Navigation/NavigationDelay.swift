//
//  NavigationDelay.swift
//  Navigation
//
//  Created by Carl Funk on 8/4/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

import Foundation

/// Helper utilities to use when chaining navigations or performing UI changes immediately after
/// a navigation.
public struct NavigationDelay {
    /// The standard delay time to use when ensuring that a navigation animation is completed.
    public static let time: TimeInterval = 0.625
    
    /// Perform an action after the standard delay time.
    ///
    /// SwiftUI navigation is problematic when attempting to perform multiple navigations in
    /// sequence or attempting to display another UI element while the navigation animation
    /// is in progress.
    public static func perform(_ completion: @escaping () -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + time) {
            completion()
        }
    }
}
