//
//  WindowRedraw.swift
//  AmpleNavigation
//
//  Created by Carl Funk on 5/12/25.
//  Copyright © 2025 Carl Funk. All rights reserved.
//

import Foundation
import UIKit

public struct WindowRedraw {
    /// SwiftUI Sheets that are pulled down after backgrounding the app were found to have
    /// UI mis-alignment issues that were not visible to the user but could be seen using the
    /// UI Debugger. The mis-alignment causes a tap zone to not be where the user expects.
    public static func force() {
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        
        if let frame = windowScene?.windows.first?.rootViewController?.view.frame {
            windowScene?.windows.first?.rootViewController?.view.frame = .zero
            windowScene?.windows.first?.rootViewController?.view.frame = frame
        }
    }
}
