//
//  PieceFactory.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/10/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

/// Factory responsible for creating game pieces. A game piece is made of one or more (not necessarily contiguous) blocks.
/// Pieces are defined in an externally-stored file that is read at start-up time. If there is an error reading that file,
/// the game will fail catastrophically.
class PieceFactory
{
    /// Initialize the factory. Pre-load the queue with pieces.
    /// - Parameter: ToEnqueueCount: The number of pieces to initially enqueue. This is also the number of pieces to
    ///              keep enqueued.
    /// - Parameter: Sequence: Game sequence (eg, sequential game number). Used for debugging.
    /// - Parameter: PieceCategories: List of categories from which to draw random pieces.
    init(_ ToEnqueueCount: Int = 3, Sequence: Int, PieceCategories: [MetaPieces])
    {
        _ValidCategories = PieceCategories
        CreatePieceUniverse()
        _GameCount = Sequence
        EnqueueCount = ToEnqueueCount
        PieceQueue = Queue<Piece?>()
    }
    
    /// Deinitialize the factory.
    deinit
    {
        //print("PieceFactory instance deinitialized.")
    }
    
    /// Holds the game count/sequence.
    private var _GameCount: Int = 0
    /// Get the game count/sequence.
    public var GameCount: Int
    {
        get
        {
            return _GameCount
        }
    }
    
    /// Holds the raw enum values for all valid pieces given the current set of piece categories.
    private var PieceUniverse = [String]()
    
    /// Create a list of all known pieces.
    private func CreatePieceUniverse()
    {
        PieceUniverse = [String]()
        for PieceGroup in _ValidCategories
        {
            switch PieceGroup
            {
                case .Standard:
                    for SomePiece in StandardPieces.allCases
                    {
                        PieceUniverse.append(SomePiece.rawValue)
                }
                
                case .NonStandard:
                    for SomePiece in NonStandardPieces.allCases
                    {
                        PieceUniverse.append(SomePiece.rawValue)
                }
                
                case .Big:
                    for SomePiece in BigPieces.allCases
                    {
                        PieceUniverse.append(SomePiece.rawValue)
                }
                
                case .PiecesWithGaps:
                    for SomePiece in PiecesWithGaps.allCases
                    {
                        PieceUniverse.append(SomePiece.rawValue)
                }
                
                case .RandomPieces:
                    for SomePiece in RandomPieces.allCases
                    {
                        PieceUniverse.append(SomePiece.rawValue)
                }
                
                case .Malicious:
                    for SomePiece in MaliciousPieces.allCases
                    {
                        PieceUniverse.append(SomePiece.rawValue)
                }
                
                case .TestPieces:
                    for SomePiece in TestPieces.allCases
                    {
                        PieceUniverse.append(SomePiece.rawValue)
                }
            }
        }
    }
    
    /// Holds the list of valid piece categories set at initialization time.
    private var _ValidCategories: [MetaPieces]!
    /// Get the list of valid piece categories. Not changeable during the instance life-time of the factory.
    public var ValidCategories: [MetaPieces]
    {
        get
        {
            return _ValidCategories
        }
    }
    
    /// The number of enqueued pieces to maintain.
    private var EnqueueCount: Int = 3
    
    /// Enqueued piece queue.
    private var PieceQueue: Queue<Piece?>? = nil
    
    /// Return the contents of the piece queue as an array. Intended for use by the AI.
    ///
    /// - Returns: Array of the contents of the piece queue.
    public func PieceQueueArray() -> [Piece?]
    {
        return (PieceQueue?.AsArray())!
    }
    
    /// Clean up the queue. Terminate any remaining pieces then deallocate them.
    ///
    /// - Note: Call this at each game over event.
    public func CleanUp()
    {
        while PieceQueue!.Count > 0
        {
            var NoLongerNeeded = PieceQueue?.Dequeue()
            NoLongerNeeded??.Terminate()
            NoLongerNeeded = nil
        }
    }
    
    /// Sets the predetermined order of pieces.
    /// - Note: Should not be called in the released version.
    /// - Parameter Enable: If true, the existing piece queue is emptied and a new queue of pieces is added - this new set
    ///                     of pieces is in a predetermined order for testing and debugging purposes. If false, the existing
    ///                     piece queue is cleared and refilled with randomly-selected pieces.
    /// - Parameter WithFirst: The first shape to use in the queue.
    public func SetPredeterminedOrder(_ Enable: Bool, WithFirst: PieceShapes)
    {
        UsePredeterminedOrder = true
        PredeterminedFirst = WithFirst
        CleanUp()
    }
    
    /// Holds the pre-determined first piece. Used for debugging purposes.
    private var PredeterminedFirst: PieceShapes = .T
    /// Holds the use-a-pre-determined-first-piece flag. Used for debugging purposes.
    private var UsePredeterminedOrder = false
    
    /// Return the contents of the queue as a list. The queue is unchanged.
    /// - Returns: List of pieces in the queue.
    public func QueueAsList() -> [Piece]
    {
        var Results = [Piece]()
        for Index in 0 ..< (PieceQueue?.Count)!
        {
            let SomePiece: Piece = (PieceQueue![Index])!!
            Results.append(SomePiece)
        }
        return Results
    }
    
