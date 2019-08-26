//
//  LevelManager.swift
//  WackyDesktopTetris
//
//  Created by Stuart Rankin on 5/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages level descriptions.
class LevelManager
{
    /// Initialize the level manager. If not called, no levels will be available.
    public static func Initialize()
    {
        CreateLevels()
    }
    
    /// Creates levels.
    private static func CreateLevels()
    {
        for Difficulty in LevelTypes.allCases
        {
            let NewLevel = GameLevelDescription(Difficulty)
            switch Difficulty
            {
            case .ReallyEasy:
                NewLevel.ValidPieceSets = [MetaPieces.Standard]
                NewLevel.ValidPieceMotions = [Directions.Left, Directions.Right, Directions.Down, Directions.DropDown, Directions.Up, Directions.UpAndAway]
                NewLevel.ValidPieceRotations = [RotationTypes.RotateLeft, RotationTypes.RotateRight]
                NewLevel.ShowHints = true
                NewLevel.Gravity = 0.5
                NewLevel.GravityIncreases = false
                NewLevel.GravityChangesSpatially = false
                NewLevel.GoodButtons = [GoodButtonTypes.StopGravity, GoodButtonTypes.Delete1Row, GoodButtonTypes.Delete2Rows, GoodButtonTypes.Delete3Rows,
                                        GoodButtonTypes.DeleteRandomly, GoodButtonTypes.EmptyBucket, GoodButtonTypes.MakeRoom, GoodButtonTypes.RemoveAllOfCurrentType]
                NewLevel.GoodButtonDuration = 3.5 ... 60.0
                NewLevel.GoodButtonProbability = 0.0 ... 0.05
                NewLevel.MaxGoodButtons = 15
                NewLevel.BadButtons = [BadButtonTypes.IncreaseGravity]
                NewLevel.BadButtonDuration = 2.5 ... 15.0
                NewLevel.BadButtonProbability = 0.0 ... 0.001
                NewLevel.MaxBadButtons = 2
                
            case .Easy:
                NewLevel.ValidPieceSets = [MetaPieces.Standard]
                NewLevel.ValidPieceMotions = [Directions.Left, Directions.Right, Directions.Down, Directions.DropDown, Directions.Up, Directions.UpAndAway]
                NewLevel.ValidPieceRotations = [RotationTypes.RotateLeft, RotationTypes.RotateRight]
                NewLevel.ShowHints = true
                NewLevel.Gravity = 0.4
                NewLevel.GravityIncreases = false
                NewLevel.GravityChangesSpatially = false
                NewLevel.GoodButtons = [GoodButtonTypes.StopGravity, GoodButtonTypes.Delete1Row, GoodButtonTypes.Delete2Rows, GoodButtonTypes.Delete3Rows,
                                        GoodButtonTypes.DeleteRandomly, GoodButtonTypes.EmptyBucket, GoodButtonTypes.MakeRoom, GoodButtonTypes.RemoveAllOfCurrentType]
                NewLevel.GoodButtonDuration = 3.5 ... 60.0
                NewLevel.GoodButtonProbability = 0.0 ... 0.05
                NewLevel.MaxGoodButtons = 15
                NewLevel.BadButtons = [BadButtonTypes.IncreaseGravity, BadButtonTypes.RetiredPiecesTurnInvisible]
                NewLevel.BadButtonDuration = 2.5 ... 30.0
                NewLevel.BadButtonProbability = 0.0 ... 0.05
                NewLevel.MaxBadButtons = 4
                
            case .Medium:
                NewLevel.ValidPieceSets = [MetaPieces.Standard, MetaPieces.NonStandard]
                NewLevel.ValidPieceMotions = [Directions.Left, Directions.Right, Directions.Down, Directions.DropDown, Directions.Up, Directions.UpAndAway]
                NewLevel.ValidPieceRotations = [RotationTypes.RotateLeft, RotationTypes.RotateRight]
                NewLevel.ShowHints = true
                NewLevel.Gravity = 0.3
                NewLevel.GravityIncreases = false
                NewLevel.GravityChangesSpatially = false
                NewLevel.GoodButtons = [GoodButtonTypes.StopGravity, GoodButtonTypes.Delete1Row, GoodButtonTypes.Delete2Rows, GoodButtonTypes.Delete3Rows,
                                        GoodButtonTypes.DeleteRandomly, GoodButtonTypes.EmptyBucket, GoodButtonTypes.MakeRoom, GoodButtonTypes.RemoveAllOfCurrentType]
                NewLevel.GoodButtonDuration = 3.5 ... 60.0
                NewLevel.GoodButtonProbability = 0.0 ... 0.05
                NewLevel.MaxGoodButtons = 15
                NewLevel.BadButtons = [BadButtonTypes.IncreaseGravity, BadButtonTypes.RetiredPiecesTurnInvisible, BadButtonTypes.AddRandomBlocks,
                                       BadButtonTypes.RandomGravity, BadButtonTypes.AddRandomBucketWalls]
                NewLevel.BadButtonDuration = 2.5 ... 30.0
                NewLevel.BadButtonProbability = 0.0 ... 0.05
                NewLevel.MaxBadButtons = 10
                
            case .SomewhatHard:
                NewLevel.ValidPieceSets = [MetaPieces.Standard, MetaPieces.NonStandard]
                NewLevel.ValidPieceMotions = [Directions.Left, Directions.Right, Directions.Down, Directions.DropDown, Directions.Up, Directions.UpAndAway]
                NewLevel.ValidPieceRotations = [RotationTypes.RotateLeft, RotationTypes.RotateRight]
                NewLevel.ShowHints = true
                NewLevel.Gravity = 0.3
                NewLevel.GravityIncreases = false
                NewLevel.GravityChangesSpatially = false
                NewLevel.GoodButtons = [GoodButtonTypes.StopGravity, GoodButtonTypes.Delete1Row, GoodButtonTypes.Delete2Rows, GoodButtonTypes.Delete3Rows,
                                        GoodButtonTypes.DeleteRandomly, GoodButtonTypes.EmptyBucket, GoodButtonTypes.MakeRoom, GoodButtonTypes.RemoveAllOfCurrentType]
                NewLevel.GoodButtonDuration = 3.5 ... 60.0
                NewLevel.GoodButtonProbability = 0.0 ... 0.05
                NewLevel.MaxGoodButtons = 15
                NewLevel.BadButtons = [BadButtonTypes.IncreaseGravity, BadButtonTypes.RetiredPiecesTurnInvisible, BadButtonTypes.AddRandomBlocks,
                                       BadButtonTypes.RandomGravity, BadButtonTypes.AddRandomBucketWalls]
                NewLevel.BadButtonDuration = 2.5 ... 30.0
                NewLevel.BadButtonProbability = 0.0 ... 0.05
                NewLevel.MaxBadButtons = 10
                
            case .Difficult:
                NewLevel.ValidPieceSets = [MetaPieces.Standard, MetaPieces.NonStandard, MetaPieces.PiecesWithGaps]
                NewLevel.ValidPieceMotions = [Directions.Left, Directions.Right, Directions.Down, Directions.DropDown]
                NewLevel.ValidPieceRotations = [RotationTypes.RotateLeft, RotationTypes.RotateRight]
                NewLevel.ShowHints = true
                NewLevel.Gravity = 0.25
                NewLevel.GravityIncreases = true
                NewLevel.GravityChangesSpatially = false
                NewLevel.GoodButtons = [GoodButtonTypes.StopGravity, GoodButtonTypes.Delete1Row, GoodButtonTypes.Delete2Rows, GoodButtonTypes.Delete3Rows,
                                        GoodButtonTypes.DeleteRandomly, GoodButtonTypes.EmptyBucket, GoodButtonTypes.MakeRoom, GoodButtonTypes.RemoveAllOfCurrentType,
                                        GoodButtonTypes.InvisibleBucketWallsRemoved]
                NewLevel.GoodButtonDuration = 3.5 ... 60.0
                NewLevel.GoodButtonProbability = 0.0 ... 0.05
                NewLevel.MaxGoodButtons = 10
                NewLevel.BadButtons = [BadButtonTypes.IncreaseGravity, BadButtonTypes.RetiredPiecesTurnInvisible, BadButtonTypes.AddRandomBlocks,
                                       BadButtonTypes.RandomGravity, BadButtonTypes.AddRandomBucketWalls, BadButtonTypes.AddInvisibleBucketWalls,
                                       BadButtonTypes.NegativeGravity]
                NewLevel.BadButtonDuration = 2.5 ... 60.0
                NewLevel.BadButtonProbability = 0.0 ... 0.05
                NewLevel.MaxBadButtons = 15
                NewLevel.Distractions = [MetaDistractions.BucketSwings]
                
            case .ReallyDifficult:
                NewLevel.ValidPieceSets = [MetaPieces.Standard, MetaPieces.NonStandard, MetaPieces.PiecesWithGaps, MetaPieces.RandomPieces]
                NewLevel.ValidPieceMotions = [Directions.Left, Directions.Right, Directions.Down, Directions.DropDown]
                NewLevel.ValidPieceRotations = [RotationTypes.RotateLeft, RotationTypes.RotateRight]
                NewLevel.ShowHints = true
                NewLevel.Gravity = 0.2
                NewLevel.GravityIncreases = true
                NewLevel.GravityChangesSpatially = true
                NewLevel.GoodButtons = [GoodButtonTypes.StopGravity, GoodButtonTypes.Delete1Row, GoodButtonTypes.Delete2Rows, GoodButtonTypes.Delete3Rows,
                                        GoodButtonTypes.DeleteRandomly, GoodButtonTypes.EmptyBucket, GoodButtonTypes.MakeRoom, GoodButtonTypes.RemoveAllOfCurrentType,
                                        GoodButtonTypes.InvisibleBucketWallsRemoved]
                NewLevel.GoodButtonDuration = 3.5 ... 30.0
                NewLevel.GoodButtonProbability = 0.0 ... 0.05
                NewLevel.MaxGoodButtons = 5
                NewLevel.BadButtons = [BadButtonTypes.IncreaseGravity, BadButtonTypes.RetiredPiecesTurnInvisible, BadButtonTypes.AddRandomBlocks,
                                       BadButtonTypes.RandomGravity, BadButtonTypes.AddRandomBucketWalls, BadButtonTypes.AddInvisibleBucketWalls,
                                       BadButtonTypes.NegativeGravity, BadButtonTypes.MirrorImagePiece, BadButtonTypes.MutatesPieceShape]
                NewLevel.BadButtonDuration = 2.5 ... 120.0
                NewLevel.BadButtonProbability = 0.0 ... 0.05
                NewLevel.MaxBadButtons = 20
                NewLevel.Distractions = [MetaDistractions.BucketSwings, MetaDistractions.BucketRotates]
                
            case .Impossible:
                NewLevel.ValidPieceSets = [MetaPieces.Standard, MetaPieces.NonStandard, MetaPieces.PiecesWithGaps, MetaPieces.Malicious,
                                           MetaPieces.Big, MetaPieces.RandomPieces]
                NewLevel.ValidPieceMotions = [Directions.Left, Directions.Right, Directions.Down, Directions.DropDown]
                NewLevel.ValidPieceRotations = [RotationTypes.RotateLeft, RotationTypes.RotateRight]
                NewLevel.ShowHints = true
                NewLevel.Gravity = 0.15
                NewLevel.GravityIncreases = true
                NewLevel.GravityChangesSpatially = true
                NewLevel.GoodButtons = [GoodButtonTypes.StopGravity, GoodButtonTypes.Delete1Row, GoodButtonTypes.Delete2Rows, GoodButtonTypes.Delete3Rows,
                                        GoodButtonTypes.DeleteRandomly, GoodButtonTypes.EmptyBucket, GoodButtonTypes.MakeRoom, GoodButtonTypes.RemoveAllOfCurrentType,
                                        GoodButtonTypes.InvisibleBucketWallsRemoved]
                NewLevel.GoodButtonDuration = 3.5 ... 15.0
                NewLevel.GoodButtonProbability = 0.0 ... 0.05
                NewLevel.MaxGoodButtons = 5
                NewLevel.BadButtons = [BadButtonTypes.IncreaseGravity, BadButtonTypes.RetiredPiecesTurnInvisible, BadButtonTypes.AddRandomBlocks,
                                       BadButtonTypes.RandomGravity, BadButtonTypes.AddRandomBucketWalls, BadButtonTypes.AddInvisibleBucketWalls,
                                       BadButtonTypes.NegativeGravity, BadButtonTypes.MirrorImagePiece, BadButtonTypes.MutatesPieceShape]
                NewLevel.BadButtonDuration = 2.5 ... 120.0
                NewLevel.BadButtonProbability = 0.0 ... 0.05
                NewLevel.MaxBadButtons = 25
                NewLevel.Distractions = [MetaDistractions.BucketSwings, MetaDistractions.BucketRotates, MetaDistractions.BucketRotates3D]
            }
            LevelTable.append(NewLevel)
        }
    }
    
