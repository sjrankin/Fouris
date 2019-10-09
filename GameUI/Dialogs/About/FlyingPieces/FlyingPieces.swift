//
//  FlyingPieces.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import AVFoundation
import ReplayKit
import Photos

/// Overriden SCNView to show flying pieces.
/// - Note:
///     - The user can select a live view as the background for the flying pieces. This has the effect of slowing things down
///       a bit and using up the battery faster. Switching from a solid color to a live view (and back) takes a lot of time
///       (on the order of seconds) as well.
///     - The live view background is not available when running on the simulator.
class FlyingPieces: SCNView, SCNSceneRendererDelegate, RPPreviewViewControllerDelegate, FlyingProtocol
{
    /// Required by framework.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.delegate = self
        Initialize()
    }
    
    /// Main scene.
    private var MainScene: SCNScene? = nil
    
    /// Initialize a scene.
    func Initialize()
    {
        PrimaryNode = SCNNode()
        PrimaryNode?.position = SCNVector3(0.0, 0.0, 0.0)
        self.clipsToBounds = true
        self.antialiasingMode = .multisampling4X
        let MainScene = SCNScene()
        self.scene = MainScene
        AddCamera()
        AddLights()
        self.backgroundColor = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
        self.showsStatistics = true
        self.debugOptions = [.showSkeletons, .showWireframe]
        self.scene?.rootNode.addChildNode(PrimaryNode!)
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleFlyingTap))
        Tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(Tap)
        if !UserDefaults.standard.bool(forKey: "RunningOnSimulator")
        {
            let Press = UILongPressGestureRecognizer(target: self, action: #selector(ToggleLiveView))
            Press.minimumPressDuration = 1.0
            self.addGestureRecognizer(Press)
        }
    }
    
    /// Toggles the live view for the background.
    /// - Note:
    ///   - Switching to or from a live view takes an appreciable amount of time and is quite slow.
    ///   - This functionality isn't available when running on a simulator.
    /// - Parameter Recognizer: The gesture recognizer.
    @objc func ToggleLiveView(Recognizer: UIGestureRecognizer)
    {
        if UserDefaults.standard.bool(forKey: "RunningOnSimulator")
        {
            return
        }
        if Recognizer.state == .began
        {
            ShowLiveView = !ShowLiveView
            if ShowLiveView
            {
                let CaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)!
                self.backgroundColor = UIColor.clear
                self.scene?.background.contents = CaptureDevice
            }
            else
            {
                self.scene?.background.contents = nil
                self.backgroundColor = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
            }
        }
    }
    
    /// Holds the showing-live-view flag.
    var ShowLiveView: Bool = false
    
    /// Handles the tap that determines the speed of rotation of the pieces about the visual Z axis.
    /// - Note: Initially, the scene does not rotate around the Z axis.
    /// - Parameter Recognizer: The gesture recognizer.
    @objc func HandleFlyingTap(Recognizer: UIGestureRecognizer)
    {
        if Recognizer.state == .ended
        {
            CurrentRotationDurationIndex = CurrentRotationDurationIndex + 1
            if CurrentRotationDurationIndex >= SceneRotationDurations.count
            {
                CurrentRotationDurationIndex = 0
            }
            let RotateDuration = SceneRotationDurations[CurrentRotationDurationIndex]
            if RotateDuration == 0.0
            {
                PrimaryNode?.removeAllActions()
                return
            }
            let Rotate = SCNAction.rotateBy(x: 0.0, y: 0.0, z: CGFloat.pi / 180 * -360.0, duration: RotateDuration)
            let Forever = SCNAction.repeatForever(Rotate)
            PrimaryNode?.runAction(Forever)
        }
    }
    
    /// Current rotation index that determines how fast to rotate objects in the scene around the Z axis.
    var CurrentRotationDurationIndex = 0
    /// Speeds of rotation around the Z axis.
    let SceneRotationDurations = [0.0, 60.0, 30.0, 20.0, 10.0, 3.0]
    
    /// Adds lighting to the scene.
    private func AddLights()
    {
        let Light = SCNLight()
        Light.color = UIColor.white.cgColor
        Light.type = .omni
        LightNode = SCNNode()
        LightNode?.position = SCNVector3(-10.0, 10.0, 30.0)
        LightNode?.light = Light
        self.scene?.rootNode.addChildNode(LightNode!)
    }
    
    /// The light node.
    private var LightNode: SCNNode? = nil
    
    /// Adds a camera to the scene.
    private func AddCamera()
    {
        let Camera = SCNCamera()
        Camera.fieldOfView = 92.5
        Camera.zFar = 1000.0
        CameraNode = SCNNode()
        CameraNode?.camera = Camera
        CameraNode?.position = SCNVector3(0.0, 0.0, 25.0)
        CameraNode?.orientation = SCNVector4(0.0, 0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(CameraNode!)
    }
    
    /// The camera node.
    private var CameraNode: SCNNode? = nil
    
    /// Play the scene with the specified number of pieces.
    /// - Note: Depending on the hardware, too many simultaneous pieces will dramatically harm the frame rate.
    /// - Parameter PieceCount: The number of simultaneous pieces in the scene.
    public func Play(PieceCount: Int)
    {
        EnterSteadyState(Count: PieceCount)
    }
    
    /// Enter the steady state in which for each piece that disappears, a new one is added.
    /// - Parameter Count: Number of simultaneous pieces to show.
    func EnterSteadyState(Count: Int)
    {
        MakePieces(Count: Count)
    }
    
    /// Stop the scene. All pieces are removed.
    /// - Parameter NoRotate: If true, any rotations are removed. Defaults to false.
    public func Stop(NoRotate: Bool = false)
    {
        PrimaryNode?.childNodes.forEach
            {
                $0.removeAllActions()
                $0.removeFromParentNode()
        }
        if NoRotate
        {
            PrimaryNode?.removeAllActions()
        }
    }
    
    /// Make a certain number of pieces.
    /// - Note: All existing pieces are removed first.
    /// - Parameter Count: Number of pieces to create and add to the scene.
    func MakePieces(Count: Int)
    {
        Stop()
        for _ in 0 ..< Count
        {
            MakeOnePiece()
        }
    }
    
    /// List of piece shapes that can be displayed in the scene.
    let PieceList: [PieceShapes] = [.Bar, .S, .Z, .T, .L, .backL, .Zig, .Zag, .ShortL, .ShortBackL, .C, .Plus, .Corner, .JoinedSquares,
                                    .EmptyBox, .lowerI, .EmptyDiamond, .ParallelLines, .Sweeper, .CapitalI, .CapitalO, .Diagonal,
                                    .X, .BigGap, .LongGap, .LongDiagonal, .V, .FarApart, .BigBlock3x3, .BigBlock4x4]
    
    /// Returns a random piece shape.
    /// - Returns: Random piece shape from `PieceList`.
    func RandomPiece() -> PieceShapes
    {
        return PieceList.randomElement()!
    }
    
    /// Make a piece shape and return it.
    /// - Parameter Shape: The shape of the piece to create.
    /// - Returns: A SCNNode overridden as a `FlyingNode` that contain the object to display in the scene. Nil returned on error.
    func MakePiece(_ Shape: PieceShapes) -> FlyingNode?
    {
        var PieceNode: FlyingNode? = nil
        let ShapeID = PieceFactory.ShapeIDMap[Shape]!
        if let Definition = PieceManager.GetPieceDefinitionFor(ID: ShapeID)
        {
            PieceNode = FlyingNode(UIColor.white, ColorServer.RandomColor(MinRed: 0.25, MinGreen: 0.25, MinBlue: 0.25))
            for Point in Definition.Locations
            {
                PieceNode?.FlyingDelegate = self
                PieceNode?.AddBlock(At: (Point.Coordinates.X!, Point.Coordinates.Y!), WithSize: 2.0)
            }
        }
        else
        {
            print("Error getting definition for \(Shape), ID=\((ShapeID))")
        }
        return PieceNode
    }
    
    /// Makes one random piece to display in the scene.
    func MakeOnePiece()
    {
        if let NewPiece = MakePiece(RandomPiece())
        {
            NewPiece.position = SCNVector3(Double.random(in: -100...100), Double.random(in: -100...100), Double.random(in: -100...100))
            NewPiece.Rotate(OnX: Double.random(in: 0.5 ... 5.0), OnY: Double.random(in: 0.5 ... 5.0), OnZ: Double.random(in: 0.5 ... 5.0))
            NewPiece.StartMoving(ToEdgeOfUniverse: true, Duration: (8.0, 20.0))
            NewPiece.opacity = 0.0
            PrimaryNode?.addChildNode(NewPiece)
            NewPiece.runAction(SCNAction.fadeIn(duration: 0.5),
                               completionHandler:
                {
                    self.MotionCompleted(Node: NewPiece, Replace: true)
            })
        }
    }
    
    /// The primary node. All flying pieces are contained in this node.
    /// - Note: By rotating this single node, we can simulate camera rotation about the Z axis (something that is probably possible
    ///         using SceneKit APIs but not really documented).
    var PrimaryNode: SCNNode? = nil
    
    /// Called by a piece when its motion is completed.
    /// - Parameter Node: The node that completed motion.
    /// - Parameter Replace: If true, a new piece is created to keep steady state going.
    func MotionCompleted(Node: SCNNode, Replace: Bool)
    {
        OperationQueue.main.addOperation
            {
                let FadeOut = SCNAction.fadeOut(duration: 0.2)
                let RemoveNode = SCNAction.removeFromParentNode()
                let Sequence = SCNAction.sequence([FadeOut, RemoveNode])
                Node.runAction(Sequence, completionHandler:
                    {
                        if Replace
                        {
                            OperationQueue.main.addOperation
                                {
                                    self.MakeOnePiece()
                            }
                        }
                })
        }
    }
    
    /// Called once a frame. Save the scene image in the `ImageArray` for use later on. No action if `CreatingVideo` is false
    /// - Parameter renderer: Not used.
    /// - Parameter didRenderScene: Not used.
    /// - Parameter atTime: Not used.
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval)
    {
        if CreatingVideo
        {
            let SceneImage = snapshot()
            ImageArray.append(SceneImage)
        }
    }
    
    /// Holds an array of images created for each frame for the intent of creating a video.
    var ImageArray: [UIImage] = [UIImage]()
    
    /// Start saving frames for video creation.
    /// - Note: See [How to record user videos using ReplayKit](https://www.hackingwithswift.com/example-code/media/how-to-record-user-videos-using-replaykit)
    public func StartVideo()
    {
        //        CreatingVideo = true
        let Recorder = RPScreenRecorder.shared()
        Recorder.startRecording
            {
                (error) in
                if let UnwrappedError = error
                {
                    print(UnwrappedError.localizedDescription)
                }
        }
    }
    
    /// Holds the video creation flag.
    private var CreatingVideo: Bool = false
    
    /// Stop saving frames for the intent of creating a video.
    /// - Parameter Clear: If true, all saved frames are cleared.
    public func StopVideo(Clear: Bool = false)
    {
        //CreatingVideo = false
        //if Clear
        //{
        //    ImageArray.removeAll()
        //}
        let Recorder = RPScreenRecorder.shared()
        Recorder.stopRecording(handler:
            {
                PreviewController, error in
                if let Error = error
                {
                    print("\(Error.localizedDescription)")
                }
                if UIDevice.current.userInterfaceIdiom == .pad
                {
                    PreviewController?.modalPresentationStyle = UIModalPresentationStyle.popover
                    PreviewController?.popoverPresentationController?.sourceRect = CGRect.zero
                    PreviewController?.popoverPresentationController?.sourceView = self
                }
                if PreviewController != nil
                {
                    PreviewController?.previewControllerDelegate = self
                }
                if let Controller = self.FindViewController()
                {
                    Controller.present(PreviewController!, animated: true)
                }
        })
    }
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController)
    {
        previewController.dismiss(animated: true)
    }
    
    /// Save the set of saved frame images as a video to the photo roll. If no frames are available, no action is taken.
    /// - Note: See: [](https://stackoverflow.com/questions/3741323/how-do-i-export-uiimage-array-as-a-movie)
    /// - Returns: True on success, false on failure (or no images to save).
    public func SaveVideo() -> Bool
    {
        return false
    }
}

extension UIView
{
    func FindViewController() -> UIViewController?
    {
        if let NextResponder = self.next as? UIViewController
        {
            return NextResponder
        }
        else
        {
            if let NextResponder = self.next as? UIView
            {
                return NextResponder.FindViewController()
            }
            else
            {
                return nil
            }
        }
    }
}
