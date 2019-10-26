//
//  UITouchImage.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/24/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Slight modification of **UIImageView** to intercept press gestures and report them (via a delegate) as button presses.
/// - Note:
///   - In order to work, **both** the image and highlight image fields must be set.
///   - **super.image** is used as the normal, non-pressed-state image and **super.highlightedImage** is used as the pressed-state
///     image.
///   - UIButton seems to have severe issues with resizing images from within the interface builder. Rather than fight
///     the tools and UIButton, I wrote this class.
class UITouchImage: UIImageView
{
    /// Delegate that receives notifications of touches.
    public weak var Delegate: UITouchImageDelegate? = nil
    
    /// Initializer.
    /// - Parameter frame: The control's frame.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter image: The initial image to display.
    override init(image: UIImage?)
    {
        super.init(image: image)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter image: The initial image to display.
    /// - Parameter highlightedImage: The highlighted image.
    override init(image: UIImage?, highlightedImage: UIImage?)
    {
        super.init(image: image, highlightedImage: highlightedImage)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Initialize the super control. Forces user interaction to be enabled.
    private func Initialize()
    {
        OriginalSize = CGSize(width: super.frame.width, height: super.frame.height)
        SizeFor(Device: .pad, Square: 48.0)
        SizeFor(Device: .phone, Square: 32.0)
        super.isUserInteractionEnabled = true
        super.contentMode = .scaleAspectFit
        let PressGesture = UILongPressGestureRecognizer(target: self, action: #selector(WasPressed))
        PressGesture.minimumPressDuration = 0.05
        super.addGestureRecognizer(PressGesture)
        #if true
        if OriginalSize.width < 1000.0
        {
            ForceSize(Device: .phone)
        }
        #else
        UpdateForDevice()
        #endif
    }
    
    /// Original size of the control.
    private var OriginalSize: CGSize!
    
    /// Updates the size of the control based on the device it is running on and the preset size for the given device.
    /// If there is no size specified for a given device, the original size is used.
    private func UpdateForDevice()
    {
        let Device = UIDevice.current.userInterfaceIdiom
        if let SquareSize = DeviceImageSizes[Device]
        {
            super.frame = CGRect(origin: CGPoint(x: super.frame.minX, y: super.frame.minY),
                                 size: CGSize(width: SquareSize, height: SquareSize))
        }
        else
        {
            super.frame = CGRect(origin: CGPoint(x: super.frame.minX, y: super.frame.minY),
                                 size: OriginalSize)
        }
    }
    
    /// Force the size of the image with the passed idiom type.
    /// - Parameter Device: The device type to use to set the image size.
    private func ForceSize(Device: UIUserInterfaceIdiom)
    {
        if let SquareSize = DeviceImageSizes[Device]
        {
            super.frame = CGRect(origin: CGPoint(x: super.frame.minX, y: super.frame.minY),
                                 size: CGSize(width: SquareSize, height: SquareSize))
        }
    }
    
    /// Adds a square size (on the assumption all images are square) for a given device. Call this function for each device
    /// type you want to have a specific size for.
    /// - Note: Any device type that does not have a size set here will result in the size of the control being reset to its
    ///         original size.
    /// - Note: If you assign a size to an already existing size for a device type, the new size will overwrite the old size.
    /// - Note: Size changes takes effect immediately.
    /// - Note: Call **ClearSizes** to remove all sizing.
    /// - Parameter Device: The device type whose size will be set.
    /// - Parameter Square: The size of the control as a square.
    public func SizeFor(Device: UIUserInterfaceIdiom, Square: CGFloat)
    {
        DeviceImageSizes[Device] = Square
        UpdateForDevice()
    }
    
    /// Removes all sizes from the device: size dictionary.
    public func ClearSizes()
    {
        DeviceImageSizes.removeAll()
    }
    
    /// Holds a dictionary of device types to sizes.
    private var DeviceImageSizes = [UIUserInterfaceIdiom: CGFloat]()
    
    /// Handles press gesture recognition actions.
    /// - Parameter sender: The press gesture recognizer.
    @objc public func WasPressed(sender: UILongPressGestureRecognizer)
    {
        if sender.state == .began
        {
            _IsPressed = true
            Highlight()
        }
        if sender.state == .ended
        {
            _IsPressed = false
            DeHighlight()
            let Tag = self.tag
            let LogicalButton = UIMotionButtons(rawValue: Tag)
            Delegate?.Touched(self, PressedButton: LogicalButton!)
        }
    }
    
    /// Highlight the image to indicate it was pressed and the user is still holding it down.
    /// - Note: This function is supplied as a way to programmatically simulate a button press. If **ForDuration** is greater
    ///         than 0.0, this function will automatically call **DeHighlight** after waiting for the specified amount of time.
    /// - Parameter ForDuration: The amount of time to wait before automatically calling **DeHighlight**. If this value
    ///                          is 0.0, **DeHighlight** is *not* called. This value has units of seconds. Default value is 0.0
    public func Highlight(ForDuration: Double = 0.0)
    {
        OperationQueue.main.addOperation
            {
                super.isHighlighted = true
        }
        if ForDuration > 0.0
        {
            OperationQueue.main.addOperation
                {
                    UIView.animate(withDuration: ForDuration,
                                   animations: {}, completion:
                        {
                            _ in
                            self.DeHighlight()
                    })
            }
        }
    }
    
    /// Highlights the button by changing the image for the specified amount of time.
    ///
    /// - Parameters:
    ///   - WithImage: Name of the highlight image. Must be in the assets folder.
    ///   - ForSeconds: Number of seconds to show the highlight image.
    ///   - OriginalName: Name of the original image (for restoration) image. Must be in
    ///                   the assets folder.
    public func Highlight(WithImage: String, ForSeconds: Double, OriginalName: String)
    {
        self.image = UIImage(named: WithImage)
        let _ = Timer.scheduledTimer(withTimeInterval: ForSeconds, repeats: false)
        {
            (TheTimer) in
            self.image = UIImage(named: OriginalName)
        }
    }
    
    /// De-highlights the image, simulating releasing the button.
    /// - Note: This function is supplied as a way to programmatically simulate a button release.
    public func DeHighlight()
    {
        OperationQueue.main.addOperation
            {
                super.isHighlighted = false
                self._IsPressed = false
        }
    }
    
    /// Holds the is pressed state.
    private var _IsPressed: Bool = false
    /// Get the button pressed state.
    public var IsPressed: Bool
    {
        get
        {
            return _IsPressed
        }
    }
}

