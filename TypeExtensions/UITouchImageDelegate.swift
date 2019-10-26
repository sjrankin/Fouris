//
//  UITouchImageDelegate.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/24/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol to receive messages of pressed motion buttons from **UITouchImage** buttons.
protocol UITouchImageDelegate: class
{
    /// Sent when the user presses then releases a **UITouchImage** button.
    /// - Parameter sender: The **UITouchImage** button the was pressed.
    /// - Parameter PressedButton: The logical button that was pressed.
    func Touched(_ sender: UITouchImage, PressedButton: UIMotionButtons)
}

/// Logical UI motion buttons implemented with **UITouchImage**.
enum UIMotionButtons: Int, CaseIterable
{
    /// Unknown motion button.
    case Unknown = 0
    /// Move piece left button.
    case MoveLeft = 1
    /// Move piece right button.
    case MoveRight = 2
    /// Move piece up button.
    case MoveUp = 3
    /// Move piece down button.
    case MoveDown = 4
    /// Drop piece to bottom button.
    case DropDown = 5
    /// Discard piece button.
    case FlyAway = 6
    /// Rotate piece left button.
    case RotateLeft = 7
    /// Rotate piece right button.
    case RotateRight = 8
}
