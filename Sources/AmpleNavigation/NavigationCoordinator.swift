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
public class NavigationCoordinator<Screen: NavigationScreen> {
    
    /// The push navigations managed by this coordinator.
    internal var navigations: NavigationFlow<Screen> = []
    
    /// The modal navigation managed by this coordinator. There can only be one
    /// managed by a coordinator.
    internal var sheetPresentation: NavigationSheetPresentation<Screen>? = nil
    
    /// The fullscreen navigation managed by this coordinator. There can only be one
    /// managed by a coordinator.
    internal var modalPresentation: NavigationModalPresentation<Screen>? = nil
    
    /// The upstream coordinator that created the current coordinator.
    internal weak var parent: NavigationCoordinator<Screen>?
    
    /// The downstream coordinator that was created by the current coordinator.
    internal weak var child: NavigationCoordinator<Screen>?
    
    /// The serttings associated with the current coordinator.
    internal let settings: NavigationSettings
    
    // MARK: - Initializers
    
    public init(
        parent: NavigationCoordinator<Screen>? = nil,
        settings: NavigationSettings = NavigationSettings()
    ) {
        self.parent = parent
        self.settings = settings
    }
    
    // MARK: - Internal
    
    /// The coordinator that is at the root of the application. The root coordinator does not have a parent.
    internal func rootCoordinator() -> NavigationCoordinator<Screen> {
        var root = self
        
        while root.parent != nil {
            root = root.parent!
        }
        
        return root
    }
    
    /// Obtain the next coordinator that should be created when a modal / sheet navigation is invoked.
    /// The next coordinator retains a reference to the current coordinator as the parent while setting the next
    /// coordinator as the child of the current coordinator.
    internal func nextCoordinator(navigationFlow: NavigationFlow<Screen>? = nil) -> NavigationCoordinator<Screen> {
        let coordinator = NavigationCoordinator(parent: self, settings: settings)
        child = coordinator
        return coordinator
    }
    
    // MARK: - Status
    
    /// Returns the status of whether a push navigation was performed by this coordinator.
    public var hasNavigation: Bool {
        !navigations.isEmpty
    }
    
    /// Returns the status of whether a push navigation of a specific screen was performed by this coordinator.
    public func hasNavigation(screen: Screen) -> Bool {
        navigations.contains(where: { $0.screen == screen })
    }
    
    /// Returns the status of whether a push navigation of a specific screen via id was performed by this coordinator.
    public func hasNavigation(id: Screen.ID) -> Bool {
        navigations.contains(where: { $0.screen.id == id })
    }
    
    /// Returns the status of whether a modal presentation is in progress by this coordinator.
    public var isPresenting: Bool {
        modalPresentation != nil || sheetPresentation != nil
    }
    
    /// Returns the status of whether a modal presentation of the specific screen is in progress by this coordinator.
    public func isPresenting(screen: Screen) -> Bool {
        modalPresentation?.navigation.screen == screen || sheetPresentation?.navigation.screen == screen
    }
    
    /// Returns the status of whether a modal presentation of the specific screen via id is in progress by this coordinator.
    public func isPresenting(id: Screen.ID) -> Bool {
        modalPresentation?.navigation.screen.id == id || sheetPresentation?.navigation.screen.id == id
    }
    
    // MARK: - Navigate Forward
    
    public func navigate(
        to screen: Screen,
        with method: Navigation<Screen>.Method = .push
    ) async throws {
        let navigation = Navigation(screen: screen, method: method)
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
            navigations.append(contentsOf: navigationFlow)
            return
        }
        