    /// Return the specified level with the specified mode.
    ///
    /// - Parameters:
    ///   - LevelType: The desired level.
    ///   - ForMode: The desired game mode.
    /// - Returns: The level description for the level/mode combination. Nil if not found.
    public static func GetLevel(LevelType: LevelTypes, ForMode: ModeTypes) -> GameLevelDescription?
    {
        for SomeLevel in LevelTable
        {
            if SomeLevel.Difficulty == LevelType
            {
                if SomeLevel.ValidModes.contains(ForMode)
                {
                    return SomeLevel
                }
            }
        }
        return nil
    }
    
    /// Holds the level descriptions.
    private static var LevelTable = [GameLevelDescription]()
    
    /// Given a level type, return its title and brief description.
    ///
    /// - Parameter Of: The level type whose title and description will be returned.
    /// - Returns: Tuple of the title and description.
    public static func GetDescription(Of: LevelTypes) -> (String, String)
    {
        switch Of
        {
        case .Difficult:
            return ("Difficult", "Difficult level.")
            
        case .Easy:
            return ("Easy", "Easy level.")
            
        case .Impossible:
            return ("Impossible", "You won't last long...")
            
        case .Medium:
            return ("Medium", "Nice, challenging level.")
            
        case .ReallyDifficult:
            return ("Really Difficult", "For when you want the computer to win.")
            
        case .ReallyEasy:
            return("Really Easy", "If you don't want a challenge.")
            
        case .SomewhatHard:
            return("Somewhat Hard", "If you're feeling board...")
        }
    }
    
    /// Map between level difficulty enums and level titles.
    static let LevelNames =
        [
            LevelTypes.ReallyEasy: "Beginner",
            LevelTypes.Easy: "Easy",
            LevelTypes.Medium: "Medium",
            LevelTypes.SomewhatHard: "Medium Difficult",
            LevelTypes.Difficult: "Hard",
            LevelTypes.ReallyDifficult: "Very Difficult",
            LevelTypes.Impossible: "Extraordinarily Difficult"
    ]
    
    /// Return the title of the difficulty.
    ///
    /// - Parameter For: The level for which the name will be returned.
    /// - Returns: Level name.
    public static func GetLevelName(For: LevelTypes) -> String
    {
        if let Name = LevelNames[For]
        {
            return Name
        }
        return "Unknown"
    }
}
