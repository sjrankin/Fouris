//
//  Settings.swift
//  WackyDesktopTetris
//
//  Created by Stuart Rankin on 5/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages settings for Tetris.
/// Settings include levels (stored as .json files in the appropriate directory for the platform) and native
/// settings in UserDefaults. Settings are exposed via functions and not native API calls.
class Settings
{
    public static let AnonymousUserID = "ef92b048-8610-452c-8b31-da4a78c5de32"
    private static let _AnonymousUserID = UUID(uuidString: AnonymousUserID)
    public static let AIUserID = "ca160948-9128-485a-8c37-c227449d91d2"
    private static let _AIUserID = UUID(uuidString: AIUserID)
    private static let _Settings = UserDefaults.standard
    private static let _InitializationValue = "ed7dfe6e-d6a4-4eec-965f-82aae0094856"
    private static var _WasInitialized = false
    private static var DocumentDirectory: URL? = nil
    private static var TableOfContents: TOC? = nil
    private static var Subscribers: [(String, SettingsChangedProtocol?)]? = nil
    
    /// Initialize the settings. If not called before use, a fatal error will be generated.
    public static func Initialize()
    {
        _WasInitialized = true
        let Storage = FileIO.GetStorageDirectory()
        DocumentDirectory = Storage!.1
        if let TOCJson = FileIO.GetFileContents(InDirectory: DocumentDirectory!, FromFile: "TOC.json")
        {
            TableOfContents = TOC.FromJSON(JSON: TOCJson)
            LoadUserData()
        }
        else
        {
            TableOfContents = TOC()
            AddUser(WithName: "Anonymous", AndID: UUID(uuidString: AnonymousUserID)!, WithType: .Anonymous)
            AddUser(WithName: "AI", AndID: UUID(uuidString: AIUserID)!, WithType: .AI)
        }
        if let _ = _Settings.string(forKey: "Initialized")
        {
            return
        }
        _Settings.set("Initialized", forKey: "Initialized")
        _Settings.set(AIUserID, forKey: "CurrentUserID")
        _Settings.set(false, forKey: "EnableHapticFeedback")
        _Settings.set(false, forKey: "EnableVibrationFeedbackForOldPhones")
        _Settings.set(true, forKey: "ShowAICommandsOnControls")
        _Settings.set(3, forKey: "MaximumSamePiecesInARow")
        _Settings.set(5, forKey: "AISneakPeakCount")
        _Settings.set(0, forKey: "LastGameViewIndex")
        _Settings.set(false, forKey: "InDistractMode")
        _Settings.set("Standard", forKey: "GameType")
        _Settings.set(true, forKey: "RotateBoard")
        _Settings.set(true, forKey: "StartWithAI")
        _Settings.set(true, forKey: "UseTDebug")
        _Settings.set(60.0, forKey: "AutoStartDuration")
        _Settings.set(15.0, forKey: "AfterGameWaitDuration")
        _Settings.set(0, forKey: "ColorPickerColorSpace")
        _Settings.set(false, forKey: "ShowAlphaInColorPicker")
        _Settings.set(20, forKey: "MostRecentlyUsedColorCapacity")
        _Settings.set("", forKey: "MostRecentlyUsedColorList")
        _Settings.set(true, forKey: "ShowClosestColor")
        _Settings.set(0, forKey: "GameBackgroundType")
        _Settings.set(false, forKey: "ConfirmGameImageSave")
        _Settings.set(false, forKey: "ShowFPSInUI")
        _Settings.set(1.25, forKey: "BucketDestructionDuration")
        _Settings.set(false, forKey: "FastClearBucket")
        _Settings.set(true, forKey: "ShowCameraControls")
        _Settings.set(true, forKey: "ShowMotionControls")
        _Settings.set(true, forKey: "ShowTopToolbar")
        _Settings.set("83c630ee-81d4-11e9-bc42-526af7764f64", forKey: "CurrentTheme")
        _Settings.set("3f0d9fee-0b77-465b-a0ac-f1663da23cc9", forKey: "Current3DTheme")
    }
    
    /// Add a subscriber for settings change notifications.
    /// - Note: Not all settings send notifications.
    /// - Parameter For: Name of the subscriber.
    /// - Parameter NewSubscriber: The new subscriber.
    public static func AddSubscriber(For: String, NewSubscriber: SettingsChangedProtocol?)
    {
        if Subscribers == nil
        {
            Subscribers = [(String, SettingsChangedProtocol?)]()
        }
        Subscribers?.append((For, NewSubscriber))
    }
    
