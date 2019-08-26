//
//  LevelData.swift
//  WackyDesktopTetris
//
//  Created by Stuart Rankin on 5/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Encapsulates level data for a given user.
class LevelData: Codable
{
    /// Initializer.
    ///
    /// - Parameter ForLevel: Initialize for the specified level.
    init(ForLevel: Int)
    {
        _Level = ForLevel
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - ForLevel: Initialize for the specified level.
    ///   - LevelGameCount: Previous game count for the level.
    ///   - TotalDuration: Total duration (in seconds) for the level.
    ///   - LevelHighScore: Previous high score for the level.
    init(ForLevel: Int, LevelGameCount: Int, TotalDuration: Double, LevelHighScore: Int)
    {
        _Level = ForLevel
        Duration = TotalDuration
        GameCount = LevelGameCount
        HighScore = LevelHighScore
    }
    
    /// Holds the dirty flag value.
    private var _IsDirty: Bool = false
    /// Get or set the dirty flag.
    public var IsDirty: Bool
    {
        get
        {
            return _IsDirty
        }
        set
        {
            _IsDirty = newValue
        }
    }
    
    /// Holds the level identifier.
    private var _Level: Int = 0
    /// Get the level identifier.
    public var Level: Int
    {
        get
        {
            return _Level
        }
    }
    
    /// Holds the number of games for this level and user.
    private var _GameCount: Int = 0
    /// Get or set the number of games run for the level and user.
    public var GameCount: Int
    {
        get
        {
            return _GameCount
        }
        set
        {
            IsDirty = true
            _GameCount = newValue
        }
    }
    
    /// Holds the number of seconds the user played this level.
    private var _Duration: Double = 0.0
    /// Get or set the number of seconds played at this level.
    public var Duration: Double
    {
        get
        {
            return _Duration
        }
        set
        {
            IsDirty = true
            _Duration = newValue
        }
    }
    
    /// Holds the high score for this level.
    private var _HighScore: Int = 0
    /// Get or set the high score for this level.
    public var HighScore: Int
    {
        get
        {
            return _HighScore
        }
        set
        {
            if newValue > _HighScore
            {
                IsDirty = true
                _HighScore = newValue
            }
        }
    }
    
    /// Holds the cumulative score for the level.
    private var _CumulativeScore: Int = 0
    /// Get or set the cumulative score.
    public var CumulativeScore: Int
    {
        get
        {
            return _CumulativeScore
        }
        set
        {
            IsDirty = true
            _CumulativeScore = newValue
        }
    }
    
    /// Holds the cumulative number of successfully placed pieces.
    private var _CumulativePieces: Int = 0
    /// Get or set the cumulative number of successfully placed pieces.
    public var CumulativePieces: Int
    {
        get
        {
            return _CumulativePieces
        }
        set
        {
            _CumulativePieces = newValue
        }
    }
}
