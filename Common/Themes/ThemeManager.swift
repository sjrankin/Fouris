//
//  ThemeManager.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// This class manages visual themes for the pieces, background, text, and bucket. Themes are saved as files in the resource
/// directory of the app.
class ThemeManager
{
    /// Initialize the theme manager. Read standard themes from a serialized file in the resource directory. Set the
    /// current theme.
    public static func Initialize()
    {
        _ThemeList = [(String, ThemeDescriptor)]()
        if let SerializedTheme = FileIO.GetFileContentsFromResource("StandardThemes", ".xml")
        {
            let Serialize = Serializer()
            let DeserializedOK = Serialize.Deserialize(From: SerializedTheme)
            if DeserializedOK
            {
                CreateThemes(Serialize)
            }
        }
        if _ThemeList.count == 0
        {
            fatalError("Error reading themes.")
        }
        let SavedID = Settings.GetCurrentThemeID()
        if SavedID == UUID.Empty
        {
            CurrentThemeID = _ThemeList[0].1.ID
        }
        else
        {
            CurrentThemeID = Settings.GetCurrentThemeID()
        }
    }
    
    /// Save themes. This applies only to user-defined themes as the standard themes are read-only.
    ///
    /// - Note: When in debug mode, standard themes are written as well.
    public static func SaveThemes()
    {
        let Encoder = Serializer()
        var Serialized = ""
        for ThemeMetadata in GetBuiltInThemes()
        {
            let Theme = ThemeFrom(ID: ThemeMetadata.1)
            if Theme!.Dirty
            {
                Serialized = Serialized + Encoder.Encode(Theme!, WithTitle: Theme!.ThemeName)
            }
        }
        //Write serialized standard theme here.
        //print(Serialized)
        let _ = FileIO.SaveFileContentsToResource(WithContents: Serialized, "StandardThemes", ".xml")
        
        var UserSerialized = ""
        for ThemeMetaData in GetUserThemes()
        {
            let Theme = ThemeFrom(ID: ThemeMetaData.1)
            if Theme!.Dirty
            {
                UserSerialized = UserSerialized + Encoder.Encode(Theme!, WithTitle: Theme!.ThemeName)
            }
        }
        //Write serialized user themes here.
        //print(UserSerialized)
        let _ = FileIO.SaveFileContentsToResource(WithContents: UserSerialized, "UserThemes", ".xml")
    }
    
    /// Create themes from the deserialized data.
    ///
    /// - Parameter Deserialized: Serializer instance with deserialized data.
    private static func CreateThemes(_ Deserialized: Serializer)
    {
        let Root = Deserialized.Tree!.Root
        for Node in Root.Children
        {
            if let NodeName = Node.AttributeValue(For: "Name")
            {
                let Name = NodeName.replacingOccurrences(of: "\"", with: "")
                let Theme = ThemeDescriptor()
                for Child in Node.Children
                {
                    let ChildType = Child.Title
                    if ChildType == "Property"
                    {
                        var Key = Child.AttributeValue(For: "Name")
                        Key = Key?.replacingOccurrences(of: "\"", with: "")
                        var Value = Child.AttributeValue(For: "Value")
                        Value = Value?.replacingOccurrences(of: "\"", with: "")
                        Theme.Populate(Key: Key!, Value: Value!)
                    }
                    if ChildType == "Array"
                    {
                        var ArrayName = Child.AttributeValue(For: "Name")
                        ArrayName = ArrayName?.replacingOccurrences(of: "\"", with: "")
                        Theme.TileList = [TileDescriptor]()
                        for Element in Child.Children
                        {
                            let ItemType = Element.Title.replacingOccurrences(of: "<", with: "")
                            if ItemType == "Item"
                            {
                                let TileData = Theme.MakeTileDescriptor()
                                for ItemNode in Element.Children
                                {
                                    var Name = ItemNode.AttributeValue(For: "Name")
                                    Name = Name?.replacingOccurrences(of: "\"", with: "")
                                    var Value = ItemNode.AttributeValue(For: "Value")
                                    Value = Value?.replacingOccurrences(of: "\"", with: "")
                                    TileData.Populate(Key: Name!, Value: Value!)
                                }
                                Theme.TileList.append(TileData)
                            }
                        }
                    }
                }
                _ThemeList.append((Name, Theme))
            }
        }
    }
    
