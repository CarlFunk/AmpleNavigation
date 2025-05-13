//
//  NavigationCoordinator.swift
//  Navigation
//
//  Created by Carl Funk on 3/30/23.
//  Copyright © 2023 Carl Funk. All rights reserved.
//

import Foundation

/// An object that can determine how to navigate.
public class NavigationCoordinator<Screen: NavigationScreen>: ObservableObject {
    
    /// The push navigations managed by this coordinator.
    @Published internal var navigations: NavigationFlow<Screen> = []
    
    /// The modal navigation managed by this coordinator. There can only be one
    /// managed by a coordinator.
    @Published internal var sheetPresentation: NavigationSheetPresentation<Screen>? = nil
    
    /// The fullscreen navigation managed by this coordinator. There can only be one
    /// managed by a coordinator.
    @Published internal var modalPresentation: NavigationModalPresentation<Screen>? = nil
    
    /// The upstream coordinator that created the current coordinator.
    internal weak var parent: NavigationCoordinator<Screen>?
    
    /// The downstream coordinator that was created by the current coordinator.
    internal weak var child: NavigationCoordinator<Screen>?
    
    // MARK: - Initializers
    
    public init(
        parent: NavigationCoordinator<Screen>? = nil
    ) {
        self.parent = parent
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
    internal func nextCoordinator(navigationFlow: NavigationFlow<Screen>? = nil, completion: NavigationCompletion? = nil) -> NavigationCoordinator<Screen> {
        let coordinator = NavigationCoordinator(parent: self)
        
        child = coordinator
        
        NavigationDelay.perform { [weak coordinator] in
            if let navigationFlow {
                coordinator?.navigate(to: navigationFlow, completion: completion)
            }
        }
        
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
        with method: Navigation<Screen>.Method = .push,
        completion: NavigationCompletion? = nil
    ) {
        let navigation = Navigation(screen: screen, method: method)
        navigate(to: navigation, completion: completion)
    }
    
    /// Perform a navigation.
    public func navigate(
        to navigation: Navigation<Screen>,
        completion: NavigationCompletion? = nil
    ) {
        internalNavigate(to: navigation, completion: completion)
    }
    
    /// Perform a flow navigation, a series of navigations in sequence.
    public func navigate(
        to navigationFlow: NavigationFlow<Screen>,
        completion: NavigationCompletion? = nil
    ) {
        if navigationFlow.isEmpty {
            completion?(.failure(.emptyNavigationFlow))
            return
        }
        
        if navigationFlow.hasOnlyPushMethods() {
            navigations.append(contentsOf: navigationFlow)
            completion?(.success)
            return
        }
        
        if let firstNonPushMethodIndex = navigationFlow.firstNonPushMethodIndex() {
            let navigationFlowCount = navigationFlow.count
            let afterFirstNonPushMethodIndex = navigationFlow.index(firstNonPushMethodIndex, offsetBy: 1, limitedBy: navigationFlowCount) ?? navigationFlowCount
            
            let pushNavigations = navigationFlow[0..<firstNonPushMethodIndex]
            let nonPushNavigation = navigationFlow[firstNonPushMethodIndex]
            let remainingNavigations = NavigationFlow(navigationFlow[afterFirstNonPushMethodIndex..<navigationFlowCount])
            
            navigations.append(contentsOf: pushNavigations)
            
            switch NavigationSettings.flowNavigationSpeed {
            case .quick:
                internalNavigate(
                    to: nonPushNavigation,
                    with: remainingNavigations.isEmpty ? nil : remainingNavigations,
                    completion: completion)
            case .slow:
                NavigationDelay.perform { [weak self] in
                    self?.internalNavigate(
                        to: nonPushNavigation,
                        with: remainingNavigations.isEmpty ? nil : remainingNavigations,
                        completion: completion)
                }
            }
            
        }
    }
    
    /// Handles a single navigation by setting one of the three appropriate properties on the current
    /// coordinator.
    private func internalNavigate(
        to navigation: Navigation<Screen>,
        with remaining: NavigationFlow<Screen>? = nil,
        completion: NavigationCompletion? = nil
    ) {
        switch navigation.method {
        case .push:
            navigations.append(navigation)
        case .sheet(let detents, let showsDragIndicator, let onDismiss):
            sheetPresentation = NavigationSheetPresentation(
                navigation: navigation,
                remainingFlow: remaining,
                detents: detents,
                showsDragIndicator: showsDragIndicator,
                onDismiss: onDismiss)
        case .modal:
            modalPresentation = NavigationModalPresentation(
                navigation: navigation,
                remainingFlow: remaining)
        }
        
        NavigationDelay.perform {
            completion?(.success)
        }
    }
    
    // MARK: - Navigate Backward
    
    /// Dismiss the modal presentation of the current coordinator.
    public func dismiss(_ completion: NavigationCompletion? = nil) {
        guard isPresenting else {
            completion?(.failure(.notCurrentlyPresenting))
            return
        }
        
        modalPresentation = nil
        sheetPresentation = nil
        NavigationDelay.perform {
            completion?(.success)
        }
    }
    
    /// Dismiss the last modal presentation.
    public func dismissLast(_ completion: NavigationCompletion? = nil) {
        if isPresenting {
            dismiss(completion)
        } else if let parent {
            parent.dismissLast(completion)
        } else {
            completion?(.failure(.notCurrentlyPresenting))
        }
    }
    
    /// Dismiss the last push presentation.
    public func popLast(_ completion: NavigationCompletion? = nil) {
        if navigations.isEmpty {
            completion?(.failure(.notCurrentlyNavigating))
            return
        }
        
        let _ = navigations.popLast()
        NavigationDelay.perform {
            completion?(.success)
        }
    }
    
    /// Dismiss all push navigations of the current coordinator until the root screen is displayed.
    public func popAll(_ completion: NavigationCompletion? = nil) {
        if navigations.isEmpty {
            completion?(.failure(.notCurrentlyNavigating))
            return
        }
        
        navigations = []
        NavigationDelay.perform {
            completion?(.success)
        }
    }
    
    /// Dismiss all push navigations of the current coordinator until the desired screen is displayed.
    public func popTo(screen: Screen, completion: NavigationCompletion? = nil) {
        guard let unwindIndex = navigations.lastIndex(where: { $0.screen == screen }) else {
            completion?(.failure(.screenNotFound))
            return
        }
        
        navigations.removeSubrange(navigations.index(after: unwindIndex)..<navigations.count)
        NavigationDelay.perform {
            completion?(.success)
        }
    }
    
    /// Dismiss all push navigations of the current coordinator until the desired screen via id is displayed.
    public func popTo(id: Screen.ID, completion: NavigationCompletion? = nil) {
        guard let unwindIndex = navigations.lastIndex(where: { $0.screen.id == id }) else {
            completion?(.failure(.screenNotFound))
            return
        }
        
        navigations.removeSubrange(navigations.index(after: unwindIndex)..<navigations.count)
        NavigationDelay.perform {
            completion?(.success)
        }
    }
    
    /// Remove all navigations such that the very first screen of the application is displayed.
    public func unwindToRoot(_ completion: NavigationCompletion? = nil) {
        let root = rootCoordinator()
        
        if root.isPresenting {
            root.dismissLast { [weak root] _ in
                root?.popAll(completion)
            }
        } else {
            root.popAll(completion)
        }
    }
    
    /// Remove all navigations backwards until the screen requested via id is displayed.
    public func unwindTo(screen: Screen, completion: NavigationCompletion? = nil) {
        if hasNavigation(screen: screen) {
            dismiss { [weak self] _ in
                self?.popTo(screen: screen, completion: completion)
            }
        } else if let parent, parent.isPresenting(screen: screen) {
            dismiss { [weak self] _ in
                self?.popAll(completion)
            }
        } else if let parent {
            parent.unwindTo(screen: screen, completion: completion)
        } else {
            // At the root and the desired screen was not found
            completion?(.failure(.screenNotFound))
        }
    }
    
    /// Remove all navigations backwards until the screen requested in displayed.
    public func unwindTo(id: Screen.ID, completion: NavigationCompletion? = nil) {
        if hasNavigation(id: id) {
            dismiss { [weak self] _ in
                self?.popTo(id: id, completion: completion)
            }
        } else if let parent, parent.isPresenting(id: id) {
            dismiss { [weak self] _ in
                self?.popAll(completion)
            }
        } else if let parent {
            parent.unwindTo(id: id, completion: completion)
        } else {
            // At the root and the desired screen was not found
            completion?(.failure(.screenNotFound))
        }
    }
}
