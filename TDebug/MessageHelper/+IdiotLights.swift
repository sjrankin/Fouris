//
//  +IdiotLights.swift
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
    // MARK: Idiot light encoding commands.
    
    //public static func MakeIdiotLightMessage(Address: String, Message: String, FGColor: OSColor, BGColor: OSColor) -> String
    public static func MakeIdiotLightMessage(Address: String, Message: String,
                                            FGColor: ColorNames,
                                            BGColor: ColorNames) -> String
    {
        let P1 = "Address=\(Address)"
        let P2 = "Message=\(Message)"
        let P3 = "FGColor=" + ColorServer.MakeHexString(From: FGColor)
        let P4 = "BGColor=" + ColorServer.MakeHexString(From: BGColor)
        let Final = GenerateCommand(Command: .IdiotLightMessage, Prefix: PrefixCode, Parts: [P1, P2, P3, P4])
        return Final
    }
    
    public static func MakeIdiotLightMessage(Address: String, State: UIFeatureStates) -> String
    {
        let Addr = "Address=\(Address)"
        let Action = "Enable=" + [UIFeatureStates.Disabled: "No", UIFeatureStates.Enabled: "Yes"][State]!
        let Final = GenerateCommand(Command: .ControlIdiotLight, Prefix: PrefixCode, Parts: [Addr, Action])
        return Final
    }
    
    public static func MakeIdiotLightMessage(Address: String, Text: String) -> String
    {
        let Addr = "Address=\(Address)"
        let Action = "Text=" + Text
        let Final = GenerateCommand(Command: .ControlIdiotLight, Prefix: PrefixCode, Parts: [Addr, Action])
        return Final
    }
    
    public static func MakeIdiotLightMessage(Address: String, FGColor: ColorNames) -> String
    {
        let Addr = "Address=\(Address)"
        let Action1 = "FGColor=" + ColorServer.MakeHexString(From: FGColor)
        let Final = GenerateCommand(Command: .ControlIdiotLight, Prefix: PrefixCode, Parts: [Addr, Action1])
        return Final
    }
    
    public static func MakeIdiotLightMessage(Address: String, BGColor: ColorNames) -> String
    {
        let Addr = "Address=\(Address)"
        let Action1 = "BGColor=" + ColorServer.MakeHexString(From: BGColor)
        let Final = GenerateCommand(Command: .ControlIdiotLight, Prefix: PrefixCode, Parts: [Addr, Action1])
        return Final
    }
    
    // MARK: Idiot light command decoding.
    
    public static func DecodeIdiotLightCommand(_ Raw: String) -> (MessageTypes, String, String, String)
    {
        if Raw.isEmpty
        {
            return (MessageTypes.Unknown, "", "", "")
        }
        let Delimiter = String(Raw.first!)
        var Next = Raw
        Next.removeFirst()
        let Parts = Next.split(separator: String.Element(Delimiter), maxSplits: 4, omittingEmptySubsequences: false)
        if Parts.count != 4
        {
            //Assume the last item in the parts list is the message and return it as an unknown type.
            return (MessageTypes.Unknown, "", "", String(Parts[Parts.count - 1]))
        }
        return (MessageTypeFromID(String(Parts[0])), String(Parts[1]), String(Parts[2]), String(Parts[3]))
    }
    
    //Format of command: command,address{,data}
    //returns command, address, text, fg color, bg color
    public static func DecodeIdiotLightMessage(_ Raw: String) ->(IdiotLightCommands, String, String?, UIColor?, UIColor?)
    {
        let Params = GetParameters(From: Raw, ["Address", "Enable", "Text", "BGColor", "FGColor"])
        var Address = ""
        var Text: String? = nil
        var Command: IdiotLightCommands = .Unknown
        var BGColor: UIColor? = nil
        var FGColor: UIColor? = nil
        for (Key, Value) in Params
        {
            switch Key
            {
            case "Address":
                Address = Value
                
            case "Enable":
                if Value.lowercased() == "yes"
                {
                    Command = .Enable
                }
                else
                {
                    Command = .Disable
                }
                break
                
            case "Text":
                Command = .SetText
                Text = Value
                
            case "BGColor":
                Command = .SetBGColor
                BGColor = UIColor(HexString: Value)!
                
            case "FGColor":
                Command = .SetFGColor
                FGColor = UIColor(HexString: Value)!
                
            default:
                continue
            }
        }
        return (Command, Address, Text, FGColor, BGColor)
    }
    
    public static func DecodeIdiotLightMessage2(_ Raw: String) -> IdiotLightMessage?
    {
        #if true
        //This function is not needed in Wacky Tetris as it doesn't have idiot lights.
        return nil
        #else
        let Params = GetParameters(From: Raw, ["Address", "Message", "BGColor", "FGColor"])
                let Result = IdiotLightMessage()
        for (Key, Value) in Params
        {
            switch Key
            {
            case "Address":
                Result.Address = Value
                
            case "Message":
                Result.Message = Value
                
            case "FGColor":
                Result.FGColor = Value
                
            case "BGColor":
                Result.BGColor = Value
                
            default:
                continue
            }
        }
        return Result
        #endif
    }
}
