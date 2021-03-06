//
//  BoardDescriptor2.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Encpasulates the description of a game board.
class BoardDescriptor2
{
    /// Holds the description of the bucket shape.
    public var _BucketShape: BucketShapes = .Empty
    /// Get or set the description of the bucket shape.
    public var BucketShape: BucketShapes
    {
        get
        {
            return _BucketShape
        }
        set
        {
            _BucketShape = newValue
        }
    }
    
    /// Holds the text description of the board.
    public var _TextDescription: String = ""
    /// Get or set the text description of the board.
    public var TextDescription: String
    {
        get
        {
            return _TextDescription
        }
        set
        {
            _TextDescription = newValue
        }
    }
    
    /// Holds the type of AI to use.
    public var _AIType: AITypes = .Rotating
    /// Get or set the AI type for the board.
    public var AIType: AITypes
    {
        get
        {
            return _AIType
        }
        set
        {
            _AIType = newValue
        }
    }
    
    /// Get the width of the game board.
    public var GameBoardWidth: Int
    {
        get
        {
            return MapLines[0].count
        }
    }
    
    /// Get the height of the game board.
    public var GameBoardHeight: Int
    {
        get
        {
            return MapLines.count
        }
    }
    
    /// Returns the size of the game board.
    /// - Returns: CGSize populated with the game board size.
    public func GameBoardSize() -> CGSize
    {
        return CGSize(width: GameBoardWidth, height: GameBoardHeight)
    }
    
    /// Holds the left-side of the bucket.
    private var _BucketX: Int = 5
    /// Get the left side of the bucket.
    public var BucketX: Int
    {
        get
        {
            return _BucketX
        }
    }
    
    /// Holds the top of the bucket.
    private var _BucketY: Int = 5
    /// Get the top of the bucket.
    public var BucketY: Int
    {
        get
        {
            return _BucketY
        }
    }
    
    /// Holds the width of teh bucket.
    private var _BucketWidth: Int = 10
    /// Get the width of the bucket, including barriers.
    public var BucketWidth: Int
    {
        get
        {
            return _BucketWidth
        }
    }
    
    /// Holds the height of the bucket.
    private var _BucketHeight: Int = 20
    /// Get the height of the bucket, including barriers.
    public var BucketHeight: Int
    {
        get
        {
            return _BucketHeight
        }
    }
    
    /// Get the depth of the bucket. Valid only for three-dimensional games. Uses the depth from
    /// the board's `BucketVolume` property.
    /// - Note: If `BucketVolume` is undefined (most likely due to this property being called on a non-three-
    ///         dimensional game), `0` is returned.
    public var BucketDepth: Int
    {
        get
        {
            if BucketVolume == nil
            {
                return 0
            }
            return Int(BucketVolume!.Depth)
        }
    }
    
    /// Returns the upper-left corner of the bucket.
    /// - Returns: CGPoint populated with the upper-left corner of the bucket.
    public func BucketCorner() -> CGPoint
    {
        return CGPoint(x: _BucketX, y: _BucketY)
    }
    
    /// Returns the size of the bucket.
    /// - Returns: CGSize populated with the size of teh bucket.
    public func BucketSize() -> CGSize
    {
        return CGSize(width: _BucketWidth, height: _BucketHeight)
    }
    
    /// Returns the bucket rectangle.
    /// - Returns: CGRect populated with the size and origin of the bucket.
    public func BucketRectangle() -> CGRect
    {
        return CGRect(origin: BucketCorner(), size: BucketSize())
    }
    
    /// Holds the can flip horizontally flag.
    public var _CanFlipHorizontally: Bool = false
    /// Get or set the can flip horizontally capability flag.
    public var CanFlipHorizontally: Bool
    {
        get
        {
            return _CanFlipHorizontally
        }
        set
        {
            _CanFlipHorizontally = newValue
        }
    }
    
    /// Holds the can flip vertically flag.
    public var _CanFlipVertically: Bool = false
    /// Get or set the can flip vertically capability flag.
    public var CanFlipVertically: Bool
    {
        get
        {
            return _CanFlipVertically
        }
        set
        {
            _CanFlipVertically = newValue
        }
    }
    
    /// Holds the bucket rotates flag.
    public var _BucketRotates: Bool = false
    /// Get or set the bucket rotates flag.
    public var BucketRotates: Bool
    {
        get
        {
            return _BucketRotates
        }
        set
        {
            _BucketRotates = newValue
        }
    }
    
