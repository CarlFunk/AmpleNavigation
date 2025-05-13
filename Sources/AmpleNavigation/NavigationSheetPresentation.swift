//
//  NavigationSheetPresentation.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 3/30/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

import SwiftUI

/// A modal presentation to navigate to.
internal struct NavigationSheetPresentation<Screen: NavigationScreen>: Identifiable {
    /// Unique identifier of the specific full screen modal navigation.
    let id = UUID()
    
    /// The specific navigation of the specific full screen modal navigation.
    let navigation: Navigation<Screen>
    
    /// The additional navigations waiting to be performed.
    let remainingFlow: NavigationFlow<Screen>?
    
    /// The supported modal display options.
    let detents: Set<PresentationDetent>
    
    /// Shows an indicator at the top of the modal that can indicate to the user
    /// that the modal can be swiped to dismiss.
    let showsDragIndicator: Bool
    
    /// The executed closure when the sheet is dismissed.
    let onDismiss: (() -> Void)?
    
    init(
        navigation: Navigation<Screen>,
        remainingFlow: NavigationFlow<Screen>?,
        detents: Set<PresentationDetent>,
        showsDragIndicator: Bool = false,
        onDismiss: (() -> Void)? = nil
    ) {
        self.navigation = navigation
        self.remainingFlow = remainingFlow
        self.detents = detents
        self.showsDragIndicator = showsDragIndicator
        self.onDismiss = onDismiss
    }
}
