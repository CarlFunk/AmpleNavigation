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
    @Bindable private var coordinator: NavigationCoordinator<Screen>
    
    private let navigation: Navigation<Screen>
    private let screenView: (_ navigation: Navigation<Screen>, _ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    
    public init(
        coordinator: NavigationCoordinator<Screen>,
        screen: Screen,
        @ViewBuilder screenView: @escaping (_ navigation : Navigation<Screen>, _ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    ) {
        self.init(
            navigation: Navigation(screen: screen),
            coordinator: coordinator,
            screenView: screenView)
    }
    
    private init(
        navigation: Navigation<Screen>,
        coordinator: NavigationCoordinator<Screen>,
        @ViewBuilder screenView: @escaping (_ navigation : Navigation<Screen>, _ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    ) {
        self.navigation = navigation
        self.coordinator = coordinator
        self.screenView = screenView
    }
    
    public var body: some View {
        NavigationStack(path: $coordinator.pushPresentation) {
            screenView(navigation, coordinator)
                .environment(coordinator)
                .navigationDestination(for: Navigation<Screen>.self) { navigation in
                    screenView(navigation, coordinator)
                        .environment(coordinator)
                }
                .sheet(item: $coordinator.sheetPresentation) { sheetPresentation in
                    NavigationCoordinatorView(
                        navigation: sheetPresentation.navigation,
                        coordinator: sheetPresentation.coordinator,
                        screenView: { navigation, coordinator in
                            screenView(navigation, coordinator)
                        })
                }
                .fullScreenCover(item: $coordinator.modalPresentation) { modalPresentation in
                    NavigationCoordinatorView(
                        navigation: modalPresentation.navigation,
                        coordinator: modalPresentation.coordinator,
                        screenView: { navigation, coordinator in
                            screenView(navigation, coordinator)
                        })
                }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
