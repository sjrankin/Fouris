//
//  +Gradient.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension RawThemeViewerCode2
{
    func PopulateGradientView(WithField: GroupField2)
    {
        GradientDescription.layer.cornerRadius = 4.0
        GradientDescription.clipsToBounds = true
        
        GradientTitle.text = WithField.Title
        GradientDescription.text = WithField.Description
        
        var GradientDescription = WithField.State as? String
        if GradientDescription == nil
        {
            GradientDescription = "(White)@(0.0),(Black)@(1.0)"
        }
        GradientViewer.GradientDescriptor = GradientDescription!
        
        CurrentField = WithField
        ShowViewType(WithField.FieldType)
        IntViewDirty.alpha = 0.0
    }
}
