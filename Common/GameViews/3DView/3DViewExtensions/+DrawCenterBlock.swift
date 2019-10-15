//
//  +DrawCenterBlock.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics
import SceneKit

/// Holds functions related to central blocks for **.Rotating4** games.
extension View3D
{
    /// Draw the center block for **.Rotating4** games.
    /// - Parameter Parent: The parent bucket node.
    /// - Parameter InShape: Determines the shape of the bucket.
    /// - Parameter InitialOpacity: Determines the opacity of the center block.
    func DrawCenterBlock(Parent: SCNNode, InShape: CenterShapes, InitialOpacity: CGFloat = 1.0)
    {
        let DiffuseColor = ColorServer.ColorFrom(CurrentTheme!.BucketDiffuseColor)
        let SpecularColor = ColorServer.ColorFrom(CurrentTheme!.BucketSpecularColor)
        switch InShape
        {
            case .Dot:
                let Center = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.5, 0.5, 0.0)
                CentralNode.categoryBitMask = GameLight
                CentralNode.opacity = InitialOpacity
                Parent.addChildNode(CentralNode)
            
            case .SmallSquare:
                let Center = SCNBox(width: 2.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.0, 0.0)
                CentralNode.categoryBitMask = GameLight
                CentralNode.opacity = InitialOpacity
                Parent.addChildNode(CentralNode)
            
            case .Square:
                let Center = SCNBox(width: 4.0, height: 4.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.0, 0.0)
                CentralNode.categoryBitMask = GameLight
                CentralNode.opacity = InitialOpacity
                Parent.addChildNode(CentralNode)
            
            case .BigSquare:
                let Center = SCNBox(width: 6.0, height: 6.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.0, 0.0)
                CentralNode.categoryBitMask = GameLight
                CentralNode.opacity = InitialOpacity
                Parent.addChildNode(CentralNode)
            
            case .SmallRectangle:
                let Center = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.5, 0.0)
                CentralNode.categoryBitMask = GameLight
                CentralNode.opacity = InitialOpacity
                Parent.addChildNode(CentralNode)
            
            case .Rectangle:
                let Center = SCNBox(width: 4.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.0, 0.0)
                CentralNode.categoryBitMask = GameLight
                CentralNode.opacity = InitialOpacity
                Parent.addChildNode(CentralNode)
            
            case .BigRectangle:
                let Center = SCNBox(width: 8.0, height: 3.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.5, 0.0)
                CentralNode.categoryBitMask = GameLight
                CentralNode.opacity = InitialOpacity
                Parent.addChildNode(CentralNode)
            
            case .SmallDiamond:
                let Group = SCNNode()
                
                let R1 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R1.materials.first?.diffuse.contents = DiffuseColor
                R1.materials.first?.specular.contents = SpecularColor
                let R1Node = SCNNode(geometry: R1)
                R1Node.position = SCNVector3(-0.5, 1.5, 0.0)
                R1Node.categoryBitMask = GameLight
                Group.addChildNode(R1Node)
                
                let R2 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R2.materials.first?.diffuse.contents = DiffuseColor
                R2.materials.first?.specular.contents = SpecularColor
                let R2Node = SCNNode(geometry: R2)
                R2Node.position = SCNVector3(-0.5, 0.5, 0.0)
                R2Node.categoryBitMask = GameLight
                Group.addChildNode(R2Node)
                
                let R3 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R3.materials.first?.diffuse.contents = DiffuseColor
                R3.materials.first?.specular.contents = SpecularColor
                let R3Node = SCNNode(geometry: R3)
                R3Node.position = SCNVector3(-0.5, -0.5, 0.0)
                R2Node.categoryBitMask = GameLight
                Group.opacity = InitialOpacity
                Group.addChildNode(R3Node)
                Parent.addChildNode(Group)
            
            case .Diamond:
                let Group = SCNNode()
                
