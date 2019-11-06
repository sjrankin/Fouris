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
import AVFoundation

/// Runs Fouris in a 3D scene, allowing for more options of viewing and confounding the player.
class View3D: SCNView,                          //Our main super class.
    SCNSceneRendererDelegate,                   //To get notifications when a new frame is drawn in order to calculate the frame rate.
    GameViewProtocol,                           //How the UI communicates with a game view.
    ThreeDProtocol,                             //The 3D game protocol.
    SmoothMotionProtocol,                       //Smooth motion protocol.
    TextLayerProtocol,                          //Text layer protocol.
    ThemeUpdatedProtocol,                       //Theme properites updated protocol.
    ParentSizeChangedProtocol                   //The parent view of this view had a size change protocol.
{
    /// Delegate to the main class.
    weak public var Main: MainDelegate? = nil
    
    /// The scene that is shown in the 3D view.
    public var GameScene: SCNScene!
    
    /// Light mask for the game.
    public static let GameLight: Int = 0x1 << 1
    
    /// Light mask for the controls.
    public static let ControlLight: Int = 0x1 << 2
    
    /// Light mask for the about box.
    public static let AboutLight: Int = 0x1 << 3
    
    // MARK: - Initialization.
    
    /// Initialize the view.
    /// - Note: Setting 'self.showsStatistics' to true will lead to the scene freezing after a period of time (on the order of
    ///         hours). Likewise, setting `self.allowsCameraControl` will lead to non-responsiveness in the UI after a period
    ///         of time (on the order of tens of minutes). Therefore, using those two properties should be transient and for
    ///         debug use only.
    /// - Parameter With: The board to use for displaying contents.
    /// - Parameter Theme: The theme manager instance.
    /// - Parameter BucketShape: The shape of the game's bucket.
    func Initialize(With: Board, Theme: ThemeManager3, BucketShape: BucketShapes)
    {
        self.isUserInteractionEnabled = true
        CenterBlockShape = BucketShape
        self.rendersContinuously = true
        CreateMasterBlockNode()
        SetBoard(With)
        CurrentTheme = Theme.UserTheme
        Theme.SubscribeToChanges(Subscriber: "View3D", SubscribingObject: self)
        if CurrentTheme!.ShowStatistics
        {
            print("Show statistics is enabled in View3D. This may lead to performance degradation.")
        }
        self.showsStatistics = CurrentTheme!.ShowStatistics
        if CurrentTheme!.CanControlCamera
        {
            print("Can control camera is enabled in View3D. This may lead to performance degradation.")
        }
        self.allowsCameraControl = CurrentTheme!.CanControlCamera
        OriginalCameraPosition = CurrentTheme!.CameraPosition
        OriginalCameraOrientation = CurrentTheme!.CameraOrientation
        #if false
        self.debugOptions = [.showBoundingBoxes, .renderAsWireframe]
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
            
            case .MultiSampling4X:
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
        
        let Node = CreateBucket(InitialOpacity: 1.0, Shape: CenterBlockShape!)
        BucketNode = Node
        self.scene?.rootNode.addChildNode(BucketNode!)
        if CurrentTheme!.ShowGrid
        {
            CreateGrid()
        }
        
        LightNode = CreateGameLight()
        self.scene?.rootNode.addChildNode(LightNode)
        
        let ControlLightNode = CreateControlLight()
        self.scene?.rootNode.addChildNode(ControlLightNode)
        
        DrawBackground()
        DrawBucketGrid(ShowLines: CurrentTheme!.ShowBucketGrid, IncludingOutline: true)
        OrbitCamera()
        AddPeskyLight()
        PerfTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(SendPerformanceData),
                                         userInfo: nil, repeats: true)
        
        ShowControls()
        DrawCenterLines()
        
        #if true
        let Obnoxious = SCNLight()
        Obnoxious.type = .spot
        Obnoxious.color = UIColor.white
        let ObNode = SCNNode()
        ObNode.light = Obnoxious
        ObNode.position = SCNVector3(0, 0, -3)
        ObNode.constraints?.append(SCNLookAtConstraint(target: CameraNode))
        #endif
    }
    
    /// Not currently used.
    public func NewParentSize(Bounds: CGRect, Frame: CGRect)
    {
    }
    
    /// The theme was updated. See what changed and take the appropriate action.
    /// - Parameter ThemeName: The name of the theme that changed.
    /// - Parameter Field: The field that changed.
    public func ThemeUpdated(ThemeName: String, Field: ThemeFields)
    {
        //print("Theme \(ThemeName) updated field \(Field)")
        if Field == .BackgroundSolidColor || Field == .BackgroundSolidColorCycleTime
        {
            NewBackgroundSolidColor()
            return
        }
        if Field == .BackgroundGradientColor || Field == .BackgroundGradientColorCycleTime
        {
            NewGradientColorBackground()
            return
        }
        if [ThemeFields.BackgroundLiveImageCamera, ThemeFields.BackgroundType,
            ThemeFields.ShowCenterLines, ThemeFields.CenterLineColor, ThemeFields.CenterLineWidth,
            ThemeFields.BackgroundSolidColor, ThemeFields.BackgroundImageName, ThemeFields.BackgroundImageFromCameraRoll].contains(Field)
        {
            DrawBackground()
        }
        else
        {
            switch Field
            {
                case .ShowCenterLines:
                    fallthrough
                case .CenterLineColor:
                    fallthrough
                case .CenterLineWidth:
                    DrawCenterLines()
                
                case .CameraFieldOfView:
                    CameraNode.camera?.fieldOfView = CGFloat(CurrentTheme!.CameraFieldOfView)
                //print("Camera field of view changed to \(CurrentTheme!.CameraFieldOfView)")
                
                default:
                    break
            }
        }
    }
    
    /// Holds the bucket shape.
    public var CenterBlockShape: BucketShapes? = nil
    
    /// Performance timer.
    var PerfTimer: Timer? = nil
    
    /// Send performance data to the owner periodically.
    @objc public func SendPerformanceData()
    {
        let CurrentFPS = FrameRate()!
        Owner?.PerformanceSample(FPS: CurrentFPS)
    }
    
    /// Orientation KVP.
    private let OrientationKVP = UUID()
    
    /// Position KVP.
    private let PositionKVP = UUID()
    
    /// Original camera orientation. Used in debug for resetting the camera after the user moves it around.
    public var OriginalCameraOrientation: SCNVector4? = nil
    
    /// Original camera position. Used in debug for resetting the camera after the user moves it around.
    public var OriginalCameraPosition: SCNVector3? = nil
    
    /// Orbit the camera around the scene.
    public func OrbitCamera()
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
    public var CameraObserver: NSKeyValueObservation? = nil
    
    /// Required by framework.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Reference back to the game UI.
    weak public var Owner: GameViewRequestProtocol? = nil
    
    /// Use default lighting flag.
    /// - Note: In the future, we won't need this as each theme will contain this flag instead.
    public var UseDefaultLighting: Bool = true
    
    /// Holds the camera node.
    public var CameraNode: SCNNode!
    
    /// Holds the light node.
    public var LightNode: SCNNode!
    
    /// Create the camera using current theme data.
    /// - Returns: Scene node with camera data.
    public func MakeCamera() -> SCNNode
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
    
    // MARK: - Background colors and hue shifting.
    
    /// Handle hue shifting of the solid background color.
    /// - Note: To turn off hue shifting, pass `0.0` in `Duration`. This also has the effect of setting the background color to
    ///         a non-changing solid color.
    /// - Parameter Duration: Duration of the hue shift through 360°.
    private func UpdateHueShifting(Duration: Double)
    {
        if Duration <= 0.0
        {
            HueTimer?.invalidate()
            HueTimer = nil
            self.scene?.background.contents = ColorServer.ColorFrom(CurrentTheme!.BackgroundSolidColor)
            return
        }
        WorkingColor = ColorServer.ColorFrom(CurrentTheme!.BackgroundSolidColor)
        let Interval = CurrentTheme!.BackgroundSolidColorCycleTime / 360.0
        HueTimer = Timer.scheduledTimer(timeInterval: Interval, target: self, selector: #selector(UpdateSolidColorBackground),
                                        userInfo: nil, repeats: true)
    }
    
    /// Shift the solid color background by (1/360)°.
    @objc private func UpdateSolidColorBackground()
    {
        var Hue = WorkingColor.Hue
        let Saturation = WorkingColor.Saturation
        let Brightness = WorkingColor.Brightness
        let Alpha = WorkingColor.Alpha()
        Hue = Hue + (1.0 / 360.0)
        if Hue > 1.0
        {
            Hue = 0.0
        }
        if Hue < 0.0
        {
            Hue = 1.0
        }
        WorkingColor = UIColor(hue: Hue, saturation: Saturation, brightness: Brightness, alpha: Alpha)
        OperationQueue.main.addOperation
            {
                self.scene?.background.contents = self.WorkingColor
        }
    }
    
    /// Holds the solid color hue shifting working value.
    private var WorkingColor: UIColor = UIColor.white
    
    /// Timer for shifting the color of the background.
    private var HueTimer: Timer? = nil
    
    /// Should be called when solid color parameters change.
    /// - Note: This function takes care of any currently shifting colors by immediately terminating the timer and resetting things
    ///         to a known value.
    private func NewBackgroundSolidColor()
    {
        UpdateHueShifting(Duration: 0.0)
        DrawBackground()
    }
    
    /// Updates gradient color shifting.
    /// - Note: Set `Duration` to `0.0` to turn off gradient color shifting.
    /// - Parameter Duration: Duration of the color shifts in the background gradient, in seconds.
    public func UpdateGradientShifting(Duration: Double)
    {
        if Duration <= 0.0
        {
            GradientTimer?.invalidate()
            GradientTimer = nil
            let BackgroundGradient = GradientManager.CreateGradientImage(From: CurrentTheme!.BackgroundGradientColor, WithFrame: self.frame)
            self.scene?.background.contents = BackgroundGradient
            return
        }
        ShiftingStops = GradientManager.ParseGradient(CurrentTheme!.BackgroundGradientColor, Vertical: &ShiftVertical, Reverse: &ShiftReversed)
        let Interval = Duration / 360.0
        GradientTimer = Timer.scheduledTimer(timeInterval: Interval, target: self, selector: #selector(UpdateShiftGradient),
                                             userInfo: nil, repeats: true)
    }
    
    /// Holds the working set of color stops when shifting gradient colors.
    private var ShiftingStops: [(UIColor, CGFloat)] = [(UIColor, CGFloat)]()
    
    /// Holds the original vertical flag in order to reassemble the gradient later.
    private var ShiftVertical: Bool = false
    
    /// Holds the original reverse flag in order to reassemble the gradient later.
    private var ShiftReversed: Bool = false
    
    /// The timer for shifting colors in the gradient.
    private var GradientTimer: Timer? = nil
    
    /// Shift the each color in the gradient by (1/360)° then update the background.
    @objc private func UpdateShiftGradient()
    {
        var NewStops = [(UIColor, CGFloat)]()
        for (Working, Stop) in ShiftingStops
        {
            var Hue = Working.Hue
            let Saturation = Working.Saturation
            let Brightness = Working.Brightness
            let Alpha = Working.Alpha()
            Hue = Hue + (1.0 / 360.0)
            if Hue > 1.0
            {
                Hue = 0.0
            }
            if Hue < 0.0
            {
                Hue = 1.0
            }
            let FinalColor = UIColor(hue: Hue, saturation: Saturation, brightness: Brightness, alpha: Alpha)
            NewStops.append((FinalColor, Stop))
        }
        let NewGradient = GradientManager.AssembleGradient(NewStops, IsVertical: ShiftVertical, Reverse: ShiftReversed)
        ShiftingStops = NewStops
        let BackgroundGradient = GradientManager.CreateGradientImage(From: NewGradient, WithFrame: self.frame)
        OperationQueue.main.addOperation
            {
                self.scene?.background.contents = BackgroundGradient
        }
    }
    
    /// Handle changes in the gradient background. Sets the color shifting to a known state (off).
    public func NewGradientColorBackground()
    {
        UpdateGradientShifting(Duration: 0.0)
        DrawBackground()
    }
    
    /// Draw the background according to the current theme.
    /// - Note: If we're running on the simulator, live view is ignored.
    public func DrawBackground()
    {
        switch CurrentTheme?.BackgroundType
        {
            case .Color:
                UpdateGradientShifting(Duration: 0.0)
                UpdateHueShifting(Duration: CurrentTheme!.BackgroundSolidColorCycleTime)
            
            case .Gradient:
                UpdateHueShifting(Duration: 0.0)
                UpdateGradientShifting(Duration: CurrentTheme!.BackgroundGradientCycleTime)
            
            case .Image:
                break
            
            case .CALayer:
                break
            
            case .Texture:
                break
            
            case .LiveView:
                if UserDefaults.standard.bool(forKey: "RunningOnSimulator")
                {
                    return
                }
                UpdateGradientShifting(Duration: 0.0)
                UpdateHueShifting(Duration: 0.0)
                var CameraPosition: AVCaptureDevice.Position!
                if CurrentTheme!.BackgroundLiveImageCamera == .Rear
                {
                    CameraPosition = .back
                }
                else
                {
                    CameraPosition = .front
                }
                let CaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: CameraPosition)!
                self.backgroundColor = UIColor.clear
                self.scene?.background.contents = CaptureDevice
            
            case .none:
                break
        }
    }
    
    /// Create the standard light using current theme data.
    /// - Returns: Scene node with light data.
    private func CreateGameLight() -> SCNNode
    {
        let Light = SCNLight()
        let LightColor = ColorServer.ColorFrom(CurrentTheme!.LightColor)
        Light.color = LightColor
        Light.categoryBitMask = View3D.GameLight
        switch CurrentTheme!.LightType
        {
            case .ambient:
                Light.type = .ambient
            
            case .spot:
                Light.type = .spot
            
            case .omni:
                Light.type = .omni
            
            case .directional:
                Light.type = .directional
        }
        Light.intensity = CGFloat(CurrentTheme!.LightIntensity)
        let Node = SCNNode()
        Node.name = "GameLight"
        Node.light = Light
        Node.position = CurrentTheme!.LightPosition
        return Node
    }
    
    /// Create the control light. This light is used for those nodes in the scene that are not directly game related, eg,
    /// motion buttons.
    /// - Returns: Node with the control light.
    private func CreateControlLight() -> SCNNode
    {
        let Light = SCNLight()
        Light.color = UIColor.white
        Light.type = .omni
        Light.shadowColor = UIColor.black
        #if false
        Light.castsShadow = true
        Light.automaticallyAdjustsShadowProjection = true
        Light.shadowSampleCount = 64
        Light.shadowRadius = 16
        Light.shadowMode = .deferred
        Light.shadowMapSize = CGSize(width: 2048, height: 2048)
        Light.shadowColor = UIColor.black.withAlphaComponent(0.75)
        #endif
        let Node = SCNNode()
        Node.name = "ControlLight"
        Node.light = Light
        Node.light?.categoryBitMask = View3D.ControlLight
        Node.position = SCNVector3(-3.0, 15.0, 50.0)
        return Node
    }
    
    public func AddPeskyLight()
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
    public func RemoveNodes(WithName: String)
    {
        NodeRemovalList.append(WithName)
    }
    
    /// Remove all nodes whose names are in the passed list.
    /// - Note:
    ///   - Any node whose name can be found in **WithNames** will be removed.
    /// - Parameter WithNames: The list of names for nodes to be removed.
    public func RemoveNodes(WithNames: [String])
    {
        if WithNames.isEmpty
        {
            return
        }
        NodeRemovalList.append(contentsOf: WithNames)
    }
    
    // MARK: Bucket-related functions.
    
    public var BucketNode: SCNNode? = nil
    
    /// Create a 3D bucket and add it to the scene. Attributes are from the current theme.
    /// - Parameter InitialOpacity: The initial opacity of the bucket. Defaults to 1.0.
    /// - Parameter Shape: The bucket's shape.
    /// - Returns: The bucket node.
    public func CreateBucket(InitialOpacity: CGFloat = 1.0, Shape: BucketShapes) -> SCNNode
    {
        if BucketNode != nil
        {
            //print("Removing bucket from parent.")
            BucketNode?.removeFromParentNode()
            //print("  Done removing bucket from parent.")
        }
        let LocalBucketNode = SCNNode()
        DrawGameBarriers(Parent: LocalBucketNode, InShape: Shape, InitialOpacity: InitialOpacity)
        _BucketAdded = true
        return LocalBucketNode
    }
    
    /// Flag indicating the bucket was added. Do we need this in this class?
    private var _BucketAdded: Bool = false
    
    /// Holds the center vertical line.
    public var CenterLineVertical: SCNNode? = nil
    
    /// Holds the center horizontal line.
    public var CenterLineHorizontal: SCNNode? = nil
    
    /// Holds a set of all visual blocks being displayed.
    public var BlockList = Set<VisualBlocks3D>()
    
    /// Determines if a block with the specified ID exists in the block list.
    /// - Parameter ID: The ID of the block to determine existences.
    /// - Returns: True if the block exists in the block list, false if not.
    public func BlockExistsInList(_ ID: UUID) -> Bool
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
    public func GetBlock(_ ID: UUID) -> VisualBlocks3D?
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
    weak public var SmoothMotionDelegate: SmoothMotionProtocol? = nil
    
    public func SmoothMoveCompleted(For: UUID)
    {
        //Not used in this class.
        fatalError("I told you this function shouldn't be called here!")
    }
    
    public func SmoothRotationCompleted(For: UUID)
    {
        //Not used in this class.
        fatalError("I told you this function shouldn't be called here!")
    }
    
    /// Called when the game is done moving a piece smoothly, eg, when it freezes into place.
    public func DoneWithSmoothPiece(_ ID: UUID)
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
    
    /// Holds the piece being moved smoothly.
    public var SmoothPiece: SCNNode? = nil
    /// Holds the ID of the piece being moved smoothly.
    public var SmoothPieceID: UUID = UUID.Empty
    
    /// Creates a new piece to move smoothly. If a piece already exists, it is deleted first.
    /// - Returns: The ID of the smoothly moving piece.
    public func CreateSmoothPiece() -> UUID
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
    
    /// Move a piece smoothly.
    /// - Note: Not currently implemented.
    public func MovePieceSmoothly(_ GamePiece: Piece, ToOffsetX: CGFloat, ToOffsetY: CGFloat, Duration: Double)
    {
        #if false
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
        #endif
    }
    
    /// Start a piece moving smoothly to the specified location.
    /// - Note: The delegate's `SmoothMoveCompleted` function is called upon completion.
    /// - Parameter GamePiece: The piece to move smoothly.
    /// - Parameter ToOffsetX: Offset horizontal value
    /// - Parameter ToOffsetY: Offset vertical value.
    /// - Parameter Duration: How long to take to move the piece.
    public func MovePieceSmoothlyX(_ GamePiece: Piece, ToOffsetX: CGFloat, ToOffsetY: CGFloat, Duration: Double)
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
    public var ExpectedAnimatedBlockCount: Int = 0
    
    /// Number of times the smooth move completion handler is called.
    public var AnimatedBlockCount: Int = 0
    
    /// Lock to prevent miscounting animation block completion handler calls.
    public var AnimatedBlockLock = NSObject()
    
    /// Called upon from each completion block of a smoothly moving piece. Once the number of calls matches the number of blocks
    /// being moved, the appropriate delegate function is called.
    public func AccumulateAnimatedBlocks()
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
    public func RotatePieceSmoothly(_ GamePiece: Piece, ByDegrees: CGFloat, Duration: Double,
                                    OnAxis: RotationalAxes = .X)
    {
        #if false
        let Radians = ByDegrees * CGFloat.pi / 180.0
        #endif
    }
    
    /// Show a piece such that the user knows it is being retired (eg, frozen).
    /// - Note: [How to add animations to change SCNNode's color](https://stackoverflow.com/questions/40472524/how-to-add-animations-to-change-sncnodes-color-scenekit)
    /// - Parameter Finalized: The piece that is freezing but not yet frozen.
    /// - Parameter Completion: Completion block.
    public func VisuallyRetirePiece(_ Finalized: Piece, Completion: (() -> ())?)
    {
        if MovingPieceNode != nil
        {
            let OriginalColor = MovingPieceNode!.childNodes[0].geometry?.firstMaterial?.diffuse.contents as! UIColor
            let ORed = OriginalColor.r
            let OGreen = OriginalColor.g
            let OBlue = OriginalColor.b
            let ColorChanger = SCNAction.customAction(duration: 0.1, action:
            {
                (Node, ElapsedTime) in
                let Percent = ElapsedTime / 5.0
                let NewColor = UIColor(red: ORed * Percent, green: OGreen * Percent, blue: OBlue * Percent, alpha: 1.0)
                Node.geometry!.firstMaterial!.diffuse.contents = NewColor
            })
            for Block in MovingPieceNode!.childNodes
            {
                Block.geometry?.firstMaterial?.diffuse.contents = UIColor.cyan
                Block.runAction(ColorChanger)
            }
        }
    }
    
    /// Create and add a block node for a piece.
    /// - Note: **Used for standard games.**
    /// - Parameter ParentID: The ID of the parent piece.
    /// - Parameter BlockID: The ID of the block node.
    /// - Parameter X: The initial X location of the node.
    /// - Parameter Y: The initial Y location of the node.
    /// - Parameter IsRetired: Initial retired status of the node.
    /// - Parameter ShapeID: The ID of the piece.
    public func AddBlockNode_Standard(ParentID: UUID, BlockID: UUID, X: Int, Y: Int, IsRetired: Bool, ShapeID: UUID)
    {
        //print("Adding standard block node to \(X),\(Y)")
        if let PVisual = PieceVisualManager2.UserVisuals!.GetVisualWith(ID: ShapeID)
        {
            let VBlock = VisualBlocks3D(BlockID, AtX: CGFloat(X), AtY: CGFloat(Y), ActiveVisuals: PVisual.ActiveVisuals!,
                                        RetiredVisuals: PVisual.RetiredVisuals!, IsRetired: IsRetired)
            VBlock.ParentID = ParentID
            VBlock.Marked = true
            VBlock.categoryBitMask = View3D.GameLight
            BlockList.insert(VBlock)
            self.scene?.rootNode.addChildNode(VBlock)
        }
        else
        {
            print("Error getting visuals for shape ID \(ShapeID)")
        }
    }
    
    /// Create and add a block node for a piece.
    /// - Note: **Used for rotating games.**
    /// - Parameter ParentID: The ID of the parent piece.
    /// - Parameter BlockID: The ID of the block node.
    /// - Parameter X: The initial X location of the node.
    /// - Parameter Y: The initial Y location of the node.
    /// - Parameter IsRetired: Initial retired status of the node.
    /// - Parameter ShapeID: The ID of the piece.
    public func AddBlockNode_Rotating(ParentID: UUID, BlockID: UUID, X: CGFloat, Y: CGFloat, IsRetired: Bool, ShapeID: UUID)
    {
        if let PVisual = PieceVisualManager2.UserVisuals!.GetVisualWith(ID: ShapeID)
        {
            let VBlock = VisualBlocks3D(BlockID, AtX: CGFloat(X), AtY: CGFloat(Y), ActiveVisuals: PVisual.ActiveVisuals!,
                                        RetiredVisuals: PVisual.RetiredVisuals!, IsRetired: IsRetired)
            VBlock.ParentID = ParentID
            VBlock.Marked = true
            VBlock.categoryBitMask = View3D.GameLight
            BlockList.insert(VBlock)
            MasterBlockNode!.addChildNode(VBlock)
        }
        else
        {
            print("Error getting visuals for shape ID \(ShapeID)")
        }
    }
    
    /// Remove all moving piece blocks from the master block node.
    public func UpdateMasterBlockNode()
    {
        if MasterBlockNode != nil
        {
            //print("Removing nodes from the MasterBlockNode")
            MasterBlockNode?.childNodes.forEach({
                if !($0 as! VisualBlocks3D).IsRetired
                {
                    $0.removeFromParentNode()
                }
            })
            //print("  Done removing nodes from the MasterBlockNode")
        }
    }
    
    public var MasterBlockNode: SCNNode? = nil
    
    /// Determines if a block should be drawn in **DrawMap3D**. Valid block types depend on the type of base game.
    /// - Note: This only determines if this class should draw the passed block - not whether it is valid or not.
    /// - Parameter BlockType: The block to check to see if it can be drawn or not.
    /// - Returns: True if the block should be drawn, false if not.
    private func ValidBlockToDraw(BlockType: PieceTypes) -> Bool
    {
        #if true
        return ![.Visible, .InvisibleBucket, .Bucket, .GamePiece, .BucketExterior].contains(BlockType)
        #else
        let BoardClass = BoardData.GetBoardClass(For: CenterBlockShape!)!
        switch BoardClass
        {
            case .Static:
                return ![.Visible, .InvisibleBucket, .Bucket].contains(BlockType)
            
            case .SemiRotatable:
            fallthrough
            case .Rotatable:
                return ![.Visible, .InvisibleBucket, .Bucket, .GamePiece, .BucketExterior].contains(BlockType)
            
            case .ThreeDimensional:
                return false
        }
        #endif
    }
    
    /// Contains a list of IDs of blocks that have been retired. Used to keep the game from moving them when they are no longer
    /// moveable.
    public var RetiredPieceIDs = [UUID]()
    
    // MARK: - Draw 3D piece.
    
    /// Draw the individual piece.
    /// - Note:
    ///    - If the piece type ID cannot be retrieved, control is returned immediately.
    ///    - If `GamePiece` has an ID that is in `RetiredPieceIDs`, control will be returned immeidately to prevent spurious
    ///      pieces from polluting the game board. Sometimes, most likely due to timers that haven't shut down, the board logic
    ///      will keep on trying to move the piece even after it is frozen into place. When that happens, the board will call
    ///      this function, adding a new moving piece even after it is frozen. When that happens, the piece appears to be unfrozen
    ///      when it should be frozen, and the piece doesn't move when the board is rotated.
    ///    - Depending on the map type, offset values are different, making the code a little more complex than I'd like.
    /// - Parameter InBoard: The current game board.
    /// - Parameter GamePiece: The piece to draw.
    /// - Parameter AsRetired: Determines if the piece is drawn as retired or active.
    public func DrawPiece3D(InBoard: Board, GamePiece: Piece, AsRetired: Bool = false)
    {
        if RetiredPieceIDs.contains(GamePiece.ID)
        {
            return
        }
        if MovingPieceNode != nil
        {
            MovingPieceNode?.removeFromParentNode()
        }
        
        let BoardDef = BoardManager.GetBoardFor(CenterBlockShape!)
        let IsOddlyShaped = !BoardDef!.GameBoardWidth.IsEven
        let XAdjustment: CGFloat = IsOddlyShaped ? -18.0 : -17.5
        let YAdjustment: CGFloat = IsOddlyShaped ? -1.0 : -1.5
        //let YStaticAdjustment: CGFloat = IsOddlyShaped ? 0.0 : -0.5
        
        MovingPieceBlocks = [VisualBlocks3D]()
        MovingPieceNode = SCNNode()
        MovingPieceNode?.name = "Moving Piece"
        let BoardType = BoardData.GetBoardClass(For: CenterBlockShape!)
        let PVisuals = PieceVisualManager2.UserVisuals!.GetVisualWith(ID: GamePiece.ShapeID)
        for Block in GamePiece.Locations!
        {
            if Block.ID == UUID.Empty
            {
                print("Block.ID is not set in DrawPiece3D")
                return
            }
            #if true
            let YOffset = (30 - 10 - 1) + YAdjustment - CGFloat(Block.Y)
            let XOffset = CGFloat(Block.X) + XAdjustment
            let VBlock = VisualBlocks3D(Block.ID, AtX: XOffset, AtY: YOffset, ActiveVisuals: PVisuals!.ActiveVisuals!,
                                        RetiredVisuals: PVisuals!.RetiredVisuals!, IsRetired: AsRetired)
            VBlock.categoryBitMask = View3D.GameLight
            MovingPieceBlocks.append(VBlock)
            MovingPieceNode?.addChildNode(VBlock)
            #else
            if BoardType == .Static
            {
                var YOffset: CGFloat = 0.0
                #if true
                YOffset = (30 - 10 - 1) - CGFloat(Block.Y) + YStaticAdjustment
                #else
                if UIDevice.current.userInterfaceIdiom == .phone
                {
                    YOffset = 9 - CGFloat(Block.Y) + YStaticAdjustment
                }
                else
                {
                    YOffset = 7 - CGFloat(Block.Y) + YStaticAdjustment
                }
                #endif
                let XOffset = CGFloat(Block.X) - 5.5
                let VBlock = VisualBlocks3D(Block.ID, AtX: XOffset, AtY: YOffset, ActiveVisuals: PVisuals!.ActiveVisuals!,
                                            RetiredVisuals: PVisuals!.RetiredVisuals!, IsRetired: AsRetired)
                
                VBlock.categoryBitMask = View3D.GameLight
                MovingPieceBlocks.append(VBlock)
                MovingPieceNode?.addChildNode(VBlock)
            }
            else
            {
                let YOffset = (30 - 10 - 1) + YAdjustment - CGFloat(Block.Y)
                let XOffset = CGFloat(Block.X) + XAdjustment
                let VBlock = VisualBlocks3D(Block.ID, AtX: XOffset, AtY: YOffset, ActiveVisuals: PVisuals!.ActiveVisuals!,
                                            RetiredVisuals: PVisuals!.RetiredVisuals!, IsRetired: AsRetired)
                VBlock.categoryBitMask = View3D.GameLight
                MovingPieceBlocks.append(VBlock)
                MovingPieceNode?.addChildNode(VBlock)
            }
            #endif
        }
        self.scene?.rootNode.addChildNode(MovingPieceNode!)
    }
    
    /// The moving piece is in its final location. Add its ID to the list of retired IDs and remove the moving blocks.
    /// - Note: This class also adds the finalized piece into the master bucket node, drawn as retired piece.
    /// - Parameter Finalized: The piece that was finalized.
    public func MergePieceIntoBucket(_ Finalized: Piece)
    {
        //let Pretty = MapType.PrettyPrint(Map: CurrentBoard!.Map!)
        //print("Merged map:\n\(Pretty)")
        RetiredPieceIDs.append(Finalized.ID)
        let BoardClass = BoardData.GetBoardClass(For: CenterBlockShape!)!
        var XOffset: CGFloat = 0.0
        var YOffset: CGFloat = 0.0
        let BoardDef = BoardManager.GetBoardFor(CenterBlockShape!)
        let IsOddlyShaped = !BoardDef!.GameBoardWidth.IsEven
        let XAdjustment: CGFloat = IsOddlyShaped ? -18.0 : -17.5
        let YAdjustment: CGFloat = IsOddlyShaped ? -1.0 : -1.5
        let BlockMap = CurrentBoard!.Map!.MergedBlockMap()
        let MergedMap = CurrentBoard!.Map!.MergeMap(Excluding: nil)
        
        for VBlock in MovingPieceBlocks
        {
            print("VBlock = \(VBlock.X),\(VBlock.Y)")
        }
        
        for Block in Finalized.Locations
        {
            print("Block = \(Block.X),\(Block.Y)")
            let ItemID = MergedMap[Block.Y][Block.X]
            let BlockID = BlockMap[Block.Y][Block.X]
            let PieceTypeID = CurrentBoard!.Map!.RetiredPieceShapes[ItemID]!
            #if true
            YOffset = (30 - 10 - 1) + YAdjustment - CGFloat(Block.Y)
            XOffset = CGFloat(Block.X) + XAdjustment
            AddBlockNode_Rotating(ParentID: ItemID, BlockID: BlockID, X: XOffset, Y: YOffset,
                                  IsRetired: true, ShapeID: PieceTypeID)
            #else
            switch BoardClass
            {
                case .Static:
                    if UIDevice.current.userInterfaceIdiom == .phone
                    {
                        YOffset = 9 - CGFloat(Block.Y)
                    }
                    else
                    {
                        YOffset = 7 - CGFloat(Block.Y)
                    }
                    XOffset = CGFloat(Block.X) - 5.5
                    AddBlockNode_Standard(ParentID: ItemID, BlockID: BlockID, X: Int(XOffset), Y: Int(YOffset),
                                          IsRetired: true, ShapeID: PieceTypeID)
                
                case .SemiRotatable:
                fallthrough
                case .Rotatable:
                    YOffset = (30 - 10 - 1) + YAdjustment - CGFloat(Block.Y)
                    XOffset = CGFloat(Block.X) + XAdjustment
                    AddBlockNode_Rotating(ParentID: ItemID, BlockID: BlockID, X: XOffset, Y: YOffset,
                                          IsRetired: true, ShapeID: PieceTypeID)
                
                case .ThreeDimensional:
                    break
            }
            #endif
        }

        RemoveMovingPiece()
    }
    
    /// Perform a fast drop execution on the supplied piece.
    /// - Parameter WithPiece: The piece to drop quickly.
    /// - Parameter DeltaX: The relative number of grid points to move horizontally.
    /// - Parameter DeltaY: The relative number of grid points to move vertically.
    /// - Parameter TotalDuration: The amount of time to take to drop.
    /// - Parameter Completed: Completion block.
    public func MovePieceRelative(WithPiece: Piece, DeltaX: Int, DeltaY: Int, TotalDuration Duration: Double, Completed: ((Piece)->())?)
    {
        print("At MovePieceRelative: DeltaX=\(DeltaX), DeltaY=\(DeltaY), TotalDuration=\(Duration)")
        MovingPieceNode?.enumerateChildNodes
            {
                Node, _ in
                let NewLocation = SCNVector3(Node.position.x + Float(DeltaX), Node.position.y + Float(DeltaY), Node.position.z)
                let Move = SCNAction.move(to: NewLocation, duration: Duration)
                Node.runAction(Move, completionHandler:
                    {
                        Completed?(WithPiece)
                })
        }
    }
    
    /// Array of visual blocks that represent the moving piece.
    public var MovingPieceBlocks = [VisualBlocks3D]()
    
    /// Remove the moving piece, if it exists.
    public func RemoveMovingPiece()
    {
        let BoardClass = BoardData.GetBoardClass(For: CenterBlockShape!)!
        if BoardClass == .Rotatable
        {
            //print("Removing moving piece in rotating game.")
            if MovingPieceNode != nil
            {
                MovingPieceNode!.removeFromParentNode()
                MovingPieceNode = nil
                UpdateMasterBlockNode()
            }
            //print("  Done removing piece from rotating game.")
        }
    }
    
    /// The SceneKit representation of the moving piece.
    public var MovingPieceNode: SCNNode? = nil
    
    /// Visually clear the bucket of pieces.
    /// - Note:
    ///   - Should be called only after the game is over.
    ///   - All retired piece IDs are removed.
    /// - Parameter FromBoard: The board that contains the map to draw. *Not currently used.*
    /// - Parameter DestroyBy: Determines how to empty the bucket.
    /// - Parameter MaxDuration: Maximum amount of time (in seconds) to take to clear the board.
    /// - Parameter DelayStartBy: Number of seconds to wait before starting to clean the bucket. Defaults to 0.0.
    public func DestroyMap3D(FromBoard: Board, DestroyBy: DestructionMethods, MaxDuration: Double, DelayStartBy: Double = 0.0)
    {
        objc_sync_enter(RotateLock)
        defer{objc_sync_exit(RotateLock)}
        BucketCleaner(DestroyBy, MaxDuration: MaxDuration, DelayStartBy: DelayStartBy)
    }
    
    // MARK: - Board map drawing.
    
    /// Draw the 3D game view map. Includes moving pieces.
    /// - Note:
    ///    - To keep things semi-efficient, 3D objects are only created when they first appear in the game board.
    ///      Once there, they are moved as needed rather than creating new ones in new locations.
    ///    - This function assumes the board changes between each piece.
    /// - Parameter FromBoard: The board that contains the map to draw.
    public func DrawMap3D(FromBoard: Board, CalledFrom: String = "")
    {
        objc_sync_enter(RotateLock)
        defer{ objc_sync_exit(RotateLock) }
        
        let BoardClass = BoardData.GetBoardClass(For: CenterBlockShape!)!
        let BoardDef = BoardManager.GetBoardFor(CenterBlockShape!)
        let IsOddlyShaped = !BoardDef!.GameBoardWidth.IsEven
        let XAdjustment: CGFloat = IsOddlyShaped ? -18.0 : -17.5
        let YAdjustment: CGFloat = IsOddlyShaped ? 0.0 : -1.0
        let ExistingBlockYOffset: CGFloat = IsOddlyShaped ? 0.0 : -0.5
        let XFinalAdjustment: CGFloat = IsOddlyShaped ? 0.0 : 0.0
        let YFinalAdjustment: CGFloat = IsOddlyShaped ? -1.0 : -0.5
        
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
                if ItemType == nil
                {
                    print(">>>>>>>>>>>>> Unexpected ID found: \(ItemID.uuidString)")
                    continue
                }
                if !ValidBlockToDraw(BlockType: ItemType!)
                {
                    //The block type isn't drawable so there is nothing to do...
                    continue
                }
                
                //Generate offsets to ensure the block is in the proper position in the 3D scene.
                var YOffset: CGFloat = 0
                var XOffset: CGFloat = 0
                #if true
                YOffset = (30 - 10 - 1) + YAdjustment - CGFloat(Y)
                XOffset = CGFloat(X) + XAdjustment
                #else
                switch BoardClass
                {
                    case .SemiRotatable:
                    fallthrough
                    case .Rotatable:
                        #if true
                        YOffset = (30 - 10 - 1) + YAdjustment - CGFloat(Y)
                        #else
                        YOffset = (30 - 10 - 1) - 1.0 - CGFloat(Y)
                        #endif
                        XOffset = CGFloat(X) + XAdjustment// - 17.5
                    
                    case .Static:
                        if UIDevice.current.userInterfaceIdiom == .phone
                        {
                            YOffset = 9 - CGFloat(Y)
                        }
                        else
                        {
                            YOffset = 7 - CGFloat(Y)
                        }
                        XOffset = CGFloat(X) - 5.5
                    
                    case .ThreeDimensional:
                        XOffset = 0
                        YOffset = 0
                }
                #endif
                
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
                        let NewY = CGFloat(YOffset) + ExistingBlockYOffset//- 0.5
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
                    //Add blocks not in the block list to the list here.
                    let PieceTypeID = CurrentMap.RetiredPieceShapes[ItemID]!
                    if BoardClass == .Rotatable
                    {
                        XOffset = XOffset + XFinalAdjustment
                        YOffset = YOffset + YFinalAdjustment//- 0.5
                    }
                    #if true
                    AddBlockNode_Rotating(ParentID: ItemID, BlockID: BlockID, X: XOffset, Y: YOffset,
                                          IsRetired: IsRetired, ShapeID: PieceTypeID)
                    #else
                    switch BoardClass
                    {
                        case .Static:
                            AddBlockNode_Standard(ParentID: ItemID, BlockID: BlockID, X: Int(XOffset), Y: Int(YOffset),
                                                  IsRetired: IsRetired, ShapeID: PieceTypeID)
                        
                        case .SemiRotatable:
                        fallthrough
                        case .Rotatable:
                            AddBlockNode_Rotating(ParentID: ItemID, BlockID: BlockID, X: XOffset, Y: YOffset,
                                                  IsRetired: IsRetired, ShapeID: PieceTypeID)
                        
                        case .ThreeDimensional:
                            break
                    }
                    #endif
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
    
    /// Sets the board to use by the view (and indirectly sets the map as well).
    /// - Parameter TheBoard: The board to use when drawing the game.
    public func SetBoard(_ TheBoard: Board)
    {
        CurrentBoard = TheBoard
        CurrentMap = TheBoard.Map
    }
    
    /// Holds the board in which we are working.
    public var CurrentBoard: Board? = nil
    
    /// Holds the map for the current board.
    public var CurrentMap: MapType? = nil
    
    /// Creates the master block node. This is the node in which all blocks are placed. This is done to allow for
    /// easy rotation of blocks when needed.
    public func CreateMasterBlockNode()
    {
        if MasterBlockNode != nil
        {
            //print("Removing everything from master block node.")
            MasterBlockNode!.removeAllActions()
            MasterBlockNode!.removeFromParentNode()
            MasterBlockNode = nil
            //print("  Done removing everything from master block node.")
        }
        MasterBlockNode = SCNNode()
        MasterBlockNode!.name = "Master Block Node"
        self.scene?.rootNode.addChildNode(MasterBlockNode!)
    }
    
    /// Clear the bucket of all pieces.
    /// - Note: The bucket will not be cleared if the view is rotating.
    public func ClearBucket()
    {
        objc_sync_enter(RotateLock)
        defer{objc_sync_exit(RotateLock)}
        CreateMasterBlockNode()
        //print("Clearing the bucket.")
        for Node in BlockList
        {
            Node.removeAllActions()
            Node.removeFromParentNode()
        }
        //print("  Done clearing the bucket.")
        #if true
        //print("Removing all blocks from BlockList.")
        BlockList.removeAll()
        //print("  Done removing all blocks from BlockList.")
        #else
        OperationQueue.main.addOperation
            {
                //Sometimes this call seems to trigger an exception from within SceneKit.
                self.BlockList.removeAll()
        }
        #endif
    }
    
    /// Empty the map of all block nodes.
    public func EmptyMap()
    {
        //print("Emptying the map.")
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
        //print("  Done emptying the map.")
    }
    
    /// Not currently implemented.
    public func LayoutCompleted()
    {
    }
    
    /// Not currently implemented.
    public func Resized()
    {
        CurrentSize = frame
    }
    
    /// Holds the current size.
    public var CurrentSize: CGRect? = nil
    
    // MARK: - Bucket grid variables.
    
    /// The node that holds the set of bucket grid lines.
    public var BucketGridNode: SCNNode? = nil
    
    /// The node that holds the outline.
    public var OutlineNode: SCNNode? = nil
    
    /// Synchronization object that defines access to the bucket.
    public var CanUseBucket: NSObject = NSObject()
    
    // MARK: - Bucket rotatation variables.
    
    /// Not implemented.
    public func MovePiece(_ ThePiece: Piece, ToLocation: CGPoint, Duration: Double,
                          Completion: ((UUID) -> ())? = nil)
    {
    }
    
    /// Not implemented.
    public func RotatePiece(_ ThePiece: Piece, Degrees: Double, Duration: Double,
                            Completion: ((UUID) -> ())? = nil)
    {
    }
    
    /// Not implemented.
    public func DrawPiece(_ ThePiece: Piece, SurfaceSize: CGSize)
    {
    }
    
    /// Lock used when the board is rotating.
    public var RotateLock = NSObject()
    
    /// Timer that controls showing off rotations.
    var ShowOffTimer: Timer? = nil
    
    /// Change the color of the bucket.
    /// - Note:
    ///   - Intended for use for debugging.
    ///   - `BucketNode` and all of its children (if any) have the diffuse surface set.
    public func ChangeBucketColor()
    {
        let NewColor = ColorServer.DarkRandomColor()
        BucketNode?.geometry?.firstMaterial?.diffuse.contents = NewColor
        BucketNode?.enumerateChildNodes(
            {
                Node, _ in
                Node.geometry?.firstMaterial?.diffuse.contents = NewColor
        })
    }
    
    /// Indicates which cardinal direction a rotation is.
    public var RotationCardinalIndex = 0
    
    /// 90° expressed in radians.
    public let HalfPi = CGFloat.pi / 2.0
    
    /// Sets the opacity level of the entire board to the specified value.
    /// - Parameter To: The new alpha/opacity level.
    /// - Parameter Duration: The duration of the opacity change.
    /// - Parameter Completed: Completion block.
    public func SetBoardOpacity(To: Double, Duration: Double, Completed: (() -> ())? = nil)
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
    
    /// Holds the scene node ID.
    public var SceneNodeID = UUID()
    
    /// Holds the max scene node ID.
    public var MaxSceneNodeID = UUID()
    
    /// Holds the max scene node count.
    public var MaxSceneNodes: Int = 0
    
    /// Handle the piece out of bounds state (which indicates game over).
    /// - Note: [Animated SCNNode Forever](https://stackoverflow.com/questions/29658772/animate-scnnode-forever-scenekit-swift)
    /// - Parameter ID: The ID of the node that froze out of bounds.
    public func PieceOutOfBounds(_ ID: UUID)
    {
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "Game", Source: "View3D", KVPs: [("Message","Piece out of bounds. Freezing in place."),("PieceID",ID.uuidString)],
                             LogFileName: &NotUsed)
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
        let BoardClass = BoardData.GetBoardClass(For: CenterBlockShape!)!
        #if true
        for Block in MovingPieceBlocks
        {
            FinalBlocks.append(Block)
            BlockList.insert(Block)
        }
        #else
        switch BoardClass
        {
            case .Static:
                for Block in BlockList
                {
                    if Block.ParentID == ID
                    {
                        FinalBlocks.append(Block)
                    }
            }
            
            case .SemiRotatable:
            fallthrough
            case .Rotatable:
                for Block in MovingPieceBlocks
                {
                    FinalBlocks.append(Block)
                    BlockList.insert(Block)
            }
            
            case .ThreeDimensional:
                break
        }
        #endif
        
        let StartColor = UIColor.yellow
        let EndColor = UIColor.red
        for Block in FinalBlocks
        {
            Block.geometry?.firstMaterial?.diffuse.contents = UIColor.yellow
        }
        var RDelta = EndColor.r - StartColor.r
        var GDelta = EndColor.g - StartColor.g
        var BDelta = EndColor.b - StartColor.b
        let FinalDuration = 0.5
        let ColorToRed = SCNAction.customAction(duration: FinalDuration, action:
        {
            (Node, Time) in
            let Percent: CGFloat = Time / CGFloat(FinalDuration)
            let Red = abs(EndColor.r + (RDelta * Percent))
            let Green = abs(EndColor.g + (GDelta * Percent))
            let Blue = abs(EndColor.b + (BDelta * Percent))
            Node.geometry?.firstMaterial?.diffuse.contents = UIColor(red: Red, green: Green, blue: Blue, alpha: 1.0)
        }
        )
        RDelta = StartColor.r - EndColor.r
        GDelta = StartColor.g - EndColor.g
        BDelta = StartColor.b - EndColor.b
        let ColorToYellow = SCNAction.customAction(duration: FinalDuration, action:
        {
            (Node, Time) in
            let Percent: CGFloat = Time / CGFloat(FinalDuration)
            let Red = abs(StartColor.r - (RDelta * Percent))
            let Green = abs(StartColor.g - (GDelta * Percent))
            let Blue = abs(StartColor.b - (BDelta * Percent))
            Node.geometry?.firstMaterial?.diffuse.contents = UIColor(red: Red, green: Green, blue: Blue, alpha: 1.0)
        }
        )
        let Wait = SCNAction.wait(duration: 0.05)
        let Sequence = SCNAction.sequence([ColorToRed, Wait, ColorToYellow, Wait])
        let Forever = SCNAction.repeatForever(Sequence)
        for Block in FinalBlocks
        {
            Block.runAction(Forever)
        }
    }
    
    /// Holds a list of blocks to finalize.
    public var FinalBlocks = [VisualBlocks3D]()
    /// Timer to visually indicate freezing.
    public var FrozenTimer: Timer!
    
    /// Not currently implemented.
    @objc public func HighlightFrozenBlocks()
    {
        
    }
    
    /// Not currently implemented.
    public func StartedFreezing(_ ID: UUID)
    {
    }
    
    /// Not currently implemented.
    public func StoppedFreezing(_ ID: UUID)
    {
    }
    
    /// Return the current frame rate.
    /// - Returns: Current frame rate.
    public func FrameRate() -> Double?
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
    public var LastUpdateTime: TimeInterval = 0.0
    
    /// The last calculated framerate.
    public var LastFrameRate: Double = 0.0
    
    /// Not currently implemented.
    public func SetOpacity(OfID: UUID, To: Double)
    {
    }
    
    /// Sets the opacity of the passed block type to the passed value.
    /// - Parameter OfID: The ID of the block whose opacity will be set.
    /// - Parameter To: The new opacity level.
    /// - Parameter Duration: The amount of time to run the opacity change action.
    public func SetOpacity(OfID: UUID, To: Double, Duration: Double)
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
    public var CurrentTheme: ThemeDescriptor2? = nil
    
    /// Not currently implemented.
    public func Refresh()
    {
    }
    
    // MARK: - ThreeDProtocol function implementations.
    
    /// Set the camera node's camera data. Used mainly for debugging purposes.
    /// - Parameter FOV: The FOV (field of view) parameter for the camera.
    /// - Parameter Position: The position of the camera node.
    /// - Parameter Orientation: The orientation of the camera node.
    public func SetCameraData(FOV: CGFloat, Position: SCNVector3, Orientation: SCNVector4)
    {
        CameraNode!.camera!.fieldOfView = FOV
        CameraNode!.position = Position
        CameraNode!.orientation = Orientation
    }
    
    /// Returns current camera data (mostly for debugging purposes).
    /// - Returns: Tuple in the order (camera field of view, camera node position, camera node orientation).
    public func GetCameraData() -> (CGFloat, SCNVector3, SCNVector4)
    {
        return (CameraNode!.camera!.fieldOfView, CameraNode!.position, CameraNode!.orientation)
    }
    
    /// Set parameters for the main lighting node. Used mainly for debugging purposes.
    /// - Parameter Position: The position of the light node.
    /// - Parameter LightingType: The type of light.
    /// - Parameter ColorName: The name of the color the light emits.
    /// - Parameter UseDefault: If true, default lighting is used.
    public func SetLightData(Position: SCNVector3, LightingType: SCNLight.LightType, ColorName: String,
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
    public func GetLightData() -> (SCNVector3, SCNLight.LightType, String, Bool)
    {
        let TheColor: UIColor = (LightNode.light?.color as? UIColor)!
        let ColorName = ColorServer.MakeColorName(From: TheColor)
        return (LightNode.position, LightNode.light!.type, ColorName!, self.autoenablesDefaultLighting)
    }
    
    // MARK: - Text layer protocol function implementation
    
    /// Handle double click events relayed to us by the text layer. Double click events will cause the camera to be reset
    /// to it's theme-appropriate values.
    public func MouseDoubleClick(At: CGPoint)
    {
        self.pointOfView?.position = OriginalCameraPosition!
        self.pointOfView?.orientation = OriginalCameraOrientation!
    }
    
    // MARK: - Heartbeat functions.
    
    /// Flag that indicates visibility of the heartbeat indicator.
    public var ShowingHeart = false
    
    /// Set the heartbeat visibility flag.
    /// - Parameter Show: If true, the indicator is shown. If false, the indicator is hidden.
    public func SetHeartbeatVisibility(Show: Bool)
    {
        if Show == ShowingHeart
        {
            return
        }
        ShowingHeart = Show
        if ShowingHeart
        {
            AppendButton(Which: .HeartButton)
        }
        else
        {
            RemoveButton(Which: .HeartButton)
        }
    }
    
    /// Holds the heartbeat indicator highlighted flag.
    private var HeartHighlighted = false
    
    /// Toggle the heartbeat highlight state.
    public func ToggleHeartState()
    {
        HeartHighlighted = !HeartHighlighted
        if HeartHighlighted
        {
            SetButtonColorToHighlight(Button: .HeartButton)
        }
        else
        {
            SetButtonColorToNormal(Button: .HeartButton)
        }
    }
    
    // MARK: - Visual debug functions.
    
    /// Run a debug command.
    /// - Note:
    ///   - Commands are:
    ///     - `Show`: Show an object or objects. See following list for objects.
    ///        - `Regions`: Regions of the game board.
    ///        - `Barriers`: Game board barriers.
    ///        - `Grid`: Background grid.
    ///        - `Heart`: Heartbeat indicator.
    ///        - `Controls`: Motion controls.
    ///     - `Hide`: Hide an object or objects. See `Show` for objects.
    ///     - `Dump`: Dump and object to the debug folder. See following list for dumpable objects.
    ///        - `Boards`: Dumps images of all boards to the debug folder.
    /// - Parameter Command: The command string to run. Case insensitive.
    /// - Returns: Depending on the command, there may or may not be a returned value. If there *is* a returned value, the
    ///            type depends on the context of the command.
    @discardableResult public func Debug(_ Command: String) -> Any?
    {
        let Raw = Command.lowercased().trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let Parts = Raw.split(separator: " ", omittingEmptySubsequences: true)
        if Parts.count < 2
        {
            return nil
        }
        switch String(Parts[0])
        {
            case "dump":
                switch String(Parts[1])
                {
                    case "boards":
                        SaveAllBucketImages()
                    
                    default:
                        break
            }
            
            case "show":
                switch String(Parts[1])
                {
                    case "regions":
                        ShowRegions(Show: true)
                    
                    case "barriers":
                        break
                    
                    case "grid":
                        break
                    
                    case "heart":
                        break
                    
                    case "controls":
                        break
                    
                    default:
                        print("Unknown show option (\(String(Parts[1]))) encountered.")
                        return nil
            }
            
            case "hide":
                switch String(Parts[1])
                {
                    case "regions":
                        ShowRegions(Show: false)
                    
                    case "barriers":
                        break
                    
                    case "grid":
                        break
                    
                    case "heart":
                        break
                    
                    case "controls":
                        break
                    
                    default:
                        print("Unknown show option (\(String(Parts[1]))) encountered.")
                        return nil
            }
            
            default:
                print("Unknown Debug command (\(String(Parts[0]))) encountered.")
                return nil
        }
        return nil
    }
    
    /// Colors to use for debug layers.
    public let LayerColors: [DebugRegions: UIColor] =
        [
            .BucketInterior: UIColor.systemYellow,
            .Barrier: UIColor.systemIndigo,
            .InvisibleBarrier: UIColor.systemTeal,
            .Exterior: UIColor.systemBlue
    ]
    
    /// Dictionary of layers.
    public var RegionLayers: [DebugRegions: SCNNode] = [DebugRegions: SCNNode]()
    
    // MARK: - Variables for buttons and button state. Button functions are found in +TextButtons.swift.
    
    /// Map of button types to button nodes.
    public var ButtonList: [NodeButtons: SCNButtonNode] = [NodeButtons: SCNButtonNode]()
    
    /// Map of button node information.
    public var ButtonDictionary: [NodeButtons: (Location: SCNVector3, Scale: Double, Color: UIColor, Highlight: UIColor)] =
        [NodeButtons: (Location: SCNVector3, Scale: Double, Color: UIColor, Highlight: UIColor)]()
    
    /// Dictionary between node button types and the system image name and location of each node.
    /// Intended for use with devices with reasonable-sized screens.
    public let BigButtonDictionary: [NodeButtons: (Location: SCNVector3, Scale: Double, Color: UIColor, Highlight: UIColor)] =
        [
            .MainButton: (SCNVector3(-10.3, 13.7, 1.0), 0.06, UIColor.white, UIColor.yellow),
            .FPSButton: (SCNVector3(-8.5, 13.0, 1.0), 0.03, UIColor.white, UIColor.yellow),
            .PlayButton: (SCNVector3(3.0, 13.0, 1.0), 0.03, UIColor.white, UIColor.red),
            .PauseButton: (SCNVector3(6.5, 13.0, 1.0), 0.03, UIColor.white, UIColor.red),
            .VideoButton: (SCNVector3(-2.8, 13.0, 1.0), 0.025, UIColor.white, UIColor.red),
            .CameraButton: (SCNVector3(0.0, 13.0, 1.0), 0.025, UIColor.white, UIColor.red),
            
            .LeftButton: (SCNVector3(-11.2, -13.2, 1.0), 0.08, UIColor.white, UIColor.yellow),
            .RotateLeftButton: (SCNVector3(-11.2, -15.5, 1.0), 0.08, UIColor.white, UIColor.yellow),
            .UpButton: (SCNVector3(-8.5, -15.5, 1.0), 0.08, UIColor.white, UIColor.yellow),
            .DownButton:  (SCNVector3(-8.5, -13.2, 1.0), 0.08, UIColor.white, UIColor.yellow),
            
            .RightButton:  (SCNVector3(9.2, -13.2, 1.0), 0.08, UIColor.white, UIColor.yellow),
            .DropDownButton:  (SCNVector3(6.5, -13.2, 1.0), 0.08, UIColor.systemGreen, UIColor.yellow),
            .FlyAwayButton:  (SCNVector3(6.5, -15.5, 1.0), 0.08, UIColor.systemBlue, UIColor.yellow),
            .RotateRightButton:  (SCNVector3(9.2, -15.5, 1.0), 0.08, UIColor.white, UIColor.yellow),
            
            .FreezeButton: (SCNVector3(-1.0, -15.5, 1.0), 0.08, UIColor.cyan, UIColor.blue),
            
            .HeartButton: (SCNVector3(9.7, 7.7, 1.0), 0.05, UIColor.systemPink, UIColor.red)
    ]
    
    /// Dictionary between node button types and the system image name and location of each node. Intended for use with
    /// devices with small screens.
    public let SmallButtonDictionary: [NodeButtons: (Location: SCNVector3, Scale: Double, Color: UIColor, Highlight: UIColor)] =
        [
            .MainButton: (SCNVector3(-7.2, 13.5, 1.0), 0.08, UIColor.white, UIColor.yellow),
            .FPSButton: (SCNVector3(-5.5, 13.0, 1.0), 0.03, UIColor.white, UIColor.yellow),
            .PlayButton: (SCNVector3(0.0, 13.0, 1.0), 0.03, UIColor.white, UIColor.red),
            .PauseButton: (SCNVector3(4.5, 13.0, 1.0), 0.03, UIColor.white, UIColor.red),
            .VideoButton: (SCNVector3(-1.8, 13.0, 1.0), 0.025, UIColor.white, UIColor.red),
            .CameraButton: (SCNVector3(0.0, 13.0, 1.0), 0.025, UIColor.white, UIColor.red),
            
            .LeftButton: (SCNVector3(-8.2, -12.95, 1.0), 0.07, UIColor.white, UIColor.yellow),
            .DownButton:  (SCNVector3(-6.0, -12.95, 1.0), 0.07, UIColor.white, UIColor.yellow),
            .RotateLeftButton: (SCNVector3(-8.2, -15.25, 1.0), 0.07, UIColor.white, UIColor.yellow),
            .UpButton: (SCNVector3(-6, -15.25, 1.0), 0.07, UIColor.white, UIColor.yellow),
            
            .RightButton:  (SCNVector3(6.2, -12.95, 1.0), 0.07, UIColor.white, UIColor.yellow),
            .DropDownButton:  (SCNVector3(4.0, -12.95, 1.0), 0.07, UIColor.systemGreen, UIColor.yellow),
            .FlyAwayButton:  (SCNVector3(4.0, -15.25, 1.0), 0.07, UIColor.systemBlue, UIColor.yellow),
            .RotateRightButton:  (SCNVector3(6.2, -15.25, 1.0), 0.07, UIColor.white, UIColor.yellow),
            
            .FreezeButton: (SCNVector3(-1.0, -15.25, 1.0), 0.07, UIColor.cyan, UIColor.blue),
            
            .HeartButton: (SCNVector3(9.2, 6.5, 1.0), 0.05, UIColor.systemPink, UIColor.red)
    ]
    
    /// Holds the main button.
    public var MainButtonObject: SCNNode? = nil
    
    /// Holds the top button set background node.
    public var ControlBackground: SCNNode? = nil
    
    /// Holds the set of disabled controls.
    public var _DisabledControls: Set<NodeButtons> = Set<NodeButtons>()
    
    /// Adjust horizontal values in the passed vector if we're running on a small device.
    /// - Parameter V: The original vector.
    /// - Returns: Possibly changed vector. If running on an iPad, the same value is returned.
    public func AdjustForSmallScreens(_ V: SCNVector3) -> SCNVector3
    {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            var X = V.x
            if X <= 1.0 && X >= -1.0
            {
                return V
            }
            if X < 0.0
            {
                X = X + 3.0
            }
            else
            {
                X = X - 3.0
            }
            return SCNVector3(X, V.y, V.z)
        }
        return V
    }
    
    // MARK: - Bucket cleaning variables.
    
    /// Holds the cleaning method. Used when `BucketCleaner` is called with a non-zero `DelayStartBy` value.
    public var CleaningMethod: DestructionMethods = .None
    
    /// Holds the amount of time to take to clean the bucket. Used when `BucketCleaner` is called with a non-zero `DelayStartBy` value.
    public var CleaningDuration: Double = 0.01
    
    // MARK: - Renderer variables.
    
    /// Nodes to remove.
    public var NodeRemovalList = [String]()
    
    /// Objects to remove.
    public var ObjectRemovalList = Set<GameViewObjects>()
    
    // MARK: - About box variables.
    
    /// Main about/version box node.
    public var AboutBoxNode: SCNNode? = nil
    
    /// Flag that indicates the about box is showing.
    public var AboutBoxShowing: Bool = false
    
    /// Timer to hide the about box node.
    public var AboutBoxHideTimer: Timer? = nil
    
    /// The light for the about box.
    public var AboutLightNode: SCNNode? = nil
}

