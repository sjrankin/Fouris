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
    /// - Parameter: The field that changed.
    func ChangeNotice(Field: ThemeFields)
    {
        ChangeDelegate?.ThemeChanged(Theme: self, Field: Field)
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
                //GameLights
                _LightType = GameLights(rawValue: Value)!
            
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
            
            case "_RotatingBucketDirection":
                //BucketRotationTypes
                _RotatingBucketDirection = BucketRotationTypes(rawValue: Value)!
            
            case "_RotateBucket":
                //Bool
                _RotateBucket = Bool(Value)!
            
            case "_RotationDuration":
                //Double
                _RotationDuration = Double(Value)!
            
            case "_RotateBucketGrid":
                //Bool
                _RotateBucketGrid = Bool(Value)!
            
            case "_FadeBucketGrid":
                //Bool
                _FadeBucketGrid = Bool(Value)!
            
            case "_FadeBucketOutline":
                //Bool
                _FadeBucketOutline = Bool(Value)!
            
            case "_BackgroundType":
                //BackgroundTypes3D
                _BackgroundType = BackgroundTypes3D(rawValue: Sanitized)!
            
            //Game background properties.
            
            case "_BackgroundSolidColor":
                //String
                _BackgroundSolidColor = Sanitized
            
            case "_BackgroundSolidColorCycleTime":
                //Double
                _BackgroundSolidColorCycleTime = Double(Value)!
            
            case "_BackgroundGradientColor":
                //String
                _BackgroundGradientColor = Sanitized
            
            case "_BackgroundGradientCycleTime":
                //Double
                _BackgroundGradientCycleTime = Double(Value)!
            
            case "_BackgroundImageName":
                //String
                _BackgroundImageName = Sanitized
            
            case "_BackgroundImageFromCameraRoll":
                //Bool
                _BackgroundImageFromCameraRoll = Bool(Value)!
            
            case "_BackgroundLiveImageCamera":
                //CameraLocations
                _BackgroundLiveImageCamera = CameraLocations(rawValue: Sanitized)!
            
            case "_MinimumVersion":
                //Int
                _MinimumVersion = Int(Value)!
            
            case "_MinimumBuild":
                //Int
                _MinimumBuild = Int(Value)!
            
            case "_AutoStartDuration":
                //Double
                _AutoStartDuration = Double(Value)!
            
            case "_GameType":
                //BaseGameTypes
                _GameType = BaseGameTypes(rawValue: Value)!
            
            case "_IsUserTheme":
                //Bool
                _IsUserTheme = Bool(Value)!
            
            case "_IsDefaultTheme":
                //Bool
                _IsDefaultTheme = Bool(Value)!
            
            case "_FileName":
                //Do nothing for this field.
                break
            
            case "_SaveAfterEdit":
                //Do nothing for this field.
                break
            
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
            ChangeNotice(Field: .ShowBucketGrid)
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
            ChangeNotice(Field: .ShowGrid)
        }
    }
    
    /// Holds the show bucket grid outline flag.
    private var _ShowBucketGridOutline: Bool = true
    /// Get or set the show bucket grid outline flag.
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
            ChangeNotice(Field: .ShowBucketGridOutline)
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
            ChangeNotice(Field: .BucketGridColor)
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
            ChangeNotice(Field: .BucketGridOutlineColor)
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
            ChangeNotice(Field: .BucketSpecularColor)
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
            ChangeNotice(Field: .BucketDiffuseColor)
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
            ChangeNotice(Field: .IsOrthographic)
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
            ChangeNotice(Field: .OrthographicScale)
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
            ChangeNotice(Field: .CameraFieldOfView)
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
            ChangeNotice(Field: .UseDefaultCamera)
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
            ChangeNotice(Field: .CameraPosition)
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
            ChangeNotice(Field: .CameraOrientation)
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
            ChangeNotice(Field: .ShowStatistics)
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
            ChangeNotice(Field: .ShowBackgroundGrid)
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
            ChangeNotice(Field: .CanControlCamera)
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
            ChangeNotice(Field: .LightColor)
        }
    }
    
    /// Holds the type of the light.
    private var _LightType: GameLights = .omni
    /// Get or set the type of the light.
    public var LightType: GameLights
    {
        get
        {
            return _LightType
        }
        set
        {
            _LightType = newValue
            _Dirty = true
            ChangeNotice(Field: .LightType)
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
            ChangeNotice(Field: .LightPosition)
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
            ChangeNotice(Field: .LightIntensity)
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
            ChangeNotice(Field: .UseDefaultLighting)
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
            ChangeNotice(Field: .AntialiasingMode)
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
            ChangeNotice(Field: .BackgroundType)
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
            ChangeNotice(Field: .BackgroundSolidColor)
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
            ChangeNotice(Field: .BackgroundSolidColorCycleTime)
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
            ChangeNotice(Field: .BackgroundGradientColor)
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
            ChangeNotice(Field: .BackgroundGradientColorCycleTime)
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
            ChangeNotice(Field: .BackgroundImageName)
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
            ChangeNotice(Field: .BackgroundImageFromCameraRoll)
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
            ChangeNotice(Field: .BackgroundLiveImageCamera)
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
            ChangeNotice(Field: .UseHapticFeedback)
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
            ChangeNotice(Field: .AfterGameWaitDuration)
        }
    }
    
    /// Holds the auto start duration.
    private var _AutoStartDuration: Double = 60.0
    /// Get or set the length of time (in seconds) from game start to running a game in attract/AI mode.
    public var AutoStartDuration: Double
    {
        get
        {
            return _AutoStartDuration
        }
        set
        {
            _AutoStartDuration = newValue
            _Dirty = true
            ChangeNotice(Field: .AutoStartDuration)
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
            ChangeNotice(Field: .DestructionMethod)
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
            ChangeNotice(Field: .DestructionDuration)
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
            ChangeNotice(Field: .ShowAIActionsOnControls)
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
            ChangeNotice(Field: .StartWithAI)
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
            ChangeNotice(Field: .AISneakPeakCount)
        }
    }
    
    // MARK: Game play properties.
    
    /// Holds the game type.
    private var _GameType: BaseGameTypes = .Standard
    /// Get or set the game type.
    public var GameType: BaseGameTypes
    {
        get
        {
            return _GameType
        }
        set
        {
            _GameType = newValue
            _Dirty = true
            ChangeNotice(Field: .GameType)
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
            ChangeNotice(Field: .RotatingBucketDirection)
        }
    }
    
    /// Holds the rotate bucket flag.
    private var _RotateBucket: Bool = true
    /// Get or set the rotate bucket flag.
    public var RotateBucket: Bool
    {
        get
        {
            return _RotateBucket
        }
        set
        {
            _RotateBucket = newValue
            _Dirty = true
            ChangeNotice(Field: .RotateBucket)
        }
    }
    
    /// Holds the time to rotate the bucket.
    private var _RotationDuration: Double = 0.3
    /// Get or set the number of seconds to take to rotate the bucket.
    public var RotationDuration: Double
    {
        get
        {
            return _RotationDuration
        }
        set
        {
            _RotationDuration = newValue
            _Dirty = true
            ChangeNotice(Field: .RotationDuration)
        }
    }
    
    /// Holds the rotate bucket grid along with the bucket flag.
    private var _RotateBucketGrid: Bool = false
    /// Get or set the rotate bucket grid with the bucket flag.
    public var RotateBucketGrid: Bool
    {
        get
        {
            return _RotateBucketGrid
        }
        set
        {
            _RotateBucketGrid = newValue
            _Dirty = true
            ChangeNotice(Field: .RotateBucketGrid)
        }
    }
    
    /// Holds the fade bucket grid flag.
    private var _FadeBucketGrid: Bool = false
    /// Get or set the fade bucket grid flag.
    public var FadeBucketGrid: Bool
    {
        get
        {
            return _FadeBucketGrid
        }
        set
        {
            _FadeBucketGrid = newValue
            _Dirty = true
            ChangeNotice(Field: .FadeBucketGrid)
        }
    }
    
    /// Holds the fade bucket outline flag.
    private var _FadeBucketOutline: Bool = false
    /// Get or set the fade bucket outline flag.
    public var FadeBucketOutline: Bool
    {
        get
        {
            return _FadeBucketOutline
        }
        set
        {
            _FadeBucketOutline = newValue
            _Dirty = true
            ChangeNotice(Field: .FadeBucketOutline)
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
            ChangeNotice(Field: .ShowNextPiece)
        }
    }
    
    // MARK: General descriptor properties.
    
    /// Holds the minimum version number this theme is valid for.
    private var _MinimumVersion: Int = 0
    /// Get or set the minimum version number of Fouris that is needed to support this theme.
    public var MinimumVersion: Int
    {
        get
        {
            return _MinimumVersion
        }
        set
        {
            _MinimumVersion = newValue
            _Dirty = true
            ChangeNotice(Field: .MinimumVersion)
        }
    }
    
    /// Holds the minimum build number this theme is valid for.
    private var _MinimumBuild: Int = 0
    /// Get or set the minimum build number of Fouris that is needed to support this theme.
    public var MinimumBuild: Int
    {
        get
        {
            return _MinimumBuild
        }
        set
        {
            _MinimumBuild = newValue
            _Dirty = true
            ChangeNotice(Field: .MinimumBuild)
        }
    }
    
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
    
    /// Returns the file name (from **FileName**) as two parts - the name itself and the extension.
    /// - Returns: Tuple with file name parts.
    public func FileNameParts() -> (Name: String, Extension: String)
    {
        let Parts = FileName.split(separator: ".")
        if Parts.count != 2
        {
            return ("", "")
        }
        return (Name: String(Parts[0]), Extension: "." + String(Parts[1]))
    }
    
    /// Holds the save after edit flag.
    private var _SaveAfterEdit: Bool = true
    /// Get or set the save after edit flag.
    /// - Note: If this property is true, the theme is saved after every edit/change made to a property (provided
    ///         the dirty flag is true, which should be the case).
    public var SaveAfterEdit: Bool
    {
        get
        {
            return _SaveAfterEdit
        }
        set
        {
            _SaveAfterEdit = newValue
        }
    }
    
    /// Holds the user theme flag.
    private var _IsUserTheme: Bool = false
    /// Get or set the flag that indicates this is the user-editable theme.
    public var IsUserTheme: Bool
    {
        get
        {
            return _IsUserTheme
        }
        set
        {
            _IsUserTheme = newValue
        }
    }
    
    /// Holds the default theme flag.
    private var _IsDefaultTheme: Bool = false
    /// Get or set the flag that indicates this is the default theme.
    public var IsDefaultTheme: Bool
    {
        get
        {
            return _IsDefaultTheme
        }
        set
        {
            _IsDefaultTheme = newValue
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
    case MultiSampling4X = "MultiSampling4X"
    case MultiSampling8X = "MultiSampling8X"
    case MultiSampling16X = "MultiSampling16X"
}

/// Game light types.
/// - **omni**: Omni light.
/// - **spot**: Spot light.
/// - **directional**: Directional light.
/// - **ambient**: Ambient light.
enum GameLights: String, CaseIterable
{
    case omni = "omni"
    case spot = "spot"
    case directional = "directional"
    case ambient = "ambient"
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

/// Theme fields used when fields are changed and subscribers are notified.
/// - Note: Field name is used as cases for the enum. Refer to the function
///         definition for the meaning/use fo the field.
enum ThemeFields: String, CaseIterable
{
    case ShowBucketGrid = "ShowBucketGrid"
    case ShowGrid = "ShowGrid"
    case ShowBucketGridOutline = "ShowBucketGridOutline"
    case BucketGridColor = "BucketGridColor"
    case BucketGridOutlineColor = "BucketGridOutlineColor"
    case BucketSpecularColor = "BucketSpecularColor"
    case BucketDiffuseColor = "BucketDiffuseColor"
    case IsOrthographic = "IsOrthographic"
    case OrthographicScale = "OrthographicScale"
    case CameraFieldOfView = "CameraFieldOfView"
    case UseDefaultCamera = "UseDefaultCamera"
    case CameraPosition = "CameraPosition"
    case CameraOrientation = "CameraOrientation"
    case ShowStatistics = "ShowStatistics"
    case ShowBackgroundGrid = "ShowBackgroundGrid"
    case CanControlCamera = "CanControlCamera"
    case LightColor = "LightColor"
    case LightType = "LightType"
    case LightPosition = "LightPosition"
    case LightIntensity = "LightIntensity"
    case UseDefaultLighting = "UseDefaultLighting"
    case AntialiasingMode = "AntialiasingMode"
    case BackgroundType = "BackgroundType"
    case BackgroundSolidColor = "BackgroundSolidColor"
    case BackgroundSolidColorCycleTime = "BackgroundSolidColorCycleTime"
    case BackgroundGradientColor = "BackgroundGradientColor"
    case BackgroundGradientColorCycleTime = "BackgroundGradientColorCycleTime"
    case BackgroundImageName = "BackgroundImageName"
    case BackgroundImageFromCameraRoll = "BackgroundImageFromCameraRoll"
    case BackgroundLiveImageCamera = "BackgroundLiveImageCamera"
    case UseHapticFeedback = "UseHapticFeedback"
    case AfterGameWaitDuration = "AfterGameWaitDuration"
    case DestructionMethod = "DestructionMethod"
    case DestructionDuration = "DestructionDuration"
    case ShowAIActionsOnControls = "ShowAIActionsOnControls"
    case StartWithAI = "StartWithAI"
    case AISneakPeakCount = "AISneakPeakCount"
    case GameType = "GameType"
    case RotatingBucketDirection = "RotatingBucketDirection"
    case RotateBucket = "RotateBucket"
    case RotationDuration = "RotationDuration"
    case RotateBucketGrid = "RotateBucketGrid"
    case FadeBucketGrid = "FadeBucketGrid"
    case FadeBucketOutline = "FadeBucketOutline"
    case ShowNextPiece = "ShowNextPiece"
    case MinimumVersion = "MinimumVersion"
    case MinimumBuild = "MinimumBuild"
    case AutoStartDuration = "AutoStartDuration"
}
