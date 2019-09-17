//
//  ColorSwatch.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/17/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Draws a color swatch color in a UIView.
/// - Note:
///   - This class assumes all color layers (except the bottom-most) are capable of having alpha values less than 1.0.
@IBDesignable class ColorSwatchColor: UIView
{
    /// Default initializer.
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
    func Initialize()
    {
        UpdateUI()
    }
    
    /// When the parent control's bounds are changed, we need to redraw the control.
    override var bounds: CGRect
    {
        didSet
        {
            UpdateUI()
        }
    }
    
    /// Update the UI by clearing all layers and redrawing everything.
    private func UpdateUI()
    {
        self.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        self.clipsToBounds = true
        self.isOpaque = false
        self.layer.borderWidth = _BorderWidth
        self.layer.cornerRadius = _CornerRadius
        self.layer.borderColor = _BorderColor.cgColor
        self.layer.addSublayer(MakeCheckerLayer())
        self.layer.addSublayer(MakeColorLayer())
    }
    
    /// Force a redraw of the control.
    public func Redraw()
    {
        UpdateUI()
    }
    
    /// Make a checkerboard layer to show alpha levels of colors above it.
    /// - Returns: Layer with a black and white checkerboard image.
    private func MakeCheckerLayer() -> CALayer
    {
        let Layer = CALayer()
        Layer.name = "CheckerBoard"
        let CheckerImage = UIImage(named: "Checkerboard1024")?.cgImage
        Layer.frame = self.bounds
        Layer.contents = CheckerImage
        Layer.zPosition = 0
        Layer.contentsGravity = CALayerContentsGravity.topLeft
        return Layer
    }
    
    /// Make a color layer. Sits on top of the control.
    /// - Returns: Layer with the current `TopColor`.
    private func MakeColorLayer() -> CALayer
    {
        let Layer = CALayer()
        Layer.name = "ColorLayer"
        Layer.isOpaque = false
        Layer.frame = self.bounds
        Layer.zPosition = 100
        Layer.backgroundColor = _TopColor.cgColor
        return Layer
    }
    
    /// Holds the top-most color.
    private var _TopColor: UIColor = UIColor.white
    {
        didSet
        {
            UpdateUI()
        }
    }
    /// Get or set the top color.
    @IBInspectable public var TopColor: UIColor
    {
        get
        {
            return _TopColor
        }
        set
        {
            _TopColor = newValue
        }
    }
    
    /// Holds the border color.
    private var _BorderColor: UIColor = UIColor.black
    {
        didSet
        {
            UpdateUI()
        }
    }
    /// Get or set the border color.
    @IBInspectable public var BorderColor: UIColor
        {
        get
        {
            return _BorderColor
        }
        set
        {
            _BorderColor = newValue
        }
    }
    
    /// Holds the corner radius.
    private var _CornerRadius: CGFloat = 5.0
    {
        didSet
        {
            UpdateUI()
        }
    }
    /// Get or set the border's corner radius.
    @IBInspectable public var CornerRadius: CGFloat
        {
        get
        {
            return _CornerRadius
        }
        set
        {
            _CornerRadius = newValue
        }
    }
    
    /// Holds the border width.
    private var _BorderWidth: CGFloat = 0.5
    {
        didSet
        {
            UpdateUI()
        }
    }
    /// Get or set the border's width.
    @IBInspectable public var BorderWidth: CGFloat
        {
        get
        {
            return _BorderWidth
        }
        set
        {
            _BorderWidth = newValue
        }
    }
}
