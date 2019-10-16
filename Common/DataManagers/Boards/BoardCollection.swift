//
//  BoardCollection.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains a collection of game boards read from persistent storage.
class BoardCollection: XMLDeserializeProtocol
{
    /// Holds the list of game boards.
    private var _BoardList: [BoardDescriptor2] = [BoardDescriptor2]()
    /// Get or set the list of game boards.
    public var BoardList: [BoardDescriptor2]
    {
        get
        {
            return _BoardList
        }
        set
        {
            _BoardList = newValue
        }
    }
    
    /// Deserialize a node from the file that contains game boards.
    /// - Parameter Node: Node to deserialize.
    func DeserializedNode(_ Node: XMLNode)
    {
        switch Node.Name
        {
            case "Boards":
                for Child in Node.Children
                {
                    if Child.NodeType == .Comment
                    {
                        continue
                    }
                    let Board = BoardDescriptor2()
                    BoardList.append(Board)
                    let BucketS = XMLNode.GetAttributeNamed("Type", InNode: Child)!
                    Board._BucketShape = BucketShapes(rawValue: BucketS)!
                    let GameS = XMLNode.GetAttributeNamed("GameType", InNode: Child)!
                    Board._GameType = BaseGameTypes(rawValue: GameS)!
                    for BoardChild in Child.Children
                    {
                        switch BoardChild.Name
                        {
                            case "Description":
                                let TextR = XMLNode.GetAttributeNamed("Text", InNode: BoardChild)!
                                Board._TextDescription = TextR
                            
                            case "Map":
                                Board._BoardMap = BoardChild.Value
                            
                            case "Rotations":
                                let BucketR = XMLNode.GetAttributeNamed("BucketRotates", InNode: BoardChild)!
                                Board._BucketRotates = Bool(BucketR)!
                                let PieceR = XMLNode.GetAttributeNamed("PiecesRotate", InNode: BoardChild)!
                                Board._PiecesRotate = Bool(PieceR)!
                            
                            case "Buttons":
                                for ButtonNode in BoardChild.Children
                                {
                                    switch ButtonNode.Name
                                    {
                                        case "Left":
                                            let Show = XMLNode.GetAttributeNamed("Visible", InNode: ButtonNode)!
                                            Board._LeftButtonVisible = Bool(Show)!
                                        
                                        case "Right":
                                            let Show = XMLNode.GetAttributeNamed("Visible", InNode: ButtonNode)!
                                            Board._RightButtonVisible = Bool(Show)!
                                        
                                        case "Up":
                                            let Show = XMLNode.GetAttributeNamed("Visible", InNode: ButtonNode)!
                                            Board._UpButtonVisible = Bool(Show)!
                                        
                                        case "Down":
                                            let Show = XMLNode.GetAttributeNamed("Visible", InNode: ButtonNode)!
                                            Board._DownButtonVisible = Bool(Show)!
                                        
                                        case "DropDown":
                                            let Show = XMLNode.GetAttributeNamed("Visible", InNode: ButtonNode)!
                                            Board._DropDownButtonVisible = Bool(Show)!
                                        
                                        case "FlyAway":
                                            let Show = XMLNode.GetAttributeNamed("Visible", InNode: ButtonNode)!
                                            Board._FlyAwayButtonVisible = Bool(Show)!
                                        
                                        case "RotateLeft":
                                            let Show = XMLNode.GetAttributeNamed("Visible", InNode: ButtonNode)!
                                            Board._RotateLeftButtonVisisble = Bool(Show)!
                                        
                                        case "RotateRight":
                                            let Show = XMLNode.GetAttributeNamed("Visible", InNode: ButtonNode)!
                                            Board._RotateRightButtonVisisble = Bool(Show)!
                                        
                                        case "Freeze":
                                            let FreezeA = XMLNode.GetAttributeNamed("Action", InNode: ButtonNode)!
                                            Board.FreezeButton = FreezeButtonActions(rawValue: FreezeA)!
                                        
                                        default:
                                            print("Unexpected button type (\(ButtonNode.Name)) found.")
                                    }
                            }
                            
                            default:
                                print("Encountered unexpected node in board \(BucketS): \(BoardChild.Name)")
                                break
                        }
                    }
            }
            default:
                break
        }
    }
    
    /// Returns the specified number of spaces in a string.
    /// - Parameter Count: Number of spaces to return.
    /// - Returns: Specified number of spaces.
    private func Spaces(_ Count: Int) -> String
    {
        var Working = ""
        for _ in 0 ..< Count
        {
            Working = Working + " "
        }
        return Working
    }
    
    /// Returns the passed string surrounded by quotation marks.
    /// - Parameter Raw: The string to return surrounded by quotation marks.
    /// - Returns: `Raw` surrounded by quotation marks.
    private func Quoted(_ Raw: String) -> String
    {
        return "\"\(Raw)\""
    }
}
