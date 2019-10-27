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
    public func DeserializedNode(_ Node: XMLNode)
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
                    for BoardChild in Child.Children
                    {
                        switch BoardChild.Name
                        {
                            case "Description":
                                let TextR = XMLNode.GetAttributeNamed("Text", InNode: BoardChild)!
                                Board._TextDescription = TextR
                            
                            case "PiecePlacement":
                                //This node is optional.
                                let Where = XMLNode.GetAttributeNamed("Location", InNode: BoardChild)!
                                Board._InitialPieceLocation = CreatePoint(From: Where)
                            
                            case "Map":
                                if ![.Simple3D].contains(Board._BucketShape)
                                {
                                    //.Cubic boards don't have a map in the board description file.
                                    Board._BoardMap = BoardChild.Value
                                }
                                if let ClearR = XMLNode.GetAttributeNamed("BucketClearRectangle", InNode: BoardChild)
                                {
                                    if let ClearPoints = CreateRectangle(From: ClearR)
                                    {
                                        Board._ClearUpperLeft = ClearPoints.0
                                        Board._ClearLowerRight = ClearPoints.1
                                    }
                            }
                                if let MapVS = XMLNode.GetAttributeNamed("Volume", InNode: BoardChild)
                                {
                                    if let V = Volume.ParseSimple(MapVS)
                                    {
                                        Board._Width3D = Int(V.Width)
                                        Board._Height3D = Int(V.Height)
                                        Board._Depth3D = Int(V.Depth)
                                    }
                            }
                            
                            case "Barriers":
                                //This is for .Cubic games. Non-.Cubic games should not have this node.
                                for BarrierChild in BoardChild.Children
                                {
                                    switch BarrierChild.Name
                                    {
                                        case "Center":
                                            let DimS = XMLNode.GetAttributeNamed("Dimensions", InNode: BarrierChild)
                                            if let V = Volume.ParseSimple(DimS!)
                                            {
                                                Board._CenterBlockDefinition = V
                                            }
                                            else
                                            {
                                                fatalError("Bad center block dimension string found: \((DimS)!)")
                                        }
                                        
                                        default:
                                            print("Unexpected node \(BarrierChild.Name) encountered in Barriers node.")
                                            break
                                    }
                            }
                            
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
    
    /// Converts a string in the format `"(x,y)"` into a CGPoint.
    /// - Parameter From: The source string.
    /// - Returns: CGPoint based on the contents of `From` on success, `CGPoint.zero` if the string
    ///            cannot be successfully parsed.
    private func CreatePoint(From: String) -> CGPoint
    {
        if From.isEmpty
        {
            return CGPoint.zero
        }
        var Raw = From.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        Raw = Raw.replacingOccurrences(of: "(", with: "")
        Raw = Raw.replacingOccurrences(of: ")", with: "")
        let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
        if Parts.count != 2
        {
            return CGPoint.zero
        }
        let XS = String(Parts[0])
        let YS = String(Parts[1])
        guard let X = Int(XS) else
        {
            return CGPoint.zero
        }
        guard let Y = Int(YS) else
        {
            return CGPoint.zero
        }
        return CGPoint(x: X, y: Y)
    }
    
    /// Parses a string in the form `(X1,Y1),(X2,Y2)` into two CGPoint structures.
    /// - Parameter From: The raw string to parse.
    /// - Returns: Tuple of CGPoint structures with data from the parsed string. Nil returned if the
    ///            string cannot be parsed.
    private func CreateRectangle(From: String) -> (CGPoint, CGPoint)?
    {
        if From.isEmpty
        {
            return nil
        }
        var Raw = From.replacingOccurrences(of: "(", with: "")
        Raw = From.replacingOccurrences(of: ")", with: "")
        Raw = Raw.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let Parts = Raw.split(separator: ",", omittingEmptySubsequences: true)
        if Parts.count != 4
        {
            return nil
        }
        let X1S = String(Parts[0])
        let Y1S = String(Parts[1])
        let X2S = String(Parts[2])
        let Y2S = String(Parts[3])
        guard let X1 = Int(X1S) else
        {
            return nil
        }
        guard let Y1 = Int(Y1S) else
        {
            return nil
        }
        guard let X2 = Int(X2S) else
        {
            return nil
        }
        guard let Y2 = Int(Y2S) else
        {
            return nil
        }
        return (CGPoint(x: X1, y: Y1), CGPoint(x: X2, y: Y2))
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
