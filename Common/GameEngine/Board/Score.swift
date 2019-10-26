//
//  Score.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Scoring rules for Tetris. Which rules are applied (see `ScoringMasks`) detemines the score. Certain actions increase
/// the score more than other actions.
///
/// - Each block in a frozen piece generates a certain score - more blocks the greater the score.
/// - Increasing the number of unreachable gaps will decrease the score. Descreasing the number of unreachable gaps
///   will increase the score.
/// - The overall map condition will affect the score, with columns with large top/bottom deltas decreasing the score.
/// - Clearing rows will increase the score, with rows higher up in the bucket having a larger positive score adjustment.
/// - Clearing rows of homogeneous piece blocks will significantly increase the score.
///
/// Set `Annotated` to true to see (in the debug console) how scores are generated.
class Score
{
    /// Initializer.
    /// - Parameters:
    ///   - WithID: ID for the score instance.
    ///   - BucketWidth: Width of the bucket.
    ///   - BucketHeight: Height of the bucket
    ///   - BucketBottom: The vertical coordinate of the bottom of the bucket.
    ///   - BucketTop: The vertical coordinate of the top of the bucket.
    init(WithID: UUID, BucketWidth: Int, BucketHeight: Int, BucketBottom: Int, BucketTop: Int)
    {
        _ID = WithID
        _Current = 0
        Width = BucketWidth
        Height = BucketHeight
        Bottom = BucketBottom
        Top = BucketTop
        ScoringMask = [.GapDelta, .MapCondition, .PieceBlockCount, .RowCollapse, .PieceBlockLocation]
    }
    
    /// Initializer.
    /// - Parameters:
    ///   - WithID: ID for the score instance.
    ///   - BucketWidth: Width of the bucket.
    ///   - BucketHeight: Height of the bucket
    ///   - BucketBottom: The vertical coordinate of the bottom of the bucket.
    ///   - BucketTop: The vertical coordinate of the top of the bucket.
    ///   - Mask: Determines how the score is calculated. See `ScoringMasks`.
    init(WithID: UUID, BucketWidth: Int, BucketHeight: Int, BucketBottom: Int, BucketTop: Int, Mask: [ScoringMasks])
    {
        _ID = WithID
        _Current = 0
        Width = BucketWidth
        Height = BucketHeight
        Bottom = BucketBottom
        Top = BucketTop
        ScoringMask = Mask
    }
    
    /// Initializer. Use passed instance to initialize this instance.
    /// - Parameter From: Other instance of a Score whose values will be used to initialize this instance.
    /// - Parameter WithID: ID for the new score instance.
    init(From: Score, WithID: UUID)
    {
        _ID = WithID
        _Current = From._Current
        Width = From.Width
        Height = From.Height
        Top = From.Top
        Bottom = From.Bottom
        Annotated = From.Annotated
        ScoringMask = From.GetScoringMasks()
    }
    
    /// Holds the ID of the scoring instance.
    private var _ID: UUID = UUID.Empty
    /// Get or set the ID of the score instance.
    public var ID: UUID
    {
        get
        {
            return _ID
        }
        set
        {
            _ID = newValue
        }
    }
    
    /// Holds the annotation flag.
    private var _Annotated: Bool = false
    /// Get or set the Annotated flag. If true, this class uses `print` statements to show the score as it accumulates.
    public var Annotated: Bool
    {
        get
        {
            return _Annotated
        }
        set
        {
            _Annotated = newValue
            _Annotated = false
        }
    }
    
    /// Copy relevant values from the passed instance.
    /// - Parameter From: Other instance of a Score from which values will be copied.
    public func CopySettings(From: Score)
    {
        _Current = From._Current
        Width = From.Width
        Height = From.Height
        Top = From.Top
        Bottom = From.Bottom
        Annotated = From.Annotated
        ScoringMask = From.GetScoringMasks()
    }
    
    /// Resets the score to 0.
    public func Reset()
    {
        _Current = 0
    }
    
