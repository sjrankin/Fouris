//
//  Piece.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Class that encapsulates a dropping piece. The shape of the piece is defined by the PieceFactory setting
/// the component array.
/// - Note: It is critical that all references to timers, whether setting, reading, or invalidating, are enclosed
///         in `OperationQueue.main.addOperation` or `DispatchQueue.main.async` blocks. This is to ensure all timers
///         are used on the same thread.
class Piece: CustomStringConvertible
{
    /// Reference to the board where the piece will be played.
    weak var _GameBoard: Board? = nil
    {
        didSet
        {
            #if false
            if _GameBoard == nil
            {
                print("GameBoard set to nil in piece \(ID)")
            }
            #endif
        }
    }
    /// Get or set the game board where the piece will be/is being played.
    weak var GameBoard: Board?
    {
        get
        {
            return _GameBoard
        }
        set
        {
            _GameBoard = newValue
        }
    }
    
    /// If true, the piece is not intended to be used in a game.
    public var IsEphemeral: Bool = true
    
    /// Initializer.
    /// - Parameters:
    ///   - TheType: The piece type. Almost always .GamePiece
    ///   - PieceID: The ID of the piece.
    ///   - TheBoard: The board where the piece will be played.
    ///   - RotationallySymmetric: Flag that says the piece is rotationally symmetric.
    init(_ TheType: PieceTypes, PieceID: UUID, _ TheBoard: Board, _ RotationallySymmetric: Bool = false)
    {
        IsEphemeral = false
        GameBoard = TheBoard
        BoardGameCount = GameBoard!.GameCount
        _PieceType = TheType
        _ID = PieceID
        Locations = Array(repeating: Block(), count: 4)
        Components = [Block]()
        GameBoardID = (GameBoard?.ID)!
    }
    
    /// Initializer.
    /// - Note:
    ///    - This initializer is intended for use *only* for assisting in the creation of generic views of pieces.
    ///    - **Do not use this for normal game piece creation.**
    ///    - It is intended that the piece instance created with this initializer be disposed of almost immediately after
    ///      creation.
    /// - Parameter PieceTypes: The piece type.
    init(_ TheType: PieceTypes)
    {
        IsEphemeral = true
        //_BaseGameType = .Standard
        _PieceType = TheType
        Locations = Array(repeating: Block(), count: 4)
        Components = [Block]()
    }
    
    /// Returns the bottom-most (eg, closest to the bottom of the bucket) point for each column the piece occupies.
    ///
    /// - Returns: List of points, one for each column of the piece, of the bottom-most point in the piece.
    public func BottomMostHorizontalPoints() -> [CGPoint]
    {
        var Bottom = [CGPoint]()
        var BPoints = [Int: Int]()
        for SomeBlock in Locations
        {
            if let SomeY = BPoints[SomeBlock.X]
            {
                if SomeBlock.Y > SomeY
                {
                    BPoints[SomeBlock.X] = SomeBlock.Y
                }
            }
            else
            {
                BPoints[SomeBlock.X] = SomeBlock.Y
            }
        }
        for (X, Y) in BPoints
        {
            Bottom.append(CGPoint(x: X, y: Y))
        }
        return Bottom
    }
    
    /// Returns a list of offsets of the bottom-most block in the piece, relative to the piece(s) closest to the bottom
    /// of the bucket.
    ///
    /// - Returns: List of height offsets along the bottom of the piece.
    public func BottomOffsets() -> [Int]
    {
        var Offsets = [Int]()
        let Bottoms = BottomMostHorizontalPoints()
        var Greatest = -1000
        for Point in Bottoms
        {
            if Int(Point.y) > Greatest
            {
                Greatest = Int(Point.y)
            }
        }
        for Point in Bottoms
        {
            let Offset = Int(Point.y) - Greatest
            Offsets.append(Offset)
        }
        return Offsets
    }
    
