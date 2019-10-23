//
//  MapType.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Encapsulates a map and ancillary data for the game board.
/// - Note:
///    - There are two two main layers to the map: The first layer is the piece type layer which identifies the type of
///      piece in a give location in the map, such as bucket, visible (empty), retired piece, active piece, and the like.
///      The second layer is the block map which is a map of identifies of which individual block occupies which location.
class MapType: CustomStringConvertible
{
    #if true
    /// Initializer.
    /// - Parameters:
    ///   - Width: Width of the map.
    ///   - Height: Height of the map.
    ///   - ID: ID of the map.
    ///   - BucketShape: Shape of the game's bucket.
    init(Width: Int, Height: Int, ID: UUID, BucketShape: BucketShapes)
    {
        print("init(Width: \(Width), Height: \(Height), ID: \(ID.uuidString), BucketShape: \(BucketShape))")
        _MapID = ID
        let Board = BoardManager.GetBoardFor(BucketShape)!
        self.Width = Board.GameBoardWidth
        self.Height = Board.GameBoardHeight
//        self.Width = Width
//        self.Height = Height
        Initialize(Width: Width, Height: Height, BoardBucketShape: BucketShape)
    }
    #else
    /// Initializer.
    ///
    /// - Parameters:
    ///   - Width: Width of the map.
    ///   - Height: Height of the map.
    ///   - ID: ID of the map.
    ///   - BaseType: Base game type.
    init(Width: Int, Height: Int, ID: UUID, BaseType: BaseGameTypes)
    {
        _MapID = ID
        self.Width = Width
        self.Height = Height
        Initialize(Width: Width, Height: Height, BaseType: BaseType)
    }
    #endif
    
    #if true
    /// Initializer. Uses the standard bucket/map size. The map size is 12x34 and the bucket is 10x20 and
    /// sits on the bottom of the map.
    /// - Parameter ID: ID of the map.
    init(ID: UUID)
    {
        print("init(ID: \(ID.uuidString))")
        let Board = BoardManager.GetBoardFor(.Classic)!
        _MapID = ID
        self.Width = Board.GameBoardWidth
        self.Height = Board.GameBoardHeight
//        Width = 12
//        Height = 34
        Initialize(Width: Width, Height: Height, BoardBucketShape: .Classic)
    }
    #else
    /// Initializer. Uses the standard bucket/map size. The map size is 12x34 and the bucket is 10x20 and
    /// sits on the bottom of the map.
    ///
    /// - Parameter ID: ID of the map.
    init(ID: UUID)
    {
        _MapID = ID
        Width = 12
        Height = 34
        Initialize(Width: Width, Height: Height, BaseType: .Standard)
    }
    #endif
    
    /// Deinitializer.
    deinit
    {
        for var SomePiece in InPlay
        {
            SomePiece?.Terminate()
            SomePiece = nil
        }
    }
    
    /// Holds the scorer for the game.
    private var _Scorer: Score? = nil
    /// Get or set the scorer for the game.
    public var Scorer: Score?
    {
        get
        {
            return _Scorer
        }
        set
        {
            _Scorer = newValue
        }
    }
    
    /// Holds the list of in-play (eg, moving) pieces.
    private var _InPlay = [Piece?]()
    /// Get or set the list of in-play pieces.
    public var InPlay: [Piece?]
    {
        get
        {
            return _InPlay
        }
        set
        {
            _InPlay = newValue
        }
    }
    
    /// Terminate and remove all in-play pieces.
    public func RemoveInPlayPieces()
    {
        for var SomePiece in InPlay
        {
            SomePiece?.Terminate()
            SomePiece = nil
        }
        InPlay.removeAll()
    }
    
    /// Deletes the specified piece from the in-play list.
    /// - Parameter ID: The ID of the piece to delete.
    public func DeleteInPlayPiece(_ ID: UUID)
    {
        for SomePiece in InPlay
        {
            if SomePiece?.ID == ID
            {
                SomePiece?.Terminate()
                break
            }
        }
        InPlay.removeAll{$0?.ID == ID}
    }
    
