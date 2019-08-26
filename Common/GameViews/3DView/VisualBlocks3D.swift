//
//  VisualBlocks3D.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

/// This class encapsulates a Scene node that acts as a visual block in the game.
class VisualBlocks3D: SCNNode
{
    /// Default initializer.
    override init()
    {
        super.init()
        CommonInitialization()
    }
    
    /// Initializer.
    /// - Parameter: WithID: ID of the block to link it to the source object in the board map.
    init(_ WithID: UUID)
    {
        super.init()
        CommonInitialization()
        _ID = WithID
    }
    
    /// Initializer.
    /// - Note: The Z location is set to 0.0.
    /// - Parameter WithID: ID of the block to link it to the source object in the board map.
    /// - Parameter AtX: Initial X location of the block.
    /// - Parameter AtY: Initial Y location of the block.
    /// - Parameter WithTile: Tile to use to create the visual look of the block.
    /// - Parameter IsRetired: Determines which set of attributes to use for the visual look.
    init(_ WithID: UUID, AtX: CGFloat, AtY: CGFloat, WithTile: TileDescriptor, IsRetired: Bool)
    {
        super.init()
        CommonInitialization()
        _ID = WithID
        _IsRetired = IsRetired
        BlockTile = WithTile
        Create(WithTile: WithTile, IsRetired: IsRetired)
        X = AtX
        Y = AtY
        Z = 0.0
    }
    
    /// Initializer.
    /// - Parameter WithID: ID of the block to link it to the source object in the board map.
    /// - Parameter AtX: Initial X location of the block.
    /// - Parameter AtY: Initial Y location of the block.
    /// - Parameter AtZ: Initial Z location of the block.
    /// - Parameter WithTile: Tile to use to create the visual look of the block.
    /// - Parameter IsRetired: Determines which set of attributes to use for the visual look.
    init(_ WithID: UUID, AtX: CGFloat, AtY: CGFloat, AtZ: CGFloat, WithTile: TileDescriptor, IsRetired: Bool)
    {
        super.init()
        CommonInitialization()
        _ID = WithID
        _IsRetired = IsRetired
        BlockTile = WithTile
        Create(WithTile: WithTile, IsRetired: IsRetired)
        X = AtX
        Y = AtY
        Z = AtZ
    }
    
