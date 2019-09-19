//
//  +Vector3.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension RawThemeViewerCode2
{
    func PopulateVector3View(WithField: GroupField2)
    {
        Vector3Description.layer.cornerRadius = 4.0
        Vector3Description.clipsToBounds = true
    
        Vector3Title.text = WithField.Title
        Vector3Description.text = WithField.Description
        if let V3 = WithField.Starting as? SCNVector3
        {
            Vector3XBox.text = "\(V3.x)"
            Vector3YBox.text = "\(V3.y)"
            Vector3ZBox.text = "\(V3.z)"
        }
        else
        {
            Vector3XBox.text = "0.0"
            Vector3YBox.text = "0.0"
            Vector3ZBox.text = "0.0"
        }
        CurrentField = WithField
        ShowViewType(WithField.FieldType)
        Vector3ViewDirty.alpha = 0.0
    }
}
