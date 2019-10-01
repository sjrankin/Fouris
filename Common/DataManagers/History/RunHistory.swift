//
//  RunHistory.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class RunHistory: Serializable
{
    // MARK: Deserialization protocol implementation.
    
    /// Sanitizes the passed string by removing all quotation marks.
    /// - Parameter Raw: The string to sanitize.
    /// - Returns: Sanitized string.
    func Sanitize(_ Raw: String) -> String
    {
        let Done = Raw.replacingOccurrences(of: "\"", with: "")
        return Done
    }
    
    /// Populate the class.
    /// - Parameter Key: The key that indicates the property name.
    /// - Parameter Value: The value to assign to the property whose name is in `Key`.
    func Populate(Key: String, Value: String)
    {
        switch Key
        {
            case "_TimeStamp":
                //String
                _TimeStamp = Sanitize(Value)
            
            case "_StandardGameCount":
                //Int
                _StandardGameCount = Int(Value)!
            
            case "_StandardCumulativeScore":
                //Int
                _StandardGameCount = Int(Value)!
            
            case "_StandardHighScore":
                //Int
                _StandardHighScore = Int(Value)!
            
            case "_StandardCumulativeDuration":
                //Int
                _StandardCumulativeDuration = Int(Value)!
            
            case "_CumulativeStandardPieceCount":
                //Int
                _CumulativeStandardPieceCount = Int(Value)!
            
            case "_RotatingGameCount":
                //Int
                _RotatingGameCount = Int(Value)!
            
            case "_RotatingCumulativeScore":
                //Int
                _RotatingCumulativeScore = Int(Value)!
            
            case "_RotatingHighScore":
                //Int
                _RotatingHighScore = Int(Value)!
            
            case "_RotatingCumulativeDuration":
                //Int
                _RotatingCumulativeDuration = Int(Value)!
            
            case "_CumulativeRotatingPieceCount":
                //Int
                _CumulativeRotatingPieceCount = Int(Value)!
            
            case "_CubicGameCount":
                //Int
                _CubicGameCount = Int(Value)!
            
            case "_CubicCumulativeScore":
                //Int
                _CubicCumulativeScore = Int(Value)!
            
            case "_CubicHighScore":
                //Int
                _CubicHighScore = Int(Value)!
            
            case "_CubicCumulativeDuration":
                //Int
                _CubicCumulativeDuration = Int(Value)!
            
            case "_CumulativeCubicPieceCount":
                //Int
                _CumulativeCubicPieceCount = Int(Value)!
            
            default:
                print("Encountered unexpected key for History.xml: \(Key)")
        }
    }
    
    /// Holds the time stamp of the file.
    private var _TimeStamp: String = ""
    /// Get or set the time stamp for the file (in string format).
    public var TimeStamp: String
    {
        get
        {
            return _TimeStamp
        }
        set
        {
            _TimeStamp = newValue
        }
    }
    
    // MARK: Game execution properties.
    
    // MARK: Standard game execution properties.
    
    /// Holds the standard game count.
    private var _StandardGameCount: Int = 0
    /// Get or set the number of standard games started.
    public var StandardGameCount: Int
    {
        get
        {
            return _StandardGameCount
        }
        set
        {
            _StandardGameCount = newValue
        }
    }
    
    /// Holds the cumulative score for standard games.
    private var _StandardCumulativeScore: Int = 0
    /// Get or set the cumulative score for standard games.
    public var StandardCumulativeScore: Int
    {
        get
        {
            return _StandardCumulativeScore
        }
        set
        {
            _StandardCumulativeScore = newValue
        }
    }
    
    /// Holds the high score for standard games.
    private var _StandardHighScore: Int = 0
    /// Get or set the highs core for standard games.
    public var StandardHighScore: Int
    {
        get
        {
            return _StandardHighScore
        }
        set
        {
            _StandardHighScore = newValue
        }
    }
    
    /// Holds the cumulative duration for all standard games.
    private var _StandardCumulativeDuration: Int = 0
    /// Get or set the cumulative duration in seconds of all standard games.
    public var StandardCumulativeDuration: Int
    {
        get
        {
            return _StandardCumulativeDuration
        }
        set
        {
            _StandardCumulativeDuration = newValue
        }
    }
    
    /// Holds the number of pieces completed for all standard games.
    private var _CumulativeStandardPieceCount: Int = 0
    /// Get or set the number of all completed pieces for all standard games.
    public var CumulativeStandardPieceCount: Int
    {
        get
        {
            return _CumulativeStandardPieceCount
        }
        set
        {
            _CumulativeStandardPieceCount = newValue
        }
    }
    
    // MARK: Rotating game execution properties.
    
    /// Holds the rotating game count.
    private var _RotatingGameCount: Int = 0
    /// Get or set the number of rotating games started.
    public var RotatingGameCount: Int
    {
        get
        {
            return _RotatingGameCount
        }
        set
        {
            _RotatingGameCount = newValue
        }
    }
    
    /// Holds the cumulative score for rotating games.
    private var _RotatingCumulativeScore: Int = 0
    /// Get or set the cumulative score for rotating games.
    public var RotatingCumulativeScore: Int
    {
        get
        {
            return _RotatingCumulativeScore
        }
        set
        {
            _RotatingCumulativeScore = newValue
        }
    }
    
    /// Holds the high score for rotating games.
    private var _RotatingHighScore: Int = 0
    /// Get or set the highs core for rotating games.
    public var RotatingHighScore: Int
    {
        get
        {
            return _RotatingHighScore
        }
        set
        {
            _RotatingHighScore = newValue
        }
    }
    
    /// Holds the cumulative duration for all rotating games.
    private var _RotatingCumulativeDuration: Int = 0
    /// Get or set the cumulative duration in seconds of all rotating games.
    public var RotatingCumulativeDuration: Int
    {
        get
        {
            return _RotatingCumulativeDuration
        }
        set
        {
            _RotatingCumulativeDuration = newValue
        }
    }
    
    /// Holds the number of pieces completed for all rotating games.
    private var _CumulativeRotatingPieceCount: Int = 0
    /// Get or set the number of all completed pieces for all rotating games.
    public var CumulativeRotatingPieceCount: Int
    {
        get
        {
            return _CumulativeRotatingPieceCount
        }
        set
        {
            _CumulativeRotatingPieceCount = newValue
        }
    }
    
    // MARK: Cubic game execution properties.
    
    /// Holds the cubic game count.
    private var _CubicGameCount: Int = 0
    /// Get or set the number of cubic games started.
    public var CubicGameCount: Int
    {
        get
        {
            return _CubicGameCount
        }
        set
        {
            _CubicGameCount = newValue
        }
    }
    
    /// Holds the cumulative score for cubic games.
    private var _CubicCumulativeScore: Int = 0
    /// Get or set the cumulative score for cubic games.
    public var CubicCumulativeScore: Int
    {
        get
        {
            return _CubicCumulativeScore
        }
        set
        {
            _CubicCumulativeScore = newValue
        }
    }
    
    /// Holds the high score for cubic games.
    private var _CubicHighScore: Int = 0
    /// Get or set the highs core for cubic games.
    public var CubicHighScore: Int
    {
        get
        {
            return _CubicHighScore
        }
        set
        {
            _CubicHighScore = newValue
        }
    }
    
    /// Holds the cumulative duration for all cubic games.
    private var _CubicCumulativeDuration: Int = 0
    /// Get or set the cumulative duration in seconds of all cubic games.
    public var CubicCumulativeDuration: Int
    {
        get
        {
            return _CubicCumulativeDuration
        }
        set
        {
            _CubicCumulativeDuration = newValue
        }
    }
    
    /// Holds the number of pieces completed for all cubic games.
    private var _CumulativeCubicPieceCount: Int = 0
    /// Get or set the number of all completed pieces for all cubic games.
    public var CumulativeCubicPieceCount: Int
    {
        get
        {
            return _CumulativeCubicPieceCount
        }
        set
        {
            _CumulativeCubicPieceCount = newValue
        }
    }
    
    // MARK: Utility functions for ease of access.
    
    /// Get the high score for the specified game type.
    /// - Returns: The high score for the specified game type.
    public  func GetHighScore(For: BaseGameTypes) -> Int
    {
        switch For
        {
            case .Standard:
                return StandardHighScore
            
            case .Rotating4:
                return RotatingHighScore
            
            case .Cubic:
                return CubicHighScore
        }
    }
    
    /// Set the high score for the specified game type.
    /// - Parameter For: The game type whose high score will be set.
    /// - Parameter NewHighScore: The new high score for the specified game type.
    public func SetHighScore(For: BaseGameTypes, NewHighScore: Int)
    {
        switch For
        {
            case .Standard:
                StandardHighScore = NewHighScore
            
            case .Rotating4:
                RotatingHighScore = NewHighScore
            
            case .Cubic:
                CubicHighScore = NewHighScore
        }
    }
    
    /// Returns the cumulative score for all games for the specified game type.
    /// - Returns: The cumulative score for the specified game type.
    public func GetCumulativeScore(For: BaseGameTypes) -> Int
    {
        switch For
        {
            case .Standard:
                return StandardCumulativeScore
            
            case .Rotating4:
                return RotatingCumulativeScore
            
            case .Cubic:
                return CubicCumulativeScore
        }
    }
    
    /// Set a new cumulative score for the specified game type.
    /// - Parameter For: The game type whose cumulative score will be set.
    /// - Parameter NewCumulativeScore: Score to set for the specified game type.
    public func SetCumulativeScore(For: BaseGameTypes, NewCumulativeScore: Int)
    {
        switch For
        {
            case .Standard:
                StandardCumulativeScore = NewCumulativeScore
            
            case .Rotating4:
                RotatingCumulativeScore = NewCumulativeScore
            
            case .Cubic:
                CubicCumulativeScore = NewCumulativeScore
        }
    }
    
    /// Accumulate the total score for the specified game type.
    /// - Parameter NewScore: Game score to add to the total score for the specified game type.
    public func AccumulateScore(For: BaseGameTypes, NewScore: Int)
    {
        let NewCumulativeScore = GetCumulativeScore(For: For) + NewScore
        SetCumulativeScore(For: For, NewCumulativeScore: NewCumulativeScore)
    }
    
    /// Returns the number of games started (not necessarily played to game over) for the specified
    /// game type.
    /// - Parameter For: The game type whose game count will be returned.
    public func GetGameCount(For: BaseGameTypes) -> Int
    {
        switch For
        {
            case .Standard:
                return StandardGameCount
            
            case .Rotating4:
                return RotatingGameCount
            
            case .Cubic:
                return CubicGameCount
        }
    }
    
    /// Set the game count for the specified game type.
    /// - Parameter For: The game type whose game count will be set.
    /// - Parameter NewGameCount: The new game count for the specified game type.
    public func SetGameCount(For: BaseGameTypes, NewGameCount: Int)
    {
        switch For
        {
            case .Standard:
                StandardGameCount = NewGameCount
            
            case .Rotating4:
                RotatingGameCount = NewGameCount
            
            case .Cubic:
                CubicGameCount = NewGameCount
        }
    }
    
    /// Increments the number of games played for the specified game type.
    /// - Parameter For: The game type whose game count will be incremented by 1.
    public func IncrementGameCount(For: BaseGameTypes)
    {
        let NewGameCount = GetGameCount(For: For) + 1
        SetGameCount(For: For, NewGameCount: NewGameCount)
    }
    
    /// Returns the total number of seconds played for the specified game type.
    /// - Parameter For: The game type whose number of seconds played will be returned.
    public func GetTotalGameSeconds(For: BaseGameTypes) -> Int
    {
        switch For
        {
            case .Standard:
                return StandardCumulativeDuration
            
            case .Rotating4:
                return RotatingCumulativeDuration
            
            case .Cubic:
                return CubicCumulativeDuration
        }
    }
    
    /// Set a new value for the total number of seconds the specified game type has been played.
    /// - Parameter For: The game type whose total number of seconds will be set.
    /// - Parameter NewDuration: New value to set for the total number of seconds played.
    public func SetTotalGameSeconds(For: BaseGameTypes, NewDuration: Int)
    {
        switch For
        {
            case .Standard:
                StandardCumulativeDuration = NewDuration
            
            case .Rotating4:
                RotatingCumulativeDuration = NewDuration
            
            case .Cubic:
                CubicCumulativeDuration = NewDuration
        }
    }
    
    /// Accumulate the number of seconds played for the specified game type.
    /// - Parameter For: The game type to accumulate game time for.
    /// - Parameter NewDuration: Duration to add to the existing game duration for the specified game type.
    public func AccumulateGameDuration(For: BaseGameTypes, NewDuration: Int)
    {
        let NewCumulativeDuration = GetTotalGameSeconds(For: For) + NewDuration
        SetTotalGameSeconds(For: For, NewDuration: NewCumulativeDuration)
    }
    
    /// Returns the total number of pieces played (eg, completed) for the specified game type.
    /// - Parameter For: The game type whose number of pieces will be returned.
    /// - Returns: The number of pieces completed for the specified game type.
    public func GetTotalPieceCount(For: BaseGameTypes) -> Int
    {
        switch For
        {
            case .Standard:
                return CumulativeStandardPieceCount
            
            case .Rotating4:
                return CumulativeRotatingPieceCount
            
            case .Cubic:
                return CumulativeCubicPieceCount
        }
    }
    
    /// Sets a new total piece count for the specified game type.
    /// - Parameter For: Game type to set the new value for.
    /// - Parameter NewCount: New total piece count.
    public func SetTotalPieceCount(For: BaseGameTypes, NewCount: Int)
    {
        switch For
        {
            case .Standard:
                CumulativeStandardPieceCount = NewCount
            
            case .Rotating4:
                CumulativeRotatingPieceCount = NewCount
            
            case .Cubic:
                CumulativeCubicPieceCount = NewCount
        }
    }
    
    /// Accumulates the piece count for the specified game type.
    /// - Parameter For: Game type to accumulate the piece count for.
    /// - Parameter NewCount: Value to add to the existing piece count.
    public func AccumulatePieceCount(For: BaseGameTypes, NewCount: Int)
    {
        let NewPieceCount = GetTotalPieceCount(For: For) + NewCount
        SetTotalPieceCount(For: For, NewCount: NewPieceCount)
    }
}
