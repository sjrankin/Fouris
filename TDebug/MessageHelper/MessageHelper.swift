//
//  MessageHelper.swift
//  T{D}Debug
//
//  Created by Stuart Rankin on 4/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

/// Class that helps with encoding and decoding messages sent to and from TD{D}ebug instances. Intended for use on iOS and macOS.
class MessageHelper
{
    /// Initialize the message helper.
    /// - Parameter Prefix: The prefix code for the instance.
    public static func Initialize(_ Prefix: UUID)
    {
        PrefixCode = Prefix
        print("MessageHelper.Initialize: PrefixCode=\(Prefix.uuidString)")
    }
    
    /// Holds the prefix code.
    public static var PrefixCode: UUID = UUID.Empty
    
    // MARK: High-level parsing code.
    
    /// Extracts a set of parameters from the passed string.
    /// - Note: The string is assumed to be the payload of a standard TDebug message with the initial character
    ///         acting as the delimiter character. Parameters are expected to be in Key=Value format. **Casing is significant.**
    /// - Parameter From: The raw string that contains the parameters to extract.
    /// - Parameter Expected: List of expected parameter names/keys. Any key not found in this list is ignored
    ///                       and not returned.
    /// - Returns: Dictionary of keys with their respective values. May be empty if nothing found.
    public static func GetParameters(From: String, _ Expected: [String]) -> [String: String]
    {
        if From.isEmpty
        {
            return [String: String]()
        }
        let Delimiter = String(From.first!)
        var Raw = From
        Raw.removeFirst()
        var Results = [String: String]()
        let Parts = Raw.split(separator: String.Element(Delimiter), omittingEmptySubsequences: true)
        for Part in Parts
        {
            if let (Key, Value) = DecodeKVP(String(Part), Delimiter: "=")
            {
                if Expected.contains(Key)
                {
                    Results[Key] = Value
                }
            }
        }
        return Results
    }
    
    /// Attempts to parse the passed string for name/value pairs and returns any it finds in a dictionary.
    /// - Parameter From: The source string to parse.
    /// - Returns: Dictionary of all key/value (eg, name/value) pairs found in the string. May be empty if
    ///            nothing found.
    public static func GetAllParameters(From: String) -> [String: String]
    {
        if From.isEmpty
        {
            return [String: String]()
        }
        let Delimiter = String(From.first!)
        var Raw = From
        Raw.removeFirst()
        var Results = [String: String]()
        let Parts = Raw.split(separator: String.Element(Delimiter), omittingEmptySubsequences: true)
        for Part in Parts
        {
            if let (Key, Value) = DecodeKVP(String(Part), Delimiter: "=")
            {
                    Results[Key] = Value
            }
        }
        return Results
    }
    
    /// Decode a key-value pair with the specified delimiter. The format is assumed to be: key=value.
    ///
    /// - Parameters:
    ///   - Raw: The string with the value to decode.
    ///   - Delimiter: The delimiter between the key and value.
    /// - Returns: Tuple with (Key, Value) (both as Strings) on success, nil on error.
    public static func DecodeKVP(_ Raw: String, Delimiter: String = "=") -> (String, String)?
    {
        if Delimiter.isEmpty
        {
            print("Empty delimiter.")
            return nil
        }
        let Parts = Raw.split(separator: String.Element(Delimiter))
        if Parts.count != 2
        {
            //print("Split into incorrect number of parts: \(Parts.count), expected 2. Raw=\"\(Raw)\"")
            return nil
        }
        return (String(Parts[0]), String(Parts[1]))
    }
    
