//
//  +Tables.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

extension MessageHelper
{
    // MARK: Table encoding commands.
    
    /// Create a table command.
    /// - Parameter SubCommand: The table sub-command.
    /// - Parameter TableID: The ID of the table.
    /// - Parameter Parameters: Parameters for the sub-command. Context sensitive.
    /// - Returns: Command string to send to a remote peer.
    public static func MakeTableCommand(SubCommand: TableCommands, TableID: UUID,
                                        Parameters: [String: String]) -> String
    {
        var KVPList = [String]()
        let P1 = "SubCommand=\(SubCommand.rawValue)"
        let P2 = "TableID=\(TableID.uuidString)"
        KVPList.append(P1)
        KVPList.append(P2)
        for (Key, Value) in Parameters
        {
            KVPList.append("\(Key)=\(Value)")
        }
        let Final = GenerateCommand(Command: .TableCommand, Prefix: PrefixCode, Parts: KVPList)
        return Final
    }
    
    // MARK: Table decoding commands.
    
    #if false
    /// Decode a received table command.
    /// - Parameter Raw: The raw data to parse.
    /// - Returns: A `TableCommandData` instance with parsed data.
    public static func DecodeTableCommand(_ Raw: String) -> TableCommandData?
    {
        let Params = GetAllParameters(From: Raw)
        var SubCommand: TableCommands = .Unknown
        if let RawSubCommand = Params["SubCommand"]
        {
            if let Cmd = TableCommands(rawValue: RawSubCommand)
            {
                SubCommand = Cmd
            }
            else
            {
                print("Malformed table sub-command (\"\(RawSubCommand)\") encountered in DecodeTableCommand.")
                return nil
            }
        }
        else
        {
            print("Malformed table command encountered - no sub-command found.")
            return nil
        }
        var TableID = UUID.Empty
        if let RawID = Params["TableID"]
        {
            if let SomeID = UUID(uuidString: RawID)
            {
                TableID = SomeID
            }
            else
            {
                print("Malformed table ID (\"\(RawID)\") encountered in DecodeTableCommand.")
                return nil
            }
        }
        let Final = TableCommandData(TableID, SubCommand)
        for (Key, Value) in Params
        {
            if Key == "SubCommand" || Key == "TableID"
            {
                continue
            }
            Final.CommandParameters[Key] = Value
        }
        return Final
    }
    #endif
}
