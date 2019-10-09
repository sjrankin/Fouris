//
//  GradientPickerProtocol.swift
//  Fouris
//  Adapted from BumpCamera.
//
//  Created by Stuart Rankin on 9/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for handling gradients with respect to editing.
protocol GradientPickerProtocol: class
{
    /// Called when a gradient has been edited.
    /// - Parameter Edited: The edited gradient. If nil, the edit operation was canceled.
    /// - Parameter Tag: Caller-supplied tag value returned to the caller. Can be used to
    ///                  keep track of multiple gradient editing requests.
    func EditedGradient(_ Edited: String?, Tag: Any?)
    
    /// Called to set a gradient to edit.
    /// - Parameter Edited: The gradient to edit. If nil, default gradient will be used.
    /// - Parameter Tag: Tag value that is echoed back on a corresponding `EditedGradient` call.
    func GradientToEdit(_ Edited: String?, Tag: Any?)

    /// Set a color stop.
    /// - Parameter StopColorIndex: The color index for the stop.
    func SetStop(StopColorIndex: Int)
}
