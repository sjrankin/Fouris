//
//  HistoryManager.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/2/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages history files for game-play statistics.
class HistoryManager
{
    /// Create history files from resource-bound initial files.
    /// - Note:
    ///  - This function will overwrite any previously existing files.
    ///  - The files this function write will reset game history to no games.
    private static func CreateHistoryFiles()
    {
        let InitialHistory = FileIO.GetFileContentsFromResource("GameHistory", ".xml")
        let _ = FileIO.SaveHistoryFile(Name: "GameHistory.xml", Contents: InitialHistory!)
        
        let InitialAIHistory = FileIO.GetFileContentsFromResource("AIGameHistory", ".xml")
        let _ = FileIO.SaveHistoryFile(Name: "AIGameHistory.xml", Contents: InitialAIHistory!)
    }
    
    /// Pre-initialize - make sure the directory structure exists. If it does not, create it and add an initial history file.
    private static func Preinitialize()
    {
        if !FileIO.DirectoryExists(DirectoryName: FileIO.HistoryDirectory)
        {
            print("Creating initial history.")
            FileIO.CreateDirectory(DirectoryName: FileIO.HistoryDirectory)
            CreateHistoryFiles()
        }
        else
        {
            print("History directory exists.")
            if !FileIO.FileExists(FileName: "GameHistory.xml", Directory: FileIO.HistoryDirectory)
            {
                CreateHistoryFiles()
            }
        }
    }
    
    /// Initialize the history manager. If history files don't exist, new files will be copied. Load history from history files into
    /// appropriate objects.
    public static func Initialize()
    {
        Preinitialize()
        GameHistoryDocument = XMLDocument(File: FileIO.MakeFileURL(FileName: "GameHistory.xml", Directory: FileIO.HistoryDirectory)!)
        GameAIHistoryDocument = XMLDocument(File: FileIO.MakeFileURL(FileName: "AIGameHistory.xml", Directory: FileIO.HistoryDirectory)!)
        _UserGameStatistics = RunHistory()
        let _ = GameHistoryDocument?.DeserializeTo(Caller: _UserGameStatistics!)
        _AIGameStatistics = RunHistory()
        let _ = GameAIHistoryDocument?.DeserializeTo(Caller: _AIGameStatistics!)
    }
    
    /// Holds the game history document.
    private static var GameHistoryDocument: XMLDocument? = nil
    /// Holds the AI game history document.
    private static var GameAIHistoryDocument: XMLDocument? = nil
    
    /// Holds the game history class.
    private static var _UserGameStatistics: RunHistory? = nil
    /// Holds the AI game history class.
    private static var _AIGameStatistics: RunHistory? = nil
    
    /// Get or set the game history
    public static var GameHistory: RunHistory?
    {
        get
        {
            return _UserGameStatistics
        }
        set
        {
            _UserGameStatistics = newValue
        }
    }
    
    /// Get or set the AI game history
    public static var AIGameHistory: RunHistory?
    {
        get
        {
            return _AIGameStatistics
        }
        set
        {
            _AIGameStatistics = newValue
        }
    }
    
    /// Get game history.
    /// - Parameter IsAI: If true, the AI game history is returned. Otherwise, the user game history is returned.
    /// - Returns: Game history on success, nil if not found (or initialized).
    public static func GetHistory(_ IsAI: Bool) -> RunHistory? 
    {
        if IsAI
        {
            return AIGameHistory
        }
        else
        {
            return GameHistory
        }
    }
    
    /// Save history files. Files are saved only if they contain dirty data.
    public static func Save()
    {
        #if false
        if GameHistory!.Dirty
        {
            let Serialized = GameHistory?.ToString()
            let _ = FileIO.SaveHistoryFile(Name: "GameHistory.xml", Contents: Serialized!)
        }
        if AIGameHistory!.Dirty
        {
            let Serialized = AIGameHistory?.ToString()
            let _ = FileIO.SaveHistoryFile(Name: "AIGameHistory.xml", Contents: Serialized!)
        }
        #endif
    }
}
