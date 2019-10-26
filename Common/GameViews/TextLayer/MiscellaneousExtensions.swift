//
//  MiscellaneousExtensions.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Int extensions.
extension Int
{
    /// Returns the instance value as a CGFloat.
    public var AsCGFloat: CGFloat
    {
        return CGFloat(self)
    }
}

/// CGRect extensions.
extension CGRect
{
    /// Returns a new CGRect based on the instance with a new `x` value.
    /// - Parameter XOffset: Value to add to `x`
    /// - Returns: New CGRect with updated `x` value.
    public func WithXOffset(_ XOffset: CGFloat) -> CGRect
    {
        let NewX = self.minX + XOffset
        return CGRect(x: NewX, y: self.minY, width: self.width, height: self.height)
    }
    
    /// Returns a new CGRect based on the instance with a new `x` value.
    /// - Parameter NewX: New value for `x`.
    /// - Returns: New CGRect with new `x` value.
    public func WithNewX(_ NewX: CGFloat) -> CGRect
    {
        return CGRect(x: NewX, y: self.minY, width: self.width, height: self.height)
    }
    
    /// Returns a new CGRect based on the instance with a new `y` value.
    /// - Parameter YOffset: Value to add to `y`
    /// - Returns: New CGRect with updated `y` value.
    public func WithYOffset(_ YOffset: CGFloat) -> CGRect
    {
        let NewY = self.minY + YOffset
        return CGRect(x: self.minX, y: NewY, width: self.width, height: self.height)
    }
    
    /// Returns a new CGRect based on the instance with a new `y` value.
    /// - Parameter NewY: New value for `y`.
    /// - Returns: New CGRect with new `y` value.
    public func WithNewY(_ NewY: CGFloat) -> CGRect
    {
        return CGRect(x: self.minX, y: NewY, width: self.width, height: self.height)
    }
    
    /// Returns a new CGRect based on the instance but with a new position.
    /// - Parameter NewX: New `x` value.
    /// - Parameter NewY: New `y` value.
    /// - Returns: New CGRect with a new position.
    public func WithNewPosition(_ NewX: CGFloat, _ NewY: CGFloat) -> CGRect
    {
        return CGRect(x: NewX, y: NewY, width: self.width, height: self.height)
    }
    
    /// Returns a new CGRect based on the instance but with a new position.
    /// - Parameter NewPosition: The new position for the returned value.
    /// - Returns: New CGRect with a new position.
    public func WithNewPosition(_ NewPosition: CGPoint) -> CGRect
    {
        return CGRect(origin: NewPosition, size: CGSize(width: self.width, height: self.height))
    }
    
    /// Returns a new CGRect based on the instance with a new size.
    /// - Parameter NewWidth: New width of the rectangle.
    /// - Parameter NewHeight: New height of the rectangle.
    /// - Returns: New CGRect with the new size.
    public func WithNewSize(_ NewWidth: CGFloat, _ NewHeight: CGFloat) -> CGRect
    {
        return CGRect(x: self.minX, y: self.minY, width: NewWidth, height: NewHeight)
    }
    
    /// Returns a new CGRect based on the instance with a new size.
    /// - Parameter NewSize: New size for the rectangle.
    /// - Returns: New CGRect with the new size.
    public func WithNewSize(_ NewSize: CGSize) -> CGRect
    {
        return CGRect(origin: CGPoint(x: self.minX, y: self.minY), size: NewSize)
    }
}
