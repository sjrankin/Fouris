//
//  +StringList.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension RawThemeViewerCode
{
    /// Populate the string list editing view.
    /// - Note: The source of string lists is usually a `CaseIterable` enum backed by `Strings`.
    /// - Parameter WithField: The group field to populate the view with.
    public func PopulateStringListView(WithField: GroupField)
    {
        CurrentPickedString = nil
        WarningBox.alpha = 0.0
        WarningLabel.alpha = 0.0
        StringListPicker.isUserInteractionEnabled = !WithField.DisableControl 
        StringListPicker.layer.borderColor = UIColor.black.cgColor
        StringListPicker.layer.borderWidth = 0.5
        StringListPicker.layer.cornerRadius = 5.0
        StringListDescription.clipsToBounds = true
        StringListDescription.layer.cornerRadius = 4.0
        
        StringListTitle.text = WithField.Title
        StringListDescription.text = WithField.Description
        StringListData = WithField.StringList
        LastSelectedPickerViewItem = nil
        StringListPicker.reloadAllComponents()
        if let CurrentValue = WithField.Starting as? String
        {
            if let Index = StringListData.firstIndex(of: CurrentValue)
            {
                StringListPicker.selectRow(Index, inComponent: 0, animated: true)
            }
        }
        
        CurrentField = WithField
        ShowViewType(WithField.FieldType)
        StringListViewDirty.alpha = 0.0
    }
}
