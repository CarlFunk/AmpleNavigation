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
    public weak var parent: NavigationCoordinator<Screen>?
    
    public init(
        parent: NavigationCoordinator<Screen>? = nil,
        navigationFlow: NavigationFlow<Screen>? = nil
    ) {
        self.parent = parent
        
        NavigationDelay.perform { [weak self] in
            if let navigationFlow {
                self?.navigate(to: navigationFlow)
            }
        }
    }
    
    /// Returns the status of whether a modal presentation is in progress by this coordinator.
    public var isPresenting: Bool {
        return modalPresentation != nil || sheetPresentation != nil
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
    
    /// Dismiss the last modal presentation.
    public func dismissLast(_ completion: (() -> Void)? = nil) {
        if isPresenting {
            modalPresentation = nil
            sheetPresentation = nil
            NavigationDelay.perform {
                completion?()
            }
        } else {
            parent?.dismissLast()
        }
    }
    
    /// Remove all push navigations of the coordinator and display the original screen.
    public func popAll() {
        navigations = []
    }
    
    /// Remove all navigations recursively until the very first screen of the application is displayed.
    public func popToRoot(_ completion: (() -> Void)? = nil) {
        var rootParent = parent
        while rootParent?.parent != nil {
            rootParent = rootParent?.parent
        }
        
        guard let rootParent else { return }
        if rootParent.isPresenting {
            rootParent.dismissLast { [weak rootParent] in
                rootParent?.popAll()
            }
        } else {
            rootParent.popAll()
        }
    }
}
