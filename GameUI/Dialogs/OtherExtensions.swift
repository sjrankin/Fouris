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

extension UIImage
{
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
