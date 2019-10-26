//
//  +VersionInfo.swift
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
    // MARK: - Versioning command encoding commands.
    
    /// Make a version push command string.
    ///
    /// - Parameters:
    ///   - Name: Name of the program.
    ///   - OS: OS under which the program runs.
    ///   - Version: Version number.
    ///   - Build: Build number.
    ///   - BuildTimeStamp: Build time-stamp.
    ///   - Copyright: Copyright string.
    ///   - BuildID: Build ID.
    ///   - ProgramID: ID that identifies a program.
    /// - Returns: Command string that pushes program information to a peer.
    public static func MakeSendVersionInfo(Name: String, OS: String, Version: String, Build: String, BuildTimeStamp: String,
                                           Copyright: String, BuildID: String, ProgramID: UUID) -> String
    {
        let Name = "Name=\(Name)"
        let OS = "OS=\(OS)"
        let Ver = "Version=\(Version)"
        let Bld = "Build=\(Build)"
        let BTS = "BuildTimeStamp=\(BuildTimeStamp)"
        let Cpr = "Copyright=\(Copyright)"
        let BID = "BuildID=\(BuildID)"
        let PgmID = "ProgramID=\(ProgramID)"
        let Final = GenerateCommand(Command: .PushVersionInformation, Prefix: PrefixCode,
                                    Parts: [Name, OS, Ver, Bld, BTS, Cpr, BID, PgmID])
        return Final
    }
    
    /// Make a version push command string from the static Versioning class.
    /// - Returns: Command string that pushes program information to a peer.
    public static func MakeSendVersionInfo() -> String
    {
        return MakeSendVersionInfo(Name: Versioning.ApplicationName,
                                   OS: Versioning.IntendedOS,
                                   Version: Versioning.MakeVersionString(IncludeVersionSuffix: true, IncludeVersionPrefix: false),
                                   Build: "\(Versioning.Build)",
            BuildTimeStamp: Versioning.BuildDate + " " + Versioning.BuildTime,
            Copyright: Versioning.CopyrightText(),
            BuildID: Versioning.BuildID,
            ProgramID: Versioning.ProgramIDAsUUID())
    }
    
    // MARK: - Version command decoding.
    
    /// Decode a pushed version message.
    ///
    /// - Parameter Raw: Raw message text.
    /// - Returns: Decoded version information in the order: (Program Name, Host OS, Version, Build, Build Time Stamp, Copyright, Build ID, Program ID).
    public static func DecodeVersionInfo(_ Raw: String) -> (String, String, String, String, String, String, String, String)
    {
        let Params = GetParameters(From: Raw, ["Name", "OS", "Version", "Build", "BuildTimeStamp",
                                               "Copyright", "BuildID", "ProgramID"])
        var Name = ""
        var OS = ""
        var Version = ""
        var Build = ""
        var BuildTimeStamp = ""
        var Copyright = ""
        var BuildID = ""
        var ProgramID = ""
        for (Key, Value) in Params
        {
            switch Key
            {
            case "Name":
                Name = Value
                
            case "OS":
                OS = Value
                
            case "Version":
                Version = Value
                
            case "Build":
                Build = Value
                
            case "BuildTimeStamp":
                BuildTimeStamp = Value
                
            case "Copyright":
                Copyright = Value
                
            case "BuildID":
                BuildID = Value
                
            case "ProgramID":
                ProgramID = Value
                
            default:
                print("Found unanticipated version key: \(Key)")
            }
        }
        return (Name, OS, Version, Build, BuildTimeStamp, Copyright, BuildID, ProgramID)
    }
}
