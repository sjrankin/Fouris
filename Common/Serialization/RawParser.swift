//
//  RawParser.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Parses raw strings into an array of logical string groups, where "logical string group" means XML entities.
class RawParser
{
    /// Default initializer.
    init()
    {
        ParseStack.Clear()
    }
    
    /// Initializer.
    ///
    /// - Parameter ThenParse: String to deserialize after initialization. Results will be available in `GetParsedNodes`.
    init(ThenParse: String)
    {
        ParseStack.Clear()
        RunParseMachine(ThenParse)
    }
    
    /// Start parsing the string. When done, the results will be available in `GetParsedNodes`.
    ///
    /// - Parameter Raw: The raw string to parse.
    func StartParsing(_ Raw: String)
    {
        ParseStack.Clear()
        RunParseMachine(Raw)
    }
    
    /// Splits a string by the passed separator, taking into account traditional English qutotation marks (which this function
    /// will not split).
    ///
    /// - Parameters:
    ///   - SplitMe: The string to split.
    ///   - WithSeparator: The separator by which to split the string. Not included in the results.
    /// - Returns: List of parts of the separated string.
    func Split2(_ SplitMe: String, WithSeparator: Character) -> [String]
    {
        var Results = [String]()
        var InQuote = false
        var Phrase = ""
        for Char in SplitMe
        {
            if Char == "\""
            {
                if InQuote
                {
                    InQuote = false
                }
                else
                {
                    InQuote = true
                }
            }
            if Char == " " && !InQuote
            {
                Results.append(Phrase)
                Phrase = ""
                continue
            }
            Phrase = Phrase + String(Char)
        }
        Results.append(Phrase)
        return Results
    }
    
    /// Make a nice node name - remove extraneous XML characters.
    ///
    /// - Parameter Raw: The raw string to clean up.
    /// - Returns: Cleaned up string.
    func MakeNiceNode(_ Raw: String) -> String
    {
        var Done = Raw.replacingOccurrences(of: "<", with: "")
        Done = Done.replacingOccurrences(of: "/>", with: "")
        Done = Done.replacingOccurrences(of: ">", with: "")
        return Done
    }
    
    /// Extraordinarily simple XML fragment parser. Has many, many limitations but for our purposes, this is all that is needed.
    ///
    /// - Note: Results are found in `Parsed`.
    ///
    /// - Parameter Raw: The raw string to parse.
    func RunParseMachine(_ Raw: String)
    {
        let Parts = Raw.split(separator: "<", omittingEmptySubsequences: true)
        for Part in Parts
        {
            //Add the leading "<" back to each part of the string.
            let SPart = "<" + String(Part).replacingOccurrences(of: "\n", with: "")

            if SPart.starts(with: "</")
            {
                //We encountered a terminal node token. Pop the node stack and if the node isn't a child, add it to the
                //results, otherwise, discard it.
                if let OldNode = ParseStack.Pop()
                {
                    if !OldNode.IsAChild
                    {
                    Parsed.append(OldNode)
                    }
                }
                continue
            }
            
            if SPart.starts(with: "<")
            {
                //We found an opening token. This code will check to see if it is also a closing token ("<token/>") and save
                //any attributes in the node. Also, if there are no parents, the node is put in the results list, otherwise,
                //the node is pushed onto the node stack.
                var AddedToParent = false
                let NewNode = ParsedNode()
                let NParts = SPart.split(separator: " ", omittingEmptySubsequences: true)
                let Last = String(NParts.last!)
                let HasChildren = !Last.Ends(With: "/>")
                let NiceNode = MakeNiceNode(String(NParts[0]))
                NewNode.Name = NiceNode
                if let Parent = ParseStack.PeekAtTop()
                {
                    AddedToParent = true
                    NewNode.IsAChild = true
                    Parent.Children.append(NewNode)
                }
                let RawAttributes = Split2(SPart, WithSeparator: " ")
                for RawAttribute in RawAttributes
                {
                    if RawAttribute.contains("=")
                    {
                        let Final = MakeNiceNode(RawAttribute)
                        NewNode.Attributes.append(Final)
                    }
                }
                if HasChildren
                {
                    ParseStack.Push(NewNode)
                }
                else
                {
                    if !AddedToParent
                    {
                        Parsed.append(NewNode)
                    }
                }
            }
        }
    }
    
    /// Holds the stack of parsed nodes during the parsing process.
    private var ParseStack = Stack<ParsedNode>()
    
    /// Holds the result of the parsing process.
    private var Parsed = [ParsedNode]()
    
    /// Return a list of parsed nodes.
    ///
    /// - Returns: Parsed raw nodes.
    func GetParsedNodes() -> [ParsedNode]
    {
        return Parsed
    }
}

/// Contains a parsed node from the deserialized string.
class ParsedNode
{
    /// The name of the node.
    var Name: String = ""
    
    /// List of attributes in the node, if any.
    var Attributes: [String] = [String]()
    
    /// List of children of the node, if any.
    var Children: [ParsedNode] = [ParsedNode]()
    
    /// Used for parsing - indicates that the node is a child of another node.
    var IsAChild: Bool = false
}

/// String extension to add a function to String instances to check the contents of the end of a string.
extension String
{
    /// Determines if the string instance ends with the passed string. Case sensitive.
    ///
    /// - Note: This is a heavy function that calls `reversed` on two strings. It can most likely be
    ///         refactored to use substring should performance become an issue.
    ///
    /// - Parameter With: The string to test against the end of the instance.
    /// - Returns: True if the end of the instance string matches `With`, false if not.
    func Ends(With: String) -> Bool
    {
        let Reversed = self.reversed()
        let htiW = With.reversed()
        return Reversed.starts(with: htiW)
    }
}
