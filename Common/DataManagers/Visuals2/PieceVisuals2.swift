//
//  PieceVisuals2.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains a set of piece visuals. The user version of the source may also contain user-defined visuals.
class PieceVisuals2: CustomStringConvertible, XMLDeserializeProtocol
{
    /// Holds the dirty flag.
    private var _Dirty: Bool = false
    /// Get or set the dirty flag.
    public var Dirty: Bool
    {
        get
        {
            return _Dirty
        }
        set
        {
            _Dirty = newValue
        }
    }
    
    /// Holds the ID of the set of visuals.
    private var _VisualsID: UUID = UUID.Empty
    /// Get or set the visuals ID, from the XMLDocument source.
    public var VisualsID: UUID
    {
        get
        {
            return _VisualsID
        }
        set
        {
            _VisualsID = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the set of visuals.
    private var _VisualsName: String = ""
    /// Get or set the name of the visuals.
    public var VisualsName: String
    {
        get
        {
            return _VisualsName
        }
        set
        {
            _VisualsName = newValue
            _Dirty = true
        }
    }
    
    /// Holds the user visuals flag.
    private var _UserVisuals: Bool = false
    /// Get or set the flag that indicates whether this is a user-defined visual file or not.
    public var UserVisuals: Bool
    {
        get
        {
            return _UserVisuals
        }
        set
        {
            _UserVisuals = newValue
            _Dirty = true
        }
    }
    
    private var _Updated: String = ""
    public var Updated: String
    {
        get
        {
            return _Updated
        }
        set
        {
            _Updated = newValue
            _Dirty = true
        }
    }
    
    /// Holds the set of visuals.
    private var _Visuals: [PieceVisual2] = [PieceVisual2]()
    /// Get or set the array of visuals.
    public var Visuals: [PieceVisual2]
    {
        get
        {
            return _Visuals
        }
        set
        {
            _Visuals = newValue
            _Dirty = true
        }
    }
    
    /// Returns the visuals for the piece type indicated by the passed ID.
    /// - Parameter ID: ID of the visuals to return. This is the same as the shape's ID.
    /// - Returns: The PieceVisual on success, nil if not found.
    public func GetVisualWith(ID: UUID) -> PieceVisual2?
    {
        for Visual in Visuals
        {
            if Visual.PieceID == ID
            {
                return Visual
            }
        }
        return nil
    }
    
    /// Holds a cache of returned visuals, keyed by the piece ID.
    private var CachedVisuals: [UUID: PieceVisual2] = [UUID: PieceVisual2]()
    
    /// Returns a cached `PieceVisual`.
    /// - Note: If the specified `PieceVisual` is not in the cache, the full array of `PieceVisual`s is searched and if found,
    ///         is cached for later use.
    /// - Parameter ID: ID of the `PieceVisual` to return.
    /// - Returns: A `PieceVisual` from the set of cached visuals.
    public func GetCachedVisualWith(ID: UUID) -> PieceVisual2?
    {
        if let CachedVisual = CachedVisuals[ID]
        {
            return CachedVisual
        }
        if let NonCachedVisual = GetVisualWith(ID: ID)
        {
            CachedVisuals[ID] = NonCachedVisual
            return NonCachedVisual
        }
        return nil
    }
    
    // MARK: Deserialization.
    
    /// Deserialize an `XMLDocument` that contains a set of visual pieces.
    /// - Parameter Node: The node to deserialize.
    func DeserializedNode(_ Node: XMLNode)
    {
        switch Node.Name
        {
            case "PieceVisuals":
                let RawName = XMLNode.GetAttributeNamed("Name", InNode: Node)!
                _VisualsName = RawName
                let IsUserVisual = XMLNode.GetAttributeNamed("UserVisuals", InNode: Node)!
                _UserVisuals = Bool(IsUserVisual)!
                let RawID = XMLNode.GetAttributeNamed("ID", InNode: Node)!
                _VisualsID = UUID(uuidString: RawID)!
                let UpdateDate = XMLNode.GetAttributeNamed("Updated", InNode: Node)!
                _Updated = UpdateDate
                
                for Child in Node.Children
                {
                    if Child.Name == "PieceVisual"
                    {
                        let NewVisual = PieceVisual2()
                        let PieceID = XMLNode.GetAttributeNamed("PieceID", InNode: Child)!
                        NewVisual._PieceID = UUID(uuidString: PieceID)!
                        let PieceName = XMLNode.GetAttributeNamed("Name", InNode: Child)!
                        NewVisual._PieceName = PieceName
                        let UserPiece = XMLNode.GetAttributeNamed("UserPiece", InNode: Child)!
                        NewVisual._UserPiece = Bool(UserPiece)!
                        for GrandChild in Child.Children
                        {
                            let NewStateVisual = StateVisual()
                            switch GrandChild.Name
                            {
                                case "Active":
                                    NewStateVisual._VisualType = .Active
                                    for VChild in GrandChild.Children
                                    {
                                        switch VChild.Name
                                        {
                                            case "Colors":
                                                let DiffuseName = XMLNode.GetAttributeNamed("Diffuse", InNode: VChild)!
                                                NewStateVisual._DiffuseColor = DiffuseName
                                                let SpecularName = XMLNode.GetAttributeNamed("Specular", InNode: VChild)!
                                                NewStateVisual._SpecularColor = SpecularName
                                            
                                            case "Textures":
                                                let DiffuseName = XMLNode.GetAttributeNamed("Diffuse", InNode: VChild)!
                                                NewStateVisual._DiffuseTexture = DiffuseName
                                                let SpecularName = XMLNode.GetAttributeNamed("Specular", InNode: VChild)!
                                                NewStateVisual._SpecularTexture = SpecularName
                                            
                                            default:
                                                break
                                        }
                                }
                                    NewVisual._ActiveVisuals = NewStateVisual
                                
                                case "Retired":
                                    NewStateVisual._VisualType = .Retired
                                    for VChild in GrandChild.Children
                                    {
                                        switch VChild.Name
                                        {
                                            case "Colors":
                                                let DiffuseName = XMLNode.GetAttributeNamed("Diffuse", InNode: VChild)!
                                                NewStateVisual._DiffuseColor = DiffuseName
                                                let SpecularName = XMLNode.GetAttributeNamed("Specular", InNode: VChild)!
                                                NewStateVisual._SpecularColor = SpecularName
                                            
                                            case "Textures":
                                                let DiffuseName = XMLNode.GetAttributeNamed("Diffuse", InNode: VChild)!
                                                NewStateVisual._DiffuseTexture = DiffuseName
                                                let SpecularName = XMLNode.GetAttributeNamed("Specular", InNode: VChild)!
                                                NewStateVisual._SpecularTexture = SpecularName
                                            
                                            default:
                                                break
                                        }
                                }
                                    NewVisual._RetiredVisuals = NewStateVisual
                                
                                default:
                                break
                            }
                        }
                        Visuals.append(NewVisual)
                    }
            }
            
            default:
                break
        }
    }
    
    // MARK: Serialization.
    
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
    
    /// Returns the contents of the class as an XML document.
    /// - Parameter AppendTerminalReturn: If true a return is appended to the result before returning it.
    /// - Returns: XML document of the contents of the class.
    public func ToString(AppendTerminalReturn: Bool = true) -> String
    {
        var Working = ""
        Working.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")
        Working.append("<PieceVisuals PieceID=" + Quoted(VisualsID.uuidString) +
            " UserVisuals=" + Quoted("\(UserVisuals)") + " Name=" + Quoted(VisualsName) +
            " Updated=" + Quoted(Updated) + ">\n")
        for Visual in Visuals
        {
            Working.append(Visual.ToString(Indent: 4, AppendTerminalReturn: true))
        }
        Working.append("</PieceVisuals>")
        if AppendTerminalReturn
        {
            Working.append("\n")
        }
        return Working
    }
    
    /// Returns the contents of the class as an XML document.
    public var description: String
    {
        get
        {
            return ToString()
        }
    }
}
