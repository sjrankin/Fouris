//
//  +ShapeOutlines.swift
//  Fouris
//
//  Created by Stuart Rankin on 11/17/26.
//

import Foundation
import UIKit
import SceneKit

/// A block position used when building a shape outline.
struct OutlineCell
{
    /// ID of the block.
    let ID: UUID
    /// Horizontal scene coordinate of the center of the block.
    let X: CGFloat
    /// Vertical scene coordinate of the center of the block.
    let Y: CGFloat
}

/// Black outlines around whole shapes (not around individual blocks).
///
/// An edge is drawn on the side of a block when the block next to it is not part of the same shape. Retired blocks remember
/// which blocks they were joined to when their piece landed (`BlockJoins`). When rows are removed, blocks of a shape that were
/// held together by a removed block are no longer joined, so each remaining part gets its own outline.
extension View3D
{
    /// Thickness of an outline line in scene units.
    private static let OutlineThickness: CGFloat = 0.08
    
    /// Depth of the outline, just in front of the front faces of the blocks.
    private static let OutlineDepth: Float = 0.52
    
    /// Records which blocks of a landing piece touch each other. Call when the piece is merged into the bucket.
    /// - Parameter Finalized: The piece that landed.
    func RecordBlockJoins(For Finalized: Piece)
    {
        guard let Blocks = Finalized.Locations else
        {
            return
        }
        for First in Blocks
        {
            for Second in Blocks where First.ID != Second.ID
            {
                if abs(First.X - Second.X) + abs(First.Y - Second.Y) == 1
                {
                    BlockJoins[First.ID, default: []].insert(Second.ID)
                }
            }
        }
    }
    
    /// Rebuilds the outlines of all retired shapes from the blocks that are currently in the bucket. Call after the map is
    /// redrawn (which includes after rows are removed).
    func RebuildShapeOutlines()
    {
        ShapeOutlineNode?.removeFromParentNode()
        ShapeOutlineNode = nil
        let Retired = BlockList.filter({$0.IsRetired})
        //Forget joins for blocks that no longer exist.
        let LiveIDs = Set(Retired.map({$0.ID}))
        BlockJoins = BlockJoins.compactMapValues(
            {
                let Remaining = $0.intersection(LiveIDs)
                return Remaining.isEmpty ? nil : Remaining
        }).filter({LiveIDs.contains($0.key)})
        let Cells = Retired.map({OutlineCell(ID: $0.ID, X: $0.X, Y: $0.Y)})
        let Joins = BlockJoins
        guard let Node = MakeOutlineNode(Cells: Cells, AreJoined: {Joins[$0.ID]?.contains($1.ID) ?? false}) else
        {
            return
        }
        Node.name = "Shape Outlines"
        MasterBlockNode?.addChildNode(Node)
        ShapeOutlineNode = Node
    }
    
    /// Draws the outline of the moving piece.
    /// - Parameter Blocks: The visual blocks of the moving piece.
    func DrawMovingPieceOutline(_ Blocks: [VisualBlocks3D])
    {
        RemoveMovingPieceOutline()
        let Cells = Blocks.map({OutlineCell(ID: $0.ID, X: $0.X, Y: $0.Y)})
        //All blocks of the moving piece belong to the same shape.
        guard let Node = MakeOutlineNode(Cells: Cells, AreJoined: {_, _ in true}) else
        {
            return
        }
        Node.name = "Moving Piece Outline"
        scene?.rootNode.addChildNode(Node)
        MovingOutlineNode = Node
    }
    
    /// Removes the outline of the moving piece.
    func RemoveMovingPieceOutline()
    {
        MovingOutlineNode?.removeFromParentNode()
        MovingOutlineNode = nil
    }
    
    /// Forgets all retired-shape outline data. Call when the bucket is cleared.
    func ResetShapeOutlines()
    {
        ShapeOutlineNode?.removeFromParentNode()
        ShapeOutlineNode = nil
        BlockJoins.removeAll()
    }
    
