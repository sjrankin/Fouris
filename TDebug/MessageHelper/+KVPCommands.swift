//
//  +KVPCommands.swift
//  TDDebug
//
//  Created by Stuart Rankin on 6/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

/// Functions related to key/value displays.
extension MessageHelper
{
    // MARK: - KVP command encoding commands.
    
    /// Make a message to send a key-value pair to a peer. Key-value pairs are display in the peer's KVPTable. Use the
    /// same `ID` to edit an existing key-value pair on the host.
    /// - Parameters:
    ///   - ID: ID of the key-value pair. This is how values can be edited in the peer's KVPTable in place.
    ///   - Key: The key name.
    ///   - Value: The value of the key.
    /// - Returns: Command string to set (or edit) a key-value pair.
    public static func MakeKVPMessage(ID: UUID, Key: String, Value: String) -> String
    {
        let IDCmd = "ID=\(ID.uuidString)"
        let KeyString = "Key=\(Key)"
        let ValueString = "Value=\(Value)"
        let Final = GenerateCommand(Command: .KVPData, Prefix: PrefixCode, Parts: [IDCmd, KeyString, ValueString])
        return Final
    }
    
    // MARK: - KVP command decoding.
    
    /// Decode a KVP message from a remote peer.
    /// - Parameter Raw: Raw data from a peer.
    /// - Returns: Tuple with an optional ID, a Key, and a Value.
    public static func DecodeKVPMessage(_ Raw: String) -> (UUID?, String, String)?
    {
        let Params = GetParameters(From: Raw, ["ID", "Key", "Value"])
        var Key = ""
        if let Ky = Params["Key"]
        {
            Key = Ky
        }
        else
        {
            print("Error decoding KVP message - no key found.")
            return nil
        }
        var Value = ""
        if let Val = Params["Value"]
        {
            Value = Val
        }
        else
        {
            print("Error decoding KVP message - no value found.")
        }
        if let IDS = Params["ID"]
        {
            let ID: UUID = UUID(uuidString: IDS)!
            return (ID, Key, Value)
        }
        return (nil, Key, Value)
    }
}
