//
//  AnimatedGradient.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class AnimatedGradient: CAGradientLayer
{
    override init()
    {
        super.init()
    }
    
    override init(layer: Any)
    {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    public func LoadGradientStops(_ GradientStops: [AnimatedGradientStop], WithFrame: CGRect,
                                  IsVertical: Bool = true, LayerName: String? = nil)
    {
        _Stops = GradientStops
        _Stops.sort{$0.Stop < $1.Stop}
        
        if let GradientLayerName = LayerName
        {
            self.name = GradientLayerName
        }
        self.frame = WithFrame
        if IsVertical
        {
            self.startPoint = CGPoint(x: 0.0, y: 0.0)
            self.endPoint = CGPoint(x: 0.0, y: 1.0)
        }
        else
        {
            self.startPoint = CGPoint(x: 0.0, y: 0.0)
            self.endPoint = CGPoint(x: 1.0, y: 0.0)
        }
        
        var StopList = [Any]()
        var Locations = [NSNumber]()
        for SomeStop in _Stops
        {
            StopList.append(SomeStop.Color.cgColor as Any)
            let TheLocation = NSNumber(value: Float(SomeStop.Stop))
            Locations.append(TheLocation)
        }
        self.colors = StopList
        self.locations = Locations
    }
    
    private var _Stops = [AnimatedGradientStop]()
    /// Get or set the list of animated gradient stops.
    /// - Note: Setting this variable stops any animation that is running.
    public var Stops: [AnimatedGradientStop]
    {
        get
        {
            return _Stops
        }
        set
        {
            StopAnimation()
            _Stops = newValue
        }
    }
    
    public func StartAnimation()
    {
    }
    
    public func StopAnimation()
    {
        
    }
}
