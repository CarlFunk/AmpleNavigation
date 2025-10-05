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
    
    private let navigation: Navigation<Screen>
    private let screenView: (_ navigation: Navigation<Screen>, _ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    
    internal init(
        navigation: Navigation<Screen>,
        coordinator: NavigationCoordinator<Screen>,
        @ViewBuilder screenView: @escaping (_ navigation : Navigation<Screen>, _ coordinator: NavigationCoordinator<Screen>) -> ScreenView
    ) {
        self.navigation = navigation
        self.coordinator = coordinator
        self.screenView = screenView
    }
    
    var body: some View {
        NavigationStack(path: $coordinator.pushPresentation) {
            screenView(navigation, coordinator)
                .environment(coordinator)
                .navigationDestination(for: Navigation<Screen>.self) { navigation in
                    screenView(navigation, coordinator)
                        .environment(coordinator)
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
                    InternalNavigationCoordinatorView(
                        navigation: sheetPresentation.navigation,
                        coordinator: sheetPresentation.coordinator,
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
                    InternalNavigationCoordinatorView(
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
