//
//  SerializerNode.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Encapsulates one node of a deserialized XML fragment.
class SerializerNode
{
    /// Default initializer.
    init()
    {
        Title = ""
        AttributeList = [(String, String)]()
        Children = [SerializerNode]()
        Contents = ""
    }
    
    /// Initializer.
    ///
    /// - Parameter NodeTitle: Title of the node.
    init(NodeTitle: String)
    {
        Title = NodeTitle
        AttributeList = [(String, String)]()
        Children = [SerializerNode]()
        Contents = ""
    }
    
    /// Return the value for the specified attribute.
    ///
    /// - Parameter For: The name of the attribute whose value will be returned. Case sensitive.
    /// - Returns: The value of the attributed named in `For` on success, nil if not found.
    func AttributeValue(For: String) -> String?
    {
        for (Name, Value) in AttributeList
        {
            if For == Name
            {
                return Value
            }
        }
        return nil
    }
    
    /// The node title.
    var Title: String = ""
    
    /// The list of attributes in the node.
    var AttributeList = [(String, String)]()
    
    /// The list of children in the node.
    var Children = [SerializerNode]()
    
    /// The contents of the node.
    var Contents: String = ""
}

