//
//  Serializable.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for the XML fragment serializer.
protocol Serializable: class
{
    /// Called by the deserializer once for each property that it deserialized.
    ///
    /// - Parameters:
    ///   - Key: Name of the key to populate. This is also the name of the field that was serialized.
    ///   - Value: Value of the key in string format. It is the responsibility of the callee to properly
    ///            convert the type as needed.
    func Populate(Key: String, Value: String)
}