    /// Update the bucket size.
    /// - Parameters:
    ///   - BucketWidth: New bucket width.
    ///   - BucketHeight: New bucket height.
    ///   - BucketBottom: The vertical coordinate of the bottom of the bucket.
    ///   - BucketTop: The vertical coordinate of the top of the bucket.
    public func BucketChanged(BucketWidth: Int, BucketHeight: Int, BucketBottom: Int, BucketTop: Int)
    {
        Width = BucketWidth
        Height = BucketHeight
        Bottom = BucketBottom
        Top = BucketTop
    }
    
    /// Holds the width of the bucket.
    private var Width: Int = 0
    
    /// Holds the height of the bucket.
    private var Height: Int = 0
    
    /// The bottom of the bucket.
    private var Bottom: Int = 0
    
    /// The top of the bucket.
    private var Top: Int = 0
    
    private var _PreviousScore: Int = 0
    public var PreviousScore: Int
    {
        get
        {
            return _PreviousScore
        }
    }
    
    /// Holds the current score. Before the new score is assigned, the old score is set to `_PreviousScore`.
    private var _Current: Int = 0
    {
        willSet
        {
            _PreviousScore = _Current
        }
    }
    /// Returns the current score. The returned score is affected by `AllowNegativeScore` so
    /// if `AllowNegativeScore` is true, all negative scores are converted to 0.
    public var Current: Int
    {
        get
        {
            if _Current < 0 && !AllowNegativeScore
            {
                if Annotated
                {
                    print("Actual score is \(_Current): Negative scores not allowed so returning 0.")
                }
                return 0
            }
            return _Current
        }
    }
    
    /// General purpose score adjuster function.
    /// - Parameter ScoreOffset: Value by which to adjust the score (whether positive or negative).
    public func AdjustScore(ScoreOffset: Int)
    {
        _Current = Current + ScoreOffset
        if Annotated
        {
            print("Score adjusted by \(ScoreOffset), Current = \(_Current)")
        }
    }
    
    /// Add the number of blocks to the score.
    /// - Parameter BlockCount: Number of block int he finalized piece.
    public func AddPieceBlockCount(BlockCount: Int)
    {
        
        if !ScoringMask.contains(.PieceBlockCount)
        {
            return
        }
        _Current = _Current + (BlockCount * ScoringAdders.Blocks.rawValue)
        if Annotated
        {
            print("Block count \(BlockCount * ScoringAdders.Blocks.rawValue) added, Current = \(_Current)")
        }
    }
    
    /// Accumulate the score based on how close to the bottom of the bucket each block in the piece is. Extra
    /// points for touching the bottom of the bucket. Also checks for out-of-bounds conditions (for the AI) and
    /// subtracts a value for that.
    /// - Parameter Points: One point for each block.
    public func ScoreLocations(_ Points: [CGPoint])
    {
        if ScoringMask.contains(.PieceOutOfBounds)
        {
            for Point in Points
            {
                if Int(Point.y) < Top
                {
                    _Current = _Current - ScoringAdders.PieceOutOfBounds.rawValue
                    if Annotated
                    {
                        print("ScoreLocations: Piece out of bounds adjustment: \(-ScoringAdders.PieceOutOfBounds.rawValue), Current = \(_Current)")
                    }
                    break
                }
            }
        }
        if !ScoringMask.contains(.PieceBlockLocation)
        {
            return
        }
        for Point in Points
        {
            let Delta = Bottom - Int(Point.y)
            if Delta == 0
            {
                //Bonus points - the block is on the bottom of the bucket!
                _Current = _Current + ScoringAdders.OnBottom.rawValue
                if Annotated
                {
                    print("ScoreLocations: On bottom bonus: \(ScoringAdders.OnBottom.rawValue), Current=\(_Current)")
                }
            }
            let AdjustedY = Bottom - Int(Point.y)
            let Percent = (Double(AdjustedY) / Double(Height)) * Double(ScoringAdders.LocationMultiplier.rawValue)
            _Current = _Current + Int(Percent)
            if Annotated
            {
                print("ScoreLocations: Location adjustment: \(Int(Percent)), Current=\(_Current)")
            }
        }
    }
    
