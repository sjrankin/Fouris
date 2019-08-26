//
//  ClientCommands.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Manages all client-side commands.
class ClientCommands
{
    /// Initialize the client command class.
    init()
    {
        InitializeBasicCommands()
    }
    
    /// Creates common, basic commands.
    private func InitializeBasicCommands()
    {
        _Basic[ClientCommandIDList[.SendText]!] =
            ClientCommand(ClientCommandIDList[.SendText]!, "Send", "Send text message", 0, "Message")
        _Basic[ClientCommandIDList[.Reset]!] =
            ClientCommand(ClientCommandIDList[.Reset]!, "Reset", "Reset client state", 1)
        _Basic[ClientCommandIDList[.ShutDown]!] =
            ClientCommand(ClientCommandIDList[.ShutDown]!, "ShutDown", "Shuts down the client", 2)
        _Basic[ClientCommandIDList[.ClientVersion]!] =
            ClientCommand(ClientCommandIDList[.ClientVersion]!, "Version", "Get client version info", 0)
    }
    
    private var _Basic: [UUID: ClientCommand] = [UUID: ClientCommand]()
    /// Get a list of basic, common commands. To remove all basic/common commands, call `ClearAllBasicCommands`.
    public var Basic: [UUID: ClientCommand]
    {
        get
        {
            return _Basic
        }
    }
    
    /// Remove all basic/command commands from the class. The only way to get them back is to recreate the class from scratch.
    func ClearAllBasicCommands()
    {
        _Basic.removeAll()
    }
    
    private var _User: [UUID: ClientCommand] = [UUID: ClientCommand]()
    /// Get or set user-level client commands (eg, commands specific to the app).
    public var User: [UUID: ClientCommand]
    {
        get
        {
            return _User
        }
        set
        {
            _User = newValue
        }
    }
    
    /// Returns all (Basic + User) commands in the class. Sort order may change between function calls and order is not
    /// guarenteed.
    ///
    /// - Returns: List of all client commands.
    public func GetAllCommands() -> [(UUID, ClientCommand)]
    {
        var Results = [(UUID, ClientCommand)]()
        for (CmdID, Cmd) in Basic
        {
            Results.append((CmdID, Cmd))
        }
        var Count = 0
        for (CmdID, Cmd) in User
        {
            Cmd.SortOrder = Count + Basic.count
            Results.append((CmdID, Cmd))
            Count = Count + 1
        }
        return Results
    }
    
    /// IDs for basic/command commands.
    let ClientCommandIDList: [ClientCommandIDs: UUID] =
        [
            .SendText: UUID(uuidString: ClientCommandIDs.SendText.rawValue)!,
            .Reset: UUID(uuidString: ClientCommandIDs.Reset.rawValue)!,
            .ShutDown: UUID(uuidString: ClientCommandIDs.ShutDown.rawValue)!,
            .ClientVersion: UUID(uuidString: ClientCommandIDs.ClientVersion.rawValue)!,
    ]
    
    /// Determines if the passed command ID is within the current set of all commands.
    ///
    /// - Parameter Command: The command ID to verify against the current set of all commands.
    /// - Returns: True if the command ID is present, false if not.
    func IsKnownCommand(_ Command: UUID) -> Bool
    {
        return GetCommand(Command) != nil
    }
    
    /// Returns the command for the specified command ID.
    ///
    /// - Parameter CommandID: The command ID whose client command will be returned.
    /// - Returns: The client command on success, nil if not found.
    func GetCommand(_ CommandID: UUID) -> ClientCommand?
    {
        let AllCommands = GetAllCommands()
        for (CmdID, Cmd) in AllCommands
        {
            if CmdID == CommandID
            {
                return Cmd
            }
        }
        return nil
    }
    
    /// Returns a list of string ready to send over multi-peer communications based on all client commands.
    ///
    /// - Returns: List of client command strings.
    func MakeCommandList() -> [String]
    {
        let AllCommands = GetAllCommands()
        var Results = [String]()
        for (_, Cmd) in AllCommands
        {
            let CmdStr = MessageHelper.MakeReturnCommandByIndex(Index: Cmd.SortOrder, Command: Cmd.ID,
                                                                CommandName: Cmd.Name, Description: Cmd.Description,
                                                                ParameterCount: Cmd.ParameterCount, Parameters: Cmd.Parameters)
            Results.append(CmdStr)
        }
        return Results
    }
}

