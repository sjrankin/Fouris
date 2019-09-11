//
//  3DView.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/13/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import SceneKit

/// Runs Tetris in a 3D scene, allowing for more options of viewing and confounding the player.
class View3D: SCNView,                          //Our main super class.
    SCNSceneRendererDelegate,                   //To get notifications when a new frame is drawn in order to calculate the frame rate.
    GameViewProtocol,                           //How the UI communicates with a game view.
    ThreeDProtocol,                             //The 3D game protocol.
    SmoothMotionProtocol,                       //Smooth motion protocol.
    TextLayerProtocol                           //Text layer protocol.
{
    /// The scene that is shown in the 3D view.
    var GameScene: SCNScene!
    
    /// Initialize the view.
    /// - Note: Setting 'self.showsStatistics' to true will lead to the scene freezing after a period of time (on the order of
    ///         hours). Likewise, setting `self.allowsCameraControl` will lead to non-responsiveness in the UI after a period
    ///         of time (on the order of tens of minutes). Therefore, using those two properties should be transient and for
    ///         debug use only.
    /// - Parameter With: The board to use for displaying contents.
    /// - Parameter Theme: The ID of the initial theme to use (may be changed via the `SetTheme` function).
    /// - Parameter BaseType: The base game type. Can only be set via this function.
    /// - Parameter CenterType: The shape of the center block for **.Rotating4** games.
    func Initialize(With: Board, Theme: UUID, BaseType: BaseGameTypes, CenterType: CenterShapes = .Square)
    {
        //MasterBlockNode = SCNNode()
        CenterBlockShape = CenterType
        self.rendersContinuously = true
        CreateMasterBlockNode()
        _BaseGameType = BaseType
        SetBoard(With)
        //print("3D Theme: \(Theme.uuidString)")
        CurrentTheme = ThemeManager.ThemeFrom(ID: Theme)
        self.showsStatistics = CurrentTheme!.ShowStatistics
        self.allowsCameraControl = false//CurrentTheme!.CanControlCamera
        OriginalCameraPosition = CurrentTheme!.CameraPosition
        OriginalCameraOrientation = CurrentTheme!.CameraOrientation
        #if false
        self.debugOptions = [.showBoundingBoxes]
        #endif
        GameScene = SCNScene()
        self.delegate = self
        self.isPlaying = true
        self.scene = GameScene
        self.autoenablesDefaultLighting = CurrentTheme!.UseDefaultLighting
        var AAMode: SCNAntialiasingMode = .multisampling2X
        switch CurrentTheme!.AntialiasingMode
        {
            case .None:
                AAMode = .none
            
            case .MultiSampling2X:
                AAMode = .multisampling2X
            
            case .Multisampling4X:
                AAMode = .multisampling4X
            
            default:
                AAMode = .multisampling2X
        }
        self.antialiasingMode = AAMode
        self.scene?.rootNode.addChildNode(MakeCamera())
        
        #if true
        if self.allowsCameraControl
        {
            //https://stackoverflow.com/questions/24768031/can-i-get-the-scnview-camera-position-when-using-allowscameracontrol
            CameraObserver = self.observe(\.pointOfView?.position, options: [.new])
            {
                (Node, Change) in
                OperationQueue.current?.addOperation
                    {
                        let DPos = Convert.ConvertToString(Node.pointOfView!.position, AddLabels: true, AddParentheses: true)
                        let DOri = Convert.ConvertToString(Node.pointOfView!.orientation, AddLabels: true, AddParentheses: true)
                        var KVPMsg = MessageHelper.MakeKVPMessage(ID: self.PositionKVP, Key: "Camera Position", Value: DPos)
                        DebugClient.SendPreformattedCommand(KVPMsg)
                        KVPMsg = MessageHelper.MakeKVPMessage(ID: self.OrientationKVP, Key: "Camera Orientation", Value: DOri)
                        DebugClient.SendPreformattedCommand(KVPMsg)
                }
            }
        }
        #endif
        
        CreateBucket()
        if CurrentTheme!.ShowGrid
        {
            CreateGrid()
        }
        
        LightNode = CreateLight()
        self.scene?.rootNode.addChildNode(LightNode)
        DrawBackground()
        DrawBucketGrid(ShowLines: CurrentTheme!.ShowBucketGrid, IncludingOutline: true)
        OrbitCamera()
        AddPeskyLight()
        PerfTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SendPerformanceData),
                                         userInfo: nil, repeats: true)
    }
    
    var CenterBlockShape: CenterShapes = .Square
    
    /// Holds the base game type.
    private var _BaseGameType: BaseGameTypes = .Standard
    /// Get the current base game type. You should delete the current instance and call **Initialize** on a new instance to
    /// change this.
    public var BaseGameType: BaseGameTypes
    {
        get
        {
            return _BaseGameType
        }
    }
    
    var PerfTimer: Timer? = nil
    @objc func SendPerformanceData()
    {
        let CurrentFPS = FrameRate()!
        Owner?.PerformanceSample(FPS: CurrentFPS)
    }
    
    let OrientationKVP = UUID()
    let PositionKVP = UUID()
    var OriginalCameraOrientation: SCNVector4? = nil
    var OriginalCameraPosition: SCNVector3? = nil
    
    func OrbitCamera()
    {
        #if false
        let RAnim = CABasicAnimation(keyPath: "rotation")
        RAnim.toValue = SCNVector4Make(0,0,1,CGFloat.pi * 2.0)
        RAnim.duration = 10.0
        RAnim.repeatCount = 10000000.0
        CameraNode.addAnimation(RAnim, forKey: "rotation")
        #endif
    }
    
    /// Used by the value observer for the user-controllable camera.
    var CameraObserver: NSKeyValueObservation? = nil
    
    /// Required by framework.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Reference back to the game UI.
    weak var Owner: GameViewRequestProtocol? = nil
    
    /// Use default lighting flag.
    /// - Note: In the future, we won't need this as each theme will contain this flag instead.
    var UseDefaultLighting: Bool = true
    
    /// Holds the camera node.
    var CameraNode: SCNNode!
    
    /// Holds the light node.
    var LightNode: SCNNode!
    
    /// Create the camera using current theme data.
    /// - Returns: Scene node with camera data.
    func MakeCamera() -> SCNNode
    {
        CameraNode = SCNNode()
        CameraNode.name = "GameCamera"
        CameraNode.camera = SCNCamera()
        CameraNode.camera?.usesOrthographicProjection = (CurrentTheme?.IsOrthographic)!
        CameraNode.camera?.orthographicScale = (CurrentTheme?.OrthographicScale)!
        CameraNode.camera?.fieldOfView = CGFloat(CurrentTheme!.CameraFieldOfView)
        CameraNode.position = CurrentTheme!.CameraPosition
        CameraNode.orientation = CurrentTheme!.CameraOrientation
        return CameraNode
    }
    
    /// Draw the background according to the current theme.
    func DrawBackground()
    {
        switch CurrentTheme?.BackgroundType3D
        {
            case .Color:
                GameScene.background.contents = ColorServer.ColorFrom(CurrentTheme!.BackgroundIdentifier3D)
            
            case .Image:
                GameScene.background.contents = ImageServer.GetNamedImage(named: CurrentTheme!.BackgroundIdentifier3D)
            
            case .CALayer:
                break
            
            case .Texture:
                break
            
            case .none:
                break
        }
    }
    
    /// Create the standard light using current theme data.
    /// - Returns: Scene node with light data.
    func CreateLight() -> SCNNode
    {
        let Light = SCNLight()
        let LightColor = ColorServer.ColorFrom(CurrentTheme!.LightColor)
        Light.color = LightColor
        Light.type = CurrentTheme!.LightType
        let Node = SCNNode()
        Node.name = "SceneLight"
        Node.light = Light
        Node.position = CurrentTheme!.LightPosition
        return Node
    }
    
    func AddPeskyLight()
    {
        let Pesky = SCNLight()
        Pesky.color = ColorServer.ColorFrom(ColorNames.YellowNCS)
        Pesky.type = .spot
        let Node = SCNNode()
        Node.name = "PeskyLight"
        Node.position = SCNVector3(5.0, 10.0, 1.0)
        self.scene?.rootNode.addChildNode(Node)
    }
    
    /// Remove specified nodes from the scene. Nodes are removed from `BlockList` as well.
    /// - Parameter WithName: All nodes with this name will be removed.
    func RemoveNodes(WithName: String)
    {
        var KillList = [SCNNode]()
        self.scene?.rootNode.enumerateChildNodes
            {
                (Node, _) in
                if Node.name == WithName
                {
                    KillList.append(Node)
                    //Node.removeFromParentNode()
                }
        }
        for Node in KillList
        {
            //            Node.geometry!.firstMaterial!.normal.contents = nil
            Node.geometry!.firstMaterial!.specular.contents = nil
            Node.geometry!.firstMaterial!.diffuse.contents = nil
            Node.removeAllActions()
            Node.removeFromParentNode()
        }
        BlockList = BlockList.filter({$0.name != WithName})
    }
    
    /// Remove all nodes whose names are in the passed list.
    /// - Note:
    ///   - Any node whose name can be found in **WithNames** will be removed.
    ///   - Calls **RemoveNodes(String)** for each string in **WithNames**.
    /// - Parameter WithNames: The list of names for nodes to be removed.
    func RemoveNodes(WithNames: [String])
    {
        if WithNames.isEmpty
        {
            return
        }
        for Name in WithNames
        {
            RemoveNodes(WithName: Name)
        }
    }
    
    var BucketNode: SCNNode? = nil
    
    /// Create a 3D bucket and add it to the scene. Attributes are from the current theme.
    func CreateBucket()
    {
        if BucketNode != nil
        {
            BucketNode?.removeFromParentNode()
        }
        BucketNode = SCNNode()
        
        switch BaseGameType
        {
            case .Standard:
                let LeftSide = SCNBox(width: 1.0, height: 20.0, length: 1.0, chamferRadius: 0.0)
                LeftSide.materials.first?.diffuse.contents = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
                LeftSide.materials.first?.specular.contents = ColorServer.ColorFrom(ColorNames.White)
                let LeftSideNode = SCNNode(geometry: LeftSide)
                LeftSideNode.position = SCNVector3(-6, 0, 0)
                BucketNode?.addChildNode(LeftSideNode)
                
                let RightSide = SCNBox(width: 1.0, height: 20.0, length: 1.0, chamferRadius: 0.0)
                RightSide.materials.first?.diffuse.contents = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
                RightSide.materials.first?.specular.contents = ColorServer.ColorFrom(ColorNames.White)
                let RightSideNode = SCNNode(geometry: RightSide)
                RightSideNode.position = SCNVector3(5, 0, 0)
                BucketNode?.addChildNode(RightSideNode)
                
                let Bottom = SCNBox(width: 12.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                Bottom.materials.first?.diffuse.contents = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
                Bottom.materials.first?.specular.contents = ColorServer.ColorFrom(ColorNames.White)
                let BottomNode = SCNNode(geometry: Bottom)
                BottomNode.position = SCNVector3(-0.5, -10.5, 0)
                BucketNode?.addChildNode(BottomNode)
            
            case .Rotating4:
                #if true
                DrawCenterBlock(Parent: BucketNode!, InShape: CenterBlockShape)
                #else
                let Center = SCNBox(width: 4.0, height: 4.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
                Center.materials.first?.specular.contents = ColorServer.ColorFrom(ColorNames.White)
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.0, 0.0)
                BucketNode?.addChildNode(CentralNode)
            #endif
            
            case .Cubic:
                let Center = SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
                Center.materials.first?.specular.contents = ColorServer.ColorFrom(ColorNames.White)
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.0, 0.0)
                BucketNode?.addChildNode(CentralNode)
        }
        self.scene?.rootNode.addChildNode(BucketNode!)
        
        _BucketAdded = true
    }
    
    /// Flag indicating the bucket was added. Do we need this in this class?
    var _BucketAdded: Bool = false
    
    /// Create a "line" and return it in a scene node.
    /// - Note: The line is really a very thin box. This makes lines a rather heavy operation.
    /// - Parameter From: Starting point of the line.
    /// - Parameter To: Ending point of the line.
    /// - Parameter Color: Color name to use to color the line.
    /// - Parameter LineWidth: Width of the line - defaults to 0.01.
    /// - Returns: Node with the specified line. The node has the name "GridNodes".
    func MakeLine(From: SCNVector3, To: SCNVector3, Color: ColorNames, LineWidth: CGFloat = 0.01) -> SCNNode
    {

        var Width: Float = 0.01
        var Height: Float = 0.01
        let FinalLineWidth = Float(LineWidth)
        if From.y == To.y
        {
            Width = abs(From.x - To.x)
            Height = FinalLineWidth
        }
        else
        {
            Height = abs(From.y - To.y)
            Width = FinalLineWidth
        }
        let Line = SCNBox(width: CGFloat(Width), height: CGFloat(Height), length: 0.01,
                          chamferRadius: 0.0)
        Line.materials.first?.diffuse.contents = ColorServer.ColorFrom(Color)
        let Node = SCNNode(geometry: Line)
        Node.position = From
        Node.name = "GridNodes"
        return Node
    }
    
    /// Create a grid and place it into the scene.
    func CreateGrid()
    {
        RemoveNodes(WithName: "GridNodes")
        for Y in stride(from: -64.0, to: 128.0, by: 1.0)
        {
            let Start = SCNVector3(-64.5, Y, 0.0)
            let End = SCNVector3(128.5, Y, 0.0)
            let LineNode = MakeLine(From: Start, To: End, Color: ColorNames.White)
            self.scene?.rootNode.addChildNode(LineNode)
        }
        for X in stride(from: -64.5, to: 128.5, by: 1.0)
        {
            let Start = SCNVector3(X, -64.0, 0.0)
            let End = SCNVector3(X, 128.0, 0.0)
            let LineNode = MakeLine(From: Start, To: End, Color: ColorNames.White)
            self.scene?.rootNode.addChildNode(LineNode)
        }
    }
    
    /// Remove the grid from the scene.
    func RemoveGrid()
    {
        RemoveNodes(WithName: "GridNodes")
    }
    
    /// Holds a set of all visual blocks being displayed.
    var BlockList = Set<VisualBlocks3D>()
    
    /// Determines if a block with the specified ID exists in the block list.
    /// - Parameter ID: The ID of the block to determine existences.
    /// - Returns: True if the block exists in the block list, false if not.
    func BlockExistsInList(_ ID: UUID) -> Bool
    {
        for VBlock in BlockList
        {
            if VBlock.ID == ID
            {
                return true
            }
        }
        return false
    }
    
    /// Returns the specified block from the block list.
    /// Parameter ID: The ID of the block to return.
    /// - Returns: The visual block on success, nil if not found.
    func GetBlock(_ ID: UUID) -> VisualBlocks3D?
    {
        for VBlock in BlockList
        {
            if VBlock.ID == ID
            {
                return VBlock
            }
        }
        return nil
    }
    
    /// The delegate for the caller of moving/rotating pieces smoothly.
    weak var SmoothMotionDelegate: SmoothMotionProtocol? = nil
    
    func SmoothMoveCompleted(For: UUID)
    {
        //Not used in this class.
        fatalError("I told you this function shouldn't be called here!")
    }
    
    func SmoothRotationCompleted(For: UUID)
    {
        //Not used in this class.
        fatalError("I told you this function shouldn't be called here!")
    }
    
    /// Called when the game is done moving a piece smoothly, eg, when it freezes into place.
    func DoneWithSmoothPiece(_ ID: UUID)
    {
        if ID != SmoothPieceID
        {
            fatalError("Received unexpected ID (received \(ID), expected \(SmoothPieceID)) in DoneWithSmoothPiece.")
        }
        if SmoothPiece != nil
        {
            SmoothPiece?.removeAllActions()
            SmoothPiece?.removeFromParentNode()
            SmoothPiece = nil
            SmoothPieceID = UUID.Empty
        }
    }
    
    var SmoothPiece: SCNNode? = nil
    var SmoothPieceID: UUID = UUID.Empty
    
    /// Creates a new piece to move smoothly. If a piece already exists, it is deleted first.
    /// - Returns: The ID of the smoothly moving piece.
    func CreateSmoothPiece() -> UUID
    {
        if SmoothPiece != nil
        {
            SmoothPiece?.removeAllActions()
            SmoothPiece?.removeFromParentNode()
            SmoothPiece = nil
        }
        SmoothPieceID = UUID()
        SmoothPiece = SCNNode()
        SmoothPiece?.name = "Smooth Piece"
        self.scene?.rootNode.addChildNode(SmoothPiece!)
        return SmoothPieceID
    }
    
    func MovePieceSmoothly(_ GamePiece: Piece, ToOffsetX: CGFloat, ToOffsetY: CGFloat, Duration: Double)
    {
        if SmoothPiece == nil
        {
            SmoothPiece = SCNNode()
            SmoothPiece?.name = "Smooth Piece"
            self.scene?.rootNode.addChildNode(SmoothPiece!)
        }
        let YOffset = (30 - 10 - 1)
        let XOffset = -6
        for Block in GamePiece.CurrentLocations()
        {
        }
    }
    
    /// Start a piece moving smoothly to the specified location.
    /// - Note: The delegate's `SmoothMoveCompleted` function is called upon completion.
    /// - Parameter GamePiece: The piece to move smoothly.
    /// - Parameter ToOffsetX: Offset horizontal value
    /// - Parameter ToOffsetY: Offset vertical value.
    /// - Parameter Duration: How long to take to move the piece.
    func MovePieceSmoothlyX(_ GamePiece: Piece, ToOffsetX: CGFloat, ToOffsetY: CGFloat, Duration: Double)
    {
        SmoothPieceID = GamePiece.ID
        var BlockIDs = [UUID]()
        for Block in GamePiece.CurrentLocations()
        {
            BlockIDs.append(Block.ID)
        }
        let YOffset: CGFloat = (30.0 - 10.0 - 1.0)
        let XOffset: CGFloat = -1.0
        ExpectedAnimatedBlockCount = BlockIDs.count
        AnimatedBlockCount = 0
        for BlockID in BlockIDs
        {
            if BlockExistsInList(BlockID)
            {
                if let VBlock = GetBlock(BlockID)
                {
                    UIView.animate(withDuration: Duration, animations:
                        {
                            VBlock.X = VBlock.X + ToOffsetX + CGFloat(XOffset)
                            VBlock.Y = VBlock.Y + ToOffsetY + CGFloat(YOffset) - 0.5
                    }, completion:
                        {
                            _ in
                            self.AccumulateAnimatedBlocks()
                    })
                }
            }
        }
    }
    
    /// Number of expected blocks to move.
    var ExpectedAnimatedBlockCount: Int = 0
    
    /// Number of times the smooth move completion handler is called.
    var AnimatedBlockCount: Int = 0
    
    /// Lock to prevent miscounting animation block completion handler calls.
    var AnimatedBlockLock = NSObject()
    
    /// Called upon from each completion block of a smoothly moving piece. Once the number of calls matches the number of blocks
    /// being moved, the appropriate delegate function is called.
    func AccumulateAnimatedBlocks()
    {
        objc_sync_enter(AnimatedBlockLock)
        defer{ objc_sync_exit(AnimatedBlockLock) }
        AnimatedBlockCount = AnimatedBlockCount + 1
        if AnimatedBlockCount == ExpectedAnimatedBlockCount
        {
            SmoothMotionDelegate?.SmoothMoveCompleted(For: SmoothPieceID)
        }
    }
    
    /// Start a piece moving rotating to the specified angle offset.
    /// - Note: The delegate's `SmoothRotationCompleted` function is called upon completion.
    /// - Parameter GamePiece: The piece to move smoothly.
    /// - Parameter ByDegrees: Angle offset to rotate to.
    /// - Parameter Duration: The amount of time to rotate the piece.
    /// - Parameter OnAxis: The axis to rotate by. Default value is .X. This parameter is ignored for non-3D game views.
    func RotatePieceSmoothly(_ GamePiece: Piece, ByDegrees: CGFloat, Duration: Double,
                             OnAxis: RotationalAxes = .X)
    {
        let Radians = ByDegrees * CGFloat.pi / 180.0
    }
    
    /// The moving piece is in its final location. Add its ID to the list of retired IDs and remove the moving blocks.
    /// - Parameter Finalized: The piece that was finalized.
    func MergePieceIntoBucket(_ Finalized: Piece)
    {
        RetiredPieceIDs.append(Finalized.ID)
        RemoveMovingPiece()
    }
    
    /// Create and add a block node for a piece.
    /// - Note: **Used for standard games.**
    /// - Parameter ParentID: The ID of the parent piece.
    /// - Parameter BlockID: The ID of the block node.
    /// - Parameter X: The initial X location of the node.
    /// - Parameter Y: The initial Y location of the node.
    /// - Parameter IsRetired: Initial retired status of the node.
    /// - Parameter Tile: The theme tile descriptor for the node.
    func AddBlockNode_Standard(ParentID: UUID, BlockID: UUID, X: Int, Y: Int, IsRetired: Bool, Tile: TileDescriptor)
    {
        let VBlock = VisualBlocks3D(BlockID, AtX: CGFloat(X), AtY: CGFloat(Y), WithTile: Tile, IsRetired: IsRetired)
        VBlock.ParentID = ParentID
        VBlock.Marked = true
        BlockList.insert(VBlock)
        self.scene?.rootNode.addChildNode(VBlock)
    }
    
    /// Create and add a block node for a piece.
    /// - Note: **Used for rotating games.**
    /// - Parameter ParentID: The ID of the parent piece.
    /// - Parameter BlockID: The ID of the block node.
    /// - Parameter X: The initial X location of the node.
    /// - Parameter Y: The initial Y location of the node.
    /// - Parameter IsRetired: Initial retired status of the node.
    /// - Parameter Tile: The theme tile descriptor for the node.
    func AddBlockNode_Rotating(ParentID: UUID, BlockID: UUID, X: CGFloat, Y: CGFloat, IsRetired: Bool, Tile: TileDescriptor)
    {
        let VBlock = VisualBlocks3D(BlockID, AtX: X, AtY: Y, WithTile: Tile, IsRetired: IsRetired)
        VBlock.ParentID = ParentID
        VBlock.Marked = true
        BlockList.insert(VBlock)
        MasterBlockNode!.addChildNode(VBlock)
    }
    
    /// Remove all moving piece blocks from the master block node.
    func UpdateMasterBlockNode()
    {
        if MasterBlockNode != nil
        {
            MasterBlockNode?.childNodes.forEach({
                if !($0 as! VisualBlocks3D).IsRetired
            {
                $0.removeFromParentNode()
                }
            })
        }
    }
    
    var MasterBlockNode: SCNNode? = nil
    
    /// Determines if a block should be drawn in **DrawMap3D**. Valid block types depend on the type of base game.
    /// - Parameter BlockType: The block to check to see if it can be drawn or not.
    /// - Returns: True if the block should be drawn, false if not.
    func ValidBlockToDraw(BlockType: PieceTypes) -> Bool
    {
        switch BaseGameType
        {
            case .Standard:
                return ![.Visible, .InvisibleBucket, .Bucket].contains(BlockType)
            
            case .Rotating4:
                return ![.Visible, .InvisibleBucket, .Bucket, .GamePiece, .BucketExterior].contains(BlockType)
            
            case .Cubic:
                return false
        }
    }
    
    /// Contains a list of IDs of blocks that have been retired. Used to keep the game from moving them when they are no longer
    /// moveable.
    var RetiredPieceIDs = [UUID]()
    
    /// Draw the individual piece. Intended to be used for the **.Rotating4** base game type.
    /// - Note:
    ///    - If the piece type ID cannot be retrieved, control is returned immediately.
    ///    - If `GamePiece` has an ID that is in `RetiredPieceIDs`, control will be returned immeidately to prevent spurious
    ///      pieces from polluting the game board.
    /// - Parameter InBoard: The current game board.
    /// - Parameter GamePiece: The piece to draw.
    func DrawPiece3D(InBoard: Board, GamePiece: Piece)
    {
        if RetiredPieceIDs.contains(GamePiece.ID)
        {
            return
        }
        if MovingPieceNode != nil
        {
            MovingPieceNode?.removeFromParentNode()
        }
        MovingPieceBlocks = [VisualBlocks3D]()
        MovingPieceNode = SCNNode()
        MovingPieceNode?.name = "Moving Piece"
        let CurrentMap = InBoard.Map!
        let ItemID = GamePiece.ID
        for Block in GamePiece.Locations!
        {
            let YOffset = (30 - 10 - 1) - 1.5 - CGFloat(Block.Y)
            let XOffset = CGFloat(Block.X) - 17.5
            let PieceTypeID = CurrentMap.RetiredPieceShapes[ItemID]
            if PieceTypeID == nil
            {
                return
            }
            let Tile = CurrentTheme?.TileDescriptorFor(PieceTypeID!)
            let VBlock = VisualBlocks3D(Block.ID, AtX: XOffset, AtY: YOffset, WithTile: Tile!, IsRetired: false)
            MovingPieceBlocks.append(VBlock)
            MovingPieceNode?.addChildNode(VBlock)
        }
        self.scene?.rootNode.addChildNode(MovingPieceNode!)
    }
    
    var MovingPieceBlocks = [VisualBlocks3D]()
    
    /// Remove the moving piece, if it exists.
    func RemoveMovingPiece()
    {
        if BaseGameType == .Rotating4
        {
            if MovingPieceNode != nil
            {
                print("Removing node \((MovingPieceNode?.name)!)")
                MovingPieceNode!.removeFromParentNode()
                MovingPieceNode = nil
                UpdateMasterBlockNode()
            }
        }
    }
    
    var MovingPieceNode: SCNNode? = nil
    
    /// Visually clear the bucket of pieces.
    /// - Note:
    ///   - Should be called only after the game is over.
    ///   - This is for the **3D** game view only.
    ///   - All retired piece IDs are removed.
    /// - Parameter FromBoard: The board that contains the map to draw. *Not currently used.*
    /// - Parameter CalledFrom: Name of the caller. Used for debugging purposes only.
    /// - Parameter DestroyBy: Determines how to empty the bucket.
    func DestroyMap3D(FromBoard: Board, CalledFrom: String, DestroyBy: DestructionMethods,
                      Completion: (() ->())?)
    {
        #if false
        print("DestroyMap3D called from \(CalledFrom)")
        #endif
        objc_sync_enter(RotateLock)
        defer{ objc_sync_exit(RotateLock) }
        
        BucketCleaner(DestroyBy, Completion: Completion)
        RetiredPieceIDs.removeAll()
    }
    
    /// Draw the 3D game view map. Includes moving pieces.
    /// - Note:
    ///    - To keep things semi-efficient, 3D objects are only created when they first appear in the game board.
    ///      Once there, they are moved as needed rather than creating new ones in new locations.
    ///    - This function assumes the board changes between each piece.
    /// - Parameter FromBoard: The board that contains the map to draw.
    func DrawMap3D(FromBoard: Board, CalledFrom: String = "")
    {
        if BaseGameType == .Rotating4
        {
            print("DrawMap3D called from \(CalledFrom)")
        }
        objc_sync_enter(RotateLock)
        defer{ objc_sync_exit(RotateLock) }
        
        BlockList.forEach({$0.Marked = false})
        
        let CurrentMap = FromBoard.Map!
        let BlockMap = FromBoard.Map!.MergedBlockMap()
        let MergedMap = FromBoard.Map!.MergeMap(Excluding: nil)
        
        for Y in 0 ..< CurrentMap.Height
        {
            for X in 0 ..< CurrentMap.Width
            {
                let ItemID = MergedMap[Y][X]
                let ItemType = CurrentMap.IDMap?.IDtoPiece(ItemID)
                if !ValidBlockToDraw(BlockType: ItemType!)
                {
                    continue
                }
                
                //Generate offsets to ensure the block is in the proper position in the 3D scene.
                var YOffset: CGFloat = 0
                var XOffset: CGFloat = 0
                switch BaseGameType
                {
                    case .Standard:
                        YOffset = (30 - 10 - 1) - CGFloat(Y)
                        XOffset = CGFloat(X) - 6.0
                    
                    case .Rotating4:
                        YOffset = (30 - 10 - 1) - 1.0 - CGFloat(Y)
                        XOffset = CGFloat(X) - 17.5
                    
                    case .Cubic:
                        XOffset = 0
                        YOffset = 0
                }
                
                let IsRetired = ItemType! == .RetiredGamePiece
                
                let BlockID = BlockMap[Y][X]
                if BlockID == UUID.Empty
                {
                    continue
                }
                if BlockExistsInList(BlockID)
                {
                    if let VBlock = GetBlock(BlockID)
                    {
                        let NewX = CGFloat(XOffset)
                        let NewY = CGFloat(YOffset) - 0.5
                        if NewX == VBlock.X && NewY == VBlock.Y
                        {
                            //Nothing to do...
                        }
                        else
                        {
                            VBlock.X = NewX
                            VBlock.Y = NewY
                        }
                        VBlock.Marked = true
                        VBlock.IsRetired = IsRetired
                    }
                }
                else
                {
                    let PieceTypeID = CurrentMap.RetiredPieceShapes[ItemID]
                    let Tile = CurrentTheme?.TileDescriptorFor(PieceTypeID!)
                    if BaseGameType == .Rotating4
                    {
                        YOffset = YOffset - 0.5
                    }
                    switch BaseGameType
                    {
                        case .Standard:
                            AddBlockNode_Standard(ParentID: ItemID, BlockID: BlockID, X: Int(XOffset), Y: Int(YOffset),
                                                  IsRetired: IsRetired, Tile: Tile!)
                        
                        case .Rotating4:
                            AddBlockNode_Rotating(ParentID: ItemID, BlockID: BlockID, X: XOffset, Y: YOffset,
                                                  IsRetired: IsRetired, Tile: Tile!)
                        case .Cubic:
                            break
                    }
                }
            }
        }
        
        //Removed blocks no longer in the map.
        var RemoveCount = 0
        for VBlock in BlockList
        {
            if !VBlock.Marked
            {
                VBlock.Remove()
                RemoveCount = RemoveCount + 1
            }
        }
        BlockList = BlockList.filter{$0.Marked}
    }
    
    /// Draw the map.
    /// - Note: **Note used in 3DView.**
    /// - Parameter FromBoard: The board to use as a source for the map.
    /// - Parameter ForEntireMap: If true, the entire map is drawn.
    func DrawMap(FromBoard: Board, ForEntireMap: Bool)
    {
        //Not used in the 3D game view.
    }
    
    /// Draw a text map.
    /// - Note: **Not used in 3DView.**
    /// - Parameter WithText: The contents to draw.
    func DrawTextMap(WithText: String)
    {
        //Not used in the 3D game view.
    }
    
    /// Sets the board to use by the view (and indirectly sets the map as well).
    /// - Parameter TheBoard: The board to use when drawing the game.
    func SetBoard(_ TheBoard: Board)
    {
        CurrentBoard = TheBoard
        CurrentMap = TheBoard.Map
    }
    
    var CurrentBoard: Board? = nil
    var CurrentMap: MapType? = nil
    
    /// Creates the master block node. This is the node in which all blocks are placed. This is done to allow for
    /// easy rotation of blocks when needed.
    func CreateMasterBlockNode()
    {
        if MasterBlockNode != nil
        {
            MasterBlockNode!.removeAllActions()
            MasterBlockNode!.removeFromParentNode()
            MasterBlockNode = nil
        }
        MasterBlockNode = SCNNode()
        MasterBlockNode!.name = "Master Block Node"
        self.scene?.rootNode.addChildNode(MasterBlockNode!)
    }
    
    /// Clear the bucket of all pieces.
    func ClearBucket()
    {
        CreateMasterBlockNode()
        for Node in BlockList
        {
            Node.removeAllActions()
            Node.removeFromParentNode()
        }
        BlockList.removeAll()
    }
    
    /// Empty the map of all block nodes.
    func EmptyMap()
    {
        self.scene?.rootNode.enumerateChildNodes
            {
                (Node, _) in
                if ["BlockNode"].contains(Node.name)
                {
                    //Node.geometry!.firstMaterial!.normal.contents = nil
                    Node.geometry!.firstMaterial!.specular.contents = nil
                    Node.geometry!.firstMaterial!.diffuse.contents = nil
                    Node.removeFromParentNode()
                }
        }
    }
    
    func LayoutCompleted()
    {
    }
    
    func Resized()
    {
        CurrentSize = frame
    }
    
    var CurrentSize: CGRect? = nil
    
    /// The node that holds the set of bucket grid lines.
    var BucketGridNode: SCNNode? = nil
    
    /// Function that does the actual "line" drawing of the bucket grid.
    /// - Note: The lines are really very thin boxes; SceneKit doesn't support lines as graphical objects.
    /// - Parameter ShowGrid: If true, the grid is drawn. If false, no grid is drawn, but see **DrawOutline**.
    /// - Parameter DrawOutline: If true, a perimeter outline is drawn.
    func DrawGridInBucket(ShowGrid: Bool = true, DrawOutline: Bool)
    {
        if BucketGridNode != nil
        {
            BucketGridNode?.removeFromParentNode()
        }
        BucketGridNode = SCNNode()
        switch BaseGameType
        {
            case .Standard:
                if ShowGrid
                {
                //Horizontal bucket lines.
                for Y in stride(from: 10.0, to: -10.5, by: -1.0)
                {
                    let Start = SCNVector3(-0.5, Y, 0.0)
                    let End = SCNVector3(10.0, Y, 0.0)
                    let LineNode = MakeLine(From: Start, To: End, Color: ColorNames.White, LineWidth: 0.03)
                    LineNode.name = "Horizontal,\(Int(Y))"
                    BucketGridNode?.addChildNode(LineNode)
                }
                //Vertical bucket lines.
                for X in stride(from: -4.5, to: 5.0, by: 1.0)
                {
                    let Start = SCNVector3(X, 0.0, 0.0)
                    let End = SCNVector3(X, 20.0, 0.0)
                    let LineNode = MakeLine(From: Start, To: End, Color: ColorNames.White, LineWidth: 0.03)
                    LineNode.name = "Vertical,\(Int(X))"
                    BucketGridNode?.addChildNode(LineNode)
            }
            }
            if DrawOutline
            {
                let TopStart = SCNVector3(-0.5, 10.0, 0.0)
                let TopEnd = SCNVector3(10.5, 10.0, 0.0)
                let TopLine = MakeLine(From: TopStart, To: TopEnd, Color: ColorNames.Red, LineWidth: 0.08)
                TopLine.name = "TopLine"
                BucketGridNode?.addChildNode(TopLine)
            }
            
            case .Rotating4:
                if ShowGrid
                {
                //Horizontal bucket lines.
                for Y in stride(from: 10.0, to: -10.5, by: -1.0)
                {
                    let Start = SCNVector3(0.0, Y, 0.0)
                    let End = SCNVector3(20.0, Y, 0.0)
                    let LineNode = MakeLine(From: Start, To: End, Color: ColorNames.White, LineWidth: 0.02)
                    LineNode.name = "Horizontal,\(Int(Y))"
                    BucketGridNode?.addChildNode(LineNode)
                }
                //Vertical bucket lines.
                for X in stride(from: -10.0, to: 10.5, by: 1.0)
                {
                    let Start = SCNVector3(X, 0.0, 0.0)
                    let End = SCNVector3(X, 20.0, 0.0)
                    let LineNode = MakeLine(From: Start, To: End, Color: ColorNames.White, LineWidth: 0.02)
                    LineNode.name = "Vertical,\(Int(X))"
                    BucketGridNode?.addChildNode(LineNode)
                }
                }
                //Outline.
                if DrawOutline
                {
                    let TopStart = SCNVector3(0.0, 10.0, 0.0)
                    let TopEnd = SCNVector3(20.0, 10.0, 0.0)
                    let TopLine = MakeLine(From: TopStart, To: TopEnd, Color: ColorNames.Red, LineWidth: 0.08)
                    TopLine.name = "TopLine"
                    BucketGridNode?.addChildNode(TopLine)
                    let BottomStart = SCNVector3(0.0, -10.0, 0.0)
                    let BottomEnd = SCNVector3(20.0, -10.0, 0.0)
                    let BottomLine = MakeLine(From: BottomStart, To: BottomEnd, Color: ColorNames.Red, LineWidth: 0.08)
                    BottomLine.name = "BottomLine"
                    BucketGridNode?.addChildNode(BottomLine)
                    let LeftStart = SCNVector3(-10.0, 0.0, 0.0)
                    let LeftEnd = SCNVector3(-10.0, 20.0, 0.0)
                    let LeftLine = MakeLine(From: LeftStart, To: LeftEnd, Color: ColorNames.Red, LineWidth: 0.08)
                    LeftLine.name = "LeftLine"
                    BucketGridNode?.addChildNode(LeftLine)
                    let RightStart = SCNVector3(10.0, 0.0, 0.0)
                    let RightEnd = SCNVector3(10.0, 20.0, 0.0)
                    let RightLine = MakeLine(From: RightStart, To: RightEnd, Color: ColorNames.Red, LineWidth: 0.08)
                    RightLine.name = "RightLine"
                    BucketGridNode?.addChildNode(RightLine)
                }
                
                #if false
                let TopLabel = SCNText(string: "Top", extrusionDepth: 0.5)
                TopLabel.materials.first!.specular.contents = ColorServer.ColorFrom(ColorNames.Black)
                TopLabel.materials.first!.diffuse.contents = ColorServer.ColorFrom(ColorNames.Cyan)
                TopLabel.flatness = 0.2
                let TopNode = SCNNode(geometry: TopLabel)
                TopNode.name = "Top"
                TopNode.scale = SCNVector3(0.02, 0.02, 0.02)
                TopNode.position = SCNVector3(-0.5, 10.4, 0.0)
                BucketGridNode?.addChildNode(TopNode)
                
                let BottomLabel = SCNText(string: "Bottom", extrusionDepth: 0.5)
                BottomLabel.materials.first!.specular.contents = ColorServer.ColorFrom(ColorNames.Black)
                BottomLabel.materials.first!.diffuse.contents = ColorServer.ColorFrom(ColorNames.Yellow)
                BottomLabel.flatness = 0.2
                let BottomNode = SCNNode(geometry: BottomLabel)
                BottomNode.name = "Bottom"
                BottomNode.scale = SCNVector3(0.02, 0.02, 0.02)
                BottomNode.rotation = SCNVector4(0.0, 0.0, 1.0, CGFloat.pi)
                BottomNode.position = SCNVector3(0.5, -10.5, 0.0)
                BucketGridNode?.addChildNode(BottomNode)
                
                let RightLabel = SCNText(string: "Right", extrusionDepth: 0.5)
                RightLabel.materials.first!.specular.contents = ColorServer.ColorFrom(ColorNames.Black)
                RightLabel.materials.first!.diffuse.contents = ColorServer.ColorFrom(ColorNames.Magenta)
                RightLabel.flatness = 0.2
                let RightNode = SCNNode(geometry: RightLabel)
                RightNode.name = "Right"
                RightNode.scale = SCNVector3(0.02, 0.02, 0.02)
                RightNode.rotation = SCNVector4(0.0, 0.0, 1.0, 270.0 * CGFloat.pi / 180.0)
                RightNode.position = SCNVector3(10.5, 1.0, 0.0)
                BucketGridNode?.addChildNode(RightNode)
                
                let LeftLabel = SCNText(string: "Left", extrusionDepth: 0.5)
                LeftLabel.materials.first!.specular.contents = ColorServer.ColorFrom(ColorNames.Gray)
                LeftLabel.materials.first!.diffuse.contents = ColorServer.ColorFrom(ColorNames.Black)
                RightLabel.flatness = 0.2
                let LeftNode = SCNNode(geometry: LeftLabel)
                LeftNode.name = "Left"
                LeftNode.scale = SCNVector3(0.02, 0.02, 0.02)
                LeftNode.rotation = SCNVector4(0.0, 0.0, 1.0, CGFloat.pi * 0.5)
                LeftNode.position = SCNVector3(-10.5, 0.0, 0.0)
                BucketGridNode?.addChildNode(LeftNode)
            #endif
            
            case .Cubic:
                break
        }
        self.scene?.rootNode.addChildNode(BucketGridNode!)
    }
    
    /// Show or hide a buck grid. The bucket grid is unit sized (according to the block size) that fills the
    /// interior of the bucket.
    /// - Parameter ShowLines: Determines if the grid is shown or hidden.
    /// - Parameter IncludingOutline: If true, the outline is drawn as well.
    func DrawBucketGrid(ShowLines: Bool, IncludingOutline: Bool = true)
    {
        DrawGridInBucket(ShowGrid: ShowLines, DrawOutline: IncludingOutline)
    }
    
    /// Hide the bucket grid by removing all grid nodes from the scene.
    func ClearBucketGrid()
    {
        RemoveNodes(WithNames: ["BucketGrid", "TopLine", "LeftLine", "BottomLine", "RightLine",
                                "Top", "Left", "Bottom", "Right"])
    }
    
    func DrawGridLines(_ Show: Bool, WithUnitSize: CGFloat?)
    {
        if Show
        {
            CreateGrid()
        }
        else
        {
            RemoveNodes(WithName: "BucketNode")
        }
    }
    
    func MovePiece(_ ThePiece: Piece, ToLocation: CGPoint, Duration: Double,
                   Completion: ((UUID) -> ())? = nil)
    {
    }
    
    func RotatePiece(_ ThePiece: Piece, Degrees: Double, Duration: Double,
                     Completion: ((UUID) -> ())? = nil)
    {
        
    }
    
    func DrawPiece(_ ThePiece: Piece, SurfaceSize: CGSize)
    {
    }
    
    var RotateLock = NSObject()
    
    var RotateMe: SCNNode = SCNNode()
    
    /// Rotates the contents of the game (but not UI or falling piece) by the specified number of degrees.
    /// - Parameter Right: If true, the contents are rotated clockwise. If false, counter-clockwise.
    /// - Parameter Duration: Duration in seconds the rotation should take.
    /// - Parameter Completed: Completion handler called at the end of the rotation.
    func RotateContents(Right: Bool, Duration: Double = 0.33, Completed: @escaping (() -> Void))
    {
        objc_sync_enter(RotateLock)
        defer{objc_sync_exit(RotateLock)}
        let DirectionalSign = CGFloat(Right ? -1.0 : 1.0)
        let ZRotation = DirectionalSign * 90.0 * CGFloat.pi / 180.0
        let RotateAction = SCNAction.rotateBy(x: 0.0, y: 0.0, z: ZRotation, duration: Duration)
        RemoveMovingPiece()
        BucketNode?.runAction(RotateAction, completionHandler: {Completed()})
        BucketGridNode?.runAction(RotateAction)
        MasterBlockNode?.runAction(RotateAction)
    }
    
    /// Rotates the contents of the game (but not UI or falling piece) by 90° right (clockwise).
    /// - Parameter Duration: Duration in seconds the rotation should take.
    /// - Parameter Completed: Completion handler called at the end of the rotation.
    func RotateContentsRight(Duration: Double = 0.33, Completed: @escaping (() -> Void))
    {
        RotateContents(Right: true, Duration: Duration, Completed: Completed)
    }
    
    /// Rotates the contents of the game (but not UI or falling piece) by 90° left (counter-clockwise).
    /// - Parameter Duration: Duration in seconds the rotation should take.
    /// - Parameter Completed: Completion handler called at the end of the rotation.
    func RotateContentsLeft(Duration: Double = 0.33, Completed: @escaping (() -> Void))
    {
        RotateContents(Right: false, Duration: Duration, Completed: Completed)
    }
    
    /// Sets the opacity level of the entire board to the specified value.
    /// - Parameter To: The new alpha/opacity level.
    /// - Parameter Duration: The duration of the opacity change.
    /// - Parameter Completed: Completion block.
    func SetBoardOpacity(To: Double, Duration: Double, Completed: (() -> ())? = nil)
    {
        var FadeAction: SCNAction!
        if To == 1.0
        {
            FadeAction = SCNAction.fadeIn(duration: Duration)
        }
        else
        {
            FadeAction = SCNAction.fadeOut(duration: Duration)
        }
        BucketNode?.runAction(FadeAction)
        BucketGridNode?.runAction(FadeAction)
        MasterBlockNode?.runAction(FadeAction, completionHandler:
            {
                if let CompletionHandler = Completed
                {
                    CompletionHandler()
                }
        }
        )
    }
    
    func GetNodeCount() -> Int
    {
        var Count = 0
        self.scene?.rootNode.enumerateChildNodes
            {
                _, _ in
                Count = Count + 1
        }
        return Count
    }
    
    var SceneNodeID = UUID()
    var MaxSceneNodeID = UUID()
    var MaxSceneNodes: Int = 0
    
    /// Handle the piece out of bounds state (which indicates game over).
    /// - Note: [Animated SCNNode Forever](https://stackoverflow.com/questions/29658772/animate-scnnode-forever-scenekit-swift)
    /// - Parameter ID: The ID of the node that froze out of bounds.
    func PieceOutOfBounds(_ ID: UUID)
    {
        //print("Piece \(ID) froze out of bounds.")
        let NodeCount = GetNodeCount()
        if NodeCount > MaxSceneNodes
        {
            MaxSceneNodes = NodeCount
        }
        let SceneNodeCountKVP = MessageHelper.MakeKVPMessage(ID: SceneNodeID, Key: "Scene Nodes", Value: "\(NodeCount)")
        DebugClient.SendPreformattedCommand(SceneNodeCountKVP)
        let MaxNodeCountKVP = MessageHelper.MakeKVPMessage(ID: MaxSceneNodeID, Key: "Max Nodes", Value: "\(MaxSceneNodes)")
        DebugClient.SendPreformattedCommand(MaxNodeCountKVP)
        
        FinalBlocks = [VisualBlocks3D]()
        switch BaseGameType
        {
            case .Standard:
                for Block in BlockList
                {
                    if Block.ParentID == ID
                    {
                        FinalBlocks.append(Block)
                    }
            }
            case .Rotating4:
                for Block in MovingPieceBlocks
                {
                    FinalBlocks.append(Block)
            }
            
            case .Cubic:
                break
        }
        
        let Rotate = SCNAction.rotateBy(x: CGFloat.pi * 2.0, y: CGFloat.pi * 2.0, z: CGFloat.pi * 2.0, duration: 0.75)
        Rotate.timingMode = .easeInEaseOut
        let ScalingDown = SCNAction.scale(by: 0.75, duration: 0.5)
        ScalingDown.timingMode = .easeInEaseOut
        let ScalingUp = SCNAction.scale(by: 1.3333333, duration: 0.5)
        ScalingUp.timingMode = .easeInEaseOut
        let ScalingSequence = SCNAction.sequence([ScalingDown, ScalingUp, Rotate])
        let ScaleLoop = SCNAction.repeatForever(ScalingSequence)
        for Block in FinalBlocks
        {
            Block.runAction(ScaleLoop)
        }
    }
    
    var FinalBlocks = [VisualBlocks3D]()
    var FrozenTimer: Timer!
    
    @objc func HighlightFrozenBlocks()
    {
        
    }
    
    func StartedFreezing(_ ID: UUID)
    {
    }
    
    func StoppedFreezing(_ ID: UUID)
    {
    }
    
    /// Return the current frame rate.
    /// - Returns: Current frame rate.
    func FrameRate() -> Double?
    {
        #if true
        return LastFrameRate
        #else
        let AnyFPS = GameScene.attribute(forKey: SCNScene.Attribute.frameRate.rawValue)
        let NSFPS: NSNumber = AnyFPS as! NSNumber
        let FPS = NSFPS as! Double
        return FPS
        #endif
    }
    
    /// Used to keep track of when the renderer was called.
    var LastUpdateTime: TimeInterval = 0.0
    
    /// The last calculated framerate.
    var LastFrameRate: Double = 0.0
    
    /// Calculate the frame rate here.
    /// - Note: We do this using this method rather than getting an attribute from the scene
    ///         because the attribute reports what the *target* framerate is, not the actual
    ///         frame rate.
    /// - Parameter renderer: Not used.
    /// - Parameter time: The time interval between calls.
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        let DeltaTime = time - LastUpdateTime
        let CurrentFPS = 1 / DeltaTime
        LastUpdateTime = time
        LastFrameRate = CurrentFPS
    }
    
    func SetOpacity(OfID: UUID, To: Double)
    {
    }
    
    /// Sets the opacity of the passed block type to the passed value.
    /// - Parameter OfID: The ID of the block whose opacity will be set.
    /// - Parameter To: The new opacity level.
    /// - Parameter Duration: The amount of time to run the opacity change action.
    func SetOpacity(OfID: UUID, To: Double, Duration: Double)
    {
        for Block in BlockList
        {
            if Block.ParentID == OfID
            {
                let Action = SCNAction.fadeOpacity(to: CGFloat(To), duration: Duration)
                Block.runAction(Action)
            }
        }
    }
    
    /// Holds the current theme.
    private var CurrentTheme: ThemeDescriptor? = nil
    
    /// Set a (potentially but most likely) new theme. Changed visuals may take a frame or two (or more) to
    /// take effect.
    /// - Parameter ThemeID: The ID of the new theme.
    func SetTheme(_ ThemeID: UUID)
    {
        CurrentTheme = ThemeManager.ThemeFrom(ID: ThemeID)
    }
    
    func Refresh()
    {
    }
    
    // MARK: ThreeDProtocol function implementations.
    
    /// Set the camera node's camera data. Used mainly for debugging purposes.
    /// - Parameter FOV: The FOV (field of view) parameter for the camera.
    /// - Parameter Position: The position of the camera node.
    /// - Parameter Orientation: The orientation of the camera node.
    func SetCameraData(FOV: CGFloat, Position: SCNVector3, Orientation: SCNVector4)
    {
        CameraNode!.camera!.fieldOfView = FOV
        CameraNode!.position = Position
        CameraNode!.orientation = Orientation
    }
    
    /// Returns current camera data (mostly for debugging purposes).
    /// - Returns: Tuple in the order (camera field of view, camera node position, camera node orientation).
    func GetCameraData() -> (CGFloat, SCNVector3, SCNVector4)
    {
        return (CameraNode!.camera!.fieldOfView, CameraNode!.position, CameraNode!.orientation)
    }
    
    /// Set parameters for the main lighting node. Used mainly for debugging purposes.
    /// - Parameter Position: The position of the light node.
    /// - Parameter LightingType: The type of light.
    /// - Parameter ColorName: The name of the color the light emits.
    /// - Parameter UseDefault: If true, default lighting is used.
    func SetLightData(Position: SCNVector3, LightingType: SCNLight.LightType, ColorName: String,
                      UseDefault: Bool)
    {
        self.autoenablesDefaultLighting = UseDefault
        LightNode.position = Position
        LightNode.light?.type = LightingType
        let Color = ColorServer.ColorFrom(ColorName)
        LightNode.light?.color = Color
    }
    
    /// Returns current lighting data (mostly for debugging purposes)
    /// - Returns: Tuple in the order (camera node position, light type, light color, use default lighting).
    func GetLightData() -> (SCNVector3, SCNLight.LightType, String, Bool)
    {
        let TheColor: UIColor = (LightNode.light?.color as? UIColor)!
        let ColorName = ColorServer.MakeColorName(From: TheColor)
        return (LightNode.position, LightNode.light!.type, ColorName!, self.autoenablesDefaultLighting)
    }
    
    // MARK: Text layer protocol function implementation
    
    /// Handle double click events relayed to us by the text layer. Double click events will cause the camera to be reset
    /// to it's theme-appropriate values.
    func MouseDoubleClick(At: CGPoint)
    {
        self.pointOfView?.position = OriginalCameraPosition!
        self.pointOfView?.orientation = OriginalCameraOrientation!
    }
}

