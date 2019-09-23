//
//  SettingsChangedProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/23/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol for notification of settings changes.
protocol SettingsChangedProtocol: class
{
    /// Called when certain setting fields are changed.
    /// - Parameter Field: Enum indicating which field changed.
    /// - Parameter NewValue: Changed setting value.
    func SettingChanged(Field: SettingsFields, NewValue: Any)
}

/// Enum that indicates which field was changed.
/// - **ShowFPSInUI**: The show the game view frames/second value in the UI flag.
/// - **ShowCameraControls**: Show camera controls in the UI.
/// - **ShowMotionControls**: Show the motion control UI.
/// - **ShowTopToolbar**: Show the top toolbar UI.
enum SettingsFields: String, CaseIterable
{
    case ShowFPSInUI = "ShowFPSInUI"
    case ShowCameraControls = "ShowCameraControls"
    case ShowMotionControls = "ShowMotionConrols"
    case ShowTopToolbar = "ShowTopToolvar"
}
