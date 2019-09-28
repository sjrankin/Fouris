//
//  XMLKVP.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Encapsulates an XML key-value pair. Also provides parsing and writing functionality.
class XMLKVP: CustomStringConvertible
{
    /// Default intializer.
    init()
    {
        _Key = ""
        Value = ""
    }
    
    /// Failable initializer.
    /// - Note: If `RawValue` cannot be parsed correctly, this initializer returns nil.
    /// - Parameter RawValue: The raw value to parse.
    init?(RawValue: String)
    {
        if Parse(Raw: RawValue) != .NoError
        {
            return nil
        }
    }
    
    /// Initializer.
    /// - Parameter WithKey: Name of the key.
    /// - Parameter WithValue: Initial value of the key.
    init(WithKey: String, WithValue: String)
    {
        _Key = WithKey
        _Value = WithValue
    }
    
    /// Holds the key's name.
    private var _Key: String = ""
    /// Get the key name.
    public var Key: String
    {
        get
        {
            return _Key
        }
    }
    
    /// Holds the value part of the KVP.
    private var _Value: String = ""
    /// Get or set the value.
    public var Value: String
    {
        get
        {
            return _Value
        }
        set
        {
            _Value = newValue
        }
    }
    
    /// Converts the contents of the KVP to a string in the format: `Key="Value"`.
    /// - Returns: XML-representable string of the key-value pair on success, empty string on error.
    public func ToString() -> String
    {
        if Key.isEmpty
        {
            return ""
        }
        let Result = "\(Key)=\"\(Value)\""
        return Result
    }
    
    /// Returns the contents of the class as a string in the format: `Key="Value"`.
    var description: String
    {
        return ToString()
    }
    
    /// Parse the raw string into a key and value parts.
    /// - Parameter Raw: The raw string to parse.
    /// - Returns: A value indicating success or failure. If failure, the value will indicate *why* the parse failed.
    public func Parse(Raw: String) -> KVPErrors
    {
        if Raw.isEmpty
        {
            return .EmptyRawData
        }
        if !Raw.contains("=")
        {
            return .MissingEqualitySign
        }
        let Parts = Raw.split(separator: "=", maxSplits: 1, omittingEmptySubsequences: true)
        if Parts.count != 2
        {
            return .IncorrectPartCount
        }
        _Key = String(Parts[0]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        var ValueX = String(Parts[1]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if ValueX.first != "\""
        {
            return .MissingValueOpeningQuote
        }
        if ValueX.last != "\""
        {
            return .MissingValueClosingQuote
        }
        ValueX.removeFirst()
        ValueX.removeLast()
        Value = ValueX
        return .NoError
    }
    
    /// Success and failure codes for key-value pair parsing.
    /// - **NoError**: No error - success in parsing.
    /// - **MissingValueOpeningQuote**: The raw value's `value` part did not have an opening quote, for example: `key=value"`.
    /// - **MissingValueClosingQuote**: The raw value's `value` part did not have a closing quote, for example: `key="value`.
    /// - **IncorrectPartCount**: The raw value's `value` part was most likely empty - for example, `key=`. It is also possible
    ///                           a missing `key` will generate this error, for example, `="value"`.
    /// - **MisingEqualitySign**: The raw value did not contain an equality sign.
    /// - **EmptyRawData**: The raw data passed to the parsing function was empty.
    enum KVPErrors: String, CaseIterable
    {
        case NoError = "NoError"
        case MissingValueOpeningQuote = "MissingOpeningQuote"
        case MissingValueClosingQuote = "MissingClosingQuote"
        case IncorrectPartCount = "IncorrectPartCount"
        case MissingEqualitySign = "MissingEqualitySign"
        case EmptyRawData = "EmptyRawData"
    }
}