    /// Holds the pieces rotate flag.
    public var _PiecesRotate: Bool = false
    /// Get or set the pieces rotate flag.
    public var PiecesRotate: Bool
    {
        get
        {
            return _PiecesRotate
        }
        set
        {
            _PiecesRotate = newValue
        }
    }
    
    /// Holds the left button visible flag.
    public var _LeftButtonVisible: Bool = true
    /// Get or set the left button visible flag.
    public var LeftButtonVisible: Bool
    {
        get
        {
            return _LeftButtonVisible
        }
        set
        {
            _LeftButtonVisible = newValue
        }
    }
    
    /// Holds the right button visible flag.
    public var _RightButtonVisible: Bool = true
    /// Get or set the right button visible flag.
    public var RightButtonVisible: Bool
    {
        get
        {
            return _RightButtonVisible
        }
        set
        {
            _RightButtonVisible = newValue
        }
    }
    
    /// Holds the up button visible flag.
    public var _UpButtonVisible: Bool = true
    /// Get or set the up button visible flag.
    public var UpButtonVisible: Bool
    {
        get
        {
            return _UpButtonVisible
        }
        set
        {
            _UpButtonVisible = newValue
        }
    }
    
    /// Holds the down button visible flag.
    public var _DownButtonVisible: Bool = true
    /// Get or set the down button visible flag.
    public var DownButtonVisible: Bool
    {
        get
        {
            return _DownButtonVisible
        }
        set
        {
            _DownButtonVisible = newValue
        }
    }
    
    /// Holds the drop down button visible flag.
    public var _DropDownButtonVisible: Bool = true
    /// Get or set the drop down button visible flag.
    public var DropDownButtonVisible: Bool
    {
        get
        {
            return _DropDownButtonVisible
        }
        set
        {
            _DropDownButtonVisible = newValue
        }
    }
    
    /// Holds the fly away button visible flag.
    public var _FlyAwayButtonVisible: Bool = true
    /// Get or set the fly away button visible flag.
    public var FlyAwayButtonVisible: Bool
    {
        get
        {
            return _FlyAwayButtonVisible
        }
        set
        {
            _FlyAwayButtonVisible = newValue
        }
    }
    
    /// Holds the rotate left button visible flag.
    public var _RotateLeftButtonVisisble: Bool = true
    /// Get or set the rotate left button visible flag.
    public var RotateLeftButtonVisisble: Bool
    {
        get
        {
            return _RotateLeftButtonVisisble
        }
        set
        {
            _RotateLeftButtonVisisble = newValue
        }
    }
    
    /// Holds the rotate right button visible flag.
    public var _RotateRightButtonVisisble: Bool = true
    /// Get or set the rotate right button visible flag.
    public var RotateRightButtonVisisble: Bool
    {
        get
        {
            return _RotateRightButtonVisisble
        }
        set
        {
            _RotateRightButtonVisisble = newValue
        }
    }
    
    /// Holds the freeze button action.
    public var _FreezeButton: FreezeButtonActions = .Invisible
    /// Get or set the freeze button action.
    public var FreezeButton: FreezeButtonActions
    {
        get
        {
            return _FreezeButton
        }
        set
        {
            _FreezeButton = newValue
        }
    }
    
    public var _ClearUpperLeft: CGPoint = CGPoint.zero
    public var ClearUpperLeft: CGPoint
    {
        get
        {
            return _ClearUpperLeft
        }
        set
        {
            _ClearUpperLeft = newValue
        }
    }
    
    public var _ClearLowerRight: CGPoint = CGPoint.zero
    public var ClearLowerRight: CGPoint
    {
        get
        {
            return _ClearLowerRight
        }
        set
        {
            _ClearLowerRight = newValue
        }
    }
    
    /// Holds the piece's initial location.
    public var _InitialPieceLocation: CGPoint? = nil
    /// Get or set the piece's initial location. If nil, use the board default.
    public var InitialPieceLocation: CGPoint?
    {
        get
        {
            return _InitialPieceLocation
        }
        set
        {
            _InitialPieceLocation = newValue
        }
    }
    
    /// Holds the 3D width.
    public var _Width3D: Int = 0
    /// Get or set the width of the bucket when in .Cubic mode.
    public var Width3D: Int
    {
        get
        {
            return _Width3D
        }
        set
        {
            _Width3D = newValue
        }
    }
    
