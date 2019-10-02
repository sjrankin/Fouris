//
//  XMLSemanticParser.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Parses a series of syntactic entities into an XML tree.
class XMLSemanticParser
{
    /// Returns the first entity in the passed string. Assumes entities are space delimited.
    /// - Parameter From: The string from which the first token/entity is returned.
    /// - Returns: The first token/entity from the passed string.
    private static func GetFirstToken(From: String) -> String
    {
        let Parts = From.split(separator: " ")
        if Parts.count > 0
        {
            return String(Parts[0])
        }
        return ""
    }
    
    /// Remove the specified string from the start of the target string.
    /// - Parameter Value: The string to remove from the start of the string.
    /// - Parameter From: The target string.
    /// - Returns: New string with the starting value of `Value` removed.
    private static func RemoveFromStart(_ Value: String, From: String) -> String
    {
        if Value.count > From.count
        {
            return From
        }
        let Working = From.dropFirst(Value.count)
        return String(Working)
    }
    
    /// Parse a list of XML string entities into an XML tree.
    /// - Note: This version assumes all XML string entities live on one line and are not split into multiple lines. **XML text
    ///         entities that span lines will cause this parser to fail in unpredictable ways.**
    /// - Parameter EntityList: The list of XML text entities, created by `XMLEntityParser`.
    /// - Returns: The root node of the XML tree.
    public static func ParseToTree(_ EntityList: [String]) -> XMLNode
    {
        let Root = XMLNode("XMLDocument", .DocumentHeader)
        var CurrentNode = Root
        
        var Line = 0
        for Entity in EntityList
        {
            Line = Line + 1
            var Working = Entity.trimmingCharacters(in: CharacterSet.whitespaces)
            
            if Working.starts(with: "<?")
            {
                //Ignore XML headers
                Root.Value = Entity
                Root.Tag = XMLNodeTypes.DocumentHeader
                continue
            }
            
            if Working.starts(with: "</")
            {
                //At the end of a multi-line entity definition. Move to the current node's parent.
                if CurrentNode.Parent == nil
                {
                    fatalError("Unexpectedly found nil parent at \"</\" token near line \(Line).")
                }
                CurrentNode = CurrentNode.Parent!
                continue
            }
            
            if Working.starts(with: "<!--")
            {
                //Found a comment.
                Working = Working.replacingOccurrences(of: "<!--", with: "")
                Working = Working.replacingOccurrences(of: "-->", with: "")
                Working = Working.trimmingCharacters(in: CharacterSet.whitespaces)
                let CommentNode = XMLNode("Comment", .Comment)
                CommentNode.Value = Working
                CurrentNode.Children.append(CommentNode)
                continue
            }
            
            //If we're here, the Entity starts with "<".
            let P0 = Working.split(separator: ">", omittingEmptySubsequences: true)
            var Content = ""
            if P0.count > 1
            {
                Content = String(P0[1])
            }
            var EntityPart = String(P0[0])
            EntityPart = EntityPart.replacingOccurrences(of: "<", with: "")
            var IsClosing = false
            if EntityPart.last == "/"
            {
                //Single line entity.
                IsClosing = true
                EntityPart.removeLast()
            }
            let Name = GetFirstToken(From: EntityPart)
            EntityPart = RemoveFromStart(Name, From: EntityPart)
            let Attributes = XMLAttributeListParser.ParseAttributes(From: EntityPart)
            let NewNode = XMLNode(Name, .XMLNode)
            NewNode.Parent = CurrentNode
            CurrentNode.Children.append(NewNode)
            NewNode.Attributes = Attributes
            if !IsClosing
            {
                NewNode.Value = Content
                CurrentNode = NewNode
            }
        }
        
        return Root
    }
}

