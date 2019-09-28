//
//  XMLNode+Other.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Ancillary and static functions for XMLNode.
extension XMLNode
{
    /// Return the value of the specified attribute.
    /// - Parameter Name: The name of the attribute whose value will be returned. Case sensitive.
    /// - Parameter InNode: The node whose attributes will be searched.
    /// - Returns: The value of the attribute with the specified name on success, nil if not found.
    public static func GetAttributeNamed(_ Name: String, InNode: XMLNode) -> String?
    {
        for Attribute in InNode.Attributes
        {
            if Attribute.Key == Name
            {
                return Attribute.Value
            }
        }
        return nil
    }
    
    /// Delete a child node in the passed parent node.
    /// - Parameter ChildNode: The node to delete.
    /// - Parameter InParent: The parent node whose child node will be deleted.
    /// - Returns: True on success, nil if the parent does not have any children.
    public static func DeleteChildNode(_ ChildNode: XMLNode, InParent: XMLNode) -> Bool
    {
        if InParent.Children.count < 1
        {
            return false
        }
        InParent.Children = InParent.Children.filter({$0.ID != ChildNode.ID})
        return true
    }
}
