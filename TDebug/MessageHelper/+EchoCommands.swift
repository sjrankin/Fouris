//
//  +EchoCommands.swift
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
    // MARK: - Echo command encoding commands.
    
    /// Make an echo message command.
    /// - Parameters:
    ///   - Message: The text message to echo.
    ///   - Delay: How long, in seconds, to delay before returning the `Message` back.
    ///   - Count: Not currently used.
    ///   - Host: The source of the echo - used by the peer to know where to send the echo.
    /// - Returns: Command string for echoing a message.
    public static func MakeEchoMessage(Message: String, Delay: Int, Count: Int, Host: String) -> String
    {
        let ReturnAddress = "EchoBackTo=\(Host)"
        let EchoCount = "Count=\(Count)"
        let EchoDelay = "Delay=\(Delay)"
        let EchoMessage = "Message=\(Message)"
        let Final = GenerateCommand(Command: .EchoReturn, Prefix: PrefixCode, Parts: [ReturnAddress, EchoCount, EchoDelay, EchoMessage])
        return Final
    }
    
    // MARK: - Echo command decoding.
    
    /// Decode an echo message.
    /// - Parameter Raw: Raw message from peer.
    /// - Returns: Tuple with the name of the peer to echo back to, the number of times to echo, the delay between echoes, and
    ///            the message to echo.
    public static func DecodeEchoMessage(_ Raw: String) -> (String, String, Int, Int)?
    {
        let Params = GetParameters(From: Raw, ["EchoBackTo", "Count", "Delay", "Message"])
        var Message = ""
        if let Msg = Params["Message"]
        {
            Message = Msg
        }
        else
        {
            print("Error decoding echo message - no message found.")
            return nil
        }
        var EchoTo = ""
        if let ETo = Params["EchoBackTo"]
        {
            EchoTo = ETo
        }
        else
        {
            print("Error decoding echo message - no return address.")
            return nil
        }
        var Delay = 0
        if let DS = Params["Delay"]
        {
            Delay = Int(DS)!
        }
        var Count = 0
        if let Ct = Params["Count"]
        {
            Count = Int(Ct)!
        }
        return (Message, EchoTo, Delay, Count)
    }
}
