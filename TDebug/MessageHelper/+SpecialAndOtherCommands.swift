//
//  +SpecialAndOtherCommands.swift
//  TDDebug
//
//  Created by Stuart Rankin on 6/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

extension MessageHelper
{
    // MARK: Special and other command encoding commands.
    
    /// Make a special command. (Special commands are used to control the UI of the host.)
    ///
    /// - Parameter Command: The special command to send.
    /// - Returns: Command string with the special command embedded in it.
    public static func MakeSpecialCommand(_ Command: SpecialCommands) -> String
    {
        let SCmd = "SpecialCommand=\(SpecialCommmandIndicators[Command]!)"
        let Final = GenerateCommand(Command: .SpecialCommand, Prefix: PrefixCode, Parts: [SCmd])
        return Final
    }
    
    /// Make a command that resets the debug UI.
    /// - Returns: Command string to reset the remote debug UI.
    public static func MakeResetTDebugUICommand() -> String
    {
        let Final = GenerateCommand(Command: .ResetTDebugUI, Prefix: PrefixCode, Parts: [""])
        return Final
    }
    
    // MARK: Special and other command decoding.
    
    public static func DecodeSpecialCommand(_ Raw: String) -> SpecialCommands
    {
        let Params = GetParameters(From: Raw, ["SpecialCommand"])
        if let SCmd = Params["SpecialCommand"]
        {
            for (Command, Indicator) in SpecialCommmandIndicators
            {
                if Indicator.lowercased() == SCmd.lowercased()
                {
                    return Command
                }
            }
        }
        return SpecialCommands.Unknown
    }
}
