//
//  BoardCollection.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/14/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class BoardCollection: CustomStringConvertible, XMLDeserializeProtocol
{
    private var _BoardList: [BoardDescriptor2] = [BoardDescriptor2]()
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
    
    func DeserializedNode(_ Node: XMLNode)
    {
        
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
    
    public func ToString(AddTerminalReturn: Bool = true) -> String
    {
        return ""
    }
    
    public var description: String
    {
        get
        {
            return ToString()
        }
    }
}