    /// Return the message type parsed from the passed raw data. Additionally, the sender's prefix code,
    /// intended recipient, and payload data are returned.
    /// - Note: This function assumes all raw data sent is in this format:
    ///         *delimiter* command ID *delimiter* SourcePrefix=ID *delimiter* {*optional* DestinationPrefix=ID *delimiter*} command-specific data.
    /// - Parameter Raw: The raw data to parse.
    /// - Returns: Tuple of: (The message type, sender's prefix code, intended recipient's prefix code,
    ///            payload of the command). If the message is not recognized, **.Unknown** is returned as
    ///            the message type, in which case the two UUIDs are not considered valid for any use, but
    ///            the payload will contain the entire raw data as passed to us for possible debug use. The
    ///            prefix code is sent by the sender and can be used for various purposes. The recipient code
    ///            may or may not be present - if it was not specified by the user, **GUID.Empty** is in its
    ///            spot. The returned string is in a *delimiter* **data** *delimiter* **data** format and contains
    ///            the the contents of the raw data past the last prefix code sent.
    public static func GetMessageData(_ Raw: String) -> (MessageTypes, UUID, UUID, String)
    {
        if Raw.isEmpty
        {
            print("Empty raw data.")
            return (.Unknown, UUID.Empty, UUID.Empty, "")
        }
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        var Parts = Next.split(separator: String.Element(Delimiter), omittingEmptySubsequences: true)
        let MessageType = MessageTypeFromID(String(Parts.first!))
        Parts.removeFirst()
        if MessageType == .Unknown
        {
            return (.Unknown, UUID.Empty, UUID.Empty, Raw)
        }
        let (P1Name, P1Data) = DecodeKVP(String(Parts.first!))!
        Parts.removeFirst()
        if P1Name != "SourcePrefix"
        {
            print("Received command with missing source prefix.")
            return (.Unknown, UUID.Empty, UUID.Empty, Raw)
        }
        let SourcePrefix = UUID(uuidString: P1Data)!
        
        if Parts.isEmpty
        {
            return (MessageType, SourcePrefix, UUID.Empty, "")
        }
        
        var DestinationPrefix = UUID.Empty
        if let (P2Name, P2Data) = DecodeKVP(String(Parts.first!))
        {
            if P2Name == "DestinationPrefix"
            {
                DestinationPrefix = UUID(uuidString: P2Data)!
                Parts.removeFirst()
            }
        }

        var Payload = ""
        if !Parts.isEmpty
        {
            Payload = Delimiter
            for Part in Parts
            {
                Payload = Payload + Delimiter + String(Part)
            }
        }

        return (MessageType, SourcePrefix, DestinationPrefix, Payload)
    }
    
    /// Return the message type parsed from the passed raw data.
    /// - Returns: The message type.
    public static func GetMessageType(_ Raw: String) -> MessageTypes
    {
        if Raw.isEmpty
        {
            print("Empty raw data.")
            return .Unknown
        }
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        let Parts = Next.split(separator: String.Element(Delimiter), omittingEmptySubsequences: true)
        for Part in Parts
        {
            let MessageType = MessageTypeFromID(String(Part))
            return MessageType
        }
        print("Unexpected message found: \(Raw)")
        return .Unknown
    }
    
    /// Return a message type from the raw string.
    /// - Parameter RawID: The raw string a message type is extracted from then returned
    /// - Returns: Message type from the raw string.
    public static func MessageTypeFromID(_ RawID: String) -> MessageTypes
    {
        let FixedID = RawID.lowercased()
        for (SomeType, StringedID) in MessageTypeIndicators
        {
            if StringedID.lowercased() == FixedID
            {
                return SomeType
            }
        }
        return .Unknown
    }
    
