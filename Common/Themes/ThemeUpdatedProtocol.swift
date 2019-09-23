//
//  ThemeUpdatedProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/22/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol used to communicate between the theme manager and subscribers. Called when the theme is updated and subscribers
/// need to change immediately.
protocol ThemeUpdatedProtocol
{
    /// Called when a theme field changes when someone sets its property.
    /// - Note: Called at each change even if the field is changed back to the original value.
    /// - Parameter ThemeName: Name of the changed theme.
    /// - Parameter Field: The field that changed.
    func ThemeUpdated(ThemeName: String, Field: ThemeFields)
}
