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
    /// If necessary, create the settings directory and move resource-bound settings files to it.
    /// - Note: This should be necessary only the first time Fouris is run but we will execute this code everytime
    ///         Fouris starts to be sure.
    private func Preinitialize()
    {
        if !FileIO.DirectoryExists(DirectoryName: FileIO.SettingsDirectory)
        {
            print("Creating initial themes.")
            FileIO.CreateDirectory(DirectoryName: FileIO.SettingsDirectory)
            let DefaultTheme = FileIO.GetFileContentsFromResource("GameThemes", ".xml")
            let _ = FileIO.SaveSettingsFile(Name: "GameThemes.xml", Contents: DefaultTheme!)
            let UserTheme = FileIO.GetFileContentsFromResource("UserGameThemes", ".xml")
            let _ = FileIO.SaveSettingsFile(Name: "UserGameThemes.xml", Contents: UserTheme!)
            #if false
            let DefaultEncoded = BufferManager.EncodeBuffer(DefaultTheme!)
            let _ = FileIO.WriteBinaryFile(Name: "DefaultTheme.dat", Directory: FileIO.SettingsDirectory, BinaryData: DefaultEncoded)
            let UserEncoded = BufferManager.EncodeBuffer(UserTheme!)
            let _ = FileIO.WriteBinaryFile(Name: "UserGameThemes.dat", Directory: FileIO.SettingsDirectory, BinaryData: UserEncoded)
            #endif
        }
        else
        {
            print("Settings directory exists.")
        }
    }
    
    /// Initialize the theme manager. Read standard themes from a serialized file in the resource directory. Set the
    /// current theme.
    public func Initialize()
    {
        Preinitialize()
        _ThemeList = [(String, ThemeDescriptor)]()
        #if false
        let EncodedDefault = FileIO.ReadBinaryFile(Name: "DefaultTheme.dat", Directory: FileIO.SettingsDirectory)
        let DecodedDefault = BufferManager.DecodeBuffer(EncodedDefault!)
        let DecodedDefaultString = BufferManager.BufferToString(DecodedDefault)
        
        let EncodedUser = FileIO.ReadBinaryFile(Name: "UserGameThemes.dat", Directory: FileIO.SettingsDirectory)
        let DecodedUser = BufferManager.DecodeBuffer(EncodedUser!)
        let DecodedUserString = BufferManager.BufferToString(DecodedUser)
        
        let DefaultSerializer = Serializer()
        let DeserializedDefaultOK = DefaultSerializer.Deserialize(From: DecodedDefaultString)
        if DeserializedDefaultOK
        {
            CreateThemes(DefaultSerializer, WithName: "GameTheme.dat")
        }
        
        let UserSerializer = Serializer()
        let DeserializedUserOK = UserSerializer.Deserialize(From: DecodedUserString)
        if DeserializedUserOK
        {
            CreateThemes(UserSerializer, WithName: "UserGameThemes.dat")
        }
        #else
        if let SerializedTheme = FileIO.GetSettingsFile(Name: "GameThemes.xml")
        {
            let Serialize = Serializer()
            let DeserializedOK = Serialize.Deserialize(From: SerializedTheme)
            if DeserializedOK
            {
                CreateThemes(Serialize, WithName: "GameThemes.xml")
            }
        }
        else
        {
            fatalError("Error reading GameThemes.xml")
        }
        if let SerializedTheme = FileIO.GetSettingsFile(Name: "UserGameThemes.xml")
        {
            let Serialize = Serializer()
            let DeserializedOK = Serialize.Deserialize(From: SerializedTheme)
            if DeserializedOK
            {
                print("Deserialized user theme:\n\(SerializedTheme)")
                CreateThemes(Serialize, WithName: "UserGameThemes.xml")
            }
        }
        else
        {
            fatalError("Error reading UserGameThemes.xml")
        }
        #endif
        if _ThemeList.count != 2
        {
            fatalError("Error reading themes. Missing either default or user theme.")
        }
        UserTheme.ChangeDelegate = self
        DefaultTheme.ChangeDelegate = self
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
            #if true
            let _ = FileIO.SaveSettingsFile(Name: "UserThemes.xml", Contents: Serialized)
            #else
            let _ = FileIO.SaveFileContentsToResource(WithContents: Serialized, "UserThemes", ".xml")
            #endif
            UserTheme.Dirty = false
        }
    }
    
    /// Saves the passed theme.
    /// - Note: Assumes the theme has a file name already assigned.
    /// - Parameter Theme: The theme to save.
    public func SaveTheme(_ Theme: ThemeDescriptor)
    {
        let Encoder = Serializer()
        var Serialized = ""
        if Theme.Dirty
        {
            Serialized = Encoder.Encode(Theme, WithTitle: UserTheme.ThemeName)
            print("Serialize=\n\(Serialized)")
            #if true
            let _ = FileIO.SaveSettingsFile(Name: Theme.FileName, Contents: Serialized)
            #else
            let FileNameParts = Theme.FileNameParts()
            let _ = FileIO.SaveFileContentsToResource(WithContents: Serialized, FileNameParts.Name, FileNameParts.Extension)
            #endif
            Theme.Dirty = false
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
                if Name == "User Theme"
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
    
    // MARK: Change notice handling/management protocol function implementation.
    
    /// Handle theme changes. Notifies all subscribers of the change. However, subscribers can set the
    /// fields they want to be notified of changes - in that case, if the changed field is not in the
    /// subscriber's list of fields, no change notice is sent.
    /// - Note: If the theme's `SaveAfterEdit` flag is true, the theme is saved after the delegate is notified
    ///         of the change.
    /// - Parameter Theme: The name of the changed theme.
    /// - Parameter Field: The field whose property changed.
    func ThemeChanged(Theme: ThemeDescriptor, Field: ThemeFields)
    {
        for (_, (Delegate, FieldList)) in Subscribers
        {
            if let FList = FieldList
            {
                if !FList.contains(Field)
                {
                    return
                }
            }
            Theme.EditDate = GetDateHere(Date())!
            Delegate.ThemeUpdated(ThemeName: Theme.ThemeName, Field: Field)
            if Theme.SaveAfterEdit
            {
                SaveTheme(Theme)
            }
        }
    }
    
    /// Returns the date and time as a string.
    /// - Parameter Now: The date to return as a string.
    /// - Returns: The passed date formatted by `DateFormatter` into a string.
    func GetDateHere(_ Now: Date) -> String?
    {
        let Result = DateFormatter.localizedString(from: Now, dateStyle: .long, timeStyle: .long)
        return Result
    }
    
    /// Holds the list of subscribers to change notices.
    private var Subscribers = [String: (ThemeUpdatedProtocol, [ThemeFields]?)]()
    
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
                                          FieldList: [ThemeFields]? = nil)
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
