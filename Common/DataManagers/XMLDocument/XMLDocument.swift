//
//  XMLDocument.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// XML document. When initialized with an XML document contains the root node of the document tree.
/// - Note: **This version only supports XML files with text entities confined to one line.**
class XMLDocument: CustomStringConvertible
{
    /// Initializer.
    /// - Parameter File: URL of the XML file to load.
    init?(File: URL)
    {
        let LoadOK = LoadDocument(From: File)
        if !LoadOK
        {
            return nil
        }
    }
    
    /// Initializer.
    /// - Parameter FileName: Name of the XML file to load.
    init?(FileName: String)
    {
        let LoadOK = LoadDocument(FromName: FileName)
        if !LoadOK
        {
            return nil
        }
    }
    
    /// Initializer.
    /// - Parameter FromString: String that contains an XML document to load.
    init?(FromString: String)
    {
        let LoadOK = LoadDocument(Raw: FromString)
        if !LoadOK
        {
            return nil
        }
    }
    
    /// Default initializer.
    init()
    {
    }
    
    /// Load an XML document.
    /// - Parameter Raw: The text of an XML document.
    /// - Returns: True on success, false on failure.
    public func LoadDocument(Raw: String) -> Bool
    {
        if Raw.isEmpty
        {
            return false
        }
        _SourceDocument = Raw
        let Entities = XMLEntityParser.ParseToEntities(Raw: Raw)
        _Root = XMLSemanticParser.ParseToTree(Entities)
        return true
    }
    
    /// Load an XML document.
    /// - Parameter From: URL of the XML document to load.
    /// - Returns: True on success, false on failure.
    public func LoadDocument(From: URL) -> Bool
    {
        _LoadedFileURL = From
        if let Raw = FileIO.GetFileContents(From: From)
        {
            _SourceDocument = Raw
            let Entities = XMLEntityParser.ParseToEntities(Raw: Raw)
            _Root = XMLSemanticParser.ParseToTree(Entities)
            return true
        }
        return false
    }
    
    /// Load an XML document.
    /// - Parameter FromName: The name of the XML file to load.
    /// - Returns: True on success, false on failure.
    private func LoadDocument(FromName: String) -> Bool
    {
        if FromName.isEmpty
        {
            return false
        }
        return LoadDocument(From: URL(fileURLWithPath: FromName))
    }
    
    /// Holds the contents of the source document.
    private var _SourceDocument: String = ""
    /// Get the source document contents in unaltered form.
    public var SourceDocument: String
    {
        get
        {
            return _SourceDocument
        }
    }
    
    /// Holds the loaded file's URL.
    private var _LoadedFileURL: URL? = nil
    /// Get the load file's URL. May be nil if `LoadDocument(String)` was called.
    public var LoadedFileURL: URL?
    {
        get
        {
            return _LoadedFileURL
        }
    }
    
    /// Holds the root of the parsed XML document.
    private var _Root: XMLNode? = nil
    /// Get or set the root of the parsed XML document. Will not be set until a file is loaded.
    public var Root: XMLNode?
    {
        get
        {
            return _Root
        }
        set
        {
            _Root = newValue
        }
    }
    
    /// Returns a minimal, standard XML file header.
    /// - Returns: XML file header.
    public func GetXMLHeader() -> String
    {
        return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    }
    
    /// Traverses the node tree.
    /// - Parameter FromNode: The node traversed.
    /// - Parameter CallAtNode: Handler to call at each node.
    private func DoTraverseTree(FromNode: XMLNode, CallAtNode: ((XMLNode) -> ())?)
    {
        CallAtNode?(FromNode)
        for Child in FromNode.Children
        {
            DoTraverseTree(FromNode: Child, CallAtNode: CallAtNode)
        }
    }
    
    /// Traverses the current XML tree, optionally calling a handler at each node.
    /// - Note: If this function is called but the handler is never called, that is an indication the `Root` is nil, which means
    ///         no document has been loaded.
    /// - Parameter CallAtNode: Handler called at each node in the tree.
    public func TraverseTree(CallAtNode: ((XMLNode) -> ())?)
    {
        if _Root == nil
        {
            return
        }
        DoTraverseTree(FromNode: _Root!, CallAtNode: CallAtNode)
    }
    
    /// Call to deserialize the XML tree into something that uses the data. The entire tree is deserialized.
    /// - Parameter Caller: The object that wants to have deserialized data.
    /// - Returns: True if the tree was successfully deserialized, false if not (due to no tree being present).
    public func DeserializeTo(Caller: XMLDeserializeProtocol) -> Bool
    {
        if _Root == nil
        {
            return false
        }
        TraverseTree(CallAtNode:
            {
                Node in
                Caller.DeserializedNode(Node)
        })
        return true
    }
    
    /// Serializes the current root to a string and returns it.
    /// - Note: Assumes the root contains the most up-to-date information.
    /// - Returns: Contents of the current XML tree as a string. If no document has been loaded, an empty string is returned.
    public func SerializeTo() -> String
    {
        if Root == nil
        {
            return ""
        }
        return (Root?.ToString())!
    }
    
    // MARK: CustomStringConvertible property.
    
    /// Implementation of the `CustomStringConvertible` description property.
    var description: String
    {
        get
        {
            if _Root == nil
            {
                return ""
            }
            else
            {
                return (_Root?.ToString())!
            }
        }
    }
}
