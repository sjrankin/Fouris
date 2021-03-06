//
//  +Int.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension RawThemeViewerCode
{
    /// Populate the Int editing view.
    /// - Parameter WithField: The group field to populate the view with.
    public func PopulateIntView(WithField: GroupField)
    {
        IntTextBox.isEnabled = !WithField.DisableControl
        IntDescription.layer.cornerRadius = 4.0
        IntDescription.clipsToBounds = true
        
        IntTitle.text = WithField.Title
        IntDescription.text = WithField.Description
        IntControlTitle.text = WithField.ControlTitle
        var Starting = 0
        if let Raw = WithField.Starting as? Int
        {
            Starting = Raw
        }
        IntTextBox.text = "\(Starting)"
        CurrentField = WithField
        ShowViewType(WithField.FieldType)
        IntViewDirty.alpha = 0.0
    }
}
