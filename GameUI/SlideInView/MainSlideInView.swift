//
//  MainSlideInView.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/22/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages those functions of the slide-in view that do not require direct access to UI interaction (because Xcode
/// doesn't like secondary windows in a main window).
/// - Note: This class assumes the view is overlapping the main storyboard at start-up time and will move
///         it offscreen to the left.
class MainSlideInView: UIView
{
    /// Initializer.
    /// - Parameter frame: The frame to use to initialize the view.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    /// Initializer. Required.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Initializes base visuals and location.
    private func Initialize()
    {
        self.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 2.0
        _IsVisible = false
        let CurrentFrame = self.frame
        self.frame = CGRect(x: -360, y: CurrentFrame.minY, width: CurrentFrame.width, height: CurrentFrame.height)
    }
    
    /// Slide the main view into visibility.
    /// - Parameter SlideInDuration: The number of seconds to take to slide the view into place. Defaults to 0.4
    ///                              seconds.
    public func ShowMainSlideIn(_ SlideInDuration: Double = 0.4)
    {
        let CurrentFrame = self.frame
        let VisibleFrame = CGRect(x: 5, y: CurrentFrame.minY, width: CurrentFrame.width, height: CurrentFrame.height)
        UIView.animate(withDuration: SlideInDuration, delay: 0.0,
                       options: [.curveEaseOut],
                       animations:
            {
                self.frame = VisibleFrame
        }, completion:
            {
                _ in
                self._IsVisible = true
        }
        )
    }
    
    /// Hide the main view by sliding it off-screen to the left.
    /// - Parameter SlideOutDuration: The number of seconds to take to slide the view off-screen. Defaults to
    ///                               0.25 seconds.
    public func HideMainSlideIn(_ SlideOutDuration: Double = 0.25)
    {
        let CurrentFrame = self.frame
        let HiddenFrame = CGRect(x: -360, y: CurrentFrame.minY, width: CurrentFrame.width, height: CurrentFrame.height)
        UIView.animate(withDuration: SlideOutDuration, delay: 0.0,
                       options:[.curveEaseIn],
                       animations:
            {
                self.frame = HiddenFrame
        }, completion:
            {
                _ in
                self._IsVisible = false
        }
        )
    }
    
    /// Holds the view is visible flag.
    private var _IsVisible: Bool = false
    /// Get the view is visible flag. You can set this property indirectly via the **ShowMainSlideIn** or
    /// **HideMainSlideIn** functions.
    public var IsVisible: Bool
    {
        get
        {
            return _IsVisible
        }
    }
}
