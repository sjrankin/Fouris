//
//  OSColorExtensions.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Extensions for UIColor.
extension UIColor
{
    /// Create an UIColor with the lower 24-bits of the passed integer. Alpha is set to 1.0.
    ///
    /// - Parameter Hex: Numeric color value. Only the lower 24-bits are used. The colors are in rrggbb order.
    convenience init(Hex: Int)
    {
        let r = (Hex >> 16) & 0xff
        let g = (Hex >> 8) & 0xff
        let b = (Hex) & 0xff
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: 1.0)
    }
    
    /// Create an UIColor with the passed hex string.
    ///
    /// - Note:
    ///   The format of the hex string is: `rrggbb` or `rrggbbaa` with optional prefix.
    ///
    /// - Parameter HexString: The hex value in a string. The value may be prefixed by `#`, `0x` or '0X' but
    ///                        values without prefixes are acceptable. Alpha channels are also permissible.
    ///                        Channel values that somehow evaluated to out of range are clamped. Invalid
    ///                        `HexString` values result in a failure (nil returned).
    convenience init?(HexString: String)
    {
        self.init()
        if HexString.count < 1
        {
            return nil
        }
        var Working = HexString.trimmingCharacters(in:. whitespacesAndNewlines)
        Working = Working.lowercased()
        Working = Working.replacingOccurrences(of: "#", with: "")
        Working = Working.replacingOccurrences(of: "0x", with: "")
        if Working.count == 6 || Working.count == 8
        {
        }
        else
        {
            print("Unable to convert \(HexString) to a color.")
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
            self.init(red: FRed, green: FGreen, blue: FBlue, alpha: FAlpha)
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
            
            self.init(red: FRed, green: FGreen, blue: FBlue, alpha: 1.0)
        }
    }
    
    /// Return the value of the instance UIColor as a hex string.
    ///
    /// - Parameters:
    ///   - Order: The order of the channels. This also determines whether alpha is included or not.
    ///   - Prefix: The prefix string.
    /// - Returns: String with the hex values of each channel in the specified order.
    func AsHexString(Order: ChannelOrders = .RGB, Prefix: String = "#") -> String
    {
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var Alpha: CGFloat = 0.0
        self.getRed(&Red, green: &Green, blue: &Blue, alpha: &Alpha)
        let IRed: Int = Int(Red * 255.0)
        let IGreen: Int = Int(Green * 255.0)
        let IBlue: Int = Int(Blue * 255.0)
        let IAlpha: Int = Int(Alpha * 255.0)
        var Final = ""
        switch Order
        {
        case .RGB:
            Final = String(format: "%02x", IRed) + String(format: "%02x", IGreen) + String(format: "%02x", IBlue)
            
        case .ARGB:
            Final = String(format: "%02x", IAlpha) + String(format: "%02x", IRed) + String(format: "%02x", IGreen) + String(format: "%02x", IBlue)
            
        case .RGBA:
            Final = String(format: "%02x", IRed) + String(format: "%02x", IGreen) + String(format: "%02x", IBlue) + String(format: "%02x", IAlpha)
            
        case .BGR:
            Final = String(format: "%02x", IBlue) + String(format: "%02x", IGreen) + String(format: "%02x", IRed)
            
        case .BGRA:
            Final = String(format: "%02x", IBlue) + String(format: "%02x", IGreen) + String(format: "%02x", IRed) + String(format: "%02x", IAlpha)
            
        case .ABGR:
            Final = String(format: "%02x", IAlpha) + String(format: "%02x", IBlue) + String(format: "%02x", IGreen) + String(format: "%02x", IRed)
        }
        Final = Prefix + Final
        return Final
    }
    
    /// Order of the channels to return for hex strings.
    enum ChannelOrders
    {
        case RGB
        case BGR
        case ARGB
        case BGRA
        case RGBA
        case ABGR
    }
    
    public static func MakeRandomColor(_ ColorType: RandomColorTypes = .AnyColor) -> UIColor
    {
        var RRed: Double = 0.0
        var RGreen: Double = 0.0
        var RBlue: Double = 0.0
        switch ColorType
        {
        case .AnyColor:
            RRed = Double.random(in: 0.0 ... 1.0)
            RGreen = Double.random(in: 0.0 ... 1.0)
            RBlue = Double.random(in: 0.0 ... 1.0)
            
        case .Dark:
            RRed = Double.random(in: 0.0 ... 0.3)
            RGreen = Double.random(in: 0.0 ... 0.3)
            RBlue = Double.random(in: 0.0 ... 0.3)
            
        case .Light:
            RRed = Double.random(in: 0.7 ... 1.0)
            RGreen = Double.random(in: 0.7 ... 1.0)
            RBlue = Double.random(in: 0.7 ... 1.0)
        }
        return UIColor(red: CGFloat(RRed), green: CGFloat(RGreen), blue: CGFloat(RBlue), alpha: 1.0)
    }
    
    /// Type of random color returned by `MakeRandomColor`.
    ///
    /// - AnyColor: Any random color - all channels are in the range 0.0 - 1.0.
    /// - Dark: Dark random color - all channels are in the range 0.0 - 0.3.
    /// - Light: Light random color - all channels are in the range 0.7 - 1.0.
    public enum RandomColorTypes
    {
        case AnyColor
        case Dark
        case Light
    }
}
