//
//  Utility.swift
//  Fouris
//  Adapted from BumpCamera and Visualizer Clock.
//
//  Created by Stuart Rankin on 8/31/19.
//  Copyright © 2018, 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Various utility functions.
class Utility
{
    /// Return a normalized RGB value.
    /// - Note: This is a fast way to return all channels of a color.
    /// - Parameter Color: The color to normalize.
    /// - Returns: Tuple of normalized values.
    public static func NormalizeRGB(_ Color: UIColor) -> (Double, Double, Double, Double)
    {
        let (A, R, G, B) = GetARGB(SourceColor: Color)
        return (Double(A), Double(R), Double(G), Double(B))
    }
    
    /// Force the test value to conform to the passed range.
    /// - Parameters:
    ///   - TestValue: The value to force to the passed range.
    ///   - ValidRange: Range to compare against the test value.
    /// - Returns: If the test value falls in the ValidRange, the test value is returned. Otherwise, the test
    ///            value is clamped to the range and returned.
    public static func ForceToValidRange(_ TestValue: Int, ValidRange: ClosedRange<Int>) -> Int
    {
        if ValidRange.lowerBound > TestValue
        {
            return ValidRange.lowerBound
        }
        if ValidRange.upperBound < TestValue
        {
            return ValidRange.upperBound
        }
        return TestValue
    }
    
    /// Convert a color to a human-readable string. For RGB, the value returned is in the format
    /// (alpha, red, green, blue) (the caller can control whether alpha is returned or not). For HSB,
    /// the format is (hue, saturation, brightness).
    /// - Parameters:
    ///   - Color: The color to convert.
    ///   - AsRGB: If true, ARGB is returned. If false, HSB is returned.
    ///   - DeNormalize: If true, color values are denomalized. If false, normalized color values are returned.
    ///   - IncludeAlpha: If true, the alpha value is returned. Otherwise, it is not.
    /// - Returns: String value of the passed color.
    public static func ColorToString(_ Color: UIColor, AsRGB: Bool = true, DeNormalize: Bool = true,
                                     IncludeAlpha: Bool = true) -> String
    {
        if AsRGB
        {
            let (A, R, G, B) = GetARGB(SourceColor: Color)
            if DeNormalize
            {
                let DNA: Int = Int(Round(A * 255.0, ToPlaces: 0))
                let DNR: Int = Int(Round(R * 255.0, ToPlaces: 0))
                let DNG: Int = Int(Round(G * 255.0, ToPlaces: 0))
                let DNB: Int = Int(Round(B * 255.0, ToPlaces: 0))
                if IncludeAlpha
                {
                    return "(\(DNA), \(DNR), \(DNG), \(DNB))"
                }
                else
                {
                    return "(\(DNR), \(DNG), \(DNB))"
                }
            }
            else
            {
                if IncludeAlpha
                {
                    return "(\(Round(A, ToPlaces: 3)), \(Round(R, ToPlaces: 3)), \(Round(G, ToPlaces: 3)), \(Round(B, ToPlaces: 3)))"
                }
                else
                {
                    return "(\(Round(R, ToPlaces: 3)), \(Round(G, ToPlaces: 3)), \(Round(B, ToPlaces: 3)))"
                }
            }
        }
        else
        {
            let (H, S, B) = GetHSB(SourceColor: Color)
            if DeNormalize
            {
                let DNH = Round(H * 360.0, ToPlaces: 1)
                let DNS = Round(S, ToPlaces: 3)
                let DNB = Round(B, ToPlaces: 3)
                return "(\(DNH), \(DNS), \(DNB))"
            }
            else
            {
                return "(\(Round(H, ToPlaces: 3)), \(Round(S, ToPlaces: 3)), \(Round(B, ToPlaces: 3)))"
            }
        }
    }
    
    /// Given a UIColor, return the hue, saturation, and brightness equivalent values.
    /// - Parameter SourceColor: The color whose hue, saturation, and brightness will be returned.
    /// - Returns: Tuple in the order: hue, saturation, brightness.
    public static func GetHSB(SourceColor: UIColor) -> (CGFloat, CGFloat, CGFloat)
    {
        let Hue = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Hue.initialize(to: 0.0)
        let Saturation = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Saturation.initialize(to: 0.0)
        let Brightness = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Brightness.initialize(to: 0.0)
        let UnusedAlpha = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        UnusedAlpha.initialize(to: 0.0)
        
        SourceColor.getHue(Hue, saturation: Saturation, brightness: Brightness, alpha: UnusedAlpha)
        
        let FinalHue = Hue.move()
        let FinalSaturation = Saturation.move()
        let FinalBrightness = Brightness.move()
        let _ = UnusedAlpha.move()
        
        //Clean up.
        Hue.deallocate()
        Saturation.deallocate()
        Brightness.deallocate()
        UnusedAlpha.deallocate()
        
        return (FinalHue, FinalSaturation, FinalBrightness)
    }
    
