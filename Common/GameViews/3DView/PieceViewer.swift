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
    var PieceScene: SCNScene!
    
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
        self.antialiasingMode = .multisampling2X
        self.debugOptions = [SCNDebugOptions.showSkeletons]
        self.allowsCameraControl = true
        AddCameraAndLight()
    }
    
    /// Adds the camera and light to the scene.
    func AddCameraAndLight()
    {
        if InfrastructureAdded
        {
            return
        }
        InfrastructureAdded = true
        
        _Light = SCNLight()
        _Light.color = UIColor.white.cgColor
        _Light.type = .omni
        let LightNode = SCNNode()
        LightNode.light = _Light
        LightNode.position = SCNVector3(-10.0, 10.0, 30.0)
        self.scene?.rootNode.addChildNode(LightNode)
        
        _Camera = SCNCamera()
        _Camera.fieldOfView = 92.5
        let CameraNode = SCNNode()
        CameraNode.camera = _Camera
        CameraNode.position = SCNVector3(0.0, 0.0, 25.0)
        CameraNode.orientation = SCNVector4(0.0, 0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(CameraNode)
    }
    
    /// The light.
    private var _Light: SCNLight!
    /// The camera.
    private var _Camera: SCNCamera!
        /// Holds the infrastructure (camera and light) added flag.
    private var InfrastructureAdded: Bool = false
    
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
    
    func GetExtents() -> (Int, Int)
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
            let NodeShape = SCNBox(width: UnitSize, height: UnitSize, length: UnitSize, chamferRadius: 0.0)
            NodeShape.materials.first?.diffuse.contents = _DiffuseColor
            NodeShape.materials.first?.specular.contents = _SpecularColor
            let Node = SCNNode(geometry: NodeShape)
            let XPos: CGFloat = CGFloat(X) * UnitSize
            let YPos: CGFloat = CGFloat(Y) * UnitSize
            Node.position = SCNVector3(XPos, YPos, 0.0)
            PieceNode?.addChildNode(Node)
        }
        self.scene?.rootNode.addChildNode(PieceNode!)
    }
    
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
    
    public func ResetRotations()
    {
        PieceNode?.removeAllActions()
        let RotatePiece = SCNAction.rotateTo(x: 0.0, y: 0.0, z: 0.0, duration: 0.001)
        PieceNode?.runAction(RotatePiece)
    }
    
    public func StopRotation()
    {
        
    }
    
    // MARK: Interface builder-related functions.
    
    private var _AutoAdjustBlockSize: Bool = true
    {
        didSet
        {
            DrawPiece()
        }
    }
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
    
    private var _BlockSize: CGFloat = 20.0
    {
        didSet
        {
            DrawPiece()
        }
    }
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
    
    private var _SpecularColor: UIColor = UIColor.white
    {
        didSet
        {
            DrawPiece()
        }
    }
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
    
    private var _DiffuseColor: UIColor = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
    {
        didSet
        {
            DrawPiece()
        }
    }
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
    
    private var _Shape: TileShapes3D = .Cubic
    {
        didSet
        {
            DrawPiece()
        }
    }
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
    
    // MARK: Visual piece creation.
    
    var PieceNode: SCNNode? = nil
    
    func Clear()
    {
        for BlockNode in PieceNode!.childNodes
        {
            BlockNode.removeFromParentNode()
        }
        BlockList.removeAll()
        DrawPiece()
    }
    
    private var BlockList = [(Int, Int)]()
    
    func DoAddBlock(_ X: Int, _ Y: Int)
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
    
    func DoRemoveBlock(_ X: Int, _ Y: Int)
    {
        BlockList = BlockList.filter({!($0.0 == X && $0.1 == Y)})
    }
    
    func AddBlockAt(_ Location: BlockCoordinates<Int>)
    {
        DoAddBlock(Location.X, Location.Y)
    }
    
    func AddBlockAt(_ Location: LogicalLocation)
    {
        DoAddBlock(Location.X, Location.Y)
    }
    
    func AddBlockAt(_ X: Int, _ Y: Int)
    {
        DoAddBlock(X, Y)
    }
    
    func RemoveBlockAt(_ Location: BlockCoordinates<Int>)
    {
        DoRemoveBlock(Location.X, Location.Y)
    }
    
    func RemoveBlockAt(_ Location: LogicalLocation)
    {
        DoRemoveBlock(Location.X, Location.Y)
    }
    
    func AddPiece(_ ThePiece: PieceDefinition)
    {
        for Location in ThePiece.LogicalLocations
        {
            DoAddBlock(Location.X, Location.Y)
        }
    }
    
    func AddPiece(_ ThePiece: Piece)
    {
        for SomeBlock in ThePiece.Components
        {
            DoAddBlock(SomeBlock.X, SomeBlock.Y)
        }
    }
}
