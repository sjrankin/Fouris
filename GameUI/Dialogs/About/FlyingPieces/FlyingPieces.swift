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

class FlyingPieces: SCNView, FlyingProtocol
{
    /// Required by framework.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    private var MainScene: SCNScene? = nil
    
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
    
    var ShowLiveView: Bool = false
    
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
    
    var CurrentRotationDurationIndex = 0
    let SceneRotationDurations = [0.0, 60.0, 30.0, 20.0, 10.0, 3.0]
    
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
    
    private var LightNode: SCNNode? = nil
    
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
    
    private var CameraNode: SCNNode? = nil
    
    public func Play(PieceCount: Int)
    {
        EnterSteadyState(Count: PieceCount)
    }
    
    func EnterSteadyState(Count: Int)
    {
        MakePieces(Count: Count)
    }
    
    public func Stop()
    {
        #if true
        PrimaryNode?.childNodes.forEach
            {
                $0.removeAllActions()
                $0.removeFromParentNode()
        }
        #else
        self.scene?.rootNode.childNodes.forEach(
            {
                $0.removeAllActions()
                $0.removeFromParentNode()
            }
        )
        #endif
    }
    
    func MakePieces(Count: Int)
    {
        #if true
        PrimaryNode?.childNodes.forEach
            {
                $0.removeAllActions()
                $0.removeFromParentNode()
        }
        #else
        self.scene?.rootNode.childNodes.forEach({$0.removeFromParentNode()})
        #endif
        for _ in 0 ..< Count
        {
            MakeOnePiece()
        }
    }
    
    let PieceList: [PieceShapes] = [.Bar, .S, .Z, .T, .L, .backL, .Zig, .Zag, .ShortL, .ShortBackL, .C, .Plus, .Corner, .JoinedSquares,
                                    .EmptyBox, .lowerI, .EmptyDiamond, .ParallelLines, .Sweeper, .CapitalI, .CapitalO, .Diagonal,
                                    .X, .BigGap, .LongGap, .LongDiagonal, .V, .FarApart, .BigBlock3x3, .BigBlock4x4]
    
    func RandomPiece() -> PieceShapes
    {
        return PieceList.randomElement()!
    }
    
    func MakePiece(_ Shape: PieceShapes) -> FlyingNode?
    {
        var PieceNode: FlyingNode? = nil
        let ShapeID = PieceFactory.ShapeIDMap[Shape]
        if let Definition = MasterPieceList.GetPieceDefinitionFor(ID: ShapeID!)
        {
            PieceNode = FlyingNode(UIColor.white, ColorServer.RandomColor(MinRed: 0.25, MinGreen: 0.25, MinBlue: 0.25))
            for Point in Definition.LogicalLocations
            {
                PieceNode?.FlyingDelegate = self
                PieceNode?.AddBlock(At: (Point.X, Point.Y), WithSize: 2.0)
            }
        }
        else
        {
            print("Error getting definition for \(Shape)/\((ShapeID)!)")
        }
        return PieceNode
    }
    
    func MakeOnePiece()
    {
        let NewPiece = MakePiece(RandomPiece())
        NewPiece?.position = SCNVector3(Double.random(in: -100...100), Double.random(in: -100...100), Double.random(in: -100...100))
        NewPiece?.Rotate(OnX: Double.random(in: 0.5 ... 5.0), OnY: Double.random(in: 0.5 ... 5.0), OnZ: Double.random(in: 0.5 ... 5.0))
        NewPiece?.StartMoving(ToEdgeOfUniverse: true, Duration: (8.0, 20.0))
        #if true
        NewPiece?.opacity = 0.0
        PrimaryNode?.addChildNode(NewPiece!)
        NewPiece?.runAction(SCNAction.fadeIn(duration: 0.5))
        #else
        self.scene?.rootNode.addChildNode(NewPiece!)
        #endif
    }
    
    var PrimaryNode: SCNNode? = nil
    
    func MotionCompleted(Node: SCNNode, Replace: Bool)
    {
        Node.removeAllActions()
        Node.removeFromParentNode()
        if Replace
        {
            OperationQueue.main.addOperation
                {
                    self.MakeOnePiece()
            }
        }
    }
}
