//
//  +DebuggeeExecution.swift
//  TDDebug
//
//  Created by Stuart Rankin on 6/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

/// Extensions for idiot light message encoding and decoding.
extension MessageHelper
{
    // MARK: - Debuggee execution encoding commands.
    
    /// Make a command that indicates execution has started.
    /// - Parameter Prefix: The prefix for the command.
    /// - Parameter Exclusive: Exclusive flag.
    /// - Returns: Command to send that indicates execution has started.
    public static func MakeExecutionStartedCommand(Prefix: UUID, Exclusive: Bool) -> String
    {
        let P1 = "Prefix=\(Prefix.uuidString)"
        let P2 = "RequestExclusive=\(Exclusive)"
        let Final = GenerateCommand(Command: .ExecutionStarted, Prefix: Prefix, Parts: [P1, P2])
        return Final
    }
    
    /// Make a command that indicates execution has terminated.
    /// - Parameter Prefix: The prefix for the command.
    /// - Parameter WasFatalError: Indicates if execution terminated due to a fatal error.
    /// - Parameter LastMessage: The last message to send.
    /// - Returns: Command to send that indicates execution has terminated.
    public static func MakeExecutionTerminatedCommand(Prefix: UUID, WasFatalError: Bool, LastMessage: String) -> String
    {
        let P1 = "Prefix=\(Prefix.uuidString)"
        let P2 = "FatalError=\(WasFatalError)"
        let P3 = "LastMessage=\(LastMessage)"
        let Final = GenerateCommand(Command: .ExecutionTerminated, Prefix: Prefix, Parts: [P1, P2, P3])
        return Final
    }
    
    // MARK: - Debuggee execution command decoding.
    
    /// Decode an execution started command from a peer.
    /// - Parameter Raw: The raw data received from the peer.
    /// - Returns: Tuple with the prefix of the remote peer as well as the exclusive flag.
    public static func DecodeExecutionStartedCommand(_ Raw: String) -> (UUID, Bool)?
    {
        let Results = GetParameters(From: Raw, ["Prefix", "RequestExclusive"])
        var PrefixCd = UUID.Empty
        if let PC = Results["Prefix"]
        {
            PrefixCd = UUID(uuidString: PC)!
        }
        else
        {
            print("Malformed execution started message encountered: missing prefix.")
            return nil
        }
        var Exclusive = false
        if let Ex = Results["Exclusive"]
        {
            Exclusive = Bool(Ex)!
        }
        return (PrefixCd, Exclusive)
    }
    
    /// Decode an execution terminated command from a peer.
    /// - Parameter Raw: Raw data from the peer.
    /// - Returns: Tuple with the remote prefix ID, fatal error flag, and last message.
    public static func DecodeExecutionTerminatedCommand(_ Raw: String) -> (UUID, Bool, String)?
    {
        let Results = GetParameters(From: Raw, ["Prefix", "FatalError", "LastMessage"])
        var PrefixCd = UUID.Empty
        if let PC = Results["Prefix"]
        {
            PrefixCd = UUID(uuidString: PC)!
        }
        else
        {
            print("Malformed execution terminated message encountered: missing prefix.")
            return nil
        }
        var WasFatal = false
        if let Fatal = Results["FatalError"]
        {
            WasFatal = Bool(Fatal)!
        }
        var LastMessage = ""
        if let Last = Results["LastMessage"]
        {
            LastMessage = Last
        }
        return (PrefixCd, WasFatal, LastMessage)
    }
}

