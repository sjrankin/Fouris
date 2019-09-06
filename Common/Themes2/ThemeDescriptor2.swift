//
//  ThemeDescriptor2.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

/// Contains the description of a visual theme.
class ThemeDescriptor2: Serializable
{
    /// Initializer.
    init()
    {
        _Dirty = false
    }
    
    /// Holds the dirty flag. Used by user-defined themes.
    private var _Dirty: Bool = false
    /// Get or set the dirty flag. Used by user-defined themes and ignored for standard themes.
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
            case "_ThemeName":
                //String
                _ThemeName = Sanitized
            
            case "_UserTheme":
                //Bool
                _UserTheme = Bool(Sanitized)!
            
            case "_ID":
                //UUID
                _ID = UUID(uuidString: Sanitized)!
            
            case "_Title":
                //String
                _Title = Sanitized
            
            //3D theme general properties.
            
            case "_BackgroundType3D":
                //BackgroundTypes3D
                _BackgroundType3D = BackgroundTypes3D(rawValue: Sanitized)!
            
            case "_BackgroundIdentifier3D":
                //String
                _BackgroundIdentifier3D = Sanitized
            
            case "_BucketColor3D":
                //String
                _BucketColor3D = Sanitized
            
            case "_Default3DTheme":
                //Bool
                _Default3DTheme = Bool(Sanitized)!
            
            case "_AntialiasingMode":
                //AntialiasingModes
                _AntialiasingMode = AntialiasingModes(rawValue: Sanitized)!
            
            case "_CameraFieldOfView":
                //Double
                _CameraFieldOfView = Double(Sanitized)!
            
            case "_CameraPosition":
                //{Three comma-separated doubles}
                let Values = SplitStringIntoDoubles(Value, With: ",", ExpectedCount: 3)
                _CameraPosition.x = Float(Values[0])
                _CameraPosition.y = Float(Values[1])
                _CameraPosition.z = Float(Values[2])
            
            case "_CameraOrientation":
                //{Four comma-separated doubles}
                let Values = SplitStringIntoDoubles(Value, With: ",", ExpectedCount: 4)
                _CameraOrientation.x = Float(Values[0])
                _CameraOrientation.y = Float(Values[1])
                _CameraOrientation.z = Float(Values[2])
                _CameraOrientation.w = Float(Values[3])
            
            case "_UseDefaultLighting":
                //Bool
                _UseDefaultLighting = Bool(Value)!
            
            case "_LightColor":
                //String
                _LightColor = Value
            
            case "_LightType":
                //SCNLight.LightType
                _LightType = SCNLight.LightType(rawValue: Value)
            
            case "_LightPosition":
                //{Three comma-seperated doubles}
                let Values = SplitStringIntoDoubles(Value, With: ",", ExpectedCount: 3)
                _LightPosition.x = Float(Values[0])
                _LightPosition.y = Float(Values[1])
                _LightPosition.z = Float(Values[2])
            
            case "_CanControlCamera":
                //Bool
                _CanControlCamera = Bool(Value)!
            
            case "_ShowStatistics":
                //Bool
                _ShowStatistics = Bool(Value)!
            
            case "_ShowGrid":
                //Bool
                _ShowGrid = Bool(Value)!
            
            case "_ShowBucketGrid":
                //Bool
                _ShowBucketGrid = Bool(Value)!
            
            case "_IsOrthographic":
                //Bool
                _IsOrthographic = Bool(Value)!
            
            case "_OrthographicScale":
                //Double
                _OrthographicScale = Double(Value)!
            
            default:
                print("Encountered unexpected key: \(Key) in ThemeDescriptor.Populate")
                break
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
    
    // MARK: 3D theme properties.
    
    /// Holds the show bucket grid flag.
    private var _ShowBucketGrid: Bool = false
    /// Determines whether the bucket grid is visible or not. The bucket grid appears only in the
    /// bucket and not the surrounding area.
    public var ShowBucketGrid: Bool
    {
        get
        {
            return _ShowBucketGrid
        }
        set
        {
            _ShowBucketGrid = newValue
            _Dirty = true
        }
    }
    
