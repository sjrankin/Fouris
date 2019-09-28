//
//  UIColorExtensions.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/30/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import simd

extension UIColor
{
    /// Convenience initializer that takes doubles as HSB channel values.
    ///
    /// - Parameters:
    ///   - hue: Hue channel value. Clamped to 0.0 to 1.0.
    ///   - saturation: Saturation channel value. Clamped to 0.0 to 1.0.
    ///   - brightness: Brightness channel value. Clamped to 0.0 to 1.0.
    ///   - alpha: Alpha channel value. Clamped to 0.0 to 1.0.
    convenience init(hue: Double, saturation: Double, brightness: Double, alpha: Double)
    {
        self.init(hue: CGFloat(hue.Clamp(0.0, 1.0)),
                  saturation: CGFloat(saturation.Clamp(0.0, 1.0)),
                  brightness: CGFloat(brightness.Clamp(0.0, 1.0)),
                  alpha: CGFloat(alpha.Clamp(0.0, 1.0)))
    }
    
    /// Convenience initializer that takes doubles as HSB channel values. Alpha is set to 1.0.
    ///
    /// - Parameters:
    ///   - hue: Hue channel value. Clamped to 0.0 to 1.0.
    ///   - saturation: Saturation channel value. Clamped to 0.0 to 1.0.
    ///   - brightness: Brightness channel value. Clamped to 0.0 to 1.0.
    convenience init(hue: Double, saturation: Double, brightness: Double)
    {
        self.init(hue: CGFloat(hue.Clamp(0.0, 1.0)),
                  saturation: CGFloat(saturation.Clamp(0.0, 1.0)),
                  brightness: CGFloat(brightness.Clamp(0.0, 1.0)),
                  alpha: 1.0)
    }
    
    /// Create a UIColor with the unnormalized RGB values. Alpha is set to 1.0.
    ///
    /// - Parameters:
    ///   - red: Red value (between 0 and 255).
    ///   - green: Green value (between 0 and 255).
    ///   - blue: Blue value (between 0 and 255).
    convenience init(red: Int, green: Int, blue: Int)
    {
        self.init(red: CGFloat(Utility.ForceToValidRange(red, ValidRange: 0...255)),
                  green: CGFloat(Utility.ForceToValidRange(green, ValidRange: 0...255)),
                  blue: CGFloat(Utility.ForceToValidRange(blue, ValidRange: 0...255)),
                  alpha: 1.0)
    }
    
    /// Create a UIColor with normalized double values. Alpha is set to 1.0.
    ///
    /// - Parameters:
    ///   - red: Red channel value clamped to 0.0 to 1.0.
    ///   - green: Green channel value clamped to 0.0 to 1.0.
    ///   - blue: Blue channel value clamped to 0.0 to 1.0.
    ///   - alpha: Alpha channel value clampled to 0.0 to 1.0.
    convenience init(red: Double, green: Double, blue: Double, alpha: Double)
    {
        self.init(red: CGFloat(red.Clamp(0.0, 1.0)),
                  green: CGFloat(green.Clamp(0.0, 1.0)),
                  blue: CGFloat(blue.Clamp(0.0, 1.0)),
                  alpha: CGFloat(alpha.Clamp(0.0, 1.0)))
    }
    
    /// Create a UIColor with normalized double values. Alpha is set to 1.0.
    ///
    /// - Parameters:
    ///   - red: Red channel value clamped to 0.0 to 1.0.
    ///   - green: Green channel value clamped to 0.0 to 1.0.
    ///   - blue: Blue channel value clamped to 0.0 to 1.0.
    convenience init(red: Double, green: Double, blue: Double)
    {
        self.init(red: CGFloat(red.Clamp(0.0, 1.0)),
                  green: CGFloat(green.Clamp(0.0, 1.0)),
                  blue: CGFloat(blue.Clamp(0.0, 1.0)),
                  alpha: 1.0)
    }
    
    /// List of known color names and their associated values.
    private static let KnownColors: [String: UIColor] =
        [
            "black": UIColor.black,
            "white": UIColor.white,
            "red": UIColor.red,
            "green": UIColor.green,
            "blue": UIColor.blue,
            "cyan": UIColor.cyan,
            "magenta": UIColor.magenta,
            "yellow": UIColor.yellow,
            "purple": UIColor.purple,
            "orange": UIColor.orange,
            "brown": UIColor.brown,
            "gray": UIColor.gray,
            "darkgray": UIColor.darkGray,
            "lightgray": UIColor.lightGray,
    ]
    