    /// Required initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        CommonInitialization()
    }
    
    /// Initialization common to all initializers.
    private func CommonInitialization()
    {
        self.name = "VisualBlock" + " [(VisualBlocks3D.BlockCount)]"
        VisualBlocks3D.BlockCount = VisualBlocks3D.BlockCount + 1
        Marked = false
    }
    
    private static var BlockCount = 0
    
    /// Reference to the tile descriptor for this block.
    private var _BlockTile: TileDescriptor? = nil
    /// Get or set the tile descriptor used to describe the visual aspects of this block. Setting the
    /// value changes the visuals immediately.
    public var BlockTile: TileDescriptor?
    {
        get
        {
            return _BlockTile
        }
        set
        {
            _BlockTile = newValue
            if let Tile = _BlockTile
            {
                SetVisualAttributes(WithTile: Tile, IsRetired: IsRetired)
            }
        }
    }
    
    /// Holds the ID of the parent.
    private var _ParentID: UUID = UUID.Empty
    /// Get or set the ID of the parent.
    public var ParentID: UUID
    {
        get
        {
            return _ParentID
        }
        set
        {
            _ParentID = newValue
        }
    }
    
    /// Holds the ID of the visual block.
    private var _ID = UUID()
    /// Get the ID of the visual block.
    public var ID: UUID
    {
        get
        {
            return _ID
        }
    }
    
    /// Holds the retired flag.
    private var _IsRetired: Bool = false
    /// Get or set the retired flag. Setting this property may change the visual aspects of the block.
    /// - Note: In order for changing this property to actually change the visual aspects of the block,
    ///         one of the initializers that takes a `TileDescriptor` as a parameter must be used or the
    ///         caller must have previously set `BlockTile` with a tile descriptor.
    public var IsRetired: Bool
    {
        get
        {
            return _IsRetired
        }
        set
        {
            if newValue == _IsRetired
            {
                return
            }
            _IsRetired = newValue
            if let Tile = BlockTile
            {
                SetVisualAttributes(WithTile: Tile, IsRetired: _IsRetired)
            }
        }
    }
    
    var VACount = 0
    /// Sets the passed tile's visual attributes to the block.
    /// - Parameter WithTile: The tile whose visual attributes will be used to draw the block.
    /// - Parameter IsRetired: Determines which set of visual attributes to use.
    public func SetVisualAttributes(WithTile: TileDescriptor, IsRetired: Bool)
    {
//        print("Setting visual attributes [\(VACount)].")
        VACount = VACount + 1
        if BlockShape == nil
        {
            return
        }
        
        //Check the retired flag and change the shape *before* updating the shape if the retired state is true.
        //This is because if the shape is changed, the textures/colors need to be reset to the new colors, so
        //we change the shape first, as needed, *then* set the colors/textures.
        if IsRetired
        {
            BlockShape = CreateGeometry(Width: OriginalWidth, Height: OriginalHeight, Depth: OriginalDepth, IsRetired: true)
            self.geometry = BlockShape
        }
        
        var Specular = "White"
        var Diffuse = "ReallyDarkGray"
        switch WithTile.VisualType
        {
            case .Draw:
                break
            
            case .Image:
                if IsRetired
                {
                    //Specular = WithTile.RetiredTextureName
                    Diffuse = WithTile.RetiredTextureName
                }
                else
                {
                    //Specular = WithTile.ActiveTextureName
                    Diffuse = WithTile.ActiveTextureName
                }
                BlockShape!.materials.first?.diffuse.contents = UIImage(named: Diffuse)
            
            case .Render:
                if WithTile.EnableColorOverride
                {
                    if IsRetired
                    {
                        Specular = WithTile.OverrideRetiredSpecularColor
                        Diffuse = WithTile.OverrideRetiredDiffuseColor
                    }
                    else
                    {
                        Specular = WithTile.OverrideActiveSpecularColor
                        Diffuse = WithTile.OverrideActiveDiffuseColor
                    }
                }
                else
                {
                if IsRetired
                {
                    Specular = WithTile.RetiredSpecularColor
                    Diffuse = WithTile.RetiredDiffuseColor
                }
                else
                {
                    Specular = WithTile.ActiveSpecularColor
                    Diffuse = WithTile.ActiveDiffuseColor
                }
                }
                BlockShape!.materials.first?.specular.contents = ColorServer.ColorFrom(Specular)
                BlockShape!.materials.first?.diffuse.contents = ColorServer.ColorFrom(Diffuse)
        }
        
        let GeoShape = IsRetired ? BlockTile?.Retired3DBlockShape : BlockTile?.Active3DBlockShape
        switch GeoShape
        {
            case .Torus:
                self.removeAllActions()
                let RotateAction = SCNAction.rotateBy(x: CGFloat.pi * 2.0, y: 0.0, z: 0.0, duration: 5.0)
                RotateAction.timingMode = .linear
                self.runAction(SCNAction.repeatForever(RotateAction))
            
            case .Tube:
                self.removeAllActions()
                let RotateAction = SCNAction.rotateBy(x: CGFloat.pi * 2.0, y: 0.0, z: 0.0, duration: 5.0)
                RotateAction.timingMode = .linear
                self.runAction(SCNAction.repeatForever(RotateAction))
            
            default:
                break
        }
    }
    
    /// Holds the geometry of the node.
    private var BlockShape: SCNGeometry? = nil
    
    /// Creates the geometric shape of the block. Relies on a previously set theme (set during initialization).
    /// - Note:
    ///   - Depending on the shape, not all parameters are used.
    ///     - **.Capsule** uses **Width** (multiplied by 0.35) for the cap radius and **Height**.
    ///     - **.Cone** uses **Width** (divided by 2) for the bottom radius and **Height**.
    ///     - **.Cubic** uses **Width**, **Height**, and **Depth**.
    ///     - **.Cylinder** uses **Width** (divided by 2) for the radius and **Height**.
    ///     - **.Pyramid** uses **Width**, **Height**, and **Depth**.
    ///     - **.RoundedCube** uses **Width**, **Height**, and **Depth** and **Width** * 0.1 for the chamfer radius.
    ///     - **.Spherical** uses **Width** divided by 2.
    ///     - **.Torus** uses **Width** divided by 2 for the outer radius and **Width** divided by 4 for the inner radius.
    ///     - **.Tube** uses **Width** divided by 2 for the outer radius, **Width** divided by 4 for the inner radius, and **Height**.
    ///     - **.Dodecahedron** uses **Width** divided by 2 for the radius of the points defining the solid.
    ///     - **.Tetrahedron** uses **Width** as the base segment length and **Height** as the height of *each* central point. To
    ///       have the overall height the same as the width, set **Height** to (***Width** * 0.5).
    /// - Parameter Width: Width of the block.
    /// - Parameter Height: Height of the block.
    /// - Parameter Depth: Depth of the block.
    /// - Parameter IsRetired: Determines which theme state to use.
    /// - Returns: An SCNGeometry instance with the appropriate shape.
    private func CreateGeometry(Width: CGFloat, Height: CGFloat, Depth: CGFloat, IsRetired: Bool) -> SCNGeometry
    {
        let GeoShape = IsRetired ? BlockTile?.Retired3DBlockShape : BlockTile?.Active3DBlockShape
        var Geometry: SCNGeometry!
        switch GeoShape!
        {
            case .Capsule:
                Geometry = SCNCapsule(capRadius: Width * 0.35, height: Height)
            
            case .Cone:
                Geometry = SCNCone(topRadius: 0.0, bottomRadius: Width * 0.5, height: Height)
            
            case .Cubic:
                Geometry = SCNBox(width: Width, height: Height, length: Depth, chamferRadius: 0.0)
            
            case .Cylinder:
                Geometry = SCNCylinder(radius: Width * 0.5, height: Height)
            
            case .Pyramid:
                Geometry = SCNPyramid(width: Width, height: Height, length: Depth)
            
            case .RoundedCube:
                Geometry = SCNBox(width: Width, height: Height, length: Depth, chamferRadius: Width * 0.1)
            
            case .Spherical:
                Geometry = SCNSphere(radius: Width * 0.5)
            
            case .Torus:
                Geometry = SCNTorus(ringRadius: Width * 0.5, pipeRadius: Width * 0.25)
            
            case .Tube:
                Geometry = SCNTube(innerRadius: Width * 0.25, outerRadius: Width * 0.5, height: Height)
            
            case .Dodecahedron:
                Geometry = SCNDodecahedron.Geometry(Radius: Width * 0.5)
            
            case .Tetrahedron:
                Geometry = SCNTetrahedron.Geometry(BaseLength: Width, Height: Height)
        }
        
        return Geometry!
    }
    
    /// Create the geometry and apply visual attributes.
    /// - Parameter Width: Width of the box.
    /// - Parameter Height: Height of the box.
    /// - Parameter Depth: Depth of the box.
    /// - Parameter EdgeRadius: Chamfer radius (rounded edges) of the box.
    /// - Parameter WithTile: The tile to use to get visual attributes.
    /// - Parameter IsRetired: Determines which set of visual attributes to use.
    public func Create(Width: CGFloat, Height: CGFloat, Depth: CGFloat, EdgeRadius: CGFloat,
                       WithTile: TileDescriptor, IsRetired: Bool)
    {
        OriginalWidth = Width
        OriginalHeight = Height
        OriginalDepth = Depth
        let BlockGeometry = CreateGeometry(Width: Width, Height: Height, Depth: Depth, IsRetired: IsRetired)
        self.geometry = BlockGeometry
        BlockShape = BlockGeometry
        SetVisualAttributes(WithTile: WithTile, IsRetired: IsRetired)
    }
    
    private var OriginalWidth: CGFloat = 1.0
    private var OriginalHeight: CGFloat = 1.0
    private var OriginalDepth: CGFloat = 1.0
    
    /// Create the geometry with default sizes and apply visual attributes.
    /// - Note: The size of the geometry will be 1.0 x 1.0 x 1.0.
    /// - Parameter WithTile: The tile to use to get visual attributes.
    /// - Parameter IsRetired: Determines which set of visual attributes to use.
    public func Create(WithTile: TileDescriptor, IsRetired: Bool)
    {
        Create(Width: 1.0, Height: 1.0, Depth: 1.0, EdgeRadius: 0.0, WithTile: WithTile, IsRetired: IsRetired)
    }
    
    /// Removes the block from the parent node (the scene).
    public func Remove()
    {
        self.removeFromParentNode()
    }
    
    /// Holds the X coordinate. Setting this value update's the node's position.
    private var _X: CGFloat = 0.0
    {
        didSet
        {
            var Position = self.position
            Position.x = Float(_X)
            self.position = Position
        }
    }
    /// Get or set the X position of the block.
    public var X: CGFloat
    {
        get
        {
            return _X
        }
        set
        {
            _X = newValue
        }
    }
    
    /// Holds the Y coordinate. Setting this value update's the node's position.
    private var _Y: CGFloat = 0.0
    {
        didSet
        {
            var Position = self.position
            Position.y = Float(_Y)
            self.position = Position
        }
    }
    /// Get or set the Y position of the block.
    public var Y: CGFloat
    {
        get
        {
            return _Y
        }
        set
        {
            _Y = newValue
        }
    }
    
    /// Holds the Z coordinate. Setting this value update's the node's position.
    private var _Z: CGFloat = 0.0
    {
        didSet
        {
            var Position = self.position
            Position.z = Float(_Z)
            self.position = Position
        }
    }
    /// Get or set the Z position of the block.
    public var Z: CGFloat
    {
        get
        {
            return _Z
        }
        set
        {
            _Z = newValue
        }
    }
    
    /// Hold the marked flag.
    private var _Marked: Bool = false
    /// Get or set the marked flag. Used to removed unused blocks.
    public var Marked: Bool
    {
        get
        {
            return _Marked
        }
        set
        {
            _Marked = newValue
        }
    }
}
