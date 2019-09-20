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
    func DrawGradient()
    {
        #if true
        let GradientAsImage = GradientManager.CreateGradientImageWithMetadata(From: _GradientDescriptor,
                                                                              WithFrame: GradientImage.bounds)
        #else
        let GradientAsImage = GradientManager.CreateGradientImage(From: _GradientDescriptor,
                                                                  WithFrame: GradientImage.bounds,
                                                                  IsVertical: _IsVertical,
                                                                  ReverseColors: _ReverseColors)
        #endif
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
}