    /// Remove a subscriber from settings change notifications.
    /// - Parameter From: Name of the subscriber.
    /// - Parameter OldSubscriber: The subscriber to remove.
    public static func RemoveSubscriber(From: String, OldSubscriber: SettingsChangedProtocol?)
    {
        if Subscribers == nil
        {
            return
        }
        Subscribers = Subscribers?.filter({!($0.0 == From)})
    }
    
    /// Send a setting change notice to subscribers.
    private static func SendNotice(From: SettingsFields, NewValue: Any)
    {
        if let SubscriberList = Subscribers
        {
            for Subscriber in SubscriberList
            {
                Subscriber.1?.SettingChanged(Field: From, NewValue: NewValue)
            }
        }
    }
    
    /// Get the show motion controls flag.
    /// - Returns: Value indicating whether motion controls should be shown or not.
    public static func GetShowMotionControls() -> Bool
    {
        return _Settings.bool(forKey: "ShowMotionControls")
    }
    
    /// Set the show motion controls flag.
    /// - Parameter NewValue: New value for the show motion controls flag.
    public static func SetShowMotionControls(NewValue: Bool)
    {
        _Settings.set(NewValue, forKey: "ShowMotionControls")
        SendNotice(From: .ShowMotionControls, NewValue: NewValue)
    }
    
    /// Get the shot top toolbar flag.
    /// - Returns: Value indicating whether the top toolbar should be shown or not.
    public static func GetShowTopToolbar() -> Bool
    {
        return _Settings.bool(forKey: "ShowTopToolbar")
    }
    
    /// Set the show top toolbar flag.
    /// -Parameter NewValue: new value for the show top toolbar flag.
    public static func SetShowTopToolbar(NewValue: Bool)
    {
        _Settings.set(NewValue, forKey: "ShowTopToolbar")
        SendNotice(From: .ShowTopToolbar, NewValue: NewValue)
    }
    
    /// Get the flag that determines whether camera controls are shown in the UI.
    /// - Returns: Flag that determines whether camera controls are shown in the UI.
    public static func GetShowCameraControls() -> Bool
    {
        return _Settings.bool(forKey: "ShowCameraControls")
    }
    
    /// Set the flag that determines whether camera controls are shown in the UI.
    /// - Parameter NewValue: New value of the show camera controls flag.
    public static func SetShowCameraControls(NewValue: Bool)
    {
        _Settings.set(NewValue, forKey: "ShowCameraControls")
        SendNotice(From: .ShowCameraControls, NewValue: NewValue as Any)
    }
    
    /// Get the clear the bucket at game over in a hurry flag.
    public static func GetFastClearBucket() -> Bool
    {
        return _Settings.bool(forKey: "FastClearBucket")
    }
    
    /// Set the clear the bucket at game over in a hurry flag.
    /// - Parameter NewValue: New value for the flag.
    public static func SetFastClearBucket(NewValue: Bool)
    {
        _Settings.set(NewValue, forKey: "FastClearBucket")
    }
    
    /// Return the amount of time to take to clear the bucket in an animated fashion.
    /// - Note: If the stored value is less than or equal to 0.0, a default value of 1.25 is returned.
    /// - Returns: The number of seconds to take to clear the bucket.
    public static func GetBucketDestructionDurationTime() -> Double
    {
        var Value = _Settings.double(forKey: "BucketDestructionDuration")
        if Value <= 0.0
        {
            Value = 1.25
        }
        return Value
    }
    
    /// Set a new value for the number of seconds to clear the bucket.
    /// - Parameter NewValue: The number of seconds to take to clear the bucket.
    public static func SetBucketDestructionDurationTime(NewValue: Double)
    {
        _Settings.set(NewValue, forKey: "BucketDestructionDuration")
    }
    
    /// Get the show FPS rate in the UI flag.
    public static func ShowFPSInUI() -> Bool
    {
        return _Settings.bool(forKey: "ShowFPSInUI")
    }
    
    /// Set the show FPS rate in the UI flag.
    public static func SetShowFPSInUI(NewValue: Bool)
    {
        _Settings.set(NewValue, forKey: "ShowFPSInUI")
        SendNotice(From: .ShowFPSInUI, NewValue: NewValue as Any)
    }
    
    /// Get the confirm image saves for the main game view.
    public static func GetConfirmGameImageSave() -> Bool
    {
        return _Settings.bool(forKey: "ConfirmGameImageSave")
    }
    
    /// Set the confirm image save flag for the main game view.
    public static func SetConfirmGameImageSave(NewValue: Bool)
    {
        _Settings.set(NewValue, forKey: "ConfirmGameImageSave")
    }
    
