//
//  XMLTreeTraversalProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for traversing an in-memory XML document.
protocol XMLTreeTraversalProtocol
{
    /// Called when the traversal code reaches a given node.
    /// - Parameter Node: The node the traversal code reached.
    func AtNode(Node: XMLNode)
}
