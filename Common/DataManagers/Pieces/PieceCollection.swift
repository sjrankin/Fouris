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
class PieceCollection: XMLDeserializeProtocol
{
    init()
    {
        _Classes = [PieceClasses: [PieceDefinition2]]()
    }
    
    /// Holds a dictionary of piece class piece definitions.
    private var _Classes: [PieceClasses: [PieceDefinition2]] = [PieceClasses: [PieceDefinition2]]()
    /// Get or set the dictionary of piece class piece definitions.
    public var Classes: [PieceClasses: [PieceDefinition2]]
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
    public func GetPieceClass(_ PieceClass: PieceClasses) -> [PieceDefinition2]?
    {
        return Classes[PieceClass]
    }
    
    // MARK: Serialization and deserialization.
    
    /// Deserialize from the passed node.
    func DeserializedNode(_ Node: XMLNode)
    {
        switch Node.Name
        {
            case "Pieces":
                for PieceNode in Node.Children
                {
                    if PieceNode.Name == "PieceClass"
                    {
                        let ClassName = XMLNode.GetAttributeNamed("Type", InNode: PieceNode)!
                        let PieceClass = PieceClasses(rawValue: ClassName)!
                        if _Classes[PieceClass] == nil
                        {
                            _Classes[PieceClass] = [PieceDefinition2]()
                        }
                        for Child in PieceNode.Children
                        {
                            if Child.Name == "Piece"
                            {
                                let PieceName = XMLNode.GetAttributeNamed("Name", InNode: Child)!
                                let RawPieceID = XMLNode.GetAttributeNamed("ID", InNode: Child)!
                                let PieceID = UUID(uuidString: RawPieceID)!
                                let NewPiece = PieceDefinition2()
                                NewPiece.ID = PieceID
                                NewPiece.PieceClass = PieceClass
                                NewPiece.Name = PieceName
                                _Classes[PieceClass]?.append(NewPiece)
                                for PieceChild in Child.Children
                                {
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
}
