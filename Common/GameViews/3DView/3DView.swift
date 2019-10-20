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
    weak var Main: MainDelegate? = nil
    
    /// The scene that is shown in the 3D view.
    var GameScene: SCNScene!
    
    /// Light mask for the game.
    let GameLight: Int = 0x1 << 1
    
    /// Light mask for the controls.
    let ControlLight: Int = 0x1 << 2
    
    /// Light mask for the about box.
    let AboutLight: Int = 0x1 << 3
    
    // MARK: - Initialization.
    
    #if true
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
        print("View3D Frame=\(self.frame)")
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
        
        let Node = CreateBucket(InitialOpacity: 1.0, Shape: CenterBlockShape)
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
    #else
    /// Initialize the view.
    /// - Note: Setting 'self.showsStatistics' to true will lead to the scene freezing after a period of time (on the order of
    ///         hours). Likewise, setting `self.allowsCameraControl` will lead to non-responsiveness in the UI after a period
    ///         of time (on the order of tens of minutes). Therefore, using those two properties should be transient and for
    ///         debug use only.
    /// - Parameter With: The board to use for displaying contents.
    /// - Parameter Theme: The theme manager instance.
    /// - Parameter BaseType: The base game type. Can only be set via this function.
    func Initialize(With: Board, Theme: ThemeManager3, BaseType: BaseGameTypes)
    {
        print("View3D Frame=\(self.frame)")
        self.isUserInteractionEnabled = true
        //MasterBlockNode = SCNNode()
        CenterBlockShape = .Square
        self.rendersContinuously = true
        CreateMasterBlockNode()
        _BaseGameType = BaseType
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
        
        let Node = CreateBucket(InitialOpacity: 1.0, Shape: CenterBlockShape)
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
    #endif
    
    func NewParentSize(Bounds: CGRect, Frame: CGRect)
    {
        
    }
    
    /// The theme was updated. See what changed and take the appropriate action.
    /// - Parameter ThemeName: The name of the theme that changed.
    /// - Parameter Field: The field that changed.
    func ThemeUpdated(ThemeName: String, Field: ThemeFields)
    {
        print("Theme \(ThemeName) updated field \(Field)")
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
                    print("Camera field of view changed to \(CurrentTheme!.CameraFieldOfView)")
                
                default:
                    break
            }
        }
    }
    
    var CenterBlockShape: BucketShapes = .Square
    
    #if false
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
    #endif
    
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
    @objc func UpdateSolidColorBackground()
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
    var WorkingColor: UIColor = UIColor.white
    
    /// Timer for shifting the color of the background.
    var HueTimer: Timer? = nil
    
    /// Should be called when solid color parameters change.
    /// - Note: This function takes care of any currently shifting colors by immediately terminating the timer and resetting things
    ///         to a known value.
    func NewBackgroundSolidColor()
    {
        UpdateHueShifting(Duration: 0.0)
        DrawBackground()
    }
    
    /// Updates gradient color shifting.
    /// - Note: Set `Duration` to `0.0` to turn off gradient color shifting.
    /// - Parameter Duration: Duration of the color shifts in the background gradient, in seconds.
    func UpdateGradientShifting(Duration: Double)
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
    var ShiftingStops: [(UIColor, CGFloat)] = [(UIColor, CGFloat)]()
    
    /// Holds the original vertical flag in order to reassemble the gradient later.
    var ShiftVertical: Bool = false
    
    /// Holds the original reverse flag in order to reassemble the gradient later.
    var ShiftReversed: Bool = false
    
    /// The timer for shifting colors in the gradient.
    var GradientTimer: Timer? = nil
    
    /// Shift the each color in the gradient by (1/360)° then update the background.
    @objc func UpdateShiftGradient()
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
    func NewGradientColorBackground()
    {
        UpdateGradientShifting(Duration: 0.0)
        DrawBackground()
    }
    
    /// Draw the background according to the current theme.
    /// - Note: If we're running on the simulator, live view is ignored.
    func DrawBackground()
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
    func CreateGameLight() -> SCNNode
    {
        let Light = SCNLight()
        let LightColor = ColorServer.ColorFrom(CurrentTheme!.LightColor)
        Light.color = LightColor
        Light.categoryBitMask = GameLight
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
    func CreateControlLight() -> SCNNode
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
        Node.light?.categoryBitMask = ControlLight
        Node.position = SCNVector3(-3.0, 15.0, 50.0)
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
        #if true
        NodeRemovalList.append(WithName)
        #else
        var KillList = [SCNNode]()
        self.scene?.rootNode.enumerateChildNodes
            {
                (Node, _) in
                if Node.name == WithName
                {
                    KillList.append(Node)
                }
        }
        print("RemoveNodes(\(WithName) started.)")
        for Node in KillList
        {
            Node.geometry!.firstMaterial!.specular.contents = nil
            Node.geometry!.firstMaterial!.diffuse.contents = nil
            Node.removeAllActions()
            Node.removeFromParentNode()
        }
        BlockList = BlockList.filter({$0.name != WithName})
        print("  RemoveNodes completed.")
        #endif
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
        #if true
        NodeRemovalList.append(contentsOf: WithNames)
        #else
        for Name in WithNames
        {
            RemoveNodes(WithName: Name)
        }
        #endif
    }
    
    // MARK: Bucket-related functions.
    
    var BucketNode: SCNNode? = nil
    
    /// Create a 3D bucket and add it to the scene. Attributes are from the current theme.
    /// - Parameter InitialOpacity: The initial opacity of the bucket. Defaults to 1.0.
    /// - Parameter Shape: The bucket's shape.
    /// - Returns: The bucket node.
    func CreateBucket(InitialOpacity: CGFloat = 1.0, Shape: BucketShapes) -> SCNNode
    {
        if BucketNode != nil
        {
            print("Removing bucket from parent.")
            BucketNode?.removeFromParentNode()
            print("  Done removing bucket from parent.")
        }
        let LocalBucketNode = SCNNode()
        
        let BoardClass = BoardData.GetBoardClass(For: CenterBlockShape)!
        switch BoardClass
        {
            case .Static:
                let LeftSide = SCNBox(width: 1.0, height: 20.0, length: 1.0, chamferRadius: 0.0)
                LeftSide.materials.first?.diffuse.contents = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
                LeftSide.materials.first?.specular.contents = ColorServer.ColorFrom(ColorNames.White)
                let LeftSideNode = SCNNode(geometry: LeftSide)
                LeftSideNode.categoryBitMask = GameLight
                LeftSideNode.position = SCNVector3(-6, 0, 0)
                LocalBucketNode.addChildNode(LeftSideNode)
                
                let RightSide = SCNBox(width: 1.0, height: 20.0, length: 1.0, chamferRadius: 0.0)
                RightSide.materials.first?.diffuse.contents = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
                RightSide.materials.first?.specular.contents = ColorServer.ColorFrom(ColorNames.White)
                let RightSideNode = SCNNode(geometry: RightSide)
                RightSideNode.categoryBitMask = GameLight
                RightSideNode.position = SCNVector3(5, 0, 0)
                LocalBucketNode.addChildNode(RightSideNode)
                
                let Bottom = SCNBox(width: 12.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                Bottom.materials.first?.diffuse.contents = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
                Bottom.materials.first?.specular.contents = ColorServer.ColorFrom(ColorNames.White)
                let BottomNode = SCNNode(geometry: Bottom)
                BottomNode.categoryBitMask = GameLight
                BottomNode.position = SCNVector3(-0.5, -10.5, 0)
                LocalBucketNode.addChildNode(BottomNode)
                
                LocalBucketNode.categoryBitMask = GameLight
                LocalBucketNode.opacity = InitialOpacity
            
            case .Rotatable:
                DrawCenterBlock(Parent: LocalBucketNode, InShape: Shape, InitialOpacity: InitialOpacity)
            
            case .ThreeDimensional:
                let Center = SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
                Center.materials.first?.specular.contents = ColorServer.ColorFrom(ColorNames.White)
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.0, 0.0)
                LocalBucketNode.addChildNode(CentralNode)
                LocalBucketNode.opacity = InitialOpacity
        }
        
        _BucketAdded = true
        return LocalBucketNode
    }
    
    /// Flag indicating the bucket was added. Do we need this in this class?
    var _BucketAdded: Bool = false
    
    /// Draw a vertical and horizontal line passing through the origin.
    /// - Note: Whether or not center lines are drawn is determined by the settings in the current theme.
    /// - Note: Center lines are intended to be used for debugging only.
    func DrawCenterLines()
    {
        print("Removing center lines.")
        CenterLineVertical?.removeFromParentNode()
        CenterLineHorizontal?.removeFromParentNode()
        print("  Done removing center lines.")
        if CurrentTheme!.ShowCenterLines
        {
            let Width: CGFloat = CGFloat(CurrentTheme!.CenterLineWidth)
            let LineColor = ColorServer.ColorFrom(CurrentTheme!.CenterLineColor)
            CenterLineVertical = MakeLine(From: SCNVector3(0.0, 20.0, 2.0), To: SCNVector3(0.0, -80.0, 2.0), Color: LineColor, LineWidth: Width)
            CenterLineHorizontal = MakeLine(From: SCNVector3(-20.0, 0.0, 2.0), To: SCNVector3(80.0, 0.0, 2.0), Color: LineColor, LineWidth: Width)
            CenterLineVertical!.categoryBitMask = ControlLight
            CenterLineHorizontal!.categoryBitMask = ControlLight
            self.scene?.rootNode.addChildNode(CenterLineVertical!)
            self.scene?.rootNode.addChildNode(CenterLineHorizontal!)
        }
    }
    
    private var CenterLineVertical: SCNNode? = nil
    private var CenterLineHorizontal: SCNNode? = nil
    
    /// Create a "line" and return it in a scene node.
    /// - Note: The line is really a very thin box. This makes lines a rather heavy operation.
    /// - Parameter From: Starting point of the line.
    /// - Parameter To: Ending point of the line.
    /// - Parameter Color: The color of the line.
    /// - Parameter LineWidth: Width of the line - defaults to 0.01.
    /// - Returns: Node with the specified line. The node has the name "GridNodes".
    func MakeLine(From: SCNVector3, To: SCNVector3, Color: UIColor, LineWidth: CGFloat = 0.01) -> SCNNode
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
        Line.materials.first?.diffuse.contents = Color
        let Node = SCNNode(geometry: Line)
        Node.categoryBitMask = GameLight
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
            let LineNode = MakeLine(From: Start, To: End, Color: UIColor.white)
            self.scene?.rootNode.addChildNode(LineNode)
        }
        for X in stride(from: -64.5, to: 128.5, by: 1.0)
        {
            let Start = SCNVector3(X, -64.0, 0.0)
            let End = SCNVector3(X, 128.0, 0.0)
            let LineNode = MakeLine(From: Start, To: End, Color: UIColor.white)
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
        #if false
        let Radians = ByDegrees * CGFloat.pi / 180.0
        #endif
    }
    
    /// The moving piece is in its final location. Add its ID to the list of retired IDs and remove the moving blocks.
    /// - Parameter Finalized: The piece that was finalized.
    func MergePieceIntoBucket(_ Finalized: Piece)
    {
        #if false
        VisuallyRetirePiece(Finalized, Completion:
            {
                self.RetiredPieceIDs.append(Finalized.ID)
                self.RemoveMovingPiece()
        })
        #else
        RetiredPieceIDs.append(Finalized.ID)
        RemoveMovingPiece()
        #endif
    }
    
    /// Show a piece such that the user knows it is being retired (eg, frozen).
    /// - Note: [How to add animations to change SCNNode's color](https://stackoverflow.com/questions/40472524/how-to-add-animations-to-change-sncnodes-color-scenekit)
    /// - Parameter Finalized: The piece that is freezing but not yet frozen.
    /// - Parameter Completion: Completion block.
    func VisuallyRetirePiece(_ Finalized: Piece, Completion: (() -> ())?)
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
    func AddBlockNode_Standard(ParentID: UUID, BlockID: UUID, X: Int, Y: Int, IsRetired: Bool, ShapeID: UUID)
    {
        print("Adding standard block node to \(X),\(Y)")
        if let PVisual = PieceVisualManager2.UserVisuals!.GetVisualWith(ID: ShapeID)
        {
            let VBlock = VisualBlocks3D(BlockID, AtX: CGFloat(X), AtY: CGFloat(Y), ActiveVisuals: PVisual.ActiveVisuals!,
                                        RetiredVisuals: PVisual.RetiredVisuals!, IsRetired: IsRetired)
            VBlock.ParentID = ParentID
            VBlock.Marked = true
            VBlock.categoryBitMask = GameLight
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
    func AddBlockNode_Rotating(ParentID: UUID, BlockID: UUID, X: CGFloat, Y: CGFloat, IsRetired: Bool, ShapeID: UUID)
    {
        if let PVisual = PieceVisualManager2.UserVisuals!.GetVisualWith(ID: ShapeID)
        {
            let VBlock = VisualBlocks3D(BlockID, AtX: CGFloat(X), AtY: CGFloat(Y), ActiveVisuals: PVisual.ActiveVisuals!,
                                        RetiredVisuals: PVisual.RetiredVisuals!, IsRetired: IsRetired)
            VBlock.ParentID = ParentID
            VBlock.Marked = true
            VBlock.categoryBitMask = GameLight
            BlockList.insert(VBlock)
            MasterBlockNode!.addChildNode(VBlock)
        }
        else
        {
            print("Error getting visuals for shape ID \(ShapeID)")
        }
    }
    
    /// Remove all moving piece blocks from the master block node.
    func UpdateMasterBlockNode()
    {
        if MasterBlockNode != nil
        {
            print("Removing nodes from the MasterBlockNode")
            MasterBlockNode?.childNodes.forEach({
                if !($0 as! VisualBlocks3D).IsRetired
                {
                    $0.removeFromParentNode()
                }
            })
            print("  Done removing nodes from the MasterBlockNode")
        }
    }
    
    var MasterBlockNode: SCNNode? = nil
    
    /// Determines if a block should be drawn in **DrawMap3D**. Valid block types depend on the type of base game.
    /// - Parameter BlockType: The block to check to see if it can be drawn or not.
    /// - Returns: True if the block should be drawn, false if not.
    func ValidBlockToDraw(BlockType: PieceTypes) -> Bool
    {
        #if true
        let BoardClass = BoardData.GetBoardClass(For: CenterBlockShape)!
        switch BoardClass
        {
            case .Static:
                return ![.Visible, .InvisibleBucket, .Bucket].contains(BlockType)
            
            case .Rotatable:
                return ![.Visible, .InvisibleBucket, .Bucket, .GamePiece, .BucketExterior].contains(BlockType)
            
            case .ThreeDimensional:
                return false
        }
        #else
        switch BaseGameType
        {
            case .Standard:
                return ![.Visible, .InvisibleBucket, .Bucket].contains(BlockType)
            
            case .SemiRotating:
                fallthrough
            case .Rotating4:
                return ![.Visible, .InvisibleBucket, .Bucket, .GamePiece, .BucketExterior].contains(BlockType)
            
            case .Cubic:
                return false
        }
        #endif
    }
    
    /// Contains a list of IDs of blocks that have been retired. Used to keep the game from moving them when they are no longer
    /// moveable.
    var RetiredPieceIDs = [UUID]()
    
    /// Draw the individual piece. Intended to be used for the **.Rotating4** base game type.
    /// - Note:
    ///    - If the piece type ID cannot be retrieved, control is returned immediately.
    ///    - If `GamePiece` has an ID that is in `RetiredPieceIDs`, control will be returned immeidately to prevent spurious
    ///      pieces from polluting the game board. Sometimes, most likely due to timers that haven't shut down, the board logic
    ///      will keep on trying to move the piece even after it is frozen into place. When that happens, the board will call
    ///      this function, adding a new moving piece even after it is frozen. When that happens, the piece appears to be unfrozen
    ///      when it should be frozen, and the piece doesn't move when the board is rotated.
    /// - Parameter InBoard: The current game board.
    /// - Parameter GamePiece: The piece to draw.
    func DrawPiece3D(InBoard: Board, GamePiece: Piece)
    {
        if RetiredPieceIDs.contains(GamePiece.ID)
        {
            return
        }
        print("Removing moving piece node.")
        if MovingPieceNode != nil
        {
            MovingPieceNode?.removeFromParentNode()
        }
        print("  Done removing moving piece node.")
        MovingPieceBlocks = [VisualBlocks3D]()
        MovingPieceNode = SCNNode()
        MovingPieceNode?.name = "Moving Piece"
        let CurrentMap = InBoard.Map!
        let ItemID = GamePiece.ID
        let PVisuals = PieceVisualManager2.UserVisuals!.GetVisualWith(ID: GamePiece.ShapeID)
        for Block in GamePiece.Locations!
        {
            if Block.ID == UUID.Empty
            {
                print("Block.ID is not set in DrawPiece3D")
                return
            }
            #if false
            let YOffset = 10 - CGFloat(Block.Y) - 0.5
            let XOffset = CGFloat(Block.X) - 6.0
            #else
            let YOffset = (30 - 10 - 1) - 1.5 - CGFloat(Block.Y)
            let XOffset = CGFloat(Block.X) - 17.5
            #endif
            let PieceTypeID = CurrentMap.RetiredPieceShapes[ItemID]
            if PieceTypeID == nil
            {
                print("Could not find ItemID in RetiredPieceShapes.")
                return
            }
            let VBlock = VisualBlocks3D(Block.ID, AtX: XOffset, AtY: YOffset, ActiveVisuals: PVisuals!.ActiveVisuals!,
                                        RetiredVisuals: PVisuals!.RetiredVisuals!, IsRetired: false)
            VBlock.categoryBitMask = GameLight
            MovingPieceBlocks.append(VBlock)
            MovingPieceNode?.addChildNode(VBlock)
        }
        print("Adding moving piece blocks to root node.")
        self.scene?.rootNode.addChildNode(MovingPieceNode!)
        print("  Done moving piece blocks to root node.")
    }
    
    var MovingPieceBlocks = [VisualBlocks3D]()
    
    /// Remove the moving piece, if it exists.
    func RemoveMovingPiece()
    {
        let BoardClass = BoardData.GetBoardClass(For: CenterBlockShape)!
        #if true
        if BoardClass == .Rotatable
        {
            print("Removing moving piece in rotating game.")
            if MovingPieceNode != nil
            {
                MovingPieceNode!.removeFromParentNode()
                MovingPieceNode = nil
                UpdateMasterBlockNode()
            }
            print("  Done removing piece from rotating game.")
        }
        #else
        if BaseGameType == .Rotating4
        {
            print("Removing moving piece in rotating game.")
            if MovingPieceNode != nil
            {
                MovingPieceNode!.removeFromParentNode()
                MovingPieceNode = nil
                UpdateMasterBlockNode()
            }
            print("  Done removing piece from rotating game.")
        }
        #endif
    }
    
    var MovingPieceNode: SCNNode? = nil
    
    /// Visually clear the bucket of pieces.
    /// - Note:
    ///   - Should be called only after the game is over.
    ///   - All retired piece IDs are removed.
    /// - Parameter FromBoard: The board that contains the map to draw. *Not currently used.*
    /// - Parameter DestroyBy: Determines how to empty the bucket.
    /// - Parameter MaxDuration: Maximum amount of time (in seconds) to take to clear the board.
    func DestroyMap3D(FromBoard: Board, DestroyBy: DestructionMethods, MaxDuration: Double)
    {
        objc_sync_enter(RotateLock)
        defer{objc_sync_exit(RotateLock)}
        BucketCleaner(DestroyBy, MaxDuration: MaxDuration)
    }
    
    /// Draw the 3D game view map. Includes moving pieces.
    /// - Note:
    ///    - To keep things semi-efficient, 3D objects are only created when they first appear in the game board.
    ///      Once there, they are moved as needed rather than creating new ones in new locations.
    ///    - This function assumes the board changes between each piece.
    /// - Parameter FromBoard: The board that contains the map to draw.
    func DrawMap3D(FromBoard: Board, CalledFrom: String = "")
    {
        #if false
        if BaseGameType == .Rotating4
        {
            print("DrawMap3D called from \(CalledFrom)")
        }
        #endif
        objc_sync_enter(RotateLock)
        defer{ objc_sync_exit(RotateLock) }
        let BoardClass = BoardData.GetBoardClass(For: CenterBlockShape)!
        
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
                #if true
                switch BoardClass
                {
                    case .Rotatable:
                        YOffset = (30 - 10 - 1) - 1.0 - CGFloat(Y)
                        XOffset = CGFloat(X) - 17.5
                    
                    case .Static:
                         YOffset = 10 - CGFloat(Y) //+ 0.5
                         XOffset = CGFloat(X) - 6.0
                    
                    case .ThreeDimensional:
                        XOffset = 0
                        YOffset = 0
                }
                #else
                switch BaseGameType
                {
                    case .Standard:
                        YOffset = (30 - 10 - 1) - CGFloat(Y)
                        XOffset = CGFloat(X) - 6.0
                    
                    case .Rotating4:
                        YOffset = (30 - 10 - 1) - 1.0 - CGFloat(Y)
                        XOffset = CGFloat(X) - 17.5
                    
                    case .SemiRotating:
                        XOffset = 0
                        YOffset = 0
                    
                    case .Cubic:
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
                    let PieceTypeID = CurrentMap.RetiredPieceShapes[ItemID]!
                    #if true
                    if BoardClass == .Rotatable
                    {
                        YOffset = YOffset - 0.5
                    }
                    #else
                    if BaseGameType == .Rotating4
                    {
                        YOffset = YOffset - 0.5
                    }
                    #endif
                    #if true
                    switch BoardClass
                    {
                        case .Static:
                            AddBlockNode_Standard(ParentID: ItemID, BlockID: BlockID, X: Int(XOffset), Y: Int(YOffset),
                                                  IsRetired: IsRetired, ShapeID: PieceTypeID)
                        
                        case .Rotatable:
                            AddBlockNode_Rotating(ParentID: ItemID, BlockID: BlockID, X: XOffset, Y: YOffset,
                                                  IsRetired: IsRetired, ShapeID: PieceTypeID)
                        
                        case .ThreeDimensional:
                            break
                    }
                    #else
                    switch BaseGameType
                    {
                        case .Standard:
                            AddBlockNode_Standard(ParentID: ItemID, BlockID: BlockID, X: Int(XOffset), Y: Int(YOffset),
                                                  IsRetired: IsRetired, ShapeID: PieceTypeID)
                        
                        case .Rotating4:
                            AddBlockNode_Rotating(ParentID: ItemID, BlockID: BlockID, X: XOffset, Y: YOffset,
                                                  IsRetired: IsRetired, ShapeID: PieceTypeID)
                        
                        case .SemiRotating:
                            break
                        
                        case .Cubic:
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
    
    /// Holds the board in which we are working.
    var CurrentBoard: Board? = nil
    
    /// Holds the map for the current board.
    var CurrentMap: MapType? = nil
    
    /// Creates the master block node. This is the node in which all blocks are placed. This is done to allow for
    /// easy rotation of blocks when needed.
    func CreateMasterBlockNode()
    {
        if MasterBlockNode != nil
        {
            print("Removing everything from master block node.")
            MasterBlockNode!.removeAllActions()
            MasterBlockNode!.removeFromParentNode()
            MasterBlockNode = nil
            print("  Done removing everything from master block node.")
        }
        MasterBlockNode = SCNNode()
        MasterBlockNode!.name = "Master Block Node"
        self.scene?.rootNode.addChildNode(MasterBlockNode!)
    }
    
    /// Clear the bucket of all pieces.
    /// - Note: The bucket will not be cleared if the view is rotating.
    func ClearBucket()
    {
        objc_sync_enter(RotateLock)
        defer{objc_sync_exit(RotateLock)}
        CreateMasterBlockNode()
        print("Clearing the bucket.")
        for Node in BlockList
        {
            Node.removeAllActions()
            Node.removeFromParentNode()
        }
        print("  Done clearing the bucket.")
        #if true
        print("Removing all blocks from BlockList.")
        BlockList.removeAll()
        print("  Done removing all blocks from BlockList.")
        #else
        OperationQueue.main.addOperation
            {
                //Sometimes this call seems to trigger an exception from within SceneKit.
                self.BlockList.removeAll()
        }
        #endif
    }
    
    /// Empty the map of all block nodes.
    func EmptyMap()
    {
        print("Emptying the map.")
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
        print("  Done emptying the map.")
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
    
    /// The node that holds the outline.
    var OutlineNode: SCNNode? = nil
    
    var CanUseBucket: NSObject = NSObject()
    
    /// Function that does the actual "line" drawing of the bucket grid.
    /// - Note: The lines are really very thin boxes; SceneKit doesn't support lines as graphical objects.
    /// - Parameter ShowGrid: If true, the grid is drawn. If false, no grid is drawn, but see **DrawOutline**.
    /// - Parameter DrawOutline: If true, a perimeter outline is drawn.
    /// - Parameter InitialOpacity: The initial opacity of the grids.
    /// - Parameter LineColorOverride: If provided, this is the color of the lines of the grid. If not provided, the color specified
    ///                                in the current theme will be used. Default is nil, which means use the theme's color.
    /// - Parameter OutlineColorOverride: If provided, this is the color of the lines of the outline. If not provided, the color specified
    ///                                   in the current theme will be used. Default is nil, which means use the theme's color.
    /// - Returns: Tuple with Grid being the bucket interior grid, and Outline the grid outline node.
    func DrawGridInBucket(ShowGrid: Bool = true, DrawOutline: Bool, InitialOpacity: CGFloat = 1.0,
                          LineColorOverride: UIColor? = nil, OutlineColorOverride: UIColor? = nil) -> (Grid: SCNNode, Outline: SCNNode)
    {
        objc_sync_enter(CanUseBucket)
        defer{objc_sync_exit(CanUseBucket)}
        print("Removing bucket grid node.")
        if BucketGridNode != nil
        {
            BucketGridNode?.removeFromParentNode()
        }
        print("  Done removing bucket grid node.")
        let BucketGridNode = SCNNode()
        let OutlineNode = SCNNode()
        
        var LineColor = UIColor.white
        var OutlineColor = UIColor.red
        if LineColorOverride != nil
        {
            LineColor = LineColorOverride!
        }
        if OutlineColorOverride != nil
        {
            OutlineColor = OutlineColorOverride!
        }
        
        let BoardClass = BoardData.GetBoardClass(For: CenterBlockShape)!
        
        #if true
        switch BoardClass
        {
            case .Static:
                if ShowGrid
                {
                    //Horizontal bucket lines.
                    for Y in stride(from: 10.0, to: -10.5, by: -1.0)
                    {
                        let Start = SCNVector3(-0.5, Y, 0.0)
                        let End = SCNVector3(10.5, Y, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.03)
                        LineNode.categoryBitMask = GameLight
                        LineNode.name = "Horizontal,\(Int(Y))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                    //Vertical bucket lines.
                    for X in stride(from: -4.5, to: 5.0, by: 1.0)
                    {
                        let Start = SCNVector3(X, 0.0, 0.0)
                        let End = SCNVector3(X, 20.0, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.03)
                        LineNode.categoryBitMask = GameLight
                        LineNode.name = "Vertical,\(Int(X))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                }
                if DrawOutline
                {
                    let TopStart = SCNVector3(-0.5, 10.0, 0.0)
                    let TopEnd = SCNVector3(10.5, 10.0, 0.0)
                    let TopLine = MakeLine(From: TopStart, To: TopEnd, Color: OutlineColor, LineWidth: 0.08)
                    TopLine.categoryBitMask = GameLight
                    TopLine.name = "TopLine"
                    BucketGridNode.addChildNode(TopLine)
                }
                BucketGridNode.opacity = InitialOpacity
            
            case .Rotatable:
                let GameBoard = BoardManager.GetBoardFor(CenterBlockShape)!
                let BucketWidth = Double(GameBoard.BucketWidth)
                let BucketHeight = Double(GameBoard.BucketHeight)
                let HalfY = BucketHeight / 2.0
                let HalfX = BucketWidth / 2.0
                if ShowGrid
                {
                    // Horizontal lines.
                    for Y in stride(from: HalfY, to: -HalfY - 0.5, by: -1.0)
                    {
                        let Start = SCNVector3(0.0, Y, 0.0)
                        let End = SCNVector3(20.0, Y, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.02)
                        LineNode.categoryBitMask = GameLight
                        LineNode.name = "Horizontal,\(Int(Y))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                    //Vertical lines.
                    for X in stride(from: -HalfX, to: HalfX + 0.5, by: 1.0)
                    {
                        let Start = SCNVector3(X, 0.0, 0.0)
                        let End = SCNVector3(X, 20.0, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.02)
                        LineNode.categoryBitMask = GameLight
                        LineNode.name = "Vertical,\(Int(X))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                }
                //Outline.
                if DrawOutline
                {
                    let TopStart = SCNVector3(0.0, HalfY, 0.0)
                    let TopEnd = SCNVector3(BucketWidth, HalfY, 0.0)
                    let TopLine = MakeLine(From: TopStart, To: TopEnd, Color: OutlineColor, LineWidth: 0.08)
                    TopLine.categoryBitMask = GameLight
                    TopLine.name = "TopLine"
                    OutlineNode.addChildNode(TopLine)
                    let BottomStart = SCNVector3(0.0, -HalfY, 0.0)
                    let BottomEnd = SCNVector3(BucketWidth, -HalfY, 0.0)
                    let BottomLine = MakeLine(From: BottomStart, To: BottomEnd, Color: OutlineColor, LineWidth: 0.08)
                    BottomLine.categoryBitMask = GameLight
                    BottomLine.name = "BottomLine"
                    OutlineNode.addChildNode(BottomLine)
                    let LeftStart = SCNVector3(-HalfX, 0.0, 0.0)
                    let LeftEnd = SCNVector3(-HalfX, BucketHeight, 0.0)
                    let LeftLine = MakeLine(From: LeftStart, To: LeftEnd, Color: OutlineColor, LineWidth: 0.08)
                    LeftLine.categoryBitMask = GameLight
                    LeftLine.name = "LeftLine"
                    OutlineNode.addChildNode(LeftLine)
                    let RightStart = SCNVector3(HalfX, 0.0, 0.0)
                    let RightEnd = SCNVector3(HalfX, BucketHeight, 0.0)
                    let RightLine = MakeLine(From: RightStart, To: RightEnd, Color: OutlineColor, LineWidth: 0.08)
                    RightLine.categoryBitMask = GameLight
                    RightLine.name = "RightLine"
                    OutlineNode.addChildNode(RightLine)
                }
                BucketGridNode.opacity = InitialOpacity
            
            case .ThreeDimensional:
                break
        }
        #else
        switch BaseGameType
        {
            case .Standard:
                if ShowGrid
                {
                    //Horizontal bucket lines.
                    for Y in stride(from: 10.0, to: -10.5, by: -1.0)
                    {
                        let Start = SCNVector3(-0.5, Y, 0.0)
                        let End = SCNVector3(10.5, Y, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.03)
                        LineNode.categoryBitMask = GameLight
                        LineNode.name = "Horizontal,\(Int(Y))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                    //Vertical bucket lines.
                    for X in stride(from: -4.5, to: 5.0, by: 1.0)
                    {
                        let Start = SCNVector3(X, 0.0, 0.0)
                        let End = SCNVector3(X, 20.0, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.03)
                        LineNode.categoryBitMask = GameLight
                        LineNode.name = "Vertical,\(Int(X))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                }
                if DrawOutline
                {
                    let TopStart = SCNVector3(-0.5, 10.0, 0.0)
                    let TopEnd = SCNVector3(10.5, 10.0, 0.0)
                    let TopLine = MakeLine(From: TopStart, To: TopEnd, Color: OutlineColor, LineWidth: 0.08)
                    TopLine.categoryBitMask = GameLight
                    TopLine.name = "TopLine"
                    BucketGridNode.addChildNode(TopLine)
                }
                BucketGridNode.opacity = InitialOpacity
            
            case .Rotating4:
                let GameBoard = BoardManager.GetBoardFor(.Square)!
                let BucketWidth = Double(GameBoard.BucketWidth)
                let BucketHeight = Double(GameBoard.BucketHeight)
                let HalfY = BucketHeight / 2.0
                let HalfX = BucketWidth / 2.0
                #if true
                if ShowGrid
                {
                    // Horizontal lines.
                    for Y in stride(from: HalfY, to: -HalfY - 0.5, by: -1.0)
                    {
                        let Start = SCNVector3(0.0, Y, 0.0)
                        let End = SCNVector3(20.0, Y, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.02)
                        LineNode.categoryBitMask = GameLight
                        LineNode.name = "Horizontal,\(Int(Y))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                    //Vertical lines.
                    for X in stride(from: -HalfX, to: HalfX + 0.5, by: 1.0)
                    {
                        let Start = SCNVector3(X, 0.0, 0.0)
                        let End = SCNVector3(X, 20.0, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.02)
                        LineNode.categoryBitMask = GameLight
                        LineNode.name = "Vertical,\(Int(X))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                }
                //Outline.
                if DrawOutline
                {
                    let TopStart = SCNVector3(0.0, HalfY, 0.0)
                    let TopEnd = SCNVector3(BucketWidth, HalfY, 0.0)
                    let TopLine = MakeLine(From: TopStart, To: TopEnd, Color: OutlineColor, LineWidth: 0.08)
                    TopLine.categoryBitMask = GameLight
                    TopLine.name = "TopLine"
                    OutlineNode.addChildNode(TopLine)
                    let BottomStart = SCNVector3(0.0, -HalfY, 0.0)
                    let BottomEnd = SCNVector3(BucketWidth, -HalfY, 0.0)
                    let BottomLine = MakeLine(From: BottomStart, To: BottomEnd, Color: OutlineColor, LineWidth: 0.08)
                    BottomLine.categoryBitMask = GameLight
                    BottomLine.name = "BottomLine"
                    OutlineNode.addChildNode(BottomLine)
                    let LeftStart = SCNVector3(-HalfX, 0.0, 0.0)
                    let LeftEnd = SCNVector3(-HalfX, BucketHeight, 0.0)
                    let LeftLine = MakeLine(From: LeftStart, To: LeftEnd, Color: OutlineColor, LineWidth: 0.08)
                    LeftLine.categoryBitMask = GameLight
                    LeftLine.name = "LeftLine"
                    OutlineNode.addChildNode(LeftLine)
                    let RightStart = SCNVector3(HalfX, 0.0, 0.0)
                    let RightEnd = SCNVector3(HalfX, BucketHeight, 0.0)
                    let RightLine = MakeLine(From: RightStart, To: RightEnd, Color: OutlineColor, LineWidth: 0.08)
                    RightLine.categoryBitMask = GameLight
                    RightLine.name = "RightLine"
                    OutlineNode.addChildNode(RightLine)
                }
                BucketGridNode.opacity = InitialOpacity
                #else
                if ShowGrid
                {
                    //Horizontal bucket lines.
                    for Y in stride(from: 10.0, to: -10.5, by: -1.0)
                    {
                        let Start = SCNVector3(0.0, Y, 0.0)
                        let End = SCNVector3(20.0, Y, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.02)
                        LineNode.categoryBitMask = GameLight
                        LineNode.name = "Horizontal,\(Int(Y))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                    //Vertical bucket lines.
                    for X in stride(from: -10.0, to: 10.5, by: 1.0)
                    {
                        let Start = SCNVector3(X, 0.0, 0.0)
                        let End = SCNVector3(X, 20.0, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.02)
                        LineNode.categoryBitMask = GameLight
                        LineNode.name = "Vertical,\(Int(X))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                }
                //Outline.
                if DrawOutline
                {
                    let TopStart = SCNVector3(0.0, 10.0, 0.0)
                    let TopEnd = SCNVector3(20.0, 10.0, 0.0)
                    let TopLine = MakeLine(From: TopStart, To: TopEnd, Color: OutlineColor, LineWidth: 0.08)
                    TopLine.categoryBitMask = GameLight
                    TopLine.name = "TopLine"
                    OutlineNode.addChildNode(TopLine)
                    let BottomStart = SCNVector3(0.0, -10.0, 0.0)
                    let BottomEnd = SCNVector3(20.0, -10.0, 0.0)
                    let BottomLine = MakeLine(From: BottomStart, To: BottomEnd, Color: OutlineColor, LineWidth: 0.08)
                    BottomLine.categoryBitMask = GameLight
                    BottomLine.name = "BottomLine"
                    OutlineNode.addChildNode(BottomLine)
                    let LeftStart = SCNVector3(-10.0, 0.0, 0.0)
                    let LeftEnd = SCNVector3(-10.0, 20.0, 0.0)
                    let LeftLine = MakeLine(From: LeftStart, To: LeftEnd, Color: OutlineColor, LineWidth: 0.08)
                    LeftLine.categoryBitMask = GameLight
                    LeftLine.name = "LeftLine"
                    OutlineNode.addChildNode(LeftLine)
                    let RightStart = SCNVector3(10.0, 0.0, 0.0)
                    let RightEnd = SCNVector3(10.0, 20.0, 0.0)
                    let RightLine = MakeLine(From: RightStart, To: RightEnd, Color: OutlineColor, LineWidth: 0.08)
                    RightLine.categoryBitMask = GameLight
                    RightLine.name = "RightLine"
                    OutlineNode.addChildNode(RightLine)
                }
                BucketGridNode.opacity = InitialOpacity
                #endif
                
                #if false
                let TopLabel = SCNText(string: "Top", extrusionDepth: 0.5)
                TopLabel.materials.first!.specular.contents = ColorServer.ColorFrom(ColorNames.Black)
                TopLabel.materials.first!.diffuse.contents = ColorServer.ColorFrom(ColorNames.Cyan)
                TopLabel.flatness = 0.2
                let TopNode = SCNNode(geometry: TopLabel)
                TopNode.categoryBitMask = GameLight
                TopNode.name = "Top"
                TopNode.scale = SCNVector3(0.02, 0.02, 0.02)
                TopNode.position = SCNVector3(-0.5, 10.4, 0.0)
                BucketGridNode.addChildNode(TopNode)
                
                let BottomLabel = SCNText(string: "Bottom", extrusionDepth: 0.5)
                BottomLabel.materials.first!.specular.contents = ColorServer.ColorFrom(ColorNames.Black)
                BottomLabel.materials.first!.diffuse.contents = ColorServer.ColorFrom(ColorNames.Yellow)
                BottomLabel.flatness = 0.2
                let BottomNode = SCNNode(geometry: BottomLabel)
                BottomNode.categoryBitMask = GameLight
                BottomNode.name = "Bottom"
                BottomNode.scale = SCNVector3(0.02, 0.02, 0.02)
                BottomNode.rotation = SCNVector4(0.0, 0.0, 1.0, CGFloat.pi)
                BottomNode.position = SCNVector3(0.5, -10.5, 0.0)
                BucketGridNode.addChildNode(BottomNode)
                
                let RightLabel = SCNText(string: "Right", extrusionDepth: 0.5)
                RightLabel.materials.first!.specular.contents = ColorServer.ColorFrom(ColorNames.Black)
                RightLabel.materials.first!.diffuse.contents = ColorServer.ColorFrom(ColorNames.Magenta)
                RightLabel.flatness = 0.2
                let RightNode = SCNNode(geometry: RightLabel)
                RightNode.categoryBitMask = GameLight
                RightNode.name = "Right"
                RightNode.scale = SCNVector3(0.02, 0.02, 0.02)
                RightNode.rotation = SCNVector4(0.0, 0.0, 1.0, 270.0 * CGFloat.pi / 180.0)
                RightNode.position = SCNVector3(10.5, 1.0, 0.0)
                BucketGridNode.addChildNode(RightNode)
                
                let LeftLabel = SCNText(string: "Left", extrusionDepth: 0.5)
                LeftLabel.materials.first!.specular.contents = ColorServer.ColorFrom(ColorNames.Gray)
                LeftLabel.materials.first!.diffuse.contents = ColorServer.ColorFrom(ColorNames.Black)
                RightLabel.flatness = 0.2
                let LeftNode = SCNNode(geometry: LeftLabel)
                LeftNode.categoryBitMask = GameLight
                LeftNode.name = "Left"
                LeftNode.scale = SCNVector3(0.02, 0.02, 0.02)
                LeftNode.rotation = SCNVector4(0.0, 0.0, 1.0, CGFloat.pi * 0.5)
                LeftNode.position = SCNVector3(-10.5, 0.0, 0.0)
                BucketGridNode.addChildNode(LeftNode)
            #endif
            
            case .SemiRotating:
                break
            
            case .Cubic:
                break
        }
        #endif
        
        return (Grid: BucketGridNode, Outline: OutlineNode)
    }
    
    /// Fades the bucket grid to an alpha of 0.0 then removes the lines from the scene.
    /// - Parameter Duration: Number of seconds for the fade effect to take place. Default is 1.0 seconds.
    func FadeBucketGrid(Duration: Double = 1.0)
    {
        let FadeAction = SCNAction.fadeOut(duration: Duration)
        print("Removing bucket grid node in FadeBucketGrid")
        BucketGridNode?.runAction(FadeAction, completionHandler:
            {
                self.BucketGridNode?.removeAllActions()
                self.BucketGridNode?.removeFromParentNode()
                self.BucketGridNode = nil
        }
        )
        print("  Done removing bucket grid node in FadeBucketGrid")
    }
    
    /// Show or hide a buck grid. The bucket grid is unit sized (according to the block size) that fills the
    /// interior of the bucket.
    /// - Parameter ShowLines: Determines if the grid is shown or hidden.
    /// - Parameter IncludingOutline: If true, the outline is drawn as well.
    func DrawBucketGrid(ShowLines: Bool, IncludingOutline: Bool = true)
    {
        let (Grid, Outline) = DrawGridInBucket(ShowGrid: ShowLines, DrawOutline: IncludingOutline)
        BucketGridNode = Grid
        OutlineNode = Outline
        self.scene?.rootNode.addChildNode(BucketGridNode!)
        self.scene?.rootNode.addChildNode(OutlineNode!)
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
    
    // MARK: - Bucket rotatation routines.
    
    /// Lock used when the board is rotating.
    var RotateLock = NSObject()
    
    /// Rotates the contents of the game (but not UI or falling piece) by the specified number of degrees.
    /// - Note:
    ///   - This function uses a synchronous lock to make sure that when the board is rotating, other things don't happen to it.
    ///   - This function uses two rotational actions because for some reason, using the same action on different SCNNodes
    ///     results in unpredictable and undesired behavior.
    /// - Parameter Right: If true, the contents are rotated clockwise. If false, counter-clockwise.
    /// - Parameter Duration: Duration in seconds the rotation should take.
    /// - Parameter Completed: Completion handler called at the end of the rotation.
    func RotateContents(Right: Bool, Duration: Double = 0.33, Completed: @escaping (() -> Void))
    {
        objc_sync_enter(RotateLock)
        defer{objc_sync_exit(RotateLock)}
        let DirectionalSign = CGFloat(Right ? -1.0 : 1.0)
        RotationCardinalIndex = RotationCardinalIndex + 1
        if RotationCardinalIndex > 3
        {
            RotationCardinalIndex = 0
        }
        let Radian = CGFloat((RotationCardinalIndex * 90)) * CGFloat.pi / 180.0
        let ZRotation = DirectionalSign * Radian
        let ZRotationTo = DirectionalSign * HalfPi
        let RotateToAction = SCNAction.rotateBy(x: 0.0, y: 0.0, z: ZRotationTo, duration: Duration)
        let RotateByAction = SCNAction.rotateTo(x: 0.0, y: 0.0, z: ZRotation, duration: Duration, usesShortestUnitArc: true)
        RemoveMovingPiece()
        if CurrentTheme!.RotateBucketGrid
        {
            BucketGridNode?.runAction(RotateByAction)
            OutlineNode?.runAction(RotateByAction)
        }
        MasterBlockNode?.runAction(RotateToAction)
        BucketNode?.runAction(RotateToAction)
        #if false
        if CurrentTheme!.EnableDebug
        {
            if CurrentTheme!.ChangeColorAfterRotation
            {
                ChangeBucketColor()
            }
        }
        #endif
    }
    
    /// Change the color of the bucket.
    /// - Note:
    ///   - Intended for use for debugging.
    ///   - `BucketNode` and all of its children (if any) have the diffuse surface set.
    func ChangeBucketColor()
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
    var RotationCardinalIndex = 0
    
    /// 90° expressed in radians.
    let HalfPi = CGFloat.pi / 2.0
    
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
    
    var SceneNodeID = UUID()
    var MaxSceneNodeID = UUID()
    var MaxSceneNodes: Int = 0
    
    /// Handle the piece out of bounds state (which indicates game over).
    /// - Note: [Animated SCNNode Forever](https://stackoverflow.com/questions/29658772/animate-scnnode-forever-scenekit-swift)
    /// - Parameter ID: The ID of the node that froze out of bounds.
    func PieceOutOfBounds(_ ID: UUID)
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
        #if true
        let BoardClass = BoardData.GetBoardClass(For: CenterBlockShape)!
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
            
            case .Rotatable:
                for Block in MovingPieceBlocks
                {
                    FinalBlocks.append(Block)
                    BlockList.insert(Block)
            }
            
            case .ThreeDimensional:
                break
        }
        #else
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
                    BlockList.insert(Block)
            }
            
            case .SemiRotating:
                break
            
            case .Cubic:
                break
        }
        #endif
        
        #if true
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
        #else
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
        #endif
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
    var CurrentTheme: ThemeDescriptor2? = nil
    
    func Refresh()
    {
    }
    
    // MARK: - ThreeDProtocol function implementations.
    
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
    
    // MARK: - Text layer protocol function implementation
    
    /// Handle double click events relayed to us by the text layer. Double click events will cause the camera to be reset
    /// to it's theme-appropriate values.
    func MouseDoubleClick(At: CGPoint)
    {
        self.pointOfView?.position = OriginalCameraPosition!
        self.pointOfView?.orientation = OriginalCameraOrientation!
    }
    
    // MARK: - Heartbeat functions.
    
    var ShowingHeart = false
    
    func SetHeartbeatVisibility(Show: Bool)
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
    
    var HeartHighlighted = false
    
    func ToggleHeartState()
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
    
    // MARK: - Variables for buttons and button state. Button functions are found in +TextButtons.swift.
    
    var ButtonList: [NodeButtons: SCNButtonNode] = [NodeButtons: SCNButtonNode]()
    
    var ButtonDictionary: [NodeButtons: (Location: SCNVector3, Scale: Double, Color: UIColor, Highlight: UIColor)] =
    [NodeButtons: (Location: SCNVector3, Scale: Double, Color: UIColor, Highlight: UIColor)]()
    
    /// Dictionary between node button types and the system image name and location of each node.
    /// Intended for use with devices with reasonable-sized screens.
    let BigButtonDictionary: [NodeButtons: (Location: SCNVector3, Scale: Double, Color: UIColor, Highlight: UIColor)] =
        [
            .MainButton: (SCNVector3(-10.3, 13.7, 1.0), 0.06, UIColor.white, UIColor.yellow),
            .FPSButton: (SCNVector3(-8.5, 13.0, 1.0), 0.03, UIColor.white, UIColor.yellow),
            .PlayButton: (SCNVector3(3.0, 13.0, 1.0), 0.03, UIColor.white, UIColor.red),
            .PauseButton: (SCNVector3(6.5, 13.0, 1.0), 0.03, UIColor.white, UIColor.red),
            .VideoButton: (SCNVector3(-2.8, 13.0, 1.0), 0.025, UIColor.white, UIColor.red),
            .CameraButton: (SCNVector3(0.0, 13.0, 1.0), 0.025, UIColor.white, UIColor.red),
            
            .LeftButton: (SCNVector3(-11.2, -12.2, 1.0), 0.08, UIColor.white, UIColor.yellow),
            .RotateLeftButton: (SCNVector3(-11.2, -14.5, 1.0), 0.08, UIColor.white, UIColor.yellow),
            .UpButton: (SCNVector3(-8.5, -14.5, 1.0), 0.08, UIColor.white, UIColor.yellow),
            .DownButton:  (SCNVector3(-8.5, -12.2, 1.0), 0.08, UIColor.white, UIColor.yellow),
            
            .RightButton:  (SCNVector3(9.2, -12.2, 1.0), 0.08, UIColor.white, UIColor.yellow),
            .DropDownButton:  (SCNVector3(6.5, -12.2, 1.0), 0.08, UIColor.systemGreen, UIColor.yellow),
            .FlyAwayButton:  (SCNVector3(6.5, -14.5, 1.0), 0.08, UIColor.systemBlue, UIColor.yellow),
            .RotateRightButton:  (SCNVector3(9.2, -14.5, 1.0), 0.08, UIColor.white, UIColor.yellow),
            
            .FreezeButton: (SCNVector3(-1.0, -13.5, 1.0), 0.08, UIColor.cyan, UIColor.blue),
            
            .HeartButton: (SCNVector3(5.0, 11, 1.0), 0.05, UIColor.systemPink, UIColor.red)
    ]
    
    /// Dictionary between node button types and the system image name and location of each node. Intended for use with
    /// devices with small screens.
    let SmallButtonDictionary: [NodeButtons: (Location: SCNVector3, Scale: Double, Color: UIColor, Highlight: UIColor)] =
        [
            .MainButton: (SCNVector3(-10.2, 13, 1.0), 0.08, UIColor.white, UIColor.yellow),
            .FPSButton: (SCNVector3(-8.5, 12.2, 1.0), 0.08, UIColor.white, UIColor.yellow),
            
            .LeftButton: (SCNVector3(-11.2, -12.2, 1.0), 0.08, UIColor.white, UIColor.yellow),
            .RotateLeftButton: (SCNVector3(-11.2, -14.5, 1.0), 0.08, UIColor.white, UIColor.yellow),
            .UpButton: (SCNVector3(-8.5, -14.5, 1.0), 0.08, UIColor.white, UIColor.yellow),
            .DownButton:  (SCNVector3(-8.5, -12.2, 1.0), 0.08, UIColor.white, UIColor.yellow),
            
            .RightButton:  (SCNVector3(9.2, -12.2, 1.0), 0.08, UIColor.white, UIColor.yellow),
            .DropDownButton:  (SCNVector3(6.5, -12.2, 1.0), 0.08, UIColor.systemGreen, UIColor.yellow),
            .FlyAwayButton:  (SCNVector3(6.5, -14.5, 1.0), 0.08, UIColor.systemBlue, UIColor.yellow),
            .RotateRightButton:  (SCNVector3(9.2, -14.5, 1.0), 0.08, UIColor.white, UIColor.yellow),
            
            .FreezeButton: (SCNVector3(-1.0, -13.5, 1.0), 0.08, UIColor.cyan, UIColor.blue),
            
            .HeartButton: (SCNVector3(5.0, 11, 1.0), 0.05, UIColor.systemPink, UIColor.red)
    ]
    
    var MainButtonObject: SCNNode? = nil
    
        var ControlBackground: SCNNode? = nil
    
    var _DisabledControls: Set<NodeButtons> = Set<NodeButtons>()
    
    /// Adjust horizontal values in the passed vector if we're running on a small device.
    /// - Parameter V: The original vector.
    /// - Returns: Possibly changed vector. If running on an iPad, the same value is returned.
    func AdjustForSmallScreens(_ V: SCNVector3) -> SCNVector3
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
    
    // MARK: - Renderer variables.
    
    var NodeRemovalList = [String]()
    var ObjectRemovalList = Set<GameViewObjects>()
    
    // MARK: - About box variables.
    
    var AboutBoxNode: SCNNode? = nil
    var AboutBoxShowing: Bool = false
    var AboutBoxHideTimer: Timer? = nil
    var AboutLightNode: SCNNode? = nil
}

// MARK: - Global enums related to 3DView.

enum GameViewObjects: String, CaseIterable
{
    case Bucket = "Bucket"
    case BucketGrid = "BucketGrid"
    case BucketGridOutline = "BucketGridOutline"
}

enum Angles: CGFloat, CaseIterable
{
    case Angle0 = 0.0
    case Angle90 = 90.0
    case Angle180 = 180.0
    case Angle270 = 270.0
}

/// Set of motion control buttons built in to the game surface.
/// - **LeftButton**: Button to move the piece to the left.
/// - **UpButton**: Button to move the piece up.
/// - **DownButton**: Button to move the piece down.
/// - **RightButton**: Button to move the piece to the right.
/// - **DropDownButton**: Button to drop the piece.
/// - **FlyAwayButton**: Button to fly the piece away.
/// - **RotateLeftButton**: Button to rotate the piece counterclockwise by 90°.
/// - **RotateRightButton**: Button to rotate the piece clockwise by 90°.
/// - **FreezeButton**: Button to freeze a button in place.
/// - **HeartButton**: Button used to display the heartbeat.
/// - **MainButton**: Button for the main menu.
/// - **FlameButton**: Flame button for miscellaneous debug use.
/// - **VideoButton**: Video button.
/// - **CameraButton**: Camera button.
/// - **StopButton**: Stop/play button.
/// - **PauseButton**: Pause/resume button.
/// - **MainButton**: Button for the main menu.
/// - **FlameButton**: Flame button for miscellaneous debug use.
/// - **VideoButton**: Video button.
/// - **CameraButton**: Camera button.
/// - **StopButton**: Stop/play button.
/// - **PauseButton**: Pause/resume button.
enum NodeButtons: String, CaseIterable
{
    case LeftButton = "LeftButton"
    case UpButton = "UpButton"
    case DownButton = "DownButton"
    case RightButton = "RightButton"
    case DropDownButton = "DropDownButton"
    case FlyAwayButton = "FlyAwayButton"
    case RotateLeftButton = "RotateLeftButton"
    case RotateRightButton = "RotateRightButton"
    case FreezeButton = "FreezeButton"
    case HeartButton = "HeartButton"
    case MainButton = "MainButton"
    case FlameButton = "FlameButton"
    case VideoButton = "VideoButton"
    case CameraButton = "CameraButton"
    case PlayButton = "PlayButton"
    case PauseButton = "PauseButton"
    case FPSButton = "FPSButton"
}
