//
//  NavigationDelay.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 8/4/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

import Foundation

/// Helper utilities to use when chaining navigations or performing UI changes immediately after
/// a navigation.
public struct NavigationDelay {
    /// The standard delay time to use when ensuring that a navigation animation is completed.
    public static let standardTime: TimeInterval = 0.625
    
    public let time: TimeInterval
    
    public init(time: TimeInterval = Self.standardTime) {
        self.time = time
    }
    
    /// Perform an action after the delay time.
    ///
    /// SwiftUI navigation is problematic when attempting to perform multiple navigations in
    /// sequence or attempting to display another UI element while the navigation animation
    /// is in progress.
    public func perform() async {
        try? await Task.sleep(for: .seconds(time))
    }
}

