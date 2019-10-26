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

/// Implements a dodecahedron-shaped SCNNode.
/// - Notes: See [Custom Geometry in SceneKit](https://medium.com/@zxlee618/custom-geometry-in-scenekit-f91464297fd1)
class SCNDodecahedron: SCNNode
{
    /// Initializer.
    override init()
    {
        super.init()
        self.Radius = 1.0
        CommonInitialization()
    }
    
    /// Initializer.
    /// - Parameter Radius: Radius of the shape.
    init(Radius: CGFloat)
    {
        super.init()
        self.Radius = Radius
        CommonInitialization()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        CommonInitialization()
    }
    
    /// Initialization common to all initializers.
    private func CommonInitialization()
    {
        self.geometry = SCNDodecahedron.Geometry(Radius: _Radius)
    }
    
    /// Updates the shape with a new radial value.
    /// - Parameter Radius: New radius value.
    private func UpdateDimensions(Radius: CGFloat)
    {
        CommonInitialization()
    }
    
    /// Holds the radius. Updates the shape when changed.
    private var _Radius: CGFloat = 1.0
    {
        didSet
        {
            UpdateDimensions(Radius: _Radius)
        }
    }
    /// Get or set the radial value of the shape. Defaults to 1.0.
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
    
    /// Holds the vertices of the shape.
    private static var Vertices = [SCNVector3]()
    
    /// Holds the original vertices of the shape (with a radius of 1.0).
    private static let OriginalVertices: [SCNVector3] =
        [
            SCNVector3(0.0, 1.0, 0.0),
            SCNVector3(-0.5, 0.0, 0.5),
            SCNVector3(0.5, 0.0, 0.5),
            SCNVector3(0.5, 0.0, -0.5),
            SCNVector3(-0.5, 0.0, -0.5),
            SCNVector3(0.0, -1.0, 0.0)
    ]
    
    /// Holds the indices of the vertices that defines the shape.
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
    
    /// Holds the source geometry.
    private static var GeoSource: SCNGeometrySource!
    /// Holds the geometric element.
    private static var GeoElement: SCNGeometryElement!
    
    /// Returns geometry that defines a dodecahedron.
    /// - Parameter Radius: The size of the dodecahedron.
    /// - Returns: SCNGeometry object with a dodecahedron.
    public static func Geometry(Radius: CGFloat) -> SCNGeometry
    {
        Vertices.removeAll()
        #if false
        let OperationalRadius = Radius
        for Vertex in OriginalVertices
        {
            //let NewVertex = SCNVector3(Vertex.x * OperationalBase, Vertex.y * OperationalHeight, Vertex.z * OperationalBase)
            //Vertices.append(NewVertex)
        }
        #endif
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

