//
//  +GameMessages.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/20/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension View3D
{
    public func PlotText(_ TextNode: SCNGameText)
    {
        self.scene?.rootNode.addChildNode(TextNode)
    }
}
