//
//  NavigationCoordinator.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 3/30/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

import Foundation

/// An object that can determine how to navigate.
@MainActor
@Observable
public final class NavigationCoordinator<Screen: NavigationScreen> {
    
    /// The navigation that caused the creation of the current coordinator. The
    /// most root navigation of all coordinators will always have a method of `.none`.
    internal let navigation: Navigation<Screen>
    
    /// The push navigations managed by this coordinator.
    internal var pushPresentation: NavigationFlow<Screen>
    
    /// The modal navigation managed by this coordinator. There can only be one
    /// managed by a coordinator at a time. It can be a sheet or a fullScreen.
    internal var presentPresentation: NavigationPresentation<Screen>?
    
    /// The sheet modal navigation managed by this coordinator. This is used
    /// by the view to determine when to show a sheet modal presentation.
    internal var sheetPresentation: NavigationPresentation<Screen>? {
        get {
            return presentPresentation?.isSheetModal == true ? presentPresentation : nil
        }
        set {
            presentPresentation = newValue
        }
    }
    
    /// The full screen modal navigation managed by this coordinator. This is used
    /// by the view to determine when to show a full screen modal presentation.
    internal var fullScreenPresentation: NavigationPresentation<Screen>? {
        get {
            return presentPresentation?.isFullScreenModal == true ? presentPresentation : nil
        }
        set {
            presentPresentation = newValue
        }
    }
    
    /// The upstream coordinator that created the current coordinator.
    internal weak var parent: NavigationCoordinator<Screen>?
    
    /// The downstream coordinator that was created by the current coordinator
    internal var child: NavigationCoordinator<Screen>? {
        return presentPresentation?.coordinator
    }
    
    /// The serttings associated with the current coordinator.
    internal let settings: NavigationSettings
    
    // MARK: - Initializers
    
    public convenience init(
        root: Screen,
        settings: NavigationSettings = NavigationSettings()
    ) {
        self.init(
            navigation: Navigation(screen: root, method: .none),
            parent: nil,
            settings: settings
        )
    }
    
    internal init(
        navigation: Navigation<Screen>,
        parent: NavigationCoordinator<Screen>?,
        settings: NavigationSettings
    ) {
        self.navigation = navigation
        self.parent = parent
        self.settings = settings
        
        self.pushPresentation = []
        self.presentPresentation = nil
        
        if settings.debug {
            setupDebugObserving()
        }
    }
    
    // MARK: - Coordinator
    
    /// The coordinator that is at the root of the application. The root coordinator does not have a parent.
    internal func rootCoordinator() -> NavigationCoordinator<Screen> {
        var root = self
        
        while root.parent != nil {
            root = root.parent!
        }
        
        return root
    }
    
    // MARK: - Status
    
    public var isRoot: Bool {
        rootCoordinator() === self
    }
    
    /// Returns the status of whether a push navigation was performed by this coordinator.
    public var isPushing: Bool {
        !pushPresentation.isEmpty
    }
    
    /// Returns the status of whether a push navigation of a specific screen was performed by this coordinator.
    public func isPushing(screen: Screen) -> Bool {
        pushPresentation.contains(where: { $0.screen == screen })
    }
    
    /// Returns the status of whether a push navigation of a specific screen via id was performed by this coordinator.
    public func isPushing(id: Screen.ID) -> Bool {
        pushPresentation.contains(where: { $0.screen.id == id })
    }
    
    /// Returns the status of whether a modal presentation is in progress by this coordinator.
    public var isPresenting: Bool {
        presentPresentation != nil
    }
    
    /// Returns the status of whether a modal presentation of the specific screen is in progress by this coordinator.
    public func isPresenting(screen: Screen) -> Bool {
        presentPresentation?.navigation.screen == screen
    }
    
    /// Returns the status of whether a modal presentation of the specific screen via id is in progress by this coordinator.
    public func isPresenting(id: Screen.ID) -> Bool {
        presentPresentation?.navigation.screen.id == id
    }
    
    // MARK: - Navigate Forward
    
    public func navigate(
        to screen: Screen,
        with method: Navigation<Screen>.Method = .push,
        onDismiss: @escaping NavigationDismiss = { },
    ) async throws(NavigationFailure) {
        let navigation = Navigation(screen: screen, method: method, onDismiss: onDismiss)
        return try await navigate(to: navigation)
    }
    
    /// Perform a navigation.
    public func navigate(
        to navigation: Navigation<Screen>
    ) async throws(NavigationFailure) {
        return try await internalNavigate(to: navigation)
    }
    
    /// Perform a flow navigation, a series of navigations in sequence.
    public func navigate(
        to navigationFlow: NavigationFlow<Screen>
    ) async throws(NavigationFailure) {
        if navigationFlow.isEmpty {
            throw .emptyNavigationFlow
        }
        
        if navigationFlow.hasOnlyPushMethods() {
            pushPresentation.append(contentsOf: navigationFlow)
            return
        }
        
        if let firstNonPushMethodIndex = navigationFlow.firstNonPushMethodIndex() {
            let navigationFlowCount = navigationFlow.count
            let afterFirstNonPushMethodIndex = navigationFlow.index(firstNonPushMethodIndex, offsetBy: 1, limitedBy: navigationFlowCount) ?? navigationFlowCount
            
            let pushNavigations = navigationFlow[0..<firstNonPushMethodIndex]
            let nonPushNavigation = navigationFlow[firstNonPushMethodIndex]
            let remainingNavigations = NavigationFlow(navigationFlow[afterFirstNonPushMethodIndex..<navigationFlowCount])
            
            pushPresentation.append(contentsOf: pushNavigations)
            
            if settings.speed == .slow {
                await NavigationDelay(time: settings.delay).perform()
            }
            
            return try await internalNavigate(
                to: nonPushNavigation,
                with: remainingNavigations.isEmpty ? nil : remainingNavigations)
        }
    }
    
