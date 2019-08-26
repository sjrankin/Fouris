//
//  +ClientCommands.swift
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
    // MARK: Client command encoding commands.
    
    /// Make a command string that requests a client command at the CommandIndexth position.
    ///
    /// - Parameter CommandIndex: Determines the client command to return.
    /// - Returns: Command string for retrieving the CommandIndexth client command.
    public static func MakeGetCommand(CommandIndex: Int) -> String
    {
        let Payload = "Index=\(CommandIndex)"
        let Final = GenerateCommand(Command: .GetCommand, Prefix: PrefixCode, Parts: [Payload])
        return Final
    }
    
    /// Make a command string returning the Indexth client command. Sent in response to a `MakeGetCommand` command string.
    ///
    /// - Parameters:
    ///   - Index: Index of the returned command - corresonds to the `CommandIndex` parameter in `MakeGetCommand`.
    ///   - Command: ID of the command.
    ///   - CommandName: Name of the command.
    ///   - Description: Description of the command.
    ///   - Parameters: List of parameter names.
    /// - Returns: String representing the client command returnable by multi-peer messaging.
    public static func MakeReturnCommandByIndex(Index: Int, Command: UUID, CommandName: String,
                                                Description: String, ParameterCount: Int, Parameters: [String]) -> String
    {
        let SIndex = "Index=\(Index)"
        let CmdVal = "Command=\(Command.uuidString)"
        let CName = "Name=\(CommandName)"
        let CDesc = "Description=\(Description)"
        let PCount = "ParameterCount=\(ParameterCount)"
        var PList = [String]()
        for Param in Parameters
        {
            if Param.isEmpty
            {
                break
            }
            PList.append("Param=\(Param)")
        }
        let Final = GenerateCommand(Command: .CommandByIndex, Prefix: PrefixCode,
                                    Parts: [[SIndex, CmdVal, CName, CDesc, PCount], PList])
        return Final
    }
    
    /// Make a string command to execute a client command in the client app on the remote system.
    ///
    /// - Parameters:
    ///   - CommandID: Client command ID.
    ///   - Parameters: List of tuples in the format (Parameter Name, Parameter Value).
    /// - Returns: String command to execute a client command.
    public static func MakeCommandForClient(CommandID: UUID, Parameters: [(String, String)]) -> String
    {
        let CmdID = "Command=\(CommandID)"
        let Count = "ParameterCount=\(Parameters.count)"
        var PList = [String]()
        for Param in Parameters
        {
            PList.append("\(Param.0)=\(Param.1)")
        }
        let Final = GenerateCommand(Command: .SendCommandToClient, Prefix: PrefixCode,
                                    Parts: [[CmdID, Count], PList])
        return Final
    }
    
    /// Make a string command to return client command execution results to the caller.
    ///
    /// - Parameters:
    ///   - Result: Result of the client command execution (eg, true, false indicating success or failure of executing
    ///             the command).
    ///   - ReturnValue: The return value (if any) from the command execution. Not considered valid if `Result` in some
    ///                  way indicates a failure to execute the command.
    /// - Returns: String to send to the caller with the results of the client command execution.
    public static func MakeClientCommandResult(Result: String, ReturnValue: String) -> String
    {
        let SResult = "Result=\(Result)"
        let SValue = "Value=\(ReturnValue)"
        let Final = GenerateCommand(Command: .ClientCommandResult, Prefix: PrefixCode, Parts: [SResult, SValue])
        return Final
    }
    
    /// Make a command string returning all client commands.
    ///
    /// - Parameter Commands: The client command manager, populated with all supported client commands.
    /// - Returns: String with all client commands in the passed client command manager.
    public static func MakeAllClientCommands(Commands: ClientCommands) -> String
    {
        let CommandList = Commands.MakeCommandList()
        //let Cmd = MessageTypeIndicators[.AllClientCommandsReturned]!
        let CmdCount = "Count=\(CommandList.count)"
        let CDel = GetUnusedDelimiter(From: CommandList)
        let FinalCommandList = "CommandList=" + AssembleCommand(FromParts: CommandList, WithDelimiter: CDel)
        #if true
        let Final = GenerateCommand(Command: .AllClientCommandsReturned, Prefix: PrefixCode,
                                    Parts: [CmdCount, FinalCommandList])
        #else
        let Delimiter = GetUnusedDelimiter(From: [Cmd, CmdCount, FinalCommandList])
        let Final = AssembleCommand(FromParts: [Cmd, CmdCount, FinalCommandList], WithDelimiter: Delimiter)
        #endif
        return Final
    }
    
    // MARK: Client command decoding.
    
    /// Decode a client command string.
    ///
    /// - Parameter Raw: The raw message string.
    /// - Returns: ClientCommand class with the command ID and parameters (but no other fields populated).
    public static func DecodeClientCommand(_ Raw: String) -> ClientCommand?
    {
        let Params = GetParameters(From: Raw, ["Command", "ParameterCount"])
        var Count = 0
        if let Ct = Params["ParameterCount"]
        {
            Count = Int(Ct)!
        }
        else
        {
            print("Unable to decode client command - no parameter count parameter specified.")
            return nil
        }
        var Command = ""
        if let Cmd = Params["Command"]
        {
            Command = Cmd
        }
        else
        {
            print("Unable to decode client command - no command data specified.")
            return nil
        }
        let CmdParams = GetAllParameters(From: Raw)
        let FCmd = ClientCommand(UUID(uuidString: Command)!, "", "", 0)
        var Index = 0
        for (Key, Value) in CmdParams
        {
            if Key == "Command" || Key == "ParameterCount"
            {
                continue
            }
            FCmd.Parameters[Index] = Key
            FCmd.ParameterValues[Index] = Value
            Index = Index + 1
        }
        return FCmd
    }
    
    /// Decode a returned client command list response.
    ///
    /// - Parameter Raw: The raw response from the client that sent the response.
    /// - Returns: List of client command classes. Nil on error.
    public static func DecodeReturnedCommandList(_ Raw: String) -> [ClientCommand]?
    {
        var Result = [ClientCommand]()
        
        //First, remove the returned command
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        let Parts = Next.split(separator: String.Element(Delimiter))
        let (CmdCountKey, CmdCountValue) = DecodeKVP(String(Parts[1]))!
        if CmdCountKey != "Count"
        {
            print("Mal-formed returned command list encountered.")
            return nil
        }
        let CmdCount = Int(CmdCountValue)!
        
        var LastPart = String(Parts[2])
        let LPDel = String(LastPart.first!)
        LastPart.removeFirst()
        //print("LastPart=\(LastPart)")
        let CParts = LastPart.split(separator: String.Element(LPDel))
        
        for Part in CParts
        {
            //print("Part=\(Part)")
            var SCmd = String(Part)
            let CmdDel = String(SCmd.first!)
            SCmd.removeFirst()
            let CmdParts = SCmd.split(separator: String.Element(CmdDel))
            var FirstPass = [(String, String)]()
            for CmdPart in CmdParts
            {
                let (K, V) = DecodeKVP(String(CmdPart))!
                FirstPass.append((K, V))
            }
            var CmdID: UUID!
            var CmdIndex: Int!
            var CmdName: String!
            var CmdDescription: String!
            var CmdPCount: Int!
            var CmdParameters = [String]()
            for (Name, Value) in FirstPass
            {
                switch Name
                {
                case "ID":
                    //This should be ignored.
                    break
                    
                case "Index":
                    if let CI = Int(Value)
                    {
                        CmdIndex = CI
                    }
                    else
                    {
                        CmdIndex = 0
                    }
                    
                case "Command":
                    if let CIv = UUID(uuidString: Value)
                    {
                        CmdID = CIv
                    }
                    else
                    {
                        CmdID = UUID()
                    }
                    
                case "Name":
                    CmdName = Value
                    
                case "Description":
                    CmdDescription = Value
                    
                case "ParameterCount":
                    if let CPC = Int(Value)
                    {
                        CmdPCount = CPC
                    }
                    else
                    {
                        CmdPCount = 0
                    }
                    
                case "Param":
                    CmdParameters.append(Value)
                    
                default:
                    print("Unexpected command key encountered: \(Name).")
                }
            }
            let CCmd = ClientCommand(CmdID, CmdName, CmdDescription, CmdIndex, CmdParameters)
            Result.append(CCmd)
        }
        
        return Result
    }
}
