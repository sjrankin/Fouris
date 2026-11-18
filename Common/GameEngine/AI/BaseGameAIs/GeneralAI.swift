//
//  GeneralAI.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/10/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// General AI for filling a game board relatively efficiently, assuming a solid floor (meaning no bottomless columns).
class GeneralAI
{
    /// Holds the motion queue. Populated when the AI is completed for a given piece.
    private static var _MotionQueue: Queue<Directions>? = nil
    /// Get or set the motion queue.
    public static var MotionQueue: Queue<Directions>
    {
        get
        {
            return _MotionQueue!
        }
        set
        {
            _MotionQueue = newValue
        }
    }
    
    /// Return (but do not modify) the contents of the motion queue.
    /// - Returns: The contents of the motion queue.
    static func DumpMotionQueue() -> [Directions]
    {
        var QDirs = [Directions]()
        let Count = MotionQueue.Count
        for Index in 0 ..< Count
        {
            QDirs.append(MotionQueue[Index]!)
        }
        return QDirs
    }
    
    /// Get the next motion in the motion queue.
    /// - Returns: The next motion in the motion queue. If the queue is empty, **.NoDirection** is returned.
    public static func GetNextMotion() -> Directions
    {
        if MotionQueue.IsEmpty
        {
            return Directions.NoDirection
        }
        return MotionQueue.Dequeue()!
    }
    
    /// Given a block of directions to find the best fit for the piece, generate a queue of motions to
    /// actually drive the block there.
    /// - Parameter Motions: Block of data that describes how to move the piece to the best location.
    static func GenerateMotionCommands(Motions: MotionCommandBlock2)
    {
        MotionQueue.Clear()
        for _ in 0 ..< Motions.InitialMoveDown
        {
            MotionQueue.Enqueue(.Down)
        }
        if Motions.AngleCount == 3
        {
            MotionQueue.Enqueue(.RotateLeft)
        }
        else
        {
            for _ in 0 ..< Motions.AngleCount
            {
                MotionQueue.Enqueue(.RotateRight)
            }
        }
        if Motions.XOffset > 0
        {
            for _ in 0 ..< Motions.XOffset
            {
                MotionQueue.Enqueue(.Left)
            }
        }
        if Motions.XOffset < 0
        {
            for _ in 0 ..< abs(Motions.XOffset)
            {
                MotionQueue.Enqueue(.Right)
            }
        }
        MotionQueue.Enqueue(.DropDown)
    }
    
    /// Find the right-most point in the set of passed points and return it.
    /// - Parameter Points: The list of points to examine to find the right-most point.
    /// - Returns: The right-most point of the set of passed points.
    static func FindRightMost(_ Points: [CGPoint]) -> CGPoint
    {
        var RightMost = -1
        var RightPoint: CGPoint!
        for Point in Points
        {
            if Int(Point.x) > RightMost
            {
                RightMost = Int(Point.x)
                RightPoint = Point
            }
        }
        return RightPoint
    }
    
    /// Find the left-most point in the set of passed points and return it.
    /// - Parameter Points: The list of points to examine to find the left-most point.
    /// - Returns: The left-most point of the set of passed points.
    static func FindLeftMost(_ Points: [CGPoint]) -> CGPoint
    {
        var LeftMost = 100000
        var LeftPoint: CGPoint!
        for Point in Points
        {
            if Int(Point.x) < LeftMost
            {
                LeftMost = Int(Point.x)
                LeftPoint = Point
            }
        }
        return LeftPoint
    }
    