    /// Create a time-stamp string from the passed date.
    ///
    /// - Parameters:
    ///   - FromDate: The date from which a string will be created.
    ///   - TimeSeparator: Separator to use for the time part.
    /// - Returns: String in the format: dd MMM yyyy HH:MM:SS
    public static func MakeTimeStamp(FromDate: Date, TimeSeparator: String = ":") -> String
    {
        let Cal = Calendar.current
        let Year = Cal.component(.year, from: FromDate)
        let Month = Cal.component(.month, from: FromDate)
        let MonthName = ["Zero", "Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][Month]
        let Day = Cal.component(.day, from: FromDate)
        let DatePart = "\(Year)-\(MonthName)-\(Day) "
        let Hour = Cal.component(.hour, from: FromDate)
        var HourString = String(describing: Hour)
        if Hour < 10
        {
            HourString = "0" + HourString
        }
        let Minute = Cal.component(.minute, from: FromDate)
        var MinuteString = String(describing: Minute)
        if Minute < 10
        {
            MinuteString = "0" + MinuteString
        }
        let Second = Cal.component(.second, from: FromDate)
        var Result = HourString + TimeSeparator + MinuteString
        var SecondString = String(describing: Second)
        if Second < 10
        {
            SecondString = "0" + SecondString
        }
        Result = Result + TimeSeparator + SecondString
        return DatePart + Result
    }
    
    /// Determines if one of the strings in `With` contains the string in `InCommon`.
    /// - Parameter InCommon: The string to search for in the strings in `With`.
    /// - Parameter With: The list of strings to search.
    /// - Returns: True if `InCommon` can be found somewhere in `With`, false if not.
    private static func IsInString(_ InCommon: String, With: [String]) -> Bool
    {
        for SomeString in With
        {
            if SomeString.contains(InCommon)
            {
                return true
            }
        }
        return false
    }
    
    /// Returns a character that is not in any of the list of strings in `From`.
    /// - Parameter From: List of strings. The return character will not be in any of these strings.
    /// - Returns: Character **not** in any string in `From`.
    public static func GetUnusedDelimiter(From: [String]) -> String
    {
        for Delimiter in Delimiters
        {
            if !IsInString(Delimiter, With: From)
            {
                return Delimiter
            }
        }
        return "\u{2}"
    }
    
    /// Returns a character that is not in any of the list of list of strings in `From`.
    /// - Parameter From: List of list of strings. The return character will not be in any of these strings.
    /// - Returns: Character **not** in any string in `From`.
    public static func GetUnusedDelimiter(From: [[String]]) -> String
    {
        let FinalList = From.flatMap{$0}
        return GetUnusedDelimiter(From: FinalList)
    }
    
    /// Delimeter strings. Used to find an unused character.
    private static let Delimiters = [",", ";", ".", "/", ":", "-", "_", "`", "~", "\"", "'", "$", "!", "\\", "¥", "°", "^", "·", "€", "‹", "›", "@"]
    

    /// Make a command to have a client return the number of commands.
    ///
    /// - Returns: Command string for retrieving the number of client commands.
    public static func MakeGetCommandCount() -> String
    {
        return MessageTypeIndicators[.RequestCommandCount]!
    }

    /// Make a command to return all client commands.
    public static func MakeGetAllClientCommands() -> String
    {
        return MessageTypeIndicators[.GetAllClientCommands]!
    }
    
    /// Assemble the list of string into a command that can be sent to another TDebug instance or other app that implements
    /// at least the MultiPeerManager.
    ///
    /// - Note: The format of the returned string is Delimiter Part {Delimiter Part}. This is so the parsing code can easily
    ///         determine what the delimiter is to seperate the parts of the raw string into coherent parts.
    ///
    /// - Parameters:
    ///   - FromParts: List of parts of the command to assemble. Order is presevered.
    ///   - WithDelimiter: The delimiter to use to separate the parts from each other.
    /// - Returns: Command string that can be sent to another TDebug instance.
    static func AssembleCommand(FromParts: [String], WithDelimiter: String) -> String
    {
        var Final = ""
        for Part in FromParts
        {
            if Part.isEmpty
            {
                continue
            }
            Final = Final + WithDelimiter + Part
        }
        return Final
    }
    
    /// Generate a formatted command to send to a peer.
    /// - Parameter Command: The command to send.
    /// - Parameter Prefix: The prefix of the sender.
    /// - Parameter Parts: The parts of the command (eg, parameters, terms, whatever).
    /// - Returns: Formatted command string to send.
    static func GenerateCommand(Command: String, Prefix: String, Parts: [String]) -> String
    {
        let PrefixTerm = "SourcePrefix=\(Prefix)"
        let Delimiter = GetUnusedDelimiter(From: [[Command, PrefixTerm], Parts])
        var FinalList = [String]()
        FinalList.append(Command)
        FinalList.append(PrefixTerm)
        for Part in Parts
        {
            FinalList.append(String(Part))
        }
        var Final = ""
        for Part in FinalList
        {
            //print("GenerateCommand: \(Part)")
            if Part.isEmpty
            {
                continue
            }
            Final = Final + Delimiter + Part
        }
        return Final
    }
    
    /// Generate a formatted command to send to a peer.
    /// - Parameter Command: The command to send.
    /// - Parameter Prefix: The prefix of the sender.
    /// - Parameter Parts: The parts of the command (eg, parameters, terms, whatever).
    /// - Returns: Formatted command string to send.
    static func GenerateCommand(Command: MessageTypes, Prefix: UUID, Parts: [String]) -> String
    {
        //print("GenerateCommand(\(Command))")
        return GenerateCommand(Command: Command.rawValue, Prefix: Prefix.uuidString, Parts: Parts)
    }
    
    /// Generate a formatted command to send to a peer.
    /// - Parameter Command: The command to send.
    /// - Parameter Prefix: The prefix of the sender.
    /// - Parameter Parts: The parts of the command (eg, parameters, terms, whatever). This particular version
    ///                    of this function accepts an array of arrays.
    /// - Returns: Formatted command string to send.
    static func GenerateCommand(Command: MessageTypes, Prefix: UUID, Parts: [[String]]) -> String
    {
        let Final = Parts.flatMap{$0}
        return GenerateCommand(Command: Command, Prefix: Prefix, Parts: Final)
    }
    
    /// Assemble the list of string into a command that can be sent to another TDebug instance or other app that implements
    /// at least the MultiPeerManager.
    ///
    /// - Note: The format of the returned string is Delimiter Part {Delimiter Part}. This is so the parsing code can easily
    ///         determine what the delimiter is to seperate the parts of the raw string into coherent parts.
    ///
    /// - Parameters:
    ///   - FromParts: List of list of parts of the command to assemble. Order is presevered.
    ///   - WithDelimiter: The delimiter to use to separate the parts from each other.
    /// - Returns: Command string that can be sent to another TDebug instance.
    static func AssembleCommandsEx(FromParts: [[String]], WithDelimiter: String) -> String
    {
        let FinalList = FromParts.flatMap{$0}
        return AssembleCommand(FromParts: FinalList, WithDelimiter: WithDelimiter)
    }
    
    /// Given a message type ID in string format, return the actual message type.
    ///
    /// - Parameter Raw: Message type ID in string format.
    /// - Returns: MessageType enumeration on success, nil if not found.
    public static func MessageTypeFromString(_ Raw: String) -> MessageTypes?
    {
        if let FindMe = UUID(uuidString: Raw)
        {
            for (MType, RawString) in MessageTypeIndicators
            {
                let MID = UUID(uuidString: RawString)
                if MID == FindMe
                {
                    return MType
                }
            }
        }
        return nil
    }
    
    /// Command definition map for message commands.
    public static let MessageTypeIndicators: [MessageTypes: String] =
        [
            MessageTypes.TextMessage: MessageTypes.TextMessage.rawValue,
            MessageTypes.CommandMessage: MessageTypes.CommandMessage.rawValue,
            MessageTypes.ControlIdiotLight: MessageTypes.ControlIdiotLight.rawValue,
            MessageTypes.EchoMessage: MessageTypes.EchoMessage.rawValue,
            MessageTypes.Acknowledge: MessageTypes.Acknowledge.rawValue,
            MessageTypes.Heartbeat: MessageTypes.Heartbeat.rawValue,
            MessageTypes.KVPData: MessageTypes.KVPData.rawValue,
            MessageTypes.EchoReturn: MessageTypes.EchoReturn.rawValue,
            MessageTypes.SpecialCommand: MessageTypes.SpecialCommand.rawValue,
            MessageTypes.HandShake: MessageTypes.HandShake.rawValue,
            MessageTypes.RequestCommandCount: MessageTypes.RequestCommandCount.rawValue,
            MessageTypes.GetCommand: MessageTypes.GetCommand.rawValue,
            MessageTypes.CommandByIndex: MessageTypes.CommandByIndex.rawValue,
            MessageTypes.SendCommandToClient: MessageTypes.SendCommandToClient.rawValue,
            MessageTypes.ClientCommandResult: MessageTypes.ClientCommandResult.rawValue,
            MessageTypes.GetAllClientCommands: MessageTypes.GetAllClientCommands.rawValue,
            MessageTypes.AllClientCommandsReturned: MessageTypes.AllClientCommandsReturned.rawValue,
            MessageTypes.IDEncapsulatedCommand: MessageTypes.IDEncapsulatedCommand.rawValue,
            MessageTypes.PushVersionInformation: MessageTypes.PushVersionInformation.rawValue,
            MessageTypes.ConnectionHeartbeat: MessageTypes.ConnectionHeartbeat.rawValue,
            MessageTypes.RequestConnectionHeartbeat: MessageTypes.RequestConnectionHeartbeat.rawValue,
            MessageTypes.BroadcastMessage: MessageTypes.BroadcastMessage.rawValue,
            MessageTypes.BroadcastCommand: MessageTypes.BroadcastCommand.rawValue,
            MessageTypes.GetPeerType: MessageTypes.GetPeerType.rawValue,
            MessageTypes.SendPeerType: MessageTypes.SendPeerType.rawValue,
            MessageTypes.IdiotLightMessage: MessageTypes.IdiotLightMessage.rawValue,
            MessageTypes.DebuggerStateChanged: MessageTypes.DebuggerStateChanged.rawValue,
            MessageTypes.ExecutionStarted: MessageTypes.ExecutionStarted.rawValue,
            MessageTypes.ExecutionTerminated: MessageTypes.ExecutionTerminated.rawValue,
            MessageTypes.ResetTDebugUI: MessageTypes.ResetTDebugUI.rawValue,
            MessageTypes.TableCommand: MessageTypes.TableCommand.rawValue,
            MessageTypes.Unknown: MessageTypes.Unknown.rawValue,
    ]
    
    /// Command definition map for special commands.
    public static let SpecialCommmandIndicators: [SpecialCommands: String] =
        [
            .ClearKVPList: SpecialCommands.ClearKVPList.rawValue,
            .ClearLogList: SpecialCommands.ClearLogList.rawValue,
            .ClearIdiotLights: SpecialCommands.ClearIdiotLights.rawValue,
            .Unknown: SpecialCommands.Unknown.rawValue,
    ]
    
    /// Command definition map for handshake commands.
    public static let HandShakeIndicators: [HandShakeCommands: String] =
        [
            .RequestConnection: HandShakeCommands.RequestConnection.rawValue,
            .ConnectionGranted: HandShakeCommands.ConnectionGranted.rawValue,
            .ConnectionRefused: HandShakeCommands.ConnectionRefused.rawValue,
            .ConnectionClose: HandShakeCommands.ConnectionClose.rawValue,
            .Disconnected: HandShakeCommands.Disconnected.rawValue,
            .DropAsClient: HandShakeCommands.DropAsClient.rawValue,
            .Unknown: HandShakeCommands.Unknown.rawValue,
    ]
    
    /// Given a formatted command string, return it in symbolic form, meaning, UUIDs are converted to human-
    /// readable strings.
    ///
    /// - Note: Do **not** send the returned result to a peer as it is not decodable.
    ///
    /// - Parameter Raw: Raw, formatted command string.
    /// - Returns: Command string with symbols, not values. The return value is intended only for display use.
    public static func MakeSymbolic(Command: String) -> String
    {
        if Command.isEmpty
        {
            return ""
        }
        var ReturnMe = Command
        for Case in SpecialCommands.allCases
        {
            let Raw = Case.rawValue
            let Nice = "\(Case)"
            ReturnMe = ReturnMe.replacingOccurrences(of: Raw, with: Nice)
        }
        for Case in HandShakeCommands.allCases
        {
            let Raw = Case.rawValue
            let Nice = "\(Case)"
            ReturnMe = ReturnMe.replacingOccurrences(of: Raw, with: Nice)
        }
        for Case in MessageTypes.allCases
        {
            let Raw = Case.rawValue
            let Nice = "\(Case)"
            ReturnMe = ReturnMe.replacingOccurrences(of: Raw, with: Nice)
        }
        return ReturnMe
    }
}

/// Special UI-infrastructure commands.
///
/// - ClearKVPList: Clear the contents of the KVP list.
/// - ClearLogList: Clear the contents of the log item list.
/// - ClearIdiotLights: Reset all idiot lights (except for A1, which is reserved for the local instance).
/// - Unknown: Unknown special command - if explicitly used, ignored.
enum SpecialCommands: String, CaseIterable
{
    case ClearKVPList = "a1a4974c-ed8f-41bc-bdbf-49570f67cc03"
    case ClearLogList = "283c06c3-dca6-4044-a8ba-b034efd51594"
    case ClearIdiotLights = "1600bf5d-ffa7-474b-ab55-c8298f056969"
    case Unknown = "bbfb4205-d9f6-49cf-bd96-630641d4fb16"
}

/// Sub-commands related to handshakes between two peers when netogiating who is the server and who is the client.
///
/// - RequestConnection: Peer requests the target to be the server.
/// - ConnectionGranted: Sent when an instance becomes the server - sent to the peer that requested a connection.
/// - ConnectionRefused: Sent when the instance is not able to be the server.
/// - ConnectionClose: Sent by the client to close the connection to the server.
/// - Disconnected: Sent by the server to the client when it closes the connection.
/// - DropAsClient: Sent by the server asynchronously when it closes the connection for any reason.
/// - Unknown: Unknown command - if explicitly used, ignored.
enum HandShakeCommands: String, CaseIterable
{
    case RequestConnection = "6dc88b50-15c0-41e0-aa6f-c1c33d93303b"
    case ConnectionGranted = "fceee865-ccdc-4c6b-8944-3a959a64d894"
    case ConnectionRefused = "b32f179c-c1b4-40c3-8bb0-ad84a985bad4"
    case ConnectionClose = "70b6f26c-92fc-423f-9ea4-418d51cc0528"
    case Disconnected = "78dfa276-48f3-47bc-88bc-4f46bd9f74ce"
    case DropAsClient = "dc430ff8-c1a3-4d01-8a0a-67997b59da31"
    case Unknown = "1f9e85e3-446b-4c93-b93d-ea8d6955f4bb"
}

/// Types of messages that may be sent or received from other peers.
///
/// - TextMessage: Send a text message.
/// - CommandMessage: Send a command message.
/// - ControlIdiotLight: Control an idiot light.
/// - EchoMessage: Echo the passed message.
/// - Acknowledge: Acknowledge an operation.
/// - Heartbeat: App-level heartbeat message.
/// - KVPData: Set KVP data in the KVP list.
/// - EchoReturn: Contains a returned echo message.
/// - SpecialCommand: Special UI command.
/// - HandShake: Handshake command (see `HandShakeCommands` for sub-commands).
/// - RequestCommandCount: Requests the number of client commands. NOT USED.
/// - GetCommand: Get a command from the client. NOT USED.
/// - CommandByIndex: Return a command by the command index. NOT USED.
/// - SendCommandToClient: Send a command to a client. NOT USED.
/// - ClientCommandResult: Returns the result of a client command.
/// - GetAllClientCommands: Get all client commands.
/// - AllClientCommandsReturned: All client commands returned to the peer that requested them.
/// - IDEncapsulatedCommand: Sends a command encapsulated in an ID - useful for asynchronous returns.
/// - PushVersionInformation: Send version information to another peer.
/// - ConnectionHeartbeat: Connection heartbeat command - used to monitor connection status.
/// - RequestConnectionHeartbeat: Request a heartbeat command to be sent from the selected peer.
/// - BroadcastMessage: Send a message to all peers.
/// - BroadcastCommand: Send a command to all peers.
/// - GetPeerType: Request peer information.
/// - SendPeerType: Send instance information to a peer.
/// - IdiotLightMessage: More complete control of idiot lights.
/// - DebuggerStateChanged: The debug state of the instance changed.
/// - ExecutionStarted: Logging execution started on remote system.
/// - ExecutionTerminated: Logging execution stopped on remote system.
/// - ResetTDebugUI: Clear and reset the UI.
/// - TableCommand: Manage data tables.
/// - Unknown: Unknown command - if explicitly used, it will be ignored.
enum MessageTypes: String, CaseIterable
{
    case TextMessage = "a8d8c35e-f638-47fe-8819-bd04d59c6989"
    case CommandMessage = "a11cac68-6298-4d21-bb84-8746ee544a7b"
    case ControlIdiotLight = "76d9f217-d2b8-4b65-93b4-182e4b38eab2"
    case EchoMessage = "9a904bd0-117b-4548-b31f-da2b4c3807dd"
    case Acknowledge = "73783e04-cad4-42a4-a3b3-449efcabf592"
    case Heartbeat = "5d8a38fd-878a-458f-aa80-62d810e520c1"
    case KVPData = "4c2805b8-d5ad-4c68-a5f8-1f554a90671a"
    case EchoReturn = "970bac64-f399-499d-8db6-c65e508ae40d"
    case SpecialCommand = "e83a5588-b285-49ee-b2fe-95f803f073b7"
    case HandShake = "52c4be7a-b84f-4812-880e-98b4c67543fb"
    case RequestCommandCount = "7eea42d3-7cda-4c4d-bb06-39b52f2cbac9"
    case GetCommand = "ec0d895a-2648-4db8-8d67-20be849edb32"
    case CommandByIndex = "37b02db4-f425-48a8-b6e7-7bbced7a0990"
    case SendCommandToClient = "9cfc1d01-f1f0-4d26-bb38-300ff3df0c92"
    case ClientCommandResult = "79726762-3eeb-450f-8c29-4701857a5073"
    case GetAllClientCommands = "582e3f52-a9ad-4ef3-8842-b8334a547500"
    case AllClientCommandsReturned = "6b3c2e18-879d-488e-b333-2d43eacb9c71"
    case IDEncapsulatedCommand = "c0e8487c-840a-4799-9d9d-906adb96f0a3"
    case PushVersionInformation = "f6a18cea-5806-4e7b-853a-58e96224cd8d"
    case ConnectionHeartbeat = "4bdaa255-16b8-43a6-b263-689c7beb439b"
    case RequestConnectionHeartbeat = "e8b711c9-8672-4ffb-a9b0-230630bd9d7c"
    case BroadcastMessage = "671841fc-b8d6-43da-bd77-288ab7e65918"
    case BroadcastCommand = "fe730b23-3f55-4338-b91e-de0d4560563d"
    case GetPeerType = "1eed12e8-a155-4887-bdcf-904042250769"
    case SendPeerType = "f57ebac8-8bf5-11e9-bc42-526af7764f64"
    case IdiotLightMessage = "fbd09de5-c994-40ba-a8b3-a56979826872"
    case DebuggerStateChanged = "1f98a419-d2a8-4a8e-b618-c729ce78e3ea"
    case ExecutionStarted = "9eac9d1b-4423-40d2-a48c-f15949e48f6e"
    case ExecutionTerminated = "e5d86e41-0810-4065-b944-463d696c3b7e"
    case ResetTDebugUI = "0ed866a9-81d8-4296-aa34-b88ce4a69ab1"
    case TableCommand = "b017ee73-b9f6-47de-8ca1-dd31bcfda4a0"
    case Unknown = "dfc5b2d5-521b-46a8-b459-a4947089312c"
}

/// Describes states of UI features.
///
/// - **Disabled**: Disabled state.
/// - **Enabled**: Enabled state.
enum UIFeatureStates: Int
{
    case Disabled = 0
    case Enabled = 1
}

/// Commands for idiot lights.
///
/// - **Disable**: Disable the specified idiot light. This resets all attributes so you will need to set them again if
///                you re-enable the same idiot light.
/// - **Enable**: Enable the specified idiot light.
/// - **SetText**: Set the text of the specified idiot light.
/// - **SetFGColor**: Set the foreground (text) color.
/// - **SetBGColor**: Set the background color.
/// - **Unknown**: Unknown command. Ignored if you explicitly use it.
enum IdiotLightCommands: Int
{
    case Disable = 0
    case Enable = 1
    case SetText = 2
    case SetFGColor = 3
    case SetBGColor = 4
    case Unknown = 10000
}

/// Set of sub-commands that control how table data is accumulated.
/// - **CreateTable**: Creates a new table in memory.
/// - **DeleteTable**: Deletes an existing table in memory.
/// - **SaveTable**: Saves an existing table to mass storage.
/// - **CloseTable**: Closes but does not delete an existing table.
/// - **AddRow**: Adds a row of data.
/// - **EditRow**: Edits an existing row of data.
/// - **DeleteRow**: Deletes an existing row of data.
/// - **Unknown**: Unknown sub-command. Effectively a NOP.
enum TableCommands: String, CaseIterable
{
    case CreateTable = "3fbf2fce-9a23-11e9-a2a3-2a2ae2dbcce4"
    case DeleteTable = "44b13da6-9a23-11e9-a2a3-2a2ae2dbcce4"
    case SaveTable = "490bd9ba-9a23-11e9-a2a3-2a2ae2dbcce4"
    case CloseTable = "54892c66-9a23-11e9-a2a3-2a2ae2dbcce4"
    case AddRow = "5984cdf6-9a23-11e9-a2a3-2a2ae2dbcce4"
    case EditRow = "5d23b4c2-9a23-11e9-a2a3-2a2ae2dbcce4"
    case DeleteRow = "61843438-9a23-11e9-a2a3-2a2ae2dbcce4"
    case Unknown = "3ef67b98-9a27-11e9-a2a3-2a2ae2dbcce4"
}
