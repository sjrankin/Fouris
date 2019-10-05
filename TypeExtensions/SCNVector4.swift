//
//  SCNVector4.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit

extension SCNVector4
{
    /// Parses a string in the format `float,float,float,float` or `(float,float,float,float)` into an SCNVector4.
    /// - Parameter Raw: The string to convert.
    /// - Returns: SCNVector4 value based on the contents of the passed string. Nil on parse failure.
    public static func Parse(_ Raw: String) -> SCNVector4?
    {
        if Raw.isEmpty
        {
            return nil
        }
        var Working = Raw.replacingOccurrences(of: "(", with: "")
        Working = Raw.replacingOccurrences(of: ")", with: "")
        let Parts = Working.trimmingCharacters(in: CharacterSet.whitespaces).split(separator: ",", omittingEmptySubsequences: true)
        if Parts.count != 4
        {
            return nil
        }
        let RawX = String(Parts[0]).trimmingCharacters(in: CharacterSet.whitespaces)
        let RawY = String(Parts[1]).trimmingCharacters(in: CharacterSet.whitespaces)
        let RawZ = String(Parts[2]).trimmingCharacters(in: CharacterSet.whitespaces)
        let RawW = String(Parts[3]).trimmingCharacters(in: CharacterSet.whitespaces)
        
        if let X = Float(RawX)
        {
            if let Y = Float(RawY)
            {
                if let Z = Float(RawZ)
                {
                    if let W = Float(RawW)
                    {
                        return SCNVector4(X, Y, Z, W)
                    }
                }
            }
        }
        return nil
    }
}
