//
//  Settings.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages settings for Fouris. Allows for consumers to subscribe to settings to be notified of changes.
class Settings
{
    // MARK: Initialization
    
    private static let _Settings = UserDefaults.standard
    private static let _InitializationValue = "ed7dfe6e-d6a4-4eec-965f-82aae0094856"
    private static var _WasInitialized = false
    private static var Subscribers: [(String, SettingsChangedProtocol?)]? = nil
    
    /// Initialize the settings. If not called before use, a fatal error will be generated.
    /// - Note: The following default values are set (refer to individual function documentation
    ///         for the context of the default settings):
    ///   - **Initialized**: Set to "Initialized".
    ///   - **ShowInitialVersionBox**: Set to **true**.
    ///   - **ShowFPSInUI**: Set to **false**.
    ///   - **ShowInstanceSecondsInstead**: Set to **false**.
    ///   - **MaximumSamePiecesInARow**: Set to **3**.
    ///   - **LastGameViewIndex**: Set to **0**.
    ///   - **UseTDebug**: Set to **true**.
    ///   - **ColorPickerColorSpace**: Set to **0** (for RGB).
    ///   - **ShowAlphaInColorPicker**: Set to **false**.
    ///   - **MostRecentlyUsedColorCapacity**: Set to **20**.
    ///   - **MostRecentlyUsedColorList**: Set to empty string.
    ///   - **ConfirmGameImageSave**: Set to **false**.
    ///   - **ShowCameraControls**: Set to **true**.
    ///   - **ShowMotionControls**: Set to **true**.
    ///   - **ShowColorsInOriginalLanguage**: Set to **true**.
    ///   - **InterfaceLanguage**: Set to **"US English"**.
    ///   - **TDebugSessionTimeOut**: Set to **10**.
    ///   - **CurrentTheme**: Set to **83c630ee-81d4-11e9-bc42-526af7764f64**.
    ///   - **Current3DTheme**: Set to **3f0d9fee-0b77-465b-a0ac-f1663da23cc9**.
    public static func Initialize()
    {
        _WasInitialized = true
        if let _ = _Settings.string(forKey: "Initialized")
        {
            return
        }
        _Settings.set("Initialized", forKey: "Initialized")
        _Settings.set(true, forKey: "ShowInitialVersionBox")
        _Settings.set(false, forKey: "ShowFPSInUI")
        _Settings.set(false, forKey: "ShowInstanceSecondsInstead")
        _Settings.set(3, forKey: "MaximumSamePiecesInARow")
        _Settings.set(0, forKey: "LastGameViewIndex")
        _Settings.set(true, forKey: "UseTDebug")
        _Settings.set(0, forKey: "ColorPickerColorSpace")
        _Settings.set(false, forKey: "ShowAlphaInColorPicker")
        _Settings.set(20, forKey: "MostRecentlyUsedColorCapacity")
        _Settings.set("", forKey: "MostRecentlyUsedColorList")
        _Settings.set(false, forKey: "ConfirmGameImageSave")
        _Settings.set(true, forKey: "ShowCameraControls")
        _Settings.set(true, forKey: "ShowMotionControls")
        _Settings.set(true, forKey: "ShowColorsInOriginalLanguage")
        _Settings.set("US English", forKey: "InterfaceLanguage")
        _Settings.set(10, forKey: "TDebugSessionTimeOut")
        _Settings.set("83c630ee-81d4-11e9-bc42-526af7764f64", forKey: "CurrentTheme")
        _Settings.set("3f0d9fee-0b77-465b-a0ac-f1663da23cc9", forKey: "Current3DTheme")
    }
    
    // MARK: - Subscription and notification functions.
    
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
    
    // MARK: - Custom functions to access customization.
    
    /// Get the number of seconds to wait for session time-outs for TDebug.
    /// - Returns: Number of seconds to wait for session time-outs.
    public static func GetTDebugSessionTimeOut() -> Int
    {
        let Raw = _Settings.integer(forKey: "TDebugSessionTimeOut")
        if Raw == 0
        {
            SetTDebugSessionTimeOut(NewValue: 10)
            return 10
        }
        return Raw
    }
    
    /// Set the number of seconds to wait for session time-outs for TDebug.
    /// - Parameter NewValue: The number of seconds to wait for TDebug time-outs. If less than 1,
    ///                       10 is written instead.
    public static func SetTDebugSessionTimeOut(NewValue: Int)
    {
        let FinalValue = NewValue < 1 ? 10 : NewValue
        _Settings.set(FinalValue, forKey: "TDebugSessionTimeOut")
    }
    
    /// Get the user-selected UI language. Default is US English.
    /// - Returns: Current UI language.
    public static func GetInterfaceLanguage() -> SupportedLanguages
    {
        if let Raw = _Settings.string(forKey: "InterfaceLanguage")
        {
        return SupportedLanguages(rawValue: Raw)!
        }
        else
        {
            return SupportedLanguages.EnglishUS
        }
    }
    
    /// Get the flag that shows the version box when first starting up.
    /// - Returns: The show version box flag.
    public static func GetShowVersionBox() -> Bool
    {
        return _Settings.bool(forKey: "ShowInitialVersionBox")
    }
    
    /// Set the show version box when starting flag.
    /// - Parameter NewValue: New value for the show initial version box flag.
    public static func SetShowVersionBox(NewValue: Bool)
    {
        _Settings.set(NewValue, forKey: "ShowInitialVersionBox")
    }
    
    /// Set the UI language.
    /// - Parameter NewValue: A supported UI language.
    public static func SetInterfaceLanguage(NewValue: SupportedLanguages)
    {
        let Raw = "\(NewValue)"
        _Settings.set(Raw, forKey: "InterfaceLanguage")
                SendNotice(From: .InterfaceLanguage, NewValue: NewValue)
    }
    
    /// Get the show color names in the source language flag.
    /// - Returns: Flag that indicates language to use for color names. If false, English is used.
    public static func GetShowColorsInSourceLanguage() -> Bool
    {
        return _Settings.bool(forKey: "ShowColorsInOriginalLanguage")
    }

    /// Set the show color names in source language flag.
    /// - Parameter NewValue: If true, color names are in their original language. If false, English is used.
    public static func SetShowColorsInSourceLanguage(NewValue: Bool)
    {
        _Settings.set(NewValue, forKey: "ShowColorsInOriginalLanguage")
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
    
    /// Get the show instance seconds instead of FPS values.
    /// - Truens: True if seconds should be shown instead of FPS, false if FPS should be shown.
    public static func ShowInstanceSeconds() -> Bool
    {
        return _Settings.bool(forKey: "ShowInstanceSecondsInstead")
    }

    /// Set the show instance seconds flag.
    /// - Parameter NewValue: New show instance seconds flag value.
    public static func SetShowInstanceSeconds(NewValue: Bool)
    {
        _Settings.set(NewValue, forKey: "ShowInstanceSecondsInstead")
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
}

// MARK: - [Int] extenions.

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


