//
//  Tree.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Generic tree.
class TreeNode<T> where T: Equatable
{
    /// Initializer.
    /// - Parameter Contents: Initial contents of the tree node.
    init(Contents: T)
    {
        _Contents = Contents
    }
    
    /// Initializer.
    /// - Parameter Contents: Initial contents of the tree node.
    /// - Parameter IsRootNode: Flag that determines if the node being created is the root node.
    init(Contents: T, IsRootNode: Bool)
    {
        _IsRoot = IsRootNode
        _Contents = Contents
    }
    
    /// Initializer.
    /// - Parameter Contents: Initial contents of the tree node.
    /// - Parameter NodeParent: Parent node.
    init(Contents: T, NodeParent: TreeNode<T>)
    {
        _Contents = Contents
        _Parent = NodeParent
    }
    
    /// Root node flag.
    private var _IsRoot: Bool = false
    /// Get or set the root flag.
    public var IsRoot: Bool
    {
        get
        {
            return _IsRoot
        }
        set
        {
            _IsRoot = newValue
        }
    }
    
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
    
    /// Holds the contents.
    private var _Contents: T? = nil
    /// Get or set the contents of the node.
    public var Contents: T?
    {
        get
        {
            return _Contents
        }
        set
        {
            _Contents = newValue
        }
    }
    
    /// Holds the parent node.
    private var _Parent: TreeNode<T>? = nil
    /// Get or set the parent node. If nil, no parent node was assigned.
    public var Parent: TreeNode<T>?
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
    
    /// Holds the child nodes.
    private var _Children: [TreeNode<T>] = [TreeNode<T>]()
    /// Get or set the child nodes.
    public var Children: [TreeNode<T>]
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
}