    /// Return the bottom-most absolute points for each column used by the piece in its current location and orientation.
    ///
    /// - Note: Points are returned sorted in column order.
    ///
    /// - Returns: List of bottom most points for each used column in the piece in its current location and orientation.
    public func BottomMostPoints() -> [CGPoint]
    {
        var PointDictionary = [Int: CGPoint]()
        for SomeBlock in Locations
        {
            if let ThePoint = PointDictionary[SomeBlock.X]
            {
                if SomeBlock.Y > Int(ThePoint.y)
                {
                    PointDictionary[SomeBlock.X] = CGPoint(x: SomeBlock.X, y: SomeBlock.Y)
                }
            }
            else
            {
                PointDictionary[SomeBlock.X] = CGPoint(x: SomeBlock.X, y: SomeBlock.Y)
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
    
    /// Return the bottom-most absolute point for each column in the set of passed points.
    ///
    /// - Note: Points are returned sorted in column order.
    ///
    /// - Parameter Points: List of points to find the bottom-most of each column for.
    /// - Returns: List of bottom-most points in the set of passed points.
    public func BottomMostPoints(_ Points: [CGPoint]) -> [CGPoint]
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
    
    /// Holds the wide orientation count.
    private var _WideOrientationCount: Int = 0
    /// Get or set the wide orientation count. This is the number of times the piece must be
    /// rotated to the right such that the widest aspect of the piece is horizontal.
    public var WideOrientationCount: Int
    {
        get
        {
            return _WideOrientationCount
        }
        set{
            _WideOrientationCount = newValue
        }
    }
    
    /// Holds the thin orientation count.
    private var _ThinOrientationCount: Int = 0
    /// Get or set the thin orientation count. This is the number of times the piece must be
    /// rotated to the right such that the thinnest aspect of the piece is vertical.
    public var ThinOrientationCount: Int
    {
        get
        {
            return _ThinOrientationCount
        }
        set
        {
            _ThinOrientationCount = newValue
        }
    }
    
    /// Holds the play mode.
    private var _PlayMode: PlayModes = .Normal
    /// Get or set the play mode.
    public var PlayMode: PlayModes
    {
        get
        {
            return _PlayMode
        }
        set
        {
            _PlayMode = newValue
        }
    }
    
    /// Return the width of the piece in its current orientation.
    public var Width: Int
    {
        get
        {
            var LeastX: Int = 10000
            var GreatestX: Int = -10000
            for SomeBlock in Locations
            {
                if SomeBlock.X < LeastX
                {
                    LeastX = SomeBlock.X
                }
                if SomeBlock.X > GreatestX
                {
                    GreatestX = SomeBlock.X
                }
            }
            return GreatestX - LeastX + 1
        }
    }
    
    /// Return the width of the component (eg, unchanging, original definition) parts of the piece.
    public var ComponentWidth: Int
    {
        get
        {
            var LeastX: Int = 10000
            var GreatestX: Int = -10000
            for SomeBlock in Components
            {
                if SomeBlock.X < LeastX
                {
                    LeastX = SomeBlock.X
                }
                if SomeBlock.X > GreatestX
                {
                    GreatestX = SomeBlock.X
                }
            }
            return GreatestX - LeastX + 1
        }
    }
    
    /// Return the height of the piece in its current orientation.
    public var Height: Int
    {
        get
        {
            var LeastY: Int = 10000
            var GreatestY: Int = -10000
            for SomeBlock in Locations
            {
                if SomeBlock.Y < LeastY
                {
                    LeastY = SomeBlock.Y
                }
                if SomeBlock.Y > GreatestY
                {
                    GreatestY = SomeBlock.Y
                }
            }
            return GreatestY - LeastY + 1
        }
    }
    
    /// Return the height of the component (eg, unchanging, original definition) parts of the piece.
    public var ComponentHeight: Int
    {
        get
        {
            var LeastY: Int = 10000
            var GreatestY: Int = -10000
            for SomeBlock in Components
            {
                if SomeBlock.Y < LeastY
                {
                    LeastY = SomeBlock.Y
                }
                if SomeBlock.Y > GreatestY
                {
                    GreatestY = SomeBlock.Y
                }
            }
            return GreatestY - LeastY + 1
        }
    }
    
    /// Returns the largest dimension of the piece.
    public var MaxDimension: Int
    {
        get
        {
            return max(Height, Width)
        }
    }
    
    /// Returns the largest component dimension (original configuration) of the piece.
    public var MaxComponentDimension: Int
    {
        get
        {
            return max(ComponentWidth, ComponentHeight)
        }
    }
    
    /// Return the current left-most point in the piece (in the current location and orientation). If more than one point
    /// is the farthest left, the first point found is returned.
    public var LeftMost: CGPoint
    {
        get
        {
            var LeastX = 10000
            var Leftish: CGPoint = CGPoint.zero
            for SomeBlock in Locations
            {
                if SomeBlock.X < LeastX
                {
                    LeastX = SomeBlock.X
                    Leftish = CGPoint(x: SomeBlock.X, y: SomeBlock.Y)
                }
            }
            return Leftish
        }
    }
    
    /// Return the current right-most point in the piece (in the current location and orientation). If more than one point
    /// is the farthest right, the first point found is returned.
    public var RightMost: CGPoint
    {
        get
        {
            var GreatestX = -10000
            var Rightish: CGPoint = CGPoint.zero
            for SomeBlock in Locations
            {
                if SomeBlock.X > GreatestX
                {
                    GreatestX = SomeBlock.X
                    Rightish = CGPoint(x: SomeBlock.X, y: SomeBlock.Y)
                }
            }
            return Rightish
        }
    }
    
    /// Return the current top-most point in the piece (in the current location and orientation). If more than one point
    /// is the highest up, the first point found is returned. Top-most is defined as being closest to the top of the
    /// bucket.
    public var TopMost: CGPoint
    {
        get
        {
            var LeastY = 10000
            var Toppish: CGPoint = CGPoint.zero
            for SomeBlock in Locations
            {
                if SomeBlock.Y < LeastY
                {
                    LeastY = SomeBlock.Y
                    Toppish = CGPoint(x: SomeBlock.X, y: SomeBlock.Y)
                }
            }
            return Toppish
        }
    }
    
    /// Return the current bottom-most point in the piece (in the current location and orientation). If more than one point
    /// is the farthest down, the first point found is returned. Top-most is defined as being closest to the bottom of the
    /// bucket.
    public var BottomMost: CGPoint
    {
        get
        {
            var GreatestY = -10000
            var Bottomish: CGPoint = CGPoint.zero
            for SomeBlock in Locations
            {
                if SomeBlock.Y > GreatestY
                {
                    GreatestY = SomeBlock.Y
                    Bottomish = CGPoint(x: SomeBlock.X, y: SomeBlock.Y)
                }
            }
            return Bottomish
        }
    }
    
    /// Returns the bottom-most point of each column of the piece in its current orientation.
    /// - Returns: List of points, one point for each column the piece occupies, with the `y` value the bottom-most value
    ///            (eg, closest to the bottom of the bucket).
    public func Bottom() -> [CGPoint]
    {
        var Results = [CGPoint]()
        var PointDict = [Int: [Int]]()
        for Block in Locations
        {
            if PointDict[Block.X] == nil
            {
                PointDict[Block.X] = [Int]()
            }
            PointDict[Block.X]!.append(Block.Y)
        }
        for (X, YList) in PointDict
        {
            Results.append(CGPoint(x: X, y: YList.max()!))
        }
        return Results
    }
    
    /// Determines if the piece (in its current location and orientation) has a block in the specified column.
    ///
    /// - Note: This function searches the current locations so the value the caller passes must be an absolute
    ///         coordinate, not an offset.
    ///
    /// - Parameter X: The column to check.
    /// - Returns: True if the piece has a block somewhere in the specified column, false if not.
    func HasBlockInColumn(_ X: Int) -> Bool
    {
        for SomeBlock in Locations
        {
            if SomeBlock.X == X
            {
                return true
            }
        }
        return false
    }
    
    /// Determines if the piece (in its current location and orientation) has a block in the specified row.
    ///
    /// - Note: This function searches the current locations so the value the caller passes must be an absolute
    ///         coordinate, not an offset.
    ///
    /// - Parameter Y: The row to check.
    /// - Returns: True if the piece has a block somewhere in the specified row, false if not.
    func HasBlockInRow(_ Y: Int) -> Bool
    {
        for SomeBlock in Locations
        {
            if SomeBlock.Y == Y
            {
                return true
            }
        }
        return false
    }
    
    /// Return all points at the specified horizontal coordinate.
    ///
    /// - Parameter X: The horizontal coordinate whose points will be returned.
    /// - Returns: List of points at the specified horizontal coordinate.
    private func GetAllPointsAt(X: Int) -> [CGPoint]
    {
        var Points = [CGPoint]()
        for SomeBlock in Locations
        {
            if SomeBlock.X == X
            {
                Points.append(CGPoint(x: SomeBlock.X, y: SomeBlock.Y))
            }
        }
        return Points
    }
    
    /// Return a list of points in the piece, one point for each unique horizontal coordinate. If there is more
    /// than one point for a unique horizontal coordinate, the point that is closest to the bottom of the bucket
    /// is returned.
    ///
    /// - Note: The list of pieces returned are current as of the call to this function. The points returned
    ///         are dependent on the current location and orientation of the piece.
    ///
    /// - Returns: List of points, one each for each unique horizontal location in the set of points for the
    ///            piece.
    public func GetHorizontalPointsClosestToBucketBottom() -> [CGPoint]
    {
        var Points = [CGPoint]()
        let UniqueHorizontalLocations = GetUniqueHorizontalLocations()
        for X in UniqueHorizontalLocations
        {
            let AllAtX = GetAllPointsAt(X: X)
            if AllAtX.count == 0
            {
                //No points - probably the wrong X was used.
                continue
            }
            if AllAtX.count == 1
            {
                Points.append(AllAtX[0])
            }
            else
            {
                var BestPoint = AllAtX[0]
                for SomeX in AllAtX
                {
                    if SomeX.y > BestPoint.y
                    {
                        BestPoint = SomeX
                    }
                }
                Points.append(BestPoint)
            }
        }
        return Points
    }
    
    /// Return a set of unique horizontal locations occupied by the piece.
    ///
    /// - Returns: Set of horizontal coordinates for the piece in its current orientation and location.
    public func GetUniqueHorizontalLocations() -> Set<Int>
    {
        var Unique = Set<Int>()
        for SomeBlock in Locations
        {
            Unique.insert(SomeBlock.X)
        }
        return Unique
    }
    
    /// Holds the rotationally symmetry flag.
    private var _IsRotationallySymmetric: Bool = false
    /// Get or set the rotationally symmetry flag. Setting this value takes no action - this is merely a descriptor.
    public var IsRotationallySymmetric: Bool
    {
        get
        {
            return _IsRotationallySymmetric
        }
        set
        {
            _IsRotationallySymmetric = newValue
        }
    }
    
    /// The ID of the board to which this piece is attached.
    var GameBoardID: UUID!
    
    /// The board's game count.
    var BoardGameCount: Int = 0
    
    /// Deinitialize the piece. If **Terminate** has not been called prior to deleting/deallocating the instance and this is *not* an
    /// ephermal piece, a fatal error will be generated.
    deinit
    {
        if !WasTerminated && !IsEphemeral
        {
            fatalError("Piece: deinit attempted but Terminate not called ahead of time.")
        }
        //print("Piece \(ID.uuidString) deleted.")
    }
    
    /// Terminates timers and the like to allow for a clean deletion.
    ///
    /// - Note: If this function is not called prior to deleting/deallocating instances of this class, the instance will continue
    ///         being active because there are items inside the instance that need to be shutdown, such as a reference to the game
    ///         board. Additionally, timers are invalidated and deleted here as well. Calling this function is so important that
    ///         if it is not called, deinit will generated a fatal error.
    func Terminate()
    {
        //print("Terminating piece \(ID.uuidString)")
        OperationQueue.main.addOperation
            {
                //Terminate all timers first to make sure they do not refer to something that does not exist due to being
                //deleted in this block.
                if self.GravitationalTimer != nil
                {
                    self.GravitationalTimer?.invalidate()
                    self.GravitationalTimer = nil
                }
                if self.FreezeTimer != nil
                {
                    self.FreezeTimer?.invalidate()
                    self.FreezeTimer = nil
                }
                if self.RandomMotionTimer != nil
                {
                    self.RandomMotionTimer?.invalidate()
                    self.RandomMotionTimer = nil
                }
                if self.RandomRotationTimer != nil
                {
                    self.RandomRotationTimer?.invalidate()
                    self.RandomRotationTimer = nil
                }
                
                //print("Setting GameBoard to nil in Piece.Terminate")
                self.GameBoard = nil
                
                self.Components.removeAll()
                self.Locations.removeAll()
                self.WasTerminated = true
        }
    }
    
    /// Flag to tell the initializer that `Terminate` was called.
    private var WasTerminated: Bool = false
    
    /// Flag set by the PieceFactory when the instance is dequeued for use.
    public var Activated: Bool = false
    
    /// Holds the identifier of the original shape of the item.
    private var _Shape: PieceShapes = PieceShapes.Bar
    /// Get or set the shape of the piece. Setting this property does **not** change the shape.
    public var Shape: PieceShapes
    {
        get
        {
            return _Shape
        }
        set
        {
            _Shape = newValue
        }
    }
    
    /// Holds the ID of the shape.
    private var _ShapeID: UUID = UUID.Empty
    /// Get or set the shape's ID.
    public var ShapeID: UUID
    {
        get
        {
            return _ShapeID
        }
        set
        {
            _ShapeID = newValue
        }
    }
    
    /// Holds the ID of the piece.
    private var _ID: UUID!
    /// Get the piece's ID.
    public var ID: UUID
    {
        get
        {
            return _ID
        }
    }
    
    /// List of curren locations for each block in the piece. Not necessarily contiguous or with positive
    /// coordinate values.
    public var Locations: [Block]!
    
    /// List of initial components. Set by the PieceFactory class. This defines the initial shape of the piece.
    public var Components: [Block]!
    
    /// Return the locations of each block in the piece as a list of points, in block order.
    ///
    /// - Returns: List of points, in block order.
    func LocationsAsPoints() -> [CGPoint]
    {
        var Result = [CGPoint]()
        for Block in Locations
        {
            Result.append(Block.Location)
        }
        return Result
    }
    
    /// Returns the current set of locations.
    ///
    /// - Returns: List of blocks that define the piece.
    func CurrentLocations() -> [Block]
    {
        return Locations
    }
    
    /// Apply the passed set of points to the blocks of the piece.
    ///
    /// - Parameter With: New points for each block. Assumed to be a set of rotated coordinates. Also assumed
    ///                   to be in the same order as the Blocks list in `Locations`.
    func DoRotate(With: [CGPoint])
    {
        for Index in 0 ..< Locations.count
        {
            Locations[Index].Location = With[Index]
        }
        GameBoard?.NewLocation(ID: ID)
    }
    
    /// Determines if the piece (in its current shape and location defined by `Locations`) can be rotated
    /// left (counter-clockwise). If the piece **can** be rotated, it **will** be rotated here.
    /// - Returns: True if the piece can be rotated counter-clockwise, false if not.
    @discardableResult func CanRotateLeft() -> Bool
    {
        let RotatedPoints = Piece.LeftRotate(Locations)
        var Blocked = false
        for Point in RotatedPoints!
        {
            #if false
            var ItemPiece: PieceTypes = .Visible
            #endif
            if (GameBoard?.MapIsEmpty(At: Point))!
            {
                continue
            }
            Blocked = true
            break
        }
        if Blocked
        {
            GameBoard?.RotationFailure(ID: ID, Direction: .Left)
            return false
        }
        DoRotate(With: RotatedPoints!)
        GameBoard?.RotationSuccess(ID: ID, Direction: .Left)
        return true
    }
    
    /// Determines if the piece (in its current shape and location defined by `Locations`) can be rotated
    /// right (clockwise). If the piece **can** be rotated, it **will** be rotated here.
    /// - Returns: True if the piece can be rotated clockwise, false if not.
    @discardableResult func CanRotateRight() -> Bool
    {
        let RotatedPoints = Piece.RightRotate(Locations)
        var Blocked = false
        for Point in RotatedPoints!
        {
            #if false
            var ItemPiece: PieceTypes = .Visible
            #endif
            if (GameBoard?.MapIsEmpty(At: Point))!
            {
                continue
            }
            Blocked = true
            break
        }
        if Blocked
        {
            GameBoard?.RotationFailure(ID: ID, Direction: .Right)
            return false
        }
        DoRotate(With: RotatedPoints!)
        GameBoard?.RotationSuccess(ID: ID, Direction: .Right)
        return true
    }
    
    /// Sets the initial location of each block in the piece. The passed coordinates are applied
    /// to each block's location in order.
    /// - Parameters:
    ///   - X: Starting horizontal position.
    ///   - Y: Starting vertical position.
    func SetStartLocation(X: Int, Y: Int)
    {
        //print("Piece=\(Shape)")
        var Index = 0
        var MinY = Int.max
        for Component in Components
        {
            if Component.Y < MinY
            {
                MinY = Component.Y
            }
        }
        MinY = abs(MinY) + Y
        for SomeBlock in Components
        {
            Locations[Index] = Block(CopyFrom: SomeBlock)
            #if true
            var iX = Locations[Index].X
            iX = iX + X
            var iY = Locations[Index].Y
            iY = iY + MinY
            Locations[Index].X = iX
            Locations[Index].Y = iY
            #else
            Locations[Index].X = Locations[Index].X + X
            Locations[Index].Y = Locations[Index].Y + Y
            #endif
            Index = Index + 1
        }
    }
    
    /// Sets gravity speed to fast or normal.
    /// - Note: Calling this function changes gravity immediately.
    /// - Parameter Enable: If true, fast gravity is enabled. If false, normal gravity is enabled.
    func SetFastGravity(_ Enable: Bool = false)
    {
        GravitationalInterval = Enable ? 0.001 : 0.33
        OperationQueue.main.addOperation
            {
                self.GravitationalTimer?.invalidate()
                self.GravitationalTimer = Timer.scheduledTimer(timeInterval: self.GravitationalInterval, target: self,
                                                               selector: #selector(self.HandleGravityTimer), userInfo: nil,
                                                               repeats: false)
        }
    }
    
    /// Gravitional timer interval. May change over the course of a game.
    var GravitationalInterval: Double = 0.33
    {
        didSet
        {
            #if false
            DebugClient.Send("Piece: Gravity changed to \(GravitationalInterval)")
            #endif
        }
    }
    
    /// Gravitation timer. Applies the downward momemtum.
    var GravitationalTimer: Timer? = nil
    
    /// Handle the gravitational timer tick. Applies gravity (at whatever vector is current) to the falling block.
    /// Restarts the gravitational timer afterwards, with a potentially different gravitational interval. This timer
    /// will be stopped once a block starts freezing.
    /// - Note: All gravitational timer calls and references need to be in an `OperationQueue.main.addOperation`
    ///         block to ensure all calls are made on the same thread.
    @objc func HandleGravityTimer()
    {
        let Start = CACurrentMediaTime()
        if ThrowingAway
        {
            let Percent = Double(TopMost.y) / Double(GameBoard!.BucketBottomInterior)
            GameBoard?.SetPieceOpacity(To: Percent, ID: ID)
        }
        let VerticalDirection = ThrowingAway ? -1 : 1
        let UpdateStart = CACurrentMediaTime()
        let MovedOK = DoUpdateLocation(XDelta: 0, YDelta: 1 * VerticalDirection)
        if BelowBottom()
        {
            GravitationalInterval = 0.04
            PieceDroppedTooFar = true
            GameBoard!.SetPieceOpacity(GamePiece: self, To: 0.0, Duration: 0.2)
        }
        let UpdateDuration = CACurrentMediaTime() - UpdateStart
        if MovedOK
        {
            GameBoard?.PieceMoved(self, Direction: .Down, Commanded: false)
        }
        OperationQueue.main.addOperation
            {
                self.GravitationalTimer?.invalidate()
                self.GravitationalTimer = Timer.scheduledTimer(timeInterval: self.GravitationalInterval, target: self,
                                                               selector: #selector(self.HandleGravityTimer), userInfo: nil,
                                                               repeats: false)
        }
        let End = CACurrentMediaTime() - Start
        if End > 0.01
        {
            var FinalEnd = "\(Convert.Round(End, ToNearest: 0.0001))"
            if FinalEnd.count > 6
            {
                FinalEnd = String(FinalEnd.prefix(6))
            }
            var FinalUpdate = "\(Convert.Round(UpdateDuration, ToNearest: 0.0001))"
            if FinalUpdate.count > 6
            {
                FinalUpdate = String(FinalUpdate.prefix(6))
            }
        }
    }
    
    /// Handle master timer ticks.
    func Tick()
    {
        
    }
    
    /// Start the piece dropping. In this context, "dropping" means falling quickly to the
    /// bottom-most "ground" level location.
    /// - Note:
    ///   - If the play mode is in step or the gravity is disabled, gravitation is not turned on here.
    ///   - If gravity is disabled, no dropping occurs.
    func StartDropping()
    {
        if PlayMode == .Step
        {
            //If in step mode, no gravity is available.
            return
        }
        if !GravityIsEnabled
        {
            print("Gravity isn't enabled.")
            return
        }
        OperationQueue.main.addOperation {
            print("Dropping updated: \(self.GravitationalInterval)")
            self.GravitationalTimer = Timer.scheduledTimer(timeInterval: self.GravitationalInterval, target: self,
                                                           selector: #selector(self.HandleGravityTimer), userInfo: nil,
                                                           repeats: false)
        }
    }
    
    /// Enable or disable gravity.
    /// - Parameter Enable: Value that enables or disables gravity.
    func EnableGravity(_ Enable: Bool)
    {
        if Enable
        {
            StartDropping()
        }
        else
        {
            StopGravity()
        }
    }
    
    /// Holds the current gravity state.
    private var _GravityIsEnabled: Bool = true
    /// Get or set the enabled flag for gravity. Setting this property will turn on or off the gravity depending
    /// on the value you pass.
    public var GravityIsEnabled: Bool
    {
        get
        {
            return _GravityIsEnabled
        }
        set
        {
            _GravityIsEnabled = newValue
            EnableGravity(newValue)
        }
    }
    
    /// Stop gravity. This may be called because the game is paused or the piece is freezing.
    func StopGravity()
    {
        OperationQueue.main.addOperation {
            if self.GravitationalTimer != nil
            {
                self.GravitationalTimer?.invalidate()
                self.GravitationalTimer = nil
            }
        }
    }
    
    /// Resume dropping. This may be called because the piece became unfrozen or the game was unpaused.
    func Resume()
    {
        StartDropping()
    }
    
    /// Pause the piece. Thin wrapper around `StopGravity`.
    func Pause()
    {
        StopGravity()
    }
    
    /// Drop the piece to the bottom of the bucket (or as close as possible). Once at the bottom, does a fast
    /// freeze (but see `AndFreeze`).
    /// - Parameter AndFreeze: If true, the piece will do a fast freeze as the user expected. If false, the
    ///                        piece will still drop to the bottom quickly but it won't freeze quickly - it will
    ///                        freeze in the normal amount of time. This is for AI uses only.
    func DropToBottom(AndFreeze: Bool = true)
    {
        while true
        {
            if !DoUpdateLocation(XDelta: 0, YDelta: 1)
            {
                break
            }
        }
        if AndFreeze
        {
            GameBoard?.CannotMove(ID: ID)
            StartFreezing(FastFreeze: true)
        }
        else
        {
            StartDropping()
        }
    }
    
    /// Flag that indicates whether the peice dropped too far (eg, below the bottom of the bucket) or not.
    public var PieceDroppedTooFar: Bool = false
    
    /// Drop the piece to the bottom-most available location.
    /// - Note: Once called, the piece is no longer manuverable. Gravity is changed to make this a very fast
    ///         operation.
    /// - Parameter AndFreeze: If true, the drop down behaves as expected with the piece falling quickly to the
    ///                        bottom-most available location in the bucket then freezing immediately. If false,
    ///                        the piece still drops quickly, but doesn't immediately freeze - it will freeze over
    ///                        the standard amount of time. This is for use by the AI only.
    func DropDown(AndFreeze: Bool)
    {
        if PlayMode == .Step
        {
            StopGravity()
            DropToBottom()
            return
        }
        print("At DropDown")
        DroppingPiece = true
        StandardDropDown = AndFreeze
        #if false
        GravitationalTimer?.invalidate()
        GravitationalTimer = nil
        let Bottoms = Bottom()
        
        var Distance = Int.max
        for BottomNode in Bottoms
        {
            let NodeDistance = GameBoard!.DistanceToBottom(From: BottomNode)
            if NodeDistance < Distance
            {
                Distance = NodeDistance
            }
        }
        GameBoard?.ExecuteDropDown(By: Distance, WithPiece: self)
        
        #else
        StopGravity()
        GravitationalInterval = 0.03
        StartDropping()
        #endif
    }
    
    /// Performs a fast freeze after a drop down command has finished.
    func FreezeAfterDropDown()
    {
        StartFreezing(FastFreeze: true)
    }
    
    /// Dropping a piece flag.
    var DroppingPiece = false
    
    /// If true, the drop down is standard (eg, drop then freeze). If false, the drop down still occurs,
    /// but freezing takes the normal amount of time.
    var StandardDropDown = true
    
    /// Update the location of the piece. Called by both the gravitational timer and by user inputs. If the piece
    /// cannot move downwards, it starts freezing and will finalize after a certain amount of time.
    /// -Note: Freezing occurs only when the block cannot move downwards (or along the path of gravity).
    /// - Parameters:
    ///   - XDelta: Horizontal delta to apply to the piece's location.
    ///   - YDelta: Vertical delta to apply to the piece's location.
    /// - Returns: True if the piece could move to the new location, false if not. A false result does not necessary
    ///            mean the piece has started to freeze - it may be that the user tried to move left when there was
    ///            no room to the left. Freezing only occurs when the piece cannot move down.
    @discardableResult func DoUpdateLocation(XDelta: Int, YDelta: Int) -> Bool
    {
        let AbleToMove = CanMove(ByX: XDelta, ByY: YDelta)
        if !AbleToMove
        {
            if ThrowingAway
            {
                GameBoard?.DiscardPiece(self)
                ThrowAway()
                return false
            }
            if YDelta > 0
            {
                GameBoard?.CannotMove(ID: ID)
                StartFreezing(FastFreeze: DroppingPiece)
                return false
            }
            //If we're here, it's because the block tried to move horizontally and couldn't. It's not
            //time to freeze it yet.
            return false
        }
        for Index in 0 ..< Locations.count
        {
            let OldPoint = Locations[Index]
            Locations[Index].X = Int(OldPoint.X) + XDelta
            Locations[Index].Y = Int(OldPoint.Y) + YDelta
        }
        //If we're here, we can move.
        StopFreezing()
        let NewLocStart = CACurrentMediaTime()
        GameBoard?.NewLocation2(ForPiece: self, XOffset: XDelta, YOffset: YDelta)
        let NewLocEnd = CACurrentMediaTime() - NewLocStart
        let FinalLoc = Convert.Round(NewLocEnd, ToNearest: 0.0001)
        var FinalLocS = "\(FinalLoc)"
        if FinalLocS.count > 6
        {
            FinalLocS = String(FinalLocS.prefix(6))
            print("FinalLocS=\(FinalLocS)")
        }
        return true
    }
    
    /// Update the location of the piece. Called by both the gravitational timer and by user inputs. If the piece
    /// cannot move downwards, it starts freezing and will finalize after a certain amount of time.
    /// - Note: Freezing occurs only when the block cannot move downwards (along the path of gravity).
    /// - Note: If the block is dropping, all input is ignored.
    /// - Parameters:
    ///   - XDelta: Horizontal delta to apply to the piece's location.
    ///   - YDelta: Vertical delta to apply to the piece's location.
    ///   - CalledBy: Debug use.
    /// - Returns: True if the piece could move to the new location, false if not. A false result does not necessary
    ///            mean the piece has started to freeze - it may be that the user tried to move left when there was
    ///            no room to the left. Freezing only occurs when the piece cannot move down.
    @discardableResult func UpdateLocation(XDelta: Int, YDelta: Int, CalledBy: String? = nil) -> Bool
    {
        if DroppingPiece
        {
            return false
        }
        #if false
        if let Caller = CalledBy
        {
            print("UpdateLocation for \(ID.uuidString) called by \(Caller)")
        }
        #endif
        return DoUpdateLocation(XDelta: XDelta, YDelta: YDelta)
    }
    
    /// Holds the stopped out of bounds flag.
    private var _StoppedOutOfBounds: Bool = false
    /// Get the stopped out of bounds flag.
    public var StoppedOutOfBounds: Bool
    {
        get
        {
            return _StoppedOutOfBounds
        }
    }
    
    /// Zoom the piece away from the board vertically and start a new piece. (This is our silly way of letting the
    /// user cancel a piece he doesn't like in favor for the next piece.)
    func UpAndAway()
    {
        ThrowingAway = true
        DroppingPiece = true
        StopGravity()
        GravitationalInterval = 0.02
        StartDropping()
    }
    
    var ThrowingAway: Bool = false
    
    func BelowBottom() -> Bool
    {
        for Block in Locations
        {
            if GameBoard!.Map!.OutOfBoundsLow(Block.X, Block.Y)
            {
                return true
            }
        }
        return false
    }
    
    /// Determines if the piece can move to the location provided by the passed offset.
    /// - Warning: Generates a fatal error if `GameBoard` is nil. This is an abnormal occurrence and should not happen but some
    ///            unusual timing scenarios have caused this issue to occur in the past.
    /// - Parameters:
    ///   - ByX: Horizontal offset.
    ///   - ByY: Vertical offset.
    /// - Returns: True if the piece can move to the offset position, false if not.
    func CanMove(ByX: Int, ByY: Int) -> Bool
    {
        var Index = -1
        for Block in Locations
        {
            #if false
            if !(GameBoard?.PointInBucket(Point: CGPoint(x: Block.X, y: Block.Y)))!
            {
                print("Point (\(Block.X),\(Block.Y)) is out of bucket.")
            }
            #endif
            if Block.X < GameBoard!.BucketInteriorLeft || Block.X > GameBoard!.BucketInteriorRight
            {
                //The block is too far right or too far left.
                return false
            }
            Index = Index + 1
            let CheckAt = Block.Location.WithOffset(ByX, ByY)
            if GameBoard == nil
            {
                print("Piece \(ID.uuidString) expected board \(GameBoardID.uuidString)")
                print("Current game board is nil.")
                print("GameCount: \(BoardGameCount)")
                print("Piece activation state: \(Activated)")
                print("Piece termination state: \(WasTerminated)")
                fatalError("Encountered active piece whose board was deinitialized.")
            }
            let MapCheckStart = CACurrentMediaTime()
            let MapIsEmpty: Bool = GameBoard!.MapIsEmpty(At: CheckAt)
            let MapCheckEnd = CACurrentMediaTime() - MapCheckStart
            var MapCheck = "\(Convert.Round(MapCheckEnd, ToNearest: 0.0001))"
            if MapCheck.count > 6
            {
                MapCheck = String(MapCheck.prefix(6))
            }
            //DebugClient.Send("MapCheck duration: \(MapCheck)")
            if !MapIsEmpty
            {
                return false
            }
        }
        return true
    }
    
    /// Holds the piece type.
    private var _PieceType: PieceTypes = .Visible
    /// Get the piece type.
    public var PieceType: PieceTypes
    {
        get
        {
            return _PieceType
        }
    }
    
    /// Handle pieces that have been thrown away and are ready to be removed from the board.
    func ThrowAway()
    {
        ThrowingAway = false
        GameBoard?.SetPieceOpacity(To: 0.0, ID: ID)
        StopGravity()
    }
    
    /// Start freezing the block. There is a certain amount of time the user can move the block before
    /// it becomes frozen and a new block drops.
    /// - Note: `FastFreeze` controls the speed at which the piece will be frozen into place. However,
    ///         if `StandardDropDown` is false, the piece will freeze into place over the standard amount
    ///         of time, not the fast amount of time. This is used by the AI only.
    /// - Parameter FastFreeze: If true, the block will freeze into place quickly (regardless of the
    ///                         current dropping state).
    func StartFreezing(FastFreeze: Bool = false)
    {
        if CurrentlyFreezing
        {
            //Don't freeze more than once.
            return
        }
        var FreezeTime = DroppingPiece ? 0.01 : 0.5
        if FastFreeze
        {
            if StandardDropDown
            {
                FreezeTime = 0.01
            }
            else
            {
                FreezeTime = 0.5
            }
        }
        OperationQueue.main.addOperation
            {
                self.RandomRotationTimer?.invalidate()
                self.RandomRotationTimer = nil
                self.RandomMotionTimer?.invalidate()
                self.RandomMotionTimer = nil
        }
        StopGravity()
        CurrentlyFreezing = true
        GameBoard?.StartedFreezing(ID)  
        OperationQueue.main.addOperation
            {
                self.FreezeTimer = Timer.scheduledTimer(timeInterval: FreezeTime, target: self,
                                                        selector: #selector(self.Frozen), userInfo: nil,
                                                        repeats: false)
        }
    }
    
    /// Current freezing state.
    var CurrentlyFreezing = false
    
    /// Stop freezing the piece and resume dropping. This is called when the user moves the block horizontally
    /// (if such a position is available) when the piece is in the freezing time-zone.
    func StopFreezing()
    {
        if !CurrentlyFreezing
        {
            return
        }
        CurrentlyFreezing = false
        OperationQueue.main.addOperation {
            self.GameBoard?.StoppedFreezing(self.ID)
            self.FreezeTimer?.invalidate()
            self.FreezeTimer = nil
        }
        StartDropping()
    }
    
    /// Called at the end of the freeze time period. The game board is called to freeze the piece into place
    /// and remove it from the list of in-play blocks. Additionally, if the piece is frozen with at least one
    /// one block above the rim of the bucket, the game is over.
    /// - Note:
    ///   - Game over determination is handled here.
    ///   - With certain game types, the freeze timer may continue working even after the piece is frozen and reset (board set
    ///     to nil, etc). If that happens, this function will not work properly as it relies on `GameBoard` being valid. So, if
    ///     this function detects `GameBoard` as invalid, it will return without taking any action other than killing the freeze
    ///     timer.
    @objc func Frozen()
    {
        if GameBoard == nil
        {
            //Nothing to do (or anything that we _can_ do.
            OperationQueue.main.addOperation
                {
                    self.FreezeTimer?.invalidate()
                    self.FreezeTimer = nil
            }
            var NotUsed: String? = nil
            ActivityLog.AddEntry(Title: "Game", Source: "Piece", KVPs: [("Message","Encountered nil GameBoard in Frozen - killed the Freeze Timer.")], LogFileName: &NotUsed)
//            print(">>>>> Encountered nil GameBoard in Frozen - killed the Freeze timer.")
            return
        }
        if !Thread.isMainThread
        {
            print("Calling PieceFroze from thread \((OperationQueue.current?.underlyingQueue?.label)!)")
            DispatchQueue.main.async
                {
                    [weak self] in
                    self?.FreezeTimer?.invalidate()
                    self?.FreezeTimer = nil
                    self?.GameBoard?.PieceFroze(ID: self!.ID)
            }
            return
        }
        OperationQueue.main.addOperation
            {
                self.FreezeTimer?.invalidate()
                self.FreezeTimer = nil
        }
        if PieceFullyInBounds()
        {
            OperationQueue.main.addOperation
                {
                    self.GameBoard?.PieceFroze(ID: self.ID)
            }
        }
        else
        {
            //If the piece stopped out of bounds, the game is over.
            _StoppedOutOfBounds = true
            GameBoard?.StoppedOutOfBounds(ID: ID)
        }
    }
    
    /// The freeze piece timer. All operational references should be in an `OperationQueue.main.addOperation` block.
    var FreezeTimer: Timer? = nil
    
    /// Determines if each block in the piece is fully in the bucket (eg, under the top of the bucket).
    func PieceFullyInBounds() -> Bool
    {
        if GameBoard == nil
        {
            Thread.callStackSymbols.forEach{print($0)}
            fatalError("GameBoard is nil in PieceFullyInBounds.")
        }
        if !(GameBoard?.PieceInBounds(self))!
        {
            return false
        }
        return true
    }
    
    /// Handle random rotations.
    /// - Note: If the randomly selected rotation is not valid (see `ValidMotions`) then no random rotation will occur for this instance.
    /// - Note: This function is exited before any motions occur a random number of times.
    @objc func HandleRandomRotation()
    {
        if Coin.Flip() == .Heads
        {
            return
        }
        let RotationDirection = [Directions.RotateLeft, Directions.RotateRight].randomElement()
        switch RotationDirection!
        {
            case Directions.RotateLeft:
                CanRotateLeft()
            
            case Directions.RotateRight:
                CanRotateRight()
            
            default:
                break
        }
    }
    
    /// Handle random motions.
    /// - Note:
    ///    - If the randomly selected motion is not valid (see `ValidMotions`) then no random motion will occur for this instance.
    ///    - This function is exited before any motions occur a random number of times.
    @objc func HandleRandomMotion()
    {
        if Coin.Flip() == .Heads
        {
            return
        }
        let MotionDirection = [Directions.Down, Directions.DropDown, Directions.Left, Directions.Right, Directions.Up].randomElement()
        switch MotionDirection!
        {
            case .Down:
                UpdateLocation(XDelta: 0, YDelta: 1)
            
            case .DropDown:
                UpdateLocation(XDelta: 0, YDelta: 1)
            
            case .Up:
                UpdateLocation(XDelta: 0, YDelta: -1)
            
            case .Right:
                UpdateLocation(XDelta: 1, YDelta: 0)
            
            case .Left:
                UpdateLocation(XDelta: -1, YDelta: 0)
            
            default:
                break
        }
    }
    
    /// Table to convert relative random motion enum values to durations in seconds.
    let RandomTimes: [Double] = [Double.greatestFiniteMagnitude, 5.0, 4.0, 2.0, 1.0]
    
    /// The random rotation timer.
    var RandomRotationTimer: Timer? = nil
    
    /// The random motion timer.
    var RandomMotionTimer: Timer? = nil
    
    /// Holds the value of the relative occurence of random rotations.
    private var _RandomRotationFrequency: RandomFrequencies = .Never
    {
        didSet
        {
            OperationQueue.main.addOperation
                {
                    if self._RandomRotationFrequency == .Never
                    {
                        if self.RandomRotationTimer != nil
                        {
                            self.RandomRotationTimer?.invalidate()
                            self.RandomRotationTimer = nil
                        }
                        else
                        {
                            let Duration = self.RandomTimes[self._RandomRotationFrequency.rawValue]
                            self.RandomRotationTimer = Timer.scheduledTimer(timeInterval: Duration, target: self,
                                                                            selector: #selector(self.HandleRandomRotation), userInfo: nil, repeats: true)
                        }
                    }
            }
        }
    }
    /// Get or set the relative occurence of random rotations.
    public var RandomRotationFrequency: RandomFrequencies
    {
        get
        {
            return _RandomRotationFrequency
        }
        set
        {
            _RandomRotationFrequency = newValue
        }
    }
    
    /// Holds the value of the relative occurence of random motions.
    private var _RandomMotionFrequency: RandomFrequencies = .Never
    {
        didSet
        {
            OperationQueue.main.addOperation
                {
                    if self._RandomMotionFrequency == .Never
                    {
                        if self.RandomMotionTimer != nil
                        {
                            self.RandomMotionTimer?.invalidate()
                            self.RandomMotionTimer = nil
                        }
                        else
                        {
                            let Duration = self.RandomTimes[self._RandomMotionFrequency.rawValue]
                            self.RandomMotionTimer = Timer.scheduledTimer(timeInterval: Duration, target: self,
                                                                          selector: #selector(self.HandleRandomMotion), userInfo: nil, repeats: true)
                        }
                    }
            }
        }
    }
    /// Get or set the relative occurence of random motions.
    public var RandomMotionFrequency: RandomFrequencies
    {
        get
        {
            return _RandomMotionFrequency
        }
        set
        {
            _RandomMotionFrequency = newValue
        }
    }
    
    /// Holds the list of valid motions for the block. If the caller sets this to an empty list, a fatal error will occur.
    private var _ValidMotions: [Directions] = [.Down, .DropDown, .Left, .Right, .Up, .RotateLeft, .RotateRight]
    {
        didSet
        {
            if _ValidMotions.isEmpty
            {
                fatalError("ValidMotions may not be empty.")
            }
        }
    }
    /// Get or set the list of valid motions for the block. Setting this property to an empty list will cause a fatal error.
    public var ValidMotions: [Directions]
    {
        get
        {
            return _ValidMotions
        }
        set
        {
            _ValidMotions = newValue
        }
    }
    
    /// Determines if the passed motion is valid compared to the `ValidMotions` property.
    /// - Parameter Motion: Motion to validated against the `ValidMotions` list.
    /// - Returns: True if the passed motion is valid, false if not.
    public func IsValidMotion(_ Motion: Directions) -> Bool
    {
        return ValidMotions.contains(Motion)
    }
    
    /// Implements subscripting for the piece. Blocks are the object returned/set.
    /// - Note: Passing an invalid index (less than 0, greater than the number of blocks) will result in a
    ///         fatal error.
    /// - Parameter Index: The index of the block to access. Invalid indicies result in fatal errors.
    public subscript(Index: Int) -> Block
    {
        get
        {
            if Index < 0 || Index > Locations.count
            {
                fatalError("Subscript out of range: \(Index)")
            }
            return Locations[Index]
        }
        set
        {
            if Index < 0 || Index > Locations.count
            {
                fatalError("Subscript out of range: \(Index)")
            }
            Locations[Index] = newValue
        }
    }
    
    /// Converts all points in the list of passed blocks to the origin, as determined by the block flag `.IsOrigin`. Used
    /// to rotate pieces.
    /// - Parameter Blocks: List of blocks. One block must have `.IsOrigin` set to true - if not, nil is returned.
    /// - Returns: List of points (in the same order as the list of blocks) translated to the origin, as defined
    ///            by the block marked by `.IsOrigin`. If no block was marked as the origin block, nil is returned.
    static func OriginOffset(_ Blocks: [Block]) -> [CGPoint]?
    {
        var Origin: CGPoint? = nil
        for SomeBlock in Blocks
        {
            if SomeBlock.IsOrigin
            {
                Origin = CGPoint(x: Int(SomeBlock.X), y: Int(SomeBlock.Y))
                break
            }
        }
        if let BlockOrigin = Origin
        {
            var Offsets = [CGPoint]()
            for SomeBlock in Blocks
            {
                let Offset = CGPoint(x: Int(BlockOrigin.x) - SomeBlock.X, y: Int(BlockOrigin.y) - SomeBlock.Y)
                Offsets.append(Offset)
            }
            return Offsets
        }
        else
        {
            return nil
        }
    }
    
    /// Returns the origin point in the list of blocks.
    /// - Parameter Blocks: Blocks whose origin block's point will be returned.
    /// - Returns: The current point of the origin block in the passed list of blocks. Nil if no block
    ///            marked as the origin.
    static func CurrentOriginIn(_ Blocks: [Block]) -> CGPoint?
    {
        for SomeBlock in Blocks
        {
            if SomeBlock.IsOrigin
            {
                return SomeBlock.Location
            }
        }
        return nil
    }
    
    /// Rotates the passed point by the specified angle.
    /// - Note: This function assumes the point has been translated to its local origin.
    /// - Parameters:
    ///   - Angle: The angle, in degrees, to rotate the point by.
    ///   - Point: The point to rotate.
    /// - Returns: The rotated point value.
    private static func RotateBy(Angle: Double, Point: CGPoint) -> CGPoint
    {
        let Radians = Angle * .pi / 180.0
        let X = round((Double(Point.x) * cos(Radians)) - (Double(Point.y) * sin(Radians)))
        let Y = round((Double(Point.x) * sin(Radians)) + (Double(Point.y) * cos(Radians)))
        return CGPoint(x: Int(X), y: Int(Y))
    }
    
    /// Rotate all blocks in the list of passed blocks 90° counter-clockwise (left).
    /// - Parameter Blocks: List of blocks that supply the points to rotate.
    /// - Returns: List of rotated points in the same order as the original, passed list of blocks.
    static func LeftRotate(_ Blocks: [Block]) -> [CGPoint]?
    {
        if let Origin = CurrentOriginIn(Blocks)
        {
            var Points = [CGPoint]()
            for Block in Blocks
            {
                Points.append(Block.Location)
            }
            return LeftRotate(Points, AboutOrigin: Origin)
        }
        else
        {
            return nil
        }
    }
    
    /// Rotates the list of points left (counter-clockwise) around the passed origin point.
    /// - Note: If Times is less than 1, a fatal error will occur.
    /// - Parameters:
    ///   - Points: The list of points to rotate.
    ///   - AboutOrigin: The origin of the points (not necessarily (0,0)).
    ///   - Times: Number of times to rotate each point.
    /// - Returns: List of rotated points.
    public static func LeftRotate(_ Points: [CGPoint], AboutOrigin: CGPoint, Times: Int = 1) -> [CGPoint]
    {
        if Times < 1
        {
            fatalError("Must rotate at least once.")
        }
        var Results = [CGPoint]()
        for Point in Points
        {
            let NewPoint = Point.WithOffset(Int(-AboutOrigin.x), Int(-AboutOrigin.y))
            var RotatedPoint: CGPoint!
            for _ in 0 ..< Times
            {
                RotatedPoint = RotateBy(Angle: 90.0, Point: NewPoint)
            }
            RotatedPoint = RotatedPoint.WithOffset(AboutOrigin)
            Results.append(RotatedPoint)
        }
        return Results
    }
    
    /// Rotate all blocks in the list of passed blocks 90° clockwise (right).
    /// - Parameter Blocks: List of blocks that supply the points to rotate.
    /// - Returns: List of rotated points in the same order as the original, passed list of blocks.
    static func RightRotate(_ Blocks: [Block]) -> [CGPoint]?
    {
        if let Origin = CurrentOriginIn(Blocks)
        {
            var Points = [CGPoint]()
            for Block in Blocks
            {
                Points.append(Block.Location)
            }
            return RightRotate(Points, AboutOrigin: Origin)
        }
        else
        {
            return nil
        }
    }
    
    /// Rotates the list of points right (clockwise) around the passed origin point.
    /// - Note: If Times is less than 1, a fatal error will occur.
    /// - Parameters:
    ///   - Points: The list of points to rotate.
    ///   - AboutOrigin: The origin of the points (not necessarily (0,0)).
    ///   - Times: Number of times to rotate each point.
    /// - Returns: List of rotated points.
    public static func RightRotate(_ Points: [CGPoint], AboutOrigin: CGPoint, Times: Int = 1) -> [CGPoint]
    {
        if Times < 1
        {
            fatalError("Must rotate at least once.")
        }
        var Results = [CGPoint]()
        for Point in Points
        {
            let NewPoint = Point.WithOffset(Int(-AboutOrigin.x), Int(-AboutOrigin.y))
            var RotatedPoint: CGPoint!
            for _ in 0 ..< Times
            {
                RotatedPoint = RotateBy(Angle: -90.0, Point: NewPoint)
            }
            RotatedPoint = RotatedPoint.WithOffset(AboutOrigin)
            Results.append(RotatedPoint)
        }
        return Results
    }
    
    /// Returns the horizontal span between the passed set of points.
    /// - Note: Horizontal span is merely the delta between the left-most point and the right-most point + 1.
    /// - Parameter Points: The list of points in which to generate the horizontal span.
    /// - Returns: The horizontal span between the left-most and right-most points in the passed list.
    public static func HorizontalSpan(_ Points: [CGPoint]) -> Int
    {
        var MaxX = Int.min
        var MinX = Int.max
        for Point in Points
        {
            if Int(Point.x) < MinX
            {
                MinX = Int(Point.x)
            }
            if Int(Point.x) > MaxX
            {
                MaxX = Int(Point.x)
            }
        }
        return MaxX - MinX + 1
    }
    
    /// Returns the vertical span between the passed set of points.
    /// - Note: Vertical span is merely the delta between the top-most point and the bottom-most point + 1.
    /// - Parameter Points: The list of points in which to generate the vertical span.
    /// - Returns: The vertical span between the top-most and bottom-most points in the passed list.
    public static func VerticalSpan(_ Points: [CGPoint]) -> Int
    {
        var MaxY = Int.min
        var MinY = Int.max
        for Point in Points
        {
            if Int(Point.y) < MinY
            {
                MinY = Int(Point.y)
            }
            if Int(Point.y) > MaxY
            {
                MaxY = Int(Point.y)
            }
        }
        return MaxY - MinY + 1
    }
    
    /// Return the points in the piece normalized to the smallest possible non-negative values (eg, moved as close to the origin as possible).
    /// - Returns: List of points (in the current orientation) normalized.
    public func NormalizedLocations() -> [CGPoint]
    {
        var SmallestX = Int.max
        var SmallestY = Int.max
        for SomeBlock in Locations
        {
            if SomeBlock.X < SmallestX
            {
                SmallestX = SomeBlock.X
            }
            if SomeBlock.Y < SmallestY
            {
                SmallestY = SomeBlock.Y
            }
        }
        var Results = [CGPoint]()
        for SomeBlock in Locations
        {
            Results.append(CGPoint(x: Int(SomeBlock.X) - SmallestX, y: Int(SomeBlock.Y) - SmallestY))
        }
        return Results
    }
    
    /// Return the original component locations normalized to the smallest possible non-negative values (eg, moved as close to the origin as possible).
    /// - Returns: List of points in the original orientation.
    public func NormalizedComponents() -> [CGPoint]
    {
        var SmallestX = Int.max
        var SmallestY = Int.max
        for SomeBlock in Components
        {
            if SomeBlock.X < SmallestX
            {
                SmallestX = SomeBlock.X
            }
            if SomeBlock.Y < SmallestY
            {
                SmallestY = SomeBlock.Y
            }
        }
        var Results = [CGPoint]()
        let YOffset = SmallestY * -1
        let XOffset = SmallestX * -1
        for SomeBlock in Components
        {
            Results.append(CGPoint(x: Int(SomeBlock.X) + XOffset, y: Int(SomeBlock.Y) + YOffset))
        }
        return Results
    }
    
    /// Return the piece as a string representing the shape of the piece in its current orientation.
    /// - Returns: String of the piece's shape in the current orientation.
    public func PieceAsString() -> String
    {
        var Result = ""
        var Lines = [String]()
        for _ in 0 ..< ComponentHeight
        {
            Lines.append(String(repeating: " ", count: ComponentWidth))
        }
        let Points = NormalizedComponents()
        for Point in Points
        {
            var stemp = Lines[Int(Point.y)]
            let Index = stemp.index(stemp.startIndex, offsetBy: Int(Point.x))
            stemp.replaceSubrange(Index ... Index, with: "\u{2588}")
            Lines[Int(Point.y)] = stemp
        }
        for Line in Lines
        {
            Result = Result + Line
            if Line != Lines.last
            {
                Result = Result + "\n"
            }
        }
        return Result
    }
    
    /// Returns a description of the contents of the Piece.
    public var description: String
    {
        get
        {
            var CompS = "("
            for Component in Components
            {
                CompS.append("(\(Component.X),\(Component.Y)) ")
            }
            CompS.append(")")
            var LocS = " ("
            for Location in Locations
            {
                LocS.append("(\(Location.X),\(Location.Y)) ")
            }
            LocS.append(")")
            return "Shape: \(Shape), Components: \(CompS), Locations: \(LocS)"
        }
    }
}

/// Describes how often to randomly move or rotate the block. The actual values are in the table `RandomTimes`.
/// - Never: Never - same as disabling random motion/rotation.
/// - Seldom: Rarely.
/// - Sometimes: More than rarely.
/// - Many: Less than too many.
/// - TooMany: Frequently, perhaps distractingly so.
enum RandomFrequencies: Int, CaseIterable
{
    case Never = 0
    case Seldom = 1
    case Sometimes = 2
    case Many = 3
    case TooMany = 4
}