    /// Virtually drop the set of passed points to the bottom-most valid location in the bucket.
    /// - Parameter Points: Points to drop to the bottom of the bucket.
    /// - Parameter GameBoard: The game board for the game.
    /// - Returns: Set of points adjusted such that they are at the bottom-most valid location in the bucket.
    static func VirtualDrop(Points: [CGPoint], GameBoard: Board) -> [CGPoint]
    {
        var Working: [CGPoint] = Points
        //print("Testing \(Points)")
        while true
        {
            for Point in Working
            {
                #if false
                var BlockingItem: PieceTypes = .BucketInterior
                #endif
                let LocationOK: Bool = GameBoard.MapIsEmpty(At: CGPoint(x: Point.x, y: Point.y))
                if !LocationOK
                {
                    //print("Found blocking item \(BlockingItem) at (\(Point))")
                    return Working
                }
            }
            for Index in 0 ..< Working.count
            {
                Working[Index] = CGPoint(x: Working[Index].x, y: Working[Index].y + 1.0)
            }
        }
    }
    
    /// Returns the bottom most points in each column of the set of points.
    /// - Parameter Points: List of points.
    /// - Returns: List of points, one for each column of data, the bottom-most (closest to the bucket bottom) for each column.
    public static func BottomMostPoints(_ Points: [CGPoint]) -> [CGPoint]
    {
        var PointDictionary = [Int: CGPoint]()
        for Point in Points
        {
            if let ThePoint = PointDictionary[Int(Point.x)]
            {
                if Int(Point.y) > Int(ThePoint.y)
                {
                    PointDictionary[Int(Point.x)] = ThePoint
                }
            }
            else
            {
                PointDictionary[Int(Point.x)] = Point
            }
        }
        var Points = [CGPoint]()
        for (_, Point) in PointDictionary
        {
            Points.append(Point)
        }
        Points.sort(by: {$0.x < $1.x})
        return Points
    }
    
    /// Return the shape of the top of the bucket (occupied spaces) in the specified horizontal range.
    /// - Parameters:
    ///   - From: A set of points whose horizontal coordinate will be used to find the proper columns to check for tops.
    ///   - GameBoard: The game board.
    /// - Returns: List of points that define the top, unoccupied points in the specified set of points.
    public static func BucketShape(From: [CGPoint], GameBoard: Board) -> [CGPoint]
    {
        var Points = [CGPoint]()
        for Point in From
        {
            let X = Int(Point.x)
            var AtBottom = true
            for Y in GameBoard.BucketTopInterior ... GameBoard.BucketBottomInterior
            {
                if GameBoard.Map!.IDMap!.IsOccupiedType(GameBoard.Map![Y,X]!)
                {
                    AtBottom = false
                    Points.append(CGPoint(x: X, y: Y))
                    break
                }
            }
            if AtBottom
            {
                Points.append(CGPoint(x: X, y: GameBoard.BucketBottomInterior))
            }
        }
        return Points
    }
    
    /// Calculate a piece score based on offset mapping - the shape of the bottom of the piece in its current location and orientation
    /// is compared to the top of the contents of the bucket in the same horizontal range.
    /// - Parameters:
    ///   - Points: The points of the piece, virtually dropped to the bottom of the bucket.
    ///   - ThePiece: The piece being scored.
    /// - Returns: Score based on how closely the bottom of the piece matches the top of the bucket.
    static func OffsetMappingScore(Points: [CGPoint], GameBoard: Board) -> Double
    {
        //let FullRows = GameBoard!.FullRowCount(WithPoints: Points)
        let BottomPoints = BottomMostPoints(Points)
        let TopPoints = BucketShape(From: BottomPoints, GameBoard: GameBoard)
        var OverTopOfBucket: Double = 0.0
        var CumulativeY: Double = 0.0
        for Point in Points
        {
            CumulativeY = CumulativeY + Double(Point.y)
            if Int(Point.y) < GameBoard.BucketTopInterior
            {
                OverTopOfBucket = OverTopOfBucket + 1.0
            }
        }
        var Cumulative: Double = 0.0
        var CumulativeDelta: Double = 0.0
        for Index in 0 ..< TopPoints.count
        {
            CumulativeDelta = CumulativeDelta + Double(TopPoints[Index].y - BottomPoints[Index].y)
            Cumulative = Cumulative + CumulativeDelta
        }
        #if false
        var ExactMatchBonus = CumulativeDelta == 0.0 ? 50.0 : 0.0
        if OverTopOfBucket > 0.0
        {
            ExactMatchBonus = 0.0
        }
        #endif
        let MeanY = CumulativeY / Double(Points.count)
        var MeanGap = Cumulative / Double(TopPoints.count)
        MeanGap = MeanY - MeanGap + (OverTopOfBucket * -100.0)
        //MeanGap = MeanGap + ExactMatchBonus
        //MeanGap = MeanGap + (Double(FullRows) * 30.0)
        return MeanGap
    }
    