    /// Add score for gap deltas. Reducing the delta adds more and increasing the delta decreases the score. It's
    /// entirely possible to end up with a negative score if you try hard enough.
    /// - Parameters:
    ///   - OldCount: Old gap count.
    ///   - NewCount: New gap count.
    public func GapDelta(OldCount: Int, NewCount: Int)
    {
        if ScoringMask.contains(.GapDelta)
        {
            let Delta = OldCount - NewCount
            let GapDeltaAdjustment = (Delta * ScoringAdders.GapDeltaMultiplier.rawValue)
            _Current = _Current + GapDeltaAdjustment
            if Annotated
            {
                if Delta == 0
                {
                    print("GapDelta is 0.")
                }
                else
                {
                    print("GapDelta(\(Delta)): Gap adjustment: \(GapDeltaAdjustment), Current=\(_Current)")
                }
            }
        }
        if ScoringMask.contains(.GapCount)
        {
            let ExistingGapPenalty = NewCount * ScoringAdders.GapAdjustment.rawValue
            _Current = _Current - ExistingGapPenalty
            if Annotated
            {
                if NewCount == 0
                {
                    print("No existing gaps.")
                }
                else
                {
                    print("ExistingGaps(\(NewCount)): Gap penalty: \(ExistingGapPenalty), Current=\(_Current)")
                }
            }
        }
    }
    
    /// Add scores for cleared rows. Clearing more than one row at a time increases the score.
    ///   - Cleared: List of rows that were cleared. Each entry in the list is the Y coordinate of the cleared row.
    ///   - HomogeneousRowCount: Number of rows that had homogeneous parts (eg, all from one type of piece). This adds a big
    ///                          bonus to the score.
    public func ScoreClearedRows(Cleared: [Int], HomogeneousRowCount: Int = 0)
    {
        if !ScoringMask.contains(.RowCollapse)
        {
            return
        }
        var Cumulative = 0
        var Base = 0
        var Index = 0
        for Y in Cleared
        {
            Base = (Index + 1) * ScoringAdders.RowDeletedMultiplier.rawValue
            let AdjustedY = Y - Height
            let Bonus = AdjustedY * ScoringAdders.RowDeletedLocationBonus.rawValue
            Cumulative = Cumulative + Base + Bonus
            _Current = _Current + Cumulative
            if Annotated
            {
                print("ScoreClearedRows(\(Y)): Base adjustment: \(Base) + Bonus adjustment: \(Bonus), Current = \(_Current)")
            }
            Index = Index + 1
        }
        if HomogeneousRowCount > 0
        {
            let HomogeneousBonus = HomogeneousRowCount * ScoringAdders.HomogeneousRowMultiplier.rawValue
            _Current = _Current + HomogeneousBonus
            if Annotated
            {
                print("ScoreClearedRows: Homogeneous bonus \(HomogeneousBonus), Current = \(_Current)")
            }
        }
    }
    
    /// Score for the overall map condition.
    /// - Note: Remember that the board's Y coordinates start at the bottom...
    /// - Parameter Map: The board map to examine.
    public func ScoreMapCondition(Map: MapType)
    {
        if !ScoringMask.contains(.MapCondition)
        {
            return
        }
        var ColumnDeltas = [Int]()
        for X in 0 ..< Width
        {
            var TopMost = 10000
            var BottomMost = -1
            for Y in 0 ..< Height
            {
                let ItemID = Map[Y,X]
                if Map.IDMap!.IsOccupiedType(ItemID!)
                {
                    if Y < TopMost
                    {
                        TopMost = Y
                    }
                    if Y > BottomMost
                    {
                        BottomMost = Y
                    }
                }
                ColumnDeltas.append(abs(BottomMost - TopMost))
            }
        }
        var ColumnDeltaSum = 0
        for Delta in ColumnDeltas
        {
            ColumnDeltaSum = ColumnDeltaSum + Delta
        }
        let MeanDelta = Double(ColumnDeltaSum) / Double(ColumnDeltas.count)
        let Adjustment = -Int(MeanDelta * Double(ScoringAdders.MapMeanColumnDelta.rawValue))
        _Current = _Current + Adjustment
        if Annotated
        {
            print("ScoreMapCondition: Column delta adjustment: \(Adjustment), Current = \(_Current)")
        }
    }
    