    /// Returns the game background type.
    /// - Returns: Value indicating the game background type.
    public static func GetGameBackgroundType() -> Int
    {
        return _Settings.integer(forKey: "GameBackgroundType")
    }
    
    /// Set the game background type value. No checking is done here.
    /// - Parameter NewValue: New game background type index.
    public static func SetGameBackgroundType(NewValue: Int)
    {
        _Settings.set(NewValue, forKey: "GameBackgroundType")
    }
    
    /// Returns the show closest color flag for the color name picker.
    /// - Returns: Boolean flag for the show closest color in the color name picker.
    public static func GetShowClosestColor() -> Bool
    {
        return _Settings.bool(forKey: "ShowClosestColor")
    }
    
    /// Set the show closest color flag for the color name picker.
    /// - Parameter NewValue: New show closest color flag value.
    public static func SetShowClosestColor(NewValue: Bool)
    {
        _Settings.set(NewValue, forKey: "ShowClosestColor")
    }
    
    /// Returns the contents of the most recently used colors.
    /// - Note:
    ///   - The number of items in the color list is limited by the value returned by **GetMostRecentlyUsedColorListCapacity**
    ///     when the list was last written.
    ///   - The format of the returned string is **Hex Value**,**Hex Value**, where **Hex Value** is a hex color value. The
    ///     delimiter between values is a comma ("**,**").
    /// - Returns: The contents of the most recently used color list. If the user has not set any colors or on first execution
    ///            after installation, an empty string will be returned.
    public static func GetMostRecentlyUsedColorList() -> String
    {
        if let Value = _Settings.string(forKey: "MostRecentlyUsedColorList")
        {
            return Value
        }
        else
        {
            return ""
        }
    }
    
    /// Set the contents of the most recently used colors list to the user defaults.
    /// - Note:
    ///   - The number of items should not exceed more than the value returned by **GetMostRecentlyUsedColorListCapacity**. However,
    ///     this function does not enforce that limit.
    ///   - The format of the passed string is **Hex Value**,**Hex Value**, where **Hex Value** is a hex color value. The
    ///     delimiter between values is a comma ("**,**").
    /// - Parameter NewValue: The new recently used color list.
    public static func SetMostRecentlyUsedColorList(NewValue: String)
    {
        _Settings.set(NewValue, forKey: "MostRecentlyUsedColorList")
    }
    
    /// Get the maximum size of the most recently used color list.
    /// - Note: If run after initial installation, iOS will return 0. For that reason, if the value in the user
    ///         settings is 0, 20 is assumed and set to the user settings file.
    /// - Returns: The maximum capacity of the most recently used color list.
    public static func GetMostRecentlyUsedColorListCapacity() -> Int
    {
        var Capacity = _Settings.integer(forKey: "MostRecentlyUsedColorCapacity")
        if Capacity == 0
        {
            Capacity = 20
            SetMostRecentlyUsedColorListCapacity(NewValue: Capacity)
        }
        return Capacity
    }
    
    /// Sets the maximum size of the most recently used color list.
    /// - Parameter NewValue: The new maximum size of the most recently used color list.
    public static func SetMostRecentlyUsedColorListCapacity(NewValue: Int)
    {
        _Settings.set(NewValue, forKey: "MostRecentlyUsedColorCapacity")
    }
    
    /// Gets the show/enable alpha for RGB in the color picker.
    /// - Returns: Show alpha flag.
    public static func GetShowAlpha() -> Bool
    {
        return _Settings.bool(forKey: "ShowAlphaInColorPicker")
    }
    
    /// Set the show/enable alpha for RGB in the color picker.
    /// - Parameter NewValue: New show alpha flag.
    public static func SetShowAlpha(NewValue: Bool)
    {
        _Settings.set(NewValue, forKey: "ShowAlphaInColorPicker")
    }
    
    /// Gets the color picker color space indicator.
    /// - Note:
    ///  - 0: RGB
    ///  - 1: HSB
    ///  - 2: YUV
    ///  - 3: CMYK
    /// - Returns: Value indicating which color space to use for the color picker.
    public static func GetColorPickerColorSpace() -> Int
    {
        return _Settings.integer(forKey: "ColorPickerColorSpace")
    }
    
