//
//  +BucketCleaner.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit
import UIKit
import simd

/// Contains functions related to visually removing individual blocks from the game board. Intended to be used to clear the
/// board at the end of the game in preparation for a new game.
extension View3D
{
    func RotateVectorOnZ(By: Float) -> simd_float3x3
    {
        let Rows =
        [
            simd_float3(cos(By), sin(By), 0),
            simd_float3(-sin(By), cos(By), 0),
            simd_float3(0, 0, 1)
        ]
        return float3x3(rows: Rows)
    }
    
    func RotateVector(Vector: SCNVector3, By Angle: Float) -> SCNVector3
    {
        let SVector = simd_float3(x: Vector.x, y: Vector.y, z: Vector.z)
        let RotationMatrix = RotateVectorOnZ(By: Angle)
        let Rotated = SVector * RotationMatrix
        return SCNVector3(x: Rotated.x, y: Rotated.y, z: Rotated.z)
    }
    
    func RandomVector(ToRange: Float, UseZ: Float? = nil, DoNotRandomizeZ: Bool = false) -> SCNVector3
    {
        let RangeMultiplier: Float = Float([-1.0, 1.0].randomElement()!)
        var Vector: SCNVector3!
        var FinalZ = UseZ == nil ? Float.random(in: 10.0 ... ToRange) : UseZ!
        var SwitchValues = [0, 1]
        if !DoNotRandomizeZ
        {
            SwitchValues.append(2)
        }
        switch SwitchValues.randomElement()!
        {
            case 0:
            //X is the range.
                
                Vector = SCNVector3(ToRange * RangeMultiplier, Float.random(in: 10.0 ... ToRange), FinalZ)
            
            case 1:
            //Y is the range.
                Vector = SCNVector3(Float.random(in: 10.0 ... ToRange), ToRange * RangeMultiplier, FinalZ)
            
            case 2:
            //Z is the range.
            Vector = SCNVector3(Float.random(in: 10.0 ... ToRange), Float.random(in: 10.0 ... ToRange), ToRange * RangeMultiplier)
            
            default:
            return SCNVector3Zero
        }
        
        return Vector
    }
    
    /// Returns the length of the passed vector.
    /// - Parameter OfVector: The vector whose length will be returned.
    /// - Returns: The length of the vector.
    func Length(OfVector: SCNVector3) -> Float
    {
        return (OfVector.x * OfVector.x) + (OfVector.y * OfVector.y) + (OfVector.z * OfVector.z)
    }
    
    /// Returns a new vector based on `From` that has the length of `TargetDistance`.
    /// - Parameter From: Source vector.
    /// - Parameter TargetDistance: The new distance for the returned vector.
    /// - Returns: Vector based on `From` but with a length of `TargetDistance`.
    func RadialVector(From: SCNVector3, TargetDistance: Float) -> SCNVector3
    {
        let VectorLength = Length(OfVector: From)
        var NewLength = TargetDistance - VectorLength
        if NewLength < 0.0
        {
            NewLength = TargetDistance
        }
        let NewVector = SCNVector3(From.x * NewLength, From.y * NewLength, From.z * NewLength)
        return NewVector
    }
    
    /// Rough simulation of gravity over time for dropping blocks in `BucketCleaner`.
    /// - Parameter Source: Source value.
    /// - Returns: New value.
    func Gravity(Source: Float) -> Float
    {
        return 1.0 - Source * Source
    }
    
    /// Returns a method type for clearing the bucket visually.
    /// - Parameter From: The base method to clear the bucket. If this value is **.Random**, the returned value will be a randomly
    ///                   selected method.
    /// - Returns: The same value as in **From** unless **From** was **.Random**, in which case a random method will be returned.
    func GetVisualMethod(From: DestructionMethods) -> DestructionMethods
    {
        if From != .Random
        {
            return From
        }
        while true
        {
            let NewMethod = DestructionMethods.allCases.randomElement()
            if NewMethod == .Random
            {
                continue
            }
            if NewMethod == .None
            {
                continue
            }
            return NewMethod!
        }
    }
    
