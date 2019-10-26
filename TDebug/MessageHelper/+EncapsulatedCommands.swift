//
//  +EncapsulatedCommands.swift
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
    // MARK: - Encapsulated command encoding commands.

    /// Make an encapsulated command. Encapsulated commands are used to coordinate asynchronous commands with
    /// their asynchronous results.
    /// - Parameters:
    ///   - WithID: The asynchronous command ID - each time this is called, a different UIID should be used.
    ///   - Payload: The command to encapsulate.
    /// - Returns: Encpasulated command string.
    public static func MakeEncapsulatedCommand(WithID: UUID, Payload: String) -> String
    {
        let CmdID = "ID=\(WithID.uuidString)"
        let Pld = "Payload=\(Payload)"
        let Final = GenerateCommand(Command: .IDEncapsulatedCommand, Prefix: PrefixCode, Parts: [CmdID, Pld])
        return Final
    }
    
    // MARK: - Encapsulated command decoding.
    
    /// Decode an encapsulated ID command.
    /// - Parameter Raw: The raw value to decode.
    /// - Returns: Tupele in the following order: (ID of the encapsulated command, Raw, encoded command). Nil on error.
    public static func DecodeEncapsulatedCommand(_ Raw: String) -> (UUID, String)?
    {
        let Params = GetParameters(From: Raw, ["ID", "Payload"])
        var CID = UUID.Empty
        if let SomeID = Params["ID"]
        {
            CID = UUID(uuidString: SomeID)!
        }
        else
        {
            print("Cannot decode encapsulated command - missing ID parameter.")
            return nil
        }
        var Payload = ""
        if let Pay = Params["Payload"]
        {
            Payload = Pay
        }
        else
        {
            print("Cannot decode encapsulated command - missing payload parameter.")
            return nil
        }
        return (CID, Payload)
    }
}
