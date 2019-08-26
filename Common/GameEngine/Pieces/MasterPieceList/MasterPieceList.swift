//
//  MasterPieceList.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Loads and manages the master list of all piece definitions. The list is stored in an XML fragment file in the resources directory
/// of the application and deserialized at start-up.
class MasterPieceList
{
    /// Initialize the master piece list. Load the serialized piece list and deserialize into something we can use.
    ///
    /// - Note: A fatal error will be generated if there is an error reading the contents of the piece definition file or if
    ///         there is an error deserializing the raw contents of the piece definition file.
    public static func Initialize()
    {
        _PieceDefinitions = [PieceDefinition]()
        if let SerializedPieces = FileIO.GetFileContentsFromResource("PieceDescriptions", ".xml")
        {
            let Deserialize = Serializer()
            if Deserialize.Deserialize(From: SerializedPieces)
            {
                CreatePieces(Deserialize)
            }
            else
            {
                fatalError("Error deserializing PieceDescriptions.xml")
            }
        }
        else
        {
            fatalError("Unable to read piece definitions.")
        }
    }
    
    /// Create the list of pieces for the master piece list.
    ///
    /// - Parameter Deserialized: Serializer/deserializer with the raw, tokenized contents of the piece definition file.
    private static func CreatePieces(_ Deserialized: Serializer)
    {
        let Root = Deserialized.Tree!.Root
        for Node in Root.Children
        {
            if Node.Title == "Piece"
            {
                let PDef = PieceDefinition()
                for Child in Node.Children
                {
                    let ChildType = Child.Title
                    if ChildType == "Property"
                    {
                        var Key = Child.AttributeValue(For: "Name")
                        Key = Key?.replacingOccurrences(of: "\"", with: "")
                        var Value = Child.AttributeValue(For: "Value")
                        Value = Value?.replacingOccurrences(of: "\"", with: "")
                        PDef.Populate(Key: Key!, Value: Value!)
                    }
                    if ChildType == "Array"
                    {
                        var ArrayName = Child.AttributeValue(For: "Name")
                        ArrayName = ArrayName?.replacingOccurrences(of: "\"", with: "")
                        PDef.LogicalLocations = [LogicalLocation]()
                        for Element in Child.Children
                        {
                            let ItemType = Element.Title.replacingOccurrences(of: "<", with: "")
                            if ItemType == "Item"
                            {
                                let Location = LogicalLocation()
                                for ItemNode in Element.Children
                                {
                                    var Name = ItemNode.AttributeValue(For: "Name")
                                    Name = Name?.replacingOccurrences(of: "\"", with: "")
                                    var Value = ItemNode.AttributeValue(For: "Value")
                                    Value = Value?.replacingOccurrences(of: "\"", with: "")
                                    Location.Populate(Key: Name!, Value: Value!)
                                }
                                PDef.LogicalLocations.append(Location)
                            }
                        }
                    }
                }
                _PieceDefinitions.append(PDef)
            }
        }
    }
    
    /// Holds the list of piece definitions.
    private static var _PieceDefinitions = [PieceDefinition]()
    /// Get the list of piece definitions.
    public static var PieceDefinitions: [PieceDefinition]
    {
        get
        {
            return _PieceDefinitions
        }
    }
    
    /// Returns all of the pieces for the specified piece class.
    ///
    /// - Parameter Class: The class whose pieces will be returned.
    /// - Returns: List of all pieces in the specified class. If the returned list is empty, no pieces were found for the passed
    ///            piece class.
    public static func GetPiecesForClass(_ Class: PieceClasses) -> [PieceDefinition]
    {
        var Results = [PieceDefinition]()
        for PDef in PieceDefinitions
        {
            if PDef.PieceClass == Class
            {
                Results.append(PDef)
            }
        }
        return Results
    }
    
    /// Given the ID of a piece, return its definition.
    ///
    /// - Parameter ID: The ID of the piece whose definition will be returned.
    /// - Returns: Definition of the specified piece on success, nil if not found.
    public static func GetPieceDefinitionFor(ID: UUID) -> PieceDefinition?
    {
        for PDef in PieceDefinitions
        {
            if PDef.ID == ID
            {
                return PDef
            }
        }
        return nil
    }
}