    #if true
    /// Initialize the map contents and related properties.
    /// - Note:
    ///   - If `Scorer` is nil, it is initialized here with standard default values.
    /// - Parameters:
    ///   - Width: Width of the map.
    ///   - Height: Height of the map.
    ///   - BucketShape: The shape of the bucket in the map.
    private func Initialize(Width: Int, Height: Int, BoardBucketShape: BucketShapes)
    {
        print("Initialize(Width: \(Width), Height: \(Height), BoardBucketShape: \(BoardBucketShape)")
        _BucketShape = BoardBucketShape
        let RawBucket = BoardManager.GetBoardFor(BoardBucketShape)
        _BoardClass = BoardData.GetBoardClass(For: BucketShape)!
        #if true
        if BoardClass == .Rotatable || BoardClass == .ThreeDimensional
        {
            if Width != Height
            {
                fatalError("Width and Height must be the same for .Rotating4 or .Cubic. Width was \(Width) and Height was \(Height).")
            }
        }
        #else
        if BaseType == .Rotating4 || BaseType == .Cubic
        {
            if Width != Height
            {
                fatalError("Width and Height must be the same for .Rotating4 or .Cubic. Width was \(Width) and Height was \(Height).")
            }
        }
        #endif
        _CurrentRotation = 0
        InPlay = [Piece]()
        #if true
                _IDMap = PieceIDMap()
        _CurrentBoardSize = CGSize(width: RawBucket!.GameBoardWidth, height: RawBucket!.GameBoardHeight)
        print("_CurrentBoardSize: \(_CurrentBoardSize)")
        _Contents = MapType.CreateMap(Width: RawBucket!.GameBoardWidth, Height: RawBucket!.GameBoardHeight,
                                      FillWith: IDMap!.StaticID(For: .Visible))
        _BlockMap = MapType.CreateMap(Width: RawBucket!.GameBoardWidth, Height: RawBucket!.GameBoardHeight,
                                      FillWith: UUID.Empty)
        #else
        _CurrentBoardSize = CGSize(width: Width, height: Height)
        _IDMap = PieceIDMap()
        _Contents = MapType.CreateMap(Width: Width, Height: Height, FillWith: IDMap!.StaticID(For: .Visible))
        _BlockMap = MapType.CreateMap(Width: Width, Height: Height, FillWith: UUID.Empty)
        #endif
        
        print("Bucket size: \(RawBucket!.BucketWidth), \(RawBucket!.BucketHeight)")
        print("Bucket location: \(RawBucket!.BucketX),\(RawBucket!.BucketY)")
        print("GameBoard size: \(RawBucket!.GameBoardSize())")
        switch BoardClass
        {
            case .Static:
                #if true
                _BucketBottom = RawBucket!.BucketHeight - 1
                _BucketInteriorBottom = _BucketBottom - 1
                _BucketTop = RawBucket!.BucketY
                _BucketInteriorTop = _BucketTop
                _BucketInteriorLeft = RawBucket!.BucketX
                _BucketInteriorRight = RawBucket!.BucketWidth - 1
                _BucketInteriorRight = (Width - _BucketInteriorLeft) - 1
                _BucketInteriorWidth = RawBucket!.BucketWidth - 2
                _BucketInteriorHeight = RawBucket!.BucketHeight - 1
                //print("_Bucket: Top=\(_BucketTop), Bottom=\(_BucketBottom), InteriorLeft=\(_BucketInteriorLeft), InteriorRight=\(_BucketInteriorRight)")
                #else
                _BucketBottom = Height - 1
                _BucketInteriorBottom = _BucketBottom - 1
                _BucketTop = Height - 21
                _BucketInteriorTop = _BucketTop
                _BucketInteriorLeft = 1
                _BucketInteriorRight = Width - 1 - 1
                _BucketInteriorWidth = (BucketInteriorRight - 1) - (BucketInteriorLeft - 1) - 1
                _BucketInteriorHeight = (BucketBottom - 1) - (BucketTop - 1) - 1
                #endif
            
            case .Rotatable:
                let bb = RawBucket!.BucketHeight + RawBucket!.BucketY - 1
                _BucketBottom = bb
                _BucketInteriorBottom = _BucketBottom
                let bt = RawBucket!.BucketY
                _BucketTop = bt
                _BucketInteriorTop = _BucketTop
                let bil = RawBucket!.BucketX
                _BucketInteriorLeft = bil
                let bir = RawBucket!.BucketX + RawBucket!.BucketWidth - 1
                _BucketInteriorRight = bir
                _BucketInteriorWidth = RawBucket!.BucketWidth
                _BucketInteriorHeight = RawBucket!.BucketHeight
                
                _CenterBlockUpperLeft = CGPoint(x: (Width / 2) - 2, y: (Height / 2) - 2)
                _CenterBlockLowerRight = CGPoint(x: (Width / 2) - 2 + 3, y: (Height / 2) - 2 + 3)
            
            case .ThreeDimensional:
                break
        }
        
        let BucketID = IDMap!.StaticID(For: .Bucket)
        let InvisibleBucketID = IDMap!.StaticID(For: .InvisibleBucket)
        let BucketExteriorID = IDMap!.StaticID(For: .BucketExterior)
        MapType.InitializeMap(Width: Width, Height: Height,
                              BucketTop: BucketTop, BucketBottom: _BucketBottom, BucketLeft: _BucketInteriorLeft - 1,
                              BucketRight: _BucketInteriorRight + 1, Map: &_Contents,
                              BucketID: BucketID, InvisibleBucketID: InvisibleBucketID, BucketExteriorID: BucketExteriorID,
                              BucketShape: BucketShape) 
        _BucketSize = CGSize(width: _BucketInteriorWidth, height: _BucketInteriorHeight)
        if Scorer == nil
        {
            Scorer = Score(WithID: UUID(), BucketWidth: _BucketInteriorWidth, BucketHeight: _BucketInteriorHeight,
                           BucketBottom: _BucketInteriorBottom, BucketTop: _BucketInteriorTop,
                           Mask: [.GapDelta, .GapCount, .MapCondition, .PieceBlockCount, .PieceBlockLocation, .RowCollapse])
            Scorer!.Annotated = true
        }
    }
    #else
    /// Initialize the map contents and related properties.
    ///
    /// - Note:
    ///   - If `Scorer` is nil, it is initialized here with standard default values.
    ///   - Some **BaseGameTypes** require the dimension of the map to be the same for both **Height** and **Width**.
    ///     If .Rotating4 or .Cubic is specified and **Height** is not equal to **Width**, a fatal error will be thrown.
    ///
    /// - Parameters:
    ///   - Width: Width of the map.
    ///   - Height: Height of the map.
    ///   - BaseType: The base game type.
    private func Initialize(Width: Int, Height: Int, BaseType: BaseGameTypes)
    {
        if BaseType == .Rotating4 || BaseType == .Cubic
        {
            if Width != Height
            {
                fatalError("Width and Height must be the same for .Rotating4 or .Cubic. Width was \(Width) and Height was \(Height).")
            }
        }
        _CurrentRotation = 0
        _BaseGameType = BaseType
        InPlay = [Piece]()
        _CurrentBoardSize = CGSize(width: Width, height: Height)
        _IDMap = PieceIDMap()
        _Contents = MapType.CreateMap(Width: Width, Height: Height, FillWith: IDMap!.StaticID(For: .Visible))
        _BlockMap = MapType.CreateMap(Width: Width, Height: Height, FillWith: UUID.Empty)
        
        switch BaseType
        {
            case .Standard:
                _BucketBottom = Height - 1
                _BucketInteriorBottom = _BucketBottom - 1
                _BucketTop = Height - 21
                _BucketInteriorTop = _BucketTop
                _BucketInteriorLeft = 1
                _BucketInteriorRight = Width - 1 - 1
                _BucketInteriorWidth = (BucketInteriorRight - 1) - (BucketInteriorLeft - 1) - 1
                _BucketInteriorHeight = (BucketBottom - 1) - (BucketTop - 1) - 1
            
            case .Rotating4:
                let BW = 20
                let BH = 20
                _BucketBottom = Height - (BH / 2) + 1
                _BucketInteriorBottom = _BucketBottom
                _BucketTop = (Height / 2) - (BH / 2)
                _BucketInteriorTop = _BucketTop
                _BucketInteriorLeft = (Width - BW) / 2
                _BucketInteriorRight = (Width - _BucketInteriorLeft) - 1
                _BucketInteriorWidth = BW
                _BucketInteriorHeight = BH
                
                _CenterBlockUpperLeft = CGPoint(x: (Width / 2) - 2, y: (Height / 2) - 2)
                _CenterBlockLowerRight = CGPoint(x: (Width / 2) - 2 + 3, y: (Height / 2) - 2 + 3)
                
                #if false
                DebugClient.Send("_BucketBottom=\(_BucketBottom), _BucketInteriorBottom=\(_BucketInteriorBottom)")
                DebugClient.Send("_BucketTop=\(_BucketTop), _BucketInteriorTop=\(_BucketInteriorTop)")
                DebugClient.Send("_BucketInteriorLeft=\(_BucketInteriorLeft)")
                DebugClient.Send("_BucketInteriorRight=\(_BucketInteriorRight)")
                DebugClient.Send("_BucketInteriorWidth=\(_BucketInteriorWidth), _BucketInteriorHeight=\(_BucketInteriorHeight)")
            #endif
            
            case .SemiRotating:
            break
            
            case .Cubic:
                break
        }
        
        let BucketID = IDMap!.StaticID(For: .BucketInterior)
        let InvisibleBucketID = IDMap!.StaticID(For: .InvisibleBucket)
        let BucketExteriorID = IDMap!.StaticID(For: .BucketExterior)
        MapType.InitializeMap(Width: Width, Height: Height,
                              BucketTop: BucketTop, BucketBottom: _BucketBottom, BucketLeft: _BucketInteriorLeft - 1,
                              BucketRight: _BucketInteriorRight + 1, Map: &_Contents,
                              BucketID: BucketID, InvisibleBucketID: InvisibleBucketID, BucketExteriorID: BucketExteriorID,
                              BaseType: BaseType)
        #if false
        print(MapType.PrettyPrint(Map: self))
        #endif
        _BucketSize = CGSize(width: _BucketInteriorWidth, height: _BucketInteriorHeight)
        if Scorer == nil
        {
            Scorer = Score(WithID: UUID(), BucketWidth: _BucketInteriorWidth, BucketHeight: _BucketInteriorHeight,
                           BucketBottom: _BucketInteriorBottom, BucketTop: _BucketInteriorTop,
                           Mask: [.GapDelta, .GapCount, .MapCondition, .PieceBlockCount, .PieceBlockLocation, .RowCollapse])
            Scorer!.Annotated = true
        }
    }
    #endif
    
    private var _BoardClass: BoardClasses = .Static
    public var BoardClass: BoardClasses
    {
        get
        {
            return _BoardClass
        }
    }
    
    private var _BucketShape: BucketShapes = .Classic
    public var BucketShape: BucketShapes
    {
        get
        {
            return _BucketShape
        }
    }
    
    /// Determines if the passed coordinates are out-of-bounds low (eg, below the bottom of the bucket/board).
    /// - Parameter X: The horizontal coordinate to check. Not really used in this function.
    /// - Parameter Y: The vertical coordinate to check.
    /// - Returns: True if the coordinate is below the bounds of the bucket/board, false if not.
    public func OutOfBoundsLow(_ X: Int, _ Y: Int) -> Bool
    {
        switch BoardClass
        {
            case .Static:
                return false
            
            case .Rotatable:
                if Y > BucketBottom
                {
                    return true
                }
                else
                {
                    return false
            }
            
            case .ThreeDimensional:
            return false
        }
    }
    
    /// Returns the starting point for the specified piece. This is where the piece will be placed in the map.
    /// - Note: The piece's location may vary depending on the base game type.
    /// - Parameter ForPiece: The piece that will be dropped.
    /// - Returns: The point where the piece will be placed in the map.
    public func GetPieceStartingPoint(ForPiece: Piece) -> CGPoint
    {
        let BoardDef = BoardManager.GetBoardFor(_BucketShape)!
        #if true
        //Y is always 1 because 0 is occupied by an invisible bucket piece.
        let Y = 1
        let X = (BoardDef.GameBoardWidth / 2) - (ForPiece.Width / 2)
        let InitialPoint = CGPoint(x: X, y: Y)
        //print("InitialPoint=\(InitialPoint)")
        return InitialPoint
        #else
        switch BoardClass
        {
            case .Static:
                let X = GetHorizontalCenter() - ForPiece.Width / 2
//                let Y = BucketTop - ForPiece.MaxComponentDimension - 2
                let Y = ForPiece.MaxComponentDimension + 0
                print(">>>>>> Static start location for \(ForPiece.Shape) is \(X),\(Y)")
                return CGPoint(x: X, y: Y)
            
            case .Rotatable:
                let X = 16
                let Y = BucketTop - ForPiece.MaxComponentDimension - 2
                return CGPoint(x: X, y: Y)
            
            case .ThreeDimensional:
                return CGPoint(x: 0, y: 0)
        }
        #endif
    }
    
