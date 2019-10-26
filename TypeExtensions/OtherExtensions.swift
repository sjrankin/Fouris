//
//  OtherExtensions.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/30/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Extension methods for Double.
extension Double
{
    /// Round a value to the supplied precision.
    /// - Parameter To: Precision of the returned value.
    /// - Returns: Rounded double value.
    func Round(To: Int) -> Double
    {
        let Div = pow(10.0, Double(To))
        return (self * Div).rounded() / Div
    }
    
    /// Clamps the instance double value.
    /// - Parameter From: Low end of the valid range.
    /// - Parameter To: High end of the valid range.
    /// - Returns: Vale of the double clamped to the supplied range.
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
    
    /// Returns the size of a double instance value in memory.
    /// - Returns: Size of the double in memory.
    func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: self)
    }
    
    /// Returns the size of a double value in memory.
    /// - Note: This is a static version of the function and supplies its own Double.
    /// - Returns: Size of the double in memory.
    static func SizeOf() -> Int
    {
        return MemoryLayout.size(ofValue: Double(0.0))
    }
}

/// UIImage extensions.
extension UIImage
{
    /// Initializer that creates a solid color image.
    /// - Parameter Color: The color to fill the image with.
    /// - Parameter Size: The size of the image. Defaults to a width of 1 and a height of 1.
    public convenience init?(Color: UIColor, Size: CGSize = CGSize(width: 1, height: 1))
    {
        let Rect = CGRect(origin: .zero, size: Size)
        UIGraphicsBeginImageContextWithOptions(Rect.size, false, UIScreen.main.scale)
        Color.setFill()
        UIRectFill(Rect)
        let Image = UIGraphicsGetImageFromCurrentImageContext()
        guard let CGimage = Image?.cgImage else
        {
            return nil
        }
        self.init(cgImage: CGimage)
    }
}
