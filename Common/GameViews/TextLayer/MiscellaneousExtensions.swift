//
//  MiscellaneousExtensions.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

extension Int
{
    var AsCGFloat: CGFloat
    {
        return CGFloat(self)
    }
}

extension CGRect
{
    func WithXOffset(_ XOffset: CGFloat) -> CGRect
    {
        let NewX = self.minX + XOffset
        return CGRect(x: NewX, y: self.minY, width: self.width, height: self.height)
    }
    
    func WithNewX(_ NewX: CGFloat) -> CGRect
    {
        return CGRect(x: NewX, y: self.minY, width: self.width, height: self.height)
    }
    
    func WithYOffset(_ YOffset: CGFloat) -> CGRect
    {
        let NewY = self.minY + YOffset
        return CGRect(x: self.minX, y: NewY, width: self.width, height: self.height)
    }
    
    func WithNewY(_ NewY: CGFloat) -> CGRect
    {
        return CGRect(x: self.minX, y: NewY, width: self.width, height: self.height)
    }
    
    func WithNewPosition(_ NewX: CGFloat, _ NewY: CGFloat) -> CGRect
    {
        return CGRect(x: NewX, y: NewY, width: self.width, height: self.height)
    }
    
    func WithNewPosition(_ NewPosition: CGPoint) -> CGRect
    {
        return CGRect(origin: NewPosition, size: CGSize(width: self.width, height: self.height))
    }
    
    func WithNewSize(_ NewWidth: CGFloat, _ NewHeight: CGFloat) -> CGRect
    {
        return CGRect(x: self.minX, y: self.minY, width: NewWidth, height: NewHeight)
    }
    
    func WithNewSize(_ NewSize: CGSize) -> CGRect
    {
        return CGRect(origin: CGPoint(x: self.minX, y: self.minY), size: NewSize)
    }
}