    /// Replaces the current scorer in the instance with the passed scoring class instance.
    ///
    /// - Parameter NewScorer: The scoring instance to use in this map class instance.
    func AddScorer(_ NewScorer: Score)
    {
        Scorer = NewScorer
    }
    
    /// Creates a new scoring class instance set up for the current map configuration.
    ///
    /// - Parameter WithID: ID to use for the new scoring instance.
    /// - Returns: New scoring class instance.
    func CreateScorer(_ WithID: UUID = UUID()) -> Score
    {
        let NewScorer = Score(WithID: WithID, BucketWidth: _BucketInteriorWidth,
                              BucketHeight: _BucketInteriorHeight, BucketBottom: _BucketInteriorBottom,
                              BucketTop: _BucketInteriorTop,
                              Mask: [.GapDelta, .GapCount, .MapCondition, .PieceBlockCount, .PieceBlockLocation, .RowCollapse])
        return NewScorer
    }
    
    /// Holds the current board size.
    private var _CurrentBoardSize: CGSize = CGSize.zero
    /// Get the current board size.
    public var CurrentBoardSize: CGSize
    {
        get
        {
            return _CurrentBoardSize
        }
    }
    
    /// Holds the size of the bucket.
    private var _BucketSize: CGSize = CGSize.zero
    /// Get the size of the bucket.
    public var BucketSize: CGSize
    {
        get
        {
            return _BucketSize
        }
    }
    
    /// Holds the current rotation.
    private var _CurrentRotation: Int = 0
    /// Get or set the current rotation.
    public var CurrentRotation: Int
    {
        get
        {
            return _CurrentRotation
        }
        set
        {
            _CurrentRotation = newValue
        }
    }
    
    /// Rotate the contents of the map and the block map 90° left.
    /// - Note: Throws a fatal error if the **Height** and **Width** are not identical.
    public func RotateMapLeft()
    {
        if Width != Height
        {
            fatalError("Unable to rotate map left because dimensions are not identical.")
        }
        CurrentRotation = CurrentRotation - 1
        var ScratchContents = MapType.CreateMap(Width: Width, Height: Height, FillWith: IDMap!.StaticID(For: .Visible))
        var ScratchBlockMap = MapType.CreateMap(Width: Width, Height: Height, FillWith: UUID.Empty)
        for Y in 0 ..< Height
        {
            for X in 0 ..< Width
            {
                ScratchContents[X][Y] = _Contents![Y][Width - X - 1]
                ScratchBlockMap[X][Y] = _BlockMap![Y][Width - X - 1]
            }
        }
        _Contents = ScratchContents
        _BlockMap = ScratchBlockMap
    }
    
    /// Rotate the contents of the map and the block map 90° right.
    /// - Note: Throws a fatal error if the **Height** and **Width** are not identical.
    public func RotateMapRight()
    {
        if Width != Height
        {
            fatalError("Unable to rotate map right because dimensions are not identical.")
        }
        CurrentRotation = CurrentRotation + 1
        var ScratchContents = MapType.CreateMap(Width: Width, Height: Height, FillWith: IDMap!.StaticID(For: .Visible))
        var ScratchBlockMap = MapType.CreateMap(Width: Width, Height: Height, FillWith: UUID.Empty)
        for Y in 0 ..< Height
        {
            for X in 0 ..< Width
            {
                ScratchContents[Y][X] = _Contents![Width - X - 1][Y]
                ScratchBlockMap[Y][X] = _BlockMap![Width - X - 1][Y]
            }
        }
        _Contents = ScratchContents
        _BlockMap = ScratchBlockMap
    }
    
    /// Reset the map to only a bucket with everything else clear. Also resets the ID map and the score.
    public func ResetMap()
    {
        Initialize(Width: Width, Height: Height, BoardBucketShape: BucketShape)
        IDMap?.ClearPieceMap()
        Scorer!.Reset()
        _RetiredPieceShapes.removeAll()
    }
    
    /// Reset the map with a new width and height. The ID map is also reset.
    ///
    /// - Parameters:
    ///   - NewWidth: New map width.
    ///   - NewHeight: New map height.
    public func ResetMap(NewWidth: Int, NewHeight: Int)
    {
        self.Width = NewWidth
        self.Height = NewHeight
        Initialize(Width: NewWidth, Height: NewHeight, BoardBucketShape: BucketShape)
        IDMap?.ClearPieceMap()
        _RetiredPieceShapes.removeAll()
    }
    
    private var _IDMap: PieceIDMap? = nil
    public var IDMap: PieceIDMap?
    {
        get
        {
            return _IDMap
        }
        set
        {
            _IDMap = newValue
        }
    }
    
    /// Holds the ID of the map.
    private var _MapID: UUID = UUID.Empty
    /// Get or set the ID of the map.
    public var MapID: UUID
    {
        get
        {
            return _MapID
        }
        set
        {
            _MapID = newValue
        }
    }
    
    /// Type alias for the map. Given how it is constructed, access needs to be on row/column order (eg, [Y][X]).
    typealias ContentsType = [[UUID]]
    
    /// Holds the contents of the map.
    private var _Contents: ContentsType!
    /// Get or set the map contents.
    /// - Note: **Setting this directly will lead to undefined behavior.**
    public var Contents: ContentsType
    {
        get
        {
            return _Contents
        }
        set
        {
            _Contents = newValue
        }
    }
    
    /// Holds the contents of the block map.
    private var _BlockMap: ContentsType!
    /// Get or set the block map. This is a map of block IDs in the current map.
    /// - Note: **Setting this directly will lead to undefined behavior.**
    public var BlockMap: ContentsType
    {
        get
        {
            return _BlockMap
        }
        set
        {
            _BlockMap = newValue
        }
    }
    
    /// Holds the width of the map.
    private var _Width: Int = 0
    /// Get or set the width of the map. Setting this property directly will result in undefined behavior.
    public var Width: Int
    {
        get
        {
            return _Width
        }
        set
        {
            _Width = newValue
        }
    }
    
    /// Holds the height of the map.
    private var _Height: Int = 0
    /// Get or set the height of the map. Setting this property directly will result in undefined behavior.
    public var Height: Int
    {
        get
        {
            return _Height
        }
        set
        {
            _Height = newValue
        }
    }
    
    /// Holds the vertical coordinate of the bucket interior bottom.
    private var _BucketInteriorBottom: Int = 0
    /// Get or set the vertical coordinate of the bucket interior bottom. This is the lowest occupyable location
    /// in the bucket.
    public var BucketInteriorBottom: Int
    {
        get
        {
            return _BucketInteriorBottom
        }
    }
    
    /// Holds the vertical coordinate of the bucket interior top.
    private var _BucketInteriorTop: Int = 0
    /// Get or set the vertical coordinate of the bucket interior top. This is the highest occupyable location
    /// in the bucket.
    public var BucketInteriorTop: Int
    {
        get
        {
            return _BucketInteriorTop
        }
    }
    
    /// Holds the interior width of the bucket.
    private var _BucketInteriorWidth: Int = 0
    /// Get the interior width of the bucket.
    public var BucketInteriorWidth: Int
    {
        get
        {
            return _BucketInteriorWidth
        }
    }
    
    /// Holds the interior height of the bucket.
    private var _BucketInteriorHeight: Int = 0
    /// Get the interior height of the bucket.
    public var BucketInteriorHeight: Int
    {
        get
        {
            return _BucketInteriorHeight
        }
    }
    
    /// Holds the interior left of the bucket.
    private var _BucketInteriorLeft: Int = 0
    /// Get the interior left of the bucket.
    public var BucketInteriorLeft: Int
    {
        get
        {
            return _BucketInteriorLeft
        }
    }
    
    /// Holds the interior right of the bucket.
    private var _BucketInteriorRight: Int = 0
    /// Get the interior Right of the bucket.
    public var BucketInteriorRight: Int
    {
        get
        {
            return _BucketInteriorRight
        }
    }
    
    /// Holds the top of the bucket.
    private var _BucketTop: Int = 0
    /// Get the top of the bucket.
    public var BucketTop: Int
    {
        get
        {
            return _BucketTop
        }
    }
    
    /// Holds the bottom of the bucket.
    private var _BucketBottom: Int = 0
    /// Get the bottom of the bucket.
    public var BucketBottom: Int
    {
        get
        {
            return _BucketBottom
        }
    }
    
    /// Holds the upper-left point of the center block in bucket units.
    private var _CenterBlockUpperLeft: CGPoint = CGPoint.zero
    /// Get the upper-left point of the center block in bucket units.
    /// - Note: This is valid only when the base game is **.Rotating4**.
    public var CenterBlockUpperLeft: CGPoint
    {
        get
        {
            return _CenterBlockUpperLeft
        }
    }
    
