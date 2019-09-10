//
//  +MainSlideInUI2.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Extension to **CommonViewController** to handle events and user interactions related to the slide in view.
extension MainViewController2
{
    public func InitializeSlideIn()
    {
        SlideInSubView.layer.borderColor = ColorServer.CGColorFrom(ColorNames.ReallyDarkGray)
    }
}

/// Command tokens for slide-in UI commands.
/// - Note: The commands here are not necessarily in the same order as presented to the user.
/// - **NoCommand**: Default command which basically means the user selected something we don't recognize. This
///                  should never be sent but is here just in case...
/// - **AboutCommand**: Show the about dialog.
/// - **SelectGameCommand**: Select the game type and style.
/// - **SettingsCommand**: Run the general purpose settings dialog.
/// - **ThemeCommand**: Run the theme dialog.
enum SlideInCommands
{
    case NoCommand
    case AboutCommand
    case SelectGameCommand
    case SettingsCommand
    case ThemeCommand
}