    /// Search the known colors list for the passed color name. Returns the color value if found.
    ///
    /// - Parameter Name: The name to search in the known colors list. Internally, the name is
    ///                   lowercased to match the names in the known colors list.
    /// - Returns: The value of the passed name on success, nil if not found.
    public static func GetKnownColor(Name: String) -> UIColor?
    {
        return KnownColors[Name.lowercased()]
    }
    
    /// Return a UIColor with the passed hex string.
    ///
    /// - Note:
    ///   The format of the hex string is: `rrggbb` or `rrggbbaa` with optional prefix.
    ///
    /// - Parameter Value: The hex value in a string. The value may be prefixed by `#` `0x` (`0X` is also OK but
    ///                    essentially the same as `0x` as the case of the input is normalized before much
    ///                    processing takes place) but values without prefixes are acceptable. Alpha channels
    ///                    are also permissible. Channel values that somehow evaluated to out of range are
    ///                    clamped. Invalid `HexString` values result in a failure (nil returned).
    /// - Returns: A UIColor with the color of the passed hex string on success, nil on failure.
    static func FromHex(_ Value: String) -> UIColor?
    {
        if Value.count < 1
        {
            return nil
        }
        var Working = Value.trimmingCharacters(in:. whitespacesAndNewlines)
        Working = Working.lowercased()
        Working = Working.replacingOccurrences(of: "#", with: "")
        Working = Working.replacingOccurrences(of: "0x", with: "")
        Working = Working.replacingOccurrences(of: "0X", with: "")
        if let IsKnown = GetKnownColor(Name: Working)
        {
            return IsKnown
        }
        if Working.count == 6 || Working.count == 8
        {
        }
        else
        {
            print("Unable to convert \(Value) to a color.")
            return nil
        }
        
        if Working.count == 8
        {
            let LowA = Working.index(Working.startIndex, offsetBy: 0)
            let HighA = Working.index(Working.startIndex, offsetBy: 1)
            let a = Working[LowA...HighA]
            let Alpha = Int(String(describing: a), radix: 16)
            
            let LowR = Working.index(Working.startIndex, offsetBy: 2)
            let HighR = Working.index(Working.startIndex, offsetBy: 3)
            let r = Working[LowR...HighR]
            let Red = Int(String(describing: r), radix: 16)
            
            let LowG = Working.index(Working.startIndex, offsetBy: 4)
            let HighG = Working.index(Working.startIndex, offsetBy: 5)
            let g = Working[LowG...HighG]
            let Green = Int(String(describing: g), radix: 16)
            
            let LowB = Working.index(Working.startIndex, offsetBy: 6)
            let HighB = Working.index(Working.startIndex, offsetBy: 7)
            let b = Working[LowB...HighB]
            let Blue = Int(String(describing: b), radix: 16)
            
            let FAlpha = CGFloat(Alpha!) / 100.0
            let FRed = CGFloat(Red!) / 255.0
            let FGreen = CGFloat(Green!) / 255.0
            let FBlue = CGFloat(Blue!) / 255.0
            return UIColor(red: FRed, green: FGreen, blue: FBlue, alpha: FAlpha)
        }
        else
        {
            let LowR = Working.index(Working.startIndex, offsetBy: 0)
            let HighR = Working.index(Working.startIndex, offsetBy: 1)
            let r = Working[LowR...HighR]
            let Red = Int(String(describing: r), radix: 16)
            
            let LowG = Working.index(Working.startIndex, offsetBy: 2)
            let HighG = Working.index(Working.startIndex, offsetBy: 3)
            let g = Working[LowG...HighG]
            let Green = Int(String(describing: g), radix: 16)
            
            let LowB = Working.index(Working.startIndex, offsetBy: 4)
            let HighB = Working.index(Working.startIndex, offsetBy: 5)
            let b = Working[LowB...HighB]
            let Blue = Int(String(describing: b), radix: 16)
            
            let FRed = CGFloat(Red!) / 255.0
            let FGreen = CGFloat(Green!) / 255.0
            let FBlue = CGFloat(Blue!) / 255.0
            
            return UIColor(red: FRed, green: FGreen, blue: FBlue, alpha: CGFloat(1.0))
        }
    }
    
