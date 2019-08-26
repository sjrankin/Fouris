//
//  TileDescriptor.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/27/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Describes a tile used to represent a block in a game piece.
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
            
            case "_VisualType":
                //TileVisualTypes
                _VisualType = TileVisualTypes(rawValue: Sanitized)!
            
            case "_ActiveImageName":
                //String
                _ActiveImageName = Sanitized
            
            case "_RetiredImageName":
                //String
                _RetiredImageName = Sanitized
            
            case "_BackgroundColor":
                //String
                _BackgroundColor = Sanitized
            
            case "_RetiredBackgroundColor":
                //String
                _RetiredBackgroundColor = Sanitized
            
            case "_BorderColor":
                //String
                _BorderColor = Sanitized
            
            case "_RetiredBorderColor":
                //String
                _RetiredBorderColor = Sanitized
            
            case "_ShowBorder":
                //Bool
                _ShowBorder = Bool(Sanitized)!
            
            case "_ShowRetiredBorder":
                //Bool
                _ShowRetiredBorder = Bool(Sanitized)!
            
            case "_BorderThickness":
                //Double
                _BorderThickness = Double(Sanitized)!
            
            case "_RetiredBorderThickness":
                //Double
                _RetiredBorderThickness = Double(Sanitized)!
            
            case "_TileShape":
                //TileShapes
                _TileShape = TileShapes(rawValue: Sanitized)!
            
            case "_RetiredShape":
                //TileShapes
                _RetiredShape = TileShapes(rawValue: Sanitized)!
            
            case "_DesaturateRetiredColor":
                //Bool
                _DesaturateRetiredColor = Bool(Sanitized)!
            
            case "_DarkenRetiredColor":
                //Bool
                _DarkenRetiredColor = Bool(Sanitized)!
            
            case "_ShowShadow":
                //Bool
                _ShowShadow = Bool(Sanitized)!
            
            case "_ShowGlow":
                //Bool
                _ShowGlow = Bool(Sanitized)!
            
            case "_GlowColorName":
                //String
                _GlowColorName = Sanitized
            
            // Rendered 3D properties
            
            case "_Active3DBlockShape":
                //TileShapes3D
                _Active3DBlockShape = TileShapes3D(rawValue: Sanitized)!
            
            case "_Retired3DBlockShape":
                //TileShapes3D
                _Retired3DBlockShape = TileShapes3D(rawValue: Sanitized)!
            
            case "_Active3DSurfaceTexture":
                //RenderedTextureTypes
                _Active3DSurfaceTexture = RenderedTextureTypes(rawValue: Sanitized)!
            
            case "_Retired3DSurfaceTexture":
                //RenderedTextureTypes
                _Retired3DSurfaceTexture = RenderedTextureTypes(rawValue: Sanitized)!
            
            case "_ActiveTextureName":
                //String
                _ActiveTextureName = Sanitized
            
            case "_RetiredTextureName":
                //String
                _RetiredTextureName = Sanitized
            
            case "_ActiveDiffuseColor":
                //String
                _ActiveDiffuseColor = Sanitized
            
            case "_ActiveSpecularColor":
                //String
                _ActiveSpecularColor = Sanitized
            
            case "_RetiredDiffuseColor":
                //String
                _RetiredDiffuseColor = Sanitized
            
            case "_RetiredSpecularColor":
                //String
                _RetiredSpecularColor = Sanitized
            
            case "_IsCompositeShape":
                //Bool
                _IsCompositeShape = Bool(Sanitized)!
            
            case "_CompositeShapeCount":
                //Int
                _CompositeShapeCount = Int(Sanitized)!
            
            case "_Active3DCompositeShape1":
                //TileShapes3D
                _Active3DCompositeShape1 = TileShapes3D(rawValue: Sanitized)!
            
            case "_Active3DCompositeShape2":
                //TileShapes3D
                _Active3DCompositeShape2 = TileShapes3D(rawValue: Sanitized)!
            
            case "_Active3DCompositeShape3":
                //TileShapes3D
                _Active3DCompositeShape3 = TileShapes3D(rawValue: Sanitized)!
            
            case "_Retired3DCompositeShape1":
                //TileShapes3D
                _Retired3DCompositeShape1 = TileShapes3D(rawValue: Sanitized)!
            
            case "_Retired3DCompositeShape2":
                //TileShapes3D
                _Retired3DCompositeShape2 = TileShapes3D(rawValue: Sanitized)!
            
            case "_Retired3DCompositeShape3":
                //TileShapes3D
                _Retired3DCompositeShape3 = TileShapes3D(rawValue: Sanitized)!
            
            case "_Active3DCompositeSurfaceTextureType1":
                //RenderedTextureTypes
                _Active3DCompositeSurfaceTextureType1 = RenderedTextureTypes(rawValue: Sanitized)!
            
            case "_Active3DCompositeSurfaceTextureType2":
                //RenderedTextureTypes
                _Active3DCompositeSurfaceTextureType2 = RenderedTextureTypes(rawValue: Sanitized)!
            
            case "_Active3DCompositeSurfaceTextureType3":
                //RenderedTextureTypes
                _Active3DCompositeSurfaceTextureType3 = RenderedTextureTypes(rawValue: Sanitized)!
            
            case "_Retired3DCompositeSurfaceTextureType1":
                //RenderedTextureTypes
                _Retired3DCompositeSurfaceTextureType1 = RenderedTextureTypes(rawValue: Sanitized)!
            
            case "_Retired3DCompositeSurfaceTextureType2":
                //RenderedTextureTypes
                _Retired3DCompositeSurfaceTextureType2 = RenderedTextureTypes(rawValue: Sanitized)!
            
            case "_Retired3DCompositeSurfaceTextureType3":
                //RenderedTextureTypes
                _Retired3DCompositeSurfaceTextureType3 = RenderedTextureTypes(rawValue: Sanitized)!
            
            case "_Active3DCompositeSurfaceTextureName1":
                //String
                _Active3DCompositeSurfaceTextureName1 = Sanitized
            
            case "_Active3DCompositeSurfaceTextureName2":
                //String
                _Active3DCompositeSurfaceTextureName2 = Sanitized
            
            case "_Active3DCompositeSurfaceTextureName3":
                //String
                _Active3DCompositeSurfaceTextureName2 = Sanitized
            
            case "_Retired3DCompositeSurfaceTextureName1":
                //String
                _Retired3DCompositeSurfaceTextureName1 = Sanitized
            
            case "_Retired3DCompositeSurfaceTextureName2":
                //String
                _Retired3DCompositeSurfaceTextureName1 = Sanitized
            
            case "_Retired3DCompositeSurfaceTextureName3":
                //String
                _Retired3DCompositeSurfaceTextureName1 = Sanitized
            
            case "_ActiveCompositeDiffuseColor1":
                //String
                _ActiveCompositeDiffuseColor1 = Sanitized
            
            case "_ActiveCompositeDiffuseColor2":
                //String
                _ActiveCompositeDiffuseColor2 = Sanitized
            
            case "_ActiveCompositeDiffuseColor3":
                //String
                _ActiveCompositeDiffuseColor3 = Sanitized
            
            case "_RetiredCompositeDiffuseColor1":
                //String
                _RetiredCompositeDiffuseColor1 = Sanitized
            
            case "_RetiredCompositeDiffuseColor2":
                //String
                _RetiredCompositeDiffuseColor2 = Sanitized
            
            case "_RetiredCompositeDiffuseColor3":
                //String
                _RetiredCompositeDiffuseColor3 = Sanitized
            
            case "_ActiveCompositeSpecularColor1":
                //String
                _ActiveCompositeSpecularColor1 = Sanitized
            
            case "_ActiveCompositeSpecularColor2":
                //String
                _ActiveCompositeSpecularColor2 = Sanitized
            
            case "_ActiveCompositeSpecularColor3":
                //String
                _ActiveCompositeSpecularColor3 = Sanitized
            
            case "_RetiredCompositeSpecularColor1":
                //String
                _RetiredCompositeSpecularColor1 = Sanitized
            
            case "_RetiredCompositeSpecularColor2":
                //String
                _RetiredCompositeSpecularColor2 = Sanitized
            
            case "_RetiredCompositeSpecularColor3":
                //String
                _RetiredCompositeSpecularColor3 = Sanitized
            
            default:
                print("Encountered unexpected key: \(Key) in TileDescriptor.Populate")
                break
        }
    }
    
    // MARK: Debug color overrides.
    
    /// Holds the override colors flag.
    private var _EnableColorOverride: Bool = false
    /// Enable or disable color overriding. Intended for debug use only.
    public var EnableColorOverride: Bool
    {
        get
        {
            return _EnableColorOverride
        }
        set
        {
            _EnableColorOverride = newValue
        }
    }
    
    /// Holds the overridden active specular color name.
    private var _OverrideActiveSpecularColor: String = "White"
    /// Get or set the overridden active specular color name. Valid only if `EnableColorOverride` is true.
    public var OverrideActiveSpecularColor: String
    {
        get
        {
            return _OverrideActiveSpecularColor
        }
        set
        {
            _OverrideActiveSpecularColor = newValue
        }
    }
    
    /// Holds the overridden active diffuse color name.
    private var _OverrideActiveDiffuseColor: String = "Black"
        /// Get or set the overridden active diffuse color name. Valid only if `EnableColorOverride` is true.
    public var OverrideActiveDiffuseColor: String
    {
        get
        {
            return _OverrideActiveDiffuseColor
        }
        set
        {
            _OverrideActiveDiffuseColor = newValue
        }
    }
    
    /// Holds the overridden retired specular color name.
    private var _OverrideRetiredSpecularColor: String = "Black"
    /// Get or set the overridden retired specular color name. Valid only if `EnableColorOverride` is true.
    public var OverrideRetiredSpecularColor: String
    {
        get
        {
            return _OverrideRetiredSpecularColor
        }
        set
        {
            _OverrideRetiredSpecularColor = newValue
        }
    }
    
    /// Holds the overridden retired diffuse color name.
    private var _OverrideRetiredDiffuseColor: String = "White"
    /// Get or set the overridden retired diffuse color name. Valid only if `EnableColorOverride` is true.
    public var OverrideRetiredDiffuseColor: String
    {
        get
        {
            return _OverrideRetiredDiffuseColor
        }
        set
        {
            _OverrideRetiredDiffuseColor = newValue
        }
    }
    
    // MARK: 3D-related properties.
    
    /// Holds the name of the first active composite sub-shape specular color.
    private var _ActiveCompositeSpecularColor1: String = "Red"
    /// Get or set the specular color name for the first active composite sub-shape.
    public var ActiveCompositeSpecularColor1: String
    {
        get
        {
            return _ActiveCompositeSpecularColor1
        }
        set
        {
            _ActiveCompositeSpecularColor1 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the second active composite sub-shape specular color.
    private var _ActiveCompositeSpecularColor2: String = "Green"
    /// Get or set the specular color name for the second active composite sub-shape.
    public var ActiveCompositeSpecularColor2: String
    {
        get
        {
            return _ActiveCompositeSpecularColor2
        }
        set
        {
            _ActiveCompositeSpecularColor2 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the third active composite sub-shape specular color.
    private var _ActiveCompositeSpecularColor3: String = "Blue"
    /// Get or set the specular color name for the third active composite sub-shape.
    public var ActiveCompositeSpecularColor3: String
    {
        get
        {
            return _ActiveCompositeSpecularColor3
        }
        set
        {
            _ActiveCompositeSpecularColor3 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the first retired composite sub-shape specular color.
    private var _RetiredCompositeSpecularColor1: String = "Red"
    /// Get or set the specular color name for the first retired composite sub-shape.
    public var RetiredCompositeSpecularColor1: String
    {
        get
        {
            return _RetiredCompositeSpecularColor1
        }
        set
        {
            _RetiredCompositeSpecularColor1 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the second retired composite sub-shape specular color.
    private var _RetiredCompositeSpecularColor2: String = "Green"
    /// Get or set the specular color name for the second retired composite sub-shape.
    public var RetiredCompositeSpecularColor2: String
    {
        get
        {
            return _RetiredCompositeSpecularColor2
        }
        set
        {
            _RetiredCompositeSpecularColor2 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the third retired composite sub-shape specular color.
    private var _RetiredCompositeSpecularColor3: String = "Blue"
    /// Get or set the specular color name for the third retired composite sub-shape.
    public var RetiredCompositeSpecularColor3: String
    {
        get
        {
            return _RetiredCompositeSpecularColor3
        }
        set
        {
            _RetiredCompositeSpecularColor3 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the first active composite sub-shape diffuse color.
    private var _ActiveCompositeDiffuseColor1: String = "Red"
    /// Get or set the diffuse color name for the first active composite sub-shape.
    public var ActiveCompositeDiffuseColor1: String
    {
        get
        {
            return _ActiveCompositeDiffuseColor1
        }
        set
        {
            _ActiveCompositeDiffuseColor1 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the second active composite sub-shape diffuse color.
    private var _ActiveCompositeDiffuseColor2: String = "Green"
    /// Get or set the diffuse color name for the second active composite sub-shape.
    public var ActiveCompositeDiffuseColor2: String
    {
        get
        {
            return _ActiveCompositeDiffuseColor2
        }
        set
        {
            _ActiveCompositeDiffuseColor2 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the third active composite sub-shape diffuse color.
    private var _ActiveCompositeDiffuseColor3: String = "Blue"
    /// Get or set the diffuse color name for the third active composite sub-shape.
    public var ActiveCompositeDiffuseColor3: String
    {
        get
        {
            return _ActiveCompositeDiffuseColor3
        }
        set
        {
            _ActiveCompositeDiffuseColor3 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the first retired composite sub-shape diffuse color.
    private var _RetiredCompositeDiffuseColor1: String = "Red"
    /// Get or set the diffuse color name for the first retired composite sub-shape.
    public var RetiredCompositeDiffuseColor1: String
    {
        get
        {
            return _RetiredCompositeDiffuseColor1
        }
        set
        {
            _RetiredCompositeDiffuseColor1 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the second retired composite sub-shape diffuse color.
    private var _RetiredCompositeDiffuseColor2: String = "Green"
    /// Get or set the diffuse color name for the second retired composite sub-shape.
    public var RetiredCompositeDiffuseColor2: String
    {
        get
        {
            return _RetiredCompositeDiffuseColor2
        }
        set
        {
            _RetiredCompositeDiffuseColor2 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the third retired composite sub-shape diffuse color.
    private var _RetiredCompositeDiffuseColor3: String = "Blue"
    /// Get or set the diffuse color name for the third retired composite sub-shape.
    public var RetiredCompositeDiffuseColor3: String
    {
        get
        {
            return _RetiredCompositeDiffuseColor3
        }
        set
        {
            _RetiredCompositeDiffuseColor3 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the texture image for the first active composite sub-shape.
    private var _Active3DCompositeSurfaceTextureName1: String = ""
    /// Get or set the name of the texture image for the first active composite sub-shape.
    public var Active3DCompositeSurfaceTextureName1: String
    {
        get
        {
            return _Active3DCompositeSurfaceTextureName1
        }
        set
        {
            _Active3DCompositeSurfaceTextureName1 = newValue
        }
    }
    
    /// Holds the name of the texture image for the second active composite sub-shape.
    private var _Active3DCompositeSurfaceTextureName2: String = ""
    /// Get or set the name of the texture image for the second active composite sub-shape.
    public var Active3DCompositeSurfaceTextureName2: String
    {
        get
        {
            return _Active3DCompositeSurfaceTextureName2
        }
        set
        {
            _Active3DCompositeSurfaceTextureName2 = newValue
        }
    }
    
    /// Holds the name of the texture image for the third active composite sub-shape.
    private var _Active3DCompositeSurfaceTextureName3: String = ""
    /// Get or set the name of the texture image for the third active composite sub-shape.
    public var Active3DCompositeSurfaceTextureName3: String
    {
        get
        {
            return _Active3DCompositeSurfaceTextureName3
        }
        set
        {
            _Active3DCompositeSurfaceTextureName3 = newValue
        }
    }
    
    /// Holds the name of the texture image for the first retired composite sub-shape.
    private var _Retired3DCompositeSurfaceTextureName1: String = ""
    /// Get or set the name of the texture image for the first retired composite sub-shape.
    public var Retired3DCompositeSurfaceTextureName1: String
    {
        get
        {
            return _Retired3DCompositeSurfaceTextureName1
        }
        set
        {
            _Retired3DCompositeSurfaceTextureName1 = newValue
        }
    }
    
    /// Holds the name of the texture image for the second retired composite sub-shape.
    private var _Retired3DCompositeSurfaceTextureName2: String = ""
    /// Get or set the name of the texture image for the second retired composite sub-shape.
    public var Retired3DCompositeSurfaceTextureName2: String
    {
        get
        {
            return _Retired3DCompositeSurfaceTextureName2
        }
        set
        {
            _Retired3DCompositeSurfaceTextureName2 = newValue
        }
    }
    
    /// Holds the name of the texture image for the third retired composite sub-shape.
    private var _Retired3DCompositeSurfaceTextureName3: String = ""
    /// Get or set the name of the texture image for the third retired composite sub-shape.
    public var Retired3DCompositeSurfaceTextureName3: String
    {
        get
        {
            return _Retired3DCompositeSurfaceTextureName3
        }
        set
        {
            _Retired3DCompositeSurfaceTextureName3 = newValue
        }
    }
    
    /// Holds the texture type for the first sub-shape of a composite shape.
    private var _Active3DCompositeSurfaceTextureType1: RenderedTextureTypes = .Color
    /// Get or set the texture type for the first sub-shape of a composite shape.
    public var Active3DCompositeSurfaceTextureType1: RenderedTextureTypes
    {
        get
        {
            return _Active3DCompositeSurfaceTextureType1
        }
        set
        {
            _Active3DCompositeSurfaceTextureType1 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the texture type for the second sub-shape of a composite shape.
    private var _Active3DCompositeSurfaceTextureType2: RenderedTextureTypes = .Color
    /// Get or set the texture type for the second sub-shape of a composite shape.
    public var Active3DCompositeSurfaceTextureType2: RenderedTextureTypes
    {
        get
        {
            return _Active3DCompositeSurfaceTextureType2
        }
        set
        {
            _Active3DCompositeSurfaceTextureType2 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the texture type for the third sub-shape of a composite shape.
    private var _Active3DCompositeSurfaceTextureType3: RenderedTextureTypes = .Color
    /// Get or set the texture type for the third sub-shape of a composite shape.
    public var Active3DCompositeSurfaceTextureType3: RenderedTextureTypes
    {
        get
        {
            return _Active3DCompositeSurfaceTextureType3
        }
        set
        {
            _Active3DCompositeSurfaceTextureType3 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the texture type for the first sub-shape of a retired composite shape.
    private var _Retired3DCompositeSurfaceTextureType1: RenderedTextureTypes = .Color
    /// Get or set the texture type for the first sub-shape of a retired composite shape.
    public var Retired3DCompositeSurfaceTextureType1: RenderedTextureTypes
    {
        get
        {
            return _Retired3DCompositeSurfaceTextureType1
        }
        set
        {
            _Retired3DCompositeSurfaceTextureType1 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the texture type for the second sub-shape of a retired composite shape.
    private var _Retired3DCompositeSurfaceTextureType2: RenderedTextureTypes = .Color
    /// Get or set the texture type for the second sub-shape of a retired composite shape.
    public var Retired3DCompositeSurfaceTextureType2: RenderedTextureTypes
    {
        get
        {
            return _Retired3DCompositeSurfaceTextureType2
        }
        set
        {
            _Retired3DCompositeSurfaceTextureType2 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the texture type for the third sub-shape of a retired composite shape.
    private var _Retired3DCompositeSurfaceTextureType3: RenderedTextureTypes = .Color
    /// Get or set the texture type for the third sub-shape of a retired composite shape.
    public var Retired3DCompositeSurfaceTextureType3: RenderedTextureTypes
    {
        get
        {
            return _Retired3DCompositeSurfaceTextureType3
        }
        set
        {
            _Retired3DCompositeSurfaceTextureType3 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the first active composite sub-shape.
    private var _Active3DCompositeShape1: TileShapes3D = .Cubic
    /// Get or set the first sub-shape of an active composite shape.
    public var Active3DCompositeShape1: TileShapes3D
    {
        get
        {
            return _Active3DCompositeShape1
        }
        set
        {
            _Active3DCompositeShape1 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the second active composite sub-shape.
    private var _Active3DCompositeShape2: TileShapes3D = .Cubic
    /// Get or set the second sub-shape of an active composite shape.
    public var Active3DCompositeShape2: TileShapes3D
    {
        get
        {
            return _Active3DCompositeShape2
        }
        set
        {
            _Active3DCompositeShape2 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the third active composite sub-shape.
    private var _Active3DCompositeShape3: TileShapes3D = .Cubic
    /// Get or set the third sub-shape of an active composite shape.
    public var Active3DCompositeShape3: TileShapes3D
    {
        get
        {
            return _Active3DCompositeShape3
        }
        set
        {
            _Active3DCompositeShape3 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the first retired composite sub-shape.
    private var _Retired3DCompositeShape1: TileShapes3D = .Cubic
    /// Get or set the first sub-shape of an retired composite shape.
    public var Retired3DCompositeShape1: TileShapes3D
    {
        get
        {
            return _Retired3DCompositeShape1
        }
        set
        {
            _Retired3DCompositeShape1 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the second retired composite sub-shape.
    private var _Retired3DCompositeShape2: TileShapes3D = .Cubic
    /// Get or set the second sub-shape of an active retired shape.
    public var Retired3DCompositeShape2: TileShapes3D
    {
        get
        {
            return _Retired3DCompositeShape2
        }
        set
        {
            _Retired3DCompositeShape2 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the third retired composite sub-shape.
    private var _Retired3DCompositeShape3: TileShapes3D = .Cubic
    /// Get or set the third sub-shape of an retired composite shape.
    public var Retired3DCompositeShape3: TileShapes3D
    {
        get
        {
            return _Retired3DCompositeShape3
        }
        set
        {
            _Retired3DCompositeShape3 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the composite shape flag.
    private var _IsCompositeShape: Bool = false
    /// Get or set the flag that indicates whether to use composite shapes or not. If true,
    /// at least one composite shape (`Active3DCompositeShape*`) must be defined (along with
    /// its retired counterpart).
    public var IsCompositeShape: Bool
    {
        get
        {
            return _IsCompositeShape
        }
        set
        {
            _IsCompositeShape = true
            _Dirty = true
        }
    }
    
    /// Holds the number of sub-shapes for the composite shape.
    private var _CompositeShapeCount: Int = 0
    /// Get or set the number of composite sub-shapes. If **IsCompositeShape** is false, this
    /// property is ignored. If **IsCompositeShape** is true, this value must be in the range
    /// 1...3 and the associated shapes defined.
    public var CompositeShapeCount: Int
    {
        get
        {
            return _CompositeShapeCount
        }
        set
        {
            _CompositeShapeCount = newValue
            _Dirty = true
        }
    }
    
    /// Holds the active, diffuse color.
    private var _ActiveDiffuseColor: String = "Red"
    /// Get or set the active diffuse color.
    public var ActiveDiffuseColor: String
    {
        get
        {
            return _ActiveDiffuseColor
        }
        set
        {
            _ActiveDiffuseColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the retired, diffuse color.
    private var _RetiredDiffuseColor: String = "DullRed"
    /// Get or set the retired diffuse color.
    public var RetiredDiffuseColor: String
    {
        get
        {
            return _RetiredDiffuseColor
        }
        set
        {
            _RetiredDiffuseColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the active, specular color.
    private var _ActiveSpecularColor: String = "White"
    /// Get or set the active specular color.
    public var ActiveSpecularColor: String
    {
        get
        {
            return _ActiveSpecularColor
        }
        set
        {
            _ActiveSpecularColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the retired, specular color.
    private var _RetiredSpecularColor: String = "White"
    /// Get or set the retired specular color.
    public var RetiredSpecularColor: String
    {
        get
        {
            return _RetiredSpecularColor
        }
        set
        {
            _RetiredSpecularColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the active texture (whether color or image name).
    private var _ActiveTextureName: String = "Red"
    /// Get or set the name of the active texture. Depending on the value of `Active3DSurfaceTexture`, this is
    /// either a color name or an image name.
    public var ActiveTextureName: String
    {
        get
        {
            return _ActiveTextureName
        }
        set
        {
            _ActiveTextureName = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the retired texture (whether color or image name).
    private var _RetiredTextureName: String = "Blue"
    /// Get or set the name of the retired texture. Depending on the value of `Retired3DSurfaceTexture`, this is
    /// either a color name or an image name.
    public var RetiredTextureName: String
    {
        get
        {
            return _RetiredTextureName
        }
        set
        {
            _RetiredTextureName = newValue
            _Dirty = true
        }
    }
    
    /// Holds the type of texture for active 3D blocks.
    private var _Active3DSurfaceTexture: RenderedTextureTypes = .Color
    /// Get or set the texture type for active 3D blocks.
    public var Active3DSurfaceTexture: RenderedTextureTypes
    {
        get
        {
            return _Active3DSurfaceTexture
        }
        set
        {
            _Active3DSurfaceTexture = newValue
            _Dirty = true
        }
    }
    
    /// Holds the type of texture for retired 3D blocks.
    private var _Retired3DSurfaceTexture: RenderedTextureTypes = .Color
    /// Get or set the texture type for retired 3D blocks.
    public var Retired3DSurfaceTexture: RenderedTextureTypes
    {
        get
        {
            return _Retired3DSurfaceTexture
        }
        set
        {
            _Retired3DSurfaceTexture = newValue
            _Dirty = true
        }
    }
    
    /// Holds the active block shape for individual 3D blocks.
    private var _Active3DBlockShape: TileShapes3D = .Cubic
    /// Get or set the 3D active block shape.
    public var Active3DBlockShape: TileShapes3D
    {
        get
        {
            return _Active3DBlockShape
        }
        set
        {
            _Active3DBlockShape = newValue
            _Dirty = true
        }
    }
    
    /// Holds the retired block shape for individual 3D blocks.
    private var _Retired3DBlockShape: TileShapes3D = .Cubic
    /// Get or set the 3D retired block shape.
    public var Retired3DBlockShape: TileShapes3D
    {
        get
        {
            return _Retired3DBlockShape
        }
        set
        {
            _Retired3DBlockShape = newValue
            _Dirty = true
        }
    }
    
    // MARK: Properties.
    
    /// Holds the ID of the piece shape.
    private var _PieceShapeID: UUID = UUID.Empty
    /// Get or set the ID of the piece shape.
    public var PieceShapeID: UUID
    {
        get
        {
            return _PieceShapeID
        }
        set
        {
            _PieceShapeID = newValue
            _Dirty = true
        }
    }
    
    /// Holds the value that determines how the tile is drawn.
    private var _VisualType: TileVisualTypes = .Draw
    /// Get or set the value that indicates how a tile is drawn.
    public var VisualType: TileVisualTypes
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
    
    // MARK: Image-related properties.
    
    /// Holds the name of the active tile image.
    private var _ActiveImageName: String = "Tile1"
    /// Get or set the name of the active tile image (for before the piece is retired).
    public var ActiveImageName: String
    {
        get
        {
            return _ActiveImageName
        }
        set
        {
            _ActiveImageName = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the retired tile image.
    private var _RetiredImageName: String = "Tile1Retired"
    /// Get or set the name of the retired tile image (for after the piece is retired).
    public var RetiredImageName: String
    {
        get
        {
            return _RetiredImageName
        }
        set
        {
            _RetiredImageName = newValue
            _Dirty = true
        }
    }
    
    // MARK: Drawing-related properties (for when no images are used).
    
    /// Holds the name of the background color.
    private var _BackgroundColor: String = "White"
    /// Get or set the background (eg, fill) color name of the tile.
    public var BackgroundColor: String
    {
        get
        {
            return _BackgroundColor
        }
        set
        {
            _BackgroundColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the retired background color.
    private var _RetiredBackgroundColor: String = "White"
    /// Get or set the retired background (eg, fill) color name of the tile.
    public var RetiredBackgroundColor: String
    {
        get
        {
            return _RetiredBackgroundColor
        }
        set
        {
            _RetiredBackgroundColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the border color.
    private var _BorderColor: String = "Black"
    /// Get or set the name of the border color.
    public var BorderColor: String
    {
        get
        {
            return _BorderColor
        }
        set
        {
            _BorderColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the retired border color.
    private var _RetiredBorderColor: String = "Black"
    /// Get or set the name of the retired border color.
    public var RetiredBorderColor: String
    {
        get
        {
            return _RetiredBorderColor
        }
        set
        {
            _RetiredBorderColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the show border flag.
    private var _ShowBorder: Bool = true
    /// Get or set the show border flag. Intended for use by active tiles.
    public var ShowBorder: Bool
    {
        get
        {
            return _ShowBorder
        }
        set
        {
            _ShowBorder = newValue
            _Dirty = true
        }
    }
    
    /// Holds the thickness of the border for active tiles.
    private var _BorderThickness: Double = 1.0
    /// Get or set the border thickness for active tiles.
    public var BorderThickness: Double
    {
        get
        {
            return _BorderThickness
        }
        set
        {
            _BorderThickness = newValue
            _Dirty = true
        }
    }
    
    /// Holds the thickness of the border for retired tiles.
    private var _RetiredBorderThickness: Double = 1.0
    /// Get or set the border thickness for retired tiles.
    public var RetiredBorderThickness: Double
    {
        get
        {
            return _RetiredBorderThickness
        }
        set
        {
            _RetiredBorderThickness = newValue
            _Dirty = true
        }
    }
    
    /// Holds the show retired border flag.
    private var _ShowRetiredBorder: Bool = true
    /// Get or set the show border flag. Intended for use by retired tiles.
    public var ShowRetiredBorder: Bool
    {
        get
        {
            return _ShowRetiredBorder
        }
        set
        {
            _ShowRetiredBorder = newValue
            _Dirty = true
        }
    }
    
    /// Holds the shape of an active tile.
    private var _TileShape: TileShapes = .Square
    /// Get or set the shape of an active tile.
    public var TileShape: TileShapes
    {
        get
        {
            return _TileShape
        }
        set
        {
            _TileShape = newValue
            _Dirty = true
        }
    }
    
    /// Holds the shape of a retired tile.
    private var _RetiredShape: TileShapes = .RoundedRect
    /// Get or set the shape of a retired tile.
    public var RetiredShape: TileShapes
    {
        get
        {
            return _RetiredShape
        }
        set
        {
            _RetiredShape = newValue
            _Dirty = true
        }
    }
    
    /// Holds the desaturate retired color flag.
    private var _DesaturateRetiredColor: Bool = true
    /// Get or set the flag that determines if retired colors are desaturated.
    public var DesaturateRetiredColor: Bool
    {
        get
        {
            return _DesaturateRetiredColor
        }
        set
        {
            _DesaturateRetiredColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the darken retired color flag.
    private var _DarkenRetiredColor: Bool = true
    /// Get or set the flag that determines if retired colors are darkened.
    public var DarkenRetiredColor: Bool
    {
        get
        {
            return _DarkenRetiredColor
        }
        set
        {
            _DarkenRetiredColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the show shadow flag.
    private var _ShowShadow: Bool = false
    /// Get or set the flag that determines if a shadow is shown for drawn blocks.
    public var ShowShadow: Bool
    {
        get
        {
            return _ShowShadow
        }
        set
        {
            _ShowShadow = newValue
            _Dirty = true
        }
    }
    
    /// Holds the show glow flag.
    private var _ShowGlow: Bool = false
    /// Get or set the flag that determines if a glow is drawn for drawn blocks.
    public var ShowGlow: Bool
    {
        get
        {
            return _ShowGlow
        }
        set
        {
            _ShowGlow = newValue
            _Dirty = true
        }
    }
    
    /// The name of the glow color.
    private var _GlowColorName: String = "Yellow"
    /// Get or set the name of the glow color for drawn blocks if `ShowGlow` is true.
    public var GlowColorName: String
    {
        get
        {
            return _GlowColorName
        }
        set
        {
            _GlowColorName = newValue
            _Dirty = true
        }
    }
}

/// Tile visual types - indicates how tiles are drawn.
///
/// - **Image**: Drawn with an image.
/// - **Draw**: Drawn with CAShapeLayer commands.
/// - **Render**: Drawn with 3D rendering.
enum TileVisualTypes: String, CaseIterable
{
    case Image = "Image"
    case Draw = "Draw"
    case Render = "Render"
}

/// Tile shapes for drawn tiles.
///
/// - **Square**: Tile is a square.
/// - **RoundedRect**: Tile is a rounded rectangle.
/// - **Circular**: Tile is a circle.
enum TileShapes: String, CaseIterable
{
    case Square = "Square"
    case RoundedRect = "RoundedRect"
    case Circular = "Circular"
}

/// Block shapes for 3D rendered tiles.
///
/// - **Cubic**: Block is a cube.
/// - **Spherical**: Block is a sphere.
/// - **RoundedCube**: Block is a rounded cube.
/// - **Cone**: Block is cone shaped.
/// - **Pyramid**: Block is pyramid shaped.
/// - **Torus**: Block is toroidal shaped.
/// - **Capsule**: Block is capsule shaped.
/// - **Cylinder**: Block is cylinder shaped.
/// - **Tube**: Block is tube shaped.
enum TileShapes3D: String, CaseIterable
{
    case Cubic = "Cubic"
    case Spherical = "Spherical"
    case RoundedCube = "RoundedCube"
    case Cone = "Cone"
    case Pyramid = "Pyramid"
    case Torus = "Torus"
    case Capsule = "Capsule"
    case Cylinder = "Cylinder"
    case Tube = "Tube"
    case Dodecahedron = "Dodecahedron"
    case Tetrahedron = "Tetrahedron"
}

/// Texture types for rendered 3D blocks.
///
/// - **Color**: Surface is rendered in color.
/// - **Image**: Surface is rendered with an image.
enum RenderedTextureTypes: String, CaseIterable
{
    case Color = "Color"
    case Image = "Image"
}
