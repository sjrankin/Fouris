//
//  TColor.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Class that encompasses a color or a gradient color.
class TColor: Serializable
{
    func Populate(Key: String, Value: String)
    {
    }
    
    private var _Name: String = ""
    public var Name: String
    {
        get
        {
            return _Name
        }
        set
        {
            //Parse name here.
            _Dirty = true
        }
    }
    
    private var _Dirty: Bool = false
    public var Dirty: Bool
    {
        get
        {
            return _Dirty
        }
    }
    
    private var _IsGradient: Bool = false
    public var IsGradient: Bool
    {
        get
        {
            return _IsGradient
        }
        set
        {
            _IsGradient = newValue
            _Dirty = true
        }
    }
    
    private var _GradientDirection: GradientDirections = .Vertical
    public var GradientDirection: GradientDirections
    {
        get
        {
            return _GradientDirection
        }
        set
        {
            _GradientDirection = newValue
            _Dirty = true
        }
    }
    
    private var _GradientNormal: Double = 0.0
    public var GradientNormal: Double
    {
        get
        {
            return _GradientNormal
        }
        set
        {
            _GradientNormal = newValue
        }
    }
}

enum GradientDirections: String, CaseIterable
{
    case Vertical = "Vertical"
    case Horizontal = "Horizontal"
}
