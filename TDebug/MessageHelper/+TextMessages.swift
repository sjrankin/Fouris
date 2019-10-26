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
}
