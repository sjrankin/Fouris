//
//  +Double.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension RawThemeViewerCode
{
    /// Populate the double editing view.
    /// - Parameter WithField: The group field to populate the view with.
    public func PopulateDoubleView(WithField: GroupField)
    {
        DoubleTextBox.isEnabled = !WithField.DisableControl
        DoubleDescription.layer.cornerRadius = 4.0
        DoubleDescription.clipsToBounds = true
        
        DoubleTitle.text = WithField.Title
        DoubleDescription.text = WithField.Description
        DoubleControlTitle.text = WithField.ControlTitle
        var Starting: Double = 0.0
        if let Raw = WithField.Starting as? Double
        {
            Starting = Raw
        }
        DoubleTextBox.text = "\(Starting)"
        CurrentField = WithField
        ShowViewType(WithField.FieldType)
        DoubleViewDirty.alpha = 0.0
    }
}
