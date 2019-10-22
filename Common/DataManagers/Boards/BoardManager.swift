//
//  BoardManager.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages the board definition file and instances built from the filee.
class BoardManager
{
    /// Create the board files from resource-bound template to the working directory.
    private static func CreateBoardFiles()
    {
        let DefaultBoard = FileIO.GetFileContentsFromResource("Boards", ".xml")
        let _ = FileIO.SaveSettingsFile(Name: "Boards.xml", Contents: DefaultBoard!)
    }
    
    /// Make sure files are where they are expected to be and create files if they are not.
    private static func Preinitialize()
    {
        if !FileIO.DirectoryExists(DirectoryName: FileIO.SettingsDirectory)
        {
            CreateBoardFiles()
        }
        else
        {
            if !FileIO.FileExists(FileName: "Boards.xml", Directory: FileIO.SettingsDirectory)
            {
                CreateBoardFiles()
            }
        }
    }
    
    /// Initialize the board manager.
    public static func Initialize()
    {
        Preinitialize()
        DefaultBoardDocument = XMLDocument(File: FileIO.MakeFileURL(FileName: "Boards.xml", Directory: FileIO.SettingsDirectory)!)
        _Boards = BoardCollection()
        let _ = DefaultBoardDocument?.DeserializeTo(Caller: _Boards!)
    }
    
    /// Holds the board XML document.
    private static var DefaultBoardDocument: XMLDocument? = nil
    /// Holds the board collection class.
    private static var _Boards: BoardCollection? = nil
    
    /// Get or set the board collection.
    public static var Boards: BoardCollection?
    {
        get
        {
            return _Boards
        }
        set
        {
            _Boards = newValue
        }
    }
    
    /// Returns the board descriptor for the board of the specified shape.
    /// - Parameter Shape: The shape of the board that determines which board descriptor to return.
    /// - Returns: The board descriptor for the specified board, nil if not found.
    public static func GetBoardFor(_ Shape: BucketShapes) -> BoardDescriptor2?
    {
        if _Boards == nil
        {
            return nil
        }
        for SomeBoard in Boards!.BoardList
        {
            if SomeBoard.BucketShape == Shape
            {
                return SomeBoard
            }
        }
        return nil
    }
}

