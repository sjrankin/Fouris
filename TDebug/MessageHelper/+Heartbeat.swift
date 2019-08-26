//
//  +Heartbeat.swift
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
    // MARK: Heartbeat command encoding commands.
    
    /// Make a connection heartbeat message.
    ///
    /// - Parameters:
    ///   - From: The name of the peer that is sending the connection heartbeat message.
    ///   - ReturnIn: Number of seconds to wait before returning a reciprocol connection heartbeat.
    ///   - LastReturn: The number of seconds the sender had to wait for the previous connection
    ///                 heartbeat message.
    ///   - FailAfter: Number of seconds to wait before declaring a communication failure. If this
    ///                value is less than `ReturnIn`, this value is added to `ReturnIn` to create
    ///                the resolved fail after time.
    ///   - ReceiveCount: Cumulative count of received connection heartbeat messages.
    /// - Returns: Connection heartbeat command message.
    public static func MakeConnectionHeartbeat(From: MCPeerID, ReturnIn: Int,
                                               LastReturn: Int, FailAfter: Int,
                                               ReceiveCount: Int) -> String
    {
        let FS = "From=\(From)"
        let RI = "ReturnIn=\(ReturnIn)"
        let LR = "LastReturn=\(LastReturn)"
        let FA = "FailAfter=\(FailAfter)"
        let RC = "ReceivedCount=\(ReceiveCount)"
        let Final = GenerateCommand(Command: .ConnectionHeartbeat, Prefix: PrefixCode,
                                    Parts: [FS, RI, LR, FA, RC])
        return Final
    }
    
    public static func MakeRequestConnectionHeartbeat(From: MCPeerID) -> String
    {
        let FromS = "From=\(From.displayName)"
        let Final = GenerateCommand(Command: .RequestConnectionHeartbeat, Prefix: PrefixCode, Parts: [FromS])
        return Final
    }
    
    public static func MakeHeartbeatMessage(NextExpectedIn: Int, _ HostName: String) -> String
    {
        let Expected = "Next=\(NextExpectedIn)"
        let Final = GenerateCommand(Command: .Heartbeat, Prefix: PrefixCode, Parts: [Expected])
        return Final
    }
    
    public static func MakeHeartbeatMessage(Payload: String, NextExpectedIn: Int, _ HostName: String) -> String
    {
        let Message = "Next=\(NextExpectedIn)"
        let MPayload = "Payload=\(Payload)"
        let Final = GenerateCommand(Command: .Heartbeat, Prefix: PrefixCode, Parts: [Message, MPayload])
        return Final
    }
    
    // MARK: Hearbeat command decoding.
    
    /// Decode a connection heartbeat message.
    ///
    /// - Parameter Raw: Raw command string to decode.
    /// - Returns: Tuple of information from the connection heartbeat command in the form
    ///            (Sending Peer Name, Return Reciprocol Message in Seconds, Time the Sender
    ///             Waited for the Pervious Message, Fail After Seconds, Cumulative Recieved Count).
    public static func DecodeConnectionHeartbeat(_ Raw: String) -> (String, Int, Int, Int, Int)
    {
        let Params = GetParameters(From: Raw, ["From", "ReturnIn", "LastReturn", "FailAfter", "ReceivedCount"])
        var FS = ""
        var RI = 0
        var LR = 0
        var FA = 0
        var RC = 0
        for (Key, Value) in Params
        {
            switch Key
            {
            case "From":
                FS = Value
                
            case "ReturnIn":
                if let RIx = Int(Value)
                {
                    RI = RIx
                }
                else
                {
                    fatalError("Error converting String to Int.")
                }
                
            case "LastReturn":
                if let LRx = Int(Value)
                {
                    LR = LRx
                }
                else
                {
                    fatalError("Error converting String to Int.")
                }
                
            case "FailAfter":
                if let FAx = Int(Value)
                {
                    FA = FAx
                }
                else
                {
                    fatalError("Error converting String to Int.")
                }
                
            case "ReceivedCount":
                if let RCx = Int(Value)
                {
                    RC = RCx
                }
                else
                {
                    fatalError("Error converting String to Int.")
                }
                
            default:
                print("Found unanticipated version key: \(Key) and value: \(Value)")
            }
        }
        return (FS, RI, LR, FA, RC)
    }
    
    public static func DecodeHeartbeat(_ Raw: String) -> (Int, String?)?
    {
        let Params = GetParameters(From: Raw, ["Next", "Payload"])
        var NextIn = 0
        if let Nxt = Params["Next"]
        {
            NextIn = Int(Nxt)!
        }
        else
        {
            print("Error decoding heartbeat command - no Next parameter found.")
            return nil
        }
        var Payload = ""
        if let Pld = Params["Payload"]
        {
            Payload = Pld
            return (NextIn, Payload)
        }
        return (NextIn, nil)
    }
}
