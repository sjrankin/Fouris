//
//  PieceVisualManager.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages the data for visual descriptions of pieces and blocks.
/// - Note: `PieceVisualManager.Initialize()` should be called as soon as possible to ensure block visuals will be available.
class PieceVisualManager
{
    /// Standard (eg, default) theme ID. This is the fallback theme for pieces that are not customized by the user.
    public static let StandardVisualThemeID = UUID(uuidString: "cd0585e3-7e0c-4279-952d-04d40ba1f9dc")!
    /// For now, the user's visual theme ID.
    private static let UserVisualThemeID = UUID(uuidString: "0f30efd7-eed5-4c38-9d29-fd98a7cacb67")!
    
    /// Initialize the Piece Visual Manager. Visuals are stored in files in the resource directory and read and deserialized
    /// here.
    public static func Initialize()
    {
        if let SerializedGameVisuals = FileIO.GetFileContentsFromResource("PieceVisuals", ".xml")
        {
            let Serialize = Serializer()
            let DeserializedOK = Serialize.Deserialize(From: SerializedGameVisuals)
            if DeserializedOK
            {
                CreateVisuals(Serialize, IsUser: false)
            }
        }
        if let SerializedUserVisuals = FileIO.GetFileContentsFromResource("UserVisuals", ".xml")
        {
            let Serialize = Serializer()
            let DeserializedOK = Serialize.Deserialize(From: SerializedUserVisuals)
            if DeserializedOK
            {
                CreateVisuals(Serialize, IsUser: true)
            }
        }
    }
    
    /// Holds the current theme ID.
    private static var _CurrentThemeID: UUID = UUID.Empty
    /// Get or set the ID of the current theme. If the theme does not match a known theme, this value will be set to the default
    /// theme ID.
    public static var CurrentThemeID: UUID
    {
        get
        {
            return _CurrentThemeID
        }
        set
        {
            var FoundTheme = false
            for Theme in VisualThemes
            {
                if Theme.ID == newValue
                {
                    FoundTheme = true
                    break
                }
            }
            if FoundTheme
            {
                _CurrentThemeID = newValue
            }
            else
            {
                _CurrentThemeID = StandardVisualThemeID
            }
        }
    }
    
    /// Holds all loaded themes.
    private static var _VisualThemes: [PieceVisuals] = [PieceVisuals]()
    /// Get or set the list of loaded themes.
    public static var VisualThemes: [PieceVisuals]
    {
        get
        {
            return _VisualThemes
        }
        set
        {
            _VisualThemes = newValue
        }
    }
    
    /// Given a piece ID, return the visual description for it in the current theme. If the current theme does not contain
    /// the piece, nil is returned.
    /// - Parameter PieceID: The ID of the piece whose descriptor will be returned.
    /// - Returns: The visual descriptor of the piece whose ID is passed to us. If not found as described in the comments, nil
    ///            will be returned.
    public static func GetPieceTheme(PieceID: UUID) -> VisualDescriptor?
    {
        if let Descriptor = GetPieceTheme(PieceID: PieceID, ThemeID: UserVisualThemeID)
        {
            return Descriptor
        }
        return GetPieceTheme(PieceID: PieceID, ThemeID: StandardVisualThemeID)
    }
    
    /// Given a piece shape, return the visual description for it in the current theme. If the current theme does not contain
    /// the piece, nil is returned.
    /// - Parameter PieceShape: The shape of the piece whose descriptor will be returned.
    /// - Returns: The visual descriptor of the piece whose shape is passed to us. If not found as described in the comments, nil
    ///            will be returned.
    public static func GetPieceTheme(PieceShape: PieceShapes) -> VisualDescriptor?
    {
        return GetPieceTheme(PieceID: PieceFactory.ShapeIDMap[PieceShape]!)
    }
    
    /// Given a piece ID, return the visual description for it in the theme whose ID is also passed.
    /// - Parameter PieceID: The ID of the piece whose visual descriptor will be returned.
    /// - Parameter ThemeID: The ID of the theme to search for the piece visuals.
    /// - Returns: The visual descriptor of the piece whose ID is passed in the theme whose ID is passed. Nil is returned if no
    ///            piece with the passed ID is found.
    public static func GetPieceTheme(PieceID: UUID, ThemeID: UUID) -> VisualDescriptor?
    {
        for VisualTheme in VisualThemes
        {
            if VisualTheme.ID == ThemeID
            {
                for PieceVisual in VisualTheme.VisualsList
                {
                    if PieceVisual.ID == PieceID
                    {
                        return PieceVisual
                    }
                }
            }
        }
        return nil
    }
    
    /// Given a piece shape, return the visual description for it in the theme whose ID is passed.
    /// - Parameter PieceShape: The shape of the piece whose visual descriptor will be returned.
    /// - Parameter ThemeID: The ID of the theme to search for the piece visuals.
    /// - Returns: The visual descriptor of the piece whose shape is passed in the theme whose ID is passed. Nil is returned if no
    ///            piece with the passed shape is found.
    public static func GetPieceTheme(PieceShape: PieceShapes, ThemeID: UUID) -> VisualDescriptor?
    {
        return GetPieceTheme(PieceID: PieceFactory.ShapeIDMap[PieceShape]!, ThemeID: ThemeID)
    }
    
    /// Parses the deserialized file into instance classes holding piece visual information.
    /// - Parameter Deserialized: Serializer that contains deserialized data that will be parsed.
    /// - Parameter IsUser: Not currently used.
    private static func CreateVisuals(_ Deserialized: Serializer, IsUser: Bool)
    {
        let Root = Deserialized.Tree!.Root
        for Node in Root.Children
        {
            if let NodeName = Node.AttributeValue(For: "Name")
            {
                let Name = NodeName.replacingOccurrences(of: "\"", with: "")
                print("Found: \(Name)")
                let Visuals = PieceVisuals()
                for Child in Node.Children
                {
                    let ChildType = Child.Title
                    if ChildType == "Property"
                    {
                        var Key = Child.AttributeValue(For: "Name")
                        Key = Key?.replacingOccurrences(of: "\"", with: "")
                        var Value = Child.AttributeValue(For: "Value")
                        Value = Value?.replacingOccurrences(of: "\"", with: "")
                        Visuals.Populate(Key: Key!, Value: Value!)
                    }
                    if ChildType == "Array"
                    {
                        var ArrayName = Child.AttributeValue(For: "Name")
                        ArrayName = ArrayName?.replacingOccurrences(of: "\"", with: "")
                        Visuals.VisualsList = [VisualDescriptor]()
                        for Element in Child.Children
                        {
                            let ItemType = Element.Title.replacingOccurrences(of: "\"", with: "")
                            if ItemType == "Item"
                            {
                                let PieceVisual = VisualDescriptor()
                                for ItemNode in Element.Children
                                {
                                    var Name = ItemNode.AttributeValue(For: "Name")
                                    Name = Name?.replacingOccurrences(of: "\"", with: "")
                                    var Value = ItemNode.AttributeValue(For: "Value")
                                    Value = Value?.replacingOccurrences(of: "\"", with: "")
                                    PieceVisual.Populate(Key: Name!, Value: Value!)
                                }
                                Visuals.VisualsList.append(PieceVisual)
                            }
                        }
                    }
                }
                _VisualThemes.append(Visuals)
            }
        }
    }
}
