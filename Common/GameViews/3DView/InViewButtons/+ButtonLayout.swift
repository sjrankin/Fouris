//
//  +ButtonLayout.swift
//  Fouris
//
//  Created by Stuart Rankin on 11/17/26.
//

import Foundation
import UIKit
import SceneKit

/// Device-independent layout of the in-view control buttons.
///
/// The button dictionaries hold design-time locations that assume a certain visible width. SceneKit's field of view is vertical,
/// so the visible width changes with the aspect ratio of the device (tall phones show less width than the design assumed).
/// These functions measure the visible width at the plane of the buttons and pull the controls toward the center when they
/// would otherwise be cropped by the edges of the screen.
extension View3D
{
    /// Depth of the plane the control buttons live in.
    private static let ButtonPlaneZ: Float = 1.0
    
    /// Margin (in scene units) kept between the outer edge of the outermost buttons and the visible edge.
    private static let ButtonEdgeInset: CGFloat = 1.0
    
    /// Returns the horizontal range of the scene that is visible in the plane of the control buttons.
    /// - Note: Screen edges are converted to rays and intersected with the button plane, so a tilted camera is handled. The
    ///         range is measured at each of the supplied vertical levels and the narrowest range is returned.
    /// - Parameter Levels: Vertical scene coordinates (in the button plane) at which to measure.
    /// - Returns: Tuple of the left-most and right-most visible scene X coordinates. Nil if the view has no size or camera yet.
    private func VisibleButtonRange(AtLevels Levels: [CGFloat]) -> (Min: CGFloat, Max: CGFloat)?
    {
        if bounds.width < 1.0 || bounds.height < 1.0 || scene == nil || pointOfView == nil || Levels.isEmpty
        {
            return nil
        }
        var Lowest = -CGFloat.infinity
        var Highest = CGFloat.infinity
        for Level in Levels
        {
            let ScreenPoint = projectPoint(SCNVector3(0.0, Float(Level), View3D.ButtonPlaneZ))
            guard let Left = PlaneIntersection(ScreenX: 0.0, ScreenY: CGFloat(ScreenPoint.y)),
                  let Right = PlaneIntersection(ScreenX: bounds.width, ScreenY: CGFloat(ScreenPoint.y)) else
            {
                return nil
            }
            Lowest = max(Lowest, Left)
            Highest = min(Highest, Right)
        }
        if !Lowest.isFinite || !Highest.isFinite || Highest <= Lowest
        {
            return nil
        }
        return (Lowest, Highest)
    }
    
    /// Intersects the ray through a screen point with the button plane.
    /// - Parameter ScreenX: Horizontal screen coordinate in points.
    /// - Parameter ScreenY: Vertical screen coordinate in points.
    /// - Returns: Scene X coordinate of the intersection, nil if the ray does not reach the plane.
    private func PlaneIntersection(ScreenX: CGFloat, ScreenY: CGFloat) -> CGFloat?
    {
        let Near = unprojectPoint(SCNVector3(Float(ScreenX), Float(ScreenY), 0.0))
        let Far = unprojectPoint(SCNVector3(Float(ScreenX), Float(ScreenY), 1.0))
        let DeltaZ = Far.z - Near.z
        if abs(DeltaZ) < 0.00001
        {
            return nil
        }
        let T = (View3D.ButtonPlaneZ - Near.z) / DeltaZ
        let X = CGFloat(Near.x + T * (Far.x - Near.x))
        return X.isFinite ? X : nil
    }
    
    /// Returns the design-time dictionary for the current device.
    /// - Note: The dictionary holds the *design* locations. `RepositionControlButtons` moves the actual nodes so they are fully
    ///         visible on the device being used.
    /// - Returns: Button dictionary to use for creating and placing buttons.
    func CurrentButtonDictionary() -> [NodeButtons: (Location: SCNVector3, Scale: Double, Color: UIColor, Highlight: UIColor)]
    {
        return UIDevice.current.userInterfaceIdiom == .phone ? SmallButtonDictionary : BigButtonDictionary
    }
    
