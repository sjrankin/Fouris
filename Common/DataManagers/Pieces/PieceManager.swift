//
//  PieceManager.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PieceManager
{
    /// Copies resource-bound default piece descriptions to the settings directory.
    private static func CreatePieceFiles()
    {
        let DefaultDescriptions = FileIO.GetFileContentsFromResource("PieceDescriptions", ".xml")
        let _ = FileIO.SaveSettingsFile(Name: "PieceDescriptions.xml", Contents: DefaultDescriptions!)
        let UserDescriptions = FileIO.GetFileContentsFromResource("UserPieceDescriptions", ".xml")
        let _ = FileIO.SaveSettingsFile(Name: "UserPieceDescriptions.xml", Contents: UserDescriptions!)
    }
    
    /// Check to see if the working set of piece description files are in the settings directory. If not, add them. Also, if
    /// necessary, create the settings directory.
    /// - Note: If the settings directory exists but `PieceDescriptions.xml` is not present, **both** `PieceDescriptions.xml` and
    ///         `UserPieceDescriptions.xml` are created.
    private static func Preinitialize()
    {
        if !FileIO.DirectoryExists(DirectoryName: FileIO.SettingsDirectory)
        {
            print("Creating initial piece descriptions.")
            CreatePieceFiles()
        }
        else
        {
            if !FileIO.FileExists(FileName: "PieceDescriptions.xml", Directory: FileIO.SettingsDirectory)
            {
                CreatePieceFiles()
            }
        }
    }
    
    /// Initialize the piece manager.
    public static func Initialize()
    {
        Preinitialize()
        DefaultPieceDocument = XMLDocument(File: FileIO.MakeFileURL(FileName: "PieceDescriptions.xml", Directory: FileIO.SettingsDirectory)!)
        UserPieceDocument = XMLDocument(File: FileIO.MakeFileURL(FileName: "UserPieceDescriptions.xml", Directory: FileIO.SettingsDirectory)!)
        _DefaultPieces = PieceCollection()
        let _ = DefaultPieceDocument?.DeserializeTo(Caller: _DefaultPieces!)
        _UserPieces = PieceCollection()
        let _ = UserPieceDocument?.DeserializeTo(Caller: _UserPieces!)
    }
    
    static var DefaultPieceDocument: XMLDocument? = nil
    static var UserPieceDocument: XMLDocument? = nil
    
    private static var _DefaultPieces: PieceCollection? = nil
    private static var _UserPieces: PieceCollection? = nil
    
    /// Get or set the collection of default pieces.
    public static var DefaultPieces: PieceCollection?
    {
        get
        {
            return _DefaultPieces
        }
        set
        {
            _DefaultPieces = newValue
        }
    }
    
    /// Get or set the collection of user pieces.
    public static var UserPieces: PieceCollection?
    {
        get
        {
            return _UserPieces
        }
        set
        {
            _UserPieces = newValue
        }
    }
    
    public static func GetPieceClass(WithType: PieceClasses, InCollection: PieceCollection) -> [PieceDefinition2]?
    {
        return InCollection.GetPieceClass(WithType)
    }
}
