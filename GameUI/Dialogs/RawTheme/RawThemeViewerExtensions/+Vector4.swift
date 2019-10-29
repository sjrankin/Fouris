//
//  +Vector4.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension RawThemeViewerCode
{
    /// Populate the vector 4 view.
    /// - Parameter WithField: The group field to populate the view with.
    public func PopulateVector4View(WithField: GroupField)
    {
        Vector4XBox.isEnabled = !WithField.DisableControl
        Vector4YBox.isEnabled = !WithField.DisableControl
        Vector4ZBox.isEnabled = !WithField.DisableControl
        Vector4WBox.isEnabled = !WithField.DisableControl
        Vector4Description.layer.cornerRadius = 4.0
        Vector4Description.clipsToBounds = true
        
        Vector4Title.text = WithField.Title
        Vector4Description.text = WithField.Description
        if let V4 = WithField.Starting as? SCNVector4
        {
            Vector4XBox.text = "\(V4.x)"
            Vector4YBox.text = "\(V4.y)"
            Vector4ZBox.text = "\(V4.z)"
            Vector4WBox.text = "\(V4.w)"
        }
        else
        {
            Vector4XBox.text = "0.0"
            Vector4YBox.text = "0.0"
            Vector4ZBox.text = "0.0"
            Vector4WBox.text = "0.0"
        }
        CurrentField = WithField
        ShowViewType(WithField.FieldType)
        Vector4ViewDirty.alpha = 0.0
    }
}
