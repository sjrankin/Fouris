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

/// Contains a theme to use for game-level visual attributes and the like. Block-level visual attributes are contained in
/// `BlockVisualManager`. Piece descriptions are in `PieceManager`.
/// - Note:
///  - Source for the theme deserializer is in `+ThemeDescriptorParser.swift`.
///  - Source for the theme writer/serializer is in `+ThemeDescriptorWriter.swift`.
class ThemeDescriptor2: CustomStringConvertible, XMLDeserializeProtocol
{
    /// Delegate to call when a theme variable changes.
    weak var ChangeDelegate: ThemeChangeProtocol2? = nil
    
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
    
    /// Holds the dirty flag.
    public var _Dirty: Bool = false
    /// Get the dirty flag.
    public var Dirty: Bool
    {
        get
        {
            return _Dirty
        }
    }
    
    // MARK: Bucket properties.
    
    /// Holds the show bucket grid flag.
    public var _ShowBucketGrid: Bool = false
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
    public var _ShowGrid: Bool = false
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
    public var _ShowBucketGridOutline: Bool = true
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
    public var _BucketGridColor: String = "Gray"
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
    public var _BucketGridOutlineColor: String = "Red"
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
    public var _BucketSpecularColor: String = "White"
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
    public var _BucketDiffuseColor: String = "Black"
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
    public var _IsOrthographic: Bool = false
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
    public var _OrthographicScale: Double = 20.0
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
    public var _CameraFieldOfView: Double = 90.0
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
    public var _UseDefaultCamera: Bool = false
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
    public var _CameraPosition: SCNVector3 = SCNVector3(x: 1.0, y: 1.0, z: 1.0)
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
    public var _CameraOrientation: SCNVector4 = SCNVector4(x: 0.2, y: 0.2, z: 0.2, w: -0.5)
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
    public var _ShowStatistics: Bool = false
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
    public var _ShowBackgroundGrid: Bool = false
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
    public var _CanControlCamera: Bool = false
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
    
    /// Holds the show heartbeat flag.
    public var _ShowHeartbeat: Bool = false
    /// Get or set the show heartbeat indicator flag.
    public var ShowHeartbeat: Bool
    {
        get
        {
            return _ShowHeartbeat
        }
        set
        {
            _ShowHeartbeat = newValue
            _Dirty = true
            ChangeNotice(Field: .ShowHeartbeat)
        }
    }
    
    /// Holds the heartbeat indicator update interval.
    public var _HeartbeatInterval: Double = 1.0
    /// Get or set the interval (in seconds) of how often to update the heartbeat indicator.
    public var HeartbeatInterval: Double
    {
        get
        {
            return _HeartbeatInterval
        }
        set
        {
            _HeartbeatInterval = newValue
            _Dirty = true
            ChangeNotice(Field: .HeartbeatInterval)
        }
    }
    
    // MARK: Light properties.
    
    /// Holds the color of the light.
    public var _LightColor: String = "White"
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
    public var _LightType: GameLights = .omni
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
    public var _LightPosition: SCNVector3 = SCNVector3(0,0,0)
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
    public var _LightIntensity: Double = 1000.0
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
    public var _UseDefaultLighting: Bool = true
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
    public var _ControlLightColor: String = "White"
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
    public var _ControlLightType: GameLights = .omni
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
    public var _ControlLightPosition: SCNVector3 = SCNVector3(0,0,0)
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
    public var _ControlLightIntensity: Double = 1000.0
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
    public var _AntialiasingMode: AntialiasingModes = .None
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
    public var _BackgroundType: BackgroundTypes3D = .Color
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
    public var _BackgroundSolidColor: String = "Maroon"
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
    public var _BackgroundSolidColorCycleTime: Double = 0.0
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
    public var _BackgroundGradientColor: String = "(Red)@(0.0),(Blue)@(1.0)"
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
    public var _BackgroundGradientCycleTime: Double = 0.0
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
    public var _BackgroundImageName: String = ""
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
    public var _BackgroundImageFromCameraRoll: Bool = true
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
    public var _BackgroundLiveImageCamera: CameraLocations = .Rear
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
    public var _UseHapticFeedback: Bool = false
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
    public var _AfterGameWaitDuration: Double = 15.0
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
    public var _AutoStartDuration: Double = 60.0
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
    public var _DestructionMethod: DestructionMethods = .Shrink
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
    
