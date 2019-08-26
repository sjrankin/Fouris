//
//  GameLevelDescription.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Tells the game, board, and pieces how to behave based on a difficulty level passed at initialization time. The instance
/// passed to the game is used as a source for parameters for timers, counts, and the like.
class GameLevelDescription
{
    /// Initializer.
    ///
    /// - Parameter Level: Determines the difficulty level.
    init(_ Level: LevelTypes)
    {
        _Difficulty = Level
    }
    
    /// Holds the current level mode.
    private var _CurrentMode: ModeTypes = .NormalMode
    /// Get or set the current level mode.
    public var CurrentMode: ModeTypes
    {
        get
        {
            return _CurrentMode
        }
        set
        {
            _CurrentMode = newValue
        }
    }
    
    /// Holds the difficulty level.
    private var _Difficulty: LevelTypes = .ReallyEasy
    /// Get the difficulty level.
    public var Difficulty: LevelTypes
    {
        get
        {
            return _Difficulty
        }
    }
    
    /// Holds the size of the playing board.
    private var _BoardSize: CGSize = CGSize(width: 12, height: 30)
    /// Get or set the size of the board.
    public var BoardSize: CGSize
    {
        get
        {
            return _BoardSize
        }
        set
        {
            _BoardSize = newValue
        }
    }
    
    /// Holds the game's gravitational constant.
    private var _Gravity: Double = 0.35
    /// Get or set the gravitational constant.
    public var Gravity: Double
    {
        get
        {
            return _Gravity
        }
        set
        {
            _Gravity = newValue
        }
    }
    
    /// Holds the gravity increases over time flag.
    private var _GravityIncreases: Bool = false
    /// Get or set the flag that indicates gravity increases over time.
    public var GravityIncreases: Bool
    {
        get
        {
            return _GravityIncreases
        }
        set
        {
            _GravityIncreases = newValue
        }
    }
    
    /// Holds the spatial variant gravity flag.
    private var _GravityChangesSpatially: Bool = false
    /// Get or set the flag that indicates gravity varies spatially.
    public var GravityChangesSpatially: Bool
    {
        get
        {
        return _GravityChangesSpatially
        }
        set
        {
            _GravityChangesSpatially = newValue
        }
    }

    /// Holds the list of valid game modes for the level.
    var ValidModes = [ModeTypes.AttractMode, ModeTypes.NormalMode, ModeTypes.ZenMode, ModeTypes.MultiUserMode]
    
    /// Holds the list of valid sets of pieces.
    var ValidPieceSets = [MetaPieces.Standard]
    
    /// Holds the list of valid motions a piece may take.
    var ValidPieceMotions = [Directions.Left, Directions.Right, Directions.Down, Directions.DropDown]
    
    /// Holds the list of valid rotations for the piece.
    var ValidPieceRotations = [RotationTypes.RotateLeft, RotationTypes.RotateRight]
    
    /// Holds a list of good button types.
    var GoodButtons = [GoodButtonTypes.StopGravity, GoodButtonTypes.Delete1Row]
    
    /// Holds range for good button appearance duration.
    var GoodButtonDuration: ClosedRange<Double> = 1.0 ... 30.0
    
    /// Holds range for good button probability appearance (per bucket location).
    var GoodButtonProbability: ClosedRange<Double> = 0.0 ... 0.005
    
    /// Holds the maximum number of good buttons that may be present at any given time.
    var MaxGoodButtons: Int = 10
    
    /// Holds a list of bad button types.
    var BadButtons = [BadButtonTypes.IncreaseGravity, BadButtonTypes.AddRandomBlocks]
    
    /// Holds range for bad button appearance duration.
    var BadButtonDuration: ClosedRange<Double> = 1.0 ... 30.0
    
    /// Holds range for bad button probability appearance (per bucket location).
    var BadButtonProbability: ClosedRange<Double> = 0.0 ... 0.01
    
    /// Holds the maximum number of bad buttons that may be present at any given time.
    var MaxBadButtons: Int = 5
    
    /// Holds meta-distractions.
    var Distractions = [MetaDistractions.NoDistractions]
    
    /// Holds the show hints flag.
    private var _ShowHints: Bool = true
    /// Get or set the show hints flag.
    public var ShowHints: Bool
    {
        get
        {
            return _ShowHints
        }
        set
        {
            _ShowHints = newValue
        }
    }
}

/// Types of rotations a piece may undertake.
///
/// - RotateLeft: Rotate left (counter-clockwise).
/// - RotateRight: Rotate right (clockwise).
enum RotationTypes: Int, CaseIterable
{
    case RotateLeft = 0
    case RotateRight = 1
}

/// Level types.
///
/// - Attract: Attract mode. Runs by itself without user input.
/// - ReallyEasy: Beginner mode.
/// - Easy: Easy mode.
/// - Medium: Slightly harder than easy.
/// - SomewhatHard: Easier than difficult.
/// - Difficult: Difficult mode.
/// - ReallyDifficult: Really hard mode.
/// - Impossible: Dont' even try.
enum LevelTypes: Int, CaseIterable
{
    case ReallyEasy = 0
    case Easy = 1
    case Medium = 2
    case SomewhatHard = 3
    case Difficult = 4
    case ReallyDifficult = 5
    case Impossible = 6
}

/// Game modes.
///
/// - AttractMode: Attract (AI) mode.
/// - NormalMode: Normal game mode (single user).
/// - ZenMode: Zen mode (always have a place to fit a piece).
/// - MultiUserMode: Multi-user mode.
enum ModeTypes: Int, CaseIterable
{
    case AttractMode = 0
    case NormalMode = 1
    case ZenMode = 2
    case MultiUserMode = 3
}

/// Meta-distractions. These are distractions based on the entire visible playing board,
/// not pieces or gravity.
///
/// - NoDistractions: No distraction.
/// - BucketSwings: The bucket swings back and forth.
/// - BucketRotates: The bucket rotates through 360°.
/// - BucketRotates3D: The bucket rotates through 360° in three axes.
enum MetaDistractions: Int, CaseIterable
{
    case NoDistractions = 0
    case BucketSwings = 1
    case BucketRotates = 2
    case BucketRotates3D = 3
}
