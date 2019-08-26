//
//  MainSlideInView2.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages those functions of the slide-in view that do not require direct access to UI interaction (because Xcode
/// doesn't like secondary windows in a main window).
/// - Note: This class assumes the view is overlapping the main storyboard at start-up time and will move
///         it offscreen to the left.
class MainSlideInView2: UIView
{
    /// Initializer.
    /// - Parameter frame: The frame to use to initialize the view.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize(HardwareIdiom: UIDevice.current.userInterfaceIdiom)
    }
    
    /// Initializer. Required.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize(HardwareIdiom: UIDevice.current.userInterfaceIdiom)
    }
    
    /// Initializes base visuals and location.
    /// - Parameter HardwareIdiom: The general type of device we're running on.
    private func Initialize(HardwareIdiom: UIUserInterfaceIdiom)
    {
        if HardwareIdiom == .pad
        {
            VisibleFrame = CGRect(x: 5, y: 70, width: 300, height: 500)
            HiddenFrame = CGRect(x: -320, y: 70, width: 300, height: 500)
        }
        else
        {
            VisibleFrame = CGRect(x: 5, y: 70, width: 250, height: 400)
            HiddenFrame = CGRect(x: -280, y: 70, width: 250, height: 400)
        }
        self.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 2.0
        _IsVisible = false
        self.alpha = 0.0
        self.isUserInteractionEnabled = false
    }
    
    var VisibleFrame: CGRect!
    var HiddenFrame: CGRect!
    
    /// Slide the main view into visibility.
    /// - Parameter SlideInDuration: The number of seconds to take to slide the view into place. Defaults to 0.4
    ///                              seconds.
    public func ShowMainSlideIn(_ SlideInDuration: Double = 0.2)
    {
        #if true
        UIView.animate(withDuration: SlideInDuration,
                       animations:
            {
                self.alpha = 1.0
        }, completion:
            {
                _ in
                self.isUserInteractionEnabled = true
                self._IsVisible = true
        })
        #else
        print("Moving slide in to VisibleFrame: \((VisibleFrame)!)")
        UIView.animate(withDuration: SlideInDuration, delay: 0.0,
                       options: [.curveEaseOut],
                       animations:
            {
                self.frame = self.VisibleFrame
        }, completion:
            {
                _ in
                self._IsVisible = true
        }
        )
        #endif
    }
    
    /// Hide the main view by sliding it off-screen to the left.
    /// - Parameter SlideOutDuration: The number of seconds to take to slide the view off-screen. Defaults to
    ///                               0.25 seconds.
    public func HideMainSlideIn(_ SlideOutDuration: Double = 0.3)
    {
        #if true
        UIView.animate(withDuration: SlideOutDuration,
                       animations:
            {
                self.alpha = 0.0
        }, completion:
            {
                _ in
                self.isUserInteractionEnabled = false
                self._IsVisible = false
        })
        #else
        print("Moving slide in to HiddenFrame: \((HiddenFrame)!)")
        UIView.animate(withDuration: SlideOutDuration, delay: 0.0,
                       options:[.curveEaseIn],
                       animations:
            {
                self.frame = self.HiddenFrame
        }, completion:
            {
                _ in
                self._IsVisible = false
        }
        )
        #endif
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