    /// Holds the lower-right point of the center block in bucket units.
    private var _CenterBlockLowerRight: CGPoint = CGPoint.zero
    /// Get the lower-right point of the center block in bucket units.
    /// - Note: This is valid only when the base game is **.Rotating4**.
    public var CenterBlockLowerRight: CGPoint
    {
        get
        {
            return _CenterBlockLowerRight
        }
    }
    
    // MARK: Utility functions.
    
    /// Determines if a block can occupy the passed point.
    ///
    /// - Parameter At: The point to check for emptiness.
    /// - Returns: True if the specified point is empty, false if not.
    func MapIsEmpty(At: CGPoint) -> Bool
    {
        if At.x < 0.0 || At.y < 0.0
        {
            return false
        }
        let YCount = Contents.count
        let XCount = Contents[0].count
        if Int(At.x) >= XCount || Int(At.y) >= YCount
        {
            return false
        }
        let ID = Contents[Int(At.y)][Int(At.x)]
        return IDMap!.IsEmptyType(ID)
    }
    
    /// Determines if a block can occupy the passed point.
    /// - Parameters
    ///   - At: The point to check for emptiness.
    ///   - BlockedBy: Returns the piece that is blocking the block.
    /// - Returns: True if the specified point is empty, false if not.
    func MapIsEmpty(At: CGPoint, BlockedBy: inout PieceTypes) -> Bool
    {
        if At.x < 0.0 || At.y < 0.0
        {
            return false
        }
        let YCount = Contents.count
        let XCount = Contents[0].count
        if Int(At.x) >= XCount || Int(At.y) >= YCount
        {
            return false
        }
        let ID = Contents[Int(At.y)][Int(At.x)]
        BlockedBy = IDMap!.IDtoPiece(ID)!
        return IDMap!.IsEmptyType(ID)
    }
    
    /// Determines if the piece is fully in bounds. Call only after the piece is frozen.
    ///
    /// - Parameter ThePiece: The piece to check for in-boundedness.
    /// - Returns: True if the piece is fully in bounds (eg, in the bucket), false otherwise.
    func PieceInBounds(_ ThePiece: Piece) -> Bool
    {
        let BoardDef = BoardManager.GetBoardFor(_BucketShape)
        #if true
                var IsInBounds = true
        for Point in ThePiece.Locations
        {
            if Point.X < BoardDef!.BucketX || Point.X > BoardDef!.BucketX + BoardDef!.BucketWidth - 1
            {
                IsInBounds = false
            }
            if Point.Y < BoardDef!.BucketY || Point.Y > BoardDef!.BucketY + BoardDef!.BucketHeight - 1
            {
                IsInBounds = false
            }
            if !IsInBounds
            {
                break
            }
        }
        #else
        let Offset: Int = BoardDef!.BucketY
        var IsInBounds = true
        for Point in ThePiece.Locations
        {
            print("Piece in bounds checking Y=\(Point.Y) < BucketTop=\(BucketTop) - Offset=\(Offset) {\(BucketTop - Offset)}")
            if Point.Y < BucketTop - Offset
            {
                IsInBounds = false
                break
            }
        }
        #endif
        Scorer?.ScoreLocations(ThePiece.LocationsAsPoints())
        return IsInBounds
    }
    
    /// Returns the Y value closest to the top of the bucket (eg, bucket entrance) for each column in the bucket.
    /// - Note: If there are no retired game pieces (or bucket parts) in a given column, the column's returned
    ///         value will be -1.
    /// - Returns: Dictionary of columns and highest occupied locations, eg, [Column: Row].
    public func HighestOccupiedLocations() -> [Int: Int]
    {
        var Results = [Int: Int]()
        for X in BucketInteriorLeft ... BucketInteriorRight
        {
            Results[X] = -1
            for Y in BucketTop ... BucketBottom
            {
                if IDMap!.IsOccupiedType(Contents[Y][X])
                {
                    Results[X] = Y
                    break
                }
            }
        }
        return Results
    }
    
    /// Combines the list of in-play pieces with the current map contents and returns the result.
    ///
    /// - Parameters:
    ///   - Excluding: If specified, the in-play piece to exclude from being combined into the result.
    /// - Returns: New `ContentsType` combining the existing contents of this instance with the passed set of in-play pieces.
    func MergeMap(Excluding: UUID? = nil) -> ContentsType
    {
        var Merged = MapType.CreateMap(Width: Width, Height: Height, FillWith: IDMap!.StaticID(For: .Visible))
        for Y in 0 ..< Merged.count
        {
            for X in 0 ..< Merged[0].count
            {
                Merged[Y][X] = Contents[Y][X]
            }
        }
        for SomePiece in InPlay
        {
            if Excluding != nil
            {
                if SomePiece?.ID == Excluding!
                {
                    continue
                }
            }
            for SomeBlock in (SomePiece?.CurrentLocations())!
            {
                Merged[SomeBlock.Y][SomeBlock.X] = SomePiece!.ID
            }
        }
        return Merged
    }
    
    /// Combines all in-play pieces with the block map and returns the result.
    /// - Returns: Current block map merged with in-play pieces.
    func MergedBlockMap() -> ContentsType
    {
        var Merged = MapType.CreateMap(Width: Width, Height: Height, FillWith: UUID.Empty)
        for Y in 0 ..< Merged.count
        {
            for X in 0 ..< Merged[0].count
            {
                Merged[Y][X] = BlockMap[Y][X]
            }
        }
        for SomePiece in InPlay
        {
            for SomeBlock in (SomePiece?.CurrentLocations())!
            {
                Merged[SomeBlock.Y][SomeBlock.X] = SomeBlock.ID
            }
        }
        return Merged
    }
    
    /// Merge a piece in its final location to the contents of the map.
    /// - Parameters:
    ///   - Retired: The piece to merge.
    func MergePieceWithMap(Retired: Piece)
    {
        IDMap!.ChangeType(For: Retired.ID, ToType: .RetiredGamePiece)
        for Block in Retired.CurrentLocations()
        {
            Contents[Int(Block.Y)][Int(Block.X)] = Retired.ID
            BlockMap[Int(Block.Y)][Int(Block.X)] = Block.ID
        }
        let PieceID = Retired.ID
        DeleteInPlayPiece(PieceID)
    }
    
    /// Delete the piece from the map. Used basically when pieces go too far out of bounds in certain game types.
    /// - Parameter: DeleteMe: The peice to delete.
    func DeletePiece(_ DeleteMe: Piece)
    {
        IDMap!.RemoveID(DeleteMe.ID)
        let PieceID = DeleteMe.ID
        DeleteInPlayPiece(PieceID)
    }
    
    /// Holds a dictionary of piece IDs to piece shapes.
    private var _RetiredPieceShapes = [UUID: UUID]()
    /// Get a dictionary of piece IDs to piece shapes. Bucket pieces are not in this
    /// dictionary.
    public var RetiredPieceShapes: [UUID: UUID]
    {
        get
        {
            return _RetiredPieceShapes
        }
        set
        {
            _RetiredPieceShapes = newValue
        }
    }
    
    // MARK: - AI-related routines.
    
    /// Determines if there are any objects in the map that can stop a piece from moving in a given column.
    /// - Note:
    ///   - Determination starts at the top of the bucket and continues to the bottom of the bucket.
    ///   - Useful for **.Rotating4** base games. **.Standard** base games probably shouldn't call this function as
    ///     nothing useful will be returned.
    /// - Parameter Column: The column to check.
    /// - Returns: True if the specified column is bottomless (eg, empty), false if something is in the column that
    ///            can stop a piece from moving (such as a retired block or a bucket).
    func ColumnIsBottomless(_ Column: Int) -> Bool
    {
        for Y in BucketInteriorTop ... BucketInteriorBottom
        {
            let MapObject = IDMap!.IDtoPiece(Contents[Y][Column])
            if [.RetiredGamePiece, .Bucket].contains(MapObject)
            {
                return false
            }
        }
        return true
    }
    
    /// Determines if the entire span of the bucket, in the map's current orientation, is blocked, eg, there are no
    /// bottomless columns.
    /// - Note: This value may change depending on the orientation/rotation of the map.
    /// - Returns: True if the entire span of the bucket is blocked, false if not.
    func BucketSpanIsBlocked() -> Bool
    {
        for X in 0 ... BucketInteriorWidth - 1
        {
            if ColumnIsBottomless(X)
            {
                return false
            }
        }
        return true
    }
    
