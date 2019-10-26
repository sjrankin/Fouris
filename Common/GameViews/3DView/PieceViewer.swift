//
//  PieceViewer.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Creates and displays game pieces for the purposes of customization and information. Not used in the game itself.
@IBDesignable class PieceViewer: SCNView
{
    /// The scene that is shown in the viewer
    public var PieceScene: SCNScene!
    
    /// Required by framework.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// For use by the Interface Builder.
    override func prepareForInterfaceBuilder()
    {
        Start()
    }
    
    /// Initialize the view.
    /// - Note: The caller must also call `Start` to start the view working.
    public func Initialize()
    {
        let PieceScene = SCNScene()
        self.scene = PieceScene
        self.clipsToBounds = true
        self.antialiasingMode = .multisampling4X
        self.allowsCameraControl = true
        self.debugOptions = [.showWireframe]
        AddCameraAndLight()
    }
    
    /// Adds the camera and light to the scene.
    public func AddCameraAndLight()
    {
        if InfrastructureAdded
        {
            return
        }
        InfrastructureAdded = true
        
        _LightNode = SCNNode()
        _LightNode.light = SCNLight()
        _LightNode.light?.color = UIColor.white.cgColor
        _LightNode.light?.type = .ambient
        _LightNode.position = SCNVector3(-10.0, 10.0, 30.0)
        self.scene?.rootNode.addChildNode(_LightNode)
        
        _Camera = SCNCamera()
        _Camera.fieldOfView = 92.5
        _CameraNode = SCNNode()
        _CameraNode.camera = _Camera
        _CameraNode.position = SCNVector3(0.0, 0.0, 25.0)
        _CameraNode.orientation = SCNVector4(0.0, 0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(_CameraNode)
    }
    
    /// The light.
    private var _LightNode: SCNNode!
    /// The camera.
    private var _Camera: SCNCamera!
    /// The camera node.
    private var _CameraNode: SCNNode!
    /// Holds the infrastructure (camera and light) added flag.
    private var InfrastructureAdded: Bool = false
    
    /// Sets the field of view for the piece.
    /// - Parameter NewFOV: New field of view value.
    public func SetFOV(_ NewFOV: CGFloat)
    {
        _CameraNode.camera?.fieldOfView = NewFOV
        _CameraNode.position = SCNVector3(0.0,0.0,40.0)
        DrawPiece()
    }
    
    /// Starts the view.
    public func Start()
    {
        DrawPiece()
    }
    
    /// If the bounds of the view changes, redraw things.
    override var bounds: CGRect
        {
        didSet
        {
            DrawPiece()
        }
    }
    
    /// Returns the extent of the piece.
    /// - Returns: Tuple with the first term as the horizontal extent, and the second term as the vertical extent.
    public func GetExtents() -> (Int, Int)
    {
        var MinX: Int = 10000
        var MaxX: Int = -10000
        var MinY: Int = 10000
        var MaxY: Int = -10000
        for (X, Y) in BlockList
        {
            if X < MinX
            {
                MinX = X
            }
            if X > MaxX
            {
                MaxX = X
            }
            if Y < MinY
            {
                MinY = Y
            }
            if Y > MaxY
            {
                MaxY = Y
            }
        }
        return ((abs(MaxX - MinX) + 1), (abs(MaxY - MinY) + 1))
    }
    
    /// Draw the piece in the view using current properties.
    public func DrawPiece()
    {
        if PieceNode == nil
        {
            PieceNode = SCNNode()
        }
        else
        {
            for Child in PieceNode!.childNodes
            {
                Child.removeFromParentNode()
            }
            PieceNode?.removeFromParentNode()
        }
        var UnitSize = _BlockSize
        if _AutoAdjustBlockSize
        {
            let (ExX, ExY) = GetExtents()
            let SmallestViewDimension = min(self.bounds.size.width, self.bounds.size.height)
            let GreatestExtent = max(ExX, ExY)
            if GreatestExtent == 0
            {
                UnitSize = _BlockSize
            }
            else
            {
                UnitSize = SmallestViewDimension / CGFloat(GreatestExtent) * 0.9
            }
        }
        for (X, Y) in BlockList
        {
            let NodeShape = CreateGeometry(GeoShape: _Shape, Width: UnitSize, Height: UnitSize, Depth: UnitSize)
            if _EnableTextures && _PieceTexture != nil
            {
                NodeShape.materials.first?.diffuse.contents = _PieceTexture
            }
            else
            {
                NodeShape.materials.first?.diffuse.contents = _DiffuseColor
                NodeShape.materials.first?.specular.contents = _SpecularColor
            }
            let Node = SCNNode(geometry: NodeShape)
            let XPos: CGFloat = CGFloat(X) * UnitSize
            let YPos: CGFloat = CGFloat(Y) * UnitSize
            Node.position = SCNVector3(XPos, YPos, 0.0)
            PieceNode?.addChildNode(Node)
        }
        self.scene?.rootNode.addChildNode(PieceNode!)
    }
    
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
    ///     - **.Hexagon** uses (**Width** * 0.5) as the radial value and (**Depth** * 0.5) as its depth.
    /// - Parameter GeoShape: The geometric shape.
    /// - Parameter Width: Width of the block.
    /// - Parameter Height: Height of the block.
    /// - Parameter Depth: Depth of the block.
    /// - Returns: An SCNGeometry instance with the appropriate shape.
    private func CreateGeometry(GeoShape: TileShapes3D, Width: CGFloat, Height: CGFloat, Depth: CGFloat) -> SCNGeometry
    {
        var Geometry: SCNGeometry!
        switch GeoShape
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
            
            case .Hexagon:
                Geometry = SCNnGon.Geometry(VertexCount: 6, Radius: Width * 0.5, Depth: Depth * 0.5)
        }
        return Geometry!
    }
    
