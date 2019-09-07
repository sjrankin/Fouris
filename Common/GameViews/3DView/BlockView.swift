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

class BlockView: SCNView
{
    /// Required by framework.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.allowsCameraControl = true
        UpdateViewNode()
    }
    
    override var bounds: CGRect
        {
        didSet
        {
            if bounds.size.width > 0 && bounds.size.height > 0
            {
                print("New bounds: \(bounds)")
                self.layer.borderColor = UIColor.black.cgColor
                IsVisible = true
                AddCameraAndLight()
                UpdateViewNode()
            }
        }
    }
    
    func AddCameraAndLight()
    {
        if InfrastructureAdded
        {
            return
        }
        InfrastructureAdded = true
        
        _Light = SCNLight()
        _Light.color = UIColor.white.cgColor
        _Light.type = .spot
        let LightNode = SCNNode()
        LightNode.light = _Light
        LightNode.position = SCNVector3(1.0, 1.0, -10.0)
        self.scene?.rootNode.addChildNode(LightNode)
        
        _Camera = SCNCamera()
        _Camera.fieldOfView = 92.5
        let CameraNode = SCNNode()
        CameraNode.camera = _Camera
        CameraNode.position = SCNVector3(0.0, 0.0, -10.0)
        CameraNode.orientation = SCNVector4(0.0, 0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(CameraNode)
        print("Added camera and light.")
    }
    
    private var _Light: SCNLight!
    private var _Camera: SCNCamera!
    
    private var InfrastructureAdded: Bool = false
    
    private var IsVisible: Bool = false
    
    private var _UseTexture: Bool = false
    {
        didSet
        {
            UpdateViewNode()
        }
    }
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
    
    private var _DiffuseColor: UIColor = UIColor.red
    {
        didSet
        {
            if !_UseTexture
            {
                UpdateViewNode()
            }
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
    
    private var _SpecularColor: UIColor = UIColor.white
    {
        didSet
        {
            if !_UseTexture
            {
                UpdateViewNode()
            }
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
    
    private var _ViewBackgroundColor: UIColor = UIColor.black
    {
        didSet
        {
            self.backgroundColor = _ViewBackgroundColor
        }
    }
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
    
    private var _Shape: TileShapes3D = .Cubic
    {
        didSet
        {
            UpdateViewNode()
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
    
    private var _Rotations: SCNVector3 = SCNVector3(0.0, 0.0, 0.0)
    {
        didSet
        {
            UpdateViewNode()
        }
    }
    @IBInspectable public var Rotations: SCNVector3
        {
        get
        {
            return _Rotations
        }
        set
        {
            _Rotations = newValue
        }
    }
    
    private func UpdateViewNode()
    {
        if !IsVisible
        {
            return
        }
        if _UseTexture && _Texture == nil
        {
            return
        }
        
        ViewNode?.removeFromParentNode()
        let NodeShape = MakeShape(Width: 32.0, Height: 32.0, Depth: 20.0)
        ViewNode = SCNNode(geometry: NodeShape)
        if _UseTexture
        {
            NodeShape.materials.first?.diffuse.contents = _Texture!
        }
        else
        {
            NodeShape.materials.first?.diffuse.contents = _DiffuseColor
            NodeShape.materials.first?.specular.contents = _SpecularColor
        }
        ViewNode?.position = SCNVector3(0.0, 0.0, 0.0)
        self.scene?.rootNode.addChildNode(ViewNode!)
    }
    
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
        }
        return Geometry
    }
    
    private var ViewNode: SCNNode? = nil
}
