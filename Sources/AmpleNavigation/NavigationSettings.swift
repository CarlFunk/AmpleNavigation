//
//  NavigationSettings.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 6/1/24.
//  Copyright © 2024 Carl Funk. All rights reserved.
//

import Foundation

public struct NavigationSettings: Equatable, Sendable {
    public enum Speed: Equatable, Sendable {
        case quick
        case slow
    }
    
    /// Enable to allow logging of navigation.
    public let debug: Bool
    
    /// The standard delay time to use when ensuring that a navigation animation is completed.
    public let delay: TimeInterval
    
    /// The speed in which to execute navigation flows.
    public let speed: Speed
    
    public init(
        debug: Bool = false,
        delay: TimeInterval = NavigationDelay.standardTime,
        speed: Speed = .quick
    ) {
        self.debug = debug
        self.delay = delay
        self.speed = speed
    }
    
    public static let debugEnabled = NavigationSettings(debug: true)
}
