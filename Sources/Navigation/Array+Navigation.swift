//
//  Array+Navigation.swift
//  Navigation
//
//  Created by Carl Funk on 5/30/24.
//  Copyright © 2024 Carl Funk. All rights reserved.
//

public extension Array {
    func screens<Screen>() -> [Screen] where Element == Navigation<Screen>, Screen: NavigationScreen {
        self.map(\.screen)
    }
}
