//
//  ColorButton.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Implements a color button where the contents of the button consist of a solid color.
/// - Note: The button type **must** be set to Custom in the interface builder or the colors will not show up correctly.
class ColorButton: UIButton
{
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.setTitle("", for: .normal)
        self.backgroundColor = UIColor.clear
        ButtonColor = UIColor.green
    }
    
    /// Holds the color of the button. Defaults to white.
    private var _ButtonColor: UIColor = UIColor.white
    /// Get or set the color of the button.
    @IBInspectable public var ButtonColor: UIColor
        {
        get
        {
            return _ButtonColor
        }
        set
        {
            _ButtonColor = newValue
            SetButtonColor(To: newValue)
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
    
    /// Set the color of the button. A checkerboard pattern is displayed under the color for
    /// colors with an alpha less than 1.0.
    /// -Parameter To: The new color.
    public func SetButtonColor(To: UIColor)
    {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.black.cgColor
        /*
        let Size = self.bounds.size
        let ColorImage = UIImage(Color: To, Size: Size)
        self.setImage(ColorImage, for: .normal)
 */
        self.setImage(MakeColorImage(WithColor: To), for: .normal)
    }
    
    /// Creates an image of the color with a checkerboard background to show transparency.
    public func MakeColorImage(WithColor: UIColor) -> UIImage
    {
        let CheckerLayer = CALayer()
        CheckerLayer.isOpaque = false
        CheckerLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        CheckerLayer.name = "CheckerBoard"
        let CheckerImage = UIImage(named: "Checkerboard1024")?.cgImage
        CheckerLayer.contents = CheckerImage
        CheckerLayer.zPosition = -200
        CheckerLayer.contentsGravity = CALayerContentsGravity.topLeft
        let ColorLayer = CALayer()
        ColorLayer.isOpaque = false
        ColorLayer.name = "ColorLayer"
        ColorLayer.zPosition = -100
        ColorLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        ColorLayer.backgroundColor = WithColor.cgColor
        let FinalLayer = CALayer()
        FinalLayer.isOpaque = false
        FinalLayer.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height)
        FinalLayer.addSublayer(CheckerLayer)
        FinalLayer.addSublayer(ColorLayer)
        
        UIGraphicsBeginImageContext(self.bounds.size)
        FinalLayer.render(in: UIGraphicsGetCurrentContext()!)
        let FinalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return FinalImage!
    }
}