    /// Creates a score value.
    /// - Parameter ForPoints: The piece (in location format) to create the score for.
    /// - Parameter CurrentPiece: The piece itself.
    /// - Parameter GameBoard: The board as currently populated.
    /// - Returns: Score for the piece in the board.
    static func MakeScore(ForPoints: [CGPoint], CurrentPiece: Piece? = nil, GameBoard: Board) -> Double
    {
        return OffsetMappingScore(Points: ForPoints, GameBoard: GameBoard)
    }
    
    /// Holds the piece that was tested.
    public static weak var FoundBestFitFor: Piece? = nil
    
    /// Holds the gap count before the best fit calculations.
    static var OriginalGapCount: Int = 0
    
    // MARK: - Placement search.
    
    /// State of a cell for placement evaluation.
    private enum PlacementCell
    {
        /// Nothing is in the cell.
        case Empty
        /// A frozen piece is in the cell.
        case Retired
        /// A barrier (bucket wall, center block, etc.) is in the cell.
        case Barrier
    }
    
    /// Weights used to score a candidate placement. These are the well-known "El-Tetris" weights. All of the measurements
    /// are made on the real board, so they work for every board layout.
    private enum PlacementWeights
    {
        static let LandingHeight = -4.500158825082766
        static let ErodedCells = 3.4181268101392694
        static let RowTransitions = -3.2178882868487753
        static let ColumnTransitions = -9.348695305445199
        static let Holes = -7.899265427351652
        static let Wells = -3.3855972247263626
        /// Penalty for each block of the piece that ends up above the opening of the bucket (which ends the game).
        static let OverTop = -1000.0
        /// Penalty for each block that ends up below the bottom of the bucket. Boards with bottomless columns have no floor
        /// under those columns, and a piece that falls through is out of bounds (game over).
        static let BelowBucket = -5000.0
    }
    
    /// Build the grid of cell states for the interior of the bucket.
    /// - Parameter GameBoard: The board to read.
    /// - Returns: Rows (top to bottom) of columns (left to right) of the bucket interior.
    private static func PlacementGrid(_ GameBoard: Board) -> [[PlacementCell]]
    {
        var Grid = [[PlacementCell]]()
        for Y in GameBoard.BucketTopInterior ... GameBoard.BucketBottomInterior
        {
            var Row = [PlacementCell]()
            for X in GameBoard.BucketInteriorLeft ... GameBoard.BucketInteriorRight
            {
                guard let ID = GameBoard.Map?[Y, X], let IDMap = GameBoard.Map?.IDMap else
                {
                    Row.append(.Barrier)
                    continue
                }
                if IDMap.IsEmptyType(ID)
                {
                    Row.append(.Empty)
                }
                else if IDMap.IsCollapsibleType(ID)
                {
                    Row.append(.Retired)
                }
                else
                {
                    Row.append(.Barrier)
                }
            }
            Grid.append(Row)
        }
        return Grid
    }
    
