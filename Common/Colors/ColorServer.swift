//
//  ColorServer.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Class that serves colors as well as providing for OS-agnostic color functions.
class ColorServer
{
    /// List of color name enum values and associated string names.
    private static var ColorNameList = [(ColorNames, String)]()
    
    /// Make the list of color name enum values and associated color names.
    public static func MakeColorNameList()
    {
        for SomeEnum in ColorNames.allCases
        {
            ColorNameList.append((SomeEnum, "\(SomeEnum)"))
        }
    }
    
    /// Determines if `FromName` is in the `ColorNameList` and if so, returns the `ColorNames` enum equivalent.
    ///
    /// - Note: If the `ColorNameList` hasn't been populated, it will be done on the first call.
    ///
    /// - Parameter FromName: Name of the color to look up.
    /// - Returns: The `ColorNames` equivalent of the name on success, nil if not found.
    public static func FindColorName(_ FromName: String) -> ColorNames?
    {
        if ColorNameList.count < 1
        {
            MakeColorNameList()
        }
        for (EnumValue, EnumName) in ColorNameList
        {
            if EnumName == FromName
            {
                return EnumValue
            }
        }
        return nil
    }
    
    /// Given a color, return it's numeric value.
    /// - Parameter From: The color whose numeric value will be returned. Channels are in RRGGBB order.
    /// - Returns: Numeric value of the passed color.
    public static func MakeColorValue(From: UIColor) -> Int
    {
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var NotUsed: CGFloat = 0.0
        From.getRed(&Red, green: &Green, blue: &Blue, alpha: &NotUsed)
        let IRed = Int(Red * 255.0)
        let IGreen = Int(Green * 255.0)
        let IBlue = Int(Blue * 255.0)
        let Final: Int = (IRed << 16) | (IGreen << 8) | IBlue
        return Final
    }
    
    /// Return the color name of the passed color.
    /// - Parameter From: The color whose name will be returned.
    /// - Parameter ReturnValueIfNoName: If the color name cannot be determined, if this parameter is true, the hex
    ///             value (preceeded by "0x") of the color will be returned.
    /// - Returns: Name of the color on success. If `ReturnValueIfNoName` is true and the color cannot be found, the
    ///            hex value of the color (in string format) is returned. Otherwise, nil is returned.
    public static func MakeColorName(From: UIColor, ReturnValueIfNoName: Bool = true) -> String?
    {
        let SourceColor = MakeColorValue(From: From)
        for SomeEnum in ColorNames.allCases
        {
            if Int(SomeEnum.rawValue) == SourceColor
            {
                return "\(SomeEnum)"
            }
        }
        if ReturnValueIfNoName
        {
            let R: Int = (SourceColor & 0xff0000) >> 16
            let G: Int = (SourceColor & 0x00ff00) >> 8
            let B: Int = (SourceColor & 0x0000ff)
            return "0x" + String(format: "%02x", R) + String(format: "%02x", G) + String(format: "%02x", B)
        }
        return nil
    }
    
    /// Returns a random color.
    ///
    /// - Parameters:
    ///   - MinRed: Minimum red channel value.
    ///   - MinGreen: Minimum green channel value.
    ///   - MinBlue: Minimum blue channel value.
    /// - Returns: Random color.
    public static func RandomColor(MinRed: CGFloat = 0.65, MinGreen: CGFloat = 0.65, MinBlue: CGFloat = 0.65) -> UIColor
    {
        let (RRed, RGreen, RBlue) = RandomValues(MinRed: MinRed, MinGreen: MinGreen, MinBlue: MinBlue)
        return UIColor(red: RRed, green: RGreen, blue: RBlue, alpha: 1.0)
    }
    
    /// Return a set of three random values (between the specified minimum and 1.0).
    ///
    /// - Parameters:
    ///   - MinRed: Minimum red value.
    ///   - MinGreen: Minimum green value.
    ///   - MinBlue: Minimum blue value.
    /// - Returns: Tuple of random, normalized values.
    private static func RandomValues(MinRed: CGFloat = 0.65, MinGreen: CGFloat = 0.65, MinBlue: CGFloat = 0.65) -> (CGFloat, CGFloat, CGFloat)
    {
        let RRed = CGFloat(Double.random(in: Double(MinRed) ... 1.0))
        let RGreen = CGFloat(Double.random(in: Double(MinGreen) ... 1.0))
        let RBlue = CGFloat(Double.random(in: Double(MinBlue) ... 1.0))
        return (RRed, RGreen, RBlue)
    }
    
