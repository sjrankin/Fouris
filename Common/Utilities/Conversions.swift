//
//  Conversions.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/20/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit

class Convert
{
    /// Round a CFGloat to the nearest passed value.
    /// - Parameter value: The value to round.
    /// - Parameter ToNearest: The value to round to.
    /// - Returns: Rounded value.
    public static func Round(_ value: CGFloat, ToNearest: CGFloat) -> CGFloat
    {
        return round(value / ToNearest) * ToNearest
    }
    
    /// Round a Double to the nearest passed value.
    /// - Parameter value: The value to round.
    /// - Parameter ToNearest: The value to round to.
    /// - Returns: Rounded value.
    public static func Round(_ value: Double, ToNearest: Double) -> Double
    {
        return round(value / ToNearest) * ToNearest
    }
    
    /// Rounds a Double value and converts it to a string.
    /// - Parameter value: The value to convert.
    /// - Parameter ToNearest: The value to round to.
    /// - Parameter CharCount: Truncation value.
    public static func RoundToString(_ value: Double, ToNearest: Double, CharCount: Int = 5) -> String
    {
        let RoundTo = ToNearest > 1.0 ? 1.0 : ToNearest
        let Rounded = round(value / RoundTo) * RoundTo
        let stemp = String(Rounded)
        return String(stemp.prefix(CharCount))
    }
    
    /// Rounds a CGFloat value and converts it to a string.
    /// - Parameter value: The value to convert.
    /// - Parameter ToNearest: The value to round to.
    /// - Parameter CharCount: Truncation value.
    public static func RoundToString(_ value: CGFloat, ToNearest: CGFloat, CharCount: Int = 5) -> String
    {
        let RoundTo = ToNearest > 1.0 ? 1.0 : ToNearest
        let Rounded = round(value / RoundTo) * RoundTo
        let stemp = String(Double(Rounded))
        return String(stemp.prefix(CharCount))
    }
    
    /// Convert an SCNVector3 to a string.
    /// - Parameter Raw: The value to convert.
    /// - Parameter AddLabels: If true, field values are labeled (eg, "x:" is prepended to the x value, etc). Defaults to false.
    /// - Parameter AddParentheses: If true, the result is encapsulated in open and close parentheses. Defaults to false.
    /// - Parameter RoundTo: Value to round to. Defaults to 0.0001.
    public static func ConvertToString(_ Raw: SCNVector3, AddLabels: Bool = false, AddParentheses: Bool = false,
                                       RoundTo: Double = 0.0001) -> String
    {
        let x = Round(CGFloat(Raw.x), ToNearest: CGFloat(RoundTo))
        let y = Round(CGFloat(Raw.y), ToNearest: CGFloat(RoundTo))
        let z = Round(CGFloat(Raw.z), ToNearest: CGFloat(RoundTo))
        var Results = ""
        if AddLabels
        {
            Results = "x: \(x), y: \(y), z: \(z)"
        }
        else
        {
            Results = "\(x), \(y), \(z)"
        }
        if AddParentheses
        {
            Results = "(" + Results + ")"
        }
        return Results
    }
    
    /// Convert an SCNVector4 to a string.
    /// - Parameter Raw: The value to convert.
    /// - Parameter AddLabels: If true, field values are labeled (eg, "x:" is prepended to the x value, etc). Defaults to false.
    /// - Parameter AddParentheses: If true, the result is encapsulated in open and close parentheses. Defaults to false.
        /// - Parameter RoundTo: Value to round to. Defaults to 0.0001.
    public static func ConvertToString(_ Raw: SCNVector4, AddLabels: Bool = false, AddParentheses: Bool = false,
                                       RoundTo: Double = 0.0001) -> String
    {
        let x = Round(CGFloat(Raw.x), ToNearest: CGFloat(RoundTo))
        let y = Round(CGFloat(Raw.y), ToNearest: CGFloat(RoundTo))
        let z = Round(CGFloat(Raw.z), ToNearest: CGFloat(RoundTo))
        let w = Round(CGFloat(Raw.w), ToNearest: CGFloat(RoundTo))
        var Results = ""
        if AddLabels
        {
            Results = "x: \(x), y: \(y), z: \(z), w: \(w)"
        }
        else
        {
            Results = "\(x), \(y), \(z), \(w)"
        }
        if AddParentheses
        {
            Results = "(" + Results + ")"
        }
        return Results
    }
}
