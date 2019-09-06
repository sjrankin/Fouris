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
class PieceVisualManager
{
    public static let StandardVisualThemeID = UUID(uuidString: "cd0585e3-7e0c-4279-952d-04d40ba1f9dc")!
    private static let UserVisualThemeID = UUID(uuidString: "0f30efd7-eed5-4c38-9d29-fd98a7cacb67")!
    
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
    
    private static var _CurrentThemeID: UUID = UUID.Empty
    public static var CurrentThemeID: UUID
    {
        get
        {
            return _CurrentThemeID
        }
        set
        {
            _CurrentThemeID = newValue
        }
    }
    
    private static var _VisualThemes: [PieceVisuals] = [PieceVisuals]()
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
    
    public static func GetPieceTheme(PieceID: UUID) -> VisualDescriptor?
    {
        if let Descriptor = GetPieceTheme(PieceID: PieceID, ThemeID: UserVisualThemeID)
        {
            return Descriptor
        }
        return GetPieceTheme(PieceID: PieceID, ThemeID: StandardVisualThemeID)
    }
    
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
    
    private static func CreateVisuals(_ Deserialized: Serializer, IsUser: Bool)
    {
        let Root = Deserialized.Tree!.Root
        for Node in Root.Children
        {
            if let NodeName = Node.AttributeValue(For: "Name")
            {
                let Name = NodeName.replacingOccurrences(of: "\"", with: "")
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
