//
//  LogEntry.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/12/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Encapsulates a single entry in the activity log.
class LogEntry: CustomStringConvertible
{
    /// Default initializer.
    init()
    {
    }
    
    /// Initializer.
        /// - Parameter Title: Title of the entry. Also functions as the XML node name.
    init(Title: String)
    {
        _Title = Title
    }
    
    /// Initializer.
    /// - Parameter Title: Title of the entry. Also functions as the XML node name.
    /// - Parameter KVPList: List of key-value pairs that will form the attribute list of the XML node.
    init(Title: String, KVPList: [(String, String)])
    {
        _Title = Title
        _KVP = KVPList
    }
    
    /// Initializer.
    /// - Parameter Title: Title of the entry. Also functions as the XML node name.
    /// - Parameter Source: The source of the entry.
    init(Title: String, Source: String)
    {
        _Title = Title
        _Source = Source
    }

    /// Initializer.
    /// - Parameter Title: Title of the entry. Also functions as the XML node name.
    /// - Parameter Source: The source of the entry.
    /// - Parameter KVPList: List of key-value pairs that will form the attribute list of the XML node.
    init(Title: String, Source: String, KVPList: [(String, String)])
    {
        _Title = Title
        _Source = Source
        _KVP = KVPList
    }
    
    /// Holds the title.
    private var _Title: String = ""
    /// Get or set the title of the entry. Also functions as the XML node name. If not present,
    /// when the entry is written, "`Entry`" will be used instead of the contents of this property.
    public var Title: String
    {
        get
        {
            return _Title
        }
        set
        {
            _Title = newValue
        }
    }
    
    /// Holds the entry source.
    private var _Source: String? = nil
    /// Get or set the source of the entry.
    public var Source: String?
    {
        get
        {
            return _Source
        }
        set
        {
            _Source = newValue
        }
    }
    
    /// Add a key-value pair to the entry's key-value pair list.
    /// - Note:
    ///   - Keys with the value of one of the following will result in the passed key-value
    ///     pair not being added because they conflict with other key names.
    ///       - `Time`
    ///       - `Source`
    ///       - `Entry`
    /// - Parameter Key: The key name.
    /// - Parameter Value: The value associated with the key.
    public func AddKeyValue(Key: String, Value: String)
    {
        if ["Time", "Source", "Entry"].contains(Key)
        {
            print("\(Key)=\(Value) not added to activity log because key already present.")
            return
        }
        KVP.append((Key, Value))
    }
    
    /// Determines if the key-value list contains a key with the passed name.
    /// - Parameter Name: The key name to check for existence.
    /// - Returns: True if the name already exists, false if not.
    public func ContainsKey(Name: String) -> Bool
    {
        return KVP.filter({!($0.0 == Name)}).isEmpty
    }
    
    /// Returns the current list of key-value pairs.
    /// - Returns: List of key-value pairs.
    public func GetKVP() -> [(String, String)]
    {
        return KVP
    }
    
    /// Holds the list of key-value pairs.
    private var _KVP: [(String, String)] = [(String, String)]()
    /// Get or set the list of key-value pairs. This is private in order to enforce key name
    /// exclusion policies.
    private var KVP: [(String, String)]
    {
        get
        {
            return _KVP
        }
        set
        {
            _KVP = newValue
        }
    }
    
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
    
    /// Returns the entry as an XML fragment.
    /// - Parameter Indent: Number of spaces to indent the returned string. Default is 4.
    /// - Parameter AddTerminalReturn: If true, a return is added to the string before it is returned.
    ///             Default is true.
    public func ToString(Indent: Int = 4, AddTerminalReturn: Bool = true) -> String
    {
        var Working = ""
        if Title.isEmpty
        {
            Working.append(Spaces(Indent) + "<Entry")
        }
        else
        {
            Working.append(Spaces(Indent) + "<" + Title)
        }
        Working.append(" Time=" + Quoted(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .long)))
        if let ItemSource = Source
        {
            if !ItemSource.isEmpty
            {
            Working.append(" Source=" + Quoted(ItemSource))
            }
        }
        for (Key, Value) in KVP
        {
            Working.append(" \(Key)=" + Quoted(Value))
        }
        
        Working.append(">")
        if AddTerminalReturn
        {
            Working.append("\n")
        }
        return Working
    }
    
    /// Returns a string description of the contents of this instance in the form of an
    /// XML fragment.
    public var description: String
    {
        get
        {
            return ToString(Indent: 0, AddTerminalReturn: false)
        }
    }
}