    /// Determines if the top of the queue has a certain number of pieces that are all the same.
    /// - Parameters:
    ///   - MaxSame: The number of pieces that must be the same before triggering the process to remove excess same pieces.
    ///   - SameShape: The piece that was repeated too many times.
    /// - Returns: True if there were `MaxSame` pieces in the queue, false if not.
    func PiecesSameForCount(_ MaxSame: Int, SameShape: inout PieceShapes) -> Bool
    {
        if MaxSame < 1
        {
            return false
        }
        if MaxSame > PieceQueue!.Count
        {
            return false
        }
        let FirstValue: Piece = (PieceQueue![0]!)!
        for Index in 1 ..< MaxSame
        {
            let OtherPiece: Piece = (PieceQueue![Index]!)!
            if OtherPiece.Shape != FirstValue.Shape
            {
                return false
            }
        }
        SameShape = FirstValue.Shape
        return true
    }
    
    /// Return an enqueued piece. Keeps the number of enqueued pieces constant (but the constant can change via the `NewCapacity`
    /// parameter).
    /// - Note: By implication, the queue isn't filled until the first call to return a piece is made.
    /// - Parameter ForBoard: The board where the enqueued piece will be played.
    /// - Parameter NewCapacity: If supplied, sets a new capacity for the queue. If the new capacity is less than the
    ///                          current capacity, nothing is done and the queue is naturally reduced in size. If the new capacity
    ///                          is larger than the current capacity, new pieces are added before the oldest is dequeued.
    /// - Returns: A new, randomly selected (when it was generated) piece.
    public func GetQueuedPiece(ForBoard: Board, NewCapacity: Int? = nil) -> Piece
    {
        if let Capacity = NewCapacity
        {
            EnqueueCount = Capacity
        }
        let MaxSame = Settings.MaximumSamePieces()
        let QDelta = EnqueueCount - PieceQueue!.Count
        if QDelta > 0
        {
            while PieceQueue!.Count < EnqueueCount
            {
                var NotShape: PieceShapes? = nil
                if PieceQueue!.Count >= MaxSame
                {
                    var SameShape: PieceShapes = .Random2x2
                    if PiecesSameForCount(MaxSame, SameShape: &SameShape)
                    {
                        NotShape = SameShape
                    }
                }
                var NewPiece: Piece!
                if UsePredeterminedOrder
                {
                    NewPiece = Create(PredeterminedFirst, WithID: UUID(), ForBoard: ForBoard)
                    UsePredeterminedOrder = false
                }
                else
                {
                    NewPiece = CreateRandom(ForBoard: ForBoard, WithID: UUID(), ButNotShape: NotShape)
                }
                #if false
                AssignAttributes(ToPiece: NewPiece)
                #endif
                PieceQueue?.Enqueue(NewPiece)
            }
        }
        let NewPiece: Piece = (PieceQueue?.Dequeue()!)!
        var NotShape: PieceShapes? = nil
        if PieceQueue!.Count >= MaxSame
        {
            var SameShape: PieceShapes = .Random2x2
            if PiecesSameForCount(MaxSame, SameShape: &SameShape)
            {
                NotShape = SameShape
            }
        }
        let Replacement = CreateRandom(ForBoard: ForBoard, WithID: UUID(), ButNotShape: NotShape)
        #if false
        AssignAttributes(ToPiece: Replacement)
        #endif
        PieceQueue?.Enqueue(Replacement)
        NewPiece.Activated = true
        return NewPiece
    }
    
    /// Returns but does not dequeue the next piece. Used to show the user the next piece after the
    /// current piece.
    /// - Returns: The next piece to dequeue (but not dequeued).
    public func GetNextPiece() -> Piece
    {
        return ((PieceQueue?.DequeuePeek())!)!
    }
    
    /// Returns a shape layer of the component view of the piece. Intended to be used to show the next block
    /// to the user.
    /// - Parameter ForPiece: The piece whose generic view will be returned.
    /// - Parameter UnitSize: The basic size of each block.
    /// - Parameter WithShadow: If true, a shadow is added to the returned layer. Defaults to false.
    /// - Parameter FillColor: The color to use to fill each block. Defaults to white.
    /// - Parameter BorderColor: The color to use to draw the stroke/outline of each block. Defaults to black.
    /// - Parameter BackgroundColor: The color to use to draw the background. Defaults to clear.
    /// - Returns: Shape layer with the generic view of the passed piece.
    public static func GetGenericView(ForPiece: Piece, UnitSize: CGFloat = 32.0, WithShadow: Bool = false,
                                      FillColor: UIColor = UIColor.white, BorderColor: UIColor = UIColor.black,
                                      BackgroundColor: UIColor = UIColor.clear) -> CAShapeLayer
    {
        let Layer = CAShapeLayer()
        let TotalWidth: CGFloat = CGFloat(ForPiece.ComponentWidth)
        let TotalHeight: CGFloat = CGFloat(ForPiece.ComponentHeight)
        Layer.frame = CGRect(x: 0, y: 0, width: TotalWidth * UnitSize, height: TotalHeight * UnitSize)
        let Normalized = ForPiece.NormalizedComponents()
        for Normal in Normalized
        {
            let Square = CAShapeLayer()
            Square.frame = CGRect(x: Normal.x * UnitSize, y: Normal.y * UnitSize, width: UnitSize, height: UnitSize)
            Square.bounds = Square.frame
            Square.backgroundColor = BackgroundColor.cgColor
            let CellRect = Square.frame
            let Corners: CGFloat = UnitSize / 4.0
            let CPath = CGPath(roundedRect: CellRect, cornerWidth: Corners, cornerHeight: Corners, transform: nil)
            Square.fillColor = FillColor.cgColor
            Square.lineWidth = 2.5
            Square.strokeColor = BorderColor.cgColor
            Square.path = CPath
            Layer.addSublayer(Square)
        }
        if WithShadow
        {
            Layer.shadowRadius = 0.0
            Layer.shadowOffset = CGSize(width: 5, height: 5)
            Layer.shadowColor = ColorServer.ColorFrom(ColorNames.Black, WithAlpha: 0.4).cgColor
            Layer.shadowOpacity = 1.0
        }
        return Layer
    }
    
