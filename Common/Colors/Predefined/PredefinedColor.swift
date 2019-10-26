//
//  PredefinedColor.swift
//  Fouris
//  Adapted from BumpCamera and Visualizer Clock.
//
//  Created by Stuart Rankin on 8/31/19.
//  Copyright © 2018, 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Encapsulates a pre-defined color.
class PredefinedColor
{
    /// Initializer.
    /// - Parameters:
    ///   - Name: Name of the color.
    ///   - PaletteName: Name of the palette.
    ///   - ColorValue: The color.
    init(_ Name: String, _ PaletteName: String, _ ColorValue: UIColor)
    {
        _ID = UUID()
        _ColorName = Name
        _Color = ColorValue
        _Palette = PaletteName
        let (H, S, B) = Utility.GetHSB(SourceColor: ColorValue)
        _Hue = Double(H)
        _Saturation = Double(S)
        _Brightness = Double(B)
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - Name: Name of the color.
    ///   - AltName: Alternative name.
    ///   - PaletteName: Name of the palette.
    ///   - ColorValue: The color.
    init(_ Name: String, _ AltName: String, _ PaletteName: String, _ ColorValue: UIColor)
    {
        _ID = UUID()
        _ColorName = Name
        _AlternativeName = AltName
        _Color = ColorValue
        _Palette = PaletteName
        let (H, S, B) = Utility.GetHSB(SourceColor: ColorValue)
        _Hue = Double(H)
        _Saturation = Double(S)
        _Brightness = Double(B)
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - Name: Name of the color.
    ///   - PaletteName: Name of the palette.
    ///   - ColorValue: String representation of the color (in #rrggbb format).
    init(_ Name: String, _ PaletteName: String, _ ColorValue: String)
    {
        _ID = UUID()
        _ColorName = Name
        _Color = Utility.FromHex2(HexString: ColorValue)!
        _Palette = PaletteName
        let (H, S, B) = Utility.GetHSB(SourceColor: _Color)
        _Hue = Double(H)
        _Saturation = Double(S)
        _Brightness = Double(B)
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - Name: Name of the color.
    ///   - AltName: Alternative name.
    ///   - PaletteName: Name of the palette.
    ///   - ColorValue: String representation of the color (in #rrggbb format).
    init(_ Name: String, _ AltName: String, _ PaletteName: String, _ ColorValue: String)
    {
        _ID = UUID()
        _ColorName = Name
        _AlternativeName = AltName
        _Color = Utility.FromHex2(HexString: ColorValue)! 
        _Palette = PaletteName
        let (H, S, B) = Utility.GetHSB(SourceColor: _Color)
        _Hue = Double(H)
        _Saturation = Double(S)
        _Brightness = Double(B)
    }
    
    /// Gets the value to sort the color by.
    /// - Parameter Order: The order by which to sort.
    /// - Returns: String value of the value to sort the color by.
    public func SortKey(_ Order: ColorOrders) -> String 
    {
        switch Order
        {
            case .Name:
                return ColorName
            
            case .Hue:
                return String(Hue * 360.0)
            
            case .Brightness:
                return String(Brightness)
            
            case .Palette:
                return Palette
            
            default:
                return ColorName
        }
    }
    
    /// Contains the ID of the color.
    private var _ID: UUID = UUID()
    /// Get the ID of the color. IDs are generated at run-time.
    public var ID: UUID
    {
        get
        {
            return _ID
        }
    }
    
    /// Determines if another color is the same as this color. Colors are compared in RGB colorspace and must
    /// be exact.
    /// - Parameter OtherColor: The color to compare to this color.
    /// - Returns: True if the other color is the same as this color, false if not.
    public func SameColor(_ OtherColor: UIColor) -> Bool
    {
        let (ThisR, ThisG, ThisB) = Utility.GetRGB(Color)
        let (ThatR, ThatG, ThatB) = Utility.GetRGB(OtherColor)
        return ThisR == ThatR && ThisG == ThatG && ThisB == ThatB
    }
    
    /// Returns the first letter of the name of the color.
    public var FirstLetter: String
    {
        get
        {
            if ColorName.isEmpty
            {
                return ""
            }
            return String(ColorName.first!)
        }
    }
    
    /// Holds the name of the color.
    private var _ColorName: String = ""
    /// Get or set the name of the color.
    public var ColorName: String
    {
        get
        {
            return _ColorName
        }
        set
        {
            _ColorName = newValue
        }
    }
    
    /// Holds the alternative color name.
    private var _AlternativeName: String = ""
    /// Get or set the alternative name of the color.
    public var AlternativeName: String
    {
        get
        {
            return _AlternativeName
        }
        set
        {
            _AlternativeName = newValue
        }
    }
    
    /// Holds the actual color.
    private var _Color: UIColor = UIColor.clear
    /// Get or set the color value.
    public var Color: UIColor
    {
        get
        {
            return _Color
        }
        set
        {
            _Color = newValue
            let (H, S, B) = Utility.GetHSB(SourceColor: _Color)
            _Hue = Double(H)
            _Saturation = Double(S)
            _Brightness = Double(B)
        }
    }
    
    /// Holds the hue of the color.
    private var _Hue: Double = 0.0
    /// Get the hue of the color.
    public var Hue: Double
    {
        get
        {
            return _Hue
        }
    }
    
    /// Holds the saturation of the color.
    private var _Saturation: Double = 0.0
    /// Get the saturation of the color.
    public var Saturation: Double
    {
        get
        {
            return _Saturation
        }
    }
    
    /// Holds the brightness of the color.
    private var _Brightness: Double = 0.0
    /// Get the brightness of the color.
    public var Brightness: Double
    {
        get
        {
            return _Brightness
        }
    }
    
    /// Holds the palette name of the color.
    private var _Palette: String = ""
    /// Get or set the name of the palette for the color.
    public var Palette: String
    {
        get
        {
            return _Palette
        }
        set
        {
            _Palette = newValue
        }
    }
    
    /// Which name was used for sorting if sorted by names.
    /// - PrimaryName: Used the primary name.
    /// - AlternativeName: Used the alternative name.
    enum SortedNames
    {
        case PrimaryName
        case AlternativeName
    }
    
    /// Holds the type of name used to sort the color (if sorting by names).
    private var _SortedName: SortedNames = .PrimaryName
    /// Get or set the name used to sort the color (when sorting by names).
    public var SortedName: SortedNames
    {
        get
        {
            return _SortedName
        }
        set
        {
            _SortedName = newValue
        }
    }
}
