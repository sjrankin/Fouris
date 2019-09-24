//
//  CustomStringConvertibleExtensions.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/24/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// This file contains extensions for classes that implement CustomStringConvertible in strange, unexpected ways, or don't
/// implement it at all. The extensions are needed by **Serializer** to ensure proper serialization and deserialization.

/// Extension to ensure `SCNVector3` can be serialized to a string of three, comma-delimited values.
extension SCNVector3: CustomStringConvertible
{
    /// Returns a string description of the instance SCNVector3 as three, comma-delimited values.
    public var description: String
    {
        return "\(x),\(y),\(z)"
    }
}

/// Extension to ensure `SCNVector4` can be serialized to a string of four, comma-delimited values.
extension SCNVector4: CustomStringConvertible
{
    /// Returns a string description of the instance SCNVector4 as four, comma-delimited values.
    public var description: String
    {
        return "\(x),\(y),\(z),\(w)"
    }
}
