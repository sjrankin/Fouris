//
//  HistoryManager.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Maintains game history on a game-type by game-type basis. No personal information is used or stored.
class HistoryManager
{
    /// Pre-initialize - make sure the directory structure exists. If it does not, create it and add an initial history file.
    private static func Preinitialize()
    {
        if !FileIO.DirectoryExists(DirectoryName: FileIO.HistoryDirectory)
        {
            print("Creating initial history.")
            FileIO.CreateDirectory(DirectoryName: FileIO.HistoryDirectory)
            let InitialHistory = FileIO.GetFileContentsFromResource("History", ".xml")
            let _ = FileIO.SaveHistoryFile(Name: "History.xml", Contents: InitialHistory!)
            let AIInitialHistory = FileIO.GetFileContentsFromResource("AIHistory", ".xml")
            let _ = FileIO.SaveHistoryFile(Name: "AIHistory.xml", Contents: AIInitialHistory!)
        }
        else
        {
            print("History directory exists.")
        }
    }
    
    /// Initialize the history manager. Loads the history file from mass storage, possibly creating a new file if one does not
    /// yet exist.
    public static func Initialize()
    {
        Preinitialize()
        if let SerializedHistory = FileIO.GetHistoryFile(Name: "History.xml")
        {
            let Serialize = Serializer()
            let DeserializedOK = Serialize.Deserialize(From: SerializedHistory)
            if DeserializedOK
            {
                CreateHistory(Serialize, ForUser: true)
            }
        }
        if let SerializedHistory = FileIO.GetHistoryFile(Name: "AIHistory.xml")
        {
            let Serialize = Serializer()
            let DeserializedOK = Serialize.Deserialize(From: SerializedHistory)
            if DeserializedOK
            {
                CreateHistory(Serialize, ForUser: false)
            }
        }
    }
    
    /// Save game history statistics.
    public static func SaveHistory()
    {
        if GameRunHistory == nil
        {
            return
        }
        let Encoder = Serializer()
        let Serialized = Encoder.Encode(GameRunHistory!, WithTitle: "History")
        let _ = FileIO.SaveHistoryFile(Name: "History.xml", Contents: Serialized)
    }
    
    /// Create the history class from the passed deserialier.
    /// - Parameter Deserialized: The serializer with deserialized information.
    private static func CreateHistory(_ Deserialized: Serializer, ForUser: Bool)
    {
        let Root = Deserialized.Tree!.Root
        for Node in Root.Children
        {
            if let NodeName = Node.AttributeValue(For: "Name")
            {
                let Name = NodeName.replacingOccurrences(of: "\"", with: "")
                let History = RunHistory()
                for Child in Node.Children
                {
                    let ChildType = Child.Title
                    if ChildType == "Property"
                    {
                        var Key = Child.AttributeValue(For: "Name")
                        Key = Key?.replacingOccurrences(of: "\"", with: "")
                        var Value = Child.AttributeValue(For: "Value")
                        Value = Value?.replacingOccurrences(of: "\"", with: "")
                        History.Populate(Key: Key!, Value: Value!)
                    }
                    
                }
                if ForUser
                {
                GameRunHistory = History
                }
                else
                {
                    AIGameRunHistory = History
                }
            }
        }
    }
    
    /// Holds the set of game execution statistics.
    /// - Note: Callers are enouraged to use the provided functions to access statistics.
    public static var GameRunHistory: RunHistory? = nil
    
    public static var AIGameRunHistory: RunHistory? = nil
}
