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
    /// Called when a theme is changed by setting a propery.
    /// - Parameter ThemeName: Name of the theme that changed.
    /// - Parameter FieldName: Name of the field that changed.
    func ThemeChanged(ThemeName: String, FieldName: String)
}
