//
//  NavigationSettings.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 6/1/24.
//  Copyright © 2024 Carl Funk. All rights reserved.
//

public struct NavigationSettings: Equatable {
    public enum Speed: Equatable {
        case quick
        case slow
    }
    
    public let speed: Speed
    
    public init(
        speed: Speed = .quick
    ) {
        self.speed = speed
    }
}
