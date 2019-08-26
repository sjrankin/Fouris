//
//  BoardDescriptor.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains one board's definition read from `BoardDescriptions.xml`.
class BoardDescriptor: Serializable
{
    /// Default initializer.
    init()
    {
    }
    
    /// Sanitize the passed string such that no quotation marks are in it.
    ///
    /// - Parameter Raw: The string to sanitize.
    /// - Returns: Sanitized string.
    func Sanitize(_ Raw: String) -> String
    {
        let Done = Raw.replacingOccurrences(of: "\"", with: "")
        return Done
    }
    
    /// Called by the deserializer. Populates the class, one property at a time.
    ///
    /// - Parameters:
    ///   - Key: The name of the property to populate.
    ///   - Value: The value of the property.
    func Populate(Key: String, Value: String)
    {
        let Sanitized = Sanitize(Value)
        switch Key
        {
            case "_Name":
                //String
                _Name = Sanitized
            
            case "_ID":
                //UUID
                _ID = UUID(uuidString: Sanitized)!
            
            case "_BaseDefault":
                //Bool
                _BaseDefault = Bool(Sanitized)!
            
            case "_BaseGame":
                //BaseGameTypes
                _BaseGame = BaseGameTypes(rawValue: Sanitized)!
            
            case "_BoardSize":
                //Two comma-separated numbers.
                let Values = SplitStringIntoDoubles(Sanitized, With: ",", ExpectedCount: 2)
                _BoardSize = CGSize(width: Values[0], height: Values[1])
            
            case "_BucketUL":
                //Two comma-separated numbers.
                let Values = SplitStringIntoDoubles(Sanitized, With: ",", ExpectedCount: 2)
                _BucketUL = CGPoint(x: Values[0], y: Values[1])
            
            case "_BucketLR":
                //Two comma-separated numbers.
                let Values = SplitStringIntoDoubles(Sanitized, With: ",", ExpectedCount: 2)
                _BucketLR = CGPoint(x: Values[0], y: Values[1])
            
            case "_CanRotate":
                //Bool
                _CanRotate = Bool(Sanitized)!
            
            case "_BucketBlockCount":
                //Int
                _BucketBlockCount = Int(Sanitized)!
            
            default:
                break
        }
    }
    
    /// Holds the name of the board.
    private var _Name: String = ""
    /// Get or set the (human-readable) name of the bucket.
    public var Name: String
    {
        get
        {
            return _Name
        }
        set
        {
            _Name = newValue
        }
    }
    
    /// Holds the ID of the board.
    private var _ID: UUID = UUID.Empty
    /// Get or set the ID of the board.
    public var ID: UUID
    {
        get
        {
            return _ID
        }
        set
        {
            _ID = newValue
        }
    }
    
    /// Holds the flag that determines if this board is the default board for the base game type.
    private var _BaseDefault: Bool = false
    /// Get or set the flag that determines if this board is the default board for the board's base game type.
    public var BaseDefault: Bool
    {
        get
        {
            return _BaseDefault
        }
        set
        {
            _BaseDefault = newValue
        }
    }
    
    /// Holds the board's base game type.
    private var _BaseGame: BaseGameTypes = .Standard
    /// Get or set the board's base game type.
    public var BaseGame: BaseGameTypes
    {
        get
        {
            return _BaseGame
        }
        set
        {
            _BaseGame = newValue
        }
    }
    
    /// Holds the rotational flag.
    private var _CanRotate: Bool = false
    /// Get or set the flag that determines whether the board can rotate.
    public var CanRotate: Bool
    {
        get
        {
            return _CanRotate
        }
        set
        {
            _CanRotate = newValue
        }
    }
    
    /// Holds the board size.
    private var _BoardSize: CGSize = CGSize.zero
    /// Get or set the board size. The values in the structure should be typecast to `Int`s.
    public var BoardSize: CGSize
    {
        get
        {
            return _BoardSize
        }
        set
        {
            _BoardSize = newValue
        }
    }
    
    /// Holds the upper-left corner of the bucket area.
    private var _BucketUL: CGPoint = CGPoint.zero
    /// Get or set the upper-left corner of the bucket area. The values in the structure should be typecast to `Int`s.
    public var BucketUL: CGPoint
    {
        get
        {
            return _BucketUL
        }
        set
        {
            _BucketUL = newValue
        }
    }
    
    /// Holds the lower-right corner of the bucket area.
    private var _BucketLR: CGPoint = CGPoint.zero
        /// Get or set the lower-right corner of the bucket area. The values in the structure should be typecast to `Int`s.
    public var BucketLR: CGPoint
    {
        get
        {
            return _BucketLR
        }
        set
        {
            _BucketLR = newValue
        }
    }
    
    /// Holds the number of bucket blocks. Setting this value creates the bucket block list.
    private var _BucketBlockCount: Int = 0
    {
        didSet
        {
            _BucketBlockList = [CGPoint](repeating: CGPoint.zero, count: _BucketBlockCount)
        }
    }
    /// Get or set the number of bucket blocks.
    public var BucketBlockCount: Int
    {
        get
        {
            return _BucketBlockCount
        }
        set
        {
            _BucketBlockCount = newValue
        }
    }
    
    /// Holds the list of bucket block points.
    private var _BucketBlockList = [CGPoint]()
    /// Get or set the list of bucket block points. Values in each point should be typecast to `Int`.
    public var BucketBlockList: [CGPoint]
    {
        get
        {
            return _BucketBlockList
        }
        set
        {
            _BucketBlockList = newValue
        }
    }
    
    /// Splits a string into an array of double values.
    ///
    /// - Note:
    ///    - The string is assumed to containly only double values separated by the `With` character.
    ///    - A fatal error is generated if:
    ///       - The number of found values is not the same as the expected number of values found
    ///         in `ExpectedCount`.
    ///       - A value fails to be converted into a Double.
    ///
    /// - Parameter Raw: The string to split.
    /// - Parameter With: The separator between the values.
    /// - Parameter ExpectedCount: The expected number of returned values.
    /// - Returns: Array of values in the same order as the source.
    func SplitStringIntoDoubles(_ Raw: String, With: String, ExpectedCount: Int) -> [Double]
    {
        let Parts = Raw.split(separator: Character(With), omittingEmptySubsequences: true)
        if Parts.count != ExpectedCount
        {
            DebugClient.FatalError("Unexpected number of string sub-components found. Expected \(ExpectedCount) but found \(Parts.count)",
                InFile: #file, InFunction: #function, OnLine: #line)
        }
        var Results = [Double]()
        var Index = 0
        for Part in Parts
        {
            if let SomeDouble = Double(Part)
            {
                Results.append(SomeDouble)
            }
            else
            {
                DebugClient.FatalError("Error converting \(String(Part)) to Double type at index \(Index)",
                    InFile: #file, InFunction: #function, OnLine: #line)
            }
            Index = Index + 1
        }
        return Results
    }
}