    /// Set the color picker color space indicator.
    /// - Note:
    ///  - 0: RGB
    ///  - 1: HSB
    ///  - 2: YUV
    ///  - 3: CMYK
    /// - Parameter NewValue: New color space indicator value. Invalid values cause control to be returned
    ///                       and no changes made.
    public static func SetColorPickerColorSpace(NewValue: Int)
    {
        if NewValue < 0
        {
            return
        }
        if NewValue > 3
        {
            return
        }
        _Settings.set(NewValue, forKey: "ColorPickerColorSpace")
    }
    
    /// Get the amount of time to wait from game over to when to start a new game in attract mode.
    /// - Returns: Number of seconds to wait between game over and staring a new game.
    public static func GetAfterGameWaitDuration() -> Double
    {
        var WaitDuration = _Settings.double(forKey: "AfterGameWaitDuration")
        if WaitDuration <= 0.0
        {
            WaitDuration = 15.0
        }
        return WaitDuration
    }
    
    /// Sets a new wait time between game over and auto starting a new game in attract mode.
    /// - Parameter NewValue: New wait time in seconds.
    public static func SetAfterGameWaitDuration(NewValue: Double)
    {
        _Settings.set(NewValue, forKey: "AfterGameWaitDuration")
    }
    
    /// Get the auto start duration (the amount of time (in seconds) between when the start finishes
    /// initialization and when the AI starts if there is no user interaction).
    /// - Returns: The number of seconds for auto start duration. Always greater than 0.0 (even if
    ///            a negative number is set in **SetAutoStartDuration**). Invalid settings will always
    ///            be returned as 60.0.
    public static func GetAutoStartDuration() -> Double
    {
        var AutoStart = _Settings.double(forKey: "AutoStartDuration")
        if AutoStart <= 0.0
        {
            AutoStart = 60.0
        }
        return AutoStart
    }
    
    /// Set the auto start duration. This is the amount of time (in seconds) between game initialization and
    /// when the AI starts playing if the user takes no actions.
    /// - Parameter ToNewValue: The new auto start duration in seconds.
    public static func SetAutoStartDuration(ToNewValue: Double)
    {
        _Settings.set(ToNewValue, forKey: "AutoStartDuration")
    }
    
    /// Get the use TDebug flag.
    /// - Note: Valid for non-release builds only.
    /// - Returns: The use TDebug flag.
    public static func GetUseTDebug() -> Bool
    {
        return _Settings.bool(forKey: "UseTDebug")
    }
    
    /// Set the use TDebug flag.
    /// - Note: Valid for non-release builds only.
    /// - Parameter Enabled: The value to set the use TDebug flag to.
    public static func SetUseTDebug(Enabled: Bool)
    {
        _Settings.set(Enabled, forKey: "UseTDebug")
    }
    
    /// Returns the start with AI flag. If true, the game will start in AI mode immediately (like an attract
    /// mode). If false, the game will wait until the user starts.
    public static func GetStartWithAI() -> Bool
    {
        return _Settings.bool(forKey: "StartWithAI")
    }
    
    /// Set the start with AI flag. Takes effect next time game is started.
    /// - Parameter Enabled: Value of the start with AI flag.
    public static func SetStartWithAI(Enabled: Bool)
    {
        _Settings.set(Enabled, forKey: "StartWithAI")
    }
    
    /// Returns the current can rotate board flag, which indicates whether rotating boards can be shown
    /// to rotate or just suddenly appear in new orientations.
    /// - Returns: Flag that indicates if boards can rotate (true) or not (false).
    public static func GetCanRotateBoard() -> Bool
    {
        return _Settings.bool(forKey: "RotateBoard")
    }
    
    /// Set the boards can rotate flag.
    /// - Parameter ToNewValue: The new boards can rotate flag.
    public static func SetCanRotateBoard(_ ToNewValue: Bool)
    {
        _Settings.set(ToNewValue, forKey: "RotateBoard")
    }
    
    /// Returns the stored base game type. If nothing stored or an unrecognizable type is stored,
    /// **BaseGameTypes.Standard** is returned.
    /// - Returns: The stored base game type.
    public static func GetGameType() -> BaseGameTypes
    {
        let Raw = _Settings.string(forKey: "GameType")
        if Raw == nil
        {
            return .Standard
        }
        if let GameType = BaseGameTypes(rawValue: Raw!)
        {
            return GameType
        }
        return .Standard
    }
    
    /// Saves the base game type in user settings.
    /// - Parameter GameType: The base game type to save.
    public static func SetGameType(_ GameType: BaseGameTypes)
    {
        _Settings.set(GameType.rawValue, forKey: "GameType")
    }
    
    /// Gets the distraction mode flag from stored user defaults.
    /// - Returns: The distraction mode flag.
    public static func GetDistractMode() -> Bool
    {
        return _Settings.bool(forKey: "InDistractMode")
    }
    
