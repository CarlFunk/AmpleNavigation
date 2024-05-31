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
    @Published internal var navigations: [Navigation<Screen>] = []
    
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
    
    internal func rootCoordinator() -> NavigationCoordinator<Screen> {
        var root = self
        
        while root.parent != nil {
            root = root.parent!
        }
        
        return root
    }
    
    internal func nextCoordinator(navigationFlow: NavigationFlow<Screen>? = nil) -> NavigationCoordinator<Screen> {
        let coordinator = NavigationCoordinator(parent: self)
        
        child = coordinator
        
        NavigationDelay.perform { [weak self] in
            if let navigationFlow {
                self?.navigate(to: navigationFlow)
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
    public func hasNavigation(_ screen: Screen) -> Bool {
        navigations.contains(where: { $0.screen == screen })
    }
    
    /// Returns the status of whether a modal presentation is in progress by this coordinator.
    public var isPresenting: Bool {
        modalPresentation != nil || sheetPresentation != nil
    }
    
    /// Returns the status of whether a modal presentation of the specific screen is in progress by this coordinator.
    public func isPresenting(_ screen: Screen) -> Bool {
        modalPresentation?.navigation.screen == screen || sheetPresentation?.navigation.screen == screen
    }
    
    // MARK: - Navigate Forward
    
    /// Perform a navigation.
    public func navigate(
        to navigation: Navigation<Screen>
    ) {
        internalNavigate(to: navigation)
    }
    
    /// Perform a flow navigation, a series of navigations in sequence.
    public func navigate(
        to navigationFlow: NavigationFlow<Screen>
    ) {
        if navigationFlow.navigations.isEmpty { return }
        let totalNavigations = navigationFlow.navigations.count
        
        let firstIndexOfNonPushMethod = navigationFlow.navigations.firstIndex(where: { $0.method != .push }) ?? totalNavigations
        let pushNavigations = navigationFlow.navigations[0..<firstIndexOfNonPushMethod]
        self.navigations.append(contentsOf: pushNavigations)
        
        // Flow navigation could be completed if no more items in list
        guard navigationFlow.navigations.indices.contains(firstIndexOfNonPushMethod) else { return }
        
        let navigation = navigationFlow.navigations[firstIndexOfNonPushMethod]
        
        if navigationFlow.navigations.count > firstIndexOfNonPushMethod {
            let nextIndexAfterNonPushMethod = firstIndexOfNonPushMethod + 1
            let remainingFlow = NavigationFlow<Screen>(
                navigations: Array(navigationFlow.navigations[nextIndexAfterNonPushMethod..<totalNavigations]))
            internalNavigate(to: navigation, with: remainingFlow)
        } else {
            internalNavigate(to: navigation)
        }
    }
    
    private func internalNavigate(
        to navigation: Navigation<Screen>,
        with remaining: NavigationFlow<Screen>? = nil
    ) {
        switch navigation.method {
        case .push:
            navigations.append(navigation)
        case .sheet(let detents, let showsDragIndicator):
            sheetPresentation = NavigationSheetPresentation(
                navigation: navigation,
                remainingFlow: remaining,
                detents: detents,
                showsDragIndicator: showsDragIndicator)
        case .modal:
            modalPresentation = NavigationModalPresentation(
                navigation: navigation,
                remainingFlow: remaining)
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
        
        navigations.removeSubrange(unwindIndex...navigations.count)
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
    
    /// Remove all navigations backwards until the screen requested in displayed.
    public func unwindTo(screen: Screen, completion: NavigationCompletion? = nil) {
        if hasNavigation(screen) {
            popTo(screen: screen, completion: completion)
        } else if let parent, parent.isPresenting(screen) {
            popAll(completion)
        } else if let parent {
            parent.unwindTo(screen: screen, completion: completion)
        } else {
            // At the root and the desired screen was not found
            completion?(.failure(.screenNotFound))
        }
    }
}
