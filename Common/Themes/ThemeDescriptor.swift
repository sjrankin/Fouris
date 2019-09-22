//
//  ThemeDescriptor.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit
import UIKit

/// Contains the description of a visual theme.
class ThemeDescriptor: Serializable
{
    /// Change notification delegate.
    weak var ChangeDelegate: ThemeChangeProtocol? = nil
    
    /// Initializer.
    init()
    {
        _Dirty = false
    }
    
    /// Called when a property changes (but not when the theme is deserialized).
    /// - Parameter: Name of the field that changed.
    func ChangeNotice(FieldName: String)
    {
        ChangeDelegate?.ThemeChanged(ThemeName: ThemeName, FieldName: FieldName)
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
            
            case "_ID":
                //UUID
                _ID = UUID(uuidString: Sanitized)!
            
            case "_Title":
                //String
                _Title = Sanitized
            
            case "_Created":
                //String
                _Created = Sanitized
            
            case "_Edited":
                //String
                _Edited = Sanitized
            
            //General properties.
            
            case "_BackgroundType":
                //BackgroundTypes3D
                _BackgroundType = BackgroundTypes3D(rawValue: Sanitized)!
            
            case "_BucketDiffuseColor":
                //String
                _BucketDiffuseColor = Sanitized
            
            case "_BucketSpecularColor":
                //String
                _BucketSpecularColor = Sanitized
            
            case "_ShowGrid":
                //Bool
                _ShowGrid = Bool(Value)!
            
            case "_ShowBucketGrid":
                //Bool
                _ShowBucketGrid = Bool(Value)!
            
            case "_ShowBucketGridOutline":
                //Bool
                _ShowBucketGridOutline = Bool(Value)!
            
            case "_BucketGridColor":
                //String
                _BucketGridColor = Sanitized
            
            case "_BucketGridOutlineColor":
                //String
                _BucketGridOutlineColor = Sanitized
            
            case "_AntialiasingMode":
                //AntialiasingModes
                _AntialiasingMode = AntialiasingModes(rawValue: Sanitized)!
            
            case "_CameraFieldOfView":
                //Double
                _CameraFieldOfView = Double(Sanitized)!
            
            case "_UseDefaultCamera":
            //Bool
            _UseDefaultCamera = Bool(Value)!
            
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
            
            case "_LightIntensity":
            //Double
            _LightIntensity = Double(Value)!
            
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
            
            case "_IsOrthographic":
                //Bool
                _IsOrthographic = Bool(Value)!
            
            case "_OrthographicScale":
                //Double
                _OrthographicScale = Double(Value)!
            
            case "_ShowAIActionsOnControls":
                //Bool
                _ShowAIActionsOnControls = Bool(Value)!
            
            case "_StartWithAI":
                //Bool
                _StartWithAI = Bool(Value)!
            
            case "_AISneakPeakCount":
                //Int
                _AISneakPeakCount = Int(Value)!
            
            case "_DestructionMethod":
                //DestructionMethods
                _DestructionMethod = DestructionMethods(rawValue: Value)!
            
            case "_DestructionDuration":
                //Double
                _DestructionDuration = Double(Value)!
            
            case "_AfterGameWaitDuration":
                //Double
                _AfterGameWaitDuration = Double(Value)!
            
            case "_UseHapticFeedback":
                //Bool
                _UseHapticFeedback = Bool(Value)!
            
            case "_ShowBackgroundGrid":
            //Bool
            _ShowBackgroundGrid = Bool(Value)!
            
            case "_ShowNextPiece":
            //Bool
            _ShowNextPiece = Bool(Value)!
            
            default:
                print("Encountered unexpected key (\(Key)) in ThemeDescriptor.Populate")
                break
        }
    }
    
    /// Splits a string into an array of double values.
    /// - Note:
    ///    - The string is assumed to containly only double values separated by the `With` character.
    ///    - A fatal error is generated if:
    ///       - The number of found values is not the same as the expected number of values found
    ///         in `ExpectedCount`.
    ///       - A value fails to be converted into a Double.
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
    
    // MARK: Bucket properties.
    
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
            ChangeNotice(FieldName: "ShowBucketGrid")
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
            ChangeNotice(FieldName: "ShowGrid")
        }
    }
    
    private var _ShowBucketGridOutline: Bool = true
    public var ShowBucketGridOutline: Bool
    {
        get
        {
            return _ShowBucketGridOutline
        }
        set
        {
            _ShowBucketGridOutline = newValue
            _Dirty = true
            ChangeNotice(FieldName: "ShowBucketGridOutline")
        }
    }
    
    /// Holds the name/value of the bucket grid color.
    private var _BucketGridColor: String = "Gray"
    /// Get or set the name (or value in string format) of the bucket grid color.
    public var BucketGridColor: String
    {
        get
        {
            return _BucketGridColor
        }
        set
        {
            _BucketGridColor = newValue
            _Dirty = true
            ChangeNotice(FieldName: "BucketGridColor")
        }
    }
    
    /// Holds the name/value of the bucket grid outline color.
    private var _BucketGridOutlineColor: String = "Red"
    /// Get or set the name (or value in string format) of the bucket grid outline color.
    public var BucketGridOutlineColor: String
    {
        get
        {
            return _BucketGridOutlineColor
        }
        set
        {
            _BucketGridOutlineColor = newValue
            _Dirty = true
            ChangeNotice(FieldName: "BucketGridOutlineColor")
        }
    }
    
    /// Holds the specular color of the bucket.
    private var _BucketSpecularColor: String = "White"
    /// Get or set the specular color name for the bucket.
    public var BucketSpecularColor: String
    {
        get
        {
            return _BucketSpecularColor
        }
        set
        {
            _BucketSpecularColor = newValue
            _Dirty = true
            ChangeNotice(FieldName: "BucketSpecularColor")
        }
    }
    
    /// Holds the diffuse color of the bucket.
    private var _BucketDiffuseColor: String = "Black"
    /// Get or set the specular color name for the bucket.
    public var BucketDiffuseColor: String
    {
        get
        {
            return _BucketDiffuseColor
        }
        set
        {
            _BucketDiffuseColor = newValue
            _Dirty = true
            ChangeNotice(FieldName: "BucketDiffuseColor")
        }
    }
    
    // MARK: Camera properties.
    
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
            ChangeNotice(FieldName: "IsOrthographic")
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
            ChangeNotice(FieldName: "OrthographicScale")
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
            ChangeNotice(FieldName: "CamerFieldOfView")
        }
    }
    
    /// Holds the use default camera flag.
    private var _UseDefaultCamera: Bool = false
    /// Get or set the use default camera flag.
    public var UseDefaultCamera: Bool
    {
        get
        {
            return _UseDefaultCamera
        }
        set
        {
            _UseDefaultCamera = newValue
            _Dirty = true
            ChangeNotice(FieldName: "UseDefaultCamera")
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
            ChangeNotice(FieldName: "CameraPosition")
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
            ChangeNotice(FieldName: "CameraOrientation")
        }
    }
    
    // MARK: Debug properties.
    
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
            ChangeNotice(FieldName: "ShowStatistics")
        }
    }
    
    /// Holds the show background grid flag.
    private var _ShowBackgroundGrid: Bool = false
    /// Get or set the show background grid flag.
    public var ShowBackgroundGrid: Bool
    {
        get
        {
            return _ShowBackgroundGrid
        }
        set
        {
            _ShowBackgroundGrid = newValue
            _Dirty = true
            ChangeNotice(FieldName: "ShowBackgroundGrid")
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
            ChangeNotice(FieldName: "CanControlCamera")
        }
    }
    
    // MARK: Light properties.
    
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
            ChangeNotice(FieldName: "LightColor")
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
            ChangeNotice(FieldName: "LightType")
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
            ChangeNotice(FieldName: "LightPosition")
        }
    }
    
    /// Holds the light intensity value.
    private var _LightIntensity: Double = 1000.0
    /// Get or set the light intensity value.
    public var LightIntensity: Double
    {
        get
        {
            return _LightIntensity
        }
        set
        {
            _LightIntensity = newValue
            _Dirty = true
            ChangeNotice(FieldName: "LightIntensity")
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
            ChangeNotice(FieldName: "UseDefaultLighting")
        }
    }
    
    // MARK: Rendering properties.
    
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
            ChangeNotice(FieldName: "AntialiasingMode")
        }
    }
    
    // MARK: Background properties.
    
    /// Holds the background type for 3D game views.
    private var _BackgroundType: BackgroundTypes3D = .Color
    /// Get or set the background type for 3D game views.
    public var BackgroundType: BackgroundTypes3D
    {
        get
        {
            return _BackgroundType
        }
        set
        {
            _BackgroundType = newValue
            _Dirty = true
            ChangeNotice(FieldName: "BackgroundType")
        }
    }
    
    /// Holds the name of the background solid color.
    private var _BackgroundSolidColor: String = "Maroon"
    /// Get or set the name of the background solid color.
    public var BackgroundSolidColor: String
    {
        get
        {
            return _BackgroundSolidColor
        }
        set
        {
            _BackgroundSolidColor = newValue
            _Dirty = true
            ChangeNotice(FieldName: "BackgroundSolidColor")
        }
    }
    
    /// Holds the amount of time to cycle through the hues of the background solid color.
    private var _BackgroundSolidColorCycleTime: Double = 0.0
    /// Get or set the time (in seconds) to cycle through the hues of the background solid color.
    public var BackgroundSolidColorCycleTime: Double
    {
        get
        {
            return _BackgroundSolidColorCycleTime
        }
        set
        {
            _BackgroundSolidColorCycleTime = newValue
            _Dirty = true
            ChangeNotice(FieldName: "BackgroundSolidColorCycleTime")
        }
    }
    
    /// Holds the background gradient descriptor.
    private var _BackgroundGradientColor: String = "(Red)@(0.0),(Blue)@(1.0)"
    /// Get or set the background gradient descriptor.
    public var BackgroundGradientColor: String
    {
        get
        {
            return _BackgroundGradientColor
        }
        set
        {
            _BackgroundGradientColor = newValue
            _Dirty = true
            ChangeNotice(FieldName: "BackgroundGradientColor")
        }
    }
    
    /// Holds the cycle time for cycling through gradient hues.
    private var _BackgroundGradientCycleTime: Double = 0.0
    /// Get or set the time (in seconds) to cycle through the hues of the gradient colors.
    public var BackgroundGradientCycleTime: Double
    {
        get
        {
            return _BackgroundGradientCycleTime
        }
        set
        {
            _BackgroundGradientCycleTime = newValue
            _Dirty = true
            ChangeNotice(FieldName: "BackgroundGradientCycleTime")
        }
    }
    
    /// Holds the name of the background image.
    private var _BackgroundImageName: String = ""
    /// Get or set the background image name.
    public var BackgroundImageName: String
    {
        get
        {
            return _BackgroundImageName
        }
        set
        {
            _BackgroundImageName = newValue
            _Dirty = true
            ChangeNotice(FieldName: "BackgroundImageName")
        }
    }
    
    /// Holds the flag that tells the program where to look for the background image.
    private var _BackgroundImageFromCameraRoll: Bool = true
    /// Flag that tells the program where to look for the background image. If true, the camera roll is searched. Otherwise,
    /// local (to the program) images are searched.
    public var BackgroundImageFromCameraRoll: Bool
    {
        get
        {
            return _BackgroundImageFromCameraRoll
        }
        set
        {
            _BackgroundImageFromCameraRoll = newValue
            _Dirty = true
            ChangeNotice(FieldName: "BackgroundImageFromCameraRoll")
        }
    }
    
    /// Holds the camera to use to generate a live view background.
    private var _BackgroundLiveImageCamera: CameraLocations = .Rear
    /// Get or set the camera to use to generate a live view background. Ignored on devices (or simulators) that don't have cameras.
    public var BackgroundLiveImageCamera: CameraLocations
    {
        get
        {
            return _BackgroundLiveImageCamera
        }
        set
        {
            _BackgroundLiveImageCamera = newValue
            _Dirty = true
            ChangeNotice(FieldName: "BackgroundLiveImageCamera")
        }
    }
    
    // MARK: Haptic properties.
    
    /// Holds the use haptic feedback flag.
    private var _UseHapticFeedback: Bool = false
    /// Get the use haptic feedback flag. Haptic feedback is available only on certain devices.
    public var UseHapticFeedback: Bool
    {
        get
        {
            return _UseHapticFeedback
        }
        set
        {
            _UseHapticFeedback = newValue
            _Dirty = true
            ChangeNotice(FieldName: "UseHapticFeedback")
        }
    }
    
    // MARK: Game over properties.
    
    /// Holds the amount of time to wait after game over before starting a new game in AI mode.
    private var _AfterGameWaitDuration: Double = 15.0
    /// Get or set the amount of time to wait after game over before starting a new game in AI/attract mode.
    /// Time is in seconds.
    public var AfterGameWaitDuration: Double
    {
        get
        {
            return _AfterGameWaitDuration
        }
        set
        {
            _AfterGameWaitDuration = newValue
            _Dirty = true
            ChangeNotice(FieldName: "AfterGameWaitDuration")
        }
    }
    
    /// Holds the method type to clear the bucket of blocks.
    private var _DestructionMethod: DestructionMethods = .Shrink
    /// Get or set the method type used to clear the bucket of blocks.
    public var DestructionMethod: DestructionMethods
    {
        get
        {
            return _DestructionMethod
        }
        set
        {
            _DestructionMethod = newValue
            _Dirty = true
            ChangeNotice(FieldName: "DestructionMethod")
        }
    }
    
    /// Holds the length of time to clear the bucket of blocks.
    private var _DestructionDuration: Double = 1.25
    /// Get or set the length of time to clear the blocks in the bucket, in seconds.
    public var DestructionDuration: Double
    {
        get
        {
            return _DestructionDuration
        }
        set
        {
            _DestructionDuration = newValue
            _Dirty = true
            ChangeNotice(FieldName: "DestructionDuration")
        }
    }
    
    // MARK: AI properties.
    
    /// Holds the show AI actions on the UI control set flag.
    private var _ShowAIActionsOnControls: Bool = true
    /// Get or set the AI "uses" (eg, shows) actions on the UI control set flag.
    public var ShowAIActionsOnControls: Bool
    {
        get
        {
            return _ShowAIActionsOnControls
        }
        set
        {
            _ShowAIActionsOnControls = newValue
            _Dirty = true
            ChangeNotice(FieldName: "ShowAIActionsOnControls")
        }
    }
    
    private var _StartWithAI: Bool = false
    public var StartWithAI: Bool
    {
        get
        {
            return _StartWithAI
        }
        set
        {
            _StartWithAI = newValue
            _Dirty = true
            ChangeNotice(FieldName: "StartWithAI")
        }
    }
    
    /// Holds the AI sneak peak count.
    private var _AISneakPeakCount: Int = 1
    /// Get or set the number of pieces ahead the AI looks when calculating the best spot for pieces under
    /// its control.
    public var AISneakPeakCount: Int
    {
        get
        {
            return _AISneakPeakCount
        }
        set
        {
            _AISneakPeakCount = newValue
            _Dirty = true
            ChangeNotice(FieldName: "AISneakPeakCount")
        }
    }
    
    // MARK: Game play properties.
    
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
            ChangeNotice(FieldName: "GameType")
        }
    }
    
    /// Holds the bucket rotation type.
    private var _RotatingBucketDirection: BucketRotationTypes = .Right
    /// Get or set the direction the bucket rotates.
    public var RotatingBucketDirection: BucketRotationTypes
    {
        get
        {
            return _RotatingBucketDirection
        }
        set
        {
            _RotatingBucketDirection = newValue
            _Dirty = true
            ChangeNotice(FieldName: "RotatingBucketDirection")
        }
    }
    
    /// Holds the show next piece flag.
    private var _ShowNextPiece: Bool = true
    /// Get or set the show next piece flag.
    public var ShowNextPiece: Bool
    {
        get
        {
            return _ShowNextPiece
        }
        set
        {
            _ShowNextPiece = newValue
            _Dirty = true
            ChangeNotice(FieldName: "ShowNextPiece")
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
    
    /// Holds the create date.
    private var _Created: String = ""
    /// Get or set the create date.
    public var CreateDate: String
    {
        get
        {
            return _Created
        }
        set
        {
            _Created = newValue
            _Dirty = true
        }
    }
    
    /// Holds the edit date.
    private var _Edited: String = ""
    /// Get or set the edit date.
    public var EditDate: String
    {
        get
        {
            return _Edited
        }
        set
        {
            _Edited = newValue
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
    
    /// Holds the name of the source file.
    private var _FileName: String = ""
    /// Get or set the source file name for the theme.
    public var FileName: String
    {
        get
        {
            return _FileName
        }
        set
        {
            _FileName = newValue
        }
    }
    
    // MARK: Tile lists and list handling.
    
    /// Creates and returns a new tile descriptor class.
    ///
    /// - Returns: New tile descriptor class.
    public func MakeTileDescriptor() -> TileDescriptor
    {
        return TileDescriptor()
    }
    
    /// Holds a list of tile descriptors, one for each piece in a set.
    private var _TileList = [TileDescriptor](repeating: TileDescriptor(), count: 10)
    /// Get or set the list of tile descriptors. Each descriptor should be applied to a single piece shape.
    public var TileList: [TileDescriptor]
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
    public func TileDescriptorFor(_ ID: UUID) -> TileDescriptor?
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
/// - **Gradient**: Gradient descriptor.
/// - **Image**: Name of an image to display.
/// - **Texture**: Name of a texture.
/// - **CALayer**: Name of a CALayer.
/// - **LiveView**: Uses live view background (when available).
enum BackgroundTypes3D: String, CaseIterable
{
    case Color = "Color"
    case Gradient = "Gradient"
    case Image = "Image"
    case Texture = "Texture"
    case CALayer = "CALayer"
    case LiveView = "LiveView"
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

/// Rotation direction/types.
/// - **None**: No rotation.
/// - **Right**: Rotate right (clockwise).
/// - **Left**: Rotate left (counterclockwise).
/// - **Random**: Rotate to random, ordinal locations.
enum BucketRotationTypes: String, CaseIterable
{
    case None = "None"
    case Right = "Right"
    case Left = "Left"
    case Random = "Random"
}