    /// Merges a set of points into the map.
    ///
    /// - Note: For use **only** by the AI. This function does **not** manage the currently playing piece list or the
    ///         piece ID map. **Unless you are the AI code, do not call this function.**
    ///
    /// - Parameters:
    ///   - Points: List of points to merge with the map.
    ///   - WithTypeID: The value of the point to set.
    func MergePointsWithMap(Points: [CGPoint], WithTypeID: UUID)
    {
        for Point in Points
        {
            Contents[Int(Point.y)][Int(Point.x)] = WithTypeID
        }
    }
    
    // MARK: - Full row deletion.
    
    /// Move an item in the map from one location to another, replacing it with the specified ID.
    /// - Note: Both the contents and the block map are updated. The block map source location is
    ///         replaced with UUID.Empty.
    /// - Parameters:
    ///   - FromX: From X location.
    ///   - FromY: From Y location.
    ///   - ToX: To X location.
    ///   - ToY: To Y location.
    ///   - ReplaceWith: What the source location will hold after the move. Ths is the replacement
    ///                  for the Contents map, **not** the block map.
    func MoveItem(FromX: Int, FromY: Int, ToX: Int, ToY: Int, ReplaceWith: UUID)
    {
        Contents[ToY][ToX] = Contents[FromY][FromX]
        Contents[FromY][FromX] = ReplaceWith
        BlockMap[ToY][ToX] = BlockMap[FromY][FromX]
        BlockMap[FromY][FromX] = UUID.Empty
    }
    
    /// Move all blocks into their ground state. Operates column by column and only affects
    /// blocks that have previously frozen into the bucket.
    ///
    /// - Parameter At: Where the row was removed (eg, the row index).
    func SlideBlocksDown(_ At: Int)
    {
        for X in BucketInteriorLeft ... BucketInteriorRight
        {
            var Bottom: Int = At + 1
            for Under in stride(from: At + 1, to: BucketBottom, by: -1)
            {
                if IDMap!.IDtoPiece(Contents[Under][X]) == .RetiredGamePiece
                {
                    break
                }
                Bottom = Under
            }
            var FoundSomethingAbove = false
            for Over in BucketTop ..< Bottom
            {
                if IDMap!.IDtoPiece(Contents[Over][X]) == .RetiredGamePiece
                {
                    FoundSomethingAbove = true
                    break
                }
            }
            if !FoundSomethingAbove
            {
                continue
            }
            for Y in stride(from: Bottom - 1, to: BucketTop, by: -1)
            {
                MoveItem(FromX: X, FromY: Y - 1, ToX: X, ToY: Y, ReplaceWith: IDMap!.StaticID(For: .Visible))
            }
        }
    }
    
    /// Delete the row at the passed index. Notify the game of the row's deletion.
    ///
    /// - Parameter At: The index of the row to delete.
    /// - Parameter WasHomogeneous: If true, the cleared row was made up of the same type of block. If false
    ///                             the row was made up of various block types.
    func ClearRow(_ At: Int, WasHomogeneous: inout Bool)
    {
        WasHomogeneous = true
        let PieceType = Contents[At][0]
        for X in BucketInteriorLeft ... BucketInteriorRight
        {
            if Contents[At][X] != PieceType
            {
                WasHomogeneous = false
            }
            Contents[At][X] = IDMap!.StaticID(For: .Visible)
            BlockMap[At][X] = UUID.Empty
        }
    }
    
    /// Delete the specified row in the bucket (presumably because it's full). Afterwards, move any blocks to their ground state
    /// if possible.
    ///
    /// - Parameter Row: The row index to delete.
    /// - Parameter WasHomogeneous: If true, the cleared row was made up of the same type of block. If false
    ///                             the row was made up of various block types.
    func DeleteFullRowAt(_ Row: Int, WasHomogeneous: inout Bool)
    {
        ClearRow(Row, WasHomogeneous: &WasHomogeneous)
        SlideBlocksDown(Row)
    }
    
    /// Get a list of all special items in the map and their locations. All special items are reset to .Visible spaces.
    ///
    /// - Returns: List of special items and their locations.
    func GetSpecialItems() -> [(UUID, CGPoint)]
    {
        var ItemList = [(UUID, CGPoint)]()
        for Y in BucketInteriorTop ... BucketInteriorBottom
        {
            for X in BucketInteriorLeft ... BucketInteriorRight
            {
                switch IDMap!.IDtoPiece(Contents[Y][X])!
                {
                    case .Action:
                        ItemList.append((Contents[Y][X], CGPoint(x: X, y: Y)))
                        Contents[Y][X] = IDMap!.StaticID(For: .Visible)
                    
                    case .Danger:
                        ItemList.append((Contents[Y][X], CGPoint(x: X, y: Y)))
                        Contents[Y][X] = IDMap!.StaticID(For: .Visible)
                    
                    default:
                        break
                }
            }
        }
        return ItemList
    }
    
    /// Populate the map with the list of special items. If something already exists in the special item's location, don't
    /// populate it.
    ///
    /// - Parameter ItemList: List of items to populate.
    func ReplaceSpecialItems(ItemList: [(UUID, CGPoint)])
    {
        for (PieceTypeID, Point) in ItemList
        {
            let X: Int = Int(Point.x)
            let Y: Int = Int(Point.y)
            if IDMap!.IsOccupiedType(Contents[Y][X])
            {
                continue
            }
            Contents[Y][X] = PieceTypeID
        }
    }
    
    /// Determines if the bucket has any rows that can be eliminated because they are full.
    ///
    /// - Returns: True if the bucket has full rows, false if not.
    func CanCompress() -> Bool
    {
        #if true
        var FullRowCount = 0
        #if true
        switch BoardClass
        {
            case .Static:
                for Row in stride(from: BucketBottom, to: BucketTop, by: -1)
                {
                    var CanCollapseRow = true
                    for X in BucketInteriorLeft ... BucketInteriorRight
                    {
                        if !IDMap!.IsCollapsibleType(Contents[Row][X])
                        {
                            CanCollapseRow = false
                            break
                        }
                        
                    }
                    FullRowCount = FullRowCount + Int(CanCollapseRow ? 1 : 0)
            }
            
            case .Rotatable:
                let BlockTop = Int(CenterBlockUpperLeft.y)
                for Row in stride(from: BlockTop + 1, to: BucketTop, by: -1)
                {
                    var CanCollapseRow = true
                    for X in BucketInteriorLeft ... BucketInteriorRight
                    {
                        if !IDMap!.IsCollapsibleType(Contents[Row][X])
                        {
                            CanCollapseRow = false
                            break
                        }
                    }
                    FullRowCount = FullRowCount + Int(CanCollapseRow ? 1 : 0)
            }
            
            case .ThreeDimensional:
                return false
        }
        #else
        switch BaseGameType
        {
            case .Standard:
                for Row in stride(from: BucketBottom, to: BucketTop, by: -1)
                {
                    var CanCollapseRow = true
                    for X in BucketInteriorLeft ... BucketInteriorRight
                    {
                        if !IDMap!.IsCollapsibleType(Contents[Row][X])
                        {
                            CanCollapseRow = false
                            break
                        }
                        
                    }
                    FullRowCount = FullRowCount + Int(CanCollapseRow ? 1 : 0)
            }
            
            case .Rotating4:
                let BlockTop = Int(CenterBlockUpperLeft.y)
                for Row in stride(from: BlockTop + 1, to: BucketTop, by: -1)
                {
                    var CanCollapseRow = true
                    for X in BucketInteriorLeft ... BucketInteriorRight
                    {
                        if !IDMap!.IsCollapsibleType(Contents[Row][X])
                        {
                            CanCollapseRow = false
                            break
                        }
                    }
                    FullRowCount = FullRowCount + Int(CanCollapseRow ? 1 : 0)
            }
            
            case .SemiRotating:
            return false
            
            case .Cubic:
                return false
        }
        #endif
        
        return FullRowCount > 0
        #else
        var FullRowCount = 0
        for Row in stride(from: BucketBottom, to: BucketTop, by: -1)
        {
            var FoundGap = false
            for X in BucketInteriorLeft ... BucketInteriorRight
            {
                if IDMap!.IsOccupiedType(Contents[Row][X])
                {
                    FoundGap = true
                }
            }
            if !FoundGap
            {
                FullRowCount = FullRowCount + 1
            }
        }
        return FullRowCount > 0
        #endif
    }
    
