//
//  TestScreen.swift
//  NavigationTests
//
//  Created by Carl Funk on 5/30/24.
//  Copyright © 2024 Carl Funk. All rights reserved.
//

import Navigation

enum TestScreen: NavigationScreen {
    case cart
    case checkout
    case checkoutConfirmation
    case home
    case productDetail(id: String)
    case productList
}
