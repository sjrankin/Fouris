//
//  OtherExtensions.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/30/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension Double
{
    func Round(To: Int) -> Double
    {
        let Div = pow(10.0, Double(To))
        return (self * Div).rounded() / Div
    }
    
    func Clamp(_ From: Double, _ To: Double) -> Double
    {
        if self < From
        {
            return From
        }
        if self > To
        {
            return To
        }
        return self
    }
    
    func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: self)
    }
    
    static func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: Double(0.0))
    }
}
