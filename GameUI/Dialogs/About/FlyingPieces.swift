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

class FlyingPieces: SCNView
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
        self.clipsToBounds = true
        self.antialiasingMode = .multisampling2X
        let MainScene = SCNScene()
        self.scene = MainScene
        AddCamera()
        AddLights()
    }
    
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
        
    }
    
    public func Stop()
    {
        
    }
    
    func AddPiece(_ Shape: PieceShapes)
    {
        let ShapeID = PieceFactory.ShapeIDMap[Shape]
        if let Definition = MasterPieceList.GetPieceDefinitionFor(ID: ShapeID!)
        {
            let PieceNode = SCNNode()
            for Point in Definition.LogicalLocations
            {
                AddBlock(To: PieceNode, At: (Point.X, Point.Y))
            }
            PieceNode.position = StartingLocation()
            self.scene?.rootNode.addChildNode(PieceNode)
        }
        else
        {
            print("Error getting definition for \(Shape)/\((ShapeID)!)")
        }
    }
    
    func AddBlock(To: SCNNode, At: (X: Int, Y: Int), WithSize: CGFloat = 1.0)
    {
        let Cube = SCNBox(width: WithSize, height: WithSize, length: WithSize, chamferRadius: 0.0)
        Cube.firstMaterial?.specular.contents = UIColor.red
        Cube.firstMaterial?.diffuse.contents = UIColor.white
        let Node = SCNNode(geometry: Cube)
        Node.position = SCNVector3(CGFloat(At.X), CGFloat(At.Y), 0.0)
        To.addChildNode(Node)
    }
    
    func StartingLocation() -> SCNVector3
    {
        let X = CGFloat.random(in: -400.0 ... 400.0)
        let Y = CGFloat.random(in: -400.0 ... 400.0)
        let Z = CGFloat.random(in: -400.0 ... 400.0)
        return SCNVector3(X, Y, Z)
    }
}
