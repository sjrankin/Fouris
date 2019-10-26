//
//  XMLDeserializeProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Deserialization protocol for XML documents.
protocol XMLDeserializeProtocol
{
    /// Deserialize a node found in an XML document.
    /// - Parameter Node: The node to deserialize.
    func DeserializedNode(_ Node: XMLNode)
}
