//
//  +Action.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/23/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension RawThemeViewerCode
{
    /// Populate the action view.
    /// - Parameter WithField: The group field to populate the view with.
    public func PopulateActionView(WithField: GroupField)
    {
        ActionDescription.layer.cornerRadius = 4.0
        ActionDescription.clipsToBounds = true
        ActionResults.layer.cornerRadius = 4.0
        ActionResults.clipsToBounds = true
        ActionResults.alpha = 0.0
        ActionView.layer.borderColor = WithField.ActionBorderColor.cgColor
        ActionView.layer.borderWidth = 3.0
        ActionView.layer.cornerRadius = 5.0
        
        ActionTitle.text = WithField.Title
        ActionDescription.text = WithField.Description
        ActionButton.setTitle(WithField.ControlTitle, for: UIControl.State.normal)
        ActionButton.titleLabel?.textColor = WithField.ActionButtonTextColor
        ActionButton.tintColor = WithField.ActionButtonTextColor
        ActionButton.backgroundColor = WithField.ActionButtonBackgroundColor
        CurrentField = WithField
        ShowViewType(WithField.FieldType) 
    }
}
