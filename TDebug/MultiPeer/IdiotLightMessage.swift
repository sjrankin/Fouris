//
//  IdiotLightMessage.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/11/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains information on how to set an idiot light.
class IdiotLightMessage
{
    /// Holds the address of the idiot light.
    private var _Address: String = ""
    /// Get or set the address of the idiot light.
    public var Address: String
    {
        get
        {
            return _Address
        }
        set
        {
            _Address = newValue
        }
    }
    
    /// Holds the text of the idiot light.
    private var _Message: String = ""
    /// Get or set the idiot light text.
    public var Message: String
    {
        get
        {
            return _Message
        }
        set
        {
            _Message = newValue
        }
    }
    
    /// Holds the foreground color of the idiot light.
    private var _FGColor: UIColor? = nil
    /// Get or set the foreground color for the idiot light.
    public var FGColor: UIColor?
    {
        get
        {
            return _FGColor
        }
        set
        {
            _FGColor = newValue
        }
    }
    
    /// Holds the background color of the idiot light.
    private var _BGColor: UIColor? = nil
    /// Get or set the background color for the idiot light.
    public var BGColor: UIColor?
    {
        get
        {
            return _BGColor
        }
        set
        {
            _BGColor = newValue
        }
    }
}
