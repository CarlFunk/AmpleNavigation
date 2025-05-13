//
//  NavigationFailure.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 5/30/24.
//  Copyright © 2024 Carl Funk. All rights reserved.
//

public enum NavigationFailure: Error {
    case emptyNavigationFlow
    case notCurrentlyNavigating
    case notCurrentlyPresenting
    case screenNotFound
}
