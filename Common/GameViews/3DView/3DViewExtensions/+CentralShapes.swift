//
//  +CentralShapes.swift
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
    func DrawCenterBlock(Parent: SCNNode, InShape: CenterShapes)
    {
        let DiffuseColor = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
        let SpecularColor = ColorServer.ColorFrom(ColorNames.White)
        switch InShape
        {
            case .Dot:
                let Center = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.0, 0.0)
                Parent.addChildNode(CentralNode)
            
            case .SmallSquare:
                let Center = SCNBox(width: 2.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.0, 0.0)
                Parent.addChildNode(CentralNode)
            
            case .Square:
                let Center = SCNBox(width: 4.0, height: 4.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.0, 0.0)
                Parent.addChildNode(CentralNode)
            
            case .BigSquare:
                let Center = SCNBox(width: 6.0, height: 6.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.0, 0.0)
                Parent.addChildNode(CentralNode)
            
            case .SmallRectangle:
                let Center = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.0, 0.0)
                Parent.addChildNode(CentralNode)
            
            case .Rectangle:
                let Center = SCNBox(width: 4.0, height: 2.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.0, 0.0)
                Parent.addChildNode(CentralNode)
            
            case .BigRectangle:
                let Center = SCNBox(width: 8.0, height: 3.0, length: 1.0, chamferRadius: 0.0)
                Center.materials.first?.diffuse.contents = DiffuseColor
                Center.materials.first?.specular.contents = SpecularColor
                let CentralNode = SCNNode(geometry: Center)
                CentralNode.position = SCNVector3(0.0, 0.0, 0.0)
                Parent.addChildNode(CentralNode)
            
            case .SmallDiamond:
                let Group = SCNNode()
                Parent.addChildNode(Group)
                
                let R1 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R1.materials.first?.diffuse.contents = DiffuseColor
                R1.materials.first?.specular.contents = SpecularColor
                let R1Node = SCNNode(geometry: R1)
                R1Node.position = SCNVector3(0.0, 1.0, 0.0)
                Group.addChildNode(R1Node)
                
                let R2 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R2.materials.first?.diffuse.contents = DiffuseColor
                R2.materials.first?.specular.contents = SpecularColor
                let R2Node = SCNNode(geometry: R2)
                R2Node.position = SCNVector3(-1.0, 0.0, 0.0)
                Group.addChildNode(R2Node)
                
                let R3 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R3.materials.first?.diffuse.contents = DiffuseColor
                R3.materials.first?.specular.contents = SpecularColor
                let R3Node = SCNNode(geometry: R3)
                R3Node.position = SCNVector3(0.0, -1.0, 0.0)
                Group.addChildNode(R3Node)
            
            case .Diamond:
                let Group = SCNNode()
                Parent.addChildNode(Group)
                
                let R1 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R1.materials.first?.diffuse.contents = DiffuseColor
                R1.materials.first?.specular.contents = SpecularColor
                let R1Node = SCNNode(geometry: R1)
                R1Node.position = SCNVector3(0.0, 2.0, 0.0)
                Group.addChildNode(R1Node)
                
                let R2 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R2.materials.first?.diffuse.contents = DiffuseColor
                R2.materials.first?.specular.contents = SpecularColor
                let R2Node = SCNNode(geometry: R2)
                R2Node.position = SCNVector3(-1.0, 1.0, 0.0)
                Group.addChildNode(R2Node)
                
                let R3 = SCNBox(width: 5.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R3.materials.first?.diffuse.contents = DiffuseColor
                R3.materials.first?.specular.contents = SpecularColor
                let R3Node = SCNNode(geometry: R3)
                R3Node.position = SCNVector3(-2.0, 0.0, 0.0)
                Group.addChildNode(R3Node)
                
                let R4 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R4.materials.first?.diffuse.contents = DiffuseColor
                R4.materials.first?.specular.contents = SpecularColor
                let R4Node = SCNNode(geometry: R4)
                R4Node.position = SCNVector3(-1.0, -1.0, 0.0)
                Group.addChildNode(R4Node)
                
                let R5 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R5.materials.first?.diffuse.contents = DiffuseColor
                R5.materials.first?.specular.contents = SpecularColor
                let R5Node = SCNNode(geometry: R5)
                R5Node.position = SCNVector3(0.0, -2.0, 0.0)
                Group.addChildNode(R5Node)
            
            case .BigDiamond:
                let Group = SCNNode()
                Parent.addChildNode(Group)
            
                let R1 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R1.materials.first?.diffuse.contents = DiffuseColor
                R1.materials.first?.specular.contents = SpecularColor
                let R1Node = SCNNode(geometry: R1)
                R1Node.position = SCNVector3(0.0, 3.0, 0.0)
                Group.addChildNode(R1Node)
                
                let R2 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R2.materials.first?.diffuse.contents = DiffuseColor
                R2.materials.first?.specular.contents = SpecularColor
                let R2Node = SCNNode(geometry: R2)
                R2Node.position = SCNVector3(-1.0, 2.0, 0.0)
                Group.addChildNode(R2Node)
                
                let R3 = SCNBox(width: 5.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R3.materials.first?.diffuse.contents = DiffuseColor
                R3.materials.first?.specular.contents = SpecularColor
                let R3Node = SCNNode(geometry: R3)
                R3Node.position = SCNVector3(-2.0, 1.0, 0.0)
                Group.addChildNode(R3Node)

                let R4 = SCNBox(width: 7.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R4.materials.first?.diffuse.contents = DiffuseColor
                R4.materials.first?.specular.contents = SpecularColor
                let R4Node = SCNNode(geometry: R4)
                R4Node.position = SCNVector3(-3.0, 0.0, 0.0)
                Group.addChildNode(R4Node)
                
                let R5 = SCNBox(width: 5.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R5.materials.first?.diffuse.contents = DiffuseColor
                R5.materials.first?.specular.contents = SpecularColor
                let R5Node = SCNNode(geometry: R5)
                R5Node.position = SCNVector3(-2.0, -1.0, 0.0)
                Group.addChildNode(R5Node)
                
                let R6 = SCNBox(width: 3.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R6.materials.first?.diffuse.contents = DiffuseColor
                R6.materials.first?.specular.contents = SpecularColor
                let R6Node = SCNNode(geometry: R6)
                R6Node.position = SCNVector3(-1.0, -2.0, 0.0)
                Group.addChildNode(R6Node)
            
                let R7 = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                R7.materials.first?.diffuse.contents = DiffuseColor
                R7.materials.first?.specular.contents = SpecularColor
                let R7Node = SCNNode(geometry: R7)
                R7Node.position = SCNVector3(0.0, -3.0, 0.0)
                Group.addChildNode(R7Node)
            
            case .Bracket2:
                let Group = SCNNode()
                Parent.addChildNode(Group)
                
                let LeftVertical = SCNBox(width: 1.0, height: 6.0, length: 1.0, chamferRadius: 0.0)
                LeftVertical.materials.first?.diffuse.contents = DiffuseColor
                LeftVertical.materials.first?.specular.contents = SpecularColor
                let LeftVerticalNode = SCNNode(geometry: LeftVertical)
                LeftVerticalNode.position = SCNVector3(-3.0, 2.0, 0.0)
                Group.addChildNode(LeftVerticalNode)
                
                let UpperLeftVertical = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                UpperLeftVertical.materials.first?.diffuse.contents = DiffuseColor
                UpperLeftVertical.materials.first?.specular.contents = SpecularColor
                let UpperLeftVerticalNode = SCNNode(geometry: UpperLeftVertical)
                UpperLeftVerticalNode.position = SCNVector3(2.0, 2.0, 0.0)
                Group.addChildNode(UpperLeftVerticalNode)
                
                let LowerLeftVertical = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                LowerLeftVertical.materials.first?.diffuse.contents = DiffuseColor
                LowerLeftVertical.materials.first?.specular.contents = SpecularColor
                let LowerLeftVerticalNode = SCNNode(geometry: LowerLeftVertical)
                LowerLeftVerticalNode.position = SCNVector3(-2.0, -3.0, 0.0)
                Group.addChildNode(LowerLeftVerticalNode)
                
                let RightVertical = SCNBox(width: 1.0, height: 6.0, length: 1.0, chamferRadius: 0.0)
                RightVertical.materials.first?.diffuse.contents = DiffuseColor
                RightVertical.materials.first?.specular.contents = SpecularColor
                let RightVerticalNode = SCNNode(geometry: RightVertical)
                RightVerticalNode.position = SCNVector3(4.0, 2.0, 0.0)
                Group.addChildNode(RightVerticalNode)
                
                let UpperRightVertical = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                UpperRightVertical.materials.first?.diffuse.contents = DiffuseColor
                UpperRightVertical.materials.first?.specular.contents = SpecularColor
                let UpperRightVerticalNode = SCNNode(geometry: UpperRightVertical)
                UpperRightVerticalNode.position = SCNVector3(2.0, 1.0, 0.0)
                Group.addChildNode(UpperRightVerticalNode)
                
                let LowerRightVertical = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                LowerRightVertical.materials.first?.diffuse.contents = DiffuseColor
                LowerRightVertical.materials.first?.specular.contents = SpecularColor
                let LowerRightVerticalNode = SCNNode(geometry: LowerRightVertical)
                LowerRightVerticalNode.position = SCNVector3(2.0, -3.0, 0.0)
                Group.addChildNode(LowerRightVerticalNode)
            
            case .Bracket4:
                let Group = SCNNode()
                Parent.addChildNode(Group)
                
                let ULA = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                ULA.materials.first?.diffuse.contents = DiffuseColor
                ULA.materials.first?.specular.contents = SpecularColor
                let ULANode = SCNNode(geometry: ULA)
                ULANode.position = SCNVector3(-2.0, 3.0, 0.0)
                Group.addChildNode(ULANode)
                
                let ULB = SCNBox(width: 1.0, height: 3.0, length: 1.0, chamferRadius: 0.0)
                ULB.materials.first?.diffuse.contents = DiffuseColor
                ULB.materials.first?.specular.contents = SpecularColor
                let ULBNode = SCNNode(geometry: ULB)
                ULBNode.position = SCNVector3(-3.0, 3.0, 0.0)
                Group.addChildNode(ULBNode)
                
                let LLA = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                LLA.materials.first?.diffuse.contents = DiffuseColor
                LLA.materials.first?.specular.contents = SpecularColor
                let LLANode = SCNNode(geometry: LLA)
                LLANode.position = SCNVector3(-2.0, -4.0, 0.0)
                Group.addChildNode(LLANode)
                
                let LLB = SCNBox(width: 1.0, height: 3.0, length: 1.0, chamferRadius: 0.0)
                LLB.materials.first?.diffuse.contents = DiffuseColor
                LLB.materials.first?.specular.contents = SpecularColor
                let LLBNode = SCNNode(geometry: LLB)
                LLBNode.position = SCNVector3(-3.0, -2.0, 0.0)
                Group.addChildNode(LLBNode)
                
                let URA = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                URA.materials.first?.diffuse.contents = DiffuseColor
                URA.materials.first?.specular.contents = SpecularColor
                let URANode = SCNNode(geometry: URA)
                URANode.position = SCNVector3(2.0, 3.0, 0.0)
                Group.addChildNode(URANode)
                
                let URB = SCNBox(width: 1.0, height: 3.0, length: 1.0, chamferRadius: 0.0)
                URB.materials.first?.diffuse.contents = DiffuseColor
                URB.materials.first?.specular.contents = SpecularColor
                let URBNode = SCNNode(geometry: URB)
                URBNode.position = SCNVector3(4.0, 3.0, 0.0)
                Group.addChildNode(URBNode)
                
                let LRA = SCNBox(width: 2.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                LRA.materials.first?.diffuse.contents = DiffuseColor
                LRA.materials.first?.specular.contents = SpecularColor
                let LRANode = SCNNode(geometry: LRA)
                LRANode.position = SCNVector3(2.0, -4.0, 0.0)
                Group.addChildNode(LRANode)
                
                let LRB = SCNBox(width: 1.0, height: 3.0, length: 1.0, chamferRadius: 0.0)
                LRB.materials.first?.diffuse.contents = DiffuseColor
                LRB.materials.first?.specular.contents = SpecularColor
                let LRBNode = SCNNode(geometry: LRB)
                LRBNode.position = SCNVector3(4.0, -2.0, 0.0)
                Group.addChildNode(LRBNode)
        }
    }
}