    /// Visually cleans the bucket by removing all retired blocks/pieces.
    /// - Note:
    ///   - Should be called only after the game ends.
    ///   - The list of blocks in **Blocks** is *not* modified.
    ///   - Control is not returned until all blocks' actions have been completed.
    /// - Parameter Method: The visual method to use to remove the blocks. If this value is **.Random**, a visual method will be
    ///                     selected at random (and not treated as **.None**.)
    /// - Parameter MaxDuration: The maximum amount of time to take to remove all of the blocks.
    func BucketCleaner(_ Method: DestructionMethods, MaxDuration: Double)
    {
        let BlockCount = self.BlockList.count
        if BlockCount < 1
        {
            print("Nothing to clean in BucketCleaner.")
            return
        }
        
        let VisualMethod = GetVisualMethod(From: Method)
        print("Cleaning bucket with Method: \(VisualMethod)")
        switch VisualMethod
        {
            case .Random:
                //Random doesn't actually do anything - it's an instruction to select a random method.
            fallthrough
            case .None:
                //Regardless of the number of blocks in the block list, do not perform any animation. Just remove all items.
                for Block in self.BlockList
                {
                    Block.removeFromParentNode()
                }
                return
            
            case .Drop:
                for Block in self.BlockList
                {
                    Block.removeAllActions()
                    let FallTo = SCNAction.move(to: SCNVector3(Block.X, -20.0, Block.Z), duration: Double.random(in: 0.25 ... MaxDuration))
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([FallTo, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .Explode:
                break
            
            case .ExplodingBlocks:
                break
            
            case .FadeAway:
                for Block in self.BlockList
                {
                    Block.removeAllActions()
                    let FadeOut = SCNAction.fadeOut(duration: Double.random(in: 0.25 ... MaxDuration))
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([FadeOut, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .Shrink:
                for Block in self.BlockList
                {
                    Block.removeAllActions()
                    let Scale = SCNAction.scale(to: 0.0, duration: Double.random(in: 0.25 ... MaxDuration))
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([Scale, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .Grow:
                for Block in self.BlockList
                {
                    Block.removeAllActions()
                    let AnimationDuration = Double.random(in: 0.25 ... MaxDuration)
                    let Scale = SCNAction.scale(to: 10.0, duration: AnimationDuration)
                    let FadeOut = SCNAction.fadeOut(duration: AnimationDuration)
                    let Group = SCNAction.group([Scale, FadeOut])
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([Group, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .SpinAway:
                for Block in self.BlockList
                {
                    let TargetVector = RadialVector(From: SCNVector3(Block.X, Block.Y, Block.Z), TargetDistance: 40.0)
                    let AnimationDuration = Double.random(in: 0.25 ... MaxDuration)
                    let SpinAction = SCNAction.rotateBy(x: 1.0, y: 1.0, z: 1.0, duration: AnimationDuration)
                    let MoveTo = SCNAction.move(to: TargetVector, duration: AnimationDuration)
                    let ActionGroup = SCNAction.group([SpinAction, MoveTo])
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([ActionGroup, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .SpinDown:
                for Block in self.BlockList
                {
                    let AnimationDuration = Double.random(in: 0.25 ... MaxDuration)
                    let SpinAction = SCNAction.rotateBy(x: 1.0, y: 1.0, z: 1.0, duration: AnimationDuration)
                    let ShrinkAction = SCNAction.scale(to: 0.01, duration: AnimationDuration)
                    let ActionGroup = SCNAction.group([SpinAction, ShrinkAction])
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([ActionGroup, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .Scatter:
                for Block in self.BlockList
                {
                    let TargetVector = RandomVector(ToRange: 40.0, UseZ: Float(Block.Z), DoNotRandomizeZ: true)
                    let AnimationDuration = Double.random(in: 0.25 ... MaxDuration)
                    let MoveTo = SCNAction.move(to: TargetVector, duration: AnimationDuration)
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([MoveTo, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .ScatterRadially:
                for Block in self.BlockList
                {
                    let TargetVector = RadialVector(From: SCNVector3(Block.X, Block.Y, Block.Z), TargetDistance: 40.0)
                    let AnimationDuration = Double.random(in: 0.25 ... MaxDuration)
                    let MoveTo = SCNAction.move(to: TargetVector, duration: AnimationDuration)
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([MoveTo, KillBlock])
                    Block.runAction(Sequence)
                }
            
            case .ScatterHorizontally:
                break
            
            case .ScatterVertically:
                break
            
            case .ScatterDirectionally:
                for Block in self.BlockList
                {
                    var TargetVector: SCNVector3 = SCNVector3Zero
                    let Rotated = RotateVector(Vector: SCNVector3(Block.X, Block.Y, Block.Z), By: 45.0 * Float.pi / 180.0)
                    if Rotated.x >= 0.0 && Rotated.y >= 0.0
                    {
                        //Move up
                        TargetVector = SCNVector3(Block.X, -40.0, Block.Z)
                    }
                    if Rotated.x >= 0.0 && Rotated.y < 0.0
                    {
                        //Move right
                        TargetVector = SCNVector3(40.0, Block.Y, Block.Z)
                    }
                    if Rotated.x < 0.0 && Rotated.y < 0.0
                    {
                        //Move down
                        TargetVector = SCNVector3(Block.X, 40.0, Block.Z)
                    }
                    if Rotated.x < 0.0 && Rotated.y >= 0.0
                    {
                        //Move left
                        TargetVector = SCNVector3(-40.0, Block.Y, Block.Z)
                    }
                    let AnimationDuration = Double.random(in: 0.25 ... MaxDuration)
                    let MoveTo = SCNAction.move(to: TargetVector, duration: AnimationDuration)
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([MoveTo, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .FlyFromSides:
                //Valid only for .Rotating4 games. If called for a non-.Rotating4 game,
                //this case is treated the same as .None.
                if BaseGameType == .Rotating4
                {
                    
                }
                else
                {
                    //We're not a .Rotating4 game so just return.
                    return
            }
        }
    }
}

/// Used to specify how to empty the bucket after game over.
/// - **None**: Do nothing - just clear the board.
/// - **Scatter**: Scatter the blocks in random directions.
/// - **Explode**: Blocks fly away radially from the center.
/// - **FadeAway**: Blocks fade out.
/// - **ExplodingBlocks**: Blocks explode.
/// - **Drop**: Blocks drop out the bottom.
/// - **ScatterHorizontally**: Blocks randomly fly left or right.
/// - **ScatterVertically**: Blocks randomly fly up or down.
/// - **ScatterDirectionally**: Blocks fly towards the closest edge.
/// - **FlyFromSides**: Blocks fly away directly from their side. Used for **.Rotating4**
///                     games only.
/// - **ScatterRadially**: Blocks fly away in a straight line radially away from the bucket center.
/// - **SpinDown**: Blocks spin rapidly and shrink simultaneously.
/// - **SpinAway**: Blocks spin and fly away radially.
/// - **Shrink**: Blocks shrink to nothingness.
/// - **Grow**: Blocks enlarge to infinity (or effectively close enough for the game) and lose opacity.
/// - **Random**: Certain functions will select a random case from this enum (other than **.Random**). If not, functions are
///               expected to treat **.Random** the same as **.None**.
enum DestructionMethods: String, CaseIterable
{
    case None = "None"
    case Scatter = "Scatter"
    case Explode = "Explode"
    case FadeAway = "FadeAway"
    case ExplodingBlocks = "ExplodingBlocks"
    case Drop = "Drop"
    case ScatterHorizontally = "ScatterHorizontally"
    case ScatterVertically = "ScatterVertically"
    case ScatterDirectionally = "ScatterDirectionally"
    case FlyFromSides = "FlyFromSides"
    case ScatterRadially = "ScatterRadially"
    case SpinDown = "SpinDown"
    case SpinAway = "SpinAway"
    case Shrink = "Shrink"
    case Grow = "Grow"
    case Random = "Random"
}
