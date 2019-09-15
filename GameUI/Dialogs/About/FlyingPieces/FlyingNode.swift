//
//  FlyingNode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/15/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class FlyingNode: SCNNode
{
    weak var FlyingDelegate: FlyingProtocol? = nil
    
    override init()
    {
        super.init()
        Initialize()
    }
    
    init(_ XRange: (Double, Double), _ YRange: (Double, Double), _ ZRange: (Double, Double))
    {
        super.init()
        Initialize()
        UniverseBounds[.X] = XRange
        UniverseBounds[.Y] = YRange
        UniverseBounds[.Z] = ZRange
    }
    
    init(_ Specular: UIColor, _ Diffuse: UIColor)
    {
        super.init()
        Initialize()
        MainSpecularColor = Specular
        MainDiffuseColor = Diffuse
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    func Initialize()
    {
        
    }
    
    var MainSpecularColor = UIColor.white
    var MainDiffuseColor = UIColor.blue
    
    var UniverseBounds: [UDirs: (Double, Double)] =
    [
        .X: (-100.0, 100.0),
        .Y: (-100.0, 100.0),
        .Z: (-100.0, 100.0)
    ]
    
    public func SetUniverseBounds(For: UDirs, Low: Double, High: Double)
    {
        UniverseBounds[For] = (Low, High)
    }
     
    public func AddBlock(At: (X: Int, Y: Int), WithSize: Double, DiffuseColor: UIColor = UIColor.blue, SpecularColor: UIColor = UIColor.white)
    {
        let Geometry = SCNBox(width: CGFloat(WithSize), height: CGFloat(WithSize), length: CGFloat(WithSize), chamferRadius: 0.0)
        Geometry.firstMaterial?.specular.contents = SpecularColor
        Geometry.firstMaterial?.diffuse.contents = DiffuseColor
        let Node = SCNNode(geometry: Geometry)
        Node.position = SCNVector3(Double(At.X) * WithSize, Double(At.Y) * WithSize, 0)
        self.addChildNode(Node)
    }
    
    public func AddBlock(At: (X: Int, Y: Int), WithSize: Double)
    {
        AddBlock(At: At, WithSize: WithSize, DiffuseColor: MainDiffuseColor, SpecularColor: MainSpecularColor)
    }
    
    public func Rotate(OnX: Double, OnY: Double, OnZ: Double)
    {
        var XRotation: SCNAction? = nil
        var YRotation: SCNAction? = nil
        var ZRotation: SCNAction? = nil
        if OnX == 0.0
        {
            self.removeAction(forKey: "XRotation")
        }
        else
        {
            XRotation = SCNAction.rotateBy(x: CGFloat.pi * 2.0, y: 0.0, z: 0.0, duration: OnX)
            let XForever = SCNAction.repeatForever(XRotation!)
            self.runAction(XForever, forKey: "XRotation")
        }
        if OnY == 0.0
        {
            self.removeAction(forKey: "YRotation")
        }
        else
        {
            YRotation = SCNAction.rotateBy(x: 0.0, y: CGFloat.pi * 2.0, z: 0.0, duration: OnY)
            let YForever = SCNAction.repeatForever(YRotation!)
            self.runAction(YForever, forKey: "YRotation")
        }
        if OnZ == 0.0
        {
            self.removeAction(forKey: "ZRotation")
        }
        else
        {
            ZRotation = SCNAction.rotateBy(x: 0.0, y: 0.0, z: CGFloat.pi * 2.0, duration: OnZ)
            let ZForever = SCNAction.repeatForever(ZRotation!)
            self.runAction(ZForever, forKey: "ZRotation")
        }
    }
    
    public func StartMoving(ToEdgeOfUniverse: Bool = true, Duration: (Min: Double, Max: Double))
    {
        var FinalX = Double.random(in: UniverseBounds[.X]!.0 ... UniverseBounds[.X]!.1)
        var FinalY = Double.random(in: UniverseBounds[.Y]!.0 ... UniverseBounds[.Y]!.1)
                var FinalZ = Double.random(in: UniverseBounds[.Z]!.0 ... UniverseBounds[.Y]!.1)
        #if false
        if ToEdgeOfUniverse
        {
            switch Int.random(in: 0...2)
            {
                case 0:
                    FinalX = [-400.0, 400.0].randomElement()!
                
                case 1:
                    FinalY = [-400.0, 400.0].randomElement()!
                
                case 2:
                    FinalZ = [-400.0, 400.0].randomElement()!
                
                default:
                    break
            }
        }
        #endif
        let FinalDuration = Double.random(in: Duration.Min ... Duration.Max)
        StartObjectMotion(To: SCNVector3(FinalX, FinalY, FinalZ), Duration: FinalDuration)
    }
    
    private func StartObjectMotion(To: SCNVector3, Duration: Double)
    {
        let FlyMove = SCNAction.move(to: To, duration: Duration)
        self.runAction(FlyMove, completionHandler:
            {
                self.FadeOut()
        }
        )
    }
    
    private func FadeOut(Replace: Bool = true)
    {
        let FadeOut = SCNAction.fadeIn(duration: 1.5)
        self.runAction(FadeOut, completionHandler:
            {
                self.FlyingDelegate?.MotionCompleted(Node: self, Replace: Replace)
        }
        )
    }
}

enum UDirs
{
    case X
    case Y
    case Z
}
