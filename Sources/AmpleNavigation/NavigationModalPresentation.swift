//
//  NavigationModalPresentation.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 3/30/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

import Foundation

/// A fullscreen modal presentation to navigate to.
internal struct NavigationModalPresentation<Screen: NavigationScreen>: Identifiable {
    /// Unique identifier of the specific full screen modal navigation.
    let id = UUID()
    
    /// The specific navigation of the specific full screen modal navigation.
    let navigation: Navigation<Screen>
    
    /// The additional navigations waiting to be performed.
    let remainingFlow: NavigationFlow<Screen>?
    
    init(
        navigation: Navigation<Screen>,
        remainingFlow: NavigationFlow<Screen>?
    ) {
        self.navigation = navigation
        self.remainingFlow = remainingFlow
    }
}