    /// Holds the show off flag.
    public var _ShowOffAfterGameOver: Bool = true
    /// Get or set the show off after game over flag.
    public var ShowOffAfterGameOver: Bool
    {
        get
        {
            return _ShowOffAfterGameOver
        }
        set
        {
            _ShowOffAfterGameOver = newValue
            _Dirty = true
            ChangeNotice(Field: .ShowOffAfterGameOver)
        }
    }
    
    /// Holds the length of time to clear the bucket of blocks.
    public var _DestructionDuration: Double = 1.25
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
    public var _ShowAIActionsOnControls: Bool = true
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
    
    /// Holds the start with AI flag.
    public var _StartWithAI: Bool = false
    /// Get or set the flag that indicates the game starts in attract mode.
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
    public var _AISneakPeakCount: Int = 1
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
    
    /// Holds the bucket shape.
    public var _BucketShape: BucketShapes = .Classic
    /// Get or set the bucket shape for the game.
    public var BucketShape: BucketShapes
    {
        get
        {
            return _BucketShape
        }
        set
        {
            _BucketShape = newValue
            _Dirty = true
            ChangeNotice(Field: .BucketShape)
        }
    }
    
    /// Holds the bucket rotation type.
    public var _RotatingBucketDirection: BucketRotationTypes = .Right
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
    public var _RotateBucket: Bool = true
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
    public var _RotationDuration: Double = 0.3
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
    public var _RotateBucketGrid: Bool = false
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
    public var _FadeBucketGrid: Bool = false
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
    public var _FadeBucketOutline: Bool = false
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
    public var _ShowNextPiece: Bool = true
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
    
    /// Holds the rotate next piece display flag.
    public var _RotateNextPiece: Bool = true
    /// Get or set the flag that indicates the next piece should rotate for visual interest.
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
    
    /// Holds the hide all motion buttons flag.
    public var _HideAllButtons: Bool = false
    /// Get or set the hide all motion buttons flag.
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
    public var _ShowUpButton: Bool = true
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
    public var _ShowFlyAwayButton: Bool = true
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
    public var _ShowDropDownButton: Bool = true
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
    public var _ShowFreezeButton: Bool = true
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
    
    /// Holds the master debug flag.
    public var _EnableDebug: Bool = false
    /// Get or set the master debug flag.
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
    
    /// Holds the width of the background grid.
    public var _BackgroundGridWidth: Double = 2.0
    /// Get or set the width of the background grid.
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
    
    /// Holds the background grid color.
    public var _BackgroundGridColor: String = "ReallyDarkGray"
    /// Get or set the background grid color.
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
    
    /// Holds the center line flag.
    public var _ShowCenterLines: Bool = false
    /// Get or set the show center lines flag.
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
    
    /// Holds the center line color.
    public var _CenterLineColor: String = "Yellow"
    /// Get or set the center line color.
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
    
    /// Holds the center line width.
    public var _CenterLineWidth: Double = 2.0
    /// Get or set the center line width.
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
    
    // MARK: Piece list.
    
    /// Holds the list of pieces.
    public var _PieceList: [UUID] = [UUID]()
    /// Get or set the list of pieces (by ID) contained in the theme.
    public var PieceList: [UUID]
    {
        get
        {
            return _PieceList
        }
        set
        {
            _PieceList = newValue
            _Dirty = true
            ChangeNotice(Field: .PieceList)
        }
    }
    
    /// Holds the change barrier color after rotation flag.
    public var _ChangeColorAfterRotation: Bool = false
    /// Get or set the change barrier color after rotating the board flag.
    public var ChangeColorAfterRotation: Bool
    {
        get
        {
            return _ChangeColorAfterRotation
        }
        set
        {
            _ChangeColorAfterRotation = newValue
            _Dirty = true
            ChangeNotice(Field: .ChangeColorAfterRotation)
        }
    }
    