    /// Returns an image of the component view of the piece.
    /// - Note: Calls polymorphic **GetGenericView** to generate a shape layer from which an image is created.
    /// - Parameter ForPiece: The piece whose generic view will be returned.
    /// - Parameter UnitSize: The basic size of each block.
    /// - Parameter WithShadow: If true, a shadow is added to the returned layer. Defaults to false.
    /// - Parameter FillColor: The color to use to fill each block. Defaults to white.
    /// - Parameter BorderColor: The color to use to draw the stroke/outline of each block. Defaults to black.
    /// - Parameter BackgroundColor: The color to use to draw the background. Defaults to clear.
    /// - Returns: Image of the generic view of the passed piece. On error, nil is returned.
    public static func GetGenericView(ForPiece: Piece, UnitSize: CGFloat = 32.0, WithShadow: Bool = false,
                                      FillColor: UIColor = UIColor.white, BorderColor: UIColor = UIColor.black,
                                      BackgroundColor: UIColor = UIColor.clear) -> UIImage?
    {
        let GenericLayer: CAShapeLayer = GetGenericView(ForPiece: ForPiece, UnitSize: UnitSize, WithShadow: WithShadow,
                                                        FillColor: FillColor, BorderColor: BorderColor,
                                                        BackgroundColor: BackgroundColor)
        GenericLayer.isOpaque = false
        GenericLayer.backgroundColor = UIColor.clear.cgColor
        UIGraphicsBeginImageContextWithOptions(CGSize(width: GenericLayer.frame.width, height: GenericLayer.frame.height),
                                               false, UIScreen.main.scale)
        defer{UIGraphicsEndImageContext()}
        guard let Context = UIGraphicsGetCurrentContext() else
        {
            return nil
        }
        GenericLayer.render(in: Context)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    /// Create and return a piece with a randomly selected shape.
    /// - Parameters
    ///    - ForBoard: The board where the block will live.
    ///   - WithID: ID to assign to the new piece.
    ///   - ButNotShape: If present, if the randomly selected shape is this value, it is rejected and another shape
    ///                  is randomly selected until a shape that is not `ButNotShape` is selected.
    /// - Returns: The piece with the randomly selected shape.
    public func CreateRandom(ForBoard: Board, WithID: UUID, ButNotShape: PieceShapes? = nil) -> Piece
    {
        var Shape: PieceShapes!
        while true
        {
            let RandomRaw = PieceUniverse.randomElement()!
            Shape = PieceShapes(rawValue: RandomRaw)
            if let InvalidShape = ButNotShape
            {
                if InvalidShape == Shape
                {
                    continue
                }
                break
            }
            else
            {
                break
            }
        }
        return Create(Shape!, WithID: WithID, ForBoard: ForBoard)
    }
    
    /// Create and return a game piece.
    /// - Note: Game piece definitions are stored in an external file named `PieceDescriptions.xml`. The file is protected by a
    ///         checksum so unauthorized changes probably won't mess things up here. The piece definition file is read at
    ///         start-up and if control reaches here, it's a valid assumption that the piece definition file is intact and contains
    ///         reasonable piece definitions.
    /// - Parameters:
    ///   - PieceShape: The shape of the piece.
    ///   - WithID: The ID to give to the piece.
    ///   - ForBoard: The board where the block will live.
    ///   - Ephemeral: If true, the piece is not intended for use in a game.
    /// - Returns: The newly created piece.
    public func Create(_ PieceShape: PieceShapes, WithID: UUID, ForBoard: Board, Ephemeral: Bool = false) -> Piece
    {
        let SomePiece = Piece(.GamePiece, PieceID: WithID, ForBoard)
        SomePiece.Shape = PieceShape
        SomePiece.ShapeID = PieceFactory.ShapeIDMap[PieceShape]!
        if let Definition = PieceManager.GetPieceDefinitionFor(ID: SomePiece.ShapeID)
        {
            SomePiece.Components = [Block]()
            SomePiece.WideOrientationCount = Definition.WideOrientation
            SomePiece.ThinOrientationCount = Definition.ThinOrientation
            #if false
            if Definition.PieceClass == .Random
            {
                //Generate a random piece here.
                var ValidRange = [Int]()
                var PointCount = 0
                switch Definition.Name
                {
                    case .Random2x2:
                        PointCount = 2
                        ValidRange = ValidRandom2x2Range
                    
                    case .Random3x3:
                        PointCount = 4
                        ValidRange = ValidRandom3x3Range
                    
                    case .Random4x4:
                        PointCount = 6
                        ValidRange = ValidRandom4x4Range
                    
                    default:
                        fatalError("Found unexpected piece type (\(Definition.Name)) in random class.")
                }
                let Points = PieceFactory.RandomLocations(Count: PointCount, Valid: ValidRange)
                var OriginBlock = true
                for Point in Points
                {
                    let NewBlock = Block(Int(Point.x), Int(Point.y), IsOriginBlock: OriginBlock, BlockID: UUID())
                    SomePiece.Components.append(NewBlock)
                    OriginBlock = false
                }
            }
            else
            {
                //Get the points of each block in the piece.
                for LLocation in Definition.LogicalLocations
                {
                    SomePiece.Components.append(Block(LLocation.X, LLocation.Y,
                                                      IsOriginBlock: LLocation.IsOrigin, BlockID: UUID()))
                }
                SomePiece.IsRotationallySymmetric = Definition.RotationallySymmetric
            }
            #else
            for LLocation in Definition.Locations
            {
                SomePiece.Components.append(Block(LLocation.Coordinates.X!, LLocation.Coordinates.Y!,
                                                  IsOriginBlock: LLocation.IsOrigin, BlockID: UUID()))
                SomePiece.IsRotationallySymmetric = Definition.RotationallySymmetric
            }
            #endif
        }
        else
        {
            fatalError("Error - unable to retrieve piece definition for \(WithID.uuidString)")
        }
        
        return SomePiece
    }
    
    /// Create a game piece that is not intended to be used in a game but to be displayed instead.
    /// - Note: Once used to generate a visual, the instance returned by this function should be disposed of.
    /// - Parameter PieceShape: The shape of the piece.
    /// - Returns: The newly created piece.
    public static func CreateEphermeralPiece(_ PieceShape: PieceShapes) -> Piece
    {
        print("Getting ephemeral piece \(PieceShape)")
        let SomePiece = Piece(.GamePiece)
        SomePiece.Shape = PieceShape
        SomePiece.ShapeID = PieceFactory.ShapeIDMap[PieceShape]!
//        if let Definition = MasterPieceList.GetPieceDefinitionFor(ID: SomePiece.ShapeID)
        if let Definition = PieceManager.GetPieceDefinitionFor(ID: SomePiece.ShapeID)
        {
            SomePiece.Components = [Block]()
            SomePiece.WideOrientationCount = Definition.WideOrientation
            SomePiece.ThinOrientationCount = Definition.ThinOrientation
            #if true
            for LLocation in Definition.Locations
            {
                SomePiece.Components.append(Block(LLocation.Coordinates.X!, LLocation.Coordinates.Y!,
                                                  IsOriginBlock: LLocation.IsOrigin, BlockID: UUID()))
                SomePiece.IsRotationallySymmetric = Definition.RotationallySymmetric
            }
            #else
            if Definition.PieceClass == .Random
            {
                //Generate a random piece here.
                var ValidRange = [Int]()
                var PointCount = 0
                switch Definition.Name
                {
                    case .Random2x2:
                        PointCount = 2
                        ValidRange = [0, 1]
                    
                    case .Random3x3:
                        PointCount = 4
                        ValidRange = [-1, 0, 1]
                    
                    case .Random4x4:
                        PointCount = 6
                        ValidRange = [-2, -1, 0, 1]
                    
                    default:
                        fatalError("Found unexpected piece type (\(Definition.Name)) in random class.")
                }
                let Points = RandomLocations(Count: PointCount, Valid: ValidRange)
                var OriginBlock = true
                for Point in Points
                {
                    let NewBlock = Block(Int(Point.x), Int(Point.y), IsOriginBlock: OriginBlock, BlockID: UUID())
                    SomePiece.Components.append(NewBlock)
                    OriginBlock = false
                }
            }
            else
            {
                //Get the points of each block in the piece.
                for LLocation in Definition.LogicalLocations
                {
                    SomePiece.Components.append(Block(LLocation.X, LLocation.Y,
                                                      IsOriginBlock: LLocation.IsOrigin, BlockID: UUID()))
                }
                SomePiece.IsRotationallySymmetric = Definition.RotationallySymmetric
            }
            #endif
        }
        else
        {
            fatalError("Error - unable to retrieve piece definition.")
        }
        
        return SomePiece
    }
    
    /// Valid range for 2x2 random pieces.
    let ValidRandom2x2Range = [0, 1]
    
    /// Valid range for 3x3 random pieces.
    let ValidRandom3x3Range = [-1, 0, 1]
    
    /// Valid range for 4x4 random pieces.
    let ValidRandom4x4Range = [-2, -1, 0, 1]
    
    /// Create a list of random points in 2-space constrained `Valid` in both dimensions. No duplicates
    /// are generated.
    ///
    /// - Parameter Count: Number of random points to return.
    /// - Parameter Valid: List of valid points.
    /// - Returns: List of random points.
    private static func RandomLocations(Count: Int, Valid: [Int]) -> [CGPoint]
    {
        var Results = [CGPoint]()
        while Results.count < Count
        {
            let X = Valid.randomElement()
            let Y = Valid.randomElement()
            for Point in Results
            {
                if Int(Point.x) == X && Int(Point.y) == Y
                {
                    continue
                }
            }
            Results.append(CGPoint(x: Int(X!), y: Int(Y!)))
        }
        if Count == 2
        {
            print("Random2x2=\(Results)")
        }
        return Results
    }
    
    /// Given a shape from any group, return its group.
    /// - Parameter From: The raw value of the enum whose group will be returned.
    /// - Returns: The group associated with the enum whose raw value is passed to us. Nil if not found.
    public static func GetPieceGroup(From: String) -> MetaPieces?
    {
        if StandardPieces(rawValue: From) != nil
        {
            return .Standard
        }
        if NonStandardPieces(rawValue: From) != nil
        {
            return .NonStandard
        }
        if BigPieces(rawValue: From) != nil
        {
            return .Big
        }
        if MaliciousPieces(rawValue: From) != nil
        {
            return .Malicious
        }
        if TestPieces(rawValue: From) != nil
        {
            return .TestPieces
        }
        if RandomPieces(rawValue: From) != nil
        {
            return .RandomPieces
        }
        if PiecesWithGaps(rawValue: From) != nil
        {
            return .PiecesWithGaps
        }
        return nil
    }
    
    /// Map between piece shapes and names.
    public static let PieceNameMap: [PieceShapes: String] =
        [
            //Standard
            .Bar: "Bar",
            .L: "Capital L",
            .backL: "Backwards Capital L",
            .S: "z",
            .Z: "s",
            .Square: "Square",
            .T: "t",
            
            //Non-standard
            .Zig: "Zig",
            .Zag: "Zag",
            .ShortL: "Short L",
            .ShortBackL: "Backwards Short L",
            .C: "Capital C",
            .Plus: "Plus Sign",
            .Corner: "Corner",
            .JoinedSquares: "Two Joined Squares",
            
            //Big
            .Sweeper: "Sweeper",
            .CapitalI: "Capital I",
            .CapitalO: "Capital O",
            .BigBlock3x3: "3x3 Square",
            .BigBlock4x4: "4x4 Square",
            
            //Pieces with gaps
            .EmptyBox: "Empty Box",
            .lowerI: "Lower-case i",
            .EmptyDiamond: "EmptyDiamond",
            .ParallelLines: "Two Parallel Lines",
            
            //Random pieces
            .Random2x2: "Random 2x2 Block",
            .Random3x3: "Random 3x3 Block",
            .Random4x4: "Random 4x4 Block",
            
            //Malicious pieces
            .Diagonal: "Diagonal Line",
            .LongDiagonal: "Long Diagonal Line",
            .V: "Capital V",
            .X: "Capital X",
            .BigGap: "Piece With Big Gap",
            .LongGap: "Piece With Long Gap",
            .FarApart: "Two Blocks Far Apart"
    ]
    
    /// Return the human-readable name for a specified piece.
    /// - Parameters:
    ///   - MetaPiece: The meta-piece group.
    ///   - PieceRawValue: The raw value of the piece.
    /// - Returns: Name of the piece.
    public static func GetPieceName(MetaPiece: MetaPieces, PieceRawValue: String) -> String
    {
        switch MetaPiece
        {
            case .Standard:
                let SomePiece = StandardPieces(rawValue: PieceRawValue)
                switch SomePiece!
                {
                    case .Bar:
                        return "Bar"
                    
                    case .L:
                        return "L"
                    
                    case .BackL:
                        return "Reversed L"
                    
                    case .S:
                        return "S"
                    
                    case .Z:
                        return "Z"
                    
                    case .Square:
                        return "Square"
                    
                    case .T:
                        return "T"
            }
            
            case .NonStandard:
                let SomePiece = NonStandardPieces(rawValue: PieceRawValue)
                switch SomePiece!
                {
                    case .Zig:
                        return "Zig"
                    
                    case .Zag:
                        return "Zag"
                    
                    case .ShortL:
                        return "Short L"
                    
                    case .ShortBackL:
                        return "Short back L"
                    
                    case .C:
                        return "C"
                    
                    case .Plus:
                        return "+"
                    
                    case .Corner:
                        return "Corner"
                    
                    case .JoinedSquares:
                        return "Joined Squares"
            }
            
            case .Big:
                let SomePiece = BigPieces(rawValue: PieceRawValue)
                switch SomePiece!
                {
                    case .Sweeper:
                        return "Sweeper"
                    
                    case .CapitalI:
                        return "Capital I"
                    
                    case .CapitalO:
                        return "Capital O"
                    
                    case .BigBlock3x3:
                        return "3x3 Block"
                    
                    case .BigBlock4x4:
                        return "4x4 Block"
            }
            
            case .PiecesWithGaps:
                let SomePiece = PiecesWithGaps(rawValue: PieceRawValue)
                switch SomePiece!
                {
                    case .EmptyBox:
                        return "Empty Box"
                    
                    case .LowerI:
                        return "Lowercase i"
                    
                    case .EmptyDiamond:
                        return "Empty Diamond"
                    
                    case .ParallelLines:
                        return "Parallel Lines"
            }
            
            case .RandomPieces:
                let SomePiece = RandomPieces(rawValue: PieceRawValue)
                switch SomePiece!
                {
                    case .Random4x4:
                        return "Random 4x4"
                    
                    case .Random3x3:
                        return "Random 3x3"
                    
                    case .Random2x2:
                        return "Random 2x2"
            }
            
            case .Malicious:
                let SomePiece = MaliciousPieces(rawValue: PieceRawValue)
                switch SomePiece!
                {
                    case .Diagonal:
                        return "Diagonal Line"
                    
                    case .X:
                        return "X"
                    
                    case .BigGap:
                        return "Large Box"
                    
                    case .LongGap:
                        return "Long Box"
                    
                    case .LongDiagonal:
                        return "Long Diagonal Line"
                    
                    case .V:
                        return "V"
                    
                    case .FarApart:
                        return "Far Apart"
            }
            
            case .TestPieces:
                let SomePiece = TestPieces(rawValue: PieceRawValue)
                switch SomePiece!
                {
                    case .Test1x1:
                        return "1x1 block"
                    
                    case .Test2x2:
                        return "2x2 block"
                    
                    case .Test3x3:
                        return "3x3 block"
            }
        }
    }
    
    /// Map of meta-pieces to individual pieces in each meta-piece group.
    static let MetaPieceMap: [MetaPieces: [PieceShapes]] =
        [
            .Standard: [.Bar, .Square, .S, .Z, .T, .L, .backL],
            .NonStandard: [.Zig, .Zag, .ShortL, .ShortBackL, .C, .Plus, .Corner, .JoinedSquares],
            .PiecesWithGaps: [.EmptyBox, .lowerI, .EmptyDiamond, .ParallelLines],
            .Malicious: [.Diagonal, .X, .BigGap, .LongGap, .LongDiagonal, .V, .FarApart],
            .Big: [.Sweeper, .CapitalI, .CapitalO, .BigBlock3x3, .BigBlock4x4],
            .RandomPieces: [.Random2x2, .Random3x3, .Random4x4]
    ]
    
    /// Given a shape, return its meta-shape group.
    /// - Parameter Shape: The shape whose meta-shape will be returned.
    /// - Returns: The meta-shape group for the passed shape. If the shape was not found, nil is returned.
    public static func GetMetaPieceFromShape(_ Shape: PieceShapes) -> MetaPieces?
    {
        for (Meta, Shapes) in MetaPieceMap
        {
            for SomeShape in Shapes
            {
                if SomeShape == Shape
                {
                    return Meta
                }
            }
        }
        return nil
    }
    
    /// Given a piece ID, return it's shape enum.
    /// - Parameter ID: ID of the shape.
    /// - Returns: The shape enum that corresponds to the passed ID. Nil if not found.
    public static func GetShapeForPiece(ID: UUID) -> PieceShapes?
    {
        for (Shape, ShapeID) in ShapeIDMap
        {
            if ShapeID == ID
            {
                return Shape
            }
        }
        return nil
    }
    
    /// Map between piece shapes and piece IDs.
    static let ShapeIDMap: [PieceShapes: UUID] =
        [
            PieceShapes.Bar: UUID(uuidString: "f4510cca-262a-4018-bf29-04d703702d65")!,
            PieceShapes.Square: UUID(uuidString: "b5bb59a5-b006-487b-a7b1-e0daf4a48810")!,
            PieceShapes.S: UUID(uuidString: "05463ade-1996-49e0-aae9-55cad6f8f605")!,
            PieceShapes.Z: UUID(uuidString: "0f2709f0-b5ed-4ed9-b8c5-d65a1e1d69e8")!,
            PieceShapes.T: UUID(uuidString: "26e5dee4-0cc5-492f-ab31-b5b810863bf4")!,
            PieceShapes.L: UUID(uuidString: "69cc6259-93f2-438d-8a9f-e0e65ad6c841")!,
            PieceShapes.backL: UUID(uuidString: "7c73c10c-86b3-406d-964e-f12abbf914cc")!,
            //Non-standard, gapless pieces.
            PieceShapes.Zig: UUID(uuidString: "70b8f7ab-cd14-4f1a-a709-91bcfe24f3ab")!,
            PieceShapes.Zag: UUID(uuidString: "85041a61-7d17-4434-a990-a033f38f34e0")!,
            PieceShapes.ShortL: UUID(uuidString: "3ff7a6e9-21b4-4afc-b5ee-0ed4e6a63f1e")!,
            PieceShapes.ShortBackL: UUID(uuidString: "35d6b1f9-b921-4d7f-8448-66b179b2ab7f")!,
            PieceShapes.C: UUID(uuidString: "49bf8a5b-6570-4456-90c8-2924811a6e59")!,
            PieceShapes.Plus: UUID(uuidString: "dec6e2c4-ff38-454a-ac56-dbe789267060")!,
            PieceShapes.Corner: UUID(uuidString: "09cbb902-d875-4337-8756-3e58bf408491")!,
            PieceShapes.JoinedSquares: UUID(uuidString: "2284f6ce-34c3-49de-b187-ba1220a0ac6f")!,
            //Non-standard, pieces with gaps
            PieceShapes.EmptyBox: UUID(uuidString: "88312d0c-73c1-4220-b91c-4d77e05236b1")!,
            PieceShapes.lowerI: UUID(uuidString: "b69d3279-2e29-4eb1-924a-2e09187c21f9")!,
            PieceShapes.EmptyDiamond: UUID(uuidString: "99d6c473-36b5-4504-b6e4-faece29fbe28")!,
            PieceShapes.ParallelLines: UUID(uuidString: "1b9fe0f0-9157-46da-b462-5222643bb1f7")!,
            //Big pieces
            PieceShapes.Sweeper: UUID(uuidString: "97b5a353-acfa-43dc-9deb-7c8aa0f32000")!,
            PieceShapes.CapitalI: UUID(uuidString: "c540885c-1b60-4577-af7b-f5d309e73d84")!,
            PieceShapes.CapitalO: UUID(uuidString: "0e7135e2-6bf7-457d-add4-63a0f1b57560")!,
            PieceShapes.BigBlock3x3: UUID(uuidString: "936170f5-1300-4553-ada8-141bdfb4d85f")!,
            PieceShapes.BigBlock4x4: UUID(uuidString: "494c7a96-060d-4c81-8f9a-609ae0e71a5e")!,
            //Randomly generated pieces.
            PieceShapes.Random4x4: UUID(uuidString: "268dcdc3-9067-46d2-818a-0b118e7ff08b")!,
            PieceShapes.Random3x3: UUID(uuidString: "1c669225-6cc8-4ad5-b128-86452f613ac9")!,
            PieceShapes.Random2x2: UUID(uuidString: "cc51e58c-c4d5-4a22-afa0-f8cbb80a4c6e")!,
            //Malicious pieces.
            PieceShapes.Diagonal: UUID(uuidString: "63285186-a589-4185-acd6-1e6e8c1368ed")!,
            PieceShapes.X: UUID(uuidString: "8ef520af-17e0-4011-8579-a92a9d520c5a")!,
            PieceShapes.BigGap: UUID(uuidString: "007c0348-e287-43cc-8901-bfce604f796b")!,
            PieceShapes.LongGap: UUID(uuidString: "742b73be-56ad-4f36-903c-dbd160428d96")!,
            PieceShapes.LongDiagonal: UUID(uuidString: "5d87accc-3edf-4c7f-b226-d83254d499ad")!,
            PieceShapes.V: UUID(uuidString: "4dbea417-4654-459b-9aaf-9bcde56720be")!,
            PieceShapes.FarApart: UUID(uuidString: "6a2b5de2-4336-4927-affa-980a89c061a6")!,
            //Test pieces
            PieceShapes.Test1x1: UUID(uuidString: "a81a0932-52bf-4619-a24b-2f1217d4fe7f")!,
            PieceShapes.Test2x2: UUID(uuidString: "690a5673-7900-4388-ab05-6beaa7bd0369")!,
            PieceShapes.Test3x3: UUID(uuidString: "817130a9-5f47-4887-b04c-c7d3e429d694")!,
    ]
}

/// Piece categories.
/// - Standard: Standard Tetris pieces.
/// - NonStandard: Non-standard but contiguous pieces.
/// - PiecesWithGaps: Pieces with gaps.
/// - RandomPieces: Randomly-formed pieces.
enum MetaPieces: Int, CaseIterable
{
    case Standard = 0
    case NonStandard = 1
    case PiecesWithGaps = 2
    case RandomPieces = 3
    case Malicious = 4
    case Big = 5
    case TestPieces = 6
}

/// Standard Tetris pieces.
/// - Bar: Bar, four blocks long.
/// - Square: 2x2 square.
/// - S: Vaguely "S" shaped.
/// - Z: Vaguely "Z" shaped.
/// - T: Vaguely "T" shaped.
/// - L: "L" shaped.
/// - BackL: Mirrored "L" shaped.
enum StandardPieces: String, CaseIterable
{
    case Bar = "Bar"
    case Square = "Square"
    case S = "S"
    case Z = "Z"
    case T = "T"
    case L = "L"
    case BackL = "backL"
}

/// Pieces with gaps and holes.
/// - EmptyBox: Empty box.
/// - LowerI: Lower-case "i".
/// - O: Capital "O".
/// - ParallelLines: Two parallel lines.
enum PiecesWithGaps: String, CaseIterable
{
    case EmptyBox = "EmptyBox"
    case LowerI = "lowerI"
    case EmptyDiamond = "EmptyDiamond"
    case ParallelLines = "ParallelLines"
}

/// Somewhat reasonable, non-standard pieces.
/// - Zig: Larger "Z" shaped piece.
/// - Zag: Backwards `Zig` piece.
/// - ShortL: Short "L" shaped.
/// - ShortBackL: Backwards short "L" shaped.
/// - C: "C" shaped.
/// - Plus: "+" shaped.
/// - Corner: Corner piece.
/// - JoinedSquares: Two joined, offset squares.
enum NonStandardPieces: String, CaseIterable
{
    case Zig = "Zig"
    case Zag = "Zag"
    case ShortL = "ShortL"
    case ShortBackL = "ShortBackL"
    case C = "C"
    case Plus = "Plus"
    case Corner = "Corner"
    case JoinedSquares = "JoinedSquare"
}

/// Unreasonable large pieces.
/// - Sweeper: Very long bar.
/// - CapitalI: Capital I with serifs.
/// - BigBlock3x3: 3x3 solid block.
/// - BigBlock4x4: 4x4 solid block.
enum BigPieces: String, CaseIterable
{
    case Sweeper = "Sweeper"
    case CapitalI = "CapitalI"
    case CapitalO = "CapitalO"
    case BigBlock3x3 = "BigBlock3x3"
    case BigBlock4x4 = "BigBlock4x4"
}

/// Randomly created pieces.
/// - Random4x4: Randomly assigned blocks in a 4x4 matrix.
/// - Random3x3: Randomly assigned blocks in a 3x3 matrix.
/// - Random2x2: Randomly assigned blocks in a 2x2 matrix.
enum RandomPieces: String, CaseIterable
{
    case Random4x4 = "Random4x4"
    case Random3x3 = "Random3x3"
    case Random2x2 = "Random2x2"
}

/// Malicious pieces designed to be mean.
/// - Diagonal: Long diagonal.
/// - X: Capital "X"
/// - BigGap: Piece with a very large gap.
/// - LongGap: Piece with a very long gap.
/// - LongDiagonal: Very long diagonal.
/// - V: Capital "V".
/// - FarApart: Two blocks far apart from each other.
enum MaliciousPieces: String, CaseIterable
{
    case Diagonal = "Diagonal"
    case X = "X"
    case BigGap = "BigGap"
    case LongGap = "LongGap"
    case LongDiagonal = "LongDiagonal"
    case V = "V"
    case FarApart = "FarApart"
}

/// Test pieces.
/// - Test1x1: 1x1 block, eg, single block.
/// - Test2x2: 2x2 block.
/// - Test3x3: 3x3 block.
enum TestPieces: String, CaseIterable
{
    case Test1x1 = "Test1x1"
    case Test2x2 = "Test2x2"
    case Test3x3 = "Test3x3"
}

/// Piece classes.
/// - **Standard**: Standard game pieces.
/// - **TestPieces**: Pieces used for AI testing. Should not be selectable by the user.
/// - **Malicious**: Malicously-shaped pieces.
/// - **NonStandard**: Non-standard pieces.
/// - **WithGaps**: Pieces with built-in gaps.
/// - **BigPieces**: Really big pieces.
/// - **Random**: Randomly-generated pieces.
/// - **User**: User-designed pieces.
enum PieceClasses: String, CaseIterable
{
    case Standard = "Standard"
    case TestPieces = "TestPieces"
    case Malicious = "Malicious"
    case NonStandard = "NonStandard"
    case WithGaps = "WithGaps"
    case BigPieces = "BigPieces"
    case Random = "Random"
    case User = "User"
}

/// All valid shapes for the game.
/// - **Bar**: 3x1 bar.
/// - **Square**: 2x2 square.
/// - **S**: Square S
/// - **Z**: Square Z
/// - **T**: T
/// - **L**: Forwards L
/// - **backL**: Backwards L
/// - **Zig**: Zig (vaguely Z-shaped)
/// - **Zag**: Zag (vaguely backwards Z-shaped)
/// - **Sweeper**: 4x1 bar
/// - **ShortL**: Short forwards L
/// - **ShortBackL**: Short backwards L
/// - **C**: C
/// - **Plus**: +
/// - **CapitalI**: Upper case I
/// - **CapitalO**" Upper case O
/// - **Corner**: "Corner" piece
/// - **EmptyBox**: Empty box.
/// - **lowerI**: Lower case i
/// - **emptyDiamond**: Empty diamond.
/// - **ParallelLines**: Two 1x3 parallel lines
/// - **Random4x4**: 4 blocks in randomly generated 4x4 space
/// - **Random3x3**: 3 blocks in randomly generated 3x3 space
/// - **Random2x2**: 2 blocks in randomly generated 2x2 space
/// - **Diagonal**: Diagonal line of 3 blocks
/// - **X**: Lower-case x
/// - **BigGap**: Piece with a large gap
/// - **LongGap**: Piece with a long gap
/// - **LongDiagonal**: Diagonal line of 4 blocks
/// - **V**: V
/// - **Test1x1**: Single block test piece
/// - **Test2x2**: Four block test piece
/// - **Test3x3**: Nine block test piece
enum PieceShapes: String, CaseIterable
{
    //Standard Tetris pieces.
    case Bar = "Bar"
    case Square = "Square"
    case S = "S"
    case Z = "Z"
    case T = "T"
    case L = "L"
    case backL = "backL"
    //Non-standard, gapless pieces.
    case Zig = "Zig"
    case Zag = "Zag"
    case ShortL = "ShortL"
    case ShortBackL = "ShortBackL"
    case C = "C"
    case Plus = "Plus"
    case Corner = "Corner"
    case JoinedSquares = "JoinedSquares"
    //Non-standard, pieces with gaps
    case EmptyBox = "EmptyBox"
    case lowerI = "lowerI"
    case EmptyDiamond = "EmptyDiamond"
    case ParallelLines = "ParallelLines"
    //Big pieces
    case Sweeper = "Sweeper"
    case CapitalI = "CapitalI"
    case CapitalO = "CapitalO"
    case BigBlock3x3 = "BigBlock3x3"
    case BigBlock4x4 = "BigBlock4x4"
    //Randomly generated pieces.
    case Random4x4 = "Random4x4"
    case Random3x3 = "Random3x3"
    case Random2x2 = "Random2x2"
    //Malicious pieces.
    case Diagonal = "Diagonal"
    case X = "X"
    case BigGap = "BigGap"
    case LongGap = "LongGap"
    case LongDiagonal = "LongDiagonal"
    case V = "V"
    case FarApart = "FarApart"
    //Test pieces
    case Test1x1 = "Test1x1"
    case Test2x2 = "Test2x2"
    case Test3x3 = "Test3x3"
}
