//
//  NavigationSettings.swift
//  Navigation
//
//  Created by Carl Funk on 6/1/24.
//  Copyright © 2024 Carl Funk. All rights reserved.
//

import Foundation

public struct NavigationSettings {
    private init() { }
    
    public enum FlowNavigationSpeed {
        case quick
        case slow
    }
    
    public static var flowNavigationSpeed: FlowNavigationSpeed = .quick
}