    /// Convert an instance of a UIColor to a SIMD float4 structure.
    ///
    /// - Returns: SIMD float4 equivalent of the instance color.
    func ToFloat4() -> simd_float4
    {
        var FVals = [Float]()
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var Alpha: CGFloat = 1.0
        self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        FVals.append(Float(Red))
        FVals.append(Float(Green))
        FVals.append(Float(Blue))
        FVals.append(Float(Alpha))
        let Result = simd_float4(FVals)
        return Result
    }
    
    /// Convert the instance color to a CIColor.
    ///
    /// - Returns: CIColor equivalent of the UIColor instance.
    func ToCIColor() -> CIColor
    {
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        let Result = CIColor(red: Red, green: Green, blue: Blue, alpha: Alpha)
        return Result
    }
    
    /// Returns the red value as an integer from 0 to 255.
    var dn_r: Int
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return Int(Red * 255.0)
        }
    }
    
    /// Returns the green value as an integer from 0 to 255.
    var dn_g: Int
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return Int(Green * 255.0)
        }
    }
    
    /// Returns the blue value as an integer from 0 to 255.
    var dn_b: Int
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return Int(Blue * 255.0)
        }
    }
    
    /// Returns the alpha value as an integer from 0 to 255.
    var dn_a: Int
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return Int(Alpha * 255.0)
        }
    }
    
    /// Returns the normalized red value.
    var r: CGFloat
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return Red
        }
    }
    
    /// Returns the normalized green value.
    var g: CGFloat
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return Green
        }
    }
    
    /// Returns the normalized blue value.
    var b: CGFloat
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return Blue
        }
    }
    
    /// Returns the normalized alpha value.
    var a: CGFloat
    {
        get
        {
            var Red: CGFloat = 0.0
            var Green: CGFloat = 0.0
            var Blue: CGFloat = 0.0
            var Alpha: CGFloat = 0.0
            self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
            return Alpha
        }
    }
    
    /// Returns the normalized hue value.
    var Hue: CGFloat
    {
        get
        {
            var H: CGFloat = 0.0
            var S: CGFloat = 0.0
            var B: CGFloat = 0.0
            var A: CGFloat = 0.0
            self.getHue(&H, saturation: &S, brightness: &B, alpha: &A)
            return H
        }
    }
    
    /// Returns the normalized saturation value.
    var Saturation: CGFloat
    {
        get
        {
            var H: CGFloat = 0.0
            var S: CGFloat = 0.0
            var B: CGFloat = 0.0
            var A: CGFloat = 0.0
            self.getHue(&H, saturation: &S, brightness: &B, alpha: &A)
            return S
        }
    }
    
    /// Returns the normalized brightness value.
    var Brightness: CGFloat
    {
        get
        {
            var H: CGFloat = 0.0
            var S: CGFloat = 0.0
            var B: CGFloat = 0.0
            var A: CGFloat = 0.0
            self.getHue(&H, saturation: &S, brightness: &B, alpha: &A)
            return B
        }
    }
    
    /// Create a new color with the same hue and saturation as the passed color, and the brightness of
    /// the passed `ToBrightness` parameter value.
    ///
    /// - Parameters:
    ///   - Source: Source color.
    ///   - ToBrightness: Brightness level to apply to the source color.
    /// - Returns: New color with the supplied brightness.
    public static func SetBrightness(_ Source: UIColor, _ ToBrightness: CGFloat) -> UIColor
    {
        let Hue = Source.Hue
        let Sat = Source.Saturation
        return UIColor(hue: Hue, saturation: Sat, brightness: ToBrightness, alpha: 1.0)
    }
    
    /// Convert a SIMD float4 structure into a UIColor.
    ///
    /// - Parameter Float4: The SIMD float4 structure whose values will be converted into a UIColor.
    /// - Returns: UIColor equivalent of the passed SIMD float4 set of values.
    static func From(Float4: simd_float4) -> UIColor
    {
        let NewColor = UIColor(red: CGFloat(Float4.w), green: CGFloat(Float4.x),
                               blue: CGFloat(Float4.y), alpha: CGFloat(Float4.z))
        return NewColor
    }
    
    /// Determines the instance color is the same as the passed color. Both the instance color and the passed
    /// color channels are converted to integers before being compared.
    ///
    /// - Parameter As: The color to compare to the instance color.
    /// - Returns: True if the colors are the same, false if not.
    func IsSame(As: UIColor) -> Bool
    {
        let red = Int(As.r * 255.0)
        let green = Int(As.g * 255.0)
        let blue = Int(As.b * 255.0)
        return self.dn_r == red && self.dn_g == green && self.dn_b == blue
    }
    
    /// Determines the instance color is the same as the passed color. Both the instance color and the passed
    /// color channels are converted to integers before being compared.
    ///
    /// - Parameter HexValue: The value of the color to compare to the instance color.
    /// - Returns: True if the colors are the same, false if not.
    func IsSame(HexValue: Int) -> Bool
    {
        let red = (HexValue >> 16) & 0xff
        let green = (HexValue >> 8) & 0xff
        let blue = (HexValue) & 0xff
        return self.dn_r == red && self.dn_g == green && self.dn_b == blue
    }
    
    /// Return the RGBA channels of the color.
    ///
    /// - Returns: Tuple of channel values in R, G, B, and A order.
    func AsRGBA() -> (CGFloat, CGFloat, CGFloat, CGFloat)
    {
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var Alpha: CGFloat = 1.0
        self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        return (Red, Green, Blue, Alpha)
    }
    
    /// Return the RGB channels of the color.
    ///
    /// - Returns: Tuple of channel values in R, G, and B order.
    func AsRGB() -> (CGFloat, CGFloat, CGFloat)
    {
        let (R, G, B, _) = AsRGBA()
        return (R, G, B)
    }
    
    /// Return the HSBA channels of the color.
    ///
    /// - Returns: Tuple of channel values in H, S, B, and A order.
    func AsHSBA() -> (CGFloat, CGFloat, CGFloat, CGFloat)
    {
        var Hue: CGFloat = 0.0
        var Saturation: CGFloat = 0.0
        var Brightness: CGFloat = 0.0
        var Alpha: CGFloat = 1.0
        self.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
        return (Hue, Saturation, Brightness, Alpha)
    }
    
    /// Change the alpha component of the color to the passed value.
    ///
    /// - Parameter To: The new alpha value. Internally clamped to 0.0 to 1.0
    /// - Returns: New color with the changed alpha.
    func ChangeAlpha(To: CGFloat) -> UIColor
    {
        let (Red, Green, Blue, _) = self.AsRGBA()
        var Final = To
        if Final < 0.0
        {
            Final = 0.0
        }
        if Final > 1.0
        {
            Final = 1.0
        }
        return UIColor(red: Red, green: Green, blue: Blue, alpha: Final)
    }
    
    /// Return the alpha value of the instance color.
    ///
    /// - Returns: Alpha value of the color.
    func Alpha() -> CGFloat
    {
        let (_, _, _, A) = AsRGBA()
        return A
    }
    
    /// Determines whether the passed color is equal to the instance color. Alpha is not used for comparison. Channels
    /// are compared individually.
    ///
    /// - Parameter Other: The other color to compare to this one.
    /// - Returns: True if the colors are equal (not counting the alpha channel), false if not.
    func Equals(_ Other: UIColor) -> Bool
    {
        let (sR, sG, sB, _) = self.AsRGBA()
        let (oR, oG, oB, _) = Other.AsRGBA()
        return sR == oR && sG == oG && sB == oB
    }
    
    /// Determines if the instance color is equal to the passed color.
    ///
    /// - Parameters:
    ///   - R: Other color red value.
    ///   - G: Other color green value.
    ///   - B: Other color blue value.
    /// - Returns: True if this color is the same as the passed color, false otherwise.
    func Equals(_ R: CGFloat, _ G: CGFloat, _ B: CGFloat) -> Bool
    {
        let (sR, sG, sB, _) = self.AsRGBA()
        return sR == R && sG == G && sB == B
    }
    
    /// Determines if the instance color is equal to the passed color.
    ///
    /// - Parameter Other: Tuple of (red, green, blue) values to compare against this color.
    /// - Returns: True if this color is the same as the passed color, false otherwise.
    func Equals(_ Other: (CGFloat, CGFloat, CGFloat)) -> Bool
    {
        return Equals(Other.0, Other.1, Other.2)
    }
    
    /// Describes the algorithm to use to determine contrast.
    ///
    /// - YIQ: Convert the source color to YIQ.
    /// - FiftyPercent: Calculate if the value of the color is > 50% of total possible value.
    /// - Brightness: Use the brightness channel directly from the color.
    enum ConstrastAlgorithms
    {
        case YIQ
        case FiftyPercent
        case Brightness
    }
    
    /// Determines whether white or black has the best contrast to the passed color and type
    /// of algorithm.
    ///
    /// - Note:
    ///    - [Calculating color contrast](https://24ways.org/2010/calculating-color-contrast/)
    ///
    /// - Parameters:
    ///   - Method: Determines how constrast is calculated.
    /// - Returns: White or black, depending on which has the greatest constrast to the passed color.
    func HighestContrastTo(Method: ConstrastAlgorithms) -> UIColor
    {
        switch Method
        {
            case .YIQ:
                var Red: CGFloat = 0.0
                var Green: CGFloat = 0.0
                var Blue: CGFloat = 0.0
                var Alpha: CGFloat = 0.0
                self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
                let YIQ = ((Red * 0.299) + (Green * 0.587) + (Blue * 0.114))
                if YIQ < 128
                {
                    return UIColor.white
                }
                else
                {
                    return UIColor.black
            }
            
            case .FiftyPercent:
                var Red: CGFloat = 0.0
                var Green: CGFloat = 0.0
                var Blue: CGFloat = 0.0
                var Alpha: CGFloat = 0.0
                self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
                let BigNum = (Red * 255.0) + (Green * 255.0) + (Blue * 255.0)
                if Int(BigNum) < 0xffffff / 2
                {
                    return UIColor.white
                }
                else
                {
                    return UIColor.black
            }
            
            case .Brightness:
                var Hue: CGFloat = 0.0
                var Saturation: CGFloat = 0.0
                var Brightness: CGFloat = 0.0
                var Alpha: CGFloat = 0.0
                self.getHue(&Hue, saturation: &Saturation, brightness: &Brightness, alpha: &Alpha)
                if Brightness < 0.5
                {
                    return UIColor.white
                }
                else
                {
                    return UIColor.black
            }
        }
    }
    
    /// Invert the RGB (and possibly A) channels of the instance color and return a new color
    /// based on the inverted values.
    ///
    /// - Parameter IncludeAlpha: If true, alpha is inverted as well.
    /// - Returns: New UIColor with inverted color values.
    func Inverted(_ IncludeAlpha: Bool = false) -> UIColor
    {
        let r = 1.0 - self.r
        let g = 1.0 - self.g
        let b = 1.0 - self.b
        let a = IncludeAlpha ? 1.0 - self.a : self.a
        return UIColor(red: r, green: g, blue: b, alpha: a)
    }
    
    /// Return the color symbol for the instance color.
    func Symbol() -> Colors
    {
        if self.Alpha() == 0.0
        {
            return .Clear
        }
        for (Color, Value) in UIColor.ColorValues
        {
            if self.Equals(Value)
            {
                return Color
            }
        }
        return .Other
    }
    
    /// Table of color symbols to color values (excluding alpha).
    static let ColorValues: [Colors: (CGFloat, CGFloat, CGFloat)] =
        [
            .Orange: (1.0, 0.5, 0.0),
            .Black: (0.0, 0.0, 0.0),
            .Blue: (0.0, 0.0, 1.0),
            .Brown: (0.6, 0.4, 0.2),
            .Cyan: (0.0, 1.0, 1.0),
            .DarkGray: (0.33, 0.33, 0.33),
            .Gray: (0.5, 0.5, 0.5),
            .Green: (0.0, 1.0, 0.0),
            .LightGray: (0.66, 0.66, 0.66),
            .Magenta: (1.0, 0.0, 1.0),
            .Purple: (0.5, 0.0, 0.5),
            .Red: (1.0, 0.0, 0.0),
            .White: (1.0, 1.0, 1.0),
            .Yellow: (1.0, 1.0, 0.0)
    ]
    
    /// Color symbols.
    enum Colors: CaseIterable
    {
        case Clear
        case Brown
        case Black
        case White
        case Red
        case Green
        case Blue
        case Cyan
        case Magenta
        case Yellow
        case Gray
        case DarkGray
        case LightGray
        case Orange
        case Purple
        case Other
    }
}

