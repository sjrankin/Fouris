//
//  TileDescriptor.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class TileDescriptor: Serializable
{
    /// Default initializer.
    init()
    {
        _Dirty = false
    }
    
    /// Hold the dirty flag.
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
    
    // MARK: Serialization/Deserialization functions.
    
    /// Sanitize the passed string to remove unneeded quotation marks.
    ///
    /// - Parameter Raw: The string to sanitize.
    /// - Returns: New string with quotation marks removed.
    func Sanitize(_ Raw: String) -> String
    {
        let Done = Raw.replacingOccurrences(of: "\"", with: "")
        return Done
    }
    
    /// Called by the deserialized to populate the class.
    ///
    /// - Note:
    ///   - Populating the class consists of multiple calls to this function with key/value pairs. The key is the name
    ///     of the property to populate (derived from when the class was serialized) and the Value is the string representation
    ///     of the value of the property. This function converts to the appropriate type.
    ///   - If the names of the properties change or if a property (or properties) is removed or new properties added, serialized
    ///     data may not be properly restored in this function.
    ///
    /// - Parameters:
    ///   - Key: The key name, which is the name of the property underwhich the value was serialized.
    ///   - Value: The value of the property/key, in string format.
    func Populate(Key: String, Value: String)
    {
        let Sanitized = Sanitize(Value)
        switch Key
        {
            case "_PieceShapeID":
                //UUID
                _PieceShapeID = UUID(uuidString: Sanitized)!
            
            default:
            break
        }
    }
    
    private var _PieceShapeID: UUID = UUID.Empty
    public var PieceShapeID: UUID
    {
        get
        {
            return _PieceShapeID
        }
        set
        {
            _PieceShapeID = newValue
        }
    }
}
