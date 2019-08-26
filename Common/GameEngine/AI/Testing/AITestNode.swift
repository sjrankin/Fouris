//
//  File.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// One node for AI test data. Each node holds data for one full test run under AI.
class AITestNode
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Method: The AI scoring method.
    ///   - Duration: Duration of the game in seconds.
    ///   - Score: Score of the game.
    ///   - Pieces: Number of pieces the game used.
    ///   - BucketSize: The size of the game bucket.
    ///   - Unreachable: The number of unreachable gaps at the end of the game.
    ///   - Reachable: The number of reachable gaps at the end of the game.
    init(_ Method: AIScoringMethods, Duration: Double, Score: Double, Pieces: Int, BucketSize: CGSize,
         Unreachable: Int, Reachable: Int)
    {
        ScoringType = Method
        RunDuration = Duration
        RunScore = Score
        RunPieces = Pieces
        self.BucketSize = BucketSize
        UnreachableGapCount = Unreachable
        ReachableGapCount = Reachable
    }
    
    /// Holds the scoring method.
    private var _ScoringType: AIScoringMethods = .MeanLocation
    /// Get or set the scoring method.
    public var ScoringType: AIScoringMethods
    {
        get
        {
            return _ScoringType
        }
        set
        {
            _ScoringType = newValue
        }
    }
    
    /// Holds the duration of the game.
    private var _RunDuration: Double = 0.0
    /// Get or set the duration of the game (in seconds).
    public var RunDuration: Double
    {
        get
        {
            return _RunDuration
        }
        set
        {
            _RunDuration = newValue
        }
    }
    
    /// Holds the score of the game.
    private var _RunScore: Double = 0.0
    /// Get or set the score of the game.
    public var RunScore: Double
    {
        get
        {
            return _RunScore
        }
        set
        {
            _RunScore = newValue
        }
    }
    
    /// Holds the number of pieces used in the game.
    private var _RunPieces: Int = 0
    /// Get or set the number of pieces used in the game.
    public var RunPieces: Int
    {
        get
        {
            return _RunPieces
        }
        set
        {
            _RunPieces = newValue
        }
    }
    
    /// Holds the size of the bucket.
    private var _BucketSize: CGSize = CGSize.zero
    /// Get or set the size of the bucket used in the game.
    public var BucketSize: CGSize
    {
        get
        {
            return _BucketSize
        }
        set
        {
            _BucketSize = newValue
        }
    }
    
    /// Holds the number of unreachable gaps at the end of the game.
    private var _UnreachableGapCount: Int = 0
    /// Get or set the number of unreachable gaps at the end of the game.
    public var UnreachableGapCount: Int
    {
        get
        {
            return _UnreachableGapCount
        }
        set
        {
            _UnreachableGapCount = newValue
        }
    }
    
    /// Holds the number of reachable gaps at the end of the game.
    private var _ReachableGapCount: Int = 0
    /// Get or set the number of reachable gaps at the end of the game.
    public var ReachableGapCount: Int
    {
        get
        {
            return _ReachableGapCount
        }
        set
        {
            _ReachableGapCount = newValue
        }
    }
    
    /// Get the percent of unreachable gaps at the end of the game.
    public var UnreachablePercent: Double
    {
        get
        {
            let Width: Int = Int(BucketSize.width)
            let Height: Int = Int(BucketSize.height)
            let Area = Width * Height
            if Area == 0
            {
                return 0.0
            }
            return Double(UnreachableGapCount) / Double(Area)
        }
    }
    
    /// Get the percent of reachable gaps at the end of the game.
    public var ReachablePercent: Double
    {
        get
        {
            let Width: Int = Int(BucketSize.width)
            let Height: Int = Int(BucketSize.height)
            let Area = Width * Height
            if Area == 0
            {
                return 0.0
            }
            return Double(ReachableGapCount) / Double(Area)
        }
    }
}
