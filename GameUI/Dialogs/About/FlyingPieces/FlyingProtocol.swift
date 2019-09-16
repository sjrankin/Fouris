//
//  FlyingProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/15/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Protocol for communicating from a flying piece to its parent scene.
protocol FlyingProtocol: class
{
    /// A flying piece completed its motion (and any terminal effects).
    /// - Parameter Node: The node that completed its motion.
    /// - Parameter Replace: Boolean that determines if the node should be replaced by a new node.
    func MotionCompleted(Node: SCNNode, Replace: Bool)
}
