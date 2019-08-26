//
//  SCNTetrahedron.swift
//  Fouris
//
//  Created by Stuart Rankin on 7/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

//https://medium.com/@zxlee618/custom-geometry-in-scenekit-f91464297fd1
class SCNTetrahedron: SCNNode
{
    override init()
    {
        super.init()
        self.BaseLength = 1.0
        self.Height = 1.0
        CommonInitialization()
    }
    
    init(BaseLength: CGFloat, Height: CGFloat, Sierpinski: Int = 1)
    {
        super.init()
        self.BaseLength = BaseLength
        self.Height = Height
        CommonInitialization()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        CommonInitialization()
    }
    
    func CommonInitialization()
    {
        self.geometry = SCNTetrahedron.Geometry(BaseLength: _BaseLength, Height: _Height, Sierpinski: _Sierpinski)
    }
    
    private func UpdateDimensions(NewBase: CGFloat, NewHeight: CGFloat, NewSierpinski: Int)
    {
        CommonInitialization()
    }
    
    private var _Sierpinski: Int = 1
    {
        didSet
        {
            UpdateDimensions(NewBase: _BaseLength, NewHeight: _Height, NewSierpinski: _Sierpinski)
        }
    }
    public var Sierpinski: Int
    {
        get
        {
            return _Sierpinski
        }
        set
        {
            _Sierpinski = newValue
        }
    }
    
    private var _Height: CGFloat = 1.0
    {
        didSet
        {
            UpdateDimensions(NewBase: _BaseLength, NewHeight: _Height, NewSierpinski: _Sierpinski)
        }
    }
    public var Height: CGFloat
    {
        get
        {
            return _Height
        }
        set
        {
            _Height = newValue
        }
    }
    
    private var _BaseLength: CGFloat = 1.0
    {
        didSet
        {
            UpdateDimensions(NewBase: _BaseLength, NewHeight: _Height, NewSierpinski: _Sierpinski)
        }
    }
    public var BaseLength: CGFloat
    {
        get
        {
            return _BaseLength
        }
        set
        {
            _BaseLength = newValue
        }
    }
    
    private static var Vertices = [SCNVector3]()
    
    private static let OriginalVertices: [SCNVector3] =
        [
            SCNVector3(0.5, 1.0, 0.0),
            SCNVector3(-0.5, 0.0, 0.5),
            SCNVector3(0.5, 0.0, 0.5),
            SCNVector3(0.0, 0.0, -0.5)
    ]
    
    private static let Indices: [UInt16] =
        [
            0, 1, 2,
            2, 3, 0,
            3, 1, 0,
            3, 2, 1
    ]
    
    private static var GeoSource: SCNGeometrySource!
    private static var GeoElement: SCNGeometryElement!
    
    //https://stackoverflow.com/questions/48728060/custom-scngeometry-not-displaying-diffuse-contents-as-texture?rq=1
    public static func Geometry(BaseLength: CGFloat, Height: CGFloat, Sierpinski: Int = 1) -> SCNGeometry
    {
        Vertices.removeAll()
        let OperationalHeight = Height
        let OperationalBase = BaseLength
        for Vertex in OriginalVertices
        {
            let NewVertex = SCNVector3(Vertex.x * Float(OperationalBase),
                                       Vertex.y * Float(OperationalHeight),
                                       Vertex.z * Float(OperationalBase))
            Vertices.append(NewVertex)
        }
        GeoSource = SCNGeometrySource(vertices: Vertices)
        GeoElement = SCNGeometryElement(indices: Indices, primitiveType: .triangles)
        let TextureCoordinates =
            [
                CGPoint(x: 0, y: 0),
                CGPoint(x: 1, y: 0),
                CGPoint(x: 0, y: 1),
                CGPoint(x: 1, y: 1)
        ]
        let UVPoints = SCNGeometrySource(textureCoordinates: TextureCoordinates)
        let Geo = SCNGeometry(sources: [GeoSource, UVPoints], elements: [GeoElement])
        return Geo
    }
}

