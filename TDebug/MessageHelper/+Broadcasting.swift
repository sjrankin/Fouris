//
//  +Broadcasting.swift
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
    // MARK: - Broadcasting encoding commands.
    
    /// Create a broadcast text message command.
    /// - Parameters:
    ///   - From: The peer that is broadcasting the message.
    ///   - Message: The text message to send.
    /// - Returns: Command string to broadcast a message.
    public static func MakeBroadcastMessage(From: MCPeerID, Message: String) -> String
    {
        return MakeBroadcastMessage(From: From.displayName, Message: Message)
    }
    
    /// Create a broadcast text message command.
    /// - Parameters:
    ///   - From: The peer that is broadcasting the message.
    ///   - Message: The text message to send.
    /// - Returns: Command string to broadcast a message.
    public static func MakeBroadcastMessage(From: String, Message: String) -> String
    {
        let Source = "From=\(From)"
        let Msg = "Message=\(Message)"
        let Final = GenerateCommand(Command: .BroadcastMessage, Prefix: PrefixCode, Parts: [Source, Msg])
        return Final
    }
    
    /// Create a broadcast command command.
    /// - Parameters:
    ///   - From: The peer that is broadcasting the message.
    ///   - PreformattedCommand: The pre-formatted command to broadcast.
    /// - Returns: Command string to broadcast as a command.
    public static func MakeBroadcastCommand(From: MCPeerID, PreformattedCommand: String) -> String
    {
        return MakeBroadcastCommand(From: From.displayName, PreformattedCommand: PreformattedCommand)
    }
    
    /// Create a broadcast command command.
    /// - Parameters:
    ///   - From: The peer that is broadcasting the message.
    ///   - PreformattedCommand: The pre-formatted command to broadcast.
    /// - Returns: Command string to broadcast as a command.
    public static func MakeBroadcastCommand(From: String, PreformattedCommand: String) -> String
    {
        let Source = "From=\(From)"
        let PCmd = "Command=\(PreformattedCommand)"
        let Final = GenerateCommand(Command: .BroadcastCommand, Prefix: PrefixCode, Parts: [Source, PCmd])
        return Final
    }
    
    // MARK: - Broadcasting command decoding.
    
    /// Decode a broadcast message.
    /// - Parameter Raw: The raw message that was broadcast.
    /// - Returns: Tuple in the form (Name of peer that broadcast message, message body). Nil on failure/error.
    public static func DecodeBroadcastMessage(_ Raw: String) -> (String, String)?
    {
        let Params = GetParameters(From: Raw, ["From", "Message"])
        var From = ""
        if let Frm = Params["From"]
        {
            From = Frm
        }
        else
        {
            print("Error decoding broadcast message - no From parameter found.")
            return nil
        }
        var Message = ""
        if let Msg = Params["Message"]
        {
            Message = Msg
        }
        else
        {
            print("Error decoding broadcast message - no Message parameter found.")
            return nil
        }
        return (From, Message)
    }
    
    /// Decode a broadcast command.
    /// - Parameter Raw: The raw command message that was broadcast.
    /// - Returns: Tuple in the form (Name of peer that broadcast message, undecoded command). Nil on failure/error.
    public static func DecodeBroadcastCommand(_ Raw: String) -> (String, String)?
    {
        let Params = GetParameters(From: Raw, ["From", "Command"])
        var From = ""
        if let Frm = Params["From"]
        {
            From = Frm
        }
        else
        {
            print("Error decoding broadcast message - no From parameter found.")
            return nil
        }
        var Command = ""
        if let Cmd = Params["Command"]
        {
            Command = Cmd
        }
        else
        {
            print("Error decoding broadcast message - no Command parameter found.")
            return nil
        }
        return (From, Command)
    }
}
