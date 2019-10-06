//
//  StateVisual.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Encapsulates a visual state for drawing blocks.
class StateVisual: CustomStringConvertible
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
    
    /// Holds the visual usage type.
    public var _VisualType: StateVisualTypes = .Active
    /// Get or set the visual usage type - Active or Retired.
    public var VisualType: StateVisualTypes
    {
        get
        {
            return _VisualType
        }
        set
        {
            _VisualType = newValue
            _Dirty = true
        }
    }
    
    /// Holds the surface type.
    public var _SurfaceType: SurfaceTypes = .Color
    /// Get or set the value that indicates whether to use colors or textures for the block surfaces.
    public var SurfaceType: SurfaceTypes
    {
        get
        {
            return _SurfaceType
        }
        set
        {
            _SurfaceType = newValue
            _Dirty = true
        }
    }
    
    /// Holds the block shape.
    public var _BlockShape: TileShapes3D = .Cubic
    /// Get or set the visual shape of the block.
    public var BlockShape: TileShapes3D
    {
        get
        {
            return _BlockShape
        }
        set
        {
            _BlockShape = newValue
            _Dirty = true
        }
    }
    
    /// Holds the surface diffuse color.
    public var _DiffuseColor: String = "Black"
    /// Get or set the surface diffuse color.
    public var DiffuseColor: String
    {
        get
        {
            return _DiffuseColor
        }
        set
        {
            _DiffuseColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the surface specular color.
    public var _SpecularColor: String = "White"
    /// Get or set the surface specular color.
    public var SpecularColor: String
    {
        get
        {
            return _SpecularColor
        }
        set
        {
            _SpecularColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the surface diffuse texture.
    public var _DiffuseTexture: String = "Not Set"
    /// Get or set the name of the surface diffuse texture.
    public var DiffuseTexture: String
    {
        get
        {
            return _DiffuseTexture
        }
        set
        {
            _DiffuseTexture = newValue
            _Dirty = true
        }
    }
    
    /// Holds the surface specular texture.
    public var _SpecularTexture: String = "Not Set"
    /// Get or set the name of the surface specular texture.
    public var SpecularTexture: String
    {
        get
        {
            return _SpecularTexture
        }
        set
        {
            _SpecularTexture = newValue
            _Dirty = true
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
    
    /// Returns the contents of this class as an XML framgent.
    /// - Parameter Indent: Number of spaces to indent. Defaults to 0.
    /// - Parameter AppendTerminalReturn: If true, a return is appended to the returned string.
    /// - Returns: XML fragment with the contents of this class.
    public func ToString(Indent: Int = 0, AppendTerminalReturn: Bool = true) -> String
    {
        var Working = ""
        Working.append(Spaces(Indent) + "<\(VisualType.rawValue) Type=" + Quoted(SurfaceType.rawValue) +
            " Shape=" + Quoted(BlockShape.rawValue) + "/>\n")
        Working.append(Spaces(Indent + 4) + "<Colors Diffuse=" + Quoted(DiffuseColor) +
            " Specular=" + Quoted(SpecularColor) + "/>\n")
        Working.append(Spaces(Indent + 4) + "<Textures Diffuse=" + Quoted(DiffuseTexture) +
            " Specular=" + Quoted(SpecularTexture) + "/>\n")
        Working.append(Spaces(Indent) + "</\(VisualType.rawValue)" + ">")
        if AppendTerminalReturn
        {
            Working.append("\n")
        }
        return Working
    }
    
    /// Returns a string description of this class as an XML fragment.
    public var description: String
    {
        get
        {
            return ToString()
        }
    }
}

/// Types of visual states.
/// - **Active**: For active (eg, falling or moveable) blocks.
/// - **Retired**: For inactive (eg, frozen) blocks.
enum StateVisualTypes: String, CaseIterable
{
    case Active = "Active"
    case Retired = "Retired"
}

/// How to render the surface of the block.
/// - **Color**: Use colors to draw the block.
/// - **Texture**: Use textures to draw the block.
enum SurfaceTypes: String, CaseIterable
{
    case Color = "Color"
    case Texture = "Texture"
}
