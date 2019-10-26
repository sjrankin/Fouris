//
//  ThemeManager3.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages themes. Two themes are currently managed - the default theme and the user theme.
class ThemeManager3: ThemeChangeProtocol2
{
    /// Move resource-bound initial theme files to the settings directory for use by the game.
    private func CreateSettingsFiles()
    {
        let DefaultTheme = FileIO.GetFileContentsFromResource("GameTheme2", ".xml")
        let _ = FileIO.SaveSettingsFile(Name: "GameTheme2.xml", Contents: DefaultTheme!)
        let UserTheme = FileIO.GetFileContentsFromResource("UserGameTheme2", ".xml")
        let _ = FileIO.SaveSettingsFile(Name: "UserGameTheme2.xml", Contents: UserTheme!)
    }
    
    /// If necessary, create the settings directory and move resource-bound settings files to it.
    /// - Note: This should be necessary only the first time Fouris is run but we will execute this code everytime
    ///         Fouris starts to be sure.
    private func Preinitialize()
    {
        if !FileIO.DirectoryExists(DirectoryName: FileIO.SettingsDirectory)
        {
            print("Creating settings directory.")
            FileIO.CreateDirectory(DirectoryName: FileIO.SettingsDirectory)
            CreateSettingsFiles()
        }
        else
        {
            print("Settings directory exists.")
            if !FileIO.FilesExist(FileList: ["GameTheme2.xml", "UserGameTheme2.sml"], InDirectory: FileIO.SettingsDirectory)
            {
                print("Creating settings files.")
                CreateSettingsFiles()
            }
        }
    }
  
    /// Place-holder to generate a theme file from raw data.
    /// - Returns: Default theme.
    private func Preinitialize2() -> String
    {
        if let GameTheme = UserDefaults.standard.string(forKey: "GameTheme")
        {
            return GameTheme
        }
        return ThemeManager3.RawTheme()
    }
    
    /// Initialize the theme manager. Creates initial theme files if they do not exist. Reads theme files and provides data via the
    /// `DefaultTheme` and `UserTheme` properties.
    public func Initialize()
    {
        #if true
        let Raw = Preinitialize2()
        UserThemeDocument = XMLDocument(FromString: Raw)
        _UserTheme = ThemeDescriptor2()
        _UserTheme?.ChangeDelegate = self
        let _ = UserThemeDocument?.DeserializeTo(Caller: _UserTheme!)
        #else
        Preinitialize()
        DefaultThemeDocument = XMLDocument(File: FileIO.MakeFileURL(FileName: "GameTheme2.xml", Directory: FileIO.SettingsDirectory)!)
        UserThemeDocument = XMLDocument(File: FileIO.MakeFileURL(FileName: "UserGameTheme2.xml", Directory: FileIO.SettingsDirectory)!)
        _DefaultTheme = ThemeDescriptor2()
        _DefaultTheme?.ChangeDelegate = self
        _UserTheme = ThemeDescriptor2()
        _UserTheme?.ChangeDelegate = self
        let _ = DefaultThemeDocument?.DeserializeTo(Caller: _DefaultTheme!)
        let _ = UserThemeDocument?.DeserializeTo(Caller: _UserTheme!)
        #endif
    }
    
    /// Holds the default theme document.
    private var DefaultThemeDocument: XMLDocument? = nil
    /// Holds the user theme document.
    private var UserThemeDocument: XMLDocument? = nil
    
    /// Holds the default theme.
    private var _DefaultTheme: ThemeDescriptor2? = nil
    /// Holds the user theme.
    private var _UserTheme: ThemeDescriptor2? = nil
    
    /// Get or set the default theme. If the returned value is nil, there was an error loading the theme.
    public var DefaultTheme: ThemeDescriptor2?
    {
        get
        {
            return _DefaultTheme
        }
        set
        {
            _DefaultTheme = newValue
        }
    }
    
    /// Get or set the user theme. If the returned value is nil, there was an error loading the theme.
    public var UserTheme: ThemeDescriptor2?
    {
        get
        {
            return _UserTheme
        }
        set
        {
            _UserTheme = newValue
        }
    }
    
    /// Save the user theme. If the theme is not dirty (eg, has not bee changed), no action is taken.
    public func SaveUserTheme()
    {
        if UserTheme!.Dirty
        {
            let Serialized = UserTheme?.ToString()
            #if true
            UserDefaults.standard.set(Serialized, forKey: "GameTheme")
            //print("Save theme:\n\(Serialized!)")
            #else
            let _ = FileIO.SaveSettingsFile(Name: "UserGameTheme2.xml", Contents: Serialized!)
            //print("Saved theme:\n\(Serialized!)")
            #endif
        }
    }
    
    /// Resets the user theme to the raw default value defined elsewhere in the class (see `RawTheme`).
    /// - Note: All user settings will be lost.
    public func ResetUserTheme()
    {
        UserDefaults.standard.set(ThemeManager3.RawTheme(), forKey: "GameTheme")
        UserThemeDocument = XMLDocument(FromString: ThemeManager3.RawTheme())
        _UserTheme = ThemeDescriptor2()
        _UserTheme?.ChangeDelegate = self
        let _ = UserThemeDocument?.DeserializeTo(Caller: _UserTheme!)
    }
    
    // MARK: ThemeChangeProtocol functions.
    
    /// Returns the date and time as a string.
    /// - Parameter Now: The date to return as a string.
    /// - Returns: The passed date formatted by `DateFormatter` into a string.
    func GetDateHere(_ Now: Date) -> String?
    {
        let Result = DateFormatter.localizedString(from: Now, dateStyle: .long, timeStyle: .long)
        return Result
    }
    
    /// Handle theme changes. Notifies all subscribers of the change. However, subscribers can set the
    /// fields they want to be notified of changes - in that case, if the changed field is not in the
    /// subscriber's list of fields, no change notice is sent.
    /// - Note: If the theme's `SaveAfterEdit` flag is true, the theme is saved after the delegate is notified
    ///         of the change.
    /// - Parameter Theme: The name of the changed theme.
    /// - Parameter Field: The field whose property changed.
    func ThemeChanged(Theme: ThemeDescriptor2, Field: ThemeFields)
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
                SaveUserTheme()
            }
        }
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
