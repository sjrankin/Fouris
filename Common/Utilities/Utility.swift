//
//  Utility.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/31/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class Utility
{
    /// Force the test value to conform to the passed range.
    ///
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
}
