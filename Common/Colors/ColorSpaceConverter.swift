//
//  ColorSpaceConverter.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/2/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Class that contains routines to convert to and from various colorspaces.
class ColorSpaceConverter
{
    /// Convert the passed RGB color to a set of CMYK values.
    /// - Note: See [Convert RGB to CMYK](https://www.rapidtables.com/convert/color/rgb-to-cmyk.html).
    /// - Parameter RGB: The color to convert to CMYK.
    /// - Returns: Tuple in the order (Cyan, Magenta, Yellow, Black). Values clamped to 0.0 to 1.0.
    public static func ToCMYK(RGB: UIColor) -> (Double, Double, Double, Double)
    {
        let (R, G, B) = Utility.GetRGB(RGB)
        let RD = Double(R) / 255.0
        let GD = Double(G) / 255.0
        let BD = Double(B) / 255.0
        if R == 0 && G == 0 && B == 0
        {
            return (0.0, 0.0, 0.0, 1.0)
        }
        let K = 1.0 - max(RD, max(GD, BD))
        if K == 1.0
        {
            return (0.0, 0.0, 0.0, 1.0)
        }
        let C = (1.0 - RD - K) / (1.0 - K)
        let M = (1 - GD - K) / (1.0 - K)
        let Y = (1 - BD - K) / (1.0 - K)
        return (C, M, Y, K)
    }
    
    /// Convert a set of CMYK values to an RGB color.
    /// - Note: See [Convert RGB to CMYK](https://www.rapidtables.com/convert/color/rgb-to-cmyk.html).
    /// - Parameter CMYK: Tuple of values (in order: Cyan, Magenta, Yellow, Black, clamped to 0.0 to 1.0) to convert an an RGB color.
    /// - Returns: RGB color equivalent of the CMYK values.
    public static func ToRGB(CMYK: (Double, Double, Double, Double)) -> UIColor
    {
        let R = (1.0 - CMYK.0) * (1.0 - CMYK.3)
        let G = (1.0 - CMYK.1) * (1.0 - CMYK.3)
        let B = (1.0 - CMYK.2) * (1.0 - CMYK.3)
        return UIColor(red: CGFloat(R), green: CGFloat(G), blue: CGFloat(B), alpha: 1.0)
    }
    
    /// Convert the passed RGB color to a set of YUV values.
    /// - Note: See [RGB to YUV Conversion](https://www.codeproject.com/Articles/402391/RGB-to-YUV-conversion-with-different-chroma-sampli).
    /// - Parameter RGB: The color to convert to YUV.
    /// - Returns: YUV values in the order Y, U, V.
    public static func ToYUV(RGB: UIColor) -> (Double, Double, Double)
    {
        let (R, G, B) = Utility.GetRGB(RGB)
        let RD = Double(R) / 255.0
        let GD = Double(G) / 255.0
        let BD = Double(B) / 255.0
        let Y: Double = (0.299 * RD) + (0.587 * GD) + BD
        let U: Double = (-0.1687 * RD) - (0.3313 * GD) + (0.5 * BD) + 128.0
        let V: Double = (0.5 * RD) - (0.4187 * GD) - (0.813 * BD) + 128.0
        return (Y, U, V)
    }
    
    /// Convert the passed YUV values to an RGB color.
    /// - Note: See [RGB to YUV Conversion](https://www.codeproject.com/Articles/402391/RGB-to-YUV-conversion-with-different-chroma-sampli).
    /// - Parameter YUV: Set of YUV values (in order: Y, U, V).
    /// - Returns: RGB color equivalent of the YUV values.
    public static func ToRGB(YUV: (Double, Double, Double)) -> UIColor
    {
        let R: CGFloat = CGFloat(YUV.0) + (1.13983 * CGFloat(YUV.2))
        let G: CGFloat = CGFloat(YUV.0) - (0.39465 * CGFloat(YUV.1)) + CGFloat(YUV.2)
        let B: CGFloat = CGFloat(YUV.0) - (0.03211 * CGFloat(YUV.1))
        return UIColor(red: R, green: G, blue: B, alpha: 1.0)
    }
    
    /// Convert the passed RGB color to a set of HSB values.
    /// - Note: Uses Apple APIs to convert.
    /// - Parameter RGB: The RGB value to convert.
    /// - Returns: HSB values (in order: H, S, B). All values clamped to 0.0 to 1.0.
    public static func ToHSB(RGB: UIColor) -> (Double, Double, Double)
    {
        let (H, S, B) = Utility.GetHSB(SourceColor: RGB)
        return (Double(H), Double(S), Double(B))
    }
    
    /// Convert the passed HSB values to an RGB color.
    /// - Note: Uses Apple APIs to convert.
    /// - Parameter HSB: Set of HSB values (in order: H, S, B), all clamped to 0.0 to 1.0.
    /// - Returns: RGB color equivalent of the HSB values.
    public static func ToRGB(HSB: (Double, Double, Double)) -> UIColor
    {
        return UIColor(hue: HSB.0, saturation: HSB.1, brightness: HSB.2)
    }
}