    // MARK: Board properties.
    
    /// Holds the show board method.
    public var _ShowBoardMethod: ShowBoardMethods = .Appear
    /// Get or set the method used to visually show a board when it appears.
    public var ShowBoardMethod: ShowBoardMethods
    {
        get
        {
            return _ShowBoardMethod
        }
        set
        {
            _ShowBoardMethod = newValue
            _Dirty = true
            ChangeNotice(Field: .ShowBoardMethod)
        }
    }
    
    /// Holds the duration of the visual effect to show the board.
    public var _ShowBoardDuration: Double = 0.25
    /// Get or set the duration of the visual effect to show the board. Units are seconds.
    public var ShowBoardDuration: Double
    {
        get
        {
            return _ShowBoardDuration
        }
        set
        {
            _ShowBoardDuration = newValue
            _Dirty = true
            ChangeNotice(Field: .ShowBoardDuration)
        }
    }
    
    /// Holds the method to hide th board.
    public var _HideBoardMethod: HideBoardMethods = .Disappear
    /// Get or set the method to hide the board.
    public var HideBoardMethod: HideBoardMethods
    {
        get
        {
            return _HideBoardMethod
        }
        set
        {
            _HideBoardMethod = newValue
            _Dirty = true
            ChangeNotice(Field: .HideBoardMethod)
        }
    }
    
    /// Holds the duration of the visual effect to hide the board.
    public var _HideBoardDuration: Double = 0.25
    /// Get or set the duration of the visual effect to hide the board. Units are seconds.
    public var HideBoardDuration: Double
    {
        get
        {
            return _HideBoardDuration
        }
        set
        {
            _HideBoardDuration = newValue
            _Dirty = true
            ChangeNotice(Field: .HideBoardDuration)
        }
    }
    
    // MARK: General descriptor properties.
    
    /// Holds the minimum version number this theme is valid for.
    public var _MinimumVersion: Double = 1.0
    /// Get or set the minimum version number of Fouris that is needed to support this theme.
    public var MinimumVersion: Double
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
    public var _MinimumBuild: Int = 0
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
    public var _ThemeName: String = ""
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
    public var _Created: String = ""
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
    public var _Edited: String = ""
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
    public var _ID: UUID = UUID.Empty
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
    public var _Title: String = "Generic Theme"
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
    public var _FileName: String = ""
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
    public var _SaveAfterEdit: Bool = true
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
    public var _IsUserTheme: Bool = false
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
    
    // MARK: CustomStringConvertible functions
    
    /// Returns a string with the contents of the class in XML format.
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

/// Types of lights. Mirrors Apple's SDK but more restrictive.
/// - **Ambient**: Ambient light.
/// - **Directional**: Directional light.
/// - **Omni**: Omni light.
/// - **Spot**: Spot light.
enum LightTypes: String, CaseIterable
{
    case Ambient = "Ambient"
    case Directional = "Directional"
    case Omni = "Omni"
    case Spot = "Spot"
}

/// Locations of cameras on devices that have them.
/// - **Rear**: The rear camera (facing away from the screen).
/// - **Front**: The front camera (selfie camera).
enum CameraLocations: String, CaseIterable
{
    case Rear = "Rear"
    case Front = "Front"
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
    case SubGameType = "SubGameType"
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
    case PieceList = "PieceList"
    case ShowBoardMethod = "ShowBoardMethod"
    case ShowBoardDuration = "ShowBoardDuration"
    case HideBoardMethod = "HideBoardMethod"
    case HideBoardDuration = "HideBoardDuration"
    case ShowHeartbeat = "ShowHeartbeat"
    case HeartbeatInterval = "HeartbeatInterval"
    case ChangeColorAfterRotation = "ChangeColorAfterRotation"
    case BucketShape = "BucketShape"
    case ShowOffAfterGameOver = "ShowOffAfterGameOver"
}