// MARK: - Global enums related to 3DView.

/// Game view objects.
enum GameViewObjects: String, CaseIterable
{
    /// The bucket.
    case Bucket = "Bucket"
    /// The bucket background grid.
    case BucketGrid = "BucketGrid"
    /// Bucket grid outline.
    case BucketGridOutline = "BucketGridOutline"
}

/// Ordinal angles in degrees.
enum Angles: CGFloat, CaseIterable
{
    /// 0°
    case Angle0 = 0.0
    /// 90°
    case Angle90 = 90.0
    /// 180°
    case Angle180 = 180.0
    /// 270°
    case Angle270 = 270.0
}

/// Set of motion control buttons built in to the game surface.
enum NodeButtons: String, CaseIterable
{
    /// Button to move the piece to the left.
    case LeftButton = "LeftButton"
    /// Button to the the piece up.
    case UpButton = "UpButton"
    /// Button to move the button down.
    case DownButton = "DownButton"
    /// Button to move the piece to the right.
    case RightButton = "RightButton"
    /// Button to drop the button down.
    case DropDownButton = "DropDownButton"
    /// Button to discard the button.
    case FlyAwayButton = "FlyAwayButton"
    /// Button to rotate the piece counter-clockwise.
    case RotateLeftButton = "RotateLeftButton"
    /// Button to rotate the piece clockwise.
    case RotateRightButton = "RotateRightButton"
    /// Button to freeze the piece in its tracks.
    case FreezeButton = "FreezeButton"
    /// Heartbeat button indicator.
    case HeartButton = "HeartButton"
    /// Main menu button.
    case MainButton = "MainButton"
    /// Flame button - *no longer used*.
    case FlameButton = "FlameButton"
    /// Video button.
    case VideoButton = "VideoButton"
    /// Camera button.
    case CameraButton = "CameraButton"
    /// Play button.
    case PlayButton = "PlayButton"
    /// Pause button.
    case PauseButton = "PauseButton"
    /// FPS "button" - more of a text label.
    case FPSButton = "FPSButton"
}

/// Enumeration of the three 3D axes.
enum Axes: String, CaseIterable
{
    /// The X axis.
    case XAxis = "X"
    /// The Y axis.
    case YAxis = "Y"
    /// The Z axis.
    case ZAxis = "Z"
}