    /// Holds the 3D height.
    public var _Height3D: Int = 0
    /// Get or set the height of the bucket when in .Cubic mode.
    public var Height3D: Int
    {
        get
        {
            return _Height3D
        }
        set
        {
            _Height3D = newValue
        }
    }
    
    /// Holds the 3D depth.
    public var _Depth3D: Int = 0
    /// Get or set the depth of the bucket when in .Cubic mode.
    public var Depth3D: Int
    {
        get
        {
            return _Depth3D
        }
        set
        {
            _Depth3D = newValue
        }
    }
    
    public var _CenterBlockDefinition: Volume? = nil
    public var CenterBlockDefinition: Volume?
    {
        get
        {
            return _CenterBlockDefinition
        }
        set
        {
            _CenterBlockDefinition = newValue
        }
    }
    
    /// Returns the volume of the bucket of a cubic game. If the game is not cubic, nil is returned.
    public var BucketVolume: Volume?
    {
        get
        {
            if [.Simple3D].contains(_BucketShape)
            {
                return Volume(Width: _Width3D, Height: _Height3D, Depth: _Depth3D)
            }
            return nil
        }
    }
    
    /// Holds the raw board map.
    public var _BoardMap: String = ""
    {
        didSet
        {
            ParseMap(_BoardMap)
        }
    }
    /// Get or set the raw board map.
    public var BoardMap: String
    {
        get
        {
            return _BoardMap
        }
        set
        {
            _BoardMap = newValue
        }
    }
    
    /// Holds lines of map data.
    private var _MapLines: [String] = [String]()
    /// Get or set raw map data.
    /// - Note:
    ///   - The map consists of the content of the <Map> node.
    ///   - Lines that start with numbers are ignored.
    ///   - All text past (and including) the first comma (`,`) is ignored.
    ///   - Maps may consist of one of the following characters:
    ///     - **_** The game board outside of the bucket.
    ///     - **.** The interior of the bucket.
    ///     - **#** Bucket blocks.
    ///     - **!** Invisible blocks
    public var MapLines: [String]
    {
        get
        {
            return _MapLines
        }
        set
        {
            _MapLines = newValue
        }
    }
    
    /// Mapping between raw map characters and board node types.
    let MapCharMap =
    [
        "_": MapNodeTypes.BucketExterior,
        ".": MapNodeTypes.BucketInterior,
        "#": MapNodeTypes.BucketBlock,
        "!": MapNodeTypes.InvisibleBlock
    ]
    
    /// Get the map node type at the specified location in the map.
    /// - Note:
    ///    - Fatal errors are generated if:
    ///      - The X or Y coordinates are negative.
    ///      - The X coordinate is too big.
    ///      - The Y coordinate is too big.
    ///      - The character in the raw map cannot be found in the `MapCharMap` dictionary.
    /// - Parameter X: The horizontal coordinate.
    /// - Parameter Y: The vertical coordinate.
    /// - Returns: The map node type at the specified coordinate.
    public func MapDataAt(X: Int, Y: Int) -> MapNodeTypes
    {
        if MapLines.isEmpty
        {
            fatalError("No map lines available. Function called too early.")
        }
        if X < 0 || Y < 0
        {
            fatalError("Negative coordinate sent to MapDataAt: (\(X),\(Y)).")
        }
        if X > MapLines[0].count - 1
        {
            fatalError("X (\(X)) is too large. Map width is \(MapLines[0].count).")
        }
        if Y > MapLines.count - 1
        {
            fatalError("Y (\(Y)) is too large. Map height is \(MapLines.count).")
        }
        let Line = MapLines[Y]
        let CharIndex = Line.index(Line.startIndex, offsetBy: X)
        let Char = String(Line[CharIndex])
        if let NodeType = MapCharMap[Char]
        {
            return NodeType
        }
        else
        {
            fatalError("Invalid character \(Char) encountered in map.")
        }
    }
    
