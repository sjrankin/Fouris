//
//  Extensions.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/10/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Convenience extensions for UUID.
extension UUID
{
    /// Returns an empty UUID (all zero values for all fields).
    static var Empty: UUID
    {
        get
        {
            return UUID(uuidString: "00000000-0000-0000-0000-000000000000")!
        }
    }
}

/// Convenience extensions for CGPoint.
extension CGPoint
{
    /// Return a new point from the instance point and passed offset coordinate.
    ///
    /// - Parameters:
    ///   - X: Horizontal coordinate to add to the instance `x` coordinate.
    ///   - Y: Vertical coordinate to add to the instance `y` coordinate.
    /// - Returns: New CGPoint created from the instance and offset values.
    func WithOffset(_ X: Int, _ Y: Int) -> CGPoint
    {
        return CGPoint(x: Int(self.x) + X, y: Int(self.y) + Y)
    }
    
    /// Return a new point from the instance point and passed offset point.
    ///
    /// - Parameter OtherPoint: The other point that will be added, on a field-by-field
    ///                         basis, to the instance point.
    /// - Returns: New CGPoint created from the instance and offset points.
    func WithOffset(_ OtherPoint: CGPoint) -> CGPoint
    {
        return CGPoint(x: Int(self.x) + Int(OtherPoint.x),
                       y: Int(self.y) + Int(OtherPoint.y))
    }
    
    /// Return a new point from the instance point and passed offset point.
    ///
    /// - Parameter OtherPoint: The other point that will be subtracted, on a field-by-field
    ///                         basis, to the instance point.
    /// - Returns: New CGPoint created from the instance and offset points.
    func WithNegativeOffset(_ OtherPoint: CGPoint) -> CGPoint
    {
        return CGPoint(x: Int(self.x) - Int(OtherPoint.x),
                       y: Int(self.y) - Int(OtherPoint.y))
    }
}