    /// Saves the distration mode flag.
    /// - Parameter Mode: The flag value to save.
    public static func SetDistractMode(_ Mode: Bool)
    {
        _Settings.set(Mode, forKey: "InDistractMode")
    }
    
    /// Returns the last saved 2D game view index value.
    /// - Returns: Last saved game view index value.
    public static func GetLastGameViewIndex() -> Int
    {
        let Index = _Settings.integer(forKey: "LastGameViewIndex")
        return Index
    }
    
    /// Save a game view index value.
    /// - Parameter Index: The game view index to save.
    public static func SetLastGameViewIndex(Index: Int)
    {
        _Settings.set(Index, forKey: "LastGameViewIndex")
    }
    
    /// Get the last saved current theme ID.
    ///
    /// - Returns: ID of the last current theme. If not previously set or invalid, an empty UUID is returned.
    public static func GetCurrentThemeID() -> UUID
    {
        if let Raw = _Settings.string(forKey: "CurrentTheme")
        {
            if let Final = UUID(uuidString: Raw)
            {
                return Final
            }
        }
        return UUID.Empty
    }
    
    /// Sets the passed ID to the current theme setting.
    ///
    /// - Parameter ID: ID of the current theme.
    public static func SetCurrentThemeID(ID: UUID)
    {
        _Settings.set(ID.uuidString, forKey: "CurrentTheme")
    }
    
    /// Get the last saved current 3D theme ID.
    /// - Returns: ID of the last 3D current theme. If not previously set or invalid, an empty UUID is returned.
    public static func GetCurrent3DThemeID() -> UUID
    {
        if let Raw = _Settings.string(forKey: "Current3DTheme")
        {
            if let Final = UUID(uuidString: Raw)
            {
                return Final
            }
        }
        return UUID.Empty
    }

    /// Sets the passed ID to the current 3D theme setting.
    /// - Parameter ID: ID of the current 3D theme.
    public static func SetCurrent3DThemeID(ID: UUID)
    {
        _Settings.set(ID.uuidString, forKey: "Current3DTheme")
    }
    
    /// Returns the maximum number of same pieces in a row before duplicates will be discarded until a different piece
    /// is generated.
    ///
    /// - Returns: Maximum number of same piece shapes in a row permitted.
    public static func MaximumSamePieces() -> Int
    {
        return _Settings.integer(forKey: "MaximumSamePiecesInARow")
    }
    
    /// Set the maximum allowable number of same pieces in a row.
    /// - Parameter ToValue: New maximum piece value. Valid values are 2, 3, 4, 5, and 1000 where 1000 essentially
    ///                      means no maximum number of like pieces in a row.
    public static func SetMaximumSamePieces(ToValue: Int)
    {
        _Settings.set(ToValue, forKey: "MaximumSamePiecesInARow")
    }
    
    /// Sets the AI sneak peak count to the passed value. Invalid values set to the nearest valid value.
    /// - Parameter To: The new AI sneak peak count. This is the number of pieces the AI will look at ahead
    ///                 to find the best motions for each path.
    public static func SetAISneakPeakCount(To: Int)
    {
        var NewCount = [1, 2, 3, 4, 5, 10, 20].ClosestValue(To: To)
        _Settings.set(NewCount, forKey: "AISneakPeakCount")
    }
    
    public static func GetAISneakPeakCount() -> Int
    {
        var Count = _Settings.integer(forKey: "AISneakPeakCount")
        if Count < 1
        {
           Count = 1
        }
        return Count
    }
    
    /// Get a flag that determines whether the AI's commands should be reflected by highlighting the appropriate
    /// UI elements.
    public static func ShowAIUICommands() -> Bool
    {
        return _Settings.bool(forKey: "ShowAICommandsOnControls")
    }
    
    /// Set the flag for showing (or not) the AI's commands on the UI.
    public static func SetAIUICommands(Enable: Bool)
    {
        _Settings.set(Enable, forKey: "ShowAICommandsOnControls")
    }
    
    /// Returns the enable vibration feedback flag. Used for older (earlier than iPhone 7) devices which don't support
    /// haptic feedback.
    ///
    /// - Returns: True if vibration should be used, false if not (or not yet set).
    public static func EnableVibrateFeedback() -> Bool
    {
        return _Settings.bool(forKey: "EnableVibrationFeedbackForOldPhones")
    }
    
