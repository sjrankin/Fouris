//
//  AnimatedGradientStop.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Encapsulates an animated gradient stop.
/// - Note: All color stop locations are in the form of a normalized value where 0.0 is at the top (or left) and 1.0 is at the
///         bottom (or right).
class AnimatedGradientStop
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer. Duration is set to 0.0 which means this particular color stop will not animate.
    /// - Parameter WithColor: Color stop color.
    /// - Parameter At: Color stop location.
    init(WithColor: UIColor, At: CGFloat)
    {
        _Color = WithColor
        Stop = At
        Duration = 0.0
    }
    
    /// Initializer.
    /// - Parameter WithColor: Color stop color.
    /// - Parameter At: Color stop location.
    /// - Parameter ForDuration: Number of seconds to run the animation.
    init(WithColor: UIColor, At: CGFloat, ForDuration: Double)
    {
        _Color = WithColor
        Stop = At
        Duration = ForDuration
    }
    
    /// Holds the color stop color.
    private var _Color: UIColor = UIColor.white
    /// Get or set the color for the color stop. Defaults to White.
    public var Color: UIColor
    {
        get
        {
            return _Color
        }
        set
        {
            _Color = newValue
        }
    }
    
    /// Holds the color stop location.
    private var _Stop: CGFloat = 0.0
    /// Get or set the location of the gradient stop. Defaults to 0.0. This is a normalized value.
    public var Stop: CGFloat
    {
        get
        {
            return _Stop
        }
        set
        {
            _Stop = newValue
        }
    }
    
    /// Holds the duration of the animation.
    private var _Duration: Double = 6.0
    /// Get or set the duration of the anißmation. Unit is seconds. Specify 0.0 to disable animation for this particular
    /// gradient stop. Defaults to 6.0 seconds. Faster durations increase CPU load.
    public var Duration: Double
    {
        get
        {
            return _Duration
        }
        set
        {
            _Duration = newValue
        }
    }
}