    /// Creates a node with black lines along every edge between a block and a block that is not part of the same shape.
    /// - Parameter Cells: Blocks to outline.
    /// - Parameter AreJoined: Determines whether two neighboring blocks belong to the same shape.
    /// - Returns: A node containing the outline, nil if there is nothing to draw.
    private func MakeOutlineNode(Cells: [OutlineCell], AreJoined: (OutlineCell, OutlineCell) -> Bool) -> SCNNode?
    {
        if Cells.isEmpty
        {
            return nil
        }
        //Positions are multiples of 0.5, so use doubled integer coordinates as keys.
        func Key(_ X: CGFloat, _ Y: CGFloat) -> [Int]
        {
            return [Int((X * 2.0).rounded()), Int((Y * 2.0).rounded())]
        }
        var Lookup = [[Int]: OutlineCell]()
        for Cell in Cells
        {
            Lookup[Key(Cell.X, Cell.Y)] = Cell
        }
        var Vertices = [SCNVector3]()
        var Indices = [UInt32]()
        let Half = View3D.OutlineThickness / 2.0
        func AddLine(FromX X0: CGFloat, FromY Y0: CGFloat, ToX X1: CGFloat, ToY Y1: CGFloat)
        {
            let Left = min(X0, X1) - Half
            let Right = max(X0, X1) + Half
            let Bottom = min(Y0, Y1) - Half
            let Top = max(Y0, Y1) + Half
            let Base = UInt32(Vertices.count)
            Vertices.append(SCNVector3(Float(Left), Float(Bottom), View3D.OutlineDepth))
            Vertices.append(SCNVector3(Float(Right), Float(Bottom), View3D.OutlineDepth))
            Vertices.append(SCNVector3(Float(Right), Float(Top), View3D.OutlineDepth))
            Vertices.append(SCNVector3(Float(Left), Float(Top), View3D.OutlineDepth))
            Indices.append(contentsOf: [Base, Base + 1, Base + 2, Base, Base + 2, Base + 3])
        }
        for Cell in Cells
        {
            let Neighbors: [(DX: CGFloat, DY: CGFloat)] = [(-1.0, 0.0), (1.0, 0.0), (0.0, 1.0), (0.0, -1.0)]
            for Neighbor in Neighbors
            {
                if let Other = Lookup[Key(Cell.X + Neighbor.DX, Cell.Y + Neighbor.DY)], AreJoined(Cell, Other)
                {
                    //Same shape on this side - no edge.
                    continue
                }
                if Neighbor.DX != 0.0
                {
                    //Vertical edge on the left or right side of the block.
                    let EdgeX = Cell.X + Neighbor.DX * 0.5
                    AddLine(FromX: EdgeX, FromY: Cell.Y - 0.5, ToX: EdgeX, ToY: Cell.Y + 0.5)
                }
                else
                {
                    //Horizontal edge on the top or bottom of the block.
                    let EdgeY = Cell.Y + Neighbor.DY * 0.5
                    AddLine(FromX: Cell.X - 0.5, FromY: EdgeY, ToX: Cell.X + 0.5, ToY: EdgeY)
                }
            }
        }
        if Vertices.isEmpty
        {
            return nil
        }
        let Normals = Vertices.map({_ in SCNVector3(0.0, 0.0, 1.0)})
        let Geometry = SCNGeometry(sources: [SCNGeometrySource(vertices: Vertices), SCNGeometrySource(normals: Normals)],
                                   elements: [SCNGeometryElement(indices: Indices, primitiveType: .triangles)])
        let Material = SCNMaterial()
        Material.diffuse.contents = UIColor.black
        Material.lightingModel = .constant
        Material.isDoubleSided = true
        Geometry.materials = [Material]
        let Node = SCNNode(geometry: Geometry)
        Node.categoryBitMask = View3D.GameLight
        return Node
    }
}