    /// Set the enable vibration for feedback flag value. Used for older (earlier than iPhone 7) devices which
    /// don't support haptic feedback.
    ///
    /// - Parameter Enable: True to enable vibration feedback, false to disable it.
    public static func SetVibrateFeedback(Enable: Bool)
    {
        _Settings.set(Enable, forKey: "EnableVibrationFeedbackForOldPhones")
    }
    
    /// Returns the use haptic feedback flag. This is only effective on iPhone 7 and later.
    ///
    /// - Returns: True if haptic feedback should be used, false if not.
    public static func EnableHapticFeedback() -> Bool
    {
        return _Settings.bool(forKey: "EnableHapticFeedback")
    }
    
    /// Set the enable haptic feedback flag value. Used only for iPhone 7 and later.
    ///
    /// - Parameter Enable: True to enable haptic feedback, false to disable it.
    public static func SetHapticFeedback(Enable: Bool)
    {
        _Settings.set(Enable, forKey: "EnableHapticFeedback")
    }
    
    /// Determines if the passed ID is a built-in user ID.
    ///
    /// - Parameter ID: The ID to check.
    /// - Returns: True if the passed ID is a built-in user ID, false if not.
    public static func IsBuiltInUser(ID: UUID) -> Bool
    {
        return [_AnonymousUserID, _AIUserID].contains(ID)
    }
    
    /// Determines if the passed ID is a built-in user ID.
    ///
    /// - Parameter StringID: The ID to check in string format.
    /// - Returns: True if the passed ID is a built-in user ID, false if not.
    public static func IsBuiltInUser(StringID: String) -> Bool
    {
        let TheID = UUID(uuidString: StringID)!
        return IsBuiltInUser(ID: TheID)
    }
    
    /// Get the ID of the current user.
    ///
    /// - Returns: ID of the current user. Nil if not set or on error.
    public static func CurrentUser() -> UUID?
    {
        if let SomeID = _Settings.string(forKey: "CurrentUserID")
        {
            if let LastID = UUID(uuidString: SomeID)
            {
                return LastID
            }
        }
        return nil
    }
    
    /// Set the ID of the current user.
    ///
    /// - Parameter ID: ID of the current user.
    public static func SetCurrentUser(_ ID: UUID)
    {
        _Settings.set(ID.uuidString, forKey: "CurrentUserID")
    }
    
    /// Delete a user from the table of contents as well as any user files in the file system.
    ///
    /// - Parameter WithID: ID of the user to delete.
    /// - Returns: True on success, false on failure.
    private static func DoDeleteUser(WithID: UUID) -> Bool
    {
        TableOfContents?.DeleteFromContents(ID: WithID)
        return true
    }
    
    /// Delete the user with the specified name.
    ///
    /// - Note: Will report failure if the caller tries to delete `AI` or `Anonymous`.
    ///
    /// - Parameter WithName: Name of the user to delete. Will not delete built-in users.
    /// - Returns: True on success, false on failure.
    public static func DeleteUser(WithName: String) -> Bool
    {
        if WithName == "AI" || WithName == "Anonymous"
        {
            return false
        }
        for User in Users
        {
            if User.UserName == WithName
            {
                return DoDeleteUser(WithID: User.UserID)
            }
        }
        return false
    }
    
    /// Load user data from user settings. If no users have yet to be defined, the anonymous and AI users are
    /// created.
    private static func LoadUserData()
    {
        if !_WasInitialized
        {
            fatalError("GetGameCount called before Initialize called.")
        }
        for Item in TableOfContents!.Contents
        {
            let SourceFile = Item.FileName
            if let FileContents = FileIO.GetFileContents(InDirectory: FileIO.AppDirectory(), FromFile: SourceFile)
            {
                let SomeUser = UserData.FromJSON(JSON: FileContents)
                DebugClient.Send("Loaded user data for \(SomeUser.UserName)")
                Users.append(SomeUser)
            }
            else
            {
                print("Error returned from FileIO.GetFileContents.")
            }
        }
    }
    
    /// Save user data.
    public static func SaveUserData()
    {
        if !_WasInitialized
        {
            fatalError("GetGameCount called before Initialize called.")
        }
        let TOCString = TableOfContents?.ToJSON()
        let OK = FileIO.SetFileContents(InDirectory: FileIO.AppDirectory(), ToFile: "TOC.json", WithContents: TOCString!)
        if !OK
        {
            print("Error returned by FileIO.SetFileContents when trying to write to TOC.json")
        }
        for Item in TableOfContents!.Contents
        {
            let User = GetUser(WithID: Item.ID)
            let FileName = Item.FileName
            let JSON = User?.ToJSON()
            let OK = FileIO.SetFileContents(InDirectory: FileIO.AppDirectory(), ToFile: FileName, WithContents: JSON!)
            if !OK
            {
                print("Error returned by FileIO.SetFileContents")
            }
        }
    }
    