    /// Holds the camera's orthographic flag.
    private var _IsOrthographic: Bool = false
    /// Get or set the value that determines if the camera uses persective or orthographic
    /// projection. Default, false, is persective.
    public var IsOrthographic: Bool
    {
        get
        {
            return _IsOrthographic
        }
        set
        {
            _IsOrthographic = newValue
            _Dirty = true
        }
    }
    
    /// Holds the scale to use if the camera is set to orthographic perspective.
    private var _OrthographicScale: Double = 20.0
    /// Get or set the scale to use when the camera is in orthographic perspective. Ignored if
    /// `IsOrthographic` is false (you can still set the value, it just will not have any effect
    /// until `IsOrthographic` is set to true).
    public var OrthographicScale: Double
    {
        get
        {
            return _OrthographicScale
        }
        set
        {
            _OrthographicScale = newValue
            _Dirty = true
        }
    }
    
    /// Holds the show grid flag.
    private var _ShowGrid: Bool = false
    /// Get or set the show grid flag. Intended for debug use only.
    public var ShowGrid: Bool
    {
        get
        {
            return _ShowGrid
        }
        set
        {
            _ShowGrid = newValue
            _Dirty = true
        }
    }
    
    /// Holds the show scene kit statistics flag.
    private var _ShowStatistics: Bool = false
    /// Get or set the show statistics flag. Intended for debug use only.
    public var ShowStatistics: Bool
    {
        get
        {
            return _ShowStatistics
        }
        set
        {
            _ShowStatistics = newValue
            _Dirty = true
        }
    }
    
    /// Holds the can control camera flag.
    private var _CanControlCamera: Bool = false
    /// Get or set the flag that allows the user to control the camera position. Should be used for
    /// debugging mainly...
    public var CanControlCamera: Bool
    {
        get
        {
            return _CanControlCamera
        }
        set
        {
            _CanControlCamera = newValue
            _Dirty = true
        }
    }
    