    /// Finds and deletes the bottom-most full row in the bucket. Upon each deletion, this function is recursively called
    /// because when a row is deleted, blocks slide down and may fill up rows that were not previously filled up.
    /// - Note:
    ///   - For those games that rotate the board, this function considers the board only in its current
    ///     orientation.
    ///   - Some game types only delete from a position in the middle of the board (such as **.Rotating4**).
    /// - Returns: True if the board was compressed (due to full rows) or false if no change was made.
    @discardableResult func DoDropBottomMostFullRow() -> Bool
    {
        var WasCompressed = false
        var BottomStart = BucketInteriorBottom
        #if true
        if BoardClass == .Rotatable
        {
            BottomStart = Int(CenterBlockUpperLeft.y) + 1
        }
        #else
        if BaseGameType == .Rotating4
        {
            BottomStart = Int(CenterBlockUpperLeft.y) + 1
        }
        #endif
        for Row in stride(from: BottomStart, to: BucketInteriorTop, by: -1)
        {
            var FoundGap = false
            for X in BucketInteriorLeft ... BucketInteriorRight
            {
                if !IDMap!.IsOccupiedType(Contents[Row][X])
                {
                    FoundGap = true
                    break
                }
            }
            if !FoundGap
            {
                var WasHomogeneous = false
                _DidCompress = true
                DeleteFullRowAt(Row, WasHomogeneous: &WasHomogeneous)
                HomogeneousCount = HomogeneousCount + Int(WasHomogeneous ? 1 : 0)
                //Call ourselves recursively because deleting a row causes blocks to move which
                //may fill up more rows under this one.
                DoDropBottomMostFullRow()
                FullRowMap.append(Row)
                WasCompressed = true
            }
        }
        return WasCompressed
    }
    
    /// Holds the number of homogeneous rows deleted.
    var HomogeneousCount = 0
    
    /// Holds a list of locations of full rows in the map.
    private var _FullRowMap = [Int]()
    /// Get or set a list of full rows in the map. Each row is indicated by its vertical coordinate.
    public var FullRowMap: [Int]
    {
        get
        {
            return _FullRowMap
        }
        set
        {
            _FullRowMap = newValue
        }
    }
    
    /// Holds the did compress flag.
    private var _DidCompress: Bool = false
    /// Get or set the flag that indicates the map was compressed due to removal of full rows.
    public var DidCompress: Bool
    {
        get
        {
            return _DidCompress
        }
    }
    
    /// Finds and deletes the bottom-most full row in the bucket. Upon each deletion, this function is recursively called
    /// because when a row is deleted, blocks slide down and may fill up rows that were not previously filled up. Special
    /// items (action and danger) and saved and put back in the same spot (but not on top of moved blocks).
    /// - Note: The which row is the bottom-most row depends on the type of base game. For some games, the bottom-most
    ///         row is actually above the middle of the bucket.
    /// - Returns: True if the board was compressed, false if not.
    func DropBottomMostFullRow() -> Bool
    {
        FullRowMap.removeAll()
        let SpecialItems = GetSpecialItems()
        HomogeneousCount = 0
        let WasCompressed = DoDropBottomMostFullRow()
        if WasCompressed
        {
            Scorer!.ScoreClearedRows(Cleared: FullRowMap, HomogeneousRowCount: HomogeneousCount)
        }
        ReplaceSpecialItems(ItemList: SpecialItems)
        _DidCompress = false
        return WasCompressed
    }
    
    #if false
    /// Remove all specified items from the map.
    ///
    /// - Parameters:
    ///   - Items: List of types of items to remove.
    ///   - ReplaceWith: What the removed items will be replaced with. Must be a type that `PieceIDMap.StaticID` comprehends.
    func RemoveFromMap(_ Items: [PieceTypes], ReplaceWith: PieceTypes = .Visible)
    {
        for Y in 0 ..< Height
        {
            for X in 0 ..< Width
            {
                let TheType = IDMap!.IDtoPiece(Contents[Y][X])!
                if Items.contains(TheType)
                {
                    Contents[Y][X] = IDMap!.StaticID(For: ReplaceWith)
                }
            }
        }
    }
    #endif
    
    /// Remove the item at the specified location.
    ///
    /// - Parameters:
    ///   - Location: The location of the item to remove.
    ///   - ReplaceWith: The new item at the location. Must be a type that `PieceIDMap.StaticID` comprehends.
    func RemoveItemAt(Location: CGPoint, ReplaceWith: PieceTypes = .Visible)
    {
        Contents[Int(Location.y)][Int(Location.x)] = IDMap!.StaticID(For: ReplaceWith)
    }
    
    /// Add the passed item ID to a random location in the contents of the map. Items will be added only to `.Visible` locations.
    ///
    /// - Note:
    ///   - `ItemIDToAdd` is assumed to be a valid ID. No checking is done here.
    ///   - Given the nature of randomness, it's possible no valid location will be found. This function provides a looping mechanism
    ///     to try several times (see `TryCount`). Bear in mind that maps full of retired game pieces will take more tries to find
    ///     an empty location than emptier maps...
    ///
    /// - Parameters:
    ///   - ItemIDToAdd: ID of the item to add. Will be added as is.
    ///   - Pieces: List of in-play pieces (needed so the item isn't placed underneath a running piece).
    ///   - TryCount: Retry count. The function will retry this many times to find a valid (eg, empty) random location.
    /// - Returns: True if the item ID was successfully placed, false if not (because the function tried `TryCount` times without
    ///            randomly selecting an empty location).
    func AddInRandomLocation(ItemIDToAdd: UUID, Pieces: [Piece?], TryCount: Int = 10) -> Bool
    {
        var Merged = MergeMap()
        var Tried = 0
        while true
        {
            let X = Int.random(in: BucketInteriorLeft ... BucketInteriorRight)
            let Y = Int.random(in: BucketTop ... BucketBottom)
            if Merged[Y][X] != IDMap!.StaticID(For: .Visible)
            {
                Tried = Tried + 1
                if Tried > TryCount
                {
                    return false
                }
                continue
            }
            Contents[Y][X] = ItemIDToAdd
            break
        }
        return true
    }
    
    /// Returns the horizontal center of the visible part of the board.
    ///
    /// - Returns: Horizontal center of the visible part of the board.
    func GetHorizontalCenter() -> Int
    {
        return (Width / 2) + 1
    }
    
    /// MARK: Gap finding and related functions. Used mostly by the AI.
    
    /// Returns the shape of a specified region. The shape is the set of offsets along the specified width of the top of the
    /// bucket - this information is used to help with AI scoring.
    ///
    /// - Parameters:
    ///   - StartX: Start of the region. Inclusive.
    ///   - EndX: End of the region. Inclusive.
    /// - Returns: Region offset values for the top-most piece in each column in the region.
    func RegionShape(StartX: Int, EndX: Int) -> [Int]
    {
        var Tops = [Int]()
        var Greatest = -1000
        for X in StartX ... EndX
        {
            let ColumnTop = TopOfColumn(X)
            if ColumnTop > Greatest
            {
                Greatest = ColumnTop
            }
            Tops.append(ColumnTop)
        }
        var RegionOffsets = [Int]()
        for Top in Tops
        {
            RegionOffsets.append(Greatest - Top)
        }
        return RegionOffsets
    }
    
    /// Returns the number of neighbors a point in the bucket has.
    ///
    /// - Note:
    ///   - This function is valid **only** when used on points in the bucket because offsets are used to find the neighbor and
    ///     if a point outside the bucket is specified, it's possible the offset will be outside of the map.
    ///   - Refer to `ValidNeighors` for what is considered a neighbor.
    ///
    /// - Parameters:
    ///   - X: Horizontal location of where to check.
    ///   - Y: Vertical location of where to check.
    /// - Returns: Number of neighbors of the specified point.
    func NeighborCount(_ X: Int, _ Y: Int) -> Int
    {
        var Count = 0
        if IDMap!.IsValidNeighborType(Contents[Y][X - 1])
        {
            Count = Count + 1
        }
        if IDMap!.IsValidNeighborType(Contents[Y][X + 1])
        {
            Count = Count + 1
        }
        if IDMap!.IsValidNeighborType(Contents[Y - 1][X])
        {
            Count = Count + 1
        }
        if IDMap!.IsValidNeighborType(Contents[Y + 1][X])
        {
            Count = Count + 1
        }
        return Count
    }
    
    /// Returns the first row in the specified column that is occupied by a bucket piece (visible or invisible) or retired
    /// game piece.
    ///
    /// - Parameter X: The column whose top-most occupied row is returned.
    /// - Returns: The vertical position of the top-most occupied row. Returned value is in the range of `BucketTop` to
    ///            `BucketBottom`, inclusive.
    func TopOfColumn(_ X: Int) -> Int
    {
        for Y in BucketTop ... BucketBottom
        {
            if IDMap!.IsOccupiedType(Contents[Y][X])
            {
                return Y
            }
        }
        return BucketBottom
    }
    
