//
//  UIButtonExtensions.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/13/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Extensions for UIButton.
extension UIButton
{
    /// Flashes the background of the button.
    ///
    /// - Parameters:
    ///   - Duration: The duration of the flash in seconds.
    ///   - Color: The color of the flash.
    func Flash(Duration: Double = 0.5, Color: UIColor = UIColor.gray)
    {
        let OldColor = self.backgroundColor
        self.backgroundColor = Color
        let _ = Timer.scheduledTimer(withTimeInterval: Duration, repeats: false)
        {
            (TheTimer) in
            self.backgroundColor = OldColor
        }
    }
    
    /// Highlights the button by changing the image for the specified amount of time.
    ///
    /// - Parameters:
    ///   - WithImage: Name of the highlight image. Must be in the assets folder.
    ///   - ForSeconds: Number of seconds to show the highlight image.
    ///   - OriginalName: Name of the original image (for restoration) image. Must be in
    ///                   the assets folder.
    func Highlight(WithImage: String, ForSeconds: Double, OriginalName: String)
    {
        self.setImage(UIImage(named: WithImage), for: UIControl.State.normal)
        let _ = Timer.scheduledTimer(withTimeInterval: ForSeconds, repeats: false)
        {
            (TheTimer) in
            self.setImage(UIImage(named: OriginalName), for: UIControl.State.normal)
        }
    }
}