    /// Holds the color of the light.
    private var _LightColor: String = "White"
    /// Get or set the name of the color of the light.
    public var LightColor: String
    {
        get
        {
            return _LightColor
        }
        set
        {
            _LightColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the type of the light.
    private var _LightType: SCNLight.LightType = .ambient
    /// Get or set the type of the light.
    public var LightType: SCNLight.LightType
    {
        get
        {
            return _LightType
        }
        set
        {
            _LightType = newValue
            _Dirty = true
        }
    }
    
    /// Holds the position of the light.
    private var _LightPosition: SCNVector3 = SCNVector3(0,0,0)
    /// Get or set the position of the light.
    public var LightPosition: SCNVector3
    {
        get
        {
            return _LightPosition
        }
        set
        {
            _LightPosition = newValue
            _Dirty = true
        }
    }
    
    /// Holds the default lighting flag.
    private var _UseDefaultLighting: Bool = true
    /// Get or set the default lighting flag.
    public var UseDefaultLighting: Bool
    {
        get
        {
            return _UseDefaultLighting
        }
        set
        {
            _UseDefaultLighting = newValue
            _Dirty = true
        }
    }
    
    /// Holds the default 3D theme flag.
    private var _Default3DTheme: Bool = false
    /// Get or set the default 3D theme flag.
    public var Default3DTheme: Bool
    {
        get
        {
            return _Default3DTheme
        }
        set
        {
            _Default3DTheme = newValue
            _Dirty = true
        }
    }
    
    /// Hold the anti-aliasing mode.
    private var _AntialiasingMode: AntialiasingModes = .None
    /// Get or set the anti-aliasing mode for 3D.
    public var AntialiasingMode: AntialiasingModes
    {
        get
        {
            return _AntialiasingMode
        }
        set
        {
            _AntialiasingMode = newValue
            _Dirty = true
        }
    }
    
    /// Holds the camera's field of view.
    private var _CameraFieldOfView: Double = 90.0
    /// Get or set the camera's field of view.
    public var CameraFieldOfView: Double
    {
        get
        {
            return _CameraFieldOfView
        }
        set
        {
            _CameraFieldOfView = newValue
            _Dirty = true
        }
    }
    
    /// Holds the camera's position in the scene.
    private var _CameraPosition: SCNVector3 = SCNVector3(x: 1.0, y: 1.0, z: 1.0)
    /// Get or set the camera's position in the scene.
    public var CameraPosition: SCNVector3
    {
        get
        {
            return _CameraPosition
        }
        set
        {
            _CameraPosition = newValue
            _Dirty = true
        }
    }
    
    /// Holds the camera's orientation in the scene.
    private var _CameraOrientation: SCNVector4 = SCNVector4(x: 0.2, y: 0.2, z: 0.2, w: -0.5)
    /// Get or set the camera's orientation in the scene.
    public var CameraOrientation: SCNVector4
    {
        get
        {
            return _CameraOrientation
        }
        set
        {
            _CameraOrientation = newValue
        }
    }
    
    /// Holds the color of the 3D bucket.
    private var _BucketColor3D: String = "Black"
    /// Get or set the color name for the 3D bucket.
    public var BucketColor3D: String
    {
        get
        {
            return _BucketColor3D
        }
        set
        {
            _BucketColor3D = newValue
            _Dirty = true
        }
    }
    
    /// Holds the identifier to use to determine the 3D background.
    private var _BackgroundIdentifier3D: String = "Black"
    /// Get or set the identifier to use in conjuction with `BackgroundType3D` to determine the 3D background.
    public var BackgroundIdentifier3D: String
    {
        get
        {
            return _BackgroundIdentifier3D
        }
        set
        {
            _BackgroundIdentifier3D = newValue
            _Dirty = true
        }
    }
    
    /// Holds the background type for 3D game views.
    private var _BackgroundType3D: BackgroundTypes3D = .Color
    /// Get or set the background type for 3D game views.
    public var BackgroundType3D: BackgroundTypes3D
    {
        get
        {
            return _BackgroundType3D
        }
        set
        {
            _BackgroundType3D = newValue
            _Dirty = true
        }
    }
    
    // MARK: General descriptor properties.
    
    /// Holds the name of the theme (different from the title).
    private var _ThemeName: String = ""
    /// Get or set the name of the theme. This is different from the title and can be considered a "short theme name".
    public var ThemeName: String
    {
        get
        {
            return _ThemeName
        }
        set
        {
            _ThemeName = newValue
            _Dirty = true
        }
    }
    
    /// Holds the is-a-user-theme flag.
    private var _UserTheme: Bool = false
    /// If true, this is a user-designed theme and can be edited. If false, this is a factory theme
    /// and cannot be edited.
    public var UserTheme: Bool
    {
        get
        {
            return _UserTheme
        }
        set
        {
            _UserTheme = newValue
            _Dirty = true
        }
    }
    
    /// Hold the default theme flag.
    private var _IsDefaultTheme: Bool = false
    /// Get or set the flag that indicates this is the default theme. Theoretically, there should be only one
    /// default theme. The default theme is used for two purposes: 1) If the user never specifies a theme, this is
    /// the theme that is used; 2) If the user specifies a user theme then deletes it, this is the fall-back theme.
    public var IsDefaultTheme: Bool
    {
        get
        {
            return _IsDefaultTheme
        }
        set
        {
            _IsDefaultTheme = newValue
            _Dirty = true
        }
    }
    
    /// Holds the ID of the theme.
    private var _ID: UUID = UUID.Empty
    /// Get or set the ID of the theme.
    public var ID: UUID
    {
        get
        {
            return _ID
        }
        set
        {
            _ID = newValue
            _Dirty = true
        }
    }
    
    /// Holds the title of the theme.
    private var _Title: String = "Generic Theme"
    /// Get or set the title/name of the theme.
    public var Title: String
    {
        get
        {
            return _Title
        }
        set
        {
            _Title = newValue
            _Dirty = true
        }
    }
    
    /// Holds the out of bounds glow color.
    private var _OutOfBoundsGlowColor: String = "Red"
    /// Get or set the color name for when a piece is frozen out of bounds.
    public var OutOfBoundsGlowColor: String
    {
        get
        {
            return _OutOfBoundsGlowColor
        }
        set
        {
            _OutOfBoundsGlowColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the piece is freezing glow color.
    private var _FreezingGlowColor: String = "Yellow"
    /// Get or set the color name for when a piece starts to freeze.
    public var FreezingGlowColor: String
    {
        get
        {
            return _FreezingGlowColor
        }
        set
        {
            _FreezingGlowColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the flag that tells the game view to glow to indicate piece status.
    private var _ShowGlowForStatus: Bool = true
    /// Get or set the glow for status flag.
    public var ShowGlowForStatus: Bool
    {
        get
        {
            return _ShowGlowForStatus
        }
        set
        {
            _ShowGlowForStatus = newValue
            _Dirty = true
        }
    }
    
    /// Holds the game type.
    private var _GameType: GameTypes = .Standard
    /// Get or set the game type.
    public var GameType: GameTypes
    {
        get
        {
            return _GameType
        }
        set
        {
            _GameType = newValue
            _Dirty = true
        }
    }
    
    // MARK: Game text properties.
    
    /// Holds the game over image name.
    private var _GameOverImage: String = "GameOverImage15"
    /// Get or set the name of the game over image.
    public var GameOverImage: String
    {
        get
        {
            return _GameOverImage
        }
        set
        {
            _GameOverImage = newValue
            _Dirty = true
        }
    }
    
    /// Holds the Press Play image name.
    private var _PressPlayImage: String = "PressPlayText14"
    /// Get or set the name of the Press Play image.
    public var PressPlayImage: String
    {
        get
        {
            return _PressPlayImage
        }
        set
        {
            _PressPlayImage = newValue
            _Dirty = true
        }
    }
    
    /// Holds the Pause image name.
    private var _PauseImage: String = "PauseText13"
    /// Get or set the name of the Pause image.
    public var PauseImage: String
    {
        get
        {
            return _PauseImage
        }
        set
        {
            _PauseImage = newValue
            _Dirty = true
        }
    }
    
    // MARK: Text label properties.
    
    /// Holds the color name for the "Game Score" label.
    private var _GameScoreColor: String = "White"
    /// Get or set the color name for the "Game Score" label.
    public var GameScoreColor: String
    {
        get
        {
            return _GameScoreColor
        }
        set
        {
            _GameScoreColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the color name for the "High Score" label.
    private var _HighScoreColor: String = "Yellow"
    /// Get or set the color name for the "High Score" label.
    public var HighScoreColor: String
    {
        get
        {
            return _HighScoreColor
        }
        set
        {
            _HighScoreColor = newValue
            _Dirty = true
        }
    }
    
    /// Hold the color name for the "Next" label.
    private var _NextColor: String = "White"
    /// Get or set the color name for the "Next" label.
    public var NextColor: String
    {
        get
        {
            return _NextColor
        }
        set
        {
            _NextColor = newValue
            _Dirty = true
        }
    }
    
    // MARK: Center-related properties.
    
    /// Holds the type of the center - drawn or image.
    private var _CenterType: BucketTypes = .Image
    /// Get or set the graphic type of the center block.
    public var CenterType: BucketTypes
    {
        get
        {
            return _CenterType
        }
        set
        {
            _CenterType = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the center block image.
    private var _CenterImageName: String = "CenterBlock1"
    /// Get or set the name of the center block image.
    public var CenterImageName: String
    {
        get
        {
            return _CenterImageName
        }
        set
        {
            _CenterImageName = newValue
            _Dirty = true
        }
    }
    
    /// Holds the color of the center block.
    private var _CenterBlockColor: String = "Yellow"
    /// Get or set the color name of the center block.
    public var CenterBlockColor: String
    {
        get
        {
            return _CenterBlockColor
        }
        set
        {
            _CenterBlockColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the center block has a border flag.
    private var _CenterBlockHasBorder: Bool = true
    /// Get or set the value that determines if the center block is drawn with a border.
    public var CenterBlockHasBorder: Bool
    {
        get
        {
            return _CenterBlockHasBorder
        }
        set
        {
            _CenterBlockHasBorder = newValue
            _Dirty = true
        }
    }
    
    /// Holds the width of the center block border.
    private var _CenterBlockBorderWidth: Double = 2.0
    /// Get or set the width of the center block border.
    public var CenterBlockBorderWidth: Double
    {
        get
        {
            return _CenterBlockBorderWidth
        }
        set
        {
            _CenterBlockBorderWidth = newValue
            _Dirty = true
        }
    }
    
    /// Holds the center block border color.
    private var _CenterBlockBorderColor: String = "Black"
    /// Get or set the name of the color for the center block border.
    public var CenterBlockBorderColor: String
    {
        get
        {
            return _CenterBlockBorderColor
        }
        set
        {
            _CenterBlockBorderColor = newValue
            _Dirty = true
        }
    }
    
    // MARK: Outline-related properties.
    
    /// Holds the show outline flag for center-based game types.
    private var _ShowOutline: Bool = true
    /// Get or set the show outline flag for center-based game types.
    public var ShowOutline: Bool
    {
        get
        {
            return _ShowOutline
        }
        set
        {
            _ShowOutline = newValue
            _Dirty = false
        }
    }
    
    /// Holds the thickness of the outline.
    private var _OutlineThickness: Double = 4.0
    /// Get or set the thickness of the center-based outline.
    public var OutlineThickness: Double
    {
        get
        {
            return _OutlineThickness
        }
        set
        {
            _OutlineThickness = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the color for the outline.
    private var _OutlineColor: String = "Red"
    /// Get or set the outline color name.
    public var OutlineColor: String
    {
        get
        {
            return _OutlineColor
        }
        set
        {
            _OutlineColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the flag that determines if the outline glows.
    private var _OutlineGlows: Bool = false
    /// Get or set the outline glows flag.
    public var OutlineGlows: Bool
    {
        get
        {
            return _OutlineGlows
        }
        set
        {
            _OutlineGlows = newValue
            _Dirty = true
        }
    }
    
    /// Holds the color name for the outline glow.
    private var _OutlineGlowColor: String = "Yellow"
    /// Get or set the color name for the outline glow color.
    public var OutlineGlowColor: String
    {
        get
        {
            return _OutlineGlowColor
        }
        set
        {
            _OutlineGlowColor = newValue
            _Dirty = true
        }
    }
    
    // MARK: Bucket-related properties.
    
    /// Holds how to draw buckets.
    private var _BucketType: BucketTypes = .Image
    /// Get or set the method used to draw buckets.
    public var BucketType: BucketTypes
    {
        get
        {
            return _BucketType
        }
        set
        {
            _BucketType = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the image to use as the bucket.
    private var _BucketImageName: String = "FullBucket7"
    /// Get or set the name of the bucket image. Ignored if `UseBucketImage` is false.
    public var BucketImageName: String
    {
        get
        {
            return _BucketImageName
        }
        set
        {
            _BucketImageName = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the image to use to build the bucket.
    private var _BucketBlockName: String = "Bucket18"
    /// Get or set the name of the image to use to build the bucket. Ignored if `UseBucketImage` is true.
    public var BucketBlockName: String
    {
        get
        {
            return _BucketBlockName
        }
        set
        {
            _BucketBlockName = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the color to used to draw buckets as a shape.
    private var _BucketColor: String = "Yellow"
    /// Color of the shape to use to draw a bucket.
    public var BucketColor: String
    {
        get
        {
            return _BucketColor
        }
        set
        {
            _BucketColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the gradient bucket color flag.
    private var _BucketColorIsGradient: Bool = false
    /// Get or set the bucket color is gradient flag.
    public var BucketColorIsGradient: Bool
    {
        get
        {
            return _BucketColorIsGradient
        }
        set
        {
            _BucketColorIsGradient = newValue
            _Dirty = true
        }
    }
    
    /// Holds the number of colors in the color gradient.
    private var _BucketColorGradientCount: Int = 0
    /// Get or set the number of color gradients. If set to 0, `BucketColorIsGradient` is set to false.
    public var BucketColorGradientCount: Int
    {
        get
        {
            return _BucketColorGradientCount
        }
        set
        {
            _BucketColorGradientCount = newValue
            _Dirty = true
            if _BucketColorGradientCount == 0
            {
                BucketColorIsGradient = false
            }
        }
    }
    
    /// Holds color 0 of the gradient.
    private var _BucketGradientColor0: String = "Black"
    /// Get or set gradient color 0. Ignored if `BucketColorGradientCount` is less than 1.
    public var BucketGradientColor0: String
    {
        get
        {
            return _BucketGradientColor0
        }
        set
        {
            _BucketGradientColor0 = newValue
            _Dirty = true
        }
    }
    
    /// Holds color 1 of the gradient.
    private var _BucketGradientColor1: String = "Black"
    /// Get or set gradient color 1. Ignored if `BucketColorGradientCount` is less than 2
    public var BucketGradientColor1: String
    {
        get
        {
            return _BucketGradientColor1
        }
        set
        {
            _BucketGradientColor1 = newValue
            _Dirty = true
        }
    }
    
    /// Holds color 2 of the gradient.
    private var _BucketGradientColor2: String = "Black"
    /// Get or set gradient color 2. Ignored if `BucketColorGradientCount` is less than 3.
    public var BucketGradientColor2: String
    {
        get
        {
            return _BucketGradientColor2
        }
        set
        {
            _BucketGradientColor2 = newValue
            _Dirty = true
        }
    }
    
    /// Holds color 3 of the gradient.
    private var _BucketGradientColor3: String = "Black"
    /// Get or set gradient color 3. Ignored if `BucketColorGradientCount` is less than 4.
    public var BucketGradientColor3: String
    {
        get
        {
            return _BucketGradientColor3
        }
        set
        {
            _BucketGradientColor3 = newValue
            _Dirty = true
        }
    }
    
    /// Holds the show bucket border flag.
    private var _ShowBucketBorder: Bool = false
    /// Get or set the flag that determines if individual blocks of the bucket have borders. This flag is only
    /// used when the bucket is drawn.
    public var ShowBucketBorder: Bool
    {
        get
        {
            return _ShowBucketBorder
        }
        set
        {
            _ShowBucketBorder = newValue
            _Dirty = true
        }
    }
    
    /// Holds the width of the bucket border.
    private var _BucketBorderWidth: Double = 0.0
    ///Get or set the width of the bucket border. Ignored if `ShowBucketBorder` is false.
    public var BucketBorderWidth: Double
    {
        get
        {
            return _BucketBorderWidth
        }
        set
        {
            _BucketBorderWidth = newValue
            _Dirty = true
        }
    }
    
    /// Holds the shape of the drawn bucket tile. Ignored if `ShowBucketBorder` is false.
    private var _DrawnBucketTileShape: TileShapes = .Square
    /// Get or set the shape of drawn bucket tiles.
    public var DrawnBucketTileShape: TileShapes
    {
        get
        {
            return _DrawnBucketTileShape
        }
        set
        {
            _DrawnBucketTileShape = newValue
            _Dirty = true
        }
    }
    
    /// Holds the name of the color for the bucket border.
    private var _BucketBorderColor: String = "Black"
    /// Get or set the name of the bucket border color. Ignored if `ShowBucketBorder` is false.
    public var BucketBorderColor: String
    {
        get
        {
            return _BucketBorderColor
        }
        set
        {
            _BucketBorderColor = newValue
            _Dirty = true
        }
    }
    
    /// Holds the bucket is visible flag.
    private var _BucketIsVisible: Bool = true
    /// Get or set the flag that determines bucket visibility.
    public var BucketIsVisible: Bool
    {
        get
        {
            return _BucketIsVisible
        }
        set
        {
            _BucketIsVisible = newValue
            _Dirty = true
        }
    }
    
    // MARK: Background.
    
    /// Holds the name of the color of the background.
    private var _BackgroundColor: String = "ReallyDarkGray"
    /// Get or set the name of the color of the background.
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
    
    
    // MARK: Tile lists and list handling.
    
    /// Creates and returns a new tile descriptor class.
    ///
    /// - Returns: New tile descriptor class.
    public func MakeTileDescriptor() -> TileDescriptor2
    {
        return TileDescriptor2()
    }
    
    /// Holds a list of tile descriptors, one for each piece in a set.
    private var _TileList = [TileDescriptor2](repeating: TileDescriptor2(), count: 10)
    /// Get or set the list of tile descriptors. Each descriptor should be applied to a single piece shape.
    public var TileList: [TileDescriptor2]
    {
        get
        {
            return _TileList
        }
        set
        {
            _TileList = newValue
            _Dirty = true
        }
    }
    
    /// Return a tile descriptor for the passed shape ID.
    ///
    /// - Parameter ID: ID of the shape whose tile descriptor will be returned.
    /// - Returns: Tile descriptor for the passed shape on success, nil on failure.
    public func TileDescriptorFor(_ ID: UUID) -> TileDescriptor2?
    {
        for Tile in TileList
        {
            if Tile.PieceShapeID == ID
            {
                return Tile
            }
        }
        return nil
    }
}

/// Types of game views. Used to indiate what game view are valid for a given theme.
///
/// - **TwoD**: Two-dimensional game view.
/// - **ThreeD**: Three-dimensional game view.
/// - **Both**: Both game views.
enum ViewTypes: String, CaseIterable
{
    case TwoD = "TwoD"
    case ThreeD = "ThreeD"
    case Both = "Both"
}

/// Indicates how to draw a bucket.
///
/// - **Image**: Use a single bucket image.
/// - **ImageBlocks**: Use multiple images to draw a bucket.
/// - **Drawn**: Use shapes (from CAShapeLayer) to draw a bucket.
/// - **Rendered**: 3D rendered.
enum BucketTypes: String, CaseIterable
{
    case Image = "Image"
    case ImageBlocks = "ImageBlocks"
    case Drawn = "Drawn"
    case Rendered = "Rendered"
}

/// Game types - eg, how pieces fall and where they fall to and how the bucket behaves.
///
/// - **Standard**: Standard Tetris game.
/// - **Centered**: Blocks fall to the center, game may rotate bucket or blocks fall in from any side.
enum GameTypes: String, CaseIterable
{
    case Standard = "Standard"
    case Centered = "Centered"
}

/// 3D game view background types.
///
/// - **Color**: Name of a color.
/// - **Image**: Name of an image to display.
/// - **Texture**: Name of a texture.
/// - **CALayer**: Name of a CALayer.
enum BackgroundTypes3D: String, CaseIterable
{
    case Color = "Color"
    case Image = "Image"
    case Texture = "Texture"
    case CALayer = "CALayer"
}

/// 3D antialiasing modes.
///
/// - **None**: No antialiasing.
/// - **MultiSampling2X**: Multi-sampling 2X mode.
/// - **MultiSampling4X**: Multi-sampling 4X mode.
/// - **MultiSampling8X**: Multi-sampling 8X mode.
/// - **MultiSampling16X**: Multi-sampling 16X mode.
enum AntialiasingModes: String, CaseIterable
{
    case None = "None"
    case MultiSampling2X = "MultiSampling2X"
    case Multisampling4X = "MultiSampling4X"
    case Multisampling8X = "MultiSampling8X"
    case Multisampling16X = "Multisampling16X"
}