    /// Determines if the passed user name already exists in the list of users.
    ///
    /// - Parameter Name: Name to check against the existing list of users.
    /// - Returns: True if the name exists, false if not.
    public static func UserNameExists(_ Name: String) -> Bool
    {
        for SomeUser in Users
        {
            if SomeUser.UserName == Name
            {
                return true
            }
        }
        return false
    }
    
    /// Add a user to the user list.
    ///
    /// - Note: If the user already exists, do not add it again. In this case, false will be returned.
    ///
    /// - Parameters:
    ///   - WithName: Name of the user to add.
    ///   - AndID: ID of the user to add.
    ///   - WithType: The type of user to add.
    /// - Returns: True on success, false on failure (user already exists).
    @discardableResult public static func AddUser(WithName: String, AndID: UUID, WithType: UserTypes = .Player) -> Bool
    {
        if UserNameExists(WithName)
        {
            return false
        }
        let NewUser = UserData(Name: WithName, ID: AndID)
        NewUser.UserType = WithType
        Users.append(NewUser)
        TableOfContents!.AddFileToContents(ID: AndID, Name: AndID.uuidString + ".json")
        return true
    }
    
    /// Return the user with the specified name.
    ///
    /// - Parameter WithName: Name of the user whose data will be returned.
    /// - Returns: User data on success, nil if not found.
    public static func GetUser(WithName: String) -> UserData?
    {
        for SomeUser in Users
        {
            if SomeUser.UserName == WithName
            {
                return SomeUser
            }
        }
        return nil
    }
    
    /// Return the user with the specified ID.
    ///
    /// - Parameter WithID: ID of the user to return.
    /// - Returns: User data on success, nil if not found.
    public static func GetUser(WithID: UUID) -> UserData?
    {
        for SomeUser in Users
        {
            if SomeUser.UserID == WithID
            {
                return SomeUser
            }
        }
        return nil
    }
    
    /// Return the name of the user with the specified ID.
    ///
    /// - Parameter ID: ID of the user whose name will be returned.
    /// - Returns: Name of the user with the specified ID. Nil if not found.
    public static func GetNameForUserID(_ ID: UUID) -> String?
    {
        for SomeUser in Users
        {
            if SomeUser.UserID == ID
            {
                return SomeUser.UserName
            }
        }
        return nil
    }
    
    /// Holds the list of user data.
    private static var _Users: [UserData] = [UserData]()
    /// Get or set the list of user data.
    public static var Users: [UserData]
    {
        get
        {
            return _Users
        }
        set
        {
            _Users = newValue
        }
    }
    
    /// Get the number of games for the specified user and level.
    ///
    /// - Note: If `Initialize` is not called prior to calling this function, a fatal error will be generated.
    ///
    /// - Parameters:
    ///   - ForUserID: The user's ID.
    ///   - AtLevel: The level to return the game count for.
    /// - Returns: The number of games completed at the specified level for the specified user.
    public static func GetGameCount(ForUserID: UUID, AtLevel: Int) -> Int
    {
        if !_WasInitialized
        {
            fatalError("GetGameCount called before Initialize called.")
        }
        if let TheUser = GetUser(WithID: ForUserID)
        {
            if let Level = TheUser.GetLevel(LevelID: AtLevel)
            {
                return Level.GameCount
            }
            else
            {
                return 0
            }
        }
        return 0
    }
    
    /// Increment the game count for the user at the specified level.
    ///
    /// - Note: If `Initialize` is not called prior to calling this function, a fatal error will be generated.
    ///
    /// - Parameters:
    ///   - ForUserID: The user's ID.
    ///   - AtLevel: The level whose game count will be incremented.
    public static func IncrementGameCount(ForUserID: UUID, AtLevel: Int)
    {
        if !_WasInitialized
        {
            fatalError("IncrementGameCount called before Initialize called.")
        }
        if let TheUser = GetUser(WithID: ForUserID)
        {
            let Level = TheUser.GetLevel(LevelID: AtLevel)
            Level!.GameCount = Level!.GameCount + 1
        }
    }
    
    /// Return the last played level for the specified user.
    ///
    /// - Note: If `Initialize` is not called prior to calling this function, a fatal error will be generated.
    ///
    /// - Parameter ForUserID: The user's ID.
    /// - Returns: The last level played by the specified user. If not played before, nil is returned.
    public static func GetLevel(ForUserID: UUID) -> Int?
    {
        if !_WasInitialized
        {
            fatalError("GetLevel called before Initialize called.")
        }
        if let TheUser = GetUser(WithID: ForUserID)
        {
            return TheUser.LastLevelPlayed
        }
        return nil
    }
    
