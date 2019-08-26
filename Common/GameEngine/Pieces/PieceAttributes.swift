//
//  PieceAttributes.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/4/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds a set of visual attributes and associated attribute-like values for a given piece.
class PieceAttributes
{
    /// Initialier.
    ///
    /// - Parameter ID: ID of the source piece.
    init(ID: UUID)
    {
        _PieceID = ID
        //Preload attributes that are needed at first use (eg, it's possible they will be read before
        //they are set).
        CommonValues[.OutOfBounds] = false
    }
    
    /// Checks for the presence of the specified key in the specified attribute type list.
    ///
    /// - Parameters:
    ///   - Key: The key to look for.
    ///   - InDictionary: The dictionary of attribute data to look at for the key.
    /// - Returns: True if the key exists in the specified attribute dictionary, false if not.
    public func ContainsKey(_ Key: ValueTypes, InDictionary: AttributeTypes) -> Bool
    {
        switch InDictionary
        {
        case .Common:
            return CommonValues.keys.contains(Key)
            
        case .TwoD:
            return TwoDValues.keys.contains(Key)
            
        case .ThreeD:
            return ThreeDValues.keys.contains(Key)
        }
    }
    
    /// Holds the ID of the piece.
    private var _PieceID: UUID = UUID()
    /// Get or set the ID of the piece associated with this attribute.
    public var PieceID: UUID
    {
        get
        {
            return _PieceID
        }
        set
        {
            _PieceID = newValue
        }
    }
    
    /// Dictionary of 2D attributes.
    var TwoDValues = [ValueTypes: Any]()
    /// Dictionary of 3D attributes.
    var ThreeDValues = [ValueTypes: Any]()
    /// Dictionary of common attributes.
    var CommonValues = [ValueTypes: Any]()
    
    /// Access (get or set) an attribute by general type and value.
    ///
    /// - Parameters:
    ///   - AttributeType: General attribute type - either 2D, 3D, or common (use appropriate enum).
    ///   - Value: Value type.
    subscript(_ AttributeType: AttributeTypes, _ Value: ValueTypes) -> Any?
    {
        get
        {
            switch AttributeType
            {
            case .TwoD:
                return TwoDValues[Value]
                
            case .ThreeD:
                return ThreeDValues[Value]
                
            case .Common:
                return CommonValues[Value]
            }
        }
        set
        {
            switch AttributeType
            {
            case .TwoD:
                TwoDValues[Value] = newValue
                
            case .ThreeD:
                ThreeDValues[Value] = newValue
                
            case .Common:
                CommonValues[Value] = newValue
            }
        }
    }
    
    /// Return a value in the specified attribute type.
    ///
    /// - Parameters:
    ///   - AttributeType: The attribute type from which the value will be returned.
    ///   - Value: The value's key.
    /// - Returns: The value itself if found, nil if not found.
    public func GetValue(_ AttributeType: AttributeTypes, _ Value: ValueTypes) -> Any?
    {
        switch AttributeType
        {
        case .TwoD:
            return TwoDValues[Value]
            
        case .ThreeD:
            return ThreeDValues[Value]
            
        case .Common:
            return CommonValues[Value]
        }
    }
    
    /// Determines if the specified attribute type has the specified value key.
    ///
    /// - Parameters:
    ///   - AttributeType: The attribute type from which the value key will be searched
    ///   - Value: The value's key.
    /// - Returns: True if the value key can be found, false if not.
    public func HasValue(_ AttributeType: AttributeTypes, _ Value: ValueTypes) -> Bool
    {
        switch AttributeType
        {
        case .TwoD:
            return TwoDValues.keys.contains(Value)
            
        case .ThreeD:
            return ThreeDValues.keys.contains(Value)
            
        case .Common:
            return CommonValues.keys.contains(Value)
        }
    }
}

/// Types of attributes.
///
/// - TwoD: Attributes for 2D.
/// - ThreeD: Attributes for 3D.
/// - Common: Attributes common for 2D and 3D.
enum AttributeTypes: Int, CaseIterable
{
    case TwoD = 0
    case ThreeD = 1
    case Common = 2
}

/// Types of values stored by the PieceAttributes class.
///
/// - Foreground: Foreground color (OS agnostic - color is stored by name).
/// - Background: Background color (OS agnostic - color is stored by name).
/// - BorderColor: Border color (OS agnostic - color is stored by name).
/// - BorderThickness: Thickness of the border.
/// - ShowBorder: Flag that determines if the border is shown.
/// - Shape: Describes the shape to use.
/// - RetiredForeground: Foreground color (OS agnostic - color is stored by name). For when piece is retired.
/// - RetiredBackground: Background color (OS agnostic - color is stored by name). For when piece is retired.
/// - RetiredBorderColor: Border color (OS agnostic - color is stored by name). For when piece is retired.
/// - RetiredBorderThickness: Thickness of the border. For when piece is retired.
/// - RetiredShowBorder: Flag that determines if the border is shown. For when piece is retired.
/// - RetiredShape: Describes the shape to use. For when piece is retired.
/// - DesaturateRetiredColor: If set to true, the standard color is desaturated and used for the retired color. Can
///                           be combined with `DarkenRetiredColor`
/// - DarkenRetiredColor: If set to true, the standard color is darkened and used for the retired color. Can be
///                       combined with `DesaturateRetiredColor`
/// - ActiveImageName: Name of the image to use when piece is active.
/// - RetiredImageName: Name of the image to use when the piece is retired.
/// - VisualType: Indicates what type of visual to use, colors or images.
/// - OriginalShape: Name of the original shape.
/// - OutOfBounds: If ture, the piece stopped out of bounds.
enum ValueTypes: Int, CaseIterable
{
    case Foreground = 0
    case Background = 1
    case BorderColor = 2
    case BorderThickness = 3
    case ShowBorder = 4
    case Shape = 5
    
    case RetiredForeground = 100
    case RetiredBackground = 101
    case RetiredBorderColor = 102
    case RetiredBorderThickness = 103
    case RetiredShowBorder = 104
    case RetiredShape = 105
    case DesaturateRetiredColor = 150
    case DarkenRetiredColor = 151
    
    case ActiveImageName = 200
    case RetiredImageName = 201
    
    case VisualType = 800
    
    case OriginalShape = 900
    
    case OutOfBounds = 1000
}
