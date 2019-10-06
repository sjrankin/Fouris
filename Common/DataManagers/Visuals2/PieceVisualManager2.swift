//
//  PieceVisualManager2.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages piece visual information.
class PieceVisualManager2
{
    /// Creates initial piece visual files from resource-bound files and places them in the settings directory.
    private static func CreateVisualsFiles()
    {
        let DefaultVisuals = FileIO.GetFileContentsFromResource("DefaultPieceVisuals", ".xml")
        let _ = FileIO.SaveSettingsFile(Name: "DefaultPieceVisuals.xml", Contents: DefaultVisuals!)
        let UserVisuals = FileIO.GetFileContentsFromResource("UserPieceVisuals", ".xml")
        let _ = FileIO.SaveSettingsFile(Name: "UserPieceVisuals.xml", Contents: UserVisuals!)
    }
    
    /// Ensures files are present. If not, they are created.
    public static func Preinitialize()
    {
        if !FileIO.DirectoryExists(DirectoryName: FileIO.SettingsDirectory)
        {
            print("Creating settings directory.")
            FileIO.CreateDirectory(DirectoryName: FileIO.SettingsDirectory)
            CreateVisualsFiles()
        }
        else
        {
            if !FileIO.FileExists(FileName: "DefaultPieceVisuals.xml", Directory: FileIO.SettingsDirectory)
            {
                print("No piece visual files - creating.")
                CreateVisualsFiles()
            }
        }
    }
    
    /// Initialize the piece visual manager.
    public static func Initialize()
    {
        Preinitialize()
        DefaultVisualsDocument = XMLDocument(File: FileIO.MakeFileURL(FileName: "DefaultPieceVisuals.xml", Directory: FileIO.SettingsDirectory)!)
        _DefaultVisuals = PieceVisuals2()
        let _ = DefaultVisualsDocument?.DeserializeTo(Caller: _DefaultVisuals!)
        UserVisualsDocument = XMLDocument(File: FileIO.MakeFileURL(FileName: "UserPieceVisuals.xml", Directory: FileIO.SettingsDirectory)!)
        _UserVisuals = PieceVisuals2()
        let _ = UserVisualsDocument?.DeserializeTo(Caller: _UserVisuals!)
    }
    
    /// Holds the default visual document.
    private static var DefaultVisualsDocument: XMLDocument? = nil
    /// Holds the user visual document.
    private static var UserVisualsDocument: XMLDocument? = nil
    
    /// Holds the default visuals.
    private static var _DefaultVisuals: PieceVisuals2? = nil
    /// Holds the user visuals.
    private static var _UserVisuals: PieceVisuals2? = nil
    
    /// Get or set the user visuals.
    public static var UserVisuals: PieceVisuals2?
    {
        get
        {
            return _UserVisuals
        }
        set
        {
            _UserVisuals = newValue
        }
    }
    
    /// Get or set the default visuals.
    public static var DefaultVisuals: PieceVisuals2?
    {
        get
        {
            return _DefaultVisuals
        }
        set
        {
            _DefaultVisuals = newValue
        }
    }
    
    /// Save user-defined visuals.
    public static func SaveUserVisuals()
    {
        UserVisuals?.Updated = DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .long)
        let Serialized = UserVisuals!.ToString()
        let _ = FileIO.SaveSettingsFile(Name: "UserPieceVisuals.xml", Contents: Serialized)
    }
}
