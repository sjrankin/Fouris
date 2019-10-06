//
//  RunHistory2.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/2/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains game run history in instance form.
/// - Note: No individually identifiable information is collected or stored.
class RunHistory: CustomStringConvertible, XMLDeserializeProtocol
{
    /// Initializer.
    init()
    {
        _Games = [BaseGameTypes: GameHistory]()
        _Games![.Standard] = GameHistory()
        _Games![.Rotating4] = GameHistory()
        _Games![.Cubic] = GameHistory()
    }
    
    /// Get the dirty flag.
    /// - Note: The dirty flag is from individual game statistic collections.
    public var Dirty: Bool
    {
        get
        {
            if let Games = Games
            {
            for (_, Game) in Games
            {
                if Game.Dirty
                {
                    return true
                }
            }
            }
            return false
        }
    }
    
    /// Holds a dictionary of game statistics.
    private var _Games: [BaseGameTypes: GameHistory]? = nil
    /// Get or set game statistics.
    public var Games: [BaseGameTypes: GameHistory]?
    {
        get
        {
            return _Games
        }
        set
        {
            _Games = newValue
        }
    }

    /// Holds the history name.
    private var _HistoryName: String = ""
    /// Get or set the history name.
    public var HistoryName: String
    {
        get
        {
            return _HistoryName
        }
        set
        {
            _HistoryName = newValue
        }
    }
    
    /// Holds the time stamp.
    private var _TimeStamp: String = ""
    /// Get or set the time stamp (in string format) for the last time the history was saved.
    public var TimeStamp: String
    {
        get
        {
            return _TimeStamp
        }
        set
        {
            _TimeStamp = newValue
        }
    }
    
    /// Deserialize from the passed node.
    /// - Note: Deserialization takes from from the top-most, non-document root node. Nodes are
    ///         traversed here so only the top-most node is processed from a call, regardless of
    ///         which node is passed to us.
    /// - Parameter Node: The node to deserialied.
    func DeserializedNode(_ Node: XMLNode)
    {
        if Node.Name == "XMLDocument"
        {
            return
        }
        if Node.Name == "History"
        {
            let Name = XMLNode.GetAttributeNamed("Name", InNode: Node)!
            let TStamp = XMLNode.GetAttributeNamed("TimeStamp", InNode: Node)!
            _TimeStamp = TStamp
            _HistoryName = Name
            for GameTypeNode in Node.Children
            {
                if GameTypeNode.Name == "Comment"
                {
                    continue
                }
                let RawGameType = XMLNode.GetAttributeNamed("Name", InNode: GameTypeNode)!
                if let GameType = BaseGameTypes(rawValue: RawGameType)
                {
                    _Games![GameType]!._GameType = GameType
                    for GameDataNode in GameTypeNode.Children
                    {
                        switch GameDataNode.Name
                        {
                            case "GameCount":
                                let RawGameCount = XMLNode.GetAttributeNamed("Started", InNode: GameDataNode)!
                                _Games![GameType]!._GameCount = Int(RawGameCount)!
                            
                            case "Score":
                                let RawCumulativeScore = XMLNode.GetAttributeNamed("Cumulative", InNode: GameDataNode)!
                                _Games![GameType]!._CumulativeScore = Int(RawCumulativeScore)!
                                let RawHighScore = XMLNode.GetAttributeNamed("High", InNode: GameDataNode)!
                                _Games![GameType]!._HighScore = Int(RawHighScore)!
                            
                            case "Duration":
                                let RawSeconds = XMLNode.GetAttributeNamed("Seconds", InNode: GameDataNode)!
                                _Games![GameType]!._Duration = Int(RawSeconds)!
                            
                            case "Pieces":
                                let RawPieces = XMLNode.GetAttributeNamed("Cumulative", InNode: GameDataNode)!
                                _Games![GameType]!._CumulativePieces = Int(RawPieces)!
                            
                            default:
                                print("Unexpected game type node encountered: \(GameDataNode.Name)")
                        }
                    }
                }
            }
        }
    }
    
    /// Returns a string with the passed number of spaces in it.
    /// - Parameter Count: Number of spaces to include in the string.
    /// - Returns: String with the specified number of spaces in it.
    private func Spaces(_ Count: Int) -> String
    {
        var SpaceString = ""
        for _ in 0 ..< Count
        {
            SpaceString = SpaceString + " "
        }
        return SpaceString
    }
    
    /// Returns the passed string surrounded by quotation marks.
    /// - Parameter Raw: The string to return surrounded by quotation marks.
    /// - Returns: `Raw` surrounded by quotation marks.
    private func Quoted(_ Raw: String) -> String
    {
        return "\"\(Raw)\""
    }
    
    /// Return the contents of the class as a string XML document.
    /// - Parameter Indent: Indent value for sub-nodes.
    /// - Parameter AppendTerminalReturns: If true, a return character is appended to the returned string.
    /// - Parameter ResetDirtyFlag: If true, the appropriate dirty flags are reset to false.
    /// - Returns: XML document string for the contents of this class.
    func ToString(Indent: Int = 4, AppendTerminalReturn: Bool = true, ResetDirtyFlag: Bool = true) -> String
    {
        var Working = ""
        
        Working.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
        Working.append("<History Name=" + Quoted(HistoryName) +
        " TimeStamp=" + Quoted(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .long)) + ">\n")
        
        for (_, History) in _Games!
        {
            Working.append(History.ToString(Indent: Indent, ResetDirtyFlag: ResetDirtyFlag))
        }
        
        Working.append("</History>")
        if AppendTerminalReturn
        {
            Working.append("\n")
        }
        
        return Working
    }
    
    /// Returns a string description of the contents of this class.
    /// - Note: Calls `ToString()`.
    var description: String
    {
        return ToString()
    }
}
