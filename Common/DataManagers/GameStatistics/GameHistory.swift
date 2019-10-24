//
//  GameHistory.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/2/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds game history (for either the user or the AI). No individually-identifiable information is collected or saved.
class GameHistory: CustomStringConvertible
{
    /// Holds the dirty flag.
    public var _Dirty: Bool = false
    /// Get the dirty flag. To reset, call `ToString` with the appropriate parameter set.
    public var Dirty: Bool
    {
        get
        {
            return _Dirty
        }
    }
    #if false
    /// Holds the game type.
    public var _GameType: BaseGameTypes = .Standard
    /// Get or set the game type.
    public var GameType: BaseGameTypes
    {
        get
        {
            return _GameType
        }
        set
        {
            _GameType = newValue
            _Dirty = true
        }
    }
    #endif
    /// Holds the game count.
    public var _GameCount: Int = 0
    /// Get or set the cumulative game count.
    public var GameCount: Int
    {
        get
        {
            return _GameCount
        }
        set
        {
            _GameCount = newValue
            _Dirty = true
        }
    }
    
    /// Increment the game count by 1.
    /// - Returns: The new game count.
    @discardableResult public func IncrementGameCount() -> Int
    {
        GameCount = GameCount + 1
        return _GameCount
    }
    
    /// Holds the cumulative game score.
    public var _CumulativeScore: Int = 0
    /// Get or set the cumulative game score.
    public var CumulativeScore: Int
    {
        get
        {
            return _CumulativeScore
        }
        set
        {
            _CumulativeScore = newValue
            _Dirty = true
        }
    }
    
    /// Adds a new score to the `CumulativeScore`.
    /// - Parameter NewScore: New game score to add.
    /// - Returns: New cumulative score.
    @discardableResult public func AddScore(NewScore: Int) -> Int
    {
        CumulativeScore = CumulativeScore + NewScore
        return _CumulativeScore
    }
    
    /// Holds the high score.
    public var _HighScore: Int = 0
    /// Get or set the high score.
    public var HighScore: Int
    {
        get
        {
            return _HighScore
        }
        set
        {
            _HighScore = newValue
            _Dirty = true
        }
    }
    
    /// Update the high score. If `NewScore` is greater than `HighScore`, the high score is updated. Otherwise, no action is taken.
    /// - Parameter NewScore: Score to set (potentially) as the high score.
    /// - Returns: The current high score.
    @discardableResult public func SetHighScore(NewScore: Int) -> Int
    {
        if NewScore > HighScore
        {
            HighScore = NewScore
        }
        return HighScore
    }
    
    /// Holds the duration of game play (in seconds).
    public var _Duration: Int = 0
    /// Get or set the total number of seconds of game play.
    public var Duration: Int
    {
        get
        {
            return _Duration
        }
        set
        {
            _Duration = newValue
            _Dirty = true
        }
    }
    
    /// Accumulate the game play duration.
    /// - Parameter NewDuration: The new duration of game play.
    /// - Returns: Duration of game play in seconds.
    @discardableResult public func AddDuration(NewDuration: Int) -> Int
    {
        Duration = Duration + NewDuration
        return Duration
    }
    
    /// Holds the cumulative number of pieces completed.
    public var _CumulativePieces: Int = 0
    /// Get or set the cumulative number of pieces completed.
    public var CumulativePieces: Int
    {
        get
        {
            return _CumulativePieces
        }
        set
        {
            _CumulativePieces = newValue
            _Dirty = true
        }
    }
    
    /// Increment the number of completed pieces.
    /// - Returns: The total number of completed pieces.
    @discardableResult public func IncrementPieceCount() -> Int
    {
        CumulativePieces = CumulativePieces + 1
        return CumulativePieces
    }
    
    // MARK: CustomStringConvertible functions and related.
    
    /// Returns a string with the passed number of spaces in it.
    /// - Parameter Count: Number of spaces to include in the string.
    /// - Returns: String with the specified number of spaces in it.
    private func Spaces(_ Count: Int) -> String
    {
        var SpaceString = ""
        for _ in 0 ..< Count
        {
            SpaceString = SpaceString + " "
        }
        return SpaceString
    }
    
    /// Returns the passed string surrounded by quotation marks.
    /// - Parameter Raw: The string to return surrounded by quotation marks.
    /// - Returns: `Raw` surrounded by quotation marks.
    private func Quoted(_ Raw: String) -> String
    {
        return "\"\(Raw)\""
    }
    
    /// Converts the contents of the class to an XML fragment.
    /// - Parameter Indent: Number of spaces to use for indentation.
    /// - Parameter ResetDirtyFlag: Determines if the dirty flag is reset.
    /// - Returns: XML fragment containing the contents of the instance of this class.
    func ToString(Indent: Int = 4, ResetDirtyFlag: Bool = true) -> String
    {
        if ResetDirtyFlag
        {
            _Dirty = false
        }
        
        var Working = ""
        //Working.append(Spaces(Indent) + "<GameType Name=" + Quoted(GameType.rawValue) + ">\n")
        
        Working.append(Spaces(Indent + 4) + "<GameCount Started=" + Quoted("\(GameCount)") + "/>\n")
        Working.append(Spaces(Indent + 4) + "<Score Cumulative=" + Quoted("\(CumulativeScore)") +
            " High=" + Quoted("\(HighScore)") + "/>\n")
        Working.append(Spaces(Indent + 4) + "<Duration Seconds=" + Quoted("\(Duration)") + "/>\n")
        Working.append(Spaces(Indent + 4) + "<Pieces Cumulative=" + Quoted("\(CumulativePieces)") + "/>\n")
        
        Working.append(Spaces(Indent) + "</GameType>\n")
        
        return Working
    }
    
    /// Returns a string description of the contents of the instance of this class.
    /// - Note: Calls `ToString()`.
    var description: String
    {
        return ToString()
    }
}