    /// Return the number of full rows (ready to be removed) with the set of points added to a "test" bucket to see if
    /// the additional points fill up any rows.
    ///
    /// - Parameter WithPoints: Points to "add" to see if any rows fill up as a result.
    /// - Parameter InRows: Will return a list of rows that are full.
    /// - Returns: Number of full rows ready to be removed if the points in `WithPoints` are added.
    func FullRowCount(WithPoints: [CGPoint], InRows: inout [Int]) -> Int
    {
        var TestBucketX = [[PieceTypes]]()
        for Y in 0 ..< Height
        {
            for X in 0 ..< Width
            {
                TestBucketX[Y][X] = IDMap!.IDtoPiece(Contents[Y][X])!
            }
        }
        for Point in WithPoints
        {
            TestBucketX[Int(Point.y)][Int(Point.x)] = .RetiredGamePiece
        }
        var FullCount = 0
        InRows = [Int]()
        for Y in BucketTop ... BucketBottom
        {
            var GapFound = false
            for X in BucketInteriorLeft ... BucketInteriorRight
            {
                if ![.Bucket, .InvisibleBucket, .RetiredGamePiece].contains(TestBucketX[Y][X])
                {
                    GapFound = true
                    break
                }
            }
            if !GapFound
            {
                FullCount = FullCount + 1
            }
            else
            {
                InRows.append(Y)
            }
        }
        return FullCount
    }
    
    /// Return the number of unreachable points in the map.
    ///
    /// - Note: An unreachable point is a point not occupied by any retired (or active) game piece but not reachable from the top
    ///         of the bucket due to being blocked at each cardinal point, or having one or more of its neighbors being blocked
    ///         the same way.
    ///
    /// - Parameter TestPoints: If present, points to add to the reachability map - use for hypothetical piece placement
    ///                         by the AI.
    /// - Parameter Reachable: Number of reachable points in the bucket.
    /// - Parameter Blocked: Number of blocked (eg, something is in it) points in the bucket.
    /// - Returns: Number of unreachable points in the current map.
    func UnreachablePointCount(TestPoints: [CGPoint]? = nil, Reachable: inout Int, Blocked: inout Int) -> Int
    {
        var GapList = [[CGPoint]]()
        ReachableMap(TestPoints: TestPoints, UnreachablePoints: &GapList)
        var Count = 0
        for PointList in GapList
        {
            Count = Count + PointList.count
        }
        Blocked = BlockedPointCount()
        let Total = ((BucketBottom - BucketTop) + 1) * ((BucketInteriorRight - BucketInteriorLeft) + 1)
        Reachable = Total - (Count + Blocked)
        return Count
    }
    
    /// Return a list of groups of points that are unreachable.
    ///
    /// - Parameter TestPoints: If present, points to add to the reachability map.
    /// - Returns: List of unreachable point groups.
    func UnreachablePointList(TestPoints: [CGPoint]? = nil) -> [[CGPoint]]
    {
        var PointList = [[CGPoint]]()
        ReachableMap(TestPoints: TestPoints, UnreachablePoints: &PointList)
        return PointList
    }
    
    /// Return a map of reachable locations (eg, not fully surrounded).
    ///
    /// - Parameter TestPoints: If present, points to prepopulate the reachability map with.
    /// - Parameter UnreachablePoints: List of list of unreachable points.
    /// - Returns: Reachability map.
    @discardableResult func ReachableMap(TestPoints: [CGPoint]? = nil, UnreachablePoints: inout [[CGPoint]]) -> [[ReachableStates]]
    {
        ReachabilityMap = Array(repeating: Array(repeating: ReachableStates.Outside, count: Width), count: Height)
        let Highest = ScanForBlocks(TestPoints)
        var UnreachableGaps = [[CGPoint]]()
        for Y in stride(from: BucketBottom, to: Highest, by: -1)
        {
            for X in BucketInteriorLeft ... BucketInteriorRight
            {
                GapPoints = [CGPoint]()
                HighestFloodFillY = Int.max
                TotalFloodFillDuration = TotalFloodFillDuration + FloodFillFrom(X, Y, HighestY: Highest, With: .Unreachable)
                TotalFloodFillCalls = TotalFloodFillCalls + 1
                if HighestFloodFillY <= Highest
                {
                    TotalFloodFillDuration = TotalFloodFillDuration + FloodFillFrom(X, Y, HighestY: Highest, With: .Reachable)
                    TotalFloodFillCalls = TotalFloodFillCalls + 1
                }
                else
                {
                    if GapPoints!.count > 0
                    {
                        UnreachableGaps.append(GapPoints!)
                    }
                }
            }
        }
        UnreachablePoints = UnreachableGaps
        //print("ReachableMap: MeanFloodFillDuration=\(TotalFloodFillDuration / Double(TotalFloodFillCalls))")
        return ReachabilityMap!
    }
    
    /// Scan the current map for blocks and bucket bits and populate the reachability map as appropriate.
    ///
    /// - Parameter TestPoints: If present, a list of points to populate in the reachability map as occupied. This can be
    ///                         used by the AI to see what the effect of placing a piece is in relation to how many gaps
    ///                         are generated as a result of the placement.
    /// - Returns: The point closest to the top of the bucket that is occupied. This value is used to reduce the amount
    ///            of work that needs to be done by ReachableMap and the flood fill algorithms.
    func ScanForBlocks(_ TestPoints: [CGPoint]? = nil) -> Int
    {
        var HighestY = 10000
        for Y in BucketInteriorTop ... BucketInteriorBottom
        {
            for X in BucketInteriorLeft ... BucketInteriorRight
            {
                if !MapIsEmpty(At: CGPoint(x: X, y: Y))
                {
                    if Y < HighestY
                    {
                        HighestY = Y
                    }
                    ReachabilityMap![Y][X] = .Block
                }
            }
        }
        if let AddPoints = TestPoints
        {
            for Point in AddPoints
            {
                ReachabilityMap![Int(Point.y)][Int(Point.x)] = .Block
            }
        }
        return HighestY
    }
    
    /// Hold the reachability map to determine where the gaps are.
    var ReachabilityMap: [[ReachableStates]]? = nil
    
    /// Total duration of the various flood fill operations. Used for debugging and optimization.
    var TotalFloodFillDuration: Double = 0
    
    /// Total number of flood fill calls. Used for debugging and optimization.
    var TotalFloodFillCalls: Int = 0
    
    /// Performs a flood fill of a special copy of the current map in order to find gaps in the
    /// map that are reachable from the top and not fully enclosed by retired blocks or bits of
    /// the bucket.
    ///
    /// - Parameters:
    ///   - X: Horizontal coordinate of where to start the flood fill.
    ///   - Y: Vertical coordinate of where to start the floor fill.
    ///   - HighestY: Value of the highest (eg, closest to the tofp of the bucket) we are allowed to flood fill.
    ///               This value is used to reduce the amount of flood filling if there are no areas of interest
    ///               higher up in the bucket.
    ///   - With: Value to fill gaps with.
    func DoFloodFillFrom(_ X: Int, _ Y: Int, HighestY: Int, With: ReachableStates)
    {
        if X < BucketInteriorLeft || X > BucketInteriorRight
        {
            return
        }
        if Y < HighestY || Y > BucketBottom
        {
            return
        }
        if !MapIsEmpty(At: CGPoint(x: X, y: Y))
        {
            return
        }
        if ReachabilityMap![Y][X] == With
        {
            return
        }
        ReachabilityMap![Y][X] = With
        GapPoints?.append(CGPoint(x: X, y: Y))
        if Y < HighestFloodFillY
        {
            HighestFloodFillY = Y
        }
        DoFloodFillFrom(X, Y + 1, HighestY: HighestY, With: With)
        DoFloodFillFrom(X, Y - 1, HighestY: HighestY, With: With)
        DoFloodFillFrom(X + 1, Y, HighestY: HighestY, With: With)
        DoFloodFillFrom(X - 1, Y, HighestY: HighestY, With: With)
    }
    
    /// Performs a flood fill of a special copy of the current map in order to find gaps in the
    /// map that are reachable from the top and not fully enclosed by retired blocks or bits of
    /// the bucket. Calls the actual function that does the flood fill.
    ///
    /// - Notes: This function measures the amount of time for each flood fill call.
    ///
    /// - Parameters:
    ///   - X: Horizontal coordinate of where to start the flood fill.
    ///   - Y: Vertical coordinate of where to start the floor fill.
    ///   - HighestY: Value of the highest (eg, closest to the top of the bucket) we are allowed to flood fill.
    ///               This value is used to reduce the amount of flood filling if there are no areas of interest
    ///               higher up in the bucket.
    ///   - With: Value to fill gaps with.
    /// - Returns: The duration of the flood fill (for optimization purposes).
    func FloodFillFrom(_ X: Int, _ Y : Int, HighestY: Int, With: ReachableStates) -> Double
    {
        let Start = CACurrentMediaTime()
        DoFloodFillFrom(X, Y, HighestY: HighestY, With: With)
        let Duration = CACurrentMediaTime() - Start
        return Duration
    }
    