    /// Horizontal extent of a button node in scene units, relative to the node's position.
    /// - Note: Button text geometry starts at the node's origin and extends to the right, so the visual center of a button
    ///         is not at its position.
    /// - Parameter Node: The button node.
    /// - Returns: Left and right extent relative to the node's position, with the node's scale applied.
    private func ButtonExtent(_ Node: SCNNode) -> (Left: CGFloat, Right: CGFloat)
    {
        var (Low, High) = Node.boundingBox
        if Low.x == High.x
        {
            //No geometry on the node itself - use its children, if any.
            for Child in Node.childNodes
            {
                let (ChildLow, ChildHigh) = Child.boundingBox
                Low.x = min(Low.x, ChildLow.x * Child.scale.x + Child.position.x)
                High.x = max(High.x, ChildHigh.x * Child.scale.x + Child.position.x)
            }
        }
        return (CGFloat(Low.x * Node.scale.x), CGFloat(High.x * Node.scale.x))
    }
    
    /// Moves all existing control buttons so they are fully visible. Call after buttons are created and whenever the size of
    /// the view changes.
    /// - Note: Buttons start from their design locations. If the whole control set already fits the visible width at the
    ///         button plane, nothing moves. Otherwise the horizontal positions are compressed toward the center, keeping a margin
    ///         to the screen edges. Vertical positions are never changed.
    /// - Returns: True if the view could be measured and the buttons were fitted, false if the view is not ready yet.
    @discardableResult func RepositionControlButtons() -> Bool
    {
        let Design = CurrentButtonDictionary()
        let Buttons = (scene?.rootNode.childNodes ?? []).compactMap({$0 as? SCNButtonNode}).filter({Design[$0.ButtonType] != nil})
        if Buttons.isEmpty
        {
            return false
        }
        let Levels = Array(Set(Buttons.map({CGFloat(Design[$0.ButtonType]!.Location.y)})))
        guard let Visible = VisibleButtonRange(AtLevels: Levels) else
        {
            return false
        }
        //Design-time horizontal extents of every button.
        var Extents = [(Button: SCNButtonNode, Left: CGFloat, Right: CGFloat)]()
        for Button in Buttons
        {
            let Position = CGFloat(Design[Button.ButtonType]!.Location.x)
            let Extent = ButtonExtent(Button)
            Extents.append((Button, Position + Extent.Left, Position + Extent.Right))
        }
        //Group buttons by side of the screen and by band (top bar, heart, bottom controls) so the spacing inside each cluster
        //is kept. Only clusters that would be cropped are slid inward.
        let AvailableLeft = Visible.Min + View3D.ButtonEdgeInset
        let AvailableRight = Visible.Max - View3D.ButtonEdgeInset
        struct ClusterKey: Hashable
        {
            let Side: Int
            let Band: Int
        }
        var Clusters = [ClusterKey: [Int]]()
        for (Index, Entry) in Extents.enumerated()
        {
            let Center = (Entry.Left + Entry.Right) / 2.0
            let Side = Center < -2.5 ? -1 : (Center > 2.5 ? 1 : 0)
            let Y = CGFloat(Design[Entry.Button.ButtonType]!.Location.y)
            let Band = Y >= 10.0 ? 2 : (Y > 0.0 ? 1 : 0)
            Clusters[ClusterKey(Side: Side, Band: Band), default: []].append(Index)
        }
        var Shifts = [Int: CGFloat]()
        for (Key, Members) in Clusters
        {
            let Left = Members.map({Extents[$0].Left}).min()!
            let Right = Members.map({Extents[$0].Right}).max()!
            var Shift: CGFloat = 0.0
            if Left < AvailableLeft
            {
                Shift = AvailableLeft - Left
            }
            else if Right > AvailableRight
            {
                Shift = AvailableRight - Right
            }
            if Key.Side == 0
            {
                //Center clusters only move if they are actually cropped.
                Shift = max(min(Shift, AvailableRight - Right), AvailableLeft - Left)
            }
            for Member in Members
            {
                Shifts[Member] = Shift
            }
        }
        for (Index, Entry) in Extents.enumerated()
        {
            var Position = Design[Entry.Button.ButtonType]!.Location
            Position.x = Position.x + Float(Shifts[Index] ?? 0.0)
            Entry.Button.position = Position
        }
        return true
    }
}
