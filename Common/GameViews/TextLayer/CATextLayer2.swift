//
//  CATextLayer2.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Version of CATextLayer that automatically vertically centers text in its bounds.
/// - Note:
///  - See [Vertically Align Text in a CATextLayer](https://stackoverflow.com/questions/4765461/vertically-align-text-in-a-catextlayer)
class CATextLayer2: CATextLayer
{
    /// Draw the text. This override will center the text vertically in its bounds
    /// - Parameter in: The context in which to draw.
    override open func draw(in ctx: CGContext)
    {
        var YDiff: CGFloat = 0.0
        var FontSize: CGFloat = 0.0
        let Height = self.bounds.height
        switch VerticalAlignment
        {
            case .Center:
                if let AttributedString = self.string as? NSAttributedString
                {
                    FontSize = AttributedString.size().height
                    YDiff = (Height - FontSize) / 2
                }
                else
                {
                    FontSize = self.fontSize
                    YDiff = (Height - FontSize) / 2 - FontSize / 10
            }
            
            case .Top:
                if let AttributedString = self.string as? NSAttributedString
                {
                    FontSize = AttributedString.size().height
                    YDiff = Height - FontSize
                }
                else
                {
                    FontSize = self.fontSize
                    YDiff = (Height - FontSize) - FontSize / 10
            }
            
            case .Bottom:
                if let AttributedString = self.string as? NSAttributedString
                {
                    FontSize = AttributedString.size().height
                    YDiff = FontSize
                }
                else
                {
                    FontSize = self.fontSize
                    YDiff = Height - FontSize / 10
            }
        }
        ctx.saveGState()
        ctx.translateBy(x: 0.0, y: YDiff)
        super.draw(in: ctx)
        ctx.restoreGState()
    }
    
    /// Hold the vertical alignment mode.
    private var _VerticalAlignment: VerticalAlignments = .Center
    /// Get or set the vertical alignment mode.
    public var VerticalAlignment: VerticalAlignments
    {
        get
        {
            return _VerticalAlignment
        }
        set
        {
            _VerticalAlignment = newValue
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
}

/// Vertical alignment modes for **CATextLayer2**.
/// - **Top**: Align to the top of the layer (where top is the closest to the top of the screen).
/// - **Center**: Align to the center of the layer.
/// - **Bottom**: Align to the bottom of the layer (where bottom is the closest to the bottom of the screen).
enum VerticalAlignments: String, CaseIterable
{
    case Top = "Top"
    case Center = "Center"
    case Bottom = "Bottom"
}