    /// Determines which columns of the bucket interior have a floor directly under the interior. Columns of rotating boards
    /// that have no floor are open at the bottom.
    /// - Parameter GameBoard: The board to read.
    /// - Returns: One flag per interior column. True if there is something solid under the column.
    private static func FloorUnderColumns(_ GameBoard: Board) -> [Bool]
    {
        var Result = [Bool]()
        let Below = GameBoard.BucketBottomInterior + 1
        for X in GameBoard.BucketInteriorLeft ... GameBoard.BucketInteriorRight
        {
            if Below >= GameBoard.Map!.Height
            {
                Result.append(true)
                continue
            }
            if let ID = GameBoard.Map?[Below, X], let IDMap = GameBoard.Map?.IDMap
            {
                Result.append(IDMap.IsOccupiedType(ID))
            }
            else
            {
                Result.append(true)
            }
        }
        return Result
    }
    
    /// Determines if a point is a valid, empty location for a piece block. Blocks may not leave the horizontal interior of the bucket.
    private static func CanOccupy(_ Point: CGPoint, GameBoard: Board) -> Bool
    {
        let X = Int(Point.x)
        if X < GameBoard.BucketInteriorLeft || X > GameBoard.BucketInteriorRight
        {
            return false
        }
        return GameBoard.MapIsEmpty(At: Point)
    }
    
    /// Determines if all points can be occupied.
    private static func CanOccupy(_ Points: [CGPoint], GameBoard: Board) -> Bool
    {
        for Point in Points
        {
            if !CanOccupy(Point, GameBoard: GameBoard)
            {
                return false
            }
        }
        return true
    }
    
    /// Score a piece that has come to rest at the passed points.
    /// - Parameter Points: Final (dropped) locations of the piece's blocks.
    /// - Parameter Grid: Interior cells of the bucket before the piece is added.
    /// - Parameter GameBoard: The board.
    /// - Returns: The score. Higher is better.
    private static func ScorePlacement(Points: [CGPoint], Grid: [[PlacementCell]], Floor: [Bool], GameBoard: Board) -> Double
    {
        var Working = Grid
        let Top = GameBoard.BucketTopInterior
        let Bottom = GameBoard.BucketBottomInterior
        let Left = GameBoard.BucketInteriorLeft
        let Width = GameBoard.BucketInteriorRight - Left + 1
        var OverTop = 0.0
        var BelowBucket = 0.0
        var HeightSum = 0.0
        var RowsWithPiece = [Int: Int]()
        for Point in Points
        {
            let Y = Int(Point.y)
            let X = Int(Point.x)
            HeightSum = HeightSum + Double(Bottom - Y)
            let Row = Y - Top
            let Column = X - Left
            if Row < 0
            {
                OverTop = OverTop + 1.0
                continue
            }
            if Row >= Working.count
            {
                BelowBucket = BelowBucket + 1.0
                continue
            }
            if Column < 0 || Column >= Width
            {
                continue
            }
            Working[Row][Column] = .Retired
            RowsWithPiece[Row, default: 0] += 1
        }
        let LandingHeight = HeightSum / Double(Points.count)
        
        //Rows that would be removed. Which rows may collapse depends on the type of board.
        var BlockTop = 0
        if let BoardClass = GameBoard.Map?.BoardClass, BoardClass != .Static
        {
            BlockTop = GameBoard.BucketInteriorHeight / 2
        }
        var ClearedRows = [Int]()
        for Row in 0 ..< Working.count
        {
            let Y = Row + Top
            if Y <= GameBoard.Map!.BucketTop || Y <= BlockTop
            {
                continue
            }
            if !Working[Row].contains(where: {$0 != .Retired})
            {
                ClearedRows.append(Row)
            }
        }
        var ErodedCells = 0
        for Row in ClearedRows
        {
            ErodedCells = ErodedCells + (RowsWithPiece[Row] ?? 0)
        }
        ErodedCells = ErodedCells * ClearedRows.count
        if !ClearedRows.isEmpty
        {
            Working = Working.enumerated().filter({!ClearedRows.contains($0.offset)}).map({$0.element})
            let EmptyRow = [PlacementCell](repeating: .Empty, count: Width)
            for _ in 0 ..< ClearedRows.count
            {
                Working.insert(EmptyRow, at: 0)
            }
        }
        
        let Height = Working.count
        func Filled(_ Row: Int, _ Column: Int) -> Bool
        {
            if Column < 0 || Column >= Width
            {
                return true
            }
            if Row < 0
            {
                return false
            }
            if Row >= Height
            {
                return Floor[Column]
            }
            return Working[Row][Column] != .Empty
        }
        
        var RowTransitions = 0
        for Row in 0 ..< Height
        {
            var Previous = true
            for Column in 0 ..< Width
            {
                let Current = Filled(Row, Column)
                if Current != Previous
                {
                    RowTransitions = RowTransitions + 1
                }
                Previous = Current
            }
            if !Previous
            {
                RowTransitions = RowTransitions + 1
            }
        }
        
        var ColumnTransitions = 0
        var Holes = 0
        var Wells = 0
        for Column in 0 ..< Width
        {
            var Previous = false
            var SawRetired = false
            var WellDepth = 0
            for Row in 0 ..< Height
            {
                let Current = Filled(Row, Column)
                if Current != Previous
                {
                    ColumnTransitions = ColumnTransitions + 1
                }
                Previous = Current
                if Working[Row][Column] == .Retired
                {
                    //Only frozen pieces create holes. Space under a barrier is part of the board's design.
                    SawRetired = true
                }
                else if Working[Row][Column] == .Empty && SawRetired
                {
                    Holes = Holes + 1
                }
                if !Current && Filled(Row, Column - 1) && Filled(Row, Column + 1)
                {
                    WellDepth = WellDepth + 1
                    Wells = Wells + WellDepth
                }
                else
                {
                    WellDepth = 0
                }
            }
            if !Previous && Floor[Column]
            {
                ColumnTransitions = ColumnTransitions + 1
            }
        }
        
        return PlacementWeights.LandingHeight * LandingHeight +
               PlacementWeights.ErodedCells * Double(ErodedCells) +
               PlacementWeights.RowTransitions * Double(RowTransitions) +
               PlacementWeights.ColumnTransitions * Double(ColumnTransitions) +
               PlacementWeights.Holes * Double(Holes) +
               PlacementWeights.Wells * Double(Wells) +
               PlacementWeights.OverTop * OverTop +
               PlacementWeights.BelowBucket * BelowBucket
    }
    