    /// Returns a randomly selected color name color.
    /// - Returns: Randomly selected color name from the universe of all known (by this program) colors.
    public static func RandomNamedColor() -> ColorNames
    {
        return ColorNameList.randomElement()!.0
    }
    
    /// Return a color from the passed color table enum value. Returned type if CGColor.
    ///
    /// - Parameter ColorValue: The color table enum raw value whose actual color will be returned.
    /// - Returns: Color (CGColor) based on the passed enum value.
    public static func CGColorFrom(_ ColorValue: UInt) -> CGColor
    {
        return ColorFrom(ColorValue).cgColor
    }
    
    /// Return a color from the passed color table enum value.
    ///
    /// - Parameter ColorValue: The color table enum raw value whose actual color will be returned.
    /// - Returns: Color based on the passed enum value.
    public static func ColorFrom(_ ColorValue: UInt) -> UIColor
    {
        let Red: CGFloat = CGFloat((ColorValue & 0xff0000) >> 16) / 255.0
        let Green: CGFloat = CGFloat((ColorValue & 0x00ff00) >> 8) / 255.0
        let Blue = CGFloat(ColorValue & 0x0000ff) / 255.0
        return UIColor(red: Red, green: Green, blue: Blue, alpha: 1.0)
    }
    
    /// Return a color from the passed color table enum. Returned type is CGColor.
    ///
    /// - Parameter ColorValue: The color table enum whose actual color will be returned.
    /// - Returns: Color (CGColor) based on the passed enum.
    public static func CGColorFrom(_ Color: ColorNames) -> CGColor
    {
        return ColorFrom(Color).cgColor
    }
    
    /// Return a color from the passed color table enum.
    ///
    /// - Parameter ColorValue: The color table enum whose actual color will be returned.
    /// - Returns: Color based on the passed enum.
    public static func ColorFrom(_ Color: ColorNames) -> UIColor
    {
        if Color == ColorNames.Clear
        {
            return UIColor.clear
        }
        if Color == ColorNames.Random
        {
            return RandomColor()
        }
        return ColorFrom(Color.rawValue)
    }
    
    /// Return a color with a possibly non-1.0 alpha level.
    /// - Parameter Color: The color name whose alpha value will be set to `WithAlpha`.
    /// - Parameter WithAlpha: The alpha value to use for the returned color. Values less than 0 or greater than 1 result
    ///                        in an alpha of 1.0.
    /// - Returns: Color with the specified alpha.
    public static func ColorFrom(_ Color: ColorNames, WithAlpha: CGFloat) -> UIColor
    {
        let TheColor = ColorFrom(Color)
        if WithAlpha < 0.0 || WithAlpha > 1.0
        {
            return TheColor
        }
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var NotUsed: CGFloat = 0.0
        TheColor.getRed(&Red, green: &Green, blue: &Blue, alpha: &NotUsed)
        return UIColor(red: Red, green: Green, blue: Blue, alpha: WithAlpha)
    }
    
    /// Converts a color that has been encoded as a string into an actual NSColor.
    ///
    /// - Note: `ColorName` must follow one of the following rules to be successfully converted to a color:
    ///   1. Must be a name that is defined in the enum `ColorNames` with exact spelling and case.
    ///   2. Must be a 24-bit hex number with a leading `0x` or `0X'.
    ///   3. Must be a 24-bit hex number with a leading `#`.
    ///
    /// - Parameters:
    ///   - ColorName: The name or value of the color.
    ///   - Default: The default color to return if `ColorName` cannot be resolved.
    /// - Returns: Color associated with the specified name.
    public static func ColorFrom(_ ColorName: String, Default: ColorNames = .MediumGray) -> UIColor
    {
        if ColorName.uppercased().starts(with: "0x") || ColorName.starts(with: "#")
        {
            var stemp = ColorName.replacingOccurrences(of: "0x", with: "")
            stemp = stemp.replacingOccurrences(of: "0X", with: "")
            stemp = stemp.replacingOccurrences(of: "#", with: "")
            let CVal = UInt(stemp, radix: 16)
            return ColorFrom(CVal!)
        }
        if let Existing = FindColorName(ColorName)
        {
            return ColorFrom(Existing)
        }
        return ColorFrom(Default)
    }
    
