//
//  +Bool.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension RawThemeViewerCode
{
    /// Populate the Bool editin view.
    /// - Parameter WithField: The group field to populate the view with.
    public func PopulateBooleanView(WithField: GroupField)
    {
        BoolSwitch.isEnabled = !WithField.DisableControl
        BoolDescription.layer.cornerRadius = 4.0
        BoolDescription.clipsToBounds = true
        
        BoolTitle.text = WithField.Title
        BoolDescription.text = WithField.Description
        BoolControlTitle.text = WithField.ControlTitle
        BoolSwitch.isOn = WithField.Starting as! Bool
        CurrentField = WithField
        ShowViewType(WithField.FieldType)
        BoolViewDirty.alpha = 0.0
    }
}
