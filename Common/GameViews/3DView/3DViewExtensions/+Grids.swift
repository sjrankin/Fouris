//
//  +Grids.swift
//  Fouris
//
//  Created by Stuart Rankin on 11/4/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// This extension contains functions related to drawing and maintaining grids.
extension View3D
{
    /// Function that does the actual "line" drawing of the bucket grid.
    /// - Note: The lines are really very thin boxes; SceneKit doesn't support lines as graphical objects.
    /// - Parameter ShowGrid: If true, the grid is drawn. If false, no grid is drawn, but see **DrawOutline**.
    /// - Parameter DrawOutline: If true, a perimeter outline is drawn.
    /// - Parameter InitialOpacity: The initial opacity of the grids.
    /// - Parameter LineColorOverride: If provided, this is the color of the lines of the grid. If not provided, the color specified
    ///                                in the current theme will be used. Default is nil, which means use the theme's color.
    /// - Parameter OutlineColorOverride: If provided, this is the color of the lines of the outline. If not provided, the color specified
    ///                                   in the current theme will be used. Default is nil, which means use the theme's color.
    /// - Returns: Tuple with Grid being the bucket interior grid, and Outline the grid outline node.
    public func DrawGridInBucket(ShowGrid: Bool = true, DrawOutline: Bool, InitialOpacity: CGFloat = 1.0,
                                 LineColorOverride: UIColor? = nil, OutlineColorOverride: UIColor? = nil) -> (Grid: SCNNode, Outline: SCNNode)
    {
        objc_sync_enter(CanUseBucket)
        defer{objc_sync_exit(CanUseBucket)}
        
        if BucketGridNode != nil
        {
            BucketGridNode?.removeFromParentNode()
        }
        let BucketGridNode = SCNNode()
        let OutlineNode = SCNNode()
        
        var LineColor = UIColor.white
        var OutlineColor = UIColor.red
        if LineColorOverride != nil
        {
            LineColor = LineColorOverride!
        }
        if OutlineColorOverride != nil
        {
            OutlineColor = OutlineColorOverride!
        }
        
        let BoardClass = BoardData.GetBoardClass(For: CenterBlockShape!)!
        switch BoardClass
        {
            #if false
            case .Static:
                let XOffset = 0.5
                var YOffset = -3.0
                if UIDevice.current.userInterfaceIdiom == .phone
                {
                    YOffset = -1.0
                }
                if ShowGrid
                {
                    //Horizontal bucket lines.
                    for Y in stride(from: 10.0 + YOffset, to: -10.5 + YOffset, by: -1.0)
                    {
                        let Start = SCNVector3(-0.5 + XOffset, Y, 0.0)
                        let End = SCNVector3(10.5 + XOffset, Y, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.03)
                        LineNode.categoryBitMask = View3D.GameLight
                        LineNode.name = "Horizontal,\(Int(Y))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                    //Vertical bucket lines.
                    for X in stride(from: -4.5, to: 5.0, by: 1.0)
                    {
                        let Start = SCNVector3(X + XOffset, 0.0 + YOffset, 0.0)
                        let End = SCNVector3(X + XOffset, 20.0 + YOffset, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.03)
                        LineNode.categoryBitMask = View3D.GameLight
                        LineNode.name = "Vertical,\(Int(X))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                }
                
                if DrawOutline
                {
                    let TopStart = SCNVector3(-0.5 + XOffset, 10.0 + YOffset, 0.0)
                    let TopEnd = SCNVector3(10.5 + XOffset, 10.0 + YOffset, 0.0)
                    let TopLine = MakeLine(From: TopStart, To: TopEnd, Color: OutlineColor, LineWidth: 0.08)
                    TopLine.categoryBitMask = View3D.GameLight
                    TopLine.name = "TopLine"
                    BucketGridNode.addChildNode(TopLine)
                }
                BucketGridNode.opacity = InitialOpacity
            #endif
            
            case .Static:
            fallthrough
            case .SemiRotatable:
                fallthrough
            case .Rotatable:
                let GameBoard = BoardManager.GetBoardFor(CenterBlockShape!)!
                let BucketWidth = Double(GameBoard.BucketWidth)
                let BucketHeight = Double(GameBoard.BucketHeight)
                var BucketOffset = 0.0
                let EndingPointX = BucketWidth
                let EndingPointY = BucketHeight
                if GameBoard.BucketWidth.isMultiple(of: 2)
                {
                    BucketOffset = 0.5
                }
                let HalfY = BucketHeight / 2.0
                let HalfX = BucketWidth / 2.0
                if ShowGrid
                {
                    // Horizontal lines.
                    for Y in stride(from: HalfY, to: -HalfY - BucketOffset, by: -1.0)
                    {
                        let Start = SCNVector3(0.0, Y, 0.0)
                        let End = SCNVector3(EndingPointX, Y, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.02)
                        LineNode.categoryBitMask = View3D.GameLight
                        LineNode.name = "Horizontal,\(Int(Y))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                    //Vertical lines.
                    for X in stride(from: -HalfX, to: HalfX + BucketOffset, by: 1.0)
                    {
                        let Start = SCNVector3(X, 0.0, 0.0)
                        let End = SCNVector3(X, EndingPointY, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.02)
                        LineNode.categoryBitMask = View3D.GameLight
                        LineNode.name = "Vertical,\(Int(X))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                }
                
                //Outline.
                if DrawOutline
                {
                    let TopStart = SCNVector3(0.0, HalfY, 0.0)
                    let TopEnd = SCNVector3(BucketWidth, HalfY, 0.0)
                    let TopLine = MakeLine(From: TopStart, To: TopEnd, Color: OutlineColor, LineWidth: 0.08)
                    TopLine.categoryBitMask = View3D.GameLight
                    TopLine.name = "TopLine"
                    OutlineNode.addChildNode(TopLine)
                    let BottomStart = SCNVector3(0.0, -HalfY, 0.0)
                    let BottomEnd = SCNVector3(BucketWidth, -HalfY, 0.0)
                    let BottomLine = MakeLine(From: BottomStart, To: BottomEnd, Color: OutlineColor, LineWidth: 0.08)
                    BottomLine.categoryBitMask = View3D.GameLight
                    BottomLine.name = "BottomLine"
                    OutlineNode.addChildNode(BottomLine)
                    let LeftStart = SCNVector3(-HalfX, 0.0, 0.0)
                    let LeftEnd = SCNVector3(-HalfX, BucketHeight, 0.0)
                    let LeftLine = MakeLine(From: LeftStart, To: LeftEnd, Color: OutlineColor, LineWidth: 0.08)
                    LeftLine.categoryBitMask = View3D.GameLight
                    LeftLine.name = "LeftLine"
                    OutlineNode.addChildNode(LeftLine)
                    let RightStart = SCNVector3(HalfX, 0.0, 0.0)
                    let RightEnd = SCNVector3(HalfX, BucketHeight, 0.0)
                    let RightLine = MakeLine(From: RightStart, To: RightEnd, Color: OutlineColor, LineWidth: 0.08)
                    RightLine.categoryBitMask = View3D.GameLight
                    RightLine.name = "RightLine"
                    OutlineNode.addChildNode(RightLine)
                }
                BucketGridNode.opacity = InitialOpacity
            
            case .ThreeDimensional:
                let GameBoard = BoardManager.GetBoardFor(CenterBlockShape!)!
                let BucketWidth = Double(GameBoard.BucketWidth)
                let BucketHeight = Double(GameBoard.BucketHeight)
                let BucketDepth = Double(GameBoard.BucketDepth)
                var BucketOffset = 0.0
                let EndingPointX = BucketWidth
                let EndingPointY = BucketHeight
                let EndingPointZ = BucketDepth
                if GameBoard.BucketWidth.isMultiple(of: 2)
                {
                    BucketOffset = 0.5
                }
                let HalfY = BucketHeight / 2.0
                let HalfX = BucketWidth / 2.0
                let HalfZ = BucketDepth / 2.0
                if ShowGrid
                {
                    //Draw perpendicular to the Z axis (Z does not vary)
                    for Y in stride(from: HalfY, to: -HalfY - BucketOffset, by: -1.0)
                    {
                        let Start = SCNVector3(0.0, Y, 0.0)
                        let End = SCNVector3(EndingPointX, Y, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.02)
                        LineNode.categoryBitMask = View3D.GameLight
                        LineNode.name = "HorizontalZ,\(Int(Y))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                    for X in stride(from: -HalfX, to: HalfX + BucketOffset, by: 1.0)
                    {
                        let Start = SCNVector3(X, 0.0, 0.0)
                        let End = SCNVector3(X, EndingPointY, 0.0)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.02)
                        LineNode.categoryBitMask = View3D.GameLight
                        LineNode.name = "VerticalZ,\(Int(X))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                    
                    //Draw perpendicular to the Y axis (Y does not vary).
                    for X in stride(from: -HalfX, to: HalfX + BucketOffset, by: 1.0)
                    {
                        let Start = SCNVector3(X, 0.0, 0.0)
                        let End = SCNVector3(X, 0.0, EndingPointZ)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.02)
                        LineNode.categoryBitMask = View3D.GameLight
                        LineNode.name = "HorizontalY,\(Int(X))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                    for Z in stride(from: -HalfZ, to: HalfZ + BucketOffset, by: 1.0)
                    {
                        let Start = SCNVector3(0.0, 0.0, Z)
                        let End = SCNVector3(EndingPointX, 0.0, Z)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.02)
                        LineNode.categoryBitMask = View3D.GameLight
                        LineNode.name = "VerticalY,\(Int(Z))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                    
                    //Draw perpendicular to the X axis (X does not vary).
                    for Z in stride(from: -HalfZ, to: HalfZ + BucketOffset, by: 1.0)
                    {
                        let Start = SCNVector3(0.0, 0.0, Z)
                        let End = SCNVector3(0.0, EndingPointY, Z)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.02)
                        LineNode.categoryBitMask = View3D.GameLight
                        LineNode.name = "VerticalX,\(Int(Z))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                    for Y in stride(from: HalfY, to: -HalfY - BucketOffset, by: -1.0)
                    {
                        let Start = SCNVector3(0.0, Y, 0.0)
                        let End = SCNVector3(0.0, Y, EndingPointZ)
                        let LineNode = MakeLine(From: Start, To: End, Color: LineColor, LineWidth: 0.02)
                        LineNode.categoryBitMask = View3D.GameLight
                        LineNode.name = "HorizontalX,\(Int(Y))"
                        BucketGridNode.addChildNode(LineNode)
                    }
                }
                
                //Outline.
                if DrawOutline
                {
                    let TopStart = SCNVector3(0.0, HalfY, 0.0)
                    let TopEnd = SCNVector3(BucketWidth, HalfY, 0.0)
                    let TopLine = MakeLine(From: TopStart, To: TopEnd, Color: OutlineColor, LineWidth: 0.08)
                    TopLine.categoryBitMask = View3D.GameLight
                    TopLine.name = "TopLine"
                    OutlineNode.addChildNode(TopLine)
                    let BottomStart = SCNVector3(0.0, -HalfY, 0.0)
                    let BottomEnd = SCNVector3(BucketWidth, -HalfY, 0.0)
                    let BottomLine = MakeLine(From: BottomStart, To: BottomEnd, Color: OutlineColor, LineWidth: 0.08)
                    BottomLine.categoryBitMask = View3D.GameLight
                    BottomLine.name = "BottomLine"
                    OutlineNode.addChildNode(BottomLine)
                    let LeftStart = SCNVector3(-HalfX, 0.0, 0.0)
                    let LeftEnd = SCNVector3(-HalfX, BucketHeight, 0.0)
                    let LeftLine = MakeLine(From: LeftStart, To: LeftEnd, Color: OutlineColor, LineWidth: 0.08)
                    LeftLine.categoryBitMask = View3D.GameLight
                    LeftLine.name = "LeftLine"
                    OutlineNode.addChildNode(LeftLine)
                    let RightStart = SCNVector3(HalfX, 0.0, 0.0)
                    let RightEnd = SCNVector3(HalfX, BucketHeight, 0.0)
                    let RightLine = MakeLine(From: RightStart, To: RightEnd, Color: OutlineColor, LineWidth: 0.08)
                    RightLine.categoryBitMask = View3D.GameLight
                    RightLine.name = "RightLine"
                    OutlineNode.addChildNode(RightLine)
                }
                BucketGridNode.opacity = InitialOpacity
            
            default:
            break
        }
        
        return (Grid: BucketGridNode, Outline: OutlineNode)
    }
    
    
    
    /// Fades the bucket grid to an alpha of 0.0 then removes the lines from the scene.
    /// - Parameter Duration: Number of seconds for the fade effect to take place. Default is 1.0 seconds.
    public func FadeBucketGrid(Duration: Double = 1.0)
    {
        let FadeAction = SCNAction.fadeOut(duration: Duration)
        //print("Removing bucket grid node in FadeBucketGrid")
        BucketGridNode?.runAction(FadeAction, completionHandler:
            {
                self.BucketGridNode?.removeAllActions()
                self.BucketGridNode?.removeFromParentNode()
                self.BucketGridNode = nil
        }
        )
        //print("  Done removing bucket grid node in FadeBucketGrid")
    }
    
    /// Show or hide a buck grid. The bucket grid is unit sized (according to the block size) that fills the
    /// interior of the bucket.
    /// - Parameter ShowLines: Determines if the grid is shown or hidden.
    /// - Parameter IncludingOutline: If true, the outline is drawn as well.
    public func DrawBucketGrid(ShowLines: Bool, IncludingOutline: Bool = true)
    {
        let (Grid, Outline) = DrawGridInBucket(ShowGrid: ShowLines, DrawOutline: IncludingOutline)
        BucketGridNode = Grid
        OutlineNode = Outline
        self.scene?.rootNode.addChildNode(BucketGridNode!)
        self.scene?.rootNode.addChildNode(OutlineNode!)
    }
    
    /// Hide the bucket grid by removing all grid nodes from the scene.
    public func ClearBucketGrid()
    {
        RemoveNodes(WithNames: ["BucketGrid", "TopLine", "LeftLine", "BottomLine", "RightLine",
                                "Top", "Left", "Bottom", "Right"])
    }
    
    /// Draw background grid lines.
    /// - Parameter Show: Determines visibility of the grid.
    /// - Parameter WithUnitSize: Defines the gap between grid lines.
    public func DrawGridLines(_ Show: Bool, WithUnitSize: CGFloat?)
    {
        if Show
        {
            CreateGrid()
        }
        else
        {
            RemoveNodes(WithName: "BucketNode")
        }
    }
    
    /// Create a "line" and return it in a scene node.
    /// - Note: The line is really a very thin box. This makes lines a rather heavy operation.
    /// - Parameter From: Starting point of the line.
    /// - Parameter To: Ending point of the line.
    /// - Parameter Color: The color of the line.
    /// - Parameter LineWidth: Width of the line - defaults to 0.01.
    /// - Returns: Node with the specified line. The node has the name "GridNodes".
    public func MakeLine(From: SCNVector3, To: SCNVector3, Color: UIColor, LineWidth: CGFloat = 0.01) -> SCNNode
    {
        var Width: Float = 0.01
        var Height: Float = 0.01
        let FinalLineWidth = Float(LineWidth)
        if From.y == To.y
        {
            Width = abs(From.x - To.x)
            Height = FinalLineWidth
        }
        else
        {
            Height = abs(From.y - To.y)
            Width = FinalLineWidth
        }
        let Line = SCNBox(width: CGFloat(Width), height: CGFloat(Height), length: 0.01,
                          chamferRadius: 0.0)
        Line.materials.first?.diffuse.contents = Color
        let Node = SCNNode(geometry: Line)
        Node.categoryBitMask = View3D.GameLight
        Node.position = From
        Node.name = "GridNodes"
        return Node
    }
    
    /// Create a grid and place it into the scene.
    public func CreateGrid()
    {
        RemoveNodes(WithName: "GridNodes")
        for Y in stride(from: -64.0, to: 128.0, by: 1.0)
        {
            let Start = SCNVector3(-64.5, Y, 0.0)
            let End = SCNVector3(128.5, Y, 0.0)
            let LineNode = MakeLine(From: Start, To: End, Color: UIColor.white)
            self.scene?.rootNode.addChildNode(LineNode)
        }
        for X in stride(from: -64.5, to: 128.5, by: 1.0)
        {
            let Start = SCNVector3(X, -64.0, 0.0)
            let End = SCNVector3(X, 128.0, 0.0)
            let LineNode = MakeLine(From: Start, To: End, Color: UIColor.white)
            self.scene?.rootNode.addChildNode(LineNode)
        }
    }
    
    /// Remove the grid from the scene.
    public func RemoveGrid()
    {
        RemoveNodes(WithName: "GridNodes")
    }
    
    /// Draw a vertical and horizontal line passing through the origin.
    /// - Note: Whether or not center lines are drawn is determined by the settings in the current theme.
    /// - Note: Center lines are intended to be used for debugging only.
    public func DrawCenterLines()
    {
        //print("Removing center lines.")
        CenterLineVertical?.removeFromParentNode()
        CenterLineHorizontal?.removeFromParentNode()
        //print("  Done removing center lines.")
        if CurrentTheme!.ShowCenterLines
        {
            let Width: CGFloat = CGFloat(CurrentTheme!.CenterLineWidth)
            let LineColor = ColorServer.ColorFrom(CurrentTheme!.CenterLineColor)
            CenterLineVertical = MakeLine(From: SCNVector3(0.0, 20.0, 2.0), To: SCNVector3(0.0, -80.0, 2.0), Color: LineColor, LineWidth: Width)
            CenterLineHorizontal = MakeLine(From: SCNVector3(-20.0, 0.0, 2.0), To: SCNVector3(80.0, 0.0, 2.0), Color: LineColor, LineWidth: Width)
            CenterLineVertical!.categoryBitMask = View3D.ControlLight
            CenterLineHorizontal!.categoryBitMask = View3D.ControlLight
            self.scene?.rootNode.addChildNode(CenterLineVertical!)
            self.scene?.rootNode.addChildNode(CenterLineHorizontal!)
        }
    }
}
