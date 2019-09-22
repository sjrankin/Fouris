//
//  ThemeManager.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// This class manages visual themes for the pieces, background, text, and bucket. Themes are saved as files in the resource
/// directory of the app.
class ThemeManager: ThemeChangeProtocol
{
    /// Initialize the theme manager. Read standard themes from a serialized file in the resource directory. Set the
    /// current theme.
    public func Initialize()
    {
        _ThemeList = [(String, ThemeDescriptor)]()
        if let SerializedTheme = FileIO.GetFileContentsFromResource("GameThemes", ".xml")
        {
            let Serialize = Serializer()
            let DeserializedOK = Serialize.Deserialize(From: SerializedTheme)
            if DeserializedOK
            {
                CreateThemes(Serialize, WithName: "GameThemes.xml")
            }
        }
        if let SerializedTheme = FileIO.GetFileContentsFromResource("UserGameThemes", ".xml")
        {
            let Serialize = Serializer()
            let DeserializedOK = Serialize.Deserialize(From: SerializedTheme)
            if DeserializedOK
            {
                CreateThemes(Serialize, WithName: "UserGameThemes.xml")
            }
        }
        if _ThemeList.count != 2
        {
            fatalError("Error reading themes. Missing either default or user theme.")
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
    
    /// Save the user theme. This applies only to user-defined themes as the standard default theme is read-only.
    /// - Note: Default theme is never written.
    public func SaveThemes()
    {
        let Encoder = Serializer()
        var Serialized = ""
        
        if UserTheme.Dirty
        {
            Serialized = Encoder.Encode(UserTheme, WithTitle: UserTheme.ThemeName)
            let _ = FileIO.SaveFileContentsToResource(WithContents: Serialized, "UserThemes", ".xml")
        }
    }
    
    /// Create themes from the deserialized data.
    ///
    /// - Parameter Deserialized: Serializer instance with deserialized data.
    private func CreateThemes(_ Deserialized: Serializer, WithName: String)
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
                Theme.FileName = WithName
                _ThemeList.append((Name, Theme))
                if Name == "User"
                {
                    _UserTheme = Theme
                }
                if Name == "Default"
                {
                    _DefaultTheme = Theme
                }
            }
        }
    }
    
    /// Holds the user theme.
    private var _UserTheme: ThemeDescriptor!
    /// Get the user theme.
    public var UserTheme: ThemeDescriptor
    {
        get
        {
            return _UserTheme
        }
    }

    /// Holds the default theme.
    private var _DefaultTheme: ThemeDescriptor!
    /// Get the default theme.
    public var DefaultTheme: ThemeDescriptor
    {
        get
        {
            return _DefaultTheme
        }
    }
    
    /// Holds a list of all themes.
    private var _ThemeList = [(String, ThemeDescriptor)]()
    
    /// Holds the current theme.
    private var _Current: ThemeDescriptor? = nil
    /// Get the current theme. If nil, try to load a theme first.
    public var Current: ThemeDescriptor?
    {
        get
        {
            return _Current
        }
    }
    
    /// Holds the current theme ID. Updates `Current` when set with a valid ID.
    private var _CurrentThemeID: UUID = UUID.Empty
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
    public var CurrentThemeID: UUID
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
    
    /// Return a list of all themes.
    ///
    /// - Returns: List of tuples in the order: (theme title, theme ID), one for each theme.
    public func GetAllThemes() -> [(String, UUID)]
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
    public func ThemeFrom(ID: UUID) -> ThemeDescriptor?
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
    public func ThemeNameFrom(ID: UUID) -> String?
    {
        if let Theme = ThemeFrom(ID: ID)
        {
            return Theme.ThemeName
        }
        return nil
    }
    
    // MARK: Protocol function handling and change notice handling/management.
    
    /// Handle theme changes. Notifies all subscribers of the change. However, subscribers can set the
    /// fields they want to be notified of changes - in that case, if the changed field is not in the
    /// subscriber's list of fields, no change notice is sent.
    /// - Parameter ThemeName: The name of the changed theme.
    /// - Parameter FieldName: The name of the changed field.
    func ThemeChanged(ThemeName: String, FieldName: String)
    {
        for (_, (Delegate, FieldList)) in Subscribers
        {
            if let FList = FieldList
            {
                if !FList.contains(FieldName)
                {
                    return
                }
            }
            Delegate.ThemeUpdated(ThemeName: ThemeName, FieldName: FieldName)
        }
    }
    
    /// Holds the list of subscribers to change notices.
    private var Subscribers = [String: (ThemeUpdatedProtocol, [String]?)]()
    
    /// Allows objects (that implement the `ThemeUpdatedProtocol`) to subscribe to changes in themes.
    /// - Parameter Subscriber: The name of the subscriber. If this subscriber is already in the
    ///                         subscribers list, it will not be added again. To change the list of
    ///                         fields, the caller must first call `CancelSubscription` on the `Subscriber`
    ///                         then call this function again with a new field list.
    /// - Parameter SubscribingObject: The object that will be called with changes.
    /// - Parameter FieldList: Optional list of fields (that must match those in the theme itself) the
    ///                        subscriber wants to be notified if changed. If nil (or empty), all changes
    ///                        will be reported to the subscriber.
    public func SubscribeToChanges(Subscriber: String, SubscribingObject: ThemeUpdatedProtocol,
                                          FieldList: [String]? = nil)
    {
        if Subscribers[Subscriber] != nil
        {
            return
        }
        Subscribers[Subscriber] = (SubscribingObject, FieldList)
    }
    
    /// Cancel an existing subscription for theme change notifications.
    /// - Parameter Subscriber: The name of the subscriber.
    public func CancelSubscription(Subscriber: String)
    {
        Subscribers.removeValue(forKey: Subscriber)
    }
}
