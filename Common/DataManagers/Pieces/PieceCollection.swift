//
//  PieceCollection.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds a collection of piece definitions.
class PieceCollection: CustomStringConvertible, XMLDeserializeProtocol
{
    /// Default initializer.
    init()
    {
    }
    
    /// Holds the list of pieces in the collection.
    private var _Pieces: [PieceDefinition] = [PieceDefinition]()
    /// Get or set the list of pieces in the collection.
    public var Pieces: [PieceDefinition]
    {
        get
        {
            return _Pieces
        }
        set
        {
            _Pieces = newValue
        }
    }
    
    /// Returns a list of all pieces of the specified piece class.
    /// - Parameter PieceClass: The class of piece to return.
    /// - Returns: All pieces of the specified class. If none found, an empty list is returned.
    public func PiecesOfClass(_ PieceClass: PieceClasses) -> [PieceDefinition]
    {
        return Pieces.filter{!($0.PieceClass == PieceClass)}
    }
    
    /// Returns the piece with the specified ID.
    /// - Parameter ID: The ID of the piece to return.
    /// - Returns: The piece with the specified ID on success, nil if not found.
    public func PieceWith(ID: UUID) -> PieceDefinition?
    {
        for SomePiece in Pieces
        {
            if SomePiece.ID == ID
            {
                return SomePiece
            }
        }
        return nil
    }
    
    /// Holds the group/collection name.
    private var _GroupName: String = ""
    /// Holds the group name ID.
    private var _GroupNameID: UUID = UUID.Empty
    /// Get or set the group/collection name.
    public var GroupName: String
    {
        get
        {
            return _GroupName
        }
        set
        {
            _GroupName = newValue
        }
    }
    
    // MARK: Serialization and deserialization.
    
    /// Serialize the contents of the piece collection to an XMLDocument.
    func Serialize() -> XMLDocument
    {
        return XMLDocument()
    }
    
