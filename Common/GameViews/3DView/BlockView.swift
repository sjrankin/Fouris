//
//  BlockView.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/7/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// This class is designed to show one block of a piece for the sole purpose of setting themes and showing examples. It is not
/// used directly in game play. To use this class, the caller must call `Initialize` first. And, if the caller didn't set the
/// `AndStart` parameter to true, `Start` must be called as well.
@IBDesignable class BlockView: SCNView
{
    /// Required by framework.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Make sure things are initialized if we're running in the Interface Builder.
    override func prepareForInterfaceBuilder()
    {
        Initialize()
        Start()
    }
    
    /// Initialize the block view.
    /// - Parameter AndStart: If true, the block view is started as well as being initialized. If false, the caller must
    ///                       call `Start` separately to see the view.
    public func Initialize(AndStart: Bool = true)
    {
        SetBorder()
        ViewScene = SCNScene()
        self.scene = ViewScene
        self.clipsToBounds = true
        //self.allowsCameraControl = true
        self.antialiasingMode = .multisampling4X
        AddCameraAndLight()
        UpdateViewNode()
        
        #if false
        CameraObserver = self.observe(\.pointOfView?.position, options: [.new])
        {
            (Node, Change) in
            OperationQueue.current?.addOperation
                {
                    let DPos = Convert.ConvertToString(Node.pointOfView!.position, AddLabels: true, AddParentheses: true)
                    let DOri = Convert.ConvertToString(Node.pointOfView!.orientation, AddLabels: true, AddParentheses: true)
                    print("Camera position: \(DPos)")
                    print("Camera orientation: \(DOri)")
            }
        }
        #endif
        
        if AndStart
        {
            Start()
        }
    }
    
    /// The view scene.
    var ViewScene: SCNScene!
    
    /// Starts the block view. All current properties are used to draw th view.
    public func Start()
    {
        UpdateViewNode()
    }
    
    /// Used by the value observer for the user-controllable camera.
    var CameraObserver: NSKeyValueObservation? = nil
    
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
    
    // MARK: Debug attributes.
    
    /// Holds the show statistics flag.
    private var _ShowStatistics: Bool = false
    {
        didSet
        {
            self.showsStatistics = _ShowStatistics
        }
    }
    /// Get or set the show statistics flag. Should always be false for production code.
    @IBInspectable public var ShowStatistics: Bool
        {
        get
        {
            return _ShowStatistics
        }
        set
        {
            _ShowStatistics = newValue
        }
    }
    
    // MARK: Border attributes.
    
    /// Set the border for the view.
    private func SetBorder()
    {
        self.layer.borderColor = _BorderColor.cgColor
        self.layer.borderWidth = _BorderWidth
        self.layer.cornerRadius = _CornerRadius
    }
    
    /// Holds the border color.
    private var _BorderColor: UIColor = UIColor.black
    {
        didSet
        {
            self.layer.borderColor = _BorderColor.cgColor
        }
    }
    /// Get or set the color to use to draw the border.
    @IBInspectable var BorderColor: UIColor
        {
        get
        {
            return _BorderColor
        }
        set
        {
            _BorderColor = newValue
        }
    }
    
    /// Holds the width of the border.
    private var _BorderWidth: CGFloat = 0.5
    {
        didSet
        {
            self.layer.borderWidth = _BorderWidth
        }
    }
    /// Get or set the width of the view's border.
    @IBInspectable var BorderWidth: CGFloat
        {
        get
        {
            return _BorderWidth
        }
        set
        {
            _BorderWidth = newValue
        }
    }
    
    /// Holds the corner radius of the border.
    private var _CornerRadius: CGFloat = 5.0
    {
        didSet
        {
            self.layer.cornerRadius = _CornerRadius
        }
    }
    /// Get or set the corner radius of the border.
    @IBInspectable var CornerRadius: CGFloat
        {
        get
        {
            return _CornerRadius
        }
        set
        {
            _CornerRadius = newValue
        }
    }
    
    // MARK: View attributes.
    
    /// Convenience function to set the sizes of all three dimensions of the block in one call.
    /// - Parameter X: Size of the block on the X axis.
    /// - Parameter Y: Size of the block on the Y axis.
    /// - Parameter Z: Size of the block on the Z axis.
    public func SetBlockSizes(X: CGFloat, Y: CGFloat, Z: CGFloat)
    {
        _BlockXSize = X
        _BlockYSize = Y
        _BlockZSize = Z
    }
    
    /// Holds the X-axis size.
    private var _BlockXSize: CGFloat = 32.0
    {
        didSet
        {
            UpdateViewNode()
        }
    }
    /// Get or set the block size along the X-axis.
    @IBInspectable public var BlockXSize: CGFloat
        {
        get
        {
            return _BlockXSize
        }
        set
        {
            _BlockXSize = newValue
        }
    }
    
    /// Holds the Y-axis size.
    private var _BlockYSize: CGFloat = 32.0
    {
        didSet
        {
            UpdateViewNode()
        }
    }
    /// Get or set the block size along the Y-axis.
    @IBInspectable public var BlockYSize: CGFloat
        {
        get
        {
            return _BlockYSize
        }
        set
        {
            _BlockYSize = newValue
        }
    }
    
    /// Holds the Z-axis size.
    private var _BlockZSize: CGFloat = 32.0
    {
        didSet
        {
            UpdateViewNode()
        }
    }
    /// Get or set the block size along the Z-axis.
    @IBInspectable public var BlockZSize: CGFloat
        {
        get
        {
            return _BlockZSize
        }
        set
        {
            _BlockZSize = newValue
        }
    }
    
