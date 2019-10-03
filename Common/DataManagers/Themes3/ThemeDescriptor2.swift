//
//  ThemeDescriptor2.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class ThemeDescriptor2: CustomStringConvertible, XMLDeserializeProtocol
{
    weak var ChangeDelegate: ThemeChangeProtocol2? = nil
    
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
    
    private var _Dirty: Bool = false
    public var Dirty: Bool
    {
        get
        {
            return _Dirty
        }
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
    
    /// Holds the color of the control light.
    private var _ControlLightColor: String = "White"
    /// Get or set the name of the color of the light.
    public var ControlLightColor: String
    {
        get
        {
            return _ControlLightColor
        }
        set
        {
            _ControlLightColor = newValue
            _Dirty = true
            ChangeNotice(Field: .ControlLightColor)
        }
    }
    
    /// Holds the type of the control light.
    private var _ControlLightType: GameLights = .omni
    /// Get or set the type of the light.
    public var ControlLightType: GameLights
    {
        get
        {
            return _ControlLightType
        }
        set
        {
            _ControlLightType = newValue
            _Dirty = true
            ChangeNotice(Field: .LightType)
        }
    }
    
    /// Holds the position of the control light.
    private var _ControlLightPosition: SCNVector3 = SCNVector3(0,0,0)
    /// Get or set the position of the light.
    public var ControlLightPosition: SCNVector3
    {
        get
        {
            return _ControlLightPosition
        }
        set
        {
            _ControlLightPosition = newValue
            _Dirty = true
            ChangeNotice(Field: .LightPosition)
        }
    }
    
    /// Holds the contorl light intensity value.
    private var _ControlLightIntensity: Double = 1000.0
    /// Get or set the light intensity value.
    public var ControlLightIntensity: Double
    {
        get
        {
            return _ControlLightIntensity
        }
        set
        {
            _ControlLightIntensity = newValue
            _Dirty = true
            ChangeNotice(Field: .LightIntensity)
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
    
    private var _RotateNextPiece: Bool = true
    public var RotateNextPiece: Bool
    {
        get
        {
            return _RotateNextPiece
        }
        set
        {
            _RotateNextPiece = newValue
            _Dirty = true
            ChangeNotice(Field: .RotateNextPiece)
        }
    }
    
    // MARK: Button properites.
    
    private var _HideAllButtons: Bool = false
    public var HideAllButtons: Bool
    {
        get
        {
            return _HideAllButtons
        }
        set
        {
            _HideAllButtons = newValue
            _Dirty = true
            ChangeNotice(Field: .HideAllButtons)
        }
    }
    
    /// Holds the show up button value.
    private var _ShowUpButton: Bool = true
    /// Get or set the show up motion button flag.
    public var ShowUpButton: Bool
    {
        get
        {
            return _ShowUpButton
        }
        set
        {
            _ShowUpButton = newValue
            _Dirty = true
            ChangeNotice(Field: .ShowUpButton)
        }
    }
    
    /// Holds the show fly away button value.
    private var _ShowFlyAwayButton: Bool = true
    /// Get or set the show fly away button flag.
    public var ShowFlyAwayButton: Bool
    {
        get
        {
            return _ShowFlyAwayButton
        }
        set
        {
            _ShowFlyAwayButton = newValue
            _Dirty = true
            ChangeNotice(Field: .ShowFlyAwayButton)
        }
    }
    
    /// Holds the show drop down button flag.
    private var _ShowDropDownButton: Bool = true
    /// Get or set the show drop down button flag.
    public var ShowDropDownButton: Bool
    {
        get
        {
            return _ShowDropDownButton
        }
        set
        {
            _ShowDropDownButton = newValue
            _Dirty = true
            ChangeNotice(Field: .ShowDropDownButton)
        }
    }
    
    /// Holds the show freeze button flag.
    private var _ShowFreezeButton: Bool = true
    /// Get or set the show freeze button flag.
    public var ShowFreezeButton: Bool
    {
        get
        {
            return _ShowFreezeButton
        }
        set
        {
            _ShowFreezeButton = newValue
            _Dirty = true
            ChangeNotice(Field: .ShowFreezeButton)
        }
    }
    
    // MARK: Debug properties.
    
    private var _EnableDebug: Bool = false
    public var EnableDebug: Bool
    {
        get
        {
            return _EnableDebug
        }
        set
        {
            _EnableDebug = newValue
            _Dirty = true
            ChangeNotice(Field: .EnableDebug)
        }
    }
    
    private var _BackgroundGridWidth: Double = 2.0
    public var BackgroundGridWidth: Double
    {
        get
        {
            return _BackgroundGridWidth
        }
        set
        {
            _BackgroundGridWidth = newValue
            _Dirty = true
            ChangeNotice(Field: .BackgroundGridWidth)
        }
    }
    
    private var _BackgroundGridColor: String = "ReallyDarkGray"
    public var BackgroundGridColor: String
    {
        get
        {
            return _BackgroundGridColor
        }
        set
        {
            _BackgroundGridColor = newValue
            _Dirty = true
            ChangeNotice(Field: .BackgroundGridColor)
        }
    }
    
    private var _ShowCenterLines: Bool = false
    public var ShowCenterLines: Bool
    {
        get
        {
            return _ShowCenterLines
        }
        set
        {
            _ShowCenterLines = newValue
            _Dirty = true
            ChangeNotice(Field: .ShowCenterLines)
        }
    }
    
    private var _CenterLineColor: String = "Yellow"
    public var CenterLineColor: String
    {
        get
        {
            return _CenterLineColor
        }
        set
        {
            _CenterLineColor = newValue
            _Dirty = true
            ChangeNotice(Field: .CenterLineColor)
        }
    }
    
    private var _CenterLineWidth: Double = 2.0
    public var CenterLineWidth: Double
    {
        get
        {
            return _CenterLineWidth
        }
        set
        {
            _CenterLineWidth = newValue
            _Dirty = true
            ChangeNotice(Field: .CenterLineWidth)
        }
    }
    
    // MARK: Block list.
    
    private var _BlockList: [UUID] = [UUID]()
    public var BlockList: [UUID]
    {
        get
        {
            return _BlockList
        }
        set
        {
            _BlockList = newValue
            _Dirty = true
            ChangeNotice(Field: .BlockList)
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
    
    // MARK: Deserialization routines.
    
    func DeserializedNode(_ Node: XMLNode)
    {
        switch Node.Name
        {
            case "Theme":
                let ThID = XMLNode.GetAttributeNamed("ID", InNode: Node)!
                let ThName = XMLNode.GetAttributeNamed("Name", InNode: Node)!
                let UTheme = XMLNode.GetAttributeNamed("UserTheme", InNode: Node)!
                _ID = UUID(uuidString: ThID)!
                _ThemeName = ThName
                _IsUserTheme = Bool(UTheme)!
                
                for Child in Node.Children
                {
                    switch Child.Name
                    {
                        case "Runtime":
                            let MinVer = XMLNode.GetAttributeNamed("MinimumVersion", InNode: Child)!
                            let MinBld = XMLNode.GetAttributeNamed("MinimumBuild", InNode: Child)!
                            MinimumVersion = Int(MinVer)!
                            MinimumBuild = Int(MinBld)!
                        
                        case "Dates":
                            let CDate = XMLNode.GetAttributeNamed("Created", InNode: Child)!
                            let EDate = XMLNode.GetAttributeNamed("Edited", InNode: Child)!
                            CreateDate = CDate
                            EditDate = EDate
                        
                        case "Quality":
                            for QChild in Child.Children
                            {
                                switch QChild.Name
                                {
                                    case "Antialiasing":
                                        let AA = XMLNode.GetAttributeNamed("Mode", InNode: QChild)!
                                        AntialiasingMode = AntialiasingModes(rawValue: AA)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Camera":
                            for CChild in Child.Children
                            {
                                switch CChild.Name
                                {
                                    case "FieldOfView":
                                        let Ang = XMLNode.GetAttributeNamed("Angle", InNode: CChild)!
                                        CameraFieldOfView = Double(Ang)!
                                    
                                    case "Positions":
                                        let Loc = XMLNode.GetAttributeNamed("Location", InNode: CChild)!
                                        CameraPosition = SCNVector3.Parse(Loc)!
                                        let Ori = XMLNode.GetAttributeNamed("Orientation", InNode: CChild)!
                                        CameraOrientation = SCNVector4.Parse(Ori)!
                                    
                                    case "Projection":
                                        let IsOrtho = XMLNode.GetAttributeNamed("IsOrthographic", InNode: CChild)!
                                        IsOrthographic = Bool(IsOrtho)!
                                        let OrthoScale = XMLNode.GetAttributeNamed("OrthographicScale", InNode: CChild)!
                                        OrthographicScale = Double(OrthoScale)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Lights":
                            for LChild in Child.Children
                            {
                                switch LChild.Name
                                {
                                    case "DefaultLighting":
                                        let Use = XMLNode.GetAttributeNamed("Use", InNode: LChild)!
                                        UseDefaultLighting = Bool(Use)!
                                    
                                    case "GameLight":
                                        let LType = XMLNode.GetAttributeNamed("Type", InNode: LChild)!
                                        LightType = GameLights(rawValue: LType)!
                                        for GLChild in LChild.Children
                                        {
                                            switch GLChild.Name
                                            {
                                                case "Position":
                                                    let Loc = XMLNode.GetAttributeNamed("Location", InNode: GLChild)!
                                                    LightPosition = SCNVector3.Parse(Loc)!
                                                
                                                case "Light":
                                                    let LColor = XMLNode.GetAttributeNamed("Color", InNode: GLChild)!
                                                    LightColor = LColor
                                                    let LInten = XMLNode.GetAttributeNamed("Intensity", InNode: GLChild)!
                                                    LightIntensity = Double(LInten)!
                                                
                                                default:
                                                    break
                                            }
                                    }
                                    
                                    case "ControlLight":
                                        let LType = XMLNode.GetAttributeNamed("Type", InNode: LChild)!
                                        ControlLightType = GameLights(rawValue: LType)!
                                        for GLChild in LChild.Children
                                        {
                                            switch GLChild.Name
                                            {
                                                case "Position":
                                                    let Loc = XMLNode.GetAttributeNamed("Location", InNode: GLChild)!
                                                    ControlLightPosition = SCNVector3.Parse(Loc)!
                                                
                                                case "Light":
                                                    let LColor = XMLNode.GetAttributeNamed("Color", InNode: GLChild)!
                                                    ControlLightColor = LColor
                                                    let LInten = XMLNode.GetAttributeNamed("Intensity", InNode: GLChild)!
                                                    ControlLightIntensity = Double(LInten)!
                                                
                                                default:
                                                    break
                                            }
                                    }
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Background":
                            let BGType = XMLNode.GetAttributeNamed("Type", InNode: Child)!
                            BackgroundType = BackgroundTypes3D(rawValue: BGType)!
                            for BChild in Child.Children
                            {
                                switch BChild.Name
                                {
                                    case "Color":
                                        let BGColor = XMLNode.GetAttributeNamed("Color", InNode: BChild)!
                                        BackgroundSolidColor = BGColor
                                        let BGColorCycle = XMLNode.GetAttributeNamed("CycleDuration", InNode: BChild)!
                                        BackgroundSolidColorCycleTime = Double(BGColorCycle)!
                                    
                                    case "Gradient":
                                        let BGGrad = XMLNode.GetAttributeNamed("Definition", InNode: BChild)!
                                        BackgroundGradientColor = BGGrad
                                        let BGGradCycle = XMLNode.GetAttributeNamed("CycleDuration", InNode: BChild)!
                                        BackgroundGradientCycleTime = Double(BGGradCycle)!
                                    
                                    case "Image":
                                        let ImgFile = XMLNode.GetAttributeNamed("FileName", InNode: BChild)!
                                        BackgroundImageName = ImgFile
                                        let FromRoll = XMLNode.GetAttributeNamed("FromCameraRoll", InNode: BChild)!
                                        BackgroundImageFromCameraRoll = Bool(FromRoll)!
                                    
                                    case "LiveView":
                                        let WhichCamera = XMLNode.GetAttributeNamed("Camera", InNode: BChild)!
                                        BackgroundLiveImageCamera = CameraLocations(rawValue: WhichCamera)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Bucket":
                            for BChild in Child.Children
                            {
                                switch BChild.Name
                                {
                                    case "Material":
                                        let Spec = XMLNode.GetAttributeNamed("Specular", InNode: BChild)!
                                        BucketSpecularColor = Spec
                                        let Difs = XMLNode.GetAttributeNamed("Diffuse", InNode: BChild)!
                                        BucketDiffuseColor = Difs
                                    
                                    case "Grid":
                                        let SGrid = XMLNode.GetAttributeNamed("Show", InNode: BChild)!
                                        ShowBucketGrid = Bool(SGrid)!
                                        let GColor = XMLNode.GetAttributeNamed("Color", InNode: BChild)!
                                        BucketGridColor = GColor
                                        let GFade = XMLNode.GetAttributeNamed("Fade", InNode: BChild)!
                                        FadeBucketGrid = Bool(GFade)!
                                    
                                    case "Outline":
                                        let SGrid = XMLNode.GetAttributeNamed("Show", InNode: BChild)!
                                        ShowBucketGridOutline = Bool(SGrid)!
                                        let GColor = XMLNode.GetAttributeNamed("Color", InNode: BChild)!
                                        BucketGridOutlineColor = GColor
                                        let GFade = XMLNode.GetAttributeNamed("Fade", InNode: BChild)!
                                        FadeBucketOutline = Bool(GFade)!
                                    
                                    case "Rotation":
                                        let EnableR = XMLNode.GetAttributeNamed("Enable", InNode: BChild)!
                                        RotateBucket = Bool(EnableR)!
                                        let RotateD = XMLNode.GetAttributeNamed("Direction", InNode: BChild)!
                                        RotatingBucketDirection = BucketRotationTypes(rawValue: RotateD)!
                                        let RotateDur = XMLNode.GetAttributeNamed("Duration", InNode: BChild)!
                                        RotationDuration = Double(RotateDur)!
                                    
                                    case "Destruction":
                                        let Mth = XMLNode.GetAttributeNamed("Method", InNode: BChild)!
                                        DestructionMethod = DestructionMethods(rawValue: Mth)!
                                        let DestDur = XMLNode.GetAttributeNamed("Duration", InNode: BChild)!
                                        DestructionDuration = Double(DestDur)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Buttons":
                            for BChild in Child.Children
                            {
                                switch BChild.Name
                                {
                                    case "AllButtons":
                                        let HideAll = XMLNode.GetAttributeNamed("Hide", InNode: BChild)!
                                        HideAllButtons = Bool(HideAll)!
                                    
                                    case "UpButton":
                                        let ShowUp = XMLNode.GetAttributeNamed("Show", InNode: BChild)!
                                        ShowUpButton = Bool(ShowUp)!
                                    
                                    case "FlyAwayButton":
                                        let ShowFly = XMLNode.GetAttributeNamed("Show", InNode: BChild)!
                                        ShowFlyAwayButton = Bool(ShowFly)!
                                    
                                    case "DropDownButton":
                                        let ShowDrop = XMLNode.GetAttributeNamed("Show", InNode: BChild)!
                                        ShowDropDownButton = Bool(ShowDrop)!
                                    
                                    case "FreezeButton":
                                        let ShowFreeze = XMLNode.GetAttributeNamed("Show", InNode: BChild)!
                                        ShowFreezeButton = Bool(ShowFreeze)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "TextOverlay":
                            for TChild in Child.Children
                            {
                                switch TChild.Name
                                {
                                    case "NextPiece":
                                        let ShowNext = XMLNode.GetAttributeNamed("Show", InNode: TChild)!
                                        let RotateNext = XMLNode.GetAttributeNamed("Rotate", InNode: TChild)!
                                        ShowNextPiece = Bool(ShowNext)!
                                        RotateNextPiece = Bool(RotateNext)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "AI":
                            for AChild in Child.Children
                            {
                                switch AChild.Name
                                {
                                    case "Controls":
                                        let ShowAI = XMLNode.GetAttributeNamed("ShowAIActions", InNode: AChild)!
                                        ShowAIActionsOnControls = Bool(ShowAI)!
                                    
                                    case "SneekPeek":
                                        let PeekCount = XMLNode.GetAttributeNamed("Count", InNode: AChild)!
                                        AISneakPeakCount = Int(PeekCount)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Timing":
                            for TChild in Child.Children
                            {
                                switch TChild.Name
                                {
                                    case "AfterGameWaitDuration":
                                        let AfterGame = XMLNode.GetAttributeNamed("Seconds", InNode: TChild)!
                                        AfterGameWaitDuration = Double(AfterGame)!
                                    
                                    case "AutoStartInterval":
                                        let AutoStart = XMLNode.GetAttributeNamed("Seconds", InNode: TChild)!
                                        AutoStartDuration = Double(AutoStart)!
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Debug":
                            let DbgEn = XMLNode.GetAttributeNamed("Enable", InNode: Child)!
                            EnableDebug = Bool(DbgEn)!
                            for DChild in Child.Children
                            {
                                switch DChild.Name
                                {
                                    case "Camera":
                                        let UseCtrl = XMLNode.GetAttributeNamed("UserCanControl", InNode: DChild)!
                                        CanControlCamera = Bool(UseCtrl)!
                                    
                                    case "Statistics":
                                        let ShowStat = XMLNode.GetAttributeNamed("ShowStatistics", InNode: DChild)!
                                        ShowStatistics = Bool(ShowStat)!
                                    
                                    case "GridLines":
                                        for GridChild in DChild.Children
                                        {
                                            switch GridChild.Name
                                            {
                                                case "BackgroundGrid":
                                                    let ShowBGGrid = XMLNode.GetAttributeNamed("Show", InNode: GridChild)!
                                                    ShowBackgroundGrid = Bool(ShowBGGrid)!
                                                    let BGGridClr = XMLNode.GetAttributeNamed("Color", InNode: GridChild)!
                                                    BackgroundGridColor = BGGridClr
                                                    let BGGridWidth = XMLNode.GetAttributeNamed("Width", InNode: GridChild)!
                                                    BackgroundGridWidth = Double(BGGridWidth)!
                                                
                                                case "CenterLines":
                                                    let ShowCtrLines = XMLNode.GetAttributeNamed("Show", InNode: GridChild)!
                                                    ShowCenterLines = Bool(ShowCtrLines)!
                                                    let CtrLineColor = XMLNode.GetAttributeNamed("Color", InNode: GridChild)!
                                                    CenterLineColor = CtrLineColor
                                                    let CtrLineWidth = XMLNode.GetAttributeNamed("Width", InNode: GridChild)!
                                                    CenterLineWidth = Double(CtrLineWidth)!
                                                
                                                default:
                                                    break
                                            }
                                    }
                                    
                                    default:
                                        break
                                }
                        }
                        
                        case "Blocks":
                            BlockList.removeAll()
                            for BlockChild in Child.Children
                            {
                                if BlockChild.Name == "Block"
                                {
                                    let BlockID = XMLNode.GetAttributeNamed("ID", InNode: BlockChild)!
                                    BlockList.append(UUID(uuidString: BlockID)!)
                                }
                        }
                        default:
                            break
                    }
            }
            
            default:
                break
        }
    }
    
    // MARK: CustomStringConvertible functions
    
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
    
    public func ToString(AppendTerminalReturn: Bool = true, ResetDirtyFlag: Bool = true) -> String
    {
        if ResetDirtyFlag
        {
            _Dirty = false
        }
        
        var Working = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n"
        Working.append("<Theme ID=" + Quoted(ID.uuidString) +
            " Name=" + Quoted(ThemeName) +
            " UserTheme=" + Quoted("\(IsUserTheme)") + ">\n")
        
        Working.append(Spaces(4) + "<Runtime MinimumVersion=" + Quoted("\(MinimumVersion)") +
            " MinimumBuild=" + Quoted("\(MinimumBuild)") + "/>\n")
        
        Working.append(Spaces(4) + "<Dates Created=" + Quoted(CreateDate) +
            " Edited=" + Quoted(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .long)) + "/>\n")
        
        Working.append(Spaces(4) + "<Quality>\n")
        Working.append(Spaces(8) + "<Antialiasing Mode=" + Quoted(AntialiasingMode.rawValue) + "/>\n")
        Working.append(Spaces(4) + "</Quality>\n")
        
        Working.append(Spaces(4) + "<Lights>\n")
        Working.append(Spaces(8) + "<DefaultLighting Use=" + Quoted("\(UseDefaultLighting)") + "/>\n")
        Working.append(Spaces(8) + "<GameLight Type=" + Quoted(LightType.rawValue) + ">\n")
        Working.append(Spaces(12) + "<Positions Location=" +
            Quoted("\(LightPosition.x),\(LightPosition.y),\(LightPosition.z)") + "/>\n")
        Working.append(Spaces(12) + "<Light Color=" + Quoted(LightColor) +
            " Intensity=" + Quoted("\(LightIntensity)") + "/>\n")
        Working.append(Spaces(8) + "</GameLight>\n")
        Working.append(Spaces(8) + "<ControlLight Type=" + Quoted(ControlLightType.rawValue) + ">\n")
        Working.append(Spaces(12) + "<Positions Location=" +
            Quoted("\(ControlLightPosition.x),\(ControlLightPosition.y),\(ControlLightPosition.z)") + "/>\n")
        Working.append(Spaces(12) + "<Light Color=" + Quoted(ControlLightColor) +
            " Intensity=" + Quoted("\(ControlLightIntensity)") + "/>\n")
        Working.append(Spaces(8) + "</ControlLight>\n")
        Working.append(Spaces(4) + "</Lights>\n")
        
        Working.append(Spaces(4) + "<Camera>\n")
        Working.append(Spaces(8) + "<FieldOfView Angle=" + Quoted("\(CameraFieldOfView)") + "/>\n")
        Working.append(Spaces(8) + "<Positions Location=" +
            Quoted("\(CameraPosition.x),\(CameraPosition.y),\(CameraPosition.z)") +
            " Orientation=" +
            Quoted("\(CameraOrientation.x),\(CameraOrientation.y),\(CameraOrientation.z),\(CameraOrientation.w)") + "/>\n")
        Working.append(Spaces(4) + "</Camera>\n")
        
        Working.append(Spaces(4) + "<Background Type=" + Quoted(BackgroundType.rawValue) + ">/n")
        Working.append(Spaces(8) + "<Color Color=" + Quoted(BackgroundSolidColor) +
            " CycleDuration=" + Quoted("\(BackgroundSolidColorCycleTime)") + "/>\n")
        Working.append(Spaces(8) + "<Gradient Definition=" + Quoted(BackgroundGradientColor) +
            " CycleDuration=" + Quoted("\(BackgroundGradientCycleTime)") + "/>\n")
        Working.append(Spaces(8) + "<Image FileName=" + Quoted(BackgroundImageName) +
            " FromCameraRoll=" + Quoted("\(BackgroundImageFromCameraRoll)") + "/>\n")
        Working.append(Spaces(8) + "<LiveView Camera=" + Quoted(BackgroundLiveImageCamera.rawValue) + "/>\n")
        Working.append(Spaces(4) + "</Background>\n")
        
        Working.append(Spaces(4) + "<Bucket>\n")
        Working.append(Spaces(8) + "<Material Specular=" + Quoted(BucketSpecularColor) + " Diffuse=" + Quoted(BucketDiffuseColor) + "/>\n")
        Working.append(Spaces(8) + "<Grid Show=" + Quoted("\(ShowBucketGrid)") + " Color=" + Quoted(BucketGridColor) +
            " Fade=" + Quoted("\(FadeBucketGrid)") + "/>\n")
        Working.append(Spaces(8) + "<Outline Show=" + Quoted("\(ShowBucketGridOutline)") + " Color=" + Quoted(BucketGridOutlineColor) +
            " Fade=" + Quoted("\(FadeBucketOutline)") + "/>\n")
        Working.append(Spaces(8) + "<Rotation Enable=" + Quoted("\(RotateBucket)") + " Direction=" + Quoted(RotatingBucketDirection.rawValue) +
            " Duration=" + Quoted("\(RotationDuration)") + "/>\n")
        Working.append(Spaces(8) + "<Destruction Method=" + Quoted(DestructionMethod.rawValue) +
            " Duration=" + Quoted("\(DestructionDuration)") + "/>\n")
        Working.append(Spaces(4) + "</Bucket>\n")
        
        Working.append(Spaces(4) + "<Buttons>\n")
        Working.append(Spaces(8) + "<AllButtons Hide=" + Quoted("\(HideAllButtons)") + "/>\n")
        Working.append(Spaces(8) + "<UpButton Show=" + Quoted("\(ShowUpButton)") + "/>\n")
        Working.append(Spaces(8) + "<FlyAwayButton Show=" + Quoted("\(ShowFlyAwayButton)") + "/>\n")
        Working.append(Spaces(8) + "<DropDownButton Show=" + Quoted("\(ShowDropDownButton)") + "/>\n")
        Working.append(Spaces(8) + "<FreezeButton Show=" + Quoted("\(ShowFreezeButton)") + "/>\n")
        Working.append(Spaces(4) + "</Buttons>\n")
        
        Working.append(Spaces(4) + "<TextOverlay>\n")
        Working.append(Spaces(8) + "<NextPiece Show=" + Quoted("\(ShowNextPiece)") +
            " Rotate=" + Quoted("\(RotateNextPiece)") + "/>\n")
        Working.append(Spaces(4) + "</TextOverlay>\n")
        
        Working.append(Spaces(4) + "<AI>\n")
        Working.append(Spaces(8) + "<Controls ShowAIActions=" + Quoted("\(ShowAIActionsOnControls)") + "/>\n")
        Working.append(Spaces(8) + "<SneakPeak Count=" + Quoted("\(AISneakPeakCount)") + "/>\n")
        Working.append(Spaces(4) + "</AI>\n")
        
        Working.append(Spaces(4) + "<Timing>\n")
        Working.append(Spaces(8) + "<AfterGameWaitDuration Seconds=" + Quoted("\(AfterGameWaitDuration)") + "/>\n")
        Working.append(Spaces(8) + "<AutoStartInterval Seconds=" + Quoted("\(AutoStartDuration)") + "/>\n")
        Working.append(Spaces(4) + "</Timing>\n")
        
        Working.append(Spaces(4) + "<Debug Enable=" + Quoted("\(EnableDebug)") + ">\n")
        Working.append(Spaces(8) + "<Camera UserCanControl=" + Quoted("\(CanControlCamera)") + "/>\n")
        Working.append(Spaces(8) + "<Statistics ShowStatistics=" + Quoted("\(ShowStatistics)") + "/>\n")
        Working.append(Spaces(8) + "<GridLines>\n")
        Working.append(Spaces(12) + "<BackgroundGrid Show=" + Quoted("\(ShowBackgroundGrid)") +
            " Color=" + Quoted(BackgroundGridColor) + " Width=" + Quoted("\(BackgroundGridWidth)") + "/>\n")
        Working.append(Spaces(8) + "</GridLines>\n")
        Working.append(Spaces(12) + "<CenterLines Show=" + Quoted("\(ShowCenterLines)") +
            " Color=" + Quoted(CenterLineColor) + " Width=" + Quoted("\(CenterLineWidth)") + "/>\n")
        Working.append(Spaces(4) + "</Debug>\n")
        
        Working.append(Spaces(4) + "<Blocks>\n")
        for BlockID in BlockList
        {
            Working.append(Spaces(8) + "<Block ID=" + Quoted(BlockID.uuidString) + "/>\n")
        }
        Working.append(Spaces(4) + "</Blocks>\n")
        
        Working.append("</Theme>")
        if AppendTerminalReturn
        {
            Working.append("\n")
        }
        
        return Working
    }
    
    public var description: String
    {
        get
        {
            return ToString()
        }
    }
}

/// 3D game view background types.
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
    case ControlLightType = "ControlLightType"
    case ControlLightColor = "ControlLightColor"
    case ControlLightPosition = "ControlLightPosition"
    case ControlLightIntensity = "ControlLightIntensity"
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
    case ShowUpButton = "ShowUpButton"
    case ShowFlyAwayButton = "ShowFlyAwayButton"
    case ShowDropDownButton = "ShowDropDownButton"
    case ShowFreezeButton = "ShowFreezeButton"
    case HideAllButtons = "HideAllButtons"
    case RotateNextPiece = "RotateNextPiece"
    case EnableDebug = "EnableDebug"
    case BackgroundGridWidth = "BackgroundGridWidth"
    case BackgroundGridColor = "BackgroundGridColor"
    case ShowCenterLines = "ShowCenterLines"
    case CenterLineColor = "CenterLineColor"
    case CenterLineWidth = "CenterLineWidth"
    case BlockList = "BlockList"
}
