//
//  ThemeChangeProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/22/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol theme descriptors use to communicate changes to the theme manager. 
protocol ThemeChangeProtocol: class
{
    /// Called when a theme is changed by setting a property.
    /// - Parameter ThemeName: The name of the theme that changed.
    /// - Parameter Field: The field that changed.
    func ThemeChanged(ThemeName: String, Field: ThemeFields)
}
