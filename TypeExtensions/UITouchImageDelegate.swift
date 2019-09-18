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
/// - **Unknown**: Unknown button. Ignore or throw a fatal error.
/// - **MoveLeft**: The move left button.
/// - **MOveRight**: The move right button.
/// - **MoveUp**: The move up button.
/// - **MoveDown**: The move down button.
/// - **DropDown**: The drop down button.
/// - **FlyAway**: The fly away (move rapidly upwards) button.
/// - **RotateLeft**: The rotate left button.
/// - **RotateRight**: the rotate right button.
enum UIMotionButtons: Int, CaseIterable
{
    case Unknown = 0
    case MoveLeft = 1
    case MoveRight = 2
    case MoveUp = 3
    case MoveDown = 4
    case DropDown = 5
    case FlyAway = 6
    case RotateLeft = 7
    case RotateRight = 8
}