    /// Set the masks that tell the class how to score the game.
    /// - Parameter Masks: List of "masks" that enable various types of scoring.
    public func SetScoringMasks(Masks: [ScoringMasks])
    {
        ScoringMask = Masks
    }
    
    /// Returns the current scoring masks.
    /// - Returns: List of current scoring masks.
    public func GetScoringMasks() -> [ScoringMasks]
    {
        return ScoringMask
    }
    
    /// Holds the scoring mask.
    private var ScoringMask = [ScoringMasks]()
    
    /// Holds the allow negative score flag.
    private var _AllowNegativeScore: Bool = true
    /// Get or set the flag that enables or disables negative scores. If false,
    /// all negative scores are converted to 0.
    public var AllowNegativeScore: Bool
    {
        get
        {
            return _AllowNegativeScore
        }
        set
        {
            _AllowNegativeScore = newValue
        }
    }
    
    /// Return a description of the passed scoring mask.
    /// - Parameter For: The scoring mask whose description will be returned.
    /// - Returns: Description of the passed scoring mask.
    public static func MaskDescription(For: ScoringMasks) -> String
    {
        switch For
        {
        case .RowCollapse:
            return "Score for full rows."
            
        case .MapCondition:
            return "Score for general map condition."
            
        case .GapDelta:
            return "Score for unreachable gap delta."
            
        case .GapCount:
            return "Score for current number of gaps."
            
        case .PieceBlockCount:
            return "Score for number of blocks in a piece."
            
        case .PieceBlockLocation:
            return "Score for how close to the bottom the piece is."
            
        case .PieceOutOfBounds:
            return "Score for piece stopped out of bounds. For AI use only."
        }
    }
}

/// Determines how to calculate scores.
///
/// - **RowCollapse**: Accumulate the score based on how many hows collapsed.
/// - **MapCondition**: Accumulate the score based on overall map condition.
/// - **GapDelta**: Accumulate the score based on the number of gaps that increased/deceased.
/// - **PieceBlockCount**: Accumulate the score based on the number of blocks in the piece.
/// - **PieceBlockLocation**: Accumulate the score based on how close to the bottom the pieces are.
/// - **PieceOutOfBounds**: Accumulate (in a negative way) the score based on whether the piece stops
///                         out of bounds. Used by the AI and should not be used by other code.
/// - **GapCount**: Accumulate penalties for the number of gaps in the map. Used by the AI.
enum ScoringMasks: Int, CaseIterable
{
    case RowCollapse = 0
    case MapCondition = 1
    case GapDelta = 2
    case PieceBlockCount = 3
    case PieceBlockLocation = 4
    case PieceOutOfBounds = 5
    case GapCount = 6
}

/// Constants for adding scores. Adjust these values to adjust how the AI works.
///
/// - **Blocks**: Number of points per block frozen.
/// - **OnBottom**: Number of points if the block freezes on the bottom of the bucket.
/// - **LocationMultiplier**: Value to multiply block Y values by to take into account how close to the bottom of
///                       the bucket each block is.
/// - **GapDeltaMultiplier**: Value to multiply by the gap delta to enforce the idea that gaps are bad.
/// - **RowDeletedMultiplier**: Number of points each deleted row is worth multiplied by its Y location.
/// - **RowDeletedLocationBonus**: Bonus for location of deleted rows (similar to `RowDeletedMultiplier`).
/// - **HomogeneousRowMultiplier**: Number of points to add if the deleted row contains only blocks from the same
///                             type of piece.
/// - **MapMeanColumnDelta**: Multiplier for each column's delta between the highest and lowest blocks.
/// - **PieceOutOfBounds**: Adjustment for when the piece freezes out of bounds.
enum ScoringAdders: Int, CaseIterable
{
    case Blocks = 1
    case OnBottom = 100
    case LocationMultiplier = 4
    case GapDeltaMultiplier = 10
    case GapAdjustment = 5
    case RowDeletedMultiplier = 1000
    case RowDeletedLocationBonus = 20
    case HomogeneousRowMultiplier = 5000
    case MapMeanColumnDelta = 2
    case PieceOutOfBounds = 3000
}
