//
//  PieceVisuals.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PieceVisuals
{
    init()
    {
        _IsDirty = false
    }
    
    private var _IsDirty: Bool = false
    public var IsDirty: Bool
    {
        get
        {
            return _IsDirty
        }
        set
        {
            _IsDirty = newValue
        }
    }
    
    // MARK: Deserialization protocol implementation.
    
    /// Sanitizes the passed string by removing all quotation marks.
    /// - Parameter Raw: The string to sanitize.
    /// - Returns: Sanitized string.
    func Sanitize(_ Raw: String) -> String
    {
        let Done = Raw.replacingOccurrences(of: "\"", with: "")
        return Done
    }
    
    /// Called by the deserializer once for each property to populate.
    ///
    /// - Parameters:
    ///   - Key: Name of the property to populate.
    ///   - Value: Value of the property in string format. We are responsible for type conversions.
    func Populate(Key: String, Value: String)
    {
        let Sanitized = Sanitize(Value)
        switch Key
        {
            case "_ID":
            //UUID
            _ID = UUID(uuidString: Sanitized)!
            
            case "_UserVisual":
            //Bool
            _UserVisual = Bool(Sanitized)!
            
            default:
            break
        }
    }
    
    private var _ID: UUID = UUID.Empty
    public var ID: UUID
    {
        get
        {
            return _ID
        }
    }
    
    private var _UserVisual: Bool = false
    public var UserVisual: Bool
    {
        get
        {
            return _UserVisual
        }
    }
    
    private var _VisualsList = [VisualDescriptor](repeating: VisualDescriptor(), count: 30)
    public var VisualsList: [VisualDescriptor]
    {
        get
        {
            return _VisualsList
        }
        set
        {
            _VisualsList = newValue
            _IsDirty = true
        }
    }
}