    /// Holds the use texture flag.
    private var _UseTexture: Bool = false
    {
        didSet
        {
            UpdateViewNode()
        }
    }
    /// Get or set the use texture flag.
    /// - Note: The caller should set the Texture property before setting this property to true.
    @IBInspectable public var UseTexture: Bool
        {
        get
        {
            return _UseTexture
        }
        set
        {
            _UseTexture = newValue
        }
    }
    
    /// Holds the texture.
    private var _Texture: UIImage? = nil
    {
        didSet
        {
            if _UseTexture
            {
                UpdateViewNode()
            }
        }
    }
    /// Get or set the image to use as the texture.
    /// - Note: This property is ignored if `UseTexture` is false. However, set this property first, then `UseTexture` to true
    ///         when setting textures.
    @IBInspectable public var Texture: UIImage?
        {
        get
        {
            return _Texture
        }
        set
        {
            _Texture = newValue
        }
    }
    
    /// Holds the diffuse color.
    private var _DiffuseColor: UIColor = UIColor.red
    {
        didSet
        {
            if !_UseTexture
            {
                ViewNode?.geometry?.materials.first?.diffuse.contents = _DiffuseColor
                //UpdateViewNode()
            }
        }
    }
    /// Get or set the diffuse color of the block.
    /// - Note: Ignored if `UseTexture` is true.
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
    
    /// Holds the specular color.
    private var _SpecularColor: UIColor = UIColor.white
    {
        didSet
        {
            if !_UseTexture
            {
                ViewNode?.geometry?.materials.first?.specular.contents = _SpecularColor
//                UpdateViewNode()
            }
        }
    }
    /// Holds the specular color of the block.
    /// - Note: Ignored if `UseTexture` is true.
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
    
    /// Holds the view's background color.
    private var _ViewBackgroundColor: UIColor = UIColor.black
    {
        didSet
        {
            self.backgroundColor = _ViewBackgroundColor
        }
    }
    /// Get or set the background color of the view.
    @IBInspectable public var ViewBackgroundColor: UIColor
        {
        get
        {
            return _ViewBackgroundColor
        }
        set
        {
            _ViewBackgroundColor = newValue
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
                UpdateViewNode()
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
    
    /// Holds the current shape/geometry of the node.
    private var _Shape: TileShapes3D = .Cubic
    {
        didSet
        {
            ViewNode?.removeAllActions()
            UpdateViewNode()
        }
    }
    /// Get or set the shape/geometry of the block.
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
    
    /// Start rotations. Blocks rotate on all axes (however, see Notes) over a 1 second period.
    /// - Note:
    ///   - Depending on the shape of the block, not all axes are rotated.
    ///   - However, if textures are being used, all axes are rotated.
    public func StartRotations()
    {
        var BlockRotate: SCNAction!
        if _Shape == .Spherical && !UseTexture
        {
            return
        }
        if _Shape == .Torus || _Shape == .Tube || _Shape == .Capsule
        {
            if UseTexture
            {
                BlockRotate = SCNAction.rotateBy(x: 1.0, y: 1.0, z: 1.0, duration: 1.0)
            }
            else
            {
                BlockRotate = SCNAction.rotateBy(x: 1.0, y: 0.0, z: 0.0, duration: 1.0)
            }
        }
        else
        {
            BlockRotate = SCNAction.rotateBy(x: 1.0, y: 1.0, z: 1.0, duration: 1.0)
        }
        let Repeat = SCNAction.repeatForever(BlockRotate)
        ViewNode?.runAction(Repeat)
    }
    
    /// Stop all rotations.
    public func StopRotations()
    {
        ViewNode?.removeAllActions()
    }
    
    // MARK: Drawing functions.
    
    /// Create the block with the properties previously specified.
    /// - Note: If the `UseTexture` flag is true but no texture has been specified, no action is taken.
    private func UpdateViewNode()
    {
        if _UseTexture && _Texture == nil
        {
            print("UseTexture specified but no texture available.")
            return
        }
        
        ViewNode?.removeFromParentNode()
        let NodeShape = MakeShape(Width: _BlockXSize, Height: _BlockYSize, Depth: _BlockZSize)
        
        ViewNode?.name = "BlockNode"
        if _UseTexture
        {
            NodeShape.materials.first?.diffuse.contents = _Texture!
        }
        else
        {
            NodeShape.materials.first?.diffuse.contents = _DiffuseColor
            NodeShape.materials.first?.specular.contents = _SpecularColor
        }
        ViewNode = SCNNode(geometry: NodeShape)
        ViewNode?.position = SCNVector3(0.0, 0.0, 0.0)
        #if false
        if _Shape == .Torus
        {
            ViewNode?.rotation = SCNVector4(0.0, 0.0, CGFloat.pi, 0.0)
        }
        #endif
        self.scene?.rootNode.addChildNode(ViewNode!)
    }
    
    /// Create the geometry for the block.
    /// - Parameter Width: The width of the block.
    /// - Parameter Height: The height of the block.
    /// - Parameter Depth: The depth of the block.
    func MakeShape(Width: CGFloat, Height: CGFloat, Depth: CGFloat) -> SCNGeometry
    {
        var Geometry: SCNGeometry!
        switch _Shape
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
                Geometry = SCNnGon.Geometry(VertexCount: 6, Radius: Width, Depth: Depth * 0.5)
        }
        return Geometry
    }
    
    private var ViewNode: SCNNode? = nil
}
