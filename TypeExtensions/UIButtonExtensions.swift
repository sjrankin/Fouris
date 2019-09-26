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
    
    /// Pulsates (enlarges and shrinks) the instance button.
    /// - Note:
    ///    - Be sure to leave room for the largest size of the button or depending on your view, things
    ///      will end up looking rather odd.
    ///    - See [Scale UIButton Animation Swift](https://stackoverflow.com/questions/31320819/scale-uibutton-animation-swift)
    /// - Parameter Duration: The amount of time in seconds for the entire animation.
    /// - Parameter From: Starting scale factor (where 1.0 is the original size).
    /// - Parameter To: Ending scale factor (where 1.0 is the original size).
    func StartPulsation(Duration: Double = 0.5, From: Double = 0.75, To: Double = 1.25)
    {
        let Pulse = CASpringAnimation(keyPath: "transform.scale")
        Pulse.duration = Duration
        Pulse.fromValue = From
        Pulse.toValue = To
        Pulse.repeatCount = Float.greatestFiniteMagnitude
        Pulse.autoreverses = true
        Pulse.initialVelocity = 0.5
        Pulse.damping = 1.0
        layer.add(Pulse, forKey: "Pulse")
    }
    
    /// Scales the instance button to the given scaling factor.
    /// - Parameter Duration: The amount of time in seconds for the scaling animation to take effect.
    /// - Parameter To: The destination scaling factor (where 1.0 is the original size).
    func Scale(Duration: Double = 0.0, To: Double = 1.0)
    {
        let Scale = CASpringAnimation(keyPath: "transform.scale")
        Scale.duration = Duration
        Scale.toValue = To
        Scale.repeatCount = 0
        Scale.initialVelocity = 0.5
        Scale.damping = 1.0
        layer.add(Scale, forKey: "Scale")
    }
    
    /// Starts cycling the `tintColor` of the instance button to the specified color. The color of
    /// `tintColor` will cycle through the original color to `To`.
    /// - Parameter Duration: Number of seconds for one cycle of animation.
    /// - Parameter To: The color to cycle the `tintColor` to.
    func StartColorCycling(Duration: Double = 0.61, To: UIColor = UIColor.red)
    {
        UIView.animate(withDuration: Duration, delay: 0.0,
                       options: [.autoreverse, .repeat],
                       animations: {
                        self.tintColor = To
        },
                       completion: nil)
    }
    
    /// Remove all animations from the instance button.
    func StopAnimations()
    {
        layer.removeAllAnimations()
    }
}