    /// Set the level played by the user. Use to restore the level after the program is re-instantiated.
    ///
    /// - Note: If `Initialize` is not called prior to calling this function, a fatal error will be generated.
    ///
    /// - Parameters:
    ///   - NewLevel: Level played by the user.
    ///   - ForUserID: The user's ID.
    public static func SetLevel(_ NewLevel: Int, ForUserID: UUID)
    {
        if !_WasInitialized
        {
            fatalError("SetLevel called before Initialize called.")
        }
        if let TheUser = GetUser(WithID: ForUserID)
        {
            TheUser.LastLevelPlayed = NewLevel
        }
    }
    
    /// Returns the list of users.
    ///
    /// - Note: If `Initialize` is not called prior to calling this function, a fatal error will be generated.
    ///
    /// - Parameter IncludingSystemUsers: If true, system users (anonymous and AI) are included.
    /// - Returns: List of users. If no users available, an empty list is returned.
    public static func GetUserList(IncludingSystemUsers: Bool) -> [String]
    {
        if !_WasInitialized
        {
            fatalError("GetUserList called before Initialize called.")
        }
        var UserNames = [String]()
        for User in Users
        {
            if User.UserName == "AI" || User.UserName == "Anonymous"
            {
                continue
            }
            UserNames.append(User.UserName)
        }
        if IncludingSystemUsers
        {
            UserNames.append("AI")
            UserNames.append("Anonymous")
        }
        return UserNames
    }
    
    /// Set the user name.
    ///
    /// - Note: If `Initialize` is not called prior to calling this function, a fatal error will be generated.
    ///
    /// - Parameter NewName: New user name. If the user name already exists, take no action.
    public static func SetUserName(_ NewName: String)
    {
        if !_WasInitialized
        {
            fatalError("SetUserName called before Initialize called.")
        }
    }
    
    /// Return the high score for the specified user and level.
    ///
    /// - Note: If `Initialize` is not called prior to calling this function, a fatal error will be generated.
    ///
    /// - Parameters:
    ///   - UserID: The user's ID.
    ///   - AtLevel: The level.
    /// - Returns: High score for the specified user and level. If no high score exists, 0 is returned.
    public static func GetHighScoreFor(UserID: UUID, AtLevel: Int) -> Int
    {
        if !_WasInitialized
        {
            fatalError("GetHighScoreFor called before Initialize called.")
        }
        let TheUser = GetUser(WithID: UserID)
        if let Level = TheUser!.GetLevel(LevelID: AtLevel)
        {
            return Level.HighScore
        }
        else
        {
            let NewLevel = LevelData(ForLevel: AtLevel)
            TheUser!.Levels.append(NewLevel)
        }
        return 0
    }
    
    /// Set the high score for the user at the specified level.
    ///
    /// - Note: If `Initialize` is not called prior to calling this function, a fatal error will be generated.
    ///
    /// - Parameters:
    ///   - UserID: The user's ID.
    ///   - AtLevel: The level.
    ///   - NewHighScore: The new high score. If the new high score is less than the existing high score, no action will be taken.
    public static func SetHighScoreFor(UserID: UUID, AtLevel: Int, NewHighScore: Int)
    {
        if !_WasInitialized
        {
            fatalError("SetHighScoreFor called before Initialize called.")
        }
        let TheUser = GetUser(WithID: UserID)
        if let Level = TheUser!.GetLevel(LevelID: AtLevel)
        {
            if Level.HighScore < NewHighScore
            {
                Level.HighScore = NewHighScore
            }
        }
        else
        {
            let NewLevel = LevelData(ForLevel: AtLevel)
            NewLevel.HighScore = NewHighScore
            TheUser!.Levels.append(NewLevel)
        }
    }
}

/// Extension of integer arrays.
extension Array where Element == Int
{
    /// Return the closest value in the array to the passed value.
    /// - Parameter To: The value used to find the closest value.
    /// - Returns: The value in the array that is closest to **To**.
    func ClosestValue(To: Int) -> Int
    {
        var Delta = Int.max
        var Closest = 0
        
        for Value in self
        {
            let ValueDelta = abs(Value - To)
            if ValueDelta < Delta
            {
                Delta = ValueDelta
                Closest = Value
            }
        }
        return Closest
    }
}


