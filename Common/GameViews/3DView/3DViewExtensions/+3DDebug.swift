//
//  +3DDebug.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/13/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Extensions to **View3D** related to debugging and performance measurement.
extension View3D
{
    // MARK: SCNSceneRendererDelegate functions.
    
    /// Calculate the frame rate here.
    /// - Note: We do this using this method rather than getting an attribute from the scene
    ///         because the attribute reports what the *target* framerate is, not the actual
    ///         frame rate.
    /// - Parameter renderer: Not used.
    /// - Parameter time: The time interval between calls.
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        let DeltaTime = time - LastUpdateTime
        let CurrentFPS = 1 / DeltaTime
        LastUpdateTime = time
        LastFrameRate = CurrentFPS
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval)
    {
        let AnimationTime = time - LastUpdateTime
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval)
    {
        let RenderTime = time - LastUpdateTime
    }
    
    // MARK: Other functions.
    
    /// Return the number of top-level nodes in the scene's root node.
    /// - Returns: Number of nodes in the scene's `rootNode`.
    func GetNodeCount() -> Int
    {
        var Count = 0
        self.scene?.rootNode.enumerateChildNodes
            {
                _, _ in
                Count = Count + 1
        }
        return Count
    }
}
