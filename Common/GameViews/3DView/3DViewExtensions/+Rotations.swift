//
//  +Rotations.swift
//  Fouris
//
//  Created by Stuart Rankin on 11/4/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Functions related to board rotations. Also contains showing-off functions.
extension View3D
{
    // MARK: - Board rotation functions.
    
    /// Rotates the contents of the game (but not UI or falling piece) on the specified axis. The contents are rotated to an
    /// absolute angle.
    /// - Note:
    ///   - This function uses a synchronous lock to make sure that when the board is rotating, no one else can access it.
    ///   - This function will rotate frozen pieces, bucket barriers, and bucket grids and outlines but no other objects.
    ///   - When rotating on the X or Y axis, the caller will most likely want to rotate by 180° otherwise the board will end
    ///     up edge-on to the viewer, making it difficult to see the pieces.
    /// - Parameter OnAxis: Determines the axis to rotate about. Use `.ZAxis` for a face-on rotation.
    /// - Parameter By: Number of degrees to rotate by. Specify negative values for clockwise rotations and positive values for
    ///                 counterclockwise rotations.
    /// - Parameter Duration: Duration of the rotation. Defaults to 0.33 seconds.
    public func RotateContentsTo(OnAxis: Axes, By Degrees: CGFloat, Duration: Double = 0.33)
    {
        objc_sync_enter(RotateLock)
        defer{objc_sync_exit(RotateLock)}
        let Radians = CGFloat.pi / 180.0 * Degrees
        var XRotationalValue: CGFloat = 0.0
        var YRotationalValue: CGFloat = 0.0
        var ZRotationalValue: CGFloat = 0.0
        switch OnAxis
        {
            case .XAxis:
                XRotationalValue = Radians
            
            case .YAxis:
                YRotationalValue = Radians
            
            case .ZAxis:
                ZRotationalValue = Radians
        }
        RemoveMovingPiece()
        let RotateTo = SCNAction.rotateTo(x: XRotationalValue, y: YRotationalValue, z: ZRotationalValue, duration: Duration)
        if CurrentTheme!.RotateBucketGrid
        {
            BucketGridNode?.runAction(RotateTo)
            OutlineNode?.runAction(RotateTo)
        }
        MasterBlockNode?.runAction(RotateTo)
        BucketNode?.runAction(RotateTo)
    }
    
    /// Rotates the contents of the game (but not UI or falling piece) on the specified axis. The contents are rotated by a
    /// relative angle.
    /// - Note:
    ///   - This function uses a synchronous lock to make sure that when the board is rotating, no one else can access it.
    ///   - This function will rotate frozen pieces, bucket barriers, and bucket grids and outlines but no other objects.
    ///   - When rotating on the X or Y axis, the caller will most likely want to rotate by 180° otherwise the board will end
    ///     up edge-on to the viewer, making it difficult to see the pieces.
    /// - Parameter OnAxis: Determines the axis to rotate about. Use `.ZAxis` for a face-on rotation.
    /// - Parameter By: Number of degrees to rotate by. Specify negative values for clockwise rotations and positive values for
    ///                 counterclockwise rotations.
    /// - Parameter Duration: Duration of the rotation. Defaults to 0.33 seconds.
    public func RotateContentsBy(OnAxis: Axes, By Degrees: CGFloat, Duration: Double = 0.33)
    {
        objc_sync_enter(RotateLock)
        defer{objc_sync_exit(RotateLock)}
        
        let Radians = CGFloat.pi / 180.0 * Degrees
        var XRotationalValue: CGFloat = 0.0
        var YRotationalValue: CGFloat = 0.0
        var ZRotationalValue: CGFloat = 0.0
        switch OnAxis
        {
            case .XAxis:
                XRotationalValue = Radians
            
            case .YAxis:
                YRotationalValue = Radians
            
            case .ZAxis:
                ZRotationalValue = Radians
        }
        RemoveMovingPiece()
        let RotateBy = SCNAction.rotateBy(x: XRotationalValue, y: YRotationalValue, z: ZRotationalValue, duration: Duration)
        if CurrentTheme!.RotateBucketGrid
        {
            BucketGridNode?.runAction(RotateBy)
            OutlineNode?.runAction(RotateBy)
        }
        MasterBlockNode?.runAction(RotateBy)
        BucketNode?.runAction(RotateBy)
    }
    
