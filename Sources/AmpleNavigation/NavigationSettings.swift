//
//  NavigationSettings.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 6/1/24.
//  Copyright © 2024 Carl Funk. All rights reserved.
//

import Foundation

public struct NavigationSettings {
    public enum FlowNavigationSpeed {
        case quick
        case slow
    }
    
    public let flowNavigationSpeed: FlowNavigationSpeed
    
    public init(
        flowNavigationSpeed: FlowNavigationSpeed = .quick
    ) {
        self.flowNavigationSpeed = flowNavigationSpeed
    }
}