/// Client commands. The raw value is the string representation of a UUID and is used to send commands.
///
/// - SendText: Send text to the client.
/// - Reset: Reset the client to a known state.
/// - ShutDown: Shut down the client.
/// - ClientVersion: Return versioning information to the caller.
enum ClientCommandIDs: String, CaseIterable
{
    case SendText = "08a5db94-b53c-4a31-9764-f31cd0043e3b"
    case Reset = "2a89b0b1-2d87-47c7-89da-12c6036ef2fd"
    case ShutDown = "0418c4c5-c476-4413-a13c-0997972dbb34"
    case ClientVersion = "414653aa-0b12-4e66-87a3-bb8cc6c3aed5"
}

/// Describes a client command.
class ClientCommand
{
    /// Initializer.
    ///
    /// - Parameters:
    ///   - CmdID: Client command ID.
    ///   - CmdName: Name of the command.
    ///   - CmdDescription: Description of the command.
    ///   - Order: Sort order of the command. May be changed by the `ClientCommands` class.
    init(_ CmdID: UUID, _ CmdName: String, _ CmdDescription: String, _ Order: Int)
    {
        _ID = CmdID
        _Name = CmdName
        _Description = CmdDescription
        _SortOrder = Order
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - CmdID: Client command ID.
    ///   - CmdName: Name of the command.
    ///   - CmdDescription: Description of the command.
    ///   - Order: Sort order of the command. May be changed by the `ClientCommands` class.
    ///   - Parameter: Name of the parameter (for commands with only one parameter).
    init(_ CmdID: UUID, _ CmdName: String, _ CmdDescription: String, _ Order: Int, _ Parameter: String)
    {
        _ID = CmdID
        _Name = CmdName
        _Description = CmdDescription
        Parameters[0] = Parameter
        _SortOrder = Order
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - CmdID: Client command ID.
    ///   - CmdName: Name of the command.
    ///   - CmdDescription: Description of the command.
    ///   - Order: Sort order of the command. May be changed by the `ClientCommands` class.
    ///   - ParameterList: List of parameter names for the command.
    init(_ CmdID: UUID, _ CmdName: String, _ CmdDescription: String, _ Order: Int, _ ParameterList: [String])
    {
        _ID = CmdID
        _Name = CmdName
        _Description = CmdDescription
        var Index = 0
        for Param in ParameterList
        {
            Parameters[Index] = Param
            Index = Index + 1
        }
        _SortOrder = Order
    }
    
    private var _SortOrder: Int = -1
    /// Get or set the sort order. May be changed by the `ClientCommands` class at will.
    public var SortOrder: Int
    {
        get
        {
            return _SortOrder
        }
        set
        {
            _SortOrder = newValue
        }
    }
    
    private var _ID: UUID = UUID()
    /// Get or set the ID of the command.
    public var ID: UUID
    {
        get
        {
            return _ID
        }
        set
        {
            _ID = newValue
        }
    }
    
    /// Returns the command type of the command.
    ///
    /// - Note: Uses the case iterable protocol to loop through the `ClientCommandIDs` enum to determine the associated
    ///         `ClientCommandIDs` base on the `ID` set (hopefully) before calling this function.
    ///
    /// - Returns: Command type of the command. Nil if unknown. In general, if nil is returned, the instance is assumed
    ///            to be unstable and should not be used.
    public func GetCommandType() -> ClientCommandIDs?
    {
        for Command in ClientCommandIDs.allCases
        {
            if UUID(uuidString: Command.rawValue) == ID
            {
                return Command
            }
        }
        return nil
    }
    
    private var _Name: String = ""
    /// Get or set the name of the command.
    public var Name: String
    {
        get
        {
            return _Name
        }
        set
        {
            _Name = newValue
        }
    }
    
    private var _Description: String = ""
    /// Get or set the description of the command.
    public var Description: String
    {
        get
        {
            return _Description
        }
        set
        {
            _Description = newValue
        }
    }
    
    /// Returns the number of parameters in the client command. Do **not** used `Parameters.count` as the count will not be correct.
    public var ParameterCount: Int
    {
        get
        {
            var Count = 0
            for SomeName in Parameters
            {
                if !SomeName.isEmpty
                {
                    Count = Count + 1
                }
                else
                {
                    break
                }
            }
            return Count
        }
    }
    
    private var _Parameters: [String] = [String](repeating: "", count: 10)
    /// Get or set the list of parameters.
    public var Parameters: [String]
    {
        get
        {
            return _Parameters
        }
        set
        {
            _Parameters = newValue
        }
    }
    
    private var _ParameterValues: [String] = [String](repeating: "", count: 10)
    /// Get or set the values that correspond to the parameters at the same position.
    public var ParameterValues: [String]
    {
        get
        {
            return _ParameterValues
        }
        set
        {
            _ParameterValues = newValue
        }
    }
}