    /// Handles a single navigation by setting one of the three appropriate properties on the current
    /// coordinator.
    private func internalNavigate(
        to navigation: Navigation<Screen>,
        with remaining: NavigationFlow<Screen>? = nil
    ) async throws(NavigationFailure) {
        switch navigation.method {
        case .push:
            pushPresentation.append(navigation)
            
            if let remaining {
                try await navigate(to: remaining)
            }
        case .sheetModal, .fullScreenModal:
            /// The next coordinator retains a reference to the current coordinator as the parent.
            let nextCoordinator = NavigationCoordinator(navigation: navigation, parent: self, settings: settings)
            presentPresentation = NavigationPresentation(
                navigation: navigation,
                coordinator: nextCoordinator)
            
            if let remaining {
                await NavigationDelay(time: settings.delay).perform()
                try await presentPresentation?.coordinator.navigate(to: remaining)
            }
        default:
            break
        }
        
        await NavigationDelay(time: settings.delay).perform()
    }
    
    // MARK: - Navigate Backward
    
    /// Dismiss the modal presentation of the current coordinator.
    public func dismiss() async throws(NavigationFailure) {
        guard isPresenting else {
            throw .notCurrentlyPresenting
        }
        
        presentPresentation = nil
        
        await NavigationDelay(time: settings.delay).perform()
    }
    
    /// Dismiss the last modal presentation.
    public func dismissLast() async throws(NavigationFailure) {
        if isPresenting {
            try await dismiss()
        } else if let parent {
            try await parent.dismissLast()
        } else {
            throw .notCurrentlyPresenting
        }
    }
    
    /// Dismiss the last push presentation.
    public func popLast() async throws(NavigationFailure) {
        if pushPresentation.isEmpty {
            throw .notCurrentlyNavigating
        }
        
        pushPresentation.removeLast()
        await NavigationDelay(time: settings.delay).perform()
    }
    
    /// Dismiss all push navigations of the current coordinator until the root screen is displayed.
    public func popAll() async throws(NavigationFailure) {
        if pushPresentation.isEmpty {
            throw .notCurrentlyNavigating
        }
        
        pushPresentation = []
        await NavigationDelay(time: settings.delay).perform()
    }
    
    /// Dismiss all push navigations of the current coordinator until the desired screen is displayed.
    public func popTo(screen: Screen) async throws(NavigationFailure) {
        guard let unwindIndex = pushPresentation.lastIndex(where: { $0.screen == screen }) else {
            throw .screenNotFound
        }
        
        pushPresentation.removeSubrange(pushPresentation.index(after: unwindIndex)..<pushPresentation.count)
        await NavigationDelay(time: settings.delay).perform()
    }
    
    /// Dismiss all push navigations of the current coordinator until the desired screen via id is displayed.
    public func popTo(id: Screen.ID) async throws(NavigationFailure) {
        guard let unwindIndex = pushPresentation.lastIndex(where: { $0.screen.id == id }) else {
            throw .screenNotFound
        }
        
        pushPresentation.removeSubrange(pushPresentation.index(after: unwindIndex)..<pushPresentation.count)
        await NavigationDelay(time: settings.delay).perform()
    }
    
    /// Remove all navigations such that the very first screen of the application is displayed.
    public func unwindToRoot() async throws(NavigationFailure) {
        let root = rootCoordinator()

        if root.isPresenting {
            try await root.dismissLast()
        }

        if root.isPushing {
            try await root.popAll()
        }
    }
    
    /// Remove all navigations backwards until the screen requested via id is displayed.
    public func unwindTo(screen: Screen) async throws(NavigationFailure) {
        if isPushing(screen: screen) {
            if isPresenting {
                try await dismiss()
            }
            try await popTo(screen: screen)
        } else if let parent, parent.isPresenting(screen: screen) {
            if isPresenting {
                try await dismiss()
            }

            if isPushing {
                try await popAll()
            }
        } else if let parent {
            try await parent.unwindTo(screen: screen)
        } else {
            // At the root and the desired screen was not found
            throw .screenNotFound
        }
    }
    
    /// Remove all navigations backwards until the screen requested in displayed.
    public func unwindTo(id: Screen.ID) async throws(NavigationFailure) {
        if isPushing(id: id) {
            if isPresenting {
                try await dismiss()
            }
            try await popTo(id: id)
        } else if let parent, parent.isPresenting(id: id) {
            if isPresenting {
                try await dismiss()
            }

            if isPushing {
                try await popAll()
            }
        } else if let parent {
            try await parent.unwindTo(id: id)
        } else {
            // At the root and the desired screen was not found
            throw .screenNotFound
        }
    }
    
    // MARK: - Debug
    
    internal func setupDebugObserving() {
        let _ = withObservationTracking {
            (pushPresentation, presentPresentation)
        } onChange: { [weak self] in
            Task { [weak self] in
                guard let self else { return }
                await print(debugAllNavigations())
                await setupDebugObserving()
            }
        }
    }
    
    internal func debugAllNavigations() -> String {
        var level: Int = 0
        var output: String = "AmpleNavigation:debugAllNavigations\n"
        var coordinator: NavigationCoordinator<Screen>? = rootCoordinator()
        while let currentCoordinator = coordinator {
            ([currentCoordinator.navigation] + currentCoordinator.pushPresentation).enumerated().forEach { index, navigation in
                let prefix = index == 0 ? "\(level)" : "-"
                output += "\(prefix) [\(navigation.method.value)] \(navigation.screen.id) \n"
            }
            
            level += 1
            coordinator = currentCoordinator.child
        }
        
        return output
    }
}