    /// A place a piece can be driven to and the motions that get it there.
    private struct ReachablePlacement
    {
        /// Horizontal distance from the starting column.
        let DX: Int
        /// Number of rows from the starting row to the final resting place.
        let RestDY: Int
        /// Motions (ending with a drop down) that put the piece there.
        let Path: [Directions]
    }
    
    /// A position of the piece relative to where it started.
    private struct PiecePosition: Hashable
    {
        let DX: Int
        let DY: Int
    }
    
    /// Finds every resting place the piece can be driven to, including places that need the piece to slide sideways partway
    /// down (under an overhang, around a barrier, onto a block in the middle of the board, etc.)
    /// - Note:
    ///   - Motions happen one per timer tick (`MotionInterval`) and gravity pulls the piece down one row every third of a second in
    ///     between, so the search follows time: each step is a move (left, right or down) followed by whatever gravity does
    ///     before the next move.
    ///   - A sideways move is only used if the space is free in the piece's row and the row below, which leaves room for the
    ///     timing being a tick or so off.
    ///   - Sideways moves are never planned for a piece that is already resting. It would freeze before the move.
    ///   - Reaching a place by the fewest motions is preferred.
    /// - Parameter Points: The piece's blocks (already rotated) at the starting position.
    /// - Parameter MotionsSoFar: Number of motions (the rotations) that happen before the search starts.
    /// - Parameter MotionInterval: Seconds between motions.
    /// - Parameter GameBoard: The board.
    /// - Returns: Places the piece can reach.
    private static func ReachablePlacements(Points: [CGPoint], MotionsSoFar: Int, MotionInterval: Double,
                                            GameBoard: Board) -> [ReachablePlacement]
    {
        let GravityInterval = 0.33
        let MaxMotions = 80
        func Free(_ Position: PiecePosition) -> Bool
        {
            let Moved = Points.map({CGPoint(x: $0.x + CGFloat(Position.DX), y: $0.y + CGFloat(Position.DY))})
            return CanOccupy(Moved, GameBoard: GameBoard)
        }
        func GravityTicks(Between First: Int, And Second: Int) -> Int
        {
            return Int((Double(Second) * MotionInterval / GravityInterval).rounded(.down)) -
                   Int((Double(First) * MotionInterval / GravityInterval).rounded(.down))
        }
        func Settle(_ Position: PiecePosition, From First: Int, To Second: Int) -> PiecePosition
        {
            var Current = Position
            for _ in 0 ..< GravityTicks(Between: First, And: Second)
            {
                let Lower = PiecePosition(DX: Current.DX, DY: Current.DY + 1)
                if !Free(Lower)
                {
                    break
                }
                Current = Lower
            }
            return Current
        }
        
        let Start = Settle(PiecePosition(DX: 0, DY: 0), From: 0, To: MotionsSoFar)
        if !Free(Start)
        {
            return []
        }
        var Parents = [PiecePosition: (Parent: PiecePosition?, Move: Directions)]()
        Parents[Start] = (nil, .NoDirection)
        var Depth = [PiecePosition: Int]()
        Depth[Start] = MotionsSoFar
        var Frontier = [Start]
        var Reached = [Start]
        var Motion = MotionsSoFar
        while !Frontier.isEmpty && Motion < MaxMotions
        {
            var Next = [PiecePosition]()
            for Position in Frontier
            {
                let Below = PiecePosition(DX: Position.DX, DY: Position.DY + 1)
                let CanFall = Free(Below)
                var Moves = [(Directions, PiecePosition)]()
                if CanFall
                {
                    Moves.append((.Down, Below))
                    for (Direction, Step) in [(Directions.Left, -1), (Directions.Right, 1)]
                    {
                        let Side = PiecePosition(DX: Position.DX + Step, DY: Position.DY)
                        let SideBelow = PiecePosition(DX: Position.DX + Step, DY: Position.DY + 1)
                        if Free(Side) && Free(SideBelow)
                        {
                            Moves.append((Direction, Side))
                        }
                    }
                }
                for (Move, After) in Moves
                {
                    let Settled = Settle(After, From: Motion, To: Motion + 1)
                    if Parents[Settled] != nil
                    {
                        continue
                    }
                    Parents[Settled] = (Position, Move)
                    Depth[Settled] = Motion + 1
                    Next.append(Settled)
                    Reached.append(Settled)
                }
            }
            Frontier = Next
            Motion = Motion + 1
        }
        
        //Every position that was reached can be turned into a resting place by dropping the piece from there.
        var Best = [PiecePosition: [Directions]]()
        for Position in Reached
        {
            var Rest = Position
            while Free(PiecePosition(DX: Rest.DX, DY: Rest.DY + 1))
            {
                Rest = PiecePosition(DX: Rest.DX, DY: Rest.DY + 1)
            }
            var Path = [Directions]()
            var Cursor: PiecePosition? = Position
            while let Current = Cursor, let Step = Parents[Current]
            {
                if Step.Move != .NoDirection
                {
                    Path.append(Step.Move)
                }
                Cursor = Step.Parent
            }
            Path.reverse()
            Path.append(.DropDown)
            if let Existing = Best[Rest], Existing.count <= Path.count
            {
                continue
            }
            Best[Rest] = Path
        }
        return Best.map({ReachablePlacement(DX: $0.key.DX, RestDY: $0.key.DY, Path: $0.value)})
    }
    
