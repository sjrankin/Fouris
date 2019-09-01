//
//  RecentlyUsedColors.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages the list of most recently used colors.
class RecentlyUsedColors
{
    /// Initialize the class. Should be called only once.
    /// - Parameter WithLimit: The greated number of colors to manage.
    public static func Initialize(WithLimit: Int)
    {
        _MaxColors = WithLimit == 0 ? 20 : WithLimit
        LoadColors()
    }
    
    /// Holds the greatest number of colors to manage in the class.
    private static var _MaxColors: Int = 0
    /// Get the greatest number of colors to manage. Set via **Initialize** but should call this only at start-up.
    public static var MaxColorCount: Int
    {
        get
        {
            return _MaxColors
        }
    }
    
    /// Write the list of colors to user defaults. Called after each modification.
    private static func WriteColors()
    {
        var Final = ""
        for (Color, _) in _ColorList
        {
            let ColorValue = ColorServer.MakeHexString(From: Color) + ","
            Final = Final + ColorValue
        }
        Settings.SetMostRecentlyUsedColorList(NewValue: Final)
    }
    
    /// Loads the list of most recently used colors from user defaults. If the number of managed colors is smaller than the
    /// number of colors in user defaults, older colors will be truncated from the resultant list.
    private static func LoadColors()
    {
        let Raw = Settings.GetMostRecentlyUsedColorList()
        if Raw.isEmpty
        {
            _ColorList.removeAll()
            return
        }
        let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
        for Part in Parts
        {
            if _ColorList.count >= _MaxColors
            {
                break
            }
            let TheColor = UIColor(HexString: String(Part))!
            var ColorName = PredefinedColors.NameFrom(Color: TheColor)
            if ColorName == nil
            {
                ColorName = ""
            }
            Add(NewColor: TheColor, NewColorName: ColorName!)
        }
    }
    
    /// Holds the list of colors.
    private static var _ColorList: [(UIColor, String)] = [(UIColor, String)]()
    /// Get the list of most recently used colors. Each entry has a color and a color name. The color name is assigned at run-time
    /// based on the contents of the predefined colors table. If the names in the predefined colors table change between instantiations,
    /// it is possible the name of the color may also change here.
    public static var ColorList: [(UIColor, String)]
    {
        get
        {
            return _ColorList
        }
    }
    
    /// Clears all content of the most recently used color list.
    public static func Clear()
    {
        _ColorList.removeAll()
        WriteColors()
    }
    
    /// Add a new color to the most recently used color list. If necessary, older colors will be deleted to make room for the
    /// new color. If the list already contains the same color being added, the color will be moved to the top of the list.
    /// - Note: Call this function to move an existing color to the top of the list.
    /// - Parameter NewColor: The new color to add.
    /// - Parameter NewColorName: The name of the color.
    public static func Add(NewColor: UIColor, NewColorName: String)
    {
        if let Index = ColorIndex(ForColor: NewColor)
        {
            let ItemColor = _ColorList[Index].0
            let ItemName = _ColorList[Index].1
            _ColorList.remove(at: Index)
            _ColorList.insert((ItemColor, ItemName), at: 0)
            WriteColors()
            return
        }
        while _ColorList.count >= _MaxColors
        {
            _ColorList.removeLast()
        }
        _ColorList.append((NewColor, NewColorName))
        WriteColors()
    }
    
    /// Remove an existing color from the most recently used color list. If the color does not exist, no action is taken.
    /// - Parameter OldColor: The color to remove.
    public static func Remove(OldColor: UIColor)
    {
        if let Index = ColorIndex(ForColor: OldColor)
        {
            _ColorList.remove(at: Index)
            WriteColors()
        }
    }
    
    /// Returns the index of the specified color in the most recently used color list.
    /// - Parameter ForColor: The color whose index into the most recently used color list will be returned.
    /// - Returns: The index into the most recently used color list for the passed color. If not found, nil will be returned.
    public static func ColorIndex(ForColor: UIColor) -> Int?
    {
        return ColorList.firstIndex(where: {$0.0 == ForColor})
    }
    
    /// Determines if the passed color is in the most recently used color list.
    /// - Parameter Color: The color to determine existence in the most recently used color list.
    /// - Returns: True if the color is in the list, false if not.
    public static func ColorExists(_ Color: UIColor) -> Bool
    {
        for (SomeColor, _) in ColorList
        {
            if SomeColor == Color
            {
                return true
            }
        }
        return false
    }
}
