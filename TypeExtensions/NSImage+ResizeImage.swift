//
//  NSImage+ResizeImage.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

#if false
/// Extensions to NSImage.
extension NSImage
{
    /// Returns a resized image from the instance image.
    /// - Note:
    ///   - See [How to Resize NSImage](https://stackoverflow.com/questions/11949250/how-to-resize-nsimage/30422317#30422317)
    /// - Parameter Width: New width of the image.
    /// - Parameter Height: New height of the image.
    /// - Returns: Resized image.
    func ResizeImage(Width: CGFloat, Height: CGFloat) -> NSImage
    {
        let Image = NSImage(size: CGSize(width: Width, height: Height))
        Image.lockFocus()
        let Context = NSGraphicsContext.current
        Context?.imageInterpolation = .high
        self.draw(in: NSMakeRect(0, 0, Width, Height), from: NSMakeRect(0, 0, size.width, size.height),
                  operation: .copy, fraction: 1)
        Image.unlockFocus()
        return Image
    }
}
#endif
