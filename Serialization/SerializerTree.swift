//
//  SerializerTree.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

class SerializerTree
{
    /// Default initializer.
    init()
    {
        _Root = SerializerNode(NodeTitle: "Root")
    }
    
    /// Holds the root of the deserialized XML fragment.
    private var _Root: SerializerNode!
    /// Get the root of the deserialized XML fragment.
    public var Root: SerializerNode
    {
        get
        {
            return _Root
        }
    }
}
