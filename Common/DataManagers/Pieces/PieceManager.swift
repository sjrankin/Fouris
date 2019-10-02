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
    
    /// Returns all piece definitions of a given class and piece collection.
    /// - Parameter WithType: The piece class pieces to return.
    /// - Parameter InCollection: The piece collection to search to return piece definitions.
    /// - Returns: List of piece definitions that match the passed search criteria.
    public static func GetPieceClass(WithType: PieceClasses, InCollection: PieceCollection) -> [PieceDefinition]?
    {
        return InCollection.GetPieceClass(WithType)
    }
    
    /// Returns a list of all piece defintions for a given class.
    /// - Parameter Class: The piece class whose piece definitions will be returned.
    /// - Returns: All piece definitions for a given piece class. If the returned list is empty,
    ///            either the piece class was not found or it contained no definitions.
    public static func GetPiecesForClass(_ Class: PieceClasses) -> [PieceDefinition]
    {
        var Results = [PieceDefinition]()
        let AllGroups = [_DefaultPieces, _UserPieces]
        for PieceGroup in AllGroups
        {
            for (TheClass, PieceSet) in PieceGroup!.Classes
            {
                if TheClass == Class
                {
                    for SomePiece in PieceSet
                    {
                        Results.append(SomePiece)
                    }
                }
            }
        }
        return Results
    }
    
    /// Return a piece definition for a piece with the specified ID.
    /// - Parameter ID: The ID whose piece definition will be returned.
    /// - Returns: Piece defintion for the specified ID on success, nil if not found.
    public static func GetPieceDefinitionFor(ID: UUID) -> PieceDefinition?
    {
        for (_, Def) in DefaultPieces!.Classes
        {
            for PieceDef in Def
            {
            if PieceDef.ID == ID
            {
                return PieceDef
            }
            }
        }
        return nil
    }
    
    /// Save user piece definitions.
    public static func SaveUserPieces()
    {
        let Serialized = UserPieces?.ToString()
        let _ = FileIO.SaveSettingsFile(Name: "UserPieceDescriptions.xml", Contents: Serialized!)
    }
}