    /// Rotates the contents of the game (but not UI or falling piece) by the specified number of degrees.
    /// - Note:
    ///   - This function uses a synchronous lock to make sure that when the board is rotating, other things don't happen to it.
    ///   - This function uses two rotational actions because for some reason, using the same action on different SCNNodes
    ///     results in unpredictable and undesired behavior.
    /// - Parameter Right: If true, the contents are rotated clockwise. If false, counter-clockwise.
    /// - Parameter Duration: Duration in seconds the rotation should take. Defaults to 0.33 seconds.
    /// - Parameter Completed: Completion handler called at the end of the rotation.
    public func RotateContents(Right: Bool, Duration: Double = 0.33, Completed: @escaping (() -> Void))
    {
        objc_sync_enter(RotateLock)
        defer{objc_sync_exit(RotateLock)}
        
        //let BoardDef = BoardManager.GetBoardFor(CenterBlockShape!)
        
        let DirectionalSign = CGFloat(Right ? -1.0 : 1.0)
        RotationCardinalIndex = RotationCardinalIndex + 1
        if RotationCardinalIndex > 3
        {
            RotationCardinalIndex = 0
        }
        let Radian = CGFloat((RotationCardinalIndex * 90)) * CGFloat.pi / 180.0
        let ZRotationTo = DirectionalSign * Radian
        let ZRotationBy = DirectionalSign * HalfPi
        let RotateBy = SCNAction.rotateBy(x: 0.0, y: 0.0, z: ZRotationBy, duration: Duration)
        let RotateTo = SCNAction.rotateTo(x: 0.0, y: 0.0, z: ZRotationTo, duration: Duration, usesShortestUnitArc: true)
        RemoveMovingPiece()
        if CurrentTheme!.RotateBucketGrid
        {
            BucketGridNode?.runAction(RotateTo)
            OutlineNode?.runAction(RotateTo)
        }
        MasterBlockNode?.runAction(RotateBy)
        BucketNode?.runAction(RotateBy)
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
    
    /// Rotates the contents of the game (but not UI or falling piece) by 90° right (clockwise).
    /// - Parameter Duration: Duration in seconds the rotation should take.
    /// - Parameter Completed: Completion handler called at the end of the rotation.
    public func RotateContentsRight(Duration: Double = 0.33, Completed: @escaping (() -> Void))
    {
        RotateContents(Right: true, Duration: Duration, Completed: Completed)
    }
    
    /// Rotates the contents of the game (but not UI or falling piece) by 90° left (counter-clockwise).
    /// - Parameter Duration: Duration in seconds the rotation should take.
    /// - Parameter Completed: Completion handler called at the end of the rotation.
    public func RotateContentsLeft(Duration: Double = 0.33, Completed: @escaping (() -> Void))
    {
        RotateContents(Right: false, Duration: Duration, Completed: Completed)
    }
    
    // MARK: - Showing-off functions.
    
    /// Stop showing off rotations.
    /// - Parameter Duration: Number of seconds to take to rotate the board back to a neutral position.
    public func StopShowingOff(Duration: Double = 1.0)
    {
        print("StopShowingOff")
        let BoardDef = BoardManager.GetBoardFor(CenterBlockShape!)
        if !BoardDef!.BucketRotates
        {
            // Do not waste time if the bucket doesn't rotate.
            print("StopShowingOff canceled - bucket doesn't rotate.")
            return
        }
        
        //Destroy the show off timer.
        ShowOffTimer?.invalidate()
        ShowOffTimer = nil
        
        //Remove node actions.
        if CurrentTheme!.RotateBucketGrid
        {
            BucketGridNode?.removeAllActions()
            OutlineNode?.removeAllActions()
        }
        MasterBlockNode?.removeAllActions()
        BucketNode?.removeAllActions()
        
        //Move to an ordinal position.
        let Reset = SCNAction.rotateTo(x: 0.0, y: 0.0, z: 0.0, duration: Duration)
        if CurrentTheme!.RotateBucketGrid
        {
            BucketGridNode?.runAction(Reset)
            OutlineNode?.runAction(Reset)
        }
        MasterBlockNode?.runAction(Reset)
        BucketNode?.runAction(Reset)
    }
    
    /// Show off rotations. Intended for use by the game after game over to provide visual interest.
    /// - Note: Rotations are selected randomly
    /// - Parameter Duration: Time for one rotation.
    /// - Parameter Delay: Time between rotations.
    public func ShowOffRotations(Duration: Double, Delay: Double)
    {
        let BoardDef = BoardManager.GetBoardFor(CenterBlockShape!)
        if !BoardDef!.BucketRotates
        {
            // Do not waste time if the bucket doesn't rotate.
            return
        }
        //Reset rotatable objects to a known rotation to keep things in sync with each other.
        let Reset = SCNAction.rotateTo(x: 0.0, y: 0.0, z: 0.0, duration: 0.01)
        MasterBlockNode?.runAction(Reset)
        BucketNode?.runAction(Reset)
        if CurrentTheme!.RotateBucketGrid
        {
            BucketGridNode?.runAction(Reset)
            OutlineNode?.runAction(Reset)
        }
        //Run the first execution prior to setting up the timer so that things do not appear to stall.
        ExecutionRotation()
        ShowOffTimer = Timer.scheduledTimer(timeInterval: Delay, target: self, selector: #selector(ExecutionRotation),
                                            userInfo: nil, repeats: true)
    }
    
    /// Execution a rotation of the board game to show off after game over.
    @objc func ExecutionRotation()
    {
        let Axis = Axes.allCases.randomElement()!
        let Angle: CGFloat = (Axis == .ZAxis ? 90.0 : 180.0) * CGFloat([1.0, -1.0].randomElement()!)
        let RotationalDuration: Double = Axis == .ZAxis ? 0.3 : 0.6
        RotateContentsBy(OnAxis: Axis, By: Angle, Duration: RotationalDuration)
    }
}