    /// Desaturate the passed color.
    ///
    /// - Parameters:
    ///   - Color: The color to desaturate.
    ///   - Multiplier: Determines the desaturation level. Defaults to 0.5 (used as a multiplier).
    /// - Returns: Desaturated version of the passed color.
    public static func Desaturate(Color: UIColor, Multiplier: CGFloat = 0.5) -> UIColor
    {
        var Hue: CGFloat = 0.0
        var Sat: CGFloat = 0.0
        var Bri: CGFloat = 0.0
        var Alp: CGFloat = 0.0
        Color.getHue(&Hue, saturation: &Sat, brightness: &Bri, alpha: &Alp)
        Sat = Sat * Multiplier
        let NewColor = UIColor(hue: Hue, saturation: Sat, brightness: Bri, alpha: Alp)
        return NewColor
    }
    
    /// Takes the passed color (from the color table enum) and returns a desaturated version.
    ///
    /// - Parameters:
    ///   - Color: Color from the color table enum.
    ///   - Multiplier: Determines the desaturation level. Defaults to 0.5 (used as a multiplier).
    /// - Returns: Desaturated version of the passed color.
    public static func Desaturate(Color: ColorNames, Multiplier: CGFloat = 0.5) -> UIColor
    {
        return Desaturate(Color: ColorFrom(Color), Multiplier: Multiplier)
    }
    
    /// Desaturate the passed color (a string value that we have to resolve) and returns a desaturated version.
    /// - Parameter ColorName: The name of the color. Resolved in `ColorFrom`.
    /// - Parameter Multiplier: Determines the desaturation level. Defaults to 0.5 (used as a multiplier).
    /// - Returns: Desaturated color based on `ColorName`.
    public static func Desaturate(ColorName: String, Multiplier: CGFloat = 0.5) -> UIColor
    {
        let TheColor = ColorFrom(ColorName)
        return Desaturate(Color: TheColor, Multiplier: Multiplier)
    }
    
    /// Desaturate the passed color value.
    ///
    /// - Parameters:
    ///   - ColorValue: The value of the color to desaturate.
    ///   - Multiplier: Determines the desaturation level. Defaults to 0.5 (used as a multiplier).
    /// - Returns: Desaturated version of the passed color value.
    public static func Desaturate(ColorValue: UInt, Multiplier: CGFloat = 0.5) -> UInt
    {
        var Red: CGFloat = CGFloat((ColorValue & 0xff0000) >> 16) / 255.0
        var Green: CGFloat = CGFloat((ColorValue & 0x00ff00) >> 8) / 255.0
        var Blue: CGFloat = CGFloat((ColorValue & 0x0000ff)) / 255.0
        var NotUsed: CGFloat = 0.0
        var ScratchColor = UIColor(red: Red, green: Green, blue: Blue, alpha: 1.0)
        ScratchColor = Desaturate(Color: ScratchColor, Multiplier: Multiplier)
        ScratchColor.getRed(&Red, green: &Green, blue: &Blue, alpha: &NotUsed)
        let Final = (UInt(Red * 255.0) << 16) + (UInt(Green * 255.0) << 8) + UInt(Blue * 255.0)
        return Final
    }
    
    /// Darken the passed color.
    ///
    /// - Parameters:
    ///   - Color: The color to darken.
    ///   - Multiplier: Determines the darkness level. Defaults to 0.5 (used as a multiplier).
    /// - Returns: Darkened version of the passed color.
    public static func Darken(Color: UIColor, Multiplier: CGFloat = 0.5) -> UIColor
    {
        var Hue: CGFloat = 0.0
        var Sat: CGFloat = 0.0
        var Bri: CGFloat = 0.0
        var Alp: CGFloat = 0.0
        Color.getHue(&Hue, saturation: &Sat, brightness: &Bri, alpha: &Alp)
        Bri = Bri * Multiplier
        let NewColor = UIColor(hue: Hue, saturation: Sat, brightness: Bri, alpha: Alp)
        return NewColor
    }
    
    /// Takes the passed color (from the color table enum) and returns a darkened version.
    ///
    /// - Parameters:
    ///   - Color: Color from the color table enum.
    ///   - Multiplier: Determines the darkness level. Defaults to 0.5 (used as a multiplier).
    /// - Returns: Darkened version of the passed color.
    public static func Darken(Color: ColorNames, Multiplier: CGFloat = 0.5) -> UIColor
    {
        return Darken(Color: ColorFrom(Color), Multiplier: Multiplier)
    }
    
    /// Takens the passed color (as a string, resolved by `ColorFrom`) and returns a darkened version.
    /// - Parameter ColorName: The name of the color in string version.
    /// - Parameter Multiplier: Determines the darkness level. Defaults to 0.5 (used as a multiplier).
    /// - Returns: Darkened version of the passed color.
    public static func Darken(ColorName: String, Multiplier: CGFloat = 0.5) -> UIColor
    {
        let TheColor = ColorFrom(ColorName)
        return Darken(Color: TheColor, Multiplier: Multiplier)
    }
    
