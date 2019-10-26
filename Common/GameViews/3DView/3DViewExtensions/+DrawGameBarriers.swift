//
//  +DrawGameBarriers.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import SceneKit

/// Holds functions related to the creation of buckets.
extension View3D
{
    /// Draw the bucket/barrier pieces based on the contents of the current game's board.
    /// - Parameter Parent: The parent bucket node.
    /// - Parameter InShape: Determines the shape of the bucket.
    /// - Parameter InitialOpacity: Determines the opacity of the center block.
    public func DrawGameBarriers(Parent: SCNNode, InShape: BucketShapes, InitialOpacity: CGFloat = 1.0)
    {
        let DiffuseColor = ColorServer.ColorFrom(CurrentTheme!.BucketDiffuseColor)
        let SpecularColor = ColorServer.ColorFrom(CurrentTheme!.BucketSpecularColor)
        let BNode = SCNNode()
        let BoardDef = BoardManager.GetBoardFor(InShape)
        if BoardDef == nil
        {
            print("Did not find board for \(InShape)")
            return
        }
        var YOffset: CGFloat = 0.0
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            YOffset = 3
        }
        let Locations = BoardDef?.BucketBlockList()
        let GWidth = BoardDef?.GameBoardWidth
        let GWidth2 = (CGFloat(GWidth!) / 2.0) - 0.5
        let GHeight = BoardDef?.GameBoardHeight
        let GHeight2 = (CGFloat(GHeight!) / 2.0) - 0.5
        for Location in Locations!
        {
            let Box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
            Box.materials.first?.diffuse.contents = DiffuseColor
            Box.materials.first?.specular.contents = SpecularColor
            let BoxNode = SCNNode(geometry: Box)
            BoxNode.categoryBitMask = View3D.GameLight
            let FinalX = Location.x - GWidth2
            //Negate the vertical component because the map has lower vertical values on top and the game view
            //(SceneKit) has lower vertical values on the bottom.
            let FinalY = -(Location.y - GHeight2)
            BoxNode.position = SCNVector3(FinalX, FinalY + YOffset, 0.0)
            BNode.addChildNode(BoxNode)
        }
        BNode.position = SCNVector3(0.0, 0.0, 0.0)
        BNode.opacity = InitialOpacity
        BNode.categoryBitMask = View3D.GameLight
        Parent.addChildNode(BNode)
    }
}
