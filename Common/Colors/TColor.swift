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
/// Not fully implemented yet - intended for future use.
class TColor: Serializable
{
    /// Not currently used.
    func Populate(Key: String, Value: String)
    {
    }
    
    /// Holds the name of a color.
    private var _Name: String = ""
    /// Get or set the name of the color.
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
    
    /// Holds the dirty flag.
    private var _Dirty: Bool = false
    /// Get the dirty flag.
    public var Dirty: Bool
    {
        get
        {
            return _Dirty
        }
    }
    
    /// Holds the gradient flag.
    private var _IsGradient: Bool = false
    /// Get or set the is gradient flag.
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
    
    /// Holds the gradient direction.
    private var _GradientDirection: GradientDirections = .Vertical
    /// Get or set the direction of the gradient.
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
    
    /// Holds the gradient normal.
    private var _GradientNormal: Double = 0.0
    /// Get or set the gradient normal.
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

/// Gradient directions.
/// - **Vertical**: Gradient is vertical.
/// - **Horizontal**: Gradient is horizontal.
enum GradientDirections: String, CaseIterable
{
    case Vertical = "Vertical"
    case Horizontal = "Horizontal"
}
