//
//  +ShowRegions.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/23/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension View3D
{
    /// Show or hide regions. This is intended for debug use only.
    /// - Parameter Show: Determines whether the debug regions are shown (`true`) or hidden (`false`).
    func ShowRegions(Show: Bool)
    {
        for (_, Node) in RegionLayers
        {
            Node.removeFromParentNode()
        }
        RegionLayers.removeAll()
        let BoardDef = BoardManager.GetBoardFor(CenterBlockShape)!
        if Show
        {
            RegionLayers[.Barrier] = SCNNode()
            RegionLayers[.BucketInterior] = SCNNode()
            RegionLayers[.Exterior] = SCNNode()
            RegionLayers[.InvisibleBarrier] = SCNNode()
            print("GameBoard: \(BoardDef.GameBoardWidth)x\(BoardDef.GameBoardHeight)")
            print("Bucket: \(BoardDef.BucketWidth)x\(BoardDef.BucketHeight)")
            for Y in 0 ..< BoardDef.GameBoardHeight
            {
                for X in 0 ..< BoardDef.GameBoardWidth
                {
                    let NodeType = BoardDef.MapDataAt(X: X, Y: Y)
                    let Node = SCNNode(geometry: SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0))
                    Node.position = SCNVector3(CGFloat(X) - 6.5, CGFloat(-Y) + 16, 0.0)
                    Node.categoryBitMask = View3D.ControlLight
                    Node.geometry?.firstMaterial?.specular.contents = UIColor.white
                    switch NodeType
                    {
                        case .BucketBlock:
                            Node.geometry?.firstMaterial?.diffuse.contents = LayerColors[.Barrier]?.withAlphaComponent(0.25)
                            RegionLayers[.Barrier]?.addChildNode(Node)
                        
                        case .BucketExterior:
                            Node.geometry?.firstMaterial?.diffuse.contents = LayerColors[.Exterior]?.withAlphaComponent(0.25)
                            RegionLayers[.Exterior]?.addChildNode(Node)
                        
                        case .BucketInterior:
                            Node.geometry?.firstMaterial?.diffuse.contents = LayerColors[.BucketInterior]?.withAlphaComponent(0.25)
                            RegionLayers[.BucketInterior]?.addChildNode(Node)
                        
                        case .InvisibleBlock:
                            Node.geometry?.firstMaterial?.diffuse.contents = LayerColors[.InvisibleBarrier]?.withAlphaComponent(0.25)
                            RegionLayers[.InvisibleBarrier]?.addChildNode(Node)
                    }
                }
            }
            for (_, Layer) in RegionLayers
            {
                self.scene?.rootNode.addChildNode(Layer)
            }
        }
    }
}

/// Debug regions for the purposes of showing where things are in the view.
/// - **BucketInterior**: Interior of the bucket.
/// - **Barrier**: Bucket blocks.
/// - **InvisibleBarrier**: Bucket blocks that are invisible.
/// - **Exterior**: Game board that does not fall into any of the above categories.
enum DebugRegions: String, CaseIterable
{
    case BucketInterior = "BucketInterior"
    case Barrier = "Barrier"
    case InvisibleBarrier = "InvisibleBarrier"
    case Exterior = "Exterior"
}
