//
//  ManagedNavigationCoordinatorView.swift
//  Navigation
//
//  Created by Carl Funk on 7/10/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

import SwiftUI

/// A coordinator view displays screens and navigations. Use this specific coordinator view when
/// managing the coordinator's lifecycle is NOT required. If deeplinking is not a requirement, using
/// this coordinator view will tie the coordinator's lifecycle to it.
public struct ManagedNavigationCoordinatorView<Screen: NavigationScreen, ScreenView: View>: View {
    @StateObject private var coordinator: NavigationCoordinator<Screen>
    
    private let rootView: (_ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    private let screenView: (_ navigation: Navigation<Screen>, _ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    
    public init(
        coordinator: NavigationCoordinator<Screen> = NavigationCoordinator(),
        rootView: @escaping (_ coordinator: NavigationCoordinator<Screen>) -> ScreenView,
        screenView: @escaping (_ navigation : Navigation<Screen>, _ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    ) {
        self._coordinator = StateObject(wrappedValue: coordinator)
        self.rootView = rootView
        self.screenView = screenView
    }
    
    public var body: some View {
        InternalNavigationCoordinatorView(
            coordinator: coordinator,
            rootView: rootView,
            screenView: screenView)
    }
}