    /// Holds a list of all themes.
    private static var _ThemeList = [(String, ThemeDescriptor)]()
    
    /// Holds the current theme.
    private static var _Current: ThemeDescriptor? = nil
    /// Get the current theme. If nil, try to load a theme first.
    public static var Current: ThemeDescriptor?
    {
        get
        {
            return _Current
        }
    }
    
    /// Holds the current theme ID. Updates `Current` when set with a valid ID.
    private static var _CurrentThemeID: UUID = UUID.Empty
    {
        didSet
        {
            if _CurrentThemeID == UUID.Empty
            {
                return
            }
            if let Theme = ThemeFrom(ID: _CurrentThemeID)
            {
                _Current = Theme
            }
        }
    }
    /// Get or set the current theme's ID. Use this property to set themes.
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
    
    /// Return a list of user-defined themes.
    ///
    /// - Returns: List of tuples in the order: (theme title, theme ID), one for each user-defined theme.
    public static func GetUserThemes() -> [(String, UUID)]
    {
        var Results = [(String, UUID)]()
        for (Title, Theme) in _ThemeList
        {
            if Theme.UserTheme
            {
                Results.append((Title, Theme.ID))
            }
        }
        return Results
    }
    
    /// Return a list of built-in themes.
    ///
    /// - Returns: List of tuples in the order: (theme title, theme ID), one for each built-in theme.
    public static func GetBuiltInThemes() -> [(String, UUID)]
    {
        var Results = [(String, UUID)]()
        for (Title, Theme) in _ThemeList
        {
            if !Theme.UserTheme
            {
                Results.append((Title, Theme.ID))
            }
        }
        return Results
    }
    
    /// Return a list of all themes.
    ///
    /// - Returns: List of tuples in the order: (theme title, theme ID), one for each theme.
    public static func GetAllThemes() -> [(String, UUID)]
    {
        var Results = [(String, UUID)]()
        for (Title, Theme) in _ThemeList
        {
            Results.append((Title, Theme.ID))
        }
        return Results
    }
    
    /// Given a theme ID, return the theme.
    ///
    /// - Parameter ID: ID of the theme to return.
    /// - Returns: The theme associated with the passed ID. Nil if not found.
    public static func ThemeFrom(ID: UUID) -> ThemeDescriptor?
    {
        for (_, Theme) in _ThemeList
        {
            if Theme.ID == ID
            {
                return Theme
            }
        }
        return nil
    }
    
    /// Given a theme ID, return the name of the associated theme.
    ///
    /// - Parameter ID: ID of the name to return.
    /// - Returns: The theme name associated with the passed ID. Nil if not found.
    public static func ThemeNameFrom(ID: UUID) -> String?
    {
        if let Theme = ThemeFrom(ID: ID)
        {
            return Theme.ThemeName
        }
        return nil
    }
    
    /// Return the default theme.
    /// - Returns: The default theme descriptor.
    public static func GetDefaultTheme() -> ThemeDescriptor?
    {
        for (_, Theme) in _ThemeList
        {
            if Theme.IsDefaultTheme
            {
                return Theme
            }
        }
        return nil
    }
    
    /// Returns the default 3D theme.
    /// - Returns: The default 3D theme descriptor.
    public static func GetDefault3DTheme() -> ThemeDescriptor?
    {
        for (_, Theme) in _ThemeList
        {
            if Theme.Default3DTheme
            {
                return Theme
            }
        }
        return nil
    }
    
    /// Returns the default 3D theme ID.
    /// - Returns: The default 3D theme ID.
    public static func GetDefault3DThemeID() -> UUID?
    {
        for (_, Theme) in _ThemeList
        {
            if Theme.Default3DTheme
            {
                return Theme.ID
            }
        }
        return nil
    }
}