    /// Returns a best fit score.
    /// - Note: Not currently implemented.
    static func BestFit(_ GamePiece: Piece, CurrentScore: Int, InBoard: Board) -> Double
    {
        return 0.0
    }
    
    /// Find the best place for the passed game piece and populate `MotionQueue` with the motions that put it there.
    /// - Note:
    ///   - Every rotation and every horizontal position the piece can actually reach is tried against the real map, so this works
    ///     for any board layout (open buckets, buckets with center blocks or other barriers, rotating boards, etc.).
    ///   - Rotations are only used if the game would allow them (the rotated piece must fit where the piece is now).
    ///   - Horizontal travel is only used if the path is clear for the first two rows of the fall, because the piece keeps
    ///     falling while the motions are carried out.
    ///   - The piece is then dropped straight down (as the game does for a drop down motion).
    /// - Parameters:
    ///   - GamePiece: The piece to find the best fit for.
    ///   - CurrentScore: The current score of the game.
    ///   - GameBoard: The board.
    /// - Returns: The score of the best placement. Higher is better.
    public static func BestFit(_ GamePiece: Piece, CurrentScore: Int, GameBoard: Board) -> Double
    {
        MotionQueue = Queue()
        FoundBestFitFor = GamePiece
        guard let Origin = GamePiece.Locations.first(where: {$0.IsOrigin})?.Location else
        {
            MotionQueue.Enqueue(.DropDown)
            return 0.0
        }
        let Grid = PlacementGrid(GameBoard)
        let Floor = FloorUnderColumns(GameBoard)
        
        //Rotations the piece can be put into. The game rotates one quarter turn at a time and refuses any turn that would
        //overlap something.
        let Start = GamePiece.LocationsAsPoints()
        var Rotations = [(Count: Int, Points: [CGPoint])]()
        Rotations.append((0, Start))
        if !GamePiece.IsRotationallySymmetric
        {
            var Turned = Start
            var ChainOK = true
            for Count in 1 ... 3
            {
                Turned = Piece.RightRotate(Turned, AboutOrigin: Origin)
                if Count < 3
                {
                    ChainOK = ChainOK && CanOccupy(Turned, GameBoard: GameBoard)
                    if ChainOK
                    {
                        Rotations.append((Count, Turned))
                    }
                }
                else if CanOccupy(Turned, GameBoard: GameBoard)
                {
                    //Three right turns are done as a single left turn.
                    Rotations.append((3, Turned))
                }
            }
        }
        
        //The motions are carried out one per timer tick while gravity keeps pulling the piece down. Planning follows that
        //timing so paths that slide sideways in mid-fall stay valid.
        let FastAI = GameBoard.Game?.FastAI ?? false
        let MotionInterval = FastAI ? 0.01 : 0.1
        
        var BestScore = -Double.greatestFiniteMagnitude
        var BestPath = [Directions]()
        var BestEffort = Int.max
        for (Count, Points) in Rotations
        {
            var Prefix = [Directions]()
            if Count == 3
            {
                Prefix.append(.RotateLeft)
            }
            else
            {
                Prefix.append(contentsOf: [Directions](repeating: .RotateRight, count: Count))
            }
            let Plans = ReachablePlacements(Points: Points, MotionsSoFar: Prefix.count, MotionInterval: MotionInterval,
                                            GameBoard: GameBoard)
            for Plan in Plans
            {
                let Dropped = Points.map({CGPoint(x: $0.x + CGFloat(Plan.DX), y: $0.y + CGFloat(Plan.RestDY))})
                let Score = ScorePlacement(Points: Dropped, Grid: Grid, Floor: Floor, GameBoard: GameBoard)
                let Effort = Prefix.count + Plan.Path.count
                if Score > BestScore + 0.000001 || (abs(Score - BestScore) <= 0.000001 && Effort < BestEffort)
                {
                    BestScore = Score
                    BestPath = Prefix + Plan.Path
                    BestEffort = Effort
                }
            }
        }
        
        //Hand the winning path to the game. Every path ends with a drop down.
        for Motion in BestPath
        {
            MotionQueue.Enqueue(Motion)
        }
        if BestPath.isEmpty
        {
            MotionQueue.Enqueue(.DropDown)
        }
        return BestScore
    }
}
