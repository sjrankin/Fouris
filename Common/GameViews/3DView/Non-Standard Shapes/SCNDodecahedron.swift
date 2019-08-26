//
//  SCNDodecahedron.swift
//  Fouris
//
//  Created by Stuart Rankin on 7/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

//https://medium.com/@zxlee618/custom-geometry-in-scenekit-f91464297fd1
class SCNDodecahedron: SCNNode
{
    override init()
    {
        super.init()
        self.Radius = 1.0
        CommonInitialization()
    }
    
    init(Radius: CGFloat)
    {
        super.init()
        self.Radius = Radius
        CommonInitialization()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        CommonInitialization()
    }
    
    func CommonInitialization()
    {
        self.geometry = SCNDodecahedron.Geometry(Radius: _Radius)
    }
    
    private func UpdateDimensions(Radius: CGFloat)
    {
        CommonInitialization()
    }
    
    private var _Radius: CGFloat = 1.0
    {
        didSet
        {
            UpdateDimensions(Radius: _Radius)
        }
    }
    public var Radius: CGFloat
    {
        get
        {
            return _Radius
        }
        set
        {
            _Radius = newValue
        }
    }
    
    private static var Vertices = [SCNVector3]()
    
    private static let OriginalVertices: [SCNVector3] =
        [
            SCNVector3(0.0, 1.0, 0.0),
            SCNVector3(-0.5, 0.0, 0.5),
            SCNVector3(0.5, 0.0, 0.5),
            SCNVector3(0.5, 0.0, -0.5),
            SCNVector3(-0.5, 0.0, -0.5),
            SCNVector3(0.0, -1.0, 0.0)
    ]
    
    private static let Indices: [UInt16] =
        [
            0, 1, 2,
            2, 3, 0,
            3, 4, 0,
            4, 1, 0,
            1, 5, 2,
            2, 5, 3,
            3, 5, 4,
            4, 5, 1
    ]
    
    private static var GeoSource: SCNGeometrySource!
    private static var GeoElement: SCNGeometryElement!
    
    public static func Geometry(Radius: CGFloat) -> SCNGeometry
    {
        Vertices.removeAll()
        let OperationalRadius = Radius
        for Vertex in OriginalVertices
        {
            //let NewVertex = SCNVector3(Vertex.x * OperationalBase, Vertex.y * OperationalHeight, Vertex.z * OperationalBase)
            //Vertices.append(NewVertex)
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
        return SCNGeometry(sources: [GeoSource, UVPoints], elements: [GeoElement])
    }
}

