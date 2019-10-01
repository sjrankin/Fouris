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
    /// Creates a rotation matrix for rotating about the Z axis.
    /// - Parameter By: The angle (in radians) to rotate.
    /// - Returns: Rotation matrix to rotate about the Z axis on the passed angle.
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
    
    /// Rotate a vector about the Z axis by the passed angle.
    /// - Note: The vector is rotated about the origin.
    /// - Parameter Vector: The vector to rotate.
    /// - Parameter By: The angle (in radians) to rotate the vector by.
    /// - Returns: Rotated vector.
    func RotateVector(Vector: SCNVector3, By Angle: Float) -> SCNVector3
    {
        let SVector = simd_float3(x: Vector.x, y: Vector.y, z: Vector.z)
        let RotationMatrix = RotateVectorOnZ(By: Angle)
        let Rotated = SVector * RotationMatrix
        return SCNVector3(x: Rotated.x, y: Rotated.y, z: Rotated.z)
    }
    
    /// Create a random vector.
    /// - Parameter ToRange: The maximum value for the wall. The wall is one of the sides of the view.
    /// - Parameter UseZ: If present, the Z value to use.
    /// - Parameter DoNotRandomizeZ: If true, Z is not selected as a wall value (in other words, randomness is for X and Y only).
    /// - Returns: Randomized vector.
    func RandomVector(ToRange: Float, UseZ: Float? = nil, DoNotRandomizeZ: Bool = false) -> SCNVector3
    {
        let RangeMultiplier: Float = Float([-1.0, 1.0].randomElement()!)
        var Vector: SCNVector3!
        let FinalZ = UseZ == nil ? Float.random(in: 10.0 ... ToRange) : UseZ!
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
            if [DestructionMethods.Random, DestructionMethods.None, DestructionMethods.Fast].contains(NewMethod)
            {
                continue
            }
            return NewMethod!
        }
    }
    
    /// Adds a random value to the passed value and returns the result.
    /// - Parameter Value: Base, source value.
    /// - Parameter Range: Determines the range of the random number. The low range is `-Range` and the high range is `Range`.
    /// - Returns: The value with a random value in the range added to it.
    func SlightlyRandomize(_ Value: Double, Range: Double) -> Double
    {
        let Offset = Double.random(in: -Range ... Range)
        return Value + Offset
    }
    
    /// Visually cleans the bucket by removing all retired blocks/pieces.
    /// - Note:
    ///   - Should be called only after the game ends.
    ///   - The list of blocks in **Blocks** is *not* modified.
    ///   - Control is not returned until all blocks' actions have been completed.
    ///   - `.Fast` and `.None` have the save effect.
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
        //print("Cleaning bucket with Method: \(VisualMethod)")
        switch VisualMethod
        {
            case .Fast:
                //Fast is just a synonym for .None - it just removes all blocks and returns.
                fallthrough
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
                //Drop blocks out the bottom of the bucket.
                for Block in self.BlockList
                {
                    Block.removeAllActions()
                    let FallTo = SCNAction.move(to: SCNVector3(Block.X, -20.0, Block.Z), duration: Double.random(in: 0.15 ... MaxDuration))
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([FallTo, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .FlyUpwards:
                //Blocks fly out the top of the bucket.
                for Block in self.BlockList
                {
                    Block.removeAllActions()
                    let FallTo = SCNAction.move(to: SCNVector3(Block.X, 30.0, Block.Z), duration: Double.random(in: 0.15 ... MaxDuration))
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([FallTo, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .Explode:
                break
            
            case .ExplodingBlocks:
                break
            
            case .FadeAway:
                //Blocks fade away.
                for Block in self.BlockList
                {
                    Block.removeAllActions()
                    let FadeOut = SCNAction.fadeOut(duration: Double.random(in: 0.15 ... MaxDuration))
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([FadeOut, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .Shrink:
                //Blocks shrink to invisibility.
                for Block in self.BlockList
                {
                    Block.removeAllActions()
                    let Scale = SCNAction.scale(to: 0.0, duration: Double.random(in: 0.15 ... MaxDuration))
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([Scale, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .Grow:
                ///Blocks grow to large sizes.
                for Block in self.BlockList
                {
                    Block.removeAllActions()
                    let AnimationDuration = Double.random(in: 0.25 ... MaxDuration)
                    let Scale = SCNAction.scale(to: CGFloat.random(in: 8.0 ... 12.0), duration: AnimationDuration)
                    let FadeOut = SCNAction.fadeOut(duration: AnimationDuration)
                    let Group = SCNAction.group([Scale, FadeOut])
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([Group, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .SpinAway:
                //Blocks spin and fly away radially.
                for Block in self.BlockList
                {
                    let TargetVector = RadialVector(From: SCNVector3(Block.X, Block.Y, Block.Z), TargetDistance: 40.0)
                    let AnimationDuration = Double.random(in: 0.15 ... MaxDuration)
                    let SpinAction = SCNAction.rotateBy(x: 1.0, y: 1.0, z: 1.0, duration: AnimationDuration)
                    let MoveTo = SCNAction.move(to: TargetVector, duration: AnimationDuration)
                    let ActionGroup = SCNAction.group([SpinAction, MoveTo])
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([ActionGroup, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .SpinDown:
                //Blocks spin and shink to invisibility.
                for Block in self.BlockList
                {
                    let AnimationDuration = Double.random(in: 0.15 ... MaxDuration)
                    let SpinAction = SCNAction.rotateBy(x: 1.0, y: 1.0, z: 1.0, duration: AnimationDuration)
                    let ShrinkAction = SCNAction.scale(to: 0.01, duration: AnimationDuration)
                    let ActionGroup = SCNAction.group([SpinAction, ShrinkAction])
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([ActionGroup, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .Scatter:
                //Blocks scatter in random directions.
                for Block in self.BlockList
                {
                    let ZValue = CGFloat.random(in: -2.0 ... 2.0)
                    let TargetVector = RandomVector(ToRange: 40.0, UseZ: Float(ZValue), DoNotRandomizeZ: true)
                    let AnimationDuration = Double.random(in: 0.15 ... MaxDuration)
                    let MoveTo = SCNAction.move(to: TargetVector, duration: AnimationDuration)
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([MoveTo, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .ScatterSpin:
                //Blocks scatter in random directions, while spinning in random directions as well.
                for Block in self.BlockList
                {
                    let ZValue = CGFloat.random(in: -2.0 ... 2.0)
                    let TargetVector = RandomVector(ToRange: 40.0, UseZ: Float(ZValue), DoNotRandomizeZ: true)
                    let AnimationDuration = Double.random(in: 0.15 ... MaxDuration)
                    let SpinX = SCNAction.rotateBy(x: 1.0, y: 0.0, z: 0.0, duration: SlightlyRandomize(AnimationDuration - 0.1, Range: 0.1))
                    let SpinY = SCNAction.rotateBy(x: 0.0, y: 1.0, z: 0.0, duration: SlightlyRandomize(AnimationDuration - 0.1, Range: 0.1))
                    let SpinZ = SCNAction.rotateBy(x: 0.0, y: 0.0, z: 1.0, duration: SlightlyRandomize(AnimationDuration - 0.1, Range: 0.1))
                    let MoveTo = SCNAction.move(to: TargetVector, duration: AnimationDuration)
                    let MotionGroup = SCNAction.group([SpinX, SpinY, SpinZ, MoveTo])
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([MotionGroup, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .ScatterRadially:
                //Blocks fly away radially.
                for Block in self.BlockList
                {
                    let TargetVector = RadialVector(From: SCNVector3(Block.X, Block.Y, Block.Z), TargetDistance: 40.0)
                    let AnimationDuration = Double.random(in: 0.15 ... MaxDuration)
                    let MoveTo = SCNAction.move(to: TargetVector, duration: AnimationDuration)
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([MoveTo, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .ScatterHorizontally:
                ///Blocks scatter randomly, right or left
                for Block in self.BlockList
                {
                    let Direction = [-1.0, 1.0].randomElement()!
                    let TargetVector = SCNVector3(CGFloat(40.0 * Direction), Block.Y, Block.Z)
                    let AnimationDuration = Double.random(in: 0.15 ... MaxDuration)
                    let MoveTo = SCNAction.move(to: TargetVector, duration: AnimationDuration)
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([MoveTo, KillBlock])
                    Block.runAction(Sequence)
            }
            
            case .ScatterVertically:
                ///Blocks scatter randomly, up or down.
                for Block in self.BlockList
                {
                    let Direction = [-1.0, 1.0].randomElement()!
                    let TargetVector = SCNVector3(Block.X, CGFloat(40.0 * Direction), Block.Z)
                    let AnimationDuration = Double.random(in: 0.15 ... MaxDuration)
                    let MoveTo = SCNAction.move(to: TargetVector, duration: AnimationDuration)
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([MoveTo, KillBlock])
                    Block.runAction(Sequence)
                }
            
            case .ScatterDirectionally:
                //Blocks fly away towards a compass direction.
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
                    let AnimationDuration = Double.random(in: 0.15 ... MaxDuration)
                    let MoveTo = SCNAction.move(to: TargetVector, duration: AnimationDuration)
                    let KillBlock = SCNAction.removeFromParentNode()
                    let Sequence = SCNAction.sequence([MoveTo, KillBlock])
                    Block.runAction(Sequence)
            }
        }
    }
}

/// Used to specify how to empty the bucket after game over.
/// - **None**: Do nothing - just clear the board.
/// - **Fast**: Same as **.None** but provided for semantic purposes.
/// - **Scatter**: Scatter the blocks in random directions.
/// - **ScatterSpin**: Same as `.Scatter` but pieces spin randomly.
/// - **Explode**: Blocks fly away radially from the center.
/// - **FadeAway**: Blocks fade out.
/// - **ExplodingBlocks**: Blocks explode.
/// - **Drop**: Blocks drop out the bottom.
/// - **FlyUpwards**: Blocks fly upwards out the top.
/// - **ScatterHorizontally**: Blocks randomly fly left or right.
/// - **ScatterVertically**: Blocks randomly fly up or down.
/// - **ScatterDirectionally**: Blocks fly towards the closest edge.
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
    case Fast = "Fast"
    case Scatter = "Scatter"
    case ScatterSpin = "ScatterSpin"
    case Explode = "Explode"
    case FadeAway = "FadeAway"
    case ExplodingBlocks = "ExplodingBlocks"
    case Drop = "Drop"
    case FlyUpwards = "FlyUpwards"
    case ScatterHorizontally = "ScatterHorizontally"
    case ScatterVertically = "ScatterVertically"
    case ScatterDirectionally = "ScatterDirectionally"
    case ScatterRadially = "ScatterRadially"
    case SpinDown = "SpinDown"
    case SpinAway = "SpinAway"
    case Shrink = "Shrink"
    case Grow = "Grow"
    case Random = "Random"
}
