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
    
    
    init()
    {
        _Classes = [PieceClasses: [PieceDefinition]]()
    }
    
    /// Holds a dictionary of piece class piece definitions.
    private var _Classes: [PieceClasses: [PieceDefinition]] = [PieceClasses: [PieceDefinition]]()
    /// Get or set the dictionary of piece class piece definitions.
    public var Classes: [PieceClasses: [PieceDefinition]]
    {
        get
        {
            return _Classes
        }
        set
        {
            _Classes = newValue
        }
    }
    
    /// Return a list of all pieces in the specified piece class.
    /// - Parameter PieceClass: The piece class whose pieces will be returned.
    /// - Returns: All pieces in the specified piece class. Nil if the piece class cannot be found.
    public func GetPieceClass(_ PieceClass: PieceClasses) -> [PieceDefinition]?
    {
        return Classes[PieceClass]
    }
    
    /// Holds the group/collection name.
    private var _GroupName: String = ""
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
                for PieceNode in Node.Children
                {
                    if PieceNode.Name == "PieceClass"
                    {
                        let ClassName = XMLNode.GetAttributeNamed("Type", InNode: PieceNode)!
                        let PieceClass = PieceClasses(rawValue: ClassName)!
                        if _Classes[PieceClass] == nil
                        {
                            _Classes[PieceClass] = [PieceDefinition]()
                        }
                        for Child in PieceNode.Children
                        {
                            if Child.Name == "Piece"
                            {
                                let PieceName = XMLNode.GetAttributeNamed("Name", InNode: Child)!
                                let RawPieceID = XMLNode.GetAttributeNamed("ID", InNode: Child)!
                                let CanDelete = XMLNode.GetAttributeNamed("CanDelete", InNode: Child)
                                let PieceID = UUID(uuidString: RawPieceID)!
                                let NewPiece = PieceDefinition()
                                NewPiece.ID = PieceID
                                NewPiece.PieceClass = PieceClass
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
                                _Classes[PieceClass]?.append(NewPiece)
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
        for (SomeClass, Pieces) in Classes
        {
            let ClassName = "\(SomeClass)"
            Working = Working + Spaces(Indent) + "<PieceClass Type=" + Quoted(ClassName) + ">\n"
            
            let NextDent = Indent + 4
            for ClassPiece in Pieces
            {
                Working = Working + ClassPiece.ToString(IndentSize: NextDent)
            }
            
            Working = Working + Spaces(Indent) + "</PieceClass>\n"
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
