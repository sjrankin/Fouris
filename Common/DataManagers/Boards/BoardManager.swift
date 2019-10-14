//
//  BoardManager.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class BoardManager
{
    private static func CreateBoardFiles()
    {
        let DefaultBoard = FileIO.GetFileContentsFromResource("Boards", ".xml")
        let _ = FileIO.SaveSettingsFile(Name: "Boards.xml", Contents: DefaultBoard!)
    }
    
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
    
    public static func Initialize()
    {
        Preinitialize()
        DefaultBoardDocument = XMLDocument(File: FileIO.MakeFileURL(FileName: "Boards.xml", Directory: FileIO.SettingsDirectory)!)
        _Boards = BoardCollection()
        let _ = DefaultBoardDocument?.DeserializeTo(Caller: _Boards!)
    }
    
    private static var DefaultBoardDocument: XMLDocument? = nil
    private static var _Boards: BoardCollection? = nil
    
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
    
    public static func GetBoardFor(_ Shape: CenterShapes) -> BoardDescriptor2?
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

