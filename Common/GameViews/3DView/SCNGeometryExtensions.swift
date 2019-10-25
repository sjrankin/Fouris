//
//  SCNGeometryExtensions.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/12/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// SCNGeometry extensions.
extension SCNGeometry
{
    /// Create SCNGeometry in the shape of a line between two vectors.
    /// - Note: See [Drawing a line between two points using SceneKit](https://stackoverflow.com/questions/21886224/drawing-a-line-between-two-points-using-scenekit)
    /// - Parameter From: Starting vector.
    /// - Parameter To: Ending vector.
    /// - Returns: An SCNGeometry instance as a line between the two specified points.
    class func Line(From Vector1: SCNVector3, To Vector2: SCNVector3) -> SCNGeometry
    {
        let Indices: [Int32] = [0, 1]
        let Source = SCNGeometrySource(vertices: [Vector1, Vector2])
        let Element = SCNGeometryElement(indices: Indices, primitiveType: .line)
        return SCNGeometry(sources: [Source], elements: [Element])
    }
}
