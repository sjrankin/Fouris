//
//  +Renderer.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/13/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Extensions to **View3D** related to debugging and performance measurement as well as node management.
extension View3D
{
    // MARK: - SCNSceneRendererDelegate functions.
    
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
    
    /// Called after animations are applied.
    func renderer(_ renderer: SCNSceneRenderer, didApplyAnimationsAtTime time: TimeInterval)
    {
    }
    
    /// Called after the scene is rendered.
    /// - Note: Nodes that need to be deleted are deleted here.
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval)
    {
//        print("renderer:didRenderScene started.")
        let StartTime = CACurrentMediaTime()
        if NodeRemovalList.count > 0
        {
            print("  Removing named nodes [\(NodeRemovalList.count)].")
            var KillList = [SCNNode]()
            for NodeName in NodeRemovalList
            {
                self.scene?.rootNode.enumerateChildNodes
                    {
                        (Node, _) in
                        if Node.name == NodeName
                        {
                            KillList.append(Node)
                        }
                }
            }
            for Node in KillList
            {
                Node.removeAllActions()
                Node.removeFromParentNode()
            }
            for NodeName in NodeRemovalList
            {
                BlockList = BlockList.filter({$0.name != NodeName})
            }
            print("    Done removing named nodes.")
        }
        if ObjectRemovalList.count > 0
        {
            print("  Removing GameViewObjects [\(ObjectRemovalList.count)]")
            for SomeObject in ObjectRemovalList
            {
                switch SomeObject
                {
                    case .Bucket:
                        BucketNode?.removeFromParentNode()
                        BucketNode = nil
                    
                    case .BucketGrid:
                        BucketGridNode?.removeFromParentNode()
                        BucketGridNode = nil
                    
                    case .BucketGridOutline:
                        OutlineNode?.removeFromParentNode()
                        OutlineNode = nil
                }
            }
            print("    Done removing GameViewObjects")
        }
//        let Duration = CACurrentMediaTime() - StartTime
//        print("  renderer:didRenderScene ended. Duration: \(Duration)")
    }
    
    // MARK: - Other functions.
    
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
