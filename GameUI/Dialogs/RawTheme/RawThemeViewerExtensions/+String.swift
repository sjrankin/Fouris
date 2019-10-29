//
//  +String.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension RawThemeViewerCode
{
    /// Populate the string editing view.
    /// - Parameter WithField: The group field to populate the view with.
    public func PopulateStringView(WithField: GroupField)
    {
        StringTextBox.isEnabled = !WithField.DisableControl
        StringDescription.layer.cornerRadius = 4.0
        StringDescription.clipsToBounds = true
        
        StringTitle.text = WithField.Title
        StringDescription.text = WithField.Description
        StringTextBox.text = WithField.Starting as? String
        CurrentField = WithField
        ShowViewType(WithField.FieldType)
        StringViewDirty.alpha = 0.0
    }
}
