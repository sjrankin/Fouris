//
//  ThemeChangeProtocol2.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol theme descriptors use to communicate changes to the theme manager.
protocol ThemeChangeProtocol2: class
{
    /// Called when a theme is changed by setting a property.
    /// - Parameter Theme: The theme that changed.
    /// - Parameter Field: The field that changed.
    func ThemeChanged(Theme: ThemeDescriptor2, Field: ThemeFields)
}