    /// Darken the passed color value.
    ///
    /// - Parameters:
    ///   - ColorValue: The value of the color to darken.
    ///   - Multiplier: Determines the darkness level. Defaults to 0.5 (used as a multiplier).
    /// - Returns: Darkened version of the passed color value.
    public static func Darken(ColorValue: UInt, Multiplier: CGFloat = 0.5) -> UInt
    {
        var Red: CGFloat = CGFloat((ColorValue & 0xff0000) >> 16) / 255.0
        var Green: CGFloat = CGFloat((ColorValue & 0x00ff00) >> 8) / 255.0
        var Blue: CGFloat = CGFloat((ColorValue & 0x0000ff)) / 255.0
        var NotUsed: CGFloat = 0.0
        var ScratchColor = UIColor(red: Red, green: Green, blue: Blue, alpha: 1.0)
        ScratchColor = Desaturate(Color: ScratchColor, Multiplier: Multiplier)
        ScratchColor.getRed(&Red, green: &Green, blue: &Blue, alpha: &NotUsed)
        let Final = (UInt(Red * 255.0) << 16) + (UInt(Green * 255.0) << 8) + UInt(Blue * 255.0)
        return Final
    }
    
    /// Converts an integer into a color.
    ///
    /// - Parameter From: The integer value of the color to return.
    /// - Returns: UIColor created from the passed integer.
    private static func MakeColor(From: Int) -> UIColor
    {
        let r = (From >> 16) & 0xff
        let g = (From >> 8) & 0xff
        let b = (From) & 0xff
        return UIColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    }
    
    /// Given a color, return a hex string (with a "0x" prefix) of the color's value.
    /// - Parameter From: The color to convert.
    /// - Returns: Hex string of the color.
    public static func MakeHexString(From: UIColor) -> String
    {
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var NotUsed: CGFloat = 0.0
        From.getRed(&Red, green: &Green, blue: &Blue, alpha: &NotUsed)
        let IRed = Int(Red * 255.0)
        let IGreen = Int(Green * 255.0)
        let IBlue = Int(Blue * 255.0)
        let Final = "0x" + String(format: "%02x", IRed) + String(format: "%02x", IGreen) + String(format: "%02x", IBlue)
        return Final
    }
    
    /// Given a color, return a hex string in the requested format.
    /// - Parameter From: The color whose values will be returned as a hex string.
    /// - Parameter Format: Determines the format of the returned string.
    /// - Parameter Prefix: The prefix string for the result. Defaults to "**#**".
    /// - Returns: String hex value of the passed color in the specified format.
    public static func MakeHexString(From: UIColor, Format: ChannelFormats, Prefix: String = "#") -> String
    {
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        From.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        let IRed = Int(Red * 255.0)
        let SRed = String(format: "%02x", IRed)
        let IGreen = Int(Green * 255.0)
        let SGreen = String(format: "%02x", IGreen)
        let IBlue = Int(Blue * 255.0)
        let SBlue = String(format: "%02x", IBlue)
        let IAlpha = Int(Alpha * 255.0)
        let SAlpha = String(format: "%02x", IAlpha)
        var Final = Prefix
        switch Format
        {
            case .RGB:
            Final = Final + SRed + SGreen + SBlue
            
            case .BGR:
            Final = Final + SBlue + SGreen + SRed
            
            case .ARGB:
            Final = Final + SAlpha + SRed + SGreen + SBlue
            
            case .RGBA:
            Final = Final + SRed + SGreen + SBlue + SAlpha
            
            case .BGRA:
            Final = Final + SBlue + SGreen + SRed + SAlpha
        }
        return Final
    }
    
    /// Given a color name enumeration, return the string hex value of the color.
    /// - Parameter From: The color name enumeration.
    /// - Returns: String hex value of the passed color.
    public static func MakeHexString(From: ColorNames) -> String
    {
        return MakeHexString(From: ColorFrom(From))
    }
}

/// Channel formats used to determine the format of color to hex values.
/// - **RGB**: Color returned in red, green, blue order.
/// - **BGR**: Color returned in blue, green, red order.
/// - **ARGB**: Color returned in alpha, red, green, blue order.
/// - **BGRA**: Color returned in blue, green, red, alpha order.
/// - **RGBA**: Color returned in red, green, blue, alpha order.
enum ChannelFormats: String, CaseIterable
{
    case RGB = "RGB"
    case BGR = "BGR"
    case ARGB = "ARGB"
    case BGRA = "BGRA"
    case RGBA = "RGBA"
}