    /// Parse the game map. Validate the contents.
    /// - Note:
    ///   - Fatal errors occur if:
    ///     - All line sizes are not the same length.
    ///     - Invalid characters found.
    /// - Parameter Map: The map to parse.
    func ParseMap(_ Map: String)
    {
        let Lines = Map.split(separator: "$", omittingEmptySubsequences: true)
        _MapLines.removeAll()
        for Line in Lines
        {
            let Working = String(Line).trimmingCharacters(in: CharacterSet.whitespaces)
            if Working.isEmpty
            {
                continue
            }
            let Initial = String(Working.first!)
            if ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"].contains(Initial)
            {
                continue
            }
            let Parts = Working.split(separator: ",", omittingEmptySubsequences: true)
            let Final = String(Parts[0])
            _MapLines.append(Final)
        }
        for Index in 1 ..< _MapLines.count
        {
            if _MapLines[Index].count != _MapLines[Index - 1].count
            {
                fatalError("Invalid map in \(BucketShape), line \(Index) - all lines must have the same length.")
            }
        }
        var LineIndex = 0
        var LeftMostBucket = Int.max
        var RightMostBucket = -1
        var TopMostBucket = Int.max
        var BottomMostBucket = -1
        for Line in _MapLines
        {
            var CharIndex = 0
            for Char in Line
            {
                if !["_", ".", "#", "!"].contains(String(Char))
                {
                    fatalError("Invalid character (\(String(Char))) found in map \(BucketShape) on line \(LineIndex).")
                }
                if [".", "#"].contains(String(Char))
                {
                    if CharIndex < LeftMostBucket
                    {
                        LeftMostBucket = CharIndex
                    }
                    if CharIndex > RightMostBucket
                    {
                        RightMostBucket = CharIndex
                    }
                    if LineIndex < TopMostBucket
                    {
                        TopMostBucket = LineIndex
                    }
                    if LineIndex > BottomMostBucket
                    {
                        BottomMostBucket = LineIndex
                    }
                }
                CharIndex = CharIndex + 1
            }
            LineIndex = LineIndex + 1
        }
        _BucketX = LeftMostBucket
        _BucketY = TopMostBucket
        _BucketWidth = RightMostBucket - LeftMostBucket + 1
        _BucketHeight = BottomMostBucket - TopMostBucket + 1
    }
    
    /// Holds a list of all bucket block locations in the map. Not populated until `BucketBlockList` is called.
    private var BlockList: [(CGPoint)]? = nil
    
    /// Returns a list of points in the game board where bucket blocks are placed.
    /// - Returns: List of bucket block locations.
    public func BucketBlockList() -> [(CGPoint)]
    {
        //if let CachedList = BlockList
       // {
        //    return CachedList
        //}
        BlockList = [(CGPoint)]()
        for Y in 0 ..< GameBoardHeight
        {
            for X in 0 ..< GameBoardWidth
            {
                if MapDataAt(X: X, Y: Y) == .BucketBlock
                {
                    BlockList!.append(CGPoint(x: X, y: Y))
                }
            }
        }
        return BlockList!
    }
    
    /// Returns a list of points in the game board where invisible blocks are placed. Usually, this type of block
    /// forms the perimeter of the game board but may be placed anywhere.
    /// - Returns: List of invisible block locations.
    public func InvisibleBucketBlockList() -> [(CGPoint)]
    {
        BlockList = [(CGPoint)]()
        for Y in 0 ..< GameBoardHeight
        {
            for X in 0 ..< GameBoardWidth
            {
                if MapDataAt(X: X, Y: Y) == .InvisibleBlock
                {
                    BlockList!.append(CGPoint(x: X, y: Y))
                }
            }
        }
        return BlockList!
    }
}

/// Actions related to the behavior and visibility of the freeze button.
/// - **Visible**: Always visible.
/// - **Invisible**: Always invisible.
/// - **Once**: Visible until the user presses it. After the users presses the button, it becomes invisible.
/// - **Rotations1**: Visible for the first rotation, after which it becomes invisible.
/// - **Rotations2**: Visible for the first two rotations, after which it becomes invisible.
/// - **Rotations3**: Visible for the first three rotations, after which it becomes invisible.
/// - **Rotations4**: Visible for the firt four rotations, after which it becomes invisible.
enum FreezeButtonActions: String, CaseIterable
{
    case Visible = "Visible"
    case Invisible = "Invisible"
    case Once = "Once"
    case Rotations1 = "Rotations1"
    case Rotations2 = "Rotations2"
    case Rotations3 = "Rotations3"
    case Rotations4 = "Rotations4"
}

/// Types of nodes in maps.
/// - **BucketExterior**: Outside of the bucket.
/// - **BucketInterior**: Inside the bucket.
/// - **BucketBlock**: Block that makes up a bucket wall.
/// - **InvisibleBlock**: Block that is invisible.
enum MapNodeTypes: String, CaseIterable
{
    case BucketExterior = "BucketExterior"
    case BucketInterior = "BucketInterior"
    case BucketBlock = "BucketBlock"
    case InvisibleBlock = "InvisibleBlock"
}
