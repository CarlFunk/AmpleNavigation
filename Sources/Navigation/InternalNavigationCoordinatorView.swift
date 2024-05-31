//
//  InternalNavigationCoordinatorView.swift
//  Navigation
//
//  Created by Carl Funk on 3/30/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

import SwiftUI

internal struct InternalNavigationCoordinatorView<Screen: NavigationScreen, ScreenView: View>: View {
    @ObservedObject private var coordinator: NavigationCoordinator<Screen>
    
    private let screenType: Navigation<Screen>.Type
    private let rootView: (_ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    private let screenView: (_ navigation: Navigation<Screen>, _ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    
    init(
        coordinator: NavigationCoordinator<Screen>,
        rootView: @escaping (_ coordinator: NavigationCoordinator<Screen>) -> ScreenView,
        screenView: @escaping (_ navigation : Navigation<Screen>, _ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    ) {
        self._coordinator = ObservedObject(wrappedValue: coordinator)
        self.screenType = Navigation<Screen>.self
        self.rootView = rootView
        self.screenView = screenView
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.navigations) {
            rootView(coordinator)
                .navigationDestination(for: screenType) { navigation in
                    screenView(navigation, coordinator)
                }
                .sheet(item: $coordinator.sheetPresentation) { sheetPresentation in
                    ManagedNavigationCoordinatorView(
                        coordinator: coordinator.nextCoordinator(navigationFlow: sheetPresentation.remainingFlow),
                        rootView: { coordinator in
                            screenView(sheetPresentation.navigation, coordinator)
                        },
                        screenView: { navigation, coordinator in
                            screenView(navigation, coordinator)
                        })
                    .presentationDetents(sheetPresentation.detents)
                    .presentationDragIndicator(sheetPresentation.showsDragIndicator ? .visible : .hidden)
                }
                .fullScreenCover(item: $coordinator.modalPresentation) { modalPresentation in
                    ManagedNavigationCoordinatorView(
                        coordinator: coordinator.nextCoordinator(navigationFlow: modalPresentation.remainingFlow),
                        rootView: { coordinator in
                            screenView(modalPresentation.navigation, coordinator)
                        },
                        screenView: { navigation, coordinator in
                            screenView(navigation, coordinator)
                        })
                }
        }
        .navigationSplitViewStyle(.balanced)
    }
}
