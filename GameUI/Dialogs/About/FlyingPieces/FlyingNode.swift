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

/// Node that is made up of cubes in the shape of a game piece.
class FlyingNode: SCNNode
{
    /// Reference to the main scene.
    weak var FlyingDelegate: FlyingProtocol? = nil
    
    /// Default initializer.
    override init()
    {
        super.init()
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter XRange: Valid X axis range for positions of the node.
    /// - Parameter YRange: Valid Y axis range for positions of the node.
    /// - Parameter ZRange: Valid Z axis range for positions of the node.
    init(_ XRange: (Double, Double), _ YRange: (Double, Double), _ ZRange: (Double, Double))
    {
        super.init()
        Initialize()
        UniverseBounds[.X] = XRange
        UniverseBounds[.Y] = YRange
        UniverseBounds[.Z] = ZRange
    }
    
    /// Initializer. If this initializer is not used, default colors are used for the specular and diffuse surface.
    /// - Parameter Specular: Specular color override.
    /// - Parameter Diffuse: Diffuse color override.
    init(_ Specular: UIColor, _ Diffuse: UIColor)
    {
        super.init()
        Initialize()
        MainSpecularColor = Specular
        MainDiffuseColor = Diffuse
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Internal initialization. Not currently required.
    private func Initialize()
    {
        
    }
    
    /// Specular color to use for the piece's surface material.
    public var MainSpecularColor = UIColor.white
    
    /// Diffuse color to use for the piece's surface material.
    public var MainDiffuseColor = UIColor.blue
    
    /// Dictionary of bounds for the piece.
    public var UniverseBounds: [UDirs: (Double, Double)] =
        [
            .X: (-100.0, 100.0),
            .Y: (-100.0, 100.0),
            .Z: (-100.0, 100.0)
    ]
    
    /// Set the bounds of the piece for the specified axis.
    /// - Note: This class (as well as `FlyingPieces`) was written on the assumption the bounds are symmetrical about the origin.
    ///         For that reason, **Low** should be the negative value of **High**.
    /// - Parameter For: The axis whose bounds will be set.
    /// - Parameter Low: Low value of the bounds.
    /// - Parameter High: High value of the bounds.
    public func SetUniverseBounds(For: UDirs, Low: Double, High: Double)
    {
        UniverseBounds[For] = (Low, High)
    }
    
    /// Add a block to the piece.
    /// - Parameter At: Tuple with the base coordinates of the block. This function assumes the values in this tuple are in logical
    ///                 units, eg, 1, 2, 3, etc, and do not take into account the size of the block.
    /// - Parameter WithSize: The actual size of the block in the scene.
    /// - Parameter DiffuseColor: The color to use for the diffuse material.
    /// - Parameter SpecularColor: The color to use for the specular material.
    public func AddBlock(At: (X: Int, Y: Int), WithSize: Double, DiffuseColor: UIColor = UIColor.blue, SpecularColor: UIColor = UIColor.white)
    {
        let Geometry = SCNBox(width: CGFloat(WithSize), height: CGFloat(WithSize), length: CGFloat(WithSize), chamferRadius: 0.0)
        Geometry.firstMaterial?.specular.contents = SpecularColor
        Geometry.firstMaterial?.diffuse.contents = DiffuseColor
        let Node = SCNNode(geometry: Geometry)
        Node.position = SCNVector3(Double(At.X) * WithSize, Double(At.Y) * WithSize, 0)
        self.addChildNode(Node)
    }
    
    /// Add a block to the piece.
    /// - Note: this function uses `MainDiffuseColor` and `MainSpecularColor` for the material's colors.
    /// - Parameter At: Tuple with the base coordinates of the block. This function assumes the values in this tuple are in logical
    ///                 units, eg, 1, 2, 3, etc, and do not take into account the size of the block.
    /// - Parameter WithSize: The actual size of the block in the scene.
    public func AddBlock(At: (X: Int, Y: Int), WithSize: Double)
    {
        AddBlock(At: At, WithSize: WithSize, DiffuseColor: MainDiffuseColor, SpecularColor: MainSpecularColor)
    }
    
    /// Set the piece's rotational attributes.
    /// - Parameter OnX: The amount of time to rotate through 360° on the X axis. If 0.0, no rotation occurs.
    /// - Parameter OnY: The amount of time to rotate through 360° on the Y axis. If 0.0, no rotation occurs.
    /// - Parameter OnZ: The amount of time to rotate through 360° on the Z axis. If 0.0, no rotation occurs.
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
    
    /// Start the piece's motion.
    /// - Parameter ToEdgeOfUniverse: If true, the piece will have as its ending location one of the sides of the universe
    ///                               as defined in the dictionary `UniverseBounds`. Otherwise, a random point will be used.
    /// - Parameter Duration: Tuple that defines a range used to generate a random number that is the amount of time for the
    ///                       piece (in seconds) to travel from its origin to its destination.
    public func StartMoving(ToEdgeOfUniverse: Bool = true, Duration: (Min: Double, Max: Double))
    {
        var FinalX = Double.random(in: UniverseBounds[.X]!.0 ... UniverseBounds[.X]!.1)
        var FinalY = Double.random(in: UniverseBounds[.Y]!.0 ... UniverseBounds[.Y]!.1)
        var FinalZ = Double.random(in: UniverseBounds[.Z]!.0 ... UniverseBounds[.Y]!.1)
        if ToEdgeOfUniverse
        {
            let RandomAxis = UDirs.allCases.randomElement()!
            let Final = [UniverseBounds[RandomAxis]!.0, UniverseBounds[RandomAxis]!.1].randomElement()!
            switch RandomAxis
            {
                case .X:
                    FinalX = Final
                
                case .Y:
                    FinalY = Final
                
                case .Z:
                    FinalZ = Final
            }
        }
        let FinalDuration = Double.random(in: Duration.Min ... Duration.Max)
        StartObjectMotion(To: SCNVector3(FinalX, FinalY, FinalZ), Duration: FinalDuration)
    }
    
    /// Starts the actual motion action for the piece.
    /// - Parameter To: The destination of the piece. The start location is the piece's origin.
    /// - Parameter Duration: The number of seconds for the motion.
    private func StartObjectMotion(To: SCNVector3, Duration: Double)
    {
        let FlyMove = SCNAction.move(to: To, duration: Duration)
        self.runAction(FlyMove, completionHandler:
            {
                self.FadeOut()
        }
        )
    }
    
    /// Fade out the piece. Called when motion is completed.
    /// - Note: The piece's parent is called to let it know a piece is gone.
    /// - Parameter Replace: If true (default), a new piece is generated to replace this one.
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

/// Used to specify axes.
/// - **X**: X axis.
/// - **Y**: Y axis.
/// - **Z**: Z axis.
enum UDirs: CaseIterable
{
    case X
    case Y
    case Z
}
