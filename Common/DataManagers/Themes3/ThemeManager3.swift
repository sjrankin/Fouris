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
            FileIO.CreateDirectory(DirectoryName: FileIO.SettingsDirectory)
            CreateSettingsFiles()
        }
        else
        {
            print("Settings directory exists.")
            if !FileIO.FileExists(FileName: "GameTheme.xml", Directory: FileIO.SettingsDirectory)
            {
                CreateSettingsFiles()
            }
        }
    }
    
    /// Initialize the theme manager. Creates initial theme files if they do not exist. Reads theme files and provides data via the
    /// `DefaultTheme` and `UserTheme` properties.
    public func Initialize()
    {
        Preinitialize()
        DefaultThemeDocument = XMLDocument(File: FileIO.MakeFileURL(FileName: "GameTheme2.xml", Directory: FileIO.SettingsDirectory)!)
                UserThemeDocument = XMLDocument(File: FileIO.MakeFileURL(FileName: "UserGameTheme2.xml", Directory: FileIO.SettingsDirectory)!)
        _DefaultTheme = ThemeDescriptor2()
        _DefaultTheme?.ChangeDelegate = self
        _UserTheme = ThemeDescriptor2()
        _UserTheme?.ChangeDelegate = self
        let _ = DefaultThemeDocument?.DeserializeTo(Caller: _DefaultTheme!)
        let _ = UserThemeDocument?.DeserializeTo(Caller: _UserTheme!)
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
            let _ = FileIO.SaveSettingsFile(Name: "UserGameTheme2.xml", Contents: Serialized!)
        }
    }
    
    // MARK: ThemeChangeProtocol functions.
    
    func ThemeChanged(Theme: ThemeDescriptor2, Field: ThemeFields)
    {
        
    }
}