    /// Rotate the game piece on the selected axes.
    /// - Note: If the caller sets all axes to false after rotating the piece, the piece will be frozen in the
    ///         position it was when the call with all `false`s is received. To stop and reset the piece to its
    ///         original orientation, call `ResetRotations`.
    /// - Parameter OnX: Determines if rotation occurs on the X axis.
    /// - Parameter OnY: Determines if rotation occurs on the Y axis.
    /// - Parameter OnZ: Determines if rotation occurs on the Z axis.
    public func RotatePiece(OnX: Bool, OnY: Bool, OnZ: Bool)
    {
        PieceNode?.removeAllActions()
        let RotatePiece = SCNAction.rotateBy(x: OnX ? 1.0 : 0.0,
                                             y: OnY ? 1.0 : 0.0,
                                             z: OnZ ? 1.0 : 0.0,
                                             duration: 1.0)
        let RotateForever = SCNAction.repeatForever(RotatePiece)
        PieceNode?.runAction(RotateForever)
    }
    
    /// Stops all actions (rotations in our case) and resets the piece to its original orientation.
    public func ResetRotations()
    {
        PieceNode?.removeAllActions()
        let RotatePiece = SCNAction.rotateTo(x: 0.0, y: 0.0, z: 0.0, duration: 0.001)
        PieceNode?.runAction(RotatePiece)
    }
    
    /// Stops all rotations. The piece is stopped in its current orientation, whatever that may be.
    public func StopRotation()
    {
        PieceNode?.removeAllActions()
    }
    
    // MARK: - Interface builder-related functions.
    
    /// Holds the the texture to use for each block.
    private var _PieceTexture: UIImage? = nil
    {
        didSet
        {
            DrawPiece()
        }
    }
    /// Get or set the texture to use for each block. If nil, colors are used instead.
    @IBInspectable public var PieceTexture: UIImage?
        {
        get
        {
            return _PieceTexture
        }
        set
        {
            _PieceTexture = newValue
        }
    }
    
    /// Holds the show wire frame flag.
    private var _ShowWireFrame: Bool = true
    {
        didSet
        {
            if _ShowWireFrame
            {
                self.debugOptions = [.showWireframe]
            }
            else
            {
                self.debugOptions = []
            }
        }
    }
    /// Get or set the show wire frame flag.
    @IBInspectable public var ShowWireFrame: Bool
        {
        get
        {
            return _ShowWireFrame
        }
        set
        {
            _ShowWireFrame = newValue
        }
    }
    
    /// Holds the auto adjust block size flag.
    private var _AutoAdjustBlockSize: Bool = true
    {
        didSet
        {
            DrawPiece()
        }
    }
    /// Get or set the auto adjust block size flag.
    @IBInspectable public var AutoAdjustBlockSize: Bool
        {
        get
        {
            return _AutoAdjustBlockSize
        }
        set
        {
            _AutoAdjustBlockSize = newValue
        }
    }
    
    /// Holds the block size.
    private var _BlockSize: CGFloat = 20.0
    {
        didSet
        {
            DrawPiece()
        }
    }
    /// Get or set the block size.
    @IBInspectable public var BlockSize: CGFloat
        {
        get
        {
            return _BlockSize
        }
        set
        {
            _BlockSize = newValue
        }
    }
    
    /// Holds the specular color.
    private var _SpecularColor: UIColor = UIColor.white
    {
        didSet
        {
            DrawPiece()
        }
    }
    /// Get or set the specular color.
    @IBInspectable public var SpecularColor: UIColor
        {
        get
        {
            return _SpecularColor
        }
        set
        {
            _SpecularColor = newValue
        }
    }
    
    /// Holds the diffuse color.
    private var _DiffuseColor: UIColor = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
    {
        didSet
        {
            DrawPiece()
        }
    }
    /// Get or set the diffuse color.
    @IBInspectable public var DiffuseColor: UIColor
        {
        get
        {
            return _DiffuseColor
        }
        set
        {
            _DiffuseColor = newValue
        }
    }
    
