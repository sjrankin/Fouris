//
//  +TextMessages.swift
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
    // MARK: - Text message command encoding commands.
    
    /// Make a command to send a text message.
    /// - Parameter WithType: Message type.
    /// - Parameter WithText: Message text.
    /// - Parameter HostName: Name of the host that sent the message.
    /// - Returns: Command to send.
    public static func MakeMessage(WithType: MessageTypes, _ WithText: String, _ HostName: String) -> String
    {
        let P1 = "Message=\(WithText)"
        let P2 = "HostName=\(HostName)"
        let P3 = "TimeStamp=\(MakeTimeStamp(FromDate: Date()))"
        let P4 = "Command=\(WithType.rawValue)"
        let Final = GenerateCommand(Command: .TextMessage, Prefix: PrefixCode, Parts: [P1, P2, P3, P4])
        return Final
    }
    
    /// Make a command to send a text message.
    /// - Parameter WithText: Message text.
    /// - Parameter HostName: Name of the host that sent the message.
    /// - Returns: Command to send.
    public static func MakeMessage(_ WithText: String, _ HostName: String) -> String
    {
        let P1 = "Message=\(WithText)"
        let P2 = "HostName=\(HostName)"
        let P3 = "TimeStamp=\(MakeTimeStamp(FromDate: Date()))"
        let Final = GenerateCommand(Command: .TextMessage, Prefix: PrefixCode, Parts: [P1, P2, P3])
        return Final
    }
    
    /// Make a command to send a block of text.
    /// - Note: The difference between a text block message and a normal message is that text block messages are displayed in a
    ///         special view for large amounts of text.
    /// - Parameter WithText: The block of text to send.
    /// - Parameter UseMonoSpaceFont: Determines whether a monospaced font should be used to display the text.
    /// - Parameter HostName: Name of the host that sent the message.
    /// - Returns: Command to send.
    public static func MakeTextBlock(_ WithText: String, _ UseMonoSpaceFont: Bool, _ HostName: String) -> String
    {
        let P1 = "Block=\(WithText)"
        let P2 = "Monofont=\(UseMonoSpaceFont)"
        let P3 = "HostName=\(HostName)"
        let P4 = "TimeStamp=\(MakeTimeStamp(FromDate: Date()))"
        let Final = GenerateCommand(Command: .TextBlock, Prefix: PrefixCode, Parts: [P1, P2, P3, P4])
        return Final
    }
    
    // MARK: - Text message command decoding.
    
    /// Decode a text message.
    /// - Parameter Raw: Raw data to decode.
    /// - Returns: Tuple with the message, host name, and time stamp.
    public static func DecodeTextMessage(_ Raw: String) -> (String, String, String)
    {
        let Params = GetParameters(From: Raw, ["Message", "HostName", "TimeStamp"])
        var Message = ""
        if let Msg = Params["Message"]
        {
            Message = Msg
        }
        var HostName = ""
        if let Host = Params["HostName"]
        {
            HostName = Host
        }
        var TimeStamp = ""
        if let TS = Params["TimeStamp"]
        {
            TimeStamp = TS
        }
        return(Message, HostName, TimeStamp)
    }
    
    /// Decode a text block message.
    /// - Parameter Raw: Raw data to decode.
    /// - Returns: Tuple with: text block, monospace font flag, host name, and time stamp.
    public static func DecodeTextBlockMessage(_ Raw: String) -> (String, Bool, String, String)
    {
        let Params = GetParameters(From: Raw, ["Block", "Monofont", "HostName", "TimeStamp"])
        var Block = ""
        if let Msg = Params["Block"]
        {
            Block = Msg
        }
        var HostName = ""
        if let Host = Params["HostName"]
        {
            HostName = Host
        }
        var TimeStamp = ""
        if let TS = Params["TimeStamp"]
        {
            TimeStamp = TS
        }
        var UseMonospace = true
        if let Mono = Params["Monofont"]
        {
            if let MonoValue = Bool(Mono)
            {
                UseMonospace = MonoValue
            }
        }
        return(Block, UseMonospace, HostName, TimeStamp)
    }
}