    /// Deserialize from the passed node.
    func DeserializedNode(_ Node: XMLNode)
    {
        switch Node.Name
        {
            case "Pieces":
                let CollectionName = XMLNode.GetAttributeNamed("GroupName", InNode: Node)!
                _GroupName = CollectionName
                _GroupNameID = Node.ID
                
                for Child in Node.Children
                {
                    if Child.Name == "Piece"
                    {
                        let PieceName = XMLNode.GetAttributeNamed("Name", InNode: Child)!
                        let RawPieceID = XMLNode.GetAttributeNamed("ID", InNode: Child)!
                        //CanDelete must be an optional variable to test for its existence in the document.
                        let CanDelete = XMLNode.GetAttributeNamed("CanDelete", InNode: Child)
                        let ClassName = XMLNode.GetAttributeNamed("Class", InNode: Child)!
                        let PieceID = UUID(uuidString: RawPieceID)!
                        let NewPiece = PieceDefinition()
                        NewPiece.ID = PieceID
                        NewPiece.PieceClass = PieceClasses(rawValue: ClassName)!
                        NewPiece.Name = PieceName
                        if CanDelete != nil
                        {
                            let CanReallyDelete: Bool = Bool(CanDelete!)!
                            NewPiece.CanDelete = CanReallyDelete
                        }
                        else
                        {
                            NewPiece.CanDelete = false
                        }
                        _Pieces.append(NewPiece)
                        for PieceChild in Child.Children
                        {
                            if PieceChild.NodeType == .Comment
                            {
                                let Comment = PieceChild.Value
                                NewPiece.CommentNodes.append(Comment)
                                continue
                            }
                            if !PieceChild.Value.isEmpty && PieceChild.Name == "Piece"
                            {
                                NewPiece.NodePayload = PieceChild.Value
                            }
                            switch PieceChild.Name
                            {
                                case "UserPiece":
                                    let RawIsUser = XMLNode.GetAttributeNamed("UserDefined", InNode: PieceChild)!
                                    let IsUser = Bool(RawIsUser)!
                                    NewPiece.IsUserPiece = IsUser
                                
                                case "Geometry":
                                    let RawThin = XMLNode.GetAttributeNamed("Thin", InNode: PieceChild)!
                                    let IsThin = Int(RawThin)!
                                    NewPiece.ThinOrientation = IsThin
                                    let RawWide = XMLNode.GetAttributeNamed("Wide", InNode: PieceChild)!
                                    let IsWide = Int(RawWide)!
                                    NewPiece.WideOrientation = IsWide
                                    let RawSymmetry = XMLNode.GetAttributeNamed("Symmetric", InNode: PieceChild)!
                                    let RotationallySymmetric = Bool(RawSymmetry)!
                                    NewPiece.RotationallySymmetric = RotationallySymmetric
                                
                                case "LogicalLocations":
                                    if PieceChild.NodeType == .Comment
                                    {
                                        NewPiece.LocationComments.append(PieceChild.Value)
                                        continue
                                    }
                                    if !PieceChild.Value.isEmpty
                                    {
                                        NewPiece.LocationPayload = PieceChild.Value
                                    }
                                    for Location in PieceChild.Children
                                    {
                                        let NewLocation = PieceBlockLocation()
                                        let RawIndex = XMLNode.GetAttributeNamed("Index", InNode: Location)!
                                        let Index = Int(RawIndex)!
                                        NewLocation.Index = Index
                                        let RawOrigin = XMLNode.GetAttributeNamed("IsOrigin", InNode: Location)!
                                        let IsOrigin = Bool(RawOrigin)!
                                        NewLocation.IsOrigin = IsOrigin
                                        let RawXY = XMLNode.GetAttributeNamed("XY", InNode: Location)!
                                        let Parts = RawXY.split(separator: ",", omittingEmptySubsequences: true)
                                        if Parts.count != 2
                                        {
                                            fatalError("Found invalid XY coordinate: \(RawXY)")
                                        }
                                        
                                        var X: Int = 0
                                        var Y: Int = 0
                                        if let PX = Int(String(Parts[0]))
                                        {
                                            X = PX
                                        }
                                        else
                                        {
                                            fatalError("Invalid X coordinate in \(RawXY)")
                                        }
                                        if let PY = Int(String(Parts[1]))
                                        {
                                            Y = PY
                                        }
                                        else
                                        {
                                            fatalError("Invalid Y coordinate in \(RawXY)")
                                        }
                                        let NewPoint = Point3D<Int>(X, Y)
                                        NewLocation.Coordinates = NewPoint
                                        NewPiece.Locations.append(NewLocation)
                                }
                                
                                default:
                                    break
                            }
                        }
                    }
            }
            
            default:
                return
        }
    }
    
    // MARK: CustomStringConvertible functions and related
    
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
    
    /// Converts the contents of this collection into an XML document string.
    /// - Parameter IncludeDocumentHeader: If true, a standard (and minimal) XML document header is appended to the beginning of
    ///                                    the returned string.
    /// - Parameter AddTerminalReturn: If true, a return character is added to the end of the returned string.
    /// - Returns: XML document populated with the contents of the class instance.
    func ToString(IncludeDocumentHeader: Bool = true, AddTerminalReturn: Bool = true) -> String
    {
        var Working = ""
        if IncludeDocumentHeader
        {
            Working = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        }
        Working = Working + "<Pieces GroupName=" + Quoted(GroupName) + ">\n"
        
        let Indent = 4
        
        for SomePiece in Pieces
        {
            Working = Working + SomePiece.ToString(IndentSize: Indent + 4)
        }
        
        Working = Working + "</Pieces>"
        if AddTerminalReturn
        {
            Working = Working + "\n"
        }
        return Working
    }
    
    /// Returns a description of the class suitable for printint.
    /// - Note: Calls `ToString()`.
    public var description: String
    {
        return ToString()
    }
}