        if let firstNonPushMethodIndex = navigationFlow.firstNonPushMethodIndex() {
            let navigationFlowCount = navigationFlow.count
            let afterFirstNonPushMethodIndex = navigationFlow.index(firstNonPushMethodIndex, offsetBy: 1, limitedBy: navigationFlowCount) ?? navigationFlowCount
            
            let pushNavigations = navigationFlow[0..<firstNonPushMethodIndex]
            let nonPushNavigation = navigationFlow[firstNonPushMethodIndex]
            let remainingNavigations = NavigationFlow(navigationFlow[afterFirstNonPushMethodIndex..<navigationFlowCount])
            
            navigations.append(contentsOf: pushNavigations)
            
            switch settings.flowNavigationSpeed {
            case .quick:
                return try await internalNavigate(
                    to: nonPushNavigation,
                    with: remainingNavigations.isEmpty ? nil : remainingNavigations)
            case .slow:
                await NavigationDelay.perform()
                return try await internalNavigate(
                    to: nonPushNavigation,
                    with: remainingNavigations.isEmpty ? nil : remainingNavigations)
            }
            
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
            navigations.append(navigation)
        case .sheet(let configuration, let onDismiss):
            sheetPresentation = NavigationSheetPresentation(
                navigation: navigation,
                remainingFlow: remaining,
                detents: configuration.detents,
                showsDragIndicator: configuration.showsDragIndicator,
                onDismiss: onDismiss)
        case .modal:
            modalPresentation = NavigationModalPresentation(
                navigation: navigation,
                remainingFlow: remaining)
        }
        
        await NavigationDelay.perform()
    }
    
    // MARK: - Navigate Backward
    
    /// Dismiss the modal presentation of the current coordinator.
    public func dismiss() async throws(NavigationFailure) {
        guard isPresenting else {
            throw .notCurrentlyPresenting
        }
        
        modalPresentation = nil
        sheetPresentation = nil
        
        await NavigationDelay.perform()
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
        if navigations.isEmpty {
            throw .notCurrentlyNavigating
        }
        
        let _ = navigations.popLast()
        await NavigationDelay.perform()
    }
    
    /// Dismiss all push navigations of the current coordinator until the root screen is displayed.
    public func popAll() async throws(NavigationFailure) {
        if navigations.isEmpty {
            throw .notCurrentlyNavigating
        }
        
        navigations = []
        await NavigationDelay.perform()
    }
    
    /// Dismiss all push navigations of the current coordinator until the desired screen is displayed.
    public func popTo(screen: Screen) async throws(NavigationFailure) {
        guard let unwindIndex = navigations.lastIndex(where: { $0.screen == screen }) else {
            throw .screenNotFound
        }
        
        navigations.removeSubrange(navigations.index(after: unwindIndex)..<navigations.count)
        await NavigationDelay.perform()
    }
    
    /// Dismiss all push navigations of the current coordinator until the desired screen via id is displayed.
    public func popTo(id: Screen.ID) async throws(NavigationFailure) {
        guard let unwindIndex = navigations.lastIndex(where: { $0.screen.id == id }) else {
            throw .screenNotFound
        }
        
        navigations.removeSubrange(navigations.index(after: unwindIndex)..<navigations.count)
        await NavigationDelay.perform()
    }
    
    /// Remove all navigations such that the very first screen of the application is displayed.
    public func unwindToRoot() async throws(NavigationFailure) {
        let root = rootCoordinator()
        
        if root.isPresenting {
            try await root.dismissLast()
            try await root.popAll()
        } else {
            try await root.popAll()
        }
    }
    
    /// Remove all navigations backwards until the screen requested via id is displayed.
    public func unwindTo(screen: Screen) async throws(NavigationFailure) {
        if hasNavigation(screen: screen) {
            try await dismiss()
            try await popTo(screen: screen)
        } else if let parent, parent.isPresenting(screen: screen) {
            try await dismiss()
            try await popAll()
        } else if let parent {
            try await parent.unwindTo(screen: screen)
        } else {
            // At the root and the desired screen was not found
            throw .screenNotFound
        }
    }
    
    /// Remove all navigations backwards until the screen requested in displayed.
    public func unwindTo(id: Screen.ID) async throws(NavigationFailure) {
        if hasNavigation(id: id) {
            try await dismiss()
            try await popTo(id: id)
        } else if let parent, parent.isPresenting(id: id) {
            try await dismiss()
            try await popAll()
        } else if let parent {
            try await parent.unwindTo(id: id)
        } else {
            // At the root and the desired screen was not found
            throw .screenNotFound
        }
    }
}

