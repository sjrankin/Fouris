//
//  UserData.swift
//  WackyDesktopTetris
//
//  Created by Stuart Rankin on 5/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds information about one user.
class UserData: Codable
{
    /// Initializer.
    init()
    {
        _UserName = ""
        _UserID = UUID()
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Name: User name.
    ///   - ID: User ID.
    init(Name: String, ID: UUID)
    {
        _UserName = Name
        _UserID = ID
    }
    
    /// Holds the storage key.
    private var _StorageKey: String? = nil
    /// Get or set the key value for storing user data. Nil if not previously set.
    public var StorageKey: String?
    {
        get
        {
            return _StorageKey
        }
        set
        {
            _StorageKey = newValue
        }
    }
    
    /// Get the dirty flag. The dirty flag is derived from user level data.
    public var IsDirty: Bool
    {
        get
        {
            for SomeLevel in Levels
            {
                if SomeLevel.IsDirty
                {
                    return true
                }
            }
            return false
        }
    }
    
    /// Holds the user name.
    private var _UserName: String = ""
    /// Get the user name.
    public var UserName: String
    {
        get
        {
            return _UserName
        }
    }
    
    /// Holds the User ID.
    private var _UserID: UUID = UUID()
    /// Get the user ID.
    public var UserID: UUID
    {
        get
        {
            return _UserID
        }
    }
    
    /// Holds the level information for the user.
    private var _Levels: [LevelData] = [LevelData]()
    /// Get the level information.
    public var Levels: [LevelData]
    {
        get
        {
            return _Levels
        }
        set
        {
            _Levels = newValue
        }
    }
    
    /// Return the specified level.
    ///
    /// - Parameter LevelID: ID of the level to return.
    /// - Parameter CreateIfDoesNotExist: If true, if the level doesn't exist, create it, add it, then return it.
    /// - Returns: The level on success, nil if not found.
    public func GetLevel(LevelID: Int, CreateIfDoesNotExist: Bool = true) -> LevelData?
    {
        for Level in Levels
        {
            if Level.Level == LevelID
            {
                return Level
            }
        }
        if CreateIfDoesNotExist
        {
            AddLevel(LevelID: LevelID)
            return GetLevel(LevelID: LevelID, CreateIfDoesNotExist: false)
        }
        return nil
    }
    
    /// Add a new, empty level.
    ///
    /// - Parameter LevelID: Level ID.
    public func AddLevel(LevelID: Int)
    {
        let NewLevel = LevelData(ForLevel: LevelID)
        Levels.append(NewLevel)
    }
    
    /// Stores the last level played.
    private var _LastLevelPlayed: Int = 0
    /// Get or set the last level played.
    public var LastLevelPlayed: Int
    {
        get
        {
            return _LastLevelPlayed
        }
        set
        {
            _LastLevelPlayed = newValue
        }
    }
    
    /// Holds the user type.
    private var _UserType: UserTypes = .Player
    /// Get or set the user type.
    public var UserType: UserTypes
    {
        get
        {
            return _UserType
        }
        set
        {
            _UserType = newValue
        }
    }
    
    /// Convert the contents of the class into a JSON string.
    ///
    /// - Returns: A string representation of the contents of the class.
    public func ToJSON() -> String
    {
        let Encoder = JSONEncoder()
        Encoder.outputFormatting = .prettyPrinted
        let Encoded = try! Encoder.encode(self)
        return String(data: Encoded, encoding: .utf8)!
    }
    
    /// Convert a JSON-formatted string into a new UserData class.
    ///
    /// - Parameter JSON: JSON-formatted string.
    /// - Returns: New UserData class.
    public static func FromJSON(JSON: String) -> UserData
    {
        let Decoder = JSONDecoder()
        let NewUserData = try! Decoder.decode(UserData.self, from: JSON.data(using: .utf8)!)
        return NewUserData
    }
}

/// Types of users.
///
/// - Player: Standard user.
/// - Anonymous: Unnamed standard user.
/// - AI: AI (eg, attract mode).
enum UserTypes: Int, CaseIterable, Codable
{
    case Player = 0
    case Anonymous = 1
    case AI = 2
}
