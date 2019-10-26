//
//  XMLNode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Implements an XML node for an XML document.
class XMLNode: CustomStringConvertible
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer.
    /// - Parameter NodeName: Name associated with the node.
    /// - Parameter TheNodeType: The type of node.
    init(_ NodeName: String, _ TheNodeType: XMLNodeTypes)
    {
        _Name = NodeName
        NodeType = TheNodeType
    }
    
    /// Initializer.
    /// - Parameter NodeName: Name associated with the node.
    /// - Parameter NodeValue: The value associated with the node.
    /// - Parameter TheNodeType: The type of node.
    init(_ NodeName: String, _ NodeValue: String, _ TheNodeType: XMLNodeTypes)
    {
        _Name = NodeName
        _Value = NodeValue
        NodeType = TheNodeType
    }
    
    /// Holds the node's ID.
    private var _ID: UUID = UUID()
    /// Get the node's ID.
    public var ID: UUID
    {
        get
        {
            return _ID
        }
    }
    
    // MARK: Node functions and properties.
    
    /// Holds the tag value.
    private var _Tag: Any? = nil
    /// Get or set the tag value.
    public var Tag: Any?
    {
        get
        {
            return _Tag
        }
        set
        {
            _Tag = newValue
        }
    }
    
    /// Holds the parent.
    private var _Parent: XMLNode? = nil
    /// Get or set the parent node.
    public var Parent: XMLNode?
    {
        get
        {
            return _Parent
        }
        set
        {
            _Parent = newValue
        }
    }
    
    /// Holds the list of child nodes.
    private var _Children: [XMLNode] = [XMLNode]()
    /// Get or set the list of child nodes.
    public var Children: [XMLNode]
    {
        get
        {
            return _Children
        }
        set
        {
            _Children = newValue
        }
    }
    
    // MARK: Payload properties and functions.
    
    /// If the node type is `.DocumentHeader`, true is returned. Otherwise, false is returned.
    public var IsRootNode: Bool
    {
        get
        {
            return NodeType == .DocumentHeader
        }
    }
    
    /// Holds the name associated with the node.
    private var _Name: String = ""
    /// Get or set the name associated with the node.
    public var Name: String
    {
        get
        {
            return _Name
        }
        set
        {
            _Name = newValue
        }
    }
    
    /// Holds the value associated with the node.
    private var _Value: String = ""
    /// Get or set the value associated with the node. This is the text between the node start entity and the node end
    /// entity (excluding child nodes and comments).
    public var Value: String
    {
        get
        {
            return _Value
        }
        set
        {
            _Value = newValue
        }
    }
    
    /// Holds the node type.
    private var _NodeType: XMLNodeTypes = .DocumentHeader
    /// Get or set the node type.
    public var NodeType: XMLNodeTypes
    {
        get
        {
            return _NodeType
        }
        set
        {
            _NodeType = newValue
        }
    }
    
    /// Holds the list of attributes for the node.
    private var _Attributes: [XMLKVP] = [XMLKVP]()
    /// Get or set the attributes for the node.
    public var Attributes: [XMLKVP]
    {
        get
        {
            return _Attributes
        }
        set
        {
            _Attributes = newValue
        }
    }
    
    /// Add a new attribute to the node.
    /// - Parameter Key: The attribute key name. If an attribute with this name already exists, the old value is overwritten.
    /// - Parameter Value: The value associated with the key.
    public func AddAttribute(Key: String, Value: String)
    {
        for Attr in Attributes
        {
            if Attr.Key == Key
            {
                Attr.Value = Value
                return
            }
        }
        Attributes.append(XMLKVP(WithKey: Key, WithValue: Value))
    }
    
    /// Sets an attribute. Alias for `AddAttribute`.
    /// - Parameter Key: The attribute key name. If an attribute with this name already exists, the old value is overwritten.
    /// - Parameter NewValue: The value associated with the key.
    public func SetAttribute(Key: String, NewValue: String)
    {
        AddAttribute(Key: Key, Value: NewValue)
    }
    
    /// Deletes the attribute with the specified name.
    /// - Parameter WithKey: The name of the attribute to delete.
    public func DeleteAttribute(WithKey: String)
    {
        Attributes.removeAll(where: {$0.Key == WithKey})
    }
    
    /// Returns the specified number of spaces in a string.
    /// - Parameter Count: Number of spaces to return.
    /// - Returns: Specified number of spaces.
    private func Spaces(_ Count: Int) -> String
    {
        var Working = ""
        for _ in 0 ..< Count
        {
            Working = Working + " "
        }
        return Working
    }
    
    /// Pretty-prints a node in XML format and optionally all its children.
    /// - Note:
    ///   - If you call from the XML document's root node, you will get the entire tree as an XML string.
    ///   - If you do not print the child nodes, the terminating entity will indicate whether the node has
    ///     children or not (eg, `/>` for no children and `>` for children).
    ///   - If you do not print child nodes, node content will not be included for nodes that contain content.
    /// - Parameter Indent: Initial indent level for the node. Child nodes are indented +2 spaces to the right. Initial
    ///                     indentation level is 0.
    /// - Parameter IncludeChildren: If true, all descendents are included in the returned string. Defaults to true.
    /// - Returns: String representation in XML format of the current node and optionally its descendent nodes.
    public func ToString(Indent: Int = 0, IncludeChildren: Bool = true) -> String
    {
        if IsRootNode
        {
            return Value
        }
        if NodeType == .Comment
        {
            return Spaces(Indent) + "<! \(Value) !>" + "\n"
        }
        var Working = Spaces(Indent) + "<\(Name)"
        if Attributes.count > 0
        {
            for Attr in Attributes
            {
                let AttrString = " " + Attr.ToString()
                Working = Working + AttrString
            }
        }
        if IncludeChildren
        {
            if Children.count == 0
            {
                Working = Working + "/>" + "\n"
            }
            else
            {
                Working = Working + ">" + "\n"
                if !Value.isEmpty
                {
                    Working = Spaces(Indent) + Value + "\n"
                }
                let NewIndent = Indent + 2
                for Child in Children
                {
                    Working = Working + Child.ToString(Indent: NewIndent)
                }
                Working = Working + "\n" + Spaces(Indent) + "</(Name)>" + "\n"
            }
        }
        else
        {
            if Children.count == 0
            {
                Working = Working + "/>"
            }
            else
            {
                Working = Working + ">"
            }
        }
        return Working
    }
    
    // MARK: Protocol function/attribute implementations.
    
    /// Returns the contents of the class as a string.
    public var description: String
    {
        get
        {
            return ToString()
        }
    }
}

/// Node types - defines how various fields should be interpreted.
/// - **DocumentHeader**: Used by the top-level document node.
/// - **XMLNode**: General purpose node.
/// - **Attribute**: Not currently used.
/// - **Comment**: Comment node.
enum XMLNodeTypes: String, CaseIterable
{
    case DocumentHeader = "DocumentHeader"
    case XMLNode = "XMLNode"
    case Attribute = "Attribute"
    case Comment = "Comment"
}

