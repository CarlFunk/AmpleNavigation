//
//  NavigationPresentation.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 3/30/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

import Foundation

/// A modal presentation to navigate to.
internal final class NavigationPresentation<Screen: NavigationScreen>: Equatable, Identifiable {
    /// Unique identifier of the specific full screen modal navigation.
    let id: UUID
    
    /// The specific navigation of the specific full screen modal navigation.
    let navigation: Navigation<Screen>
    
    /// The navigation coordinator associated with the sheet navigation to be performed.
    let coordinator: NavigationCoordinator<Screen>
    
    init(
        id: UUID = UUID(),
        navigation: Navigation<Screen>,
        coordinator: NavigationCoordinator<Screen>
    ) {
        self.id = id
        self.navigation = navigation
        self.coordinator = coordinator
    }
    
    var isSheetModal: Bool {
        navigation.method == .sheetModal
    }
    
    var isFullScreenModal: Bool {
        navigation.method == .fullScreenModal
    }
    
    static func == (lhs: NavigationPresentation<Screen>, rhs: NavigationPresentation<Screen>) -> Bool {
        lhs.id == rhs.id && lhs.navigation == rhs.navigation && lhs.coordinator === rhs.coordinator
    }
}