    /// Holds the shape of each block.
    private var _Shape: TileShapes3D = .Cubic
    {
        didSet
        {
            DrawPiece()
        }
    }
    /// Get or set the shape for each block.
    public var Shape: TileShapes3D
    {
        get
        {
            return _Shape
        }
        set
        {
            _Shape = newValue
        }
    }
    
    /// Holds the name of the shape.
    private var _ShapeName: String = "Cubic"
    {
        didSet
        {
            if let NewShape = TileShapes3D(rawValue: _ShapeName)
            {
                Shape = NewShape
                DrawPiece()
            }
        }
    }
    /// Get or set the shape name.
    /// - Note: Due to the way Swift interacts with Objective-C runtimes and the Interface Builder, we can't use enums
    ///         for `@IBInspectable` properties. To get around that, the caller can set this property to a string value.
    ///         If the string value is recognized as one of the raw values for the `TileShapes3D` enum, it will be converted
    ///         and the shape will change as appropriate. If the string contains an unrecognizable value, no change will occur.
    @IBInspectable public var ShapeName: String
        {
        get
        {
            return _ShapeName
        }
        set
        {
            _ShapeName = newValue
        }
    }
    
    /// Holds the enable textures flag.
    private var _EnableTextures: Bool = false
    {
        didSet
        {
            if _PieceTexture != nil
            {
                DrawPiece()
            }
        }
    }
    /// Get or set the enable textures flag.
    @IBInspectable public var EnableTextures: Bool
        {
        get
        {
            return _EnableTextures
        }
        set
        {
            _EnableTextures = newValue
        }
    }
    
    // MARK: - Visual piece creation.
    
    /// Node that holds the blocks that make up the piece.
    public var PieceNode: SCNNode? = nil
    
    /// Removes all blocks from the piece to view.
    public func Clear()
    {
        for BlockNode in PieceNode!.childNodes
        {
            BlockNode.removeFromParentNode()
        }
        BlockList.removeAll()
        DrawPiece()
    }
    
    /// Holds the positions of each block in the piece.
    private var BlockList = [(Int, Int)]()
    
    /// Add a block at the specified coordinate. If a block is already in that coordinate, no action is taken.
    /// - Parameter X: Horizontal coordinate.
    /// - Parameter Y: Vertical coordinate.
    public func DoAddBlock(_ X: Int, _ Y: Int)
    {
        for (AtX, AtY) in BlockList
        {
            if AtX == X && AtY == Y
            {
                return
            }
        }
        BlockList.append((X, Y))
        DrawPiece()
    }
    
    /// Remove the block from the piece at the specified coordinate. If there is no block at that location,
    /// no action is taken.
    /// - Parameter X: Horizontal coordinate.
    /// - Parameter Y: Vertical coordinate.
    public func DoRemoveBlock(_ X: Int, _ Y: Int)
    {
        BlockList = BlockList.filter({!($0.0 == X && $0.1 == Y)})
        DrawPiece()
    }
    
    /// Add a block at the specified coordinate.
    /// - Parameter Location: Blook coordinate class.
    public func AddBlockAt(_ Location: BlockCoordinates<Int>)
    {
        DoAddBlock(Location.X, Location.Y)
    }
    
    /// Add a block at the specified coordinate.
    /// - Parameter Location: Block logical location.
    public func AddBlockAt(_ Location: PieceBlockLocation)
    {
        DoAddBlock(Location.Coordinates.X!, Location.Coordinates.Y!)
    }
    
    /// Add a block at the specified coordinate.
    /// - Parameter X: Horizontal coordinate.
    /// - Parameter Y: Vertical coordinate.
    public func AddBlockAt(_ X: Int, _ Y: Int)
    {
        DoAddBlock(X, Y)
    }
    
    /// Remove a block from the specified coordinate.
    /// - Parameter Location: The coordinate of the block to remove.
    public func RemoveBlockAt(_ Location: BlockCoordinates<Int>)
    {
        DoRemoveBlock(Location.X, Location.Y)
    }
    
    /// Remove a block from the specified coordinate.
    /// - Parameter Location: The logical location of the block to remove.
    public func RemoveBlockAt(_ Location: PieceBlockLocation)
    {
        DoRemoveBlock(Location.Coordinates.X!, Location.Coordinates.Y!)
    }
    
    /// Add a piece to display in the view.
    /// - Note: Existing blocks will be removed.
    /// - Parameter ThePiece: A piece definition that will be displayed.
    public func AddPiece(_ ThePiece: PieceDefinition)
    {
        BlockList.removeAll()
        for Location in ThePiece.Locations
        {
            DoAddBlock(Location.Coordinates.X!, Location.Coordinates.Y!)
        }
    }
    
    /// Add a piece to display in the view.
    /// - Note: Existing blocks will be removed.
    /// - Parameter ThePiece: A piece that will be displayed. This piece will most likely be an ephemeral piece,
    ///                       not a piece in the game.
    public func AddPiece(_ ThePiece: Piece)
    {
        BlockList.removeAll()
        for SomeBlock in ThePiece.Components
        {
            DoAddBlock(SomeBlock.X, SomeBlock.Y)
        }
    }
}
