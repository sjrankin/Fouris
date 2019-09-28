//
//  Serializer.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import var CommonCrypto.CC_MD5_DIGEST_LENGTH
import func CommonCrypto.CC_MD5
import typealias CommonCrypto.CC_LONG
import UIKit

/// Simple XML-fragment serializer/deserializer. Uses reflection to read classes that follow the `Serializable` protocol to
/// encode them, and the `Serializable` protocol to help populate them.
class Serializer
{
    // MARK: Serialization functions.
    
    /// Encode a `Serializable` object into an XML fragment.
    /// - Notes:
    ///   - This is not a general purpose encoder - it is tuned for themes for Fouris.
    ///   - Properties that do not start with an underscore ("`_`") are not serialized.
    ///   - `_Dirty` is not serialized.
    ///   - [Swift reflection dump](https://gist.github.com/natecook1000/4ee3ee560000062b1ace)
    ///   - [Swift reflection dump](http://ericasadun.com/2014/06/24/swift-reflection-dump/)
    /// - Parameters:
    ///   - SerializeMe: The `Serializable` object to encode.
    ///   - WithTitle: The title of the root node. If this value is empty, no header tags are added to the result.
    ///   - IndentLevel: How many spaces to indent each line by.
    /// - Returns: Encoded XML fragment of the object.
    func Encode(_ SerializeMe: Serializable, WithTitle: String, IndentLevel: Int = 0) -> String
    {
        var Fragment = ""
        if !WithTitle.isEmpty
        {
            Fragment = Indentation(IndentLevel) + "<Theme Name=\"\(WithTitle)\">\n"
        }
        let mirror = Mirror(reflecting: SerializeMe)
        for mirrored in mirror.children
        {
            switch mirrored.value
            {
            case let SomeArray as [Serializable]:
                var Counter = 0
                Fragment = Fragment + Indentation(IndentLevel + 2) + "<Array Name=\"\((mirrored.label)!)\">\n"
                for SomeElement in SomeArray
                {
                    Fragment = Fragment + Indentation(IndentLevel + 4) + "<Item Index=\"\(Counter)\">\n"
                    let Encoded = Encode(SomeElement, WithTitle: "", IndentLevel: IndentLevel + 4)
                    Counter = Counter + 1
                    Fragment = Fragment + Encoded
                    Fragment = Fragment + Indentation(IndentLevel + 4) + "</Item>\n"
                }
                Fragment = Fragment + Indentation(IndentLevel + 2) + "</Array>\n"
                
            default:
                if (mirrored.label)! == "_Dirty"
                {
                    continue
                }
                if (mirrored.label?.starts(with: "_"))!
                {
                Fragment = Fragment + Indentation(IndentLevel + 2) + "<Property Name=\"\((mirrored.label)!)\" Value=\"\(mirrored.value)\"/>\n"
                }
            }
        }
        if !WithTitle.isEmpty
        {
            Fragment = Fragment + Indentation(IndentLevel) + "</Theme>\n"
        }
        return Fragment
    }
    
    /// Returns the specified number of spaces for indentation purposes.
    ///
    /// - Parameter Count: Number of space to return.
    /// - Returns: String of spaces.
    private func Indentation(_ Count: Int) -> String
    {
        var Spaces = ""
        for _ in 0 ..< Count
        {
            Spaces = Spaces + " "
        }
        return Spaces
    }
    
    // MARK: Deserialization functions.
    
    /// Deserialize the passed string into a `SerializerTree` held in the instance (see `Tree`.).
    ///
    /// - Parameter From: The string to deserialize.
    /// - Returns: True on success, false on failure.
    public func Deserialize(From: String) -> Bool
    {
        if From.isEmpty
        {
            print("Nothing to deserialize.")
            _Tree = nil
            return false
        }
        let MD5 = MD5Checksum(For: From)
        //print("Checksum=\(MD5ChecksumToString(MD5))")
        _Tree = SerializerTree()
        let Parser = RawParser(ThenParse: From)
        let Results = Parser.GetParsedNodes()
        CreateTree(Results, Parent: _Tree!.Root)
        return true
    }
    
    /// Create the final deserialized tree from the raw nodes passed here.
    ///
    /// - Parameters:
    ///   - With: List of parsed nodes to convert to a serialized tree.
    ///   - Parent: The parent serializer node.
    private func CreateTree(_ With: [ParsedNode], Parent: SerializerNode)
    {
        for Node in With
        {
            let Name = Node.Name.replacingOccurrences(of: "<", with: "")
            let NewNode = SerializerNode(NodeTitle: Name)
            for Attr in Node.Attributes
            {
                let Parts = Attr.split(separator: "=")
                NewNode.AttributeList.append((String(Parts[0]), String(Parts[1])))
            }
            if !Node.Children.isEmpty
            {
                CreateTree(Node.Children, Parent: NewNode)
            }
            Parent.Children.append(NewNode)
        }
    }
    
