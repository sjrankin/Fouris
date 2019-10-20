//
//  PopOverProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol for the communication between the pop-over menu and the main UI.
protocol PopOverProtocol: class
{
    /// Requests the main UI to run the command selected by the user.
    /// - Parameter Command: The command to run.
    func RunPopOverCommand(_ Command: PopOverCommands)
    
    /// Reset the main button to its normal state.
    func ResetMainButton()
}