    /// Given a UIColor, return the alpha red, green, and blue component parts.
    /// - Parameter SourceColor: The color whose component parts will be returned.
    /// - Returns: Tuple in the order: Alpha, Red, Green, Blue.
    public static func GetARGB(SourceColor: UIColor) -> (CGFloat, CGFloat, CGFloat, CGFloat)
    {
        let Red = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Red.initialize(to: 0.0)
        let Green = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Green.initialize(to: 0.0)
        let Blue = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Blue.initialize(to: 0.0)
        let Alpha = UnsafeMutablePointer<CGFloat>.allocate(capacity: 1)
        Alpha.initialize(to: 0.0)
        
        SourceColor.getRed(Red, green: Green, blue: Blue, alpha: Alpha)
        
        let FinalRed = Red.move()
        let FinalGreen = Green.move()
        let FinalBlue = Blue.move()
        let FinalAlpha = Alpha.move()
        
        //Clean up.
        Red.deallocate()
        Green.deallocate()
        Blue.deallocate()
        Alpha.deallocate()
        
        return (FinalAlpha, FinalRed, FinalGreen, FinalBlue)
    }
    
    /// Converts the passed color to a tuple of RGB values (as integers).
    /// - Parameter Source: Source color to convert.
    /// - Returns: Tuple in the order (Red, Green, Blue) with each value an integer.
    public static func GetRGB(_ Source: UIColor) -> (Int, Int, Int)
    {
        let (_, R, G, B) = GetARGB(SourceColor: Source)
        let iR = Int(255.0 * R)
        let iG = Int(255.0 * G)
        let iB = Int(255.0 * B)
        return (iR, iG, iB)
    }
    
    /// Convert a string representation of a color (in hex format) to a color. For 24- or 32-bit colors.
    /// - Parameter HexString: The string representation of a color (in hex format).
    /// - Returns: Actual color. Nil on error or otherwise unable to convert.
    public static func FromHex2(HexString: String) -> UIColor?
    {
        if HexString.count < 1
        {
            return nil
        }
        var Working = HexString.trimmingCharacters(in:. whitespacesAndNewlines)
        Working = Working.replacingOccurrences(of: "#", with: "")
        Working = Working.replacingOccurrences(of: "0x", with: "")
        Working = Working.replacingOccurrences(of: "0X", with: "")
        if Working.count == 6 || Working.count == 8
        {
        }
        else
        {
            print("Unable to convert \(HexString) to a color.")
            return nil
        }
        
        var NewColor: UIColor!
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
            
            NewColor = UIColor.init(red: FRed, green: FGreen, blue: FBlue, alpha: FAlpha)
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
            
            NewColor = UIColor.init(red: FRed, green: FGreen, blue: FBlue, alpha: 1.0)
        }
        return NewColor
    }
    
    /// Truncate a double value to the number of places.
    /// - Parameters:
    ///   - Value: Value to truncate.
    ///   - ToPlaces: Where to truncate the value.
    /// - Returns: Truncated double value.
    public static func Truncate(_ Value: Double, ToPlaces: Int) -> Double
    {
        let D: Decimal = 10.0
        let X = pow(D, ToPlaces)
        let X1: Double = Double(truncating: X as NSNumber)
        let Working: Int = Int(Value * X1)
        let Final: Double = Double(Working) / X1
        return Final
    }
    
    /// Round a double value to the specified number of places.
    /// - Parameters:
    ///   - Value: Value to round.
    ///   - ToPlaces: Number of places to round to.
    /// - Returns: Rounded value.
    public static func Round(_ Value: Double, ToPlaces: Int) -> Double
    {
        let D: Decimal = 10.0
        let X = pow(D, ToPlaces + 1)
        let X1: Double = Double(truncating: X as NSNumber)
        var Working: Int = Int(Value * X1)
        let Last = Working % 10
        Working = Working / 10
        if Last >= 5
        {
            Working = Working + 1
        }
        let Final: Double = Double(Working) / (X1 / 10.0)
        return Final
    }
    
    /// Round a CGFloat value to the specified number of places.
    /// - Parameters:
    ///   - Value: Value to round.
    ///   - ToPlaces: Number of places to round to.
    /// - Returns: Rounded value.
    public static func Round(_ Value: CGFloat, ToPlaces: Int) -> CGFloat
    {
        let D: Decimal = 10.0
        let X = pow(D, ToPlaces + 1)
        let X1: CGFloat = CGFloat(truncating: X as NSNumber)
        var Working: Int = Int(Value * X1)
        let Last = Working % 10
        Working = Working / 10
        if Last >= 5
        {
            Working = Working + 1
        }
        let Final: CGFloat = CGFloat(Working) / (X1 / 10.0)
        return Final
    }
    
    /// Round a Float value to the specified number of places.
    /// - Parameters:
    ///   - Value: Value to round.
    ///   - ToPlaces: Number of places to round to.
    /// - Returns: Rounded value.
    public static func Round(_ Value: Float, ToPlaces: Int) -> Float
    {
        let D: Decimal = 10.0
        let X = pow(D, ToPlaces + 1)
        let X1: Float = Float(truncating: X as NSNumber)
        var Working: Int = Int(Value * X1)
        let Last = Working % 10
        Working = Working / 10
        if Last >= 5
        {
            Working = Working + 1
        }
        let Final: Float = Float(Working) / (X1 / 10.0)
        return Final
    }
}