    /// Holds the deserialized tree from the XML fragment.
    private var _Tree: SerializerTree? = nil
    /// Get the deserialized tree from the XML fragment.
    public var Tree: SerializerTree?
    {
        get
        {
            return _Tree
        }
    }
    
    // MARK: Convenience functions.
    
    /// Returns a list of themes in the deserialized tree.
    ///
    /// - Note: If the tree has not been deserialized yet, a fatal error will result.
    ///
    /// - Returns: List of theme names.
    public func ThemeList() -> [String]
    {
        if _Tree == nil
        {
            fatalError("No deserialized tree available.")
        }
        var Result = [String]()
        let Node = _Tree?.Root
        if (Node?.Children.count)! < 1
        {
            return Result
        }
        for ThemeNode in Node!.Children
        {
            Result.append(ThemeNode.Title)
        }
        return Result
    }
    
    /// Get the theme node with the passed name.
    ///
    /// - Parameter Name: Name of the theme node to return.
    /// - Returns: The specified theme node on success, nil if not found.
    public func GetThemeNode(_ Name: String) -> SerializerNode?
    {
        let Node = _Tree?.Root
        if (Node?.Children.count)! < 1
        {
            return nil
        }
        for ThemeNode in Node!.Children
        {
            if ThemeNode.Title == "Theme"
            {
                if ThemeNode.AttributeValue(For: "Name") == Name
                {
                    return ThemeNode
                }
            }
        }
        return nil
    }
    
    /// Return all nodes of a certain type from the passed node.
    ///
    /// - Parameters:
    ///   - Title: Determines which node types are returned. Case sensitive.
    ///   - InNode: The parent node that will be searched for the specified node title.
    /// - Returns: List of all nodes in the children of `InNode` that are of the specified type.
    public func GetAll(_ Title: String, InNode: SerializerNode) -> [SerializerNode]
    {
        var Results = [SerializerNode]()
        for SomeNode in InNode.Children
        {
            if SomeNode.Title == Title
            {
                Results.append(SomeNode)
            }
        }
        return Results
    }
    
    /// Return the array in `InNode` with the specified name.
    ///
    /// - Parameters:
    ///   - WithName: Name of the array to return.
    ///   - InNode: The node searched for the specified node.
    /// - Returns: List of nodes that make up the contents of the array.
    public func GetArray(WithName: String, InNode: SerializerNode) -> [SerializerNode]
    {
        let Arrays = GetAll("Array", InNode: InNode)
        for SomeArray in Arrays
        {
            if SomeArray.AttributeValue(For: "Name") == WithName
            {
                return SomeArray.Children
            }
        }
        return [SerializerNode]()
    }
    
    // MARK: Check-sum generation.
    
    /// Create an MD5 checksum for the passed string.
    ///
    /// - Note: [Create MD5 hash](https://stackoverflow.com/questions/32163848/how-can-i-convert-a-string-to-an-md5-hash-in-ios-using-swift)
    ///
    /// - Parameter For: The string for which an MD5 checksum will be created.
    /// - Returns: MD5 checksum in the form of a `Data` class.
    public func MD5Checksum(For: String) -> Data
    {
        let Length = Int(CC_MD5_DIGEST_LENGTH)
        let MessageData = For.data(using: .utf8)!
        var DigestData = Data(count: Length)
        
        _ = DigestData.withUnsafeMutableBytes
            {
                DigestBytes -> UInt8 in
                MessageData.withUnsafeBytes
                    {
                        MessageBytes -> UInt8 in
                          if let MessageBytesBaseAddress = MessageBytes.baseAddress,
                            let DigestBytesBlindMemory = DigestBytes.bindMemory(to: UInt8.self).baseAddress
                          {
                            let MessageLength = CC_LONG(MessageData.count)
                            CC_MD5(MessageBytesBaseAddress, MessageLength, DigestBytesBlindMemory)
                        }
                        return 0
                }
        }
        return DigestData
    }
    
    /// Return a string value of the checksum data.
    /// - Parameter ChecksumData: Checksum data (assumed to be created by `MD5Checksum`).
    /// - Returns: String equivalent of the checksum in the passed parameter.
    public func MD5ChecksumToString(_ ChecksumData: Data) -> String
    {
        let MD5Hex = ChecksumData.map{String(format: "%02hhx", $0)}.joined()
        return MD5Hex
    }
    
    // MARK: Variables for extensions
    // Because Swift (for no known good reason) doesn't allow variable definitions in extensions.
    
    let EntityList =
    [
        "\"": "&quot;",
        "&": "&amp;",
        "'": "&apos;",
        "<": "&lt;",
        ">": "&gt;"
    ]
}
