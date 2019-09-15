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

protocol FlyingProtocol: class
{
    func MotionCompleted(Node: SCNNode, Replace: Bool)
}
