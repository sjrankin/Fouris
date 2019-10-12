//
//  GradientSwatch.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Simple control to display a gradient in a rectangle.
/// - Note: The gradient is converted to a UIImage and display in a UIImageView, which is a sub-view of the main UIView.
@IBDesignable class GradientSwatch: UIView
{
    /// Holds the delegate to the observer, if any.
    weak var ObserverDelegate: GradientObserver? = nil
    
    /// Initializer.
    /// - Parameter frame: Frame of the control.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Initialize the control.
    private func Initialize()
    {
        self.clipsToBounds = true
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.5
        self.layer.cornerRadius = 5.0
        GradientImage = UIImageView(frame: self.bounds)
        self.addSubview(GradientImage)
    }
    
    /// Holds the control that does the actual display of the gradient.
    private var GradientImage: UIImageView!
    
    /// Every time the bounds change, we need to redraw the gradient.
    override var bounds: CGRect
        {
        didSet
        {
            DrawGradient()
        }
    }
    
    /// Draw the gradient.
    /// - Parameter WithOverride: If present, the gradient description to use. Otherwise, the backing value of `GradientDescriptor`
    ///                           is used.
    func DrawGradient(WithOverride: String? = nil)
    {
        let Descriptor: String = WithOverride == nil ? _GradientDescriptor : WithOverride!
        let GradientAsImage = GradientManager.CreateGradientImageWithMetadata(From: Descriptor,
                                                                              WithFrame: GradientImage.bounds)
        GradientImage.image = GradientAsImage
    }
    
    /// Holds the current gradient descriptor.
    private var _GradientDescriptor: String = "(White)@(0.0),(Black)@(1.0)"
    {
        didSet
        {
            DrawGradient()
        }
    }
    /// Get or set the gradient descriptor.
    /// - Note: Gradient descriptors are strings made up of tuples of values, which each tuple indicating a color stop. Each tuple
    ///         has the format `(color)@(location)` where `color` is a color name or color value and `location` is a normal value
    ///         indicating where in the gradient the color falls. Color tuples are separated by commas.
    @IBInspectable public var GradientDescriptor: String
        {
        get
        {
            return _GradientDescriptor
        }
        set
        {
            _GradientDescriptor = newValue
        }
    }
    
    /// Holds the vertical flag.
    private var _IsVertical: Bool = false
    {
        didSet
        {
            DrawGradient()
        }
    }
    /// Get or set the vertical flag, indicating whether the gradient is horizontal or vertical.
    @IBInspectable public var IsVertical: Bool
        {
        get
        {
            return _IsVertical
        }
        set
        {
            _IsVertical = newValue
        }
    }
    
    /// Holds the reverse colors flag.
    private var _ReverseColors: Bool = false
    {
        didSet
        {
            DrawGradient()
        }
    }
    /// Holds the reverse colors flag.
    @IBInspectable public var ReverseColors: Bool
        {
        get
        {
            return _ReverseColors
        }
        set
        {
            _ReverseColors = newValue
        }
    }
    
    private func UpdateHueShifting()
    {
        if _HueShiftDuration <= 0.0 || !_EnableHueShifting
        {
            HueTimer?.invalidate()
            HueTimer = nil
            ShiftingStops.removeAll()
            DrawGradient()
            return
        }
        ShiftingStops = GradientManager.ParseGradient(_GradientDescriptor, Vertical: &ShiftVertical, Reverse: &ShiftReversed)
        let Interval = HueShiftDuration / 360.0
        HueTimer = Timer.scheduledTimer(timeInterval: Interval, target: self, selector: #selector(UpdateShiftGradient),
                                        userInfo: nil, repeats: true)
    }
    
    var ShiftVertical: Bool = false
    var ShiftReversed: Bool = false
    
    var ShiftingStops: [(UIColor, CGFloat)] = [(UIColor, CGFloat)]()
    
    private var HueTimer: Timer? = nil
    
    @objc func UpdateShiftGradient()
    {
        var NewStops = [(UIColor, CGFloat)]()
        for (Working, Stop) in ShiftingStops
        {
            var Hue = Working.Hue
            let Saturation = Working.Saturation
            let Brightness = Working.Brightness
            let Alpha = Working.Alpha()
            Hue = Hue + (1.0 / 360.0)
            if Hue > 1.0
            {
                Hue = 0.0
            }
            if Hue < 0.0
            {
                Hue = 1.0
            }
            let FinalColor = UIColor(hue: Hue, saturation: Saturation, brightness: Brightness, alpha: Alpha)
            NewStops.append((FinalColor, Stop))
        }
        let NewGradient = GradientManager.AssembleGradient(NewStops, IsVertical: ShiftVertical, Reverse: ShiftReversed)
        ShiftingStops = NewStops
        DrawGradient(WithOverride: NewGradient)
        ObserverDelegate?.GradientChanged(NewGradient: NewGradient)
    }
    
    private var _EnableHueShifting: Bool = false
    {
        didSet
        {
            UpdateHueShifting()
        }
    }
    @IBInspectable public var EnableHueShifting: Bool
        {
        get
        {
            return _EnableHueShifting
        }
        set
        {
            _EnableHueShifting = newValue
        }
    }
    
    private var _HueShiftDuration: Double = 60.0
    {
        didSet
        {
            UpdateHueShifting()
        }
    }
    @IBInspectable public var HueShiftDuration: Double
        {
        get
        {
            return _HueShiftDuration
        }
        set
        {
            _HueShiftDuration = newValue
        }
    }
}