                let R1 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R1.materials.first?.diffuse.contents = DiffuseColor
                R1.materials.first?.specular.contents = SpecularColor
                let R1Node = SCNNode(geometry: R1)
                R1Node.position = SCNVector3(0.5, 2.5, 0.0)
                R1Node.categoryBitMask = GameLight
                Group.addChildNode(R1Node)
                
                let R2 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R2.materials.first?.diffuse.contents = DiffuseColor
                R2.materials.first?.specular.contents = SpecularColor
                let R2Node = SCNNode(geometry: R2)
                R2Node.position = SCNVector3(0.5, 1.5, 0.0)
                R2Node.categoryBitMask = GameLight
                Group.addChildNode(R2Node)
                
                let R3 = SCNBox(width: 5.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R3.materials.first?.diffuse.contents = DiffuseColor
                R3.materials.first?.specular.contents = SpecularColor
                let R3Node = SCNNode(geometry: R3)
                R3Node.position = SCNVector3(0.5, 0.5, 0.0)
                R3Node.categoryBitMask = GameLight
                Group.addChildNode(R3Node)
                
                let R4 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R4.materials.first?.diffuse.contents = DiffuseColor
                R4.materials.first?.specular.contents = SpecularColor
                let R4Node = SCNNode(geometry: R4)
                R4Node.position = SCNVector3(0.5, -0.5, 0.0)
                R4Node.categoryBitMask = GameLight
                Group.addChildNode(R4Node)
                
                let R5 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R5.materials.first?.diffuse.contents = DiffuseColor
                R5.materials.first?.specular.contents = SpecularColor
                let R5Node = SCNNode(geometry: R5)
                R5Node.position = SCNVector3(0.5, -1.5, 0.0)
                R5Node.categoryBitMask = GameLight
                Group.opacity = InitialOpacity
                Group.addChildNode(R5Node)
                Parent.addChildNode(Group)
            
            case .BigDiamond:
                let Group = SCNNode()
                
                let R1 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R1.materials.first?.diffuse.contents = DiffuseColor
                R1.materials.first?.specular.contents = SpecularColor
                let R1Node = SCNNode(geometry: R1)
                R1Node.position = SCNVector3(0.5, 3.5, 0.0)
                R1Node.categoryBitMask = GameLight
                Group.addChildNode(R1Node)
                
                let R2 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R2.materials.first?.diffuse.contents = DiffuseColor
                R2.materials.first?.specular.contents = SpecularColor
                let R2Node = SCNNode(geometry: R2)
                R2Node.position = SCNVector3(0.5, 2.5, 0.0)
                R2Node.categoryBitMask = GameLight
                Group.addChildNode(R2Node)
                
                let R3 = SCNBox(width: 5.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R3.materials.first?.diffuse.contents = DiffuseColor
                R3.materials.first?.specular.contents = SpecularColor
                let R3Node = SCNNode(geometry: R3)
                R3Node.position = SCNVector3(0.5, 1.5, 0.0)
                R3Node.categoryBitMask = GameLight
                Group.addChildNode(R3Node)
                
                let R4 = SCNBox(width: 7.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R4.materials.first?.diffuse.contents = DiffuseColor
                R4.materials.first?.specular.contents = SpecularColor
                let R4Node = SCNNode(geometry: R4)
                R4Node.position = SCNVector3(0.5, 0.5, 0.0)
                R4Node.categoryBitMask = GameLight
                Group.addChildNode(R4Node)
                
                let R5 = SCNBox(width: 5.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R5.materials.first?.diffuse.contents = DiffuseColor
                R5.materials.first?.specular.contents = SpecularColor
                let R5Node = SCNNode(geometry: R5)
                R5Node.position = SCNVector3(0.5, -0.5, 0.0)
                R5Node.categoryBitMask = GameLight
                Group.addChildNode(R5Node)
                
                let R6 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R6.materials.first?.diffuse.contents = DiffuseColor
                R6.materials.first?.specular.contents = SpecularColor
                let R6Node = SCNNode(geometry: R6)
                R6Node.position = SCNVector3(0.5, -1.5, 0.0)
                R6Node.categoryBitMask = GameLight
                Group.addChildNode(R6Node)
                
                let R7 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R7.materials.first?.diffuse.contents = DiffuseColor
                R7.materials.first?.specular.contents = SpecularColor
                let R7Node = SCNNode(geometry: R7)
                R7Node.position = SCNVector3(0.5, -2.5, 0.0)
                R7Node.categoryBitMask = GameLight
                Group.opacity = InitialOpacity
                Group.addChildNode(R7Node)
                Parent.addChildNode(Group)
            
            case .Bracket2:
                let Group = SCNNode()
                
                let LeftVertical = SCNBox(width: 1.0, height: 6.0, length: 1.0, chamferRadius: 0.0)
                LeftVertical.materials.first?.diffuse.contents = DiffuseColor
                LeftVertical.materials.first?.specular.contents = SpecularColor
                let LeftVerticalNode = SCNNode(geometry: LeftVertical)
                LeftVerticalNode.position = SCNVector3(-4.5, 0, 0.0)
                LeftVerticalNode.categoryBitMask = GameLight
                Group.addChildNode(LeftVerticalNode)
                
                let UpperLeftVertical = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                UpperLeftVertical.materials.first?.diffuse.contents = DiffuseColor
                UpperLeftVertical.materials.first?.specular.contents = SpecularColor
                let UpperLeftVerticalNode = SCNNode(geometry: UpperLeftVertical)
                UpperLeftVerticalNode.position = SCNVector3(-3.0, 2.5, 0.0)
                UpperLeftVerticalNode.categoryBitMask = GameLight
                Group.addChildNode(UpperLeftVerticalNode)
                
                let LowerLeftVertical = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                LowerLeftVertical.materials.first?.diffuse.contents = DiffuseColor
                LowerLeftVertical.materials.first?.specular.contents = SpecularColor
                let LowerLeftVerticalNode = SCNNode(geometry: LowerLeftVertical)
                LowerLeftVerticalNode.position = SCNVector3(-3.0, -2.5, 0.0)
                LowerLeftVerticalNode.categoryBitMask = GameLight
                Group.addChildNode(LowerLeftVerticalNode)
                
                let RightVertical = SCNBox(width: 1.0, height: 6.0, length: 1.0, chamferRadius: 0.0)
                RightVertical.materials.first?.diffuse.contents = DiffuseColor
                RightVertical.materials.first?.specular.contents = SpecularColor
                let RightVerticalNode = SCNNode(geometry: RightVertical)
                RightVerticalNode.position = SCNVector3(4.5, 0, 0.0)
                RightVerticalNode.categoryBitMask = GameLight
                Group.addChildNode(RightVerticalNode)
                
                let UpperRightVertical = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                UpperRightVertical.materials.first?.diffuse.contents = DiffuseColor
                UpperRightVertical.materials.first?.specular.contents = SpecularColor
                let UpperRightVerticalNode = SCNNode(geometry: UpperRightVertical)
                UpperRightVerticalNode.position = SCNVector3(3.0, 2.5, 0.0)
                UpperRightVerticalNode.categoryBitMask = GameLight
                Group.addChildNode(UpperRightVerticalNode)
                
                let LowerRightVertical = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                LowerRightVertical.materials.first?.diffuse.contents = DiffuseColor
                LowerRightVertical.materials.first?.specular.contents = SpecularColor
                let LowerRightVerticalNode = SCNNode(geometry: LowerRightVertical)
                LowerRightVerticalNode.position = SCNVector3(3.0, -2.5, 0.0)
                LowerRightVerticalNode.categoryBitMask = GameLight
                Group.opacity = InitialOpacity
                Group.addChildNode(LowerRightVerticalNode)
                Parent.addChildNode(Group)
            
            case .Bracket4:
                let Group = SCNNode()
                
                let ULA = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                ULA.materials.first?.diffuse.contents = DiffuseColor
                ULA.materials.first?.specular.contents = SpecularColor
                let ULANode = SCNNode(geometry: ULA)
                ULANode.position = SCNVector3(-3.0, 4.5, 0.0)
                ULANode.categoryBitMask = GameLight
                Group.addChildNode(ULANode)
                
                let ULB = SCNBox(width: 1.0, height: 3.0, length: 1.0, chamferRadius: 0.0)
                ULB.materials.first?.diffuse.contents = DiffuseColor
                ULB.materials.first?.specular.contents = SpecularColor
                let ULBNode = SCNNode(geometry: ULB)
                ULBNode.position = SCNVector3(-4.5, 3.5, 0.0)
                ULBNode.categoryBitMask = GameLight
                Group.addChildNode(ULBNode)
                
                let LLA = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                LLA.materials.first?.diffuse.contents = DiffuseColor
                LLA.materials.first?.specular.contents = SpecularColor
                let LLANode = SCNNode(geometry: LLA)
                LLANode.position = SCNVector3(-3.0, -4.5, 0.0)
                LLANode.categoryBitMask = GameLight
                Group.addChildNode(LLANode)
                
                let LLB = SCNBox(width: 1.0, height: 3.0, length: 1.0, chamferRadius: 0.0)
                LLB.materials.first?.diffuse.contents = DiffuseColor
                LLB.materials.first?.specular.contents = SpecularColor
                let LLBNode = SCNNode(geometry: LLB)
                LLBNode.position = SCNVector3(-4.5, -3.5, 0.0)
                LLBNode.categoryBitMask = GameLight
                Group.addChildNode(LLBNode)
                
                let URA = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                URA.materials.first?.diffuse.contents = DiffuseColor
                URA.materials.first?.specular.contents = SpecularColor
                let URANode = SCNNode(geometry: URA)
                URANode.position = SCNVector3(3.0, 4.5, 0.0)
                URANode.categoryBitMask = GameLight
                Group.addChildNode(URANode)
                
                let URB = SCNBox(width: 1.0, height: 3.0, length: 1.0, chamferRadius: 0.0)
                URB.materials.first?.diffuse.contents = DiffuseColor
                URB.materials.first?.specular.contents = SpecularColor
                let URBNode = SCNNode(geometry: URB)
                URBNode.position = SCNVector3(4.5, 3.5, 0.0)
                URBNode.categoryBitMask = GameLight
                Group.addChildNode(URBNode)
                
                let LRA = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                LRA.materials.first?.diffuse.contents = DiffuseColor
                LRA.materials.first?.specular.contents = SpecularColor
                let LRANode = SCNNode(geometry: LRA)
                LRANode.position = SCNVector3(3.0, -4.5, 0.0)
                LRANode.categoryBitMask = GameLight
                Group.addChildNode(LRANode)
                
                let LRB = SCNBox(width: 1.0, height: 3.0, length: 1.0, chamferRadius: 0.0)
                LRB.materials.first?.diffuse.contents = DiffuseColor
                LRB.materials.first?.specular.contents = SpecularColor
                let LRBNode = SCNNode(geometry: LRB)
                LRBNode.position = SCNVector3(4.5, -3.5, 0.0)
                LRBNode.categoryBitMask = GameLight
                Group.addChildNode(LRBNode)
                Group.opacity = InitialOpacity
                Parent.addChildNode(Group)
            
            case .FourLines:
                let Group = SCNNode()
                
                let Line1 = SCNBox(width: 6.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                Line1.materials.first?.diffuse.contents = DiffuseColor
                Line1.materials.first?.specular.contents = SpecularColor
                let Line1Node = SCNNode(geometry: Line1)
                Line1Node.position = SCNVector3(0.0, 9.5, 0.0)
                Line1Node.categoryBitMask = GameLight
                Group.addChildNode(Line1Node)
                
                let Line2 = SCNBox(width: 6.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                Line2.materials.first?.diffuse.contents = DiffuseColor
                Line2.materials.first?.specular.contents = SpecularColor
                let Line2Node = SCNNode(geometry: Line2)
                Line2Node.position = SCNVector3(0.0, -9.5, 0.0)
                Line2Node.categoryBitMask = GameLight
                Group.addChildNode(Line2Node)
                
                let Line3 = SCNBox(width: 1.0, height: 6.0, length: 1.0, chamferRadius: 0.0)
                Line3.materials.first?.diffuse.contents = DiffuseColor
                Line3.materials.first?.specular.contents = SpecularColor
                let Line3Node = SCNNode(geometry: Line3)
                Line3Node.position = SCNVector3(-9.5, 0.0, 0.0)
                Line3Node.categoryBitMask = GameLight
                Group.addChildNode(Line3Node)
                
                let Line4 = SCNBox(width: 1.0, height: 6.0, length: 1.0, chamferRadius: 0.0)
                Line4.materials.first?.diffuse.contents = DiffuseColor
                Line4.materials.first?.specular.contents = SpecularColor
                let Line4Node = SCNNode(geometry: Line4)
                Line4Node.position = SCNVector3(9.5, 0.0, 0.0)
                Line4Node.categoryBitMask = GameLight
                Group.addChildNode(Line4Node)
                
                Group.opacity = InitialOpacity
                Parent.addChildNode(Group)
            
            case .Corners:
                let Group = SCNNode()
                
                let UL0 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                UL0.materials.first?.diffuse.contents = DiffuseColor
                UL0.materials.first?.specular.contents = SpecularColor
                let UL0Node = SCNNode(geometry: UL0)
                UL0Node.position = SCNVector3(-8.5, 9.5, 0.0)
                UL0Node.categoryBitMask = GameLight
                Group.addChildNode(UL0Node)
                let UL1 = SCNBox(width: 1.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
                UL1.materials.first?.diffuse.contents = DiffuseColor
                UL1.materials.first?.specular.contents = SpecularColor
                let UL1Node = SCNNode(geometry: UL1)
                UL1Node.position = SCNVector3(-9.5, 8.0, 0.0)
                UL1Node.categoryBitMask = GameLight
                Group.addChildNode(UL1Node)
                
                let UR0 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                UR0.materials.first?.diffuse.contents = DiffuseColor
                UR0.materials.first?.specular.contents = SpecularColor
                let UR0Node = SCNNode(geometry: UR0)
                UR0Node.position = SCNVector3(8.5, 9.5, 0.0)
                UR0Node.categoryBitMask = GameLight
                Group.addChildNode(UR0Node)
                let UR1 = SCNBox(width: 1.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
                UR1.materials.first?.diffuse.contents = DiffuseColor
                UR1.materials.first?.specular.contents = SpecularColor
                let UR1Node = SCNNode(geometry: UR1)
                UR1Node.position = SCNVector3(9.5, 8.0, 0.0)
                UR1Node.categoryBitMask = GameLight
                Group.addChildNode(UR1Node)
                
                let LL0 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                LL0.materials.first?.diffuse.contents = DiffuseColor
                LL0.materials.first?.specular.contents = SpecularColor
                let LL0Node = SCNNode(geometry: LL0)
                LL0Node.position = SCNVector3(-8.5, -9.5, 0.0)
                LL0Node.categoryBitMask = GameLight
                Group.addChildNode(LL0Node)
                let LL1 = SCNBox(width: 1.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
                LL1.materials.first?.diffuse.contents = DiffuseColor
                LL1.materials.first?.specular.contents = SpecularColor
                let LL1Node = SCNNode(geometry: LL1)
                LL1Node.position = SCNVector3(-9.5, -8.0, 0.0)
                LL1Node.categoryBitMask = GameLight
                Group.addChildNode(LL1Node)
                
                let LR0 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                LR0.materials.first?.diffuse.contents = DiffuseColor
                LR0.materials.first?.specular.contents = SpecularColor
                let LR0Node = SCNNode(geometry: LR0)
                LR0Node.position = SCNVector3(8.5, -9.5, 0.0)
                LR0Node.categoryBitMask = GameLight
                Group.addChildNode(LR0Node)
                let LR1 = SCNBox(width: 1.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
                LR1.materials.first?.diffuse.contents = DiffuseColor
                LR1.materials.first?.specular.contents = SpecularColor
                let LR1Node = SCNNode(geometry: LR1)
                LR1Node.position = SCNVector3(9.5, -8.0, 0.0)
                LR1Node.categoryBitMask = GameLight
                Group.addChildNode(LR1Node)
                
                Group.opacity = InitialOpacity
                Parent.addChildNode(Group)
            
            case .Quadrant:
                let Group = SCNNode()
                
                let VLine = SCNBox(width: 1.0, height: 20.0, length: 1.0, chamferRadius: 0.0)
                VLine.materials.first?.diffuse.contents = DiffuseColor
                VLine.materials.first?.specular.contents = SpecularColor
                let VLineNode = SCNNode(geometry: VLine)
                VLineNode.position = SCNVector3(0.5, 0.0, 0.0)
                VLineNode.categoryBitMask = GameLight
                Group.addChildNode(VLineNode)
                
                let HLine = SCNBox(width: 20.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                HLine.materials.first?.diffuse.contents = DiffuseColor
                HLine.materials.first?.specular.contents = SpecularColor
                let HLineNode = SCNNode(geometry: HLine)
                HLineNode.position = SCNVector3(0.0, 0.5, 0.0)
                HLineNode.categoryBitMask = GameLight
                Group.addChildNode(HLineNode)
                
                Group.opacity = InitialOpacity
                Parent.addChildNode(Group)
            
            case .Plus:
                let Group = SCNNode()
                
                let VLine = SCNBox(width: 1.0, height: 5.0, length: 1.0, chamferRadius: 0.0)
                VLine.materials.first?.diffuse.contents = DiffuseColor
                VLine.materials.first?.specular.contents = SpecularColor
                let VLineNode = SCNNode(geometry: VLine)
                VLineNode.position = SCNVector3(0.5, 0.5, 0.0)
                VLineNode.categoryBitMask = GameLight
                Group.addChildNode(VLineNode)
                
                let HLine = SCNBox(width: 5.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                HLine.materials.first?.diffuse.contents = DiffuseColor
                HLine.materials.first?.specular.contents = SpecularColor
                let HLineNode = SCNNode(geometry: HLine)
                HLineNode.position = SCNVector3(0.5, 0.5, 0.0)
                HLineNode.categoryBitMask = GameLight
                Group.addChildNode(HLineNode)
                
                Group.opacity = InitialOpacity
                Parent.addChildNode(Group)
            
            case .HorizontalLine:
                let Group = SCNNode()
                
                let HLine = SCNBox(width: 20.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                HLine.materials.first?.diffuse.contents = DiffuseColor
                HLine.materials.first?.specular.contents = SpecularColor
                let HLineNode = SCNNode(geometry: HLine)
                HLineNode.position = SCNVector3(0.0, 0.5, 0.0)
                HLineNode.categoryBitMask = GameLight
                Group.addChildNode(HLineNode)
                
                Group.opacity = InitialOpacity
                Parent.addChildNode(Group)
            
            case .ParallelLines:
                let Group = SCNNode()
                
                let Line1 = SCNBox(width: 1.0, height: 8.0, length: 1.0, chamferRadius: 0.0)
                Line1.materials.first?.diffuse.contents = DiffuseColor
                Line1.materials.first?.specular.contents = SpecularColor
                let Line1Node = SCNNode(geometry: Line1)
                Line1Node.position = SCNVector3(-4.5, 0.0, 0.0)
                Line1Node.categoryBitMask = GameLight
                Group.addChildNode(Line1Node)
                
                let Line2 = SCNBox(width: 1.0, height: 8.0, length: 1.0, chamferRadius: 0.0)
                Line2.materials.first?.diffuse.contents = DiffuseColor
                Line2.materials.first?.specular.contents = SpecularColor
                let Line2Node = SCNNode(geometry: Line2)
                Line2Node.position = SCNVector3(4.5, 0.0, 0.0)
                Line2Node.categoryBitMask = GameLight
                Group.addChildNode(Line2Node)
                
                Group.opacity = InitialOpacity
                Parent.addChildNode(Group)
            
            case .Empty:
                //Nothing to draw...
                break
            
            case .CornerDots:
                let Group = SCNNode()
                
                let Dot1 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                Dot1.materials.first?.diffuse.contents = DiffuseColor
                Dot1.materials.first?.specular.contents = SpecularColor
                let Dot1Node = SCNNode(geometry: Dot1)
                Dot1Node.position = SCNVector3(-9.5, 9.5, 0.0)
                Dot1Node.categoryBitMask = GameLight
                Group.addChildNode(Dot1Node)
                
                let Dot2 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                Dot2.materials.first?.diffuse.contents = DiffuseColor
                Dot2.materials.first?.specular.contents = SpecularColor
                let Dot2Node = SCNNode(geometry: Dot2)
                Dot2Node.position = SCNVector3(9.5, 9.5, 0.0)
                Dot2Node.categoryBitMask = GameLight
                Group.addChildNode(Dot2Node)
                
                let Dot3 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                Dot3.materials.first?.diffuse.contents = DiffuseColor
                Dot3.materials.first?.specular.contents = SpecularColor
                let Dot3Node = SCNNode(geometry: Dot3)
                Dot3Node.position = SCNVector3(-9.5, -9.5, 0.0)
                Dot3Node.categoryBitMask = GameLight
                Group.addChildNode(Dot3Node)
                
                let Dot4 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                Dot4.materials.first?.diffuse.contents = DiffuseColor
                Dot4.materials.first?.specular.contents = SpecularColor
                let Dot4Node = SCNNode(geometry: Dot4)
                Dot4Node.position = SCNVector3(9.5, -9.5, 0.0)
                Dot4Node.categoryBitMask = GameLight
                Group.addChildNode(Dot4Node)
                
                Group.opacity = InitialOpacity
                Parent.addChildNode(Group)
            
            case .FourSmallSquares:
                let Group = SCNNode()
                
                let Sq1 = SCNBox(width: 2.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
                Sq1.materials.first?.diffuse.contents = DiffuseColor
                Sq1.materials.first?.specular.contents = SpecularColor
                let Sq1Node = SCNNode(geometry: Sq1)
                Sq1Node.position = SCNVector3(-5.0, 5.0, 0.0)
                Sq1Node.categoryBitMask = GameLight
                Group.addChildNode(Sq1Node)
                
                let Sq2 = SCNBox(width: 2.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
                Sq2.materials.first?.diffuse.contents = DiffuseColor
                Sq2.materials.first?.specular.contents = SpecularColor
                let Sq2Node = SCNNode(geometry: Sq2)
                Sq2Node.position = SCNVector3(5.0, 5.0, 0.0)
                Sq2Node.categoryBitMask = GameLight
                Group.addChildNode(Sq2Node)
                
                let Sq3 = SCNBox(width: 2.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
                Sq3.materials.first?.diffuse.contents = DiffuseColor
                Sq3.materials.first?.specular.contents = SpecularColor
                let Sq3Node = SCNNode(geometry: Sq3)
                Sq3Node.position = SCNVector3(-5.0, -5.0, 0.0)
                Sq3Node.categoryBitMask = GameLight
                Group.addChildNode(Sq3Node)
                
                let Sq4 = SCNBox(width: 2.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
                Sq4.materials.first?.diffuse.contents = DiffuseColor
                Sq4.materials.first?.specular.contents = SpecularColor
                let Sq4Node = SCNNode(geometry: Sq4)
                Sq4Node.position = SCNVector3(5.0, -5.0, 0.0)
                Sq4Node.categoryBitMask = GameLight
                Group.addChildNode(Sq4Node)
                
                Group.opacity = InitialOpacity
                Parent.addChildNode(Group)
            
            case .ShortDiagonals:
                let Group = SCNNode()
                
                let Center = SCNBox(width: 2.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CenterNode = SCNNode(geometry: Center)
                CenterNode.position = SCNVector3(0.0, 0.0, 0.0)
                CenterNode.categoryBitMask = GameLight
                Group.addChildNode(CenterNode)
                
                for Index in 0 ..< 4
                {
                    let Sq = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                    Sq.materials.first?.diffuse.contents = DiffuseColor
                    Sq.materials.first?.specular.contents = SpecularColor
                    let SqNode = SCNNode(geometry: Sq)
                    let Q = Float(Index) + 0.5
                    SqNode.position = SCNVector3(Q, Q, 0)
                    SqNode.categoryBitMask = GameLight
                    Group.addChildNode(SqNode)
                    let Q1Node = SqNode.clone()
                    Q1Node.position = SCNVector3(-Q, Q, 0)
                    Q1Node.categoryBitMask = GameLight
                    Group.addChildNode(Q1Node)
                    let Q3Node = SqNode.clone()
                    Q3Node.position = SCNVector3(Q, -Q, 0)
                    Q3Node.categoryBitMask = GameLight
                    Group.addChildNode(Q3Node)
                    let Q4Node = SqNode.clone()
                    Q4Node.position = SCNVector3(-Q, -Q, 0)
                    Q4Node.categoryBitMask = GameLight
                    Group.addChildNode(Q4Node)
                }
                
                Group.opacity = InitialOpacity
                Parent.addChildNode(Group)
            
            case .LongDiagonals:
                let Group = SCNNode()
                
                let Center = SCNBox(width: 2.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CenterNode = SCNNode(geometry: Center)
                CenterNode.position = SCNVector3(0.0, 0.0, 0.0)
                CenterNode.categoryBitMask = GameLight
                Group.addChildNode(CenterNode)
                
                for Index in 0 ..< 6
                {
                    let Sq = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                    Sq.materials.first?.diffuse.contents = DiffuseColor
                    Sq.materials.first?.specular.contents = SpecularColor
                    let SqNode = SCNNode(geometry: Sq)
                    let Q = Float(Index) + 0.5
                    SqNode.position = SCNVector3(Q, Q, 0)
                    SqNode.categoryBitMask = GameLight
                    Group.addChildNode(SqNode)
                    let Q1Node = SqNode.clone()
                    Q1Node.position = SCNVector3(-Q, Q, 0)
                    Q1Node.categoryBitMask = GameLight
                    Group.addChildNode(Q1Node)
                    let Q3Node = SqNode.clone()
                    Q3Node.position = SCNVector3(Q, -Q, 0)
                    Q3Node.categoryBitMask = GameLight
                    Group.addChildNode(Q3Node)
                    let Q4Node = SqNode.clone()
                    Q4Node.position = SCNVector3(-Q, -Q, 0)
                    Q4Node.categoryBitMask = GameLight
                    Group.addChildNode(Q4Node)
                }
                
                Group.opacity = InitialOpacity
                Parent.addChildNode(Group)
            
            case .OneOpening:
                break
            
            case .Classic:
                break
            
            case .TallThin:
                break
            
            case .ShortWide:
                break
            
            case .Big:
                break
            
            case .Small:
                break
            
            case .SquareBucket:
                break
        }
    }
}
