//
//  PredefinedColorGroup.swift
//  Fouris
//  Adapted from BumpCamera and Visualizer Clock.
//
//  Created by Stuart Rankin on 8/31/19.
//  Copyright © 2018, 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Encapsulates a group of pre-defined colors.
class PredefinedColorGroup
{
    /// Holds the name of the group.
    private var _GroupName: String = ""
    /// Get or set the name of the group.
    public var GroupName: String
    {
        get
        {
            return _GroupName
        }
        set
        {
            _GroupName = newValue
        }
    }
    
    /// Holds the group sub-title.
    private var _GroupSubTitle: String = ""
    /// Get or set the sub-title of the group.
    public var GroupSubTitle: String
    {
        get
        {
            return _GroupSubTitle
        }
        set
        {
            _GroupSubTitle = newValue
        }
    }
    
    /// Holds the value by which to sort groups.
    private var _SortValue: Double = 0.0
    /// Get or set the value to use to sort groups.
    public var SortValue: Double
    {
        get
        {
            return _SortValue
        }
        set
        {
            _SortValue = newValue
        }
    }
    
    /// Holds the current ordered by value.
    private var _OrderedBy: PredefinedColors.ColorOrders = .Name
    /// Get or set the ordered by value. This is purely for storage and convenience - setting this
    /// property causes no sorting to be done.
    public var OrderedBy: PredefinedColors.ColorOrders
    {
        get
        {
            return _OrderedBy
        }
        set
        {
            _OrderedBy = newValue
        }
    }
    
    /// Holds the colors in the group.
    private var _GroupColors = [PredefinedColor]()
    /// Get or set the colors in the predefined color group.
    public var GroupColors: [PredefinedColor]
    {
        get
        {
            return _GroupColors
        }
        set
        {
            _GroupColors = newValue
        }
    }
    
    /// Get the number of colors in the predefined color group.
    public var ColorCount: Int
    {
        get
        {
            return _GroupColors.count
        }
    }
}