    /// Holds a list of points in a flood fill region.
    var GapPoints: [CGPoint]? = nil
    
    /// Used to determine how close to the bucket top the flood fill resulted.
    var HighestFloodFillY: Int = Int.max
    
    /// Return the total number of blocked (retired game piece, bucket, invisible bucket) in the bucket region of the map.
    ///
    /// - Returns: Number of blocked pieces in the bucket.
    func BlockedPointCount() -> Int
    {
        var Count = 0
        for Y in BucketInteriorTop ... BucketInteriorBottom
        {
            for X in BucketInteriorLeft ... BucketInteriorRight
            {
                Count = Count + Int(IDMap!.IsOccupiedType(Contents[Y][X]) ? 1 : 0)
            }
        }
        return Count
    }
    
    /// Returns the percent the bucket is full of retired pieces.
    /// - Returns: The percent full for the bucket.
    func PercentFull() -> Double
    {
        let Total = (BucketInteriorRight - BucketInteriorLeft + 1) * (BucketInteriorBottom - BucketInteriorTop + 1)
        let Occupied = BlockedPointCount()
        return Double(Occupied) / Double(Total)
    }
    
    // MARK: Subscripting.
    
    /// Subscript operator for access into the map contents. Returns nil if parameters out of range.
    ///
    /// - Note: The order of subscript values is Y, X.
    ///
    /// - Parameters:
    ///   - Y: Vertical location.
    ///   - X: Horizontal location.
    subscript (Y: Int, X: Int) -> UUID?
    {
        get
        {
            if X < 0 || X > Width - 1
            {
                print("X out of range: \(X) not in 0..<\(Width)")
                return nil
            }
            if Y < 0 || Y > Height - 1
            {
                print("Y out of range: \(Y) not in 0..<\(Height)")
                return nil
            }
            return Contents[Y][X]
        }
        set
        {
            if X < 0 || X > Width - 1
            {
                return
            }
            if Y < 0 || Y > Height - 1
            {
                return
            }
            Contents[Y][X] = newValue!
        }
    }
    
    // MARK: Static functions.
    
    /// Create a map.
    ///
    /// - Parameters:
    ///   - Width: Width of the map.
    ///   - Height: Height of the map.
    /// - Returns: New map, all locations initialized to `.Visible.`
    public static func CreateMap(Width: Int, Height: Int, FillWith: UUID) -> ContentsType
    {
        var Map = Array(repeating: Array(repeating: UUID(), count: Width), count: Height)
        for Y in 0 ..< Height
        {
            for X in 0 ..< Width
            {
                Map[Y][X] = FillWith
            }
        }
        return Map
    }
    
    /// Create a block map.
    /// - Parameter Width: Width of the map.
    /// - Parameter Height: Height of the map.
    /// - Parameter FillWith: The ID to fill the map with.
    /// - Returns: New, empty block map.
    public static func CreateBlockMap(Width: Int, Height: Int, FillWith: UUID = UUID.Empty) -> ContentsType
    {
        var Map = Array(repeating: Array(repeating: UUID(), count: Width), count: Height)
        for Y in 0 ..< Height
        {
            for X in 0 ..< Width
            {
                Map[Y][X] = FillWith
            }
        }
        return Map
    }
    
    /// Column headers for showing the board in text format.
    private static let ColumnHeaders = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
                                        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R",
                                        "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j",
                                        "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"]
    
    /// Map of piece type to string for showing the board in text format.
    private static let TextMapping: [PieceTypes: String] =
        [
            .GamePiece: "\u{2592}",
            .RetiredGamePiece: "\u{2593}",
            .Bucket: "\u{2588}",
            .InvisibleBucket: "\u{2395}",
            .Unreachable: "\u{2b59}",
            .Visible: " ",
            .Danger: "©",
            .Action: "",
            .BucketExterior: "·",
    ]
    
    /// Create a string representation of the passed map. Useful for debugging (or running on text-only terminals, should any still
    /// exist).
    ///
    /// - Parameters:
    ///   - Map: The base map that will be dumped as a string.
    ///   - WithInPlayPieces: If true, the in-play pieces will be included in the result.
    ///   - ShowCoordinates: If true, coordinates are displayed. If false, no coordinates are shown.
    /// - Returns: String representation of the contents of `Map`.
    public static func PrettyPrint(Map: MapType, WithInPlayPieces: Bool = true, ShowCoordinates: Bool = true) -> String
    {
        var Final: ContentsType!
        if WithInPlayPieces
        {
            Final = Map.MergeMap()
        }
        else
        {
            Final = Map.Contents
        }
        
        var PrettyMap = ""
        if ShowCoordinates
        {
            PrettyMap = PrettyMap + "    "
            for X in 0 ..< Map.Width
            {
                PrettyMap = PrettyMap + ColumnHeaders[X]
            }
            PrettyMap = PrettyMap + "\n"
        }
        for Y in 0 ..< Map.Height
        {
            if ShowCoordinates
            {
                PrettyMap = PrettyMap + String(format: "%03d", Y) + " "
            }
            for X in 0 ..< Map.Width
            {
                let MapTypeID = Final![Y][X]
                let MapTypePiece = Map.IDMap!.IDtoPiece(MapTypeID)!
                #if true
                var stemp = ""
                switch MapTypePiece
                {
                    case .Bucket:
                    stemp = "∏"
                    case .InvisibleBucket:
                    stemp = "•"
                    case .BucketExterior:
                    stemp = "·"
                    case .Visible:
                    stemp = " "
                    default:
                    stemp = ""
                }
                PrettyMap = PrettyMap + stemp
                #else
                PrettyMap = PrettyMap + TextMapping[MapTypePiece]!
                #endif
            }
            if ShowCoordinates
            {
                PrettyMap = PrettyMap + " " + String(format: "%03d", Y)
            }
            PrettyMap = PrettyMap + "\n"
        }
        if ShowCoordinates
        {
            PrettyMap = PrettyMap + "    "
            for X in 0 ..< Map.Width
            {
                PrettyMap = PrettyMap + ColumnHeaders[X]
            }
            PrettyMap = PrettyMap + "\n"
        }
        
        return PrettyMap
    }
    
    /// Create a string representation of the block map.
    ///
    /// - Parameters:
    ///   - Map: The base map that will be dumped as a string.
    ///   - WithInPlayPieces: If true, the in-play pieces will be included in the result.
    ///   - ShowCoordinates: If true, coordinates are displayed. If false, no coordinates are shown.
    /// - Returns: String representation of the contents of `Map`.
    public static func PrettyBlockPrint(Map: MapType, WithInPlayPieces: Bool = true, ShowCoordinates: Bool = true) -> String
    {
        var Final: ContentsType!
        if WithInPlayPieces
        {
            Final = Map.MergedBlockMap()
        }
        else
        {
            Final = Map.BlockMap
        }
        
        var PrettyMap = ""
        if ShowCoordinates
        {
            PrettyMap = PrettyMap + "    "
            for X in 0 ..< Map.Width
            {
                PrettyMap = PrettyMap + ColumnHeaders[X]
            }
            PrettyMap = PrettyMap + "\n"
        }
        for Y in 0 ..< Map.Height
        {
            if ShowCoordinates
            {
                PrettyMap = PrettyMap + String(format: "%03d", Y) + " "
            }
            for X in 0 ..< Map.Width
            {
                if Final![Y][X] == UUID.Empty
                {
                    PrettyMap = PrettyMap + " "
                }
                else
                {
                    PrettyMap = PrettyMap + ""
                }
            }
            if ShowCoordinates
            {
                PrettyMap = PrettyMap + " " + String(format: "%03d", Y)
            }
            PrettyMap = PrettyMap + "\n"
        }
        if ShowCoordinates
        {
            PrettyMap = PrettyMap + "    "
            for X in 0 ..< Map.Width
            {
                PrettyMap = PrettyMap + ColumnHeaders[X]
            }
        }
        
        return PrettyMap
    }
    
    public var description: String
    {
        get
        {
            return MapType.PrettyPrint(Map: self)
        }
    }
    
    /// Clone the passed map.
    /// -Note: The ID of the new map will be different from the source map.
    /// - Parameter From: The source of the clone.
    /// - Returns: Cloned map.
    public static func Clone(From: MapType) -> MapType
    {
        let NewMap = MapType(Width: From.Width, Height: From.Height, ID: UUID(), BucketShape: From.BucketShape)
        NewMap.Contents = From.Contents
        //NewMap.IDMap = From.IDMap!.Clone()
        return NewMap
    }
}
