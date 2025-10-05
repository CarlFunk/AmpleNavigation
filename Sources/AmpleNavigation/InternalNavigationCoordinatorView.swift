//
//  InternalNavigationCoordinatorView.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 3/30/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

import SwiftUI

internal struct InternalNavigationCoordinatorView<Screen: NavigationScreen, ScreenView: View>: View {
    @Bindable private var coordinator: NavigationCoordinator<Screen>
    
    private let screenType: Navigation<Screen>.Type
    private let rootView: (_ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    private let screenView: (_ navigation: Navigation<Screen>, _ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    
    init(
        coordinator: NavigationCoordinator<Screen>,
        rootView: @escaping (_ coordinator: NavigationCoordinator<Screen>) -> ScreenView,
        screenView: @escaping (_ navigation : Navigation<Screen>, _ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    ) {
        self.coordinator = coordinator
        self.screenType = Navigation<Screen>.self
        self.rootView = rootView
        self.screenView = screenView
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.pushPresentation) {
            rootView(coordinator)
                .navigationDestination(for: screenType) { navigation in
                    screenView(navigation, coordinator)
                }
                .sheet(
                    item: Binding(get: {
                        (coordinator.modalPresentation?.isSheet ?? false) ? coordinator.modalPresentation : nil
                    }, set: { modalPresentation in
                        guard modalPresentation == nil else { return }
                        WindowRedraw.force()
                        Task {
                            try await coordinator.dismiss()
                        }
                    })
                ) { sheetPresentation in
                    ManagedNavigationCoordinatorView(
                        coordinator: sheetPresentation.coordinator,
                        rootView: { coordinator in
                            screenView(sheetPresentation.navigation, coordinator)
                        },
                        screenView: { navigation, coordinator in
                            screenView(navigation, coordinator)
                        })
                }
                .fullScreenCover(
                    item: Binding(get: {
                        (coordinator.modalPresentation?.isModal ?? false) ? coordinator.modalPresentation : nil
                    }, set: { modalPresentation in
                        guard modalPresentation == nil else { return }
                        WindowRedraw.force()
                        Task {
                            try await coordinator.dismiss()
                        }
                    })
                ) { modalPresentation in
                    ManagedNavigationCoordinatorView(
                        coordinator: modalPresentation.coordinator,
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
