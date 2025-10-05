//
//  NavigationCoordinatorView.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 7/10/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

import SwiftUI

/// A coordinator view displays screens and navigations. Use this specific coordinator view when
/// managing the coordinator's lifecycle is required. Situations that might require this are for
/// flow navigations after receiving a deeplink. Typically this would only require the most root
/// coordinator to be managed by the developer.
public struct NavigationCoordinatorView<Screen: NavigationScreen, ScreenView: View>: View {
    private var coordinator: NavigationCoordinator<Screen>
    
    private let screen: Screen
    private let screenView: (_ navigation: Navigation<Screen>, _ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    
    public init(
        coordinator: NavigationCoordinator<Screen>,
        screen: Screen,
        @ViewBuilder screenView: @escaping (_ navigation : Navigation<Screen>, _ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    ) {
        self.coordinator = coordinator
        self.screen = screen
        self.screenView = screenView
    }
    
    public var body: some View {
        InternalNavigationCoordinatorView(
            navigation: Navigation(screen: screen),
            coordinator: coordinator,
            screenView: screenView)
    }
}
