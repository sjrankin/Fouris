//
//  ColorPickerProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/30/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for assigning default colors and returning new colors from the color picker.
protocol ColorPickerProtocol: class
{
    /// Set the color to edit.
    /// - Parameter Color: The color to edit.
    /// - Parameter Tag: Value returned to the caller in **EditedColor**. Provided as a convenience. Not
    ///                  changed by the color picker.
    func ColorToEdit(_ Color: UIColor, Tag: Any?)
    
    /// Returns the newly edited color from the color picker.
    /// - Parameter Edited: The edited color. If nil, no change (the user canceled editing).
    /// - Parameter Tag: Value assigned in call to **ColorToEdit**. Provided as a convenience. Not changed
    ///                  by the color picker.
    func EditedColor(_ Edited: UIColor?, Tag: Any?)
}
