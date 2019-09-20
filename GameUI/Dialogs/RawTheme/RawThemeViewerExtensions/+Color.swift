//
//  +Color.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension RawThemeViewerCode
{
    func PopulateColorView(WithField: GroupField)
    {
        ColorSwatch.isUserInteractionEnabled = !WithField.DisableControl
        ColorDescription.layer.cornerRadius = 4.0
        ColorDescription.clipsToBounds = true
        
        let StartColor = WithField.Starting as? UIColor
        let ColorNames = PredefinedColors.NamesFrom(FindColor: StartColor!)
        let ColorName: String? = ColorNames.count > 0 ? ColorNames[0] : nil
        if let FinalColorName = ColorName
        {
            ColorControlTitle.text = FinalColorName
        }
        else
        {
            ColorControlTitle.text = ""
        }
        ColorTitle.text = WithField.Title
        ColorDescription.text = WithField.Description
        ColorSwatch.TopColor = StartColor!
        
        CurrentField = WithField
        ShowViewType(WithField.FieldType)
        ColorViewDirty.alpha = 0.0
    }
}