// MARK: Global enums related to 3DView.

/// Possible shapes for center blocks for **.Rotating4** games.
/// - **Dot**: 1 x 1 center (or close enough to it) block.
/// - **Square**: 4 x 4 center square.
/// - **SmallSquare**: 2 x 2 center square.
/// - **BigSquare**: 6 x 6 center square.
/// - **SmallRectangle**: 2 x 1 center (or close enough) rectangle.
/// - **Rectangle**: 4 x 2 center rectangle.
/// - **BigRectangle**: 8 x 3 center (or close enough) rectangle.
/// - **SmallDiamond**: Diamond, 3 x 3 square rotated 90°.
/// - **Diamond**: Diamond, 5 x 5 square rotated 90°.
/// - **BigDiamond**: Diamond, 6 x 6 square rotated 90°.
/// - **Bracket2**: Two brackets facing each other.
/// - **Bracket4**: Four brackets arranged in a square.
enum CenterShapes: String, CaseIterable
{
    case Dot = "Dot"
    case Square = "Square"
    case SmallSquare = "SmallSquare"
    case BigSquare = "BigSquare"
    case SmallRectangle = "SmallRectangle"
    case Rectangle = "Rectangle"
    case BigRectangle = "BigRectangle"
    case SmallDiamond = "SmallDiamond"
    case Diamond = "Diamond"
    case BigDiamond = "BigDiamond"
    case Bracket2 = "Bracket2"
    case Bracket4 = "Bracket4"
}
