//
//  _Bool.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension RawThemeViewerCode2
{
    func PopulateBooleanView(WithField: GroupField2)
    {
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
