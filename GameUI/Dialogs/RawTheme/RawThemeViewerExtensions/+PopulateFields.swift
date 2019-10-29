//
//  +PopulateFields.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension RawThemeViewerCode
{
    /// Populates all fields in a very long, ugly series of steps.
    public func PopulateFields()
    {
        //Debug
        let DebugGroup = GroupData("Debug")
        DebugGroup.AddField(ID: UUID(), Title: "Show FPS in UI",
                            Description: "Show the game view's frames/second value in the main UI.", ControlTitle: "Show FPS",
                            Default: false, Starting: Settings.ShowFPSInUI(), FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetShowFPSInUI(NewValue: NewBool)
        })
        DebugGroup.AddField(ID: UUID(), Title: "Use TDebug",
                            Description: "Use the remote logger TDebug for displaying debug data.",
                            ControlTitle: "Use TDebug", Default: true, Starting: Settings.GetUseTDebug(),
                            FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetUseTDebug(Enabled: NewBool)
        })
        DebugGroup.AddField(ID: UUID(), Title: "Show rendering statistics",
                            Description: "Use SceneKit's built-in display for showing real-time rendering information.",
                            ControlTitle: "Show statistics", Default: false as Any,
                            Starting: self.UserTheme!.ShowStatistics as Any,
                            FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let DoShow = NewValue as! Bool
                self.UserTheme?.ShowStatistics = DoShow
        })
        DebugGroup.AddField(ID: UUID(), Title: "Camera control",
                            Description: "User can control camera position.",
                            ControlTitle: "User control", Default: false as Any,
                            Starting: self.UserTheme!.CanControlCamera as Any,
                            FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let CanControl = NewValue as! Bool
                self.UserTheme?.CanControlCamera = CanControl
        })
        DebugGroup.AddField(ID: UUID(), Title: "Use default camera",
                            Description: "Use the built-in default SceneKit camera.",
                            ControlTitle: "Default camera", Default: false as Any,
                            Starting: self.UserTheme!.UseDefaultCamera as Any,
                            FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let DefaultCamera = NewValue as! Bool
                self.UserTheme?.UseDefaultCamera = DefaultCamera
        })
        DebugGroup.AddField(ID: UUID(), Title: "Show background grid",
                            Description: "Shows a grid in the background.", ControlTitle: "Show grid",
                            Default: false as Any, Starting: self.UserTheme!.ShowBackgroundGrid as Any,
                            FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let ShowGrid = NewValue as! Bool
                self.UserTheme?.ShowBackgroundGrid = ShowGrid
        })
        DebugGroup.AddField(ID: UUID(), Title: "Heartbeat",
                            Description: "Shows a graphic that indicates the main loop is running.",
                            ControlTitle: "Show heartbeat",
                            Default: false as Any, Starting: self.UserTheme!.ShowHeartbeat as Any,
                            FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let ShowBeat = NewValue as! Bool
                self.UserTheme?.ShowHeartbeat = ShowBeat
        })
        DebugGroup.AddField(ID: UUID(), Title: "Heartbeat interval",
                            Description: "Amount of time (in seconds) between updating the heartbeat graphic.",
                            ControlTitle: "", Default: 1.0 as Any, Starting: self.UserTheme!.HeartbeatInterval as Any,
                            FieldType: .Double, List: nil, Handler:
            {
                NewValue in
                let NewDouble = NewValue as! Double
                self.UserTheme!.HeartbeatInterval = NewDouble
        })
        FieldTables.append(DebugGroup)
        
        let RotateDebugGroup = GroupData("Rotating Game Debug")
        RotateDebugGroup.AddField(ID: UUID(), Title: "Change center color",
                                  Description: "Change the color of the center block/bucket parts after each piece freezes.",
                                  ControlTitle: "Change colors", Default: false as Any,
                                  Starting: self.UserTheme!.ChangeColorAfterRotation as Any,
                                  FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let ChangeColors = NewValue as! Bool
                self.UserTheme?.ChangeColorAfterRotation = ChangeColors
        })
        FieldTables.append(RotateDebugGroup)
        
        //Settings
        let SettingsGroup = GroupData("Settings")
        SettingsGroup.AddField(ID: UUID(), Title: "Show version",
                               Description: "Shows a small version box on the screen when first starting.",
                               ControlTitle: "Show version on start up", Default: true as Any,
                               Starting: Settings.GetShowVersionBox() as Any, FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetShowVersionBox(NewValue: NewBool)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Confirm image save",
                               Description: "Shows an alert indicating an image was saved when saving screen shots.",
                               ControlTitle: "Confirm saved", Default: false as Any,
                               Starting: Settings.GetConfirmGameImageSave() as Any, FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetConfirmGameImageSave(NewValue: NewBool)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Auto-start wait duration",
                               Description: "How long to wait after start-up before attract mode starts on its own after initial start of game.",
                               ControlTitle: "Seconds", Default: 60.0 as Any,
                               Starting: self.UserTheme!.AutoStartDuration as Any, FieldType: .Double,
                               List: nil, Handler:
            {
                NewValue in
                let NewDouble = NewValue as! Double
                self.UserTheme!.AutoStartDuration = NewDouble
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Maximum identical pieces",
                               Description: "The maximum number of identical pieces that can be randomly generated in a row.",
                               ControlTitle: "Maximum same",
                               Default: 3, Starting: Settings.MaximumSamePieces(),
                               FieldType: .Int, List: nil, Handler:
            {
                NewValue in
                let NewInt = NewValue as! Int
                Settings.SetMaximumSamePieces(ToValue: NewInt)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Show alpha in color picker",
                               Description: "Enable setting alpha in the color picker.",
                               ControlTitle: "Enable alpha", Default: true as Any,
                               Starting: Settings.GetShowAlpha() as Any, FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetShowAlpha(NewValue: NewBool)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Show closest color",
                               Description: "Show the closest color in the color picker.",
                               ControlTitle: "Closest color", Default: true as Any,
                               Starting: Settings.GetShowClosestColor() as Any, FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetShowClosestColor(NewValue: NewBool)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Show camera controls",
                               Description: "Show or hide camera-related controls in the UI.",
                               ControlTitle: "Show controls", Default: true as Any,
                               Starting: Settings.GetShowCameraControls() as Any, FieldType: .Bool,
                               List: nil, Handler:
            {
                NewValue in
                Settings.SetShowCameraControls(NewValue: NewValue as! Bool)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Show motion controls",
                               Description: "show or hide the bottom motion controls. If hidden, you must use gestures to move pieces.",
                               ControlTitle: "Show motion controls", Default: true as Any,
                               Starting: Settings.GetShowMotionControls() as Any, FieldType: .Bool,
                               List: nil, Handler:
            {
                NewValue in
                Settings.SetShowMotionControls(NewValue: NewValue as! Bool)
        })
        FieldTables.append(SettingsGroup)
        
        //AI.
        let AIGroup = GroupData("AI")
        AIGroup.AddField(ID: UUID(), Title: "AI sneak peak count",
                         Description: "Number of pieces ahead the AI looks at to determine the best location for the current piece.",
                         ControlTitle: "Look-ahead count", Default: 1 as Any,
                         Starting: self.UserTheme!.AISneakPeakCount as Any, FieldType: .Int, List: nil, Handler:
            {
                NewValue in
                let NewInt = NewValue as! Int
                self.UserTheme?.AISneakPeakCount = NewInt
        })
        AIGroup.AddField(ID: UUID(), Title: "Show AI commands",
                         Description: "Show AI actions on the UI as if it were pressing the buttons.",
                         ControlTitle: "Show AI actions", Default: true as Any,
                         Starting: self.UserTheme!.ShowAIActionsOnControls as Any, FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                self.UserTheme?.ShowAIActionsOnControls = NewBool
        })
        AIGroup.AddField(ID: UUID(), Title: "Game over wait duration",
                         Description: "How long to wait between game over and starting a new game in attract mode.",
                         ControlTitle: "Seconds", Default: 15.0 as Any,
                         Starting: self.UserTheme!.AfterGameWaitDuration as Any, FieldType: .Double,
                         List: nil, Handler:
            {
                NewValue in
                let NewDouble = NewValue as! Double
                self.UserTheme!.AfterGameWaitDuration = NewDouble
        })
        FieldTables.append(AIGroup)
        
        //Playing.
        let PlayGroup = GroupData("Play")
        PlayGroup.AddField(ID: UUID(), Title: "Show next piece",
                           Description: "Show the next queued piece during game play.",
                           ControlTitle: "Show next piece", Default: true as Any,
                           Starting: self.UserTheme!.ShowNextPiece as Any,
                           FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let ShowNext = NewValue as! Bool
                self.UserTheme?.ShowNextPiece = ShowNext
        })
        PlayGroup.AddField(ID: UUID(), Title: "Block destruction method",
                           Description: "The method to use to clear a block from the bucket at the end of the game.",
                           ControlTitle: "", Default: "FadeAway" as Any,
                           Starting: "\(self.UserTheme!.DestructionMethod)" as Any, FieldType: .StringList,
                           List: GroupData.EnumListToStringList(DestructionMethods.allCases), Handler:
            {
                NewValue in
                let MethodString = NewValue as! String
                if let Method = DestructionMethods(rawValue: MethodString)
                {
                    self.UserTheme?.DestructionMethod = Method
                }
        })
        PlayGroup.AddField(ID: UUID(), Title: "Bucket destruction duration",
                           Description: "The amount of time in seconds to clear the bucket in a visual fashion. Set to 0.0 to disable destruction of blocks.",
                           ControlTitle: "Seconds", Default: 1.25 as Any,
                           Starting: self.UserTheme?.DestructionDuration as Any, FieldType: .Double,
                           List: nil, Handler:
            {
                NewValue in
                let NewDouble = NewValue as! Double
                self.UserTheme?.DestructionDuration = NewDouble
        })
        PlayGroup.AddField(ID: UUID(), Title: "Enable haptic feedback",
                           Description: "Use haptic feedback for those devices that support it.",
                           ControlTitle: "Haptic feedback", Default: false as Any,
                           Starting: self.UserTheme!.UseHapticFeedback as Any, FieldType: .Bool, List: nil,
                           Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                self.UserTheme!.UseHapticFeedback = NewBool
        })
        FieldTables.append(PlayGroup)
        
        //Languages.
        let LangGroup = GroupData("Languages")
        LangGroup.AddField(ID: UUID(), Title: "Color names",
                           Description: "If true, color names are shown in the original language where the color was described. If false, English is used for all color names.",
                           ControlTitle: "Colors in source language", Default: true as Any,
                           Starting: Settings.GetShowColorsInSourceLanguage() as Any, FieldType: .Bool,
                           List: nil, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetShowColorsInSourceLanguage(NewValue: NewBool)
        })
        LangGroup.AddField(ID: UUID(), Title: "Interface language",
                           Description: "Language to use for the user interface.", ControlTitle: "",
                           Default: "US English" as Any, Starting: "\(Settings.GetInterfaceLanguage())" as Any,
                           FieldType: .StringList, List: GroupData.EnumListToStringList(SupportedLanguages.allCases),
                           Handler:
            {
                NewValue in
                let RawString = NewValue as! String
                let NewLang = SupportedLanguages(rawValue: RawString)!
                Settings.SetInterfaceLanguage(NewValue: NewLang)
        })
        FieldTables.append(LangGroup)
        
        //Game view.
        let GameGroup = GroupData("Game View")
        GameGroup.AddField(ID: UUID(), Title: "Antialiasing mode",
                           Description: "The antialiasing mode for the game view. Anything higher than MultiSampling4X is ignored (not available on iOS).",
                           ControlTitle: "", Default: "MultiSampling4X" as Any,
                           Starting: "\(UserTheme!.AntialiasingMode)" as Any, FieldType: .StringList,
                           List: GroupData.EnumListToStringList(AntialiasingModes.allCases), Handler:
            {
                NewValue in
                let RawString = NewValue as! String
                let NewMode = AntialiasingModes(rawValue: RawString)!
                self.UserTheme!.AntialiasingMode = NewMode
        })
        GameGroup.AddField(ID: UUID(), Title: "Field of view",
                           Description: "Field of view for the camera.",
                           ControlTitle: "Field of view", Default: 92.5 as Any,
                           Starting: UserTheme!.CameraFieldOfView as Any, FieldType: .Double,
                           List: nil, Handler:
            {
                NewValue in
                let NewFOV = NewValue as! Double
                self.UserTheme?.CameraFieldOfView = NewFOV
        })
        GameGroup.AddField(ID: UUID(), Title: "Camera position",
                           Description: "The position of the camera in the game view scene.",
                           ControlTitle: "", Default: SCNVector3(-0.5, 2.0, 15.0) as Any,
                           Starting: self.UserTheme!.CameraPosition as Any,
                           FieldType: .Vector3, List: nil, Handler:
            {
                NewValue in
                let NewVector = NewValue as! SCNVector3
                self.UserTheme!.CameraPosition = NewVector
        })
        GameGroup.AddField(ID: UUID(), Title: "Camera orientation",
                           Description: "The orientation of the camera in the game view scene.",
                           ControlTitle: "", Default: SCNVector4(0.0, 0.0, 0.0, 0.0) as Any,
                           Starting: self.UserTheme!.CameraOrientation as Any,
                           FieldType: .Vector4, List: nil, Handler:
            {
                NewValue in
                let NewVector = NewValue as! SCNVector4
                self.UserTheme!.CameraOrientation = NewVector
        })
        GameGroup.AddField(ID: UUID(), Title: "Orthographic projection",
                           Description: "Sets the camera to orthographic projection. If off, perspective projection is used.",
                           ControlTitle: "Use orthographic", Default: false as Any, Starting: self.UserTheme?.IsOrthographic as Any,
                           FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let UseOrthographic = NewValue as! Bool
                self.UserTheme?.IsOrthographic = UseOrthographic
        })
        GameGroup.AddField(ID: UUID(), Title: "Orthographic scale",
                           Description: "The scale of the orthographic project (if enabled).",
                           ControlTitle: "", Default: 20.0 as Any, Starting: self.UserTheme?.OrthographicScale as Any,
                           FieldType: .Double, List: nil, Handler:
            {
                NewValue in
                let Scale = NewValue as! Double
                self.UserTheme?.OrthographicScale = Scale
        })
        GameGroup.AddField(ID: UUID(), Title: "Light color",
                           Description: "The color of the light.",
                           ControlTitle: "", Default: UIColor.white as Any,
                           Starting: ColorServer.ColorFrom(UserTheme!.LightColor) as Any,
                           FieldType: .Color, List: nil, Handler:
            {
                NewValue in
                let RawColor = NewValue as! UIColor
                let ColorName = ColorServer.MakeColorName(From: RawColor)
                self.UserTheme!.LightColor = ColorName!
        })
        GameGroup.AddField(ID: UUID(), Title: "Light type",
                           Description: "The type of light to use for the game view.",
                           ControlTitle: "", Default: "omni" as Any,
                           Starting: "\(UserTheme!.LightType)" as Any,
                           FieldType: .StringList, List: GroupData.EnumListToStringList(GameLights.allCases),
                           Handler:
            {
                NewValue in
                let RawValue = NewValue as! String
                self.UserTheme!.LightType = GameLights(rawValue: RawValue)!
//                self.UserTheme!.LightType = SCNLight.LightType(rawValue: RawValue)
        })
        GameGroup.AddField(ID: UUID(), Title: "Light position",
                           Description: "The position of the light in the game view scene.",
                           ControlTitle: "", Default: SCNVector3(-5.0, 15.0, 40.0) as Any,
                           Starting: UserTheme!.LightPosition as Any,
                           FieldType: .Vector3, List: nil, Handler:
            {
                NewValue in
                let NewVector = NewValue as! SCNVector3
                self.UserTheme!.LightPosition = NewVector
        })
        FieldTables.append(GameGroup)
        
        let BGGroup = GroupData("Game Background")
        BGGroup.AddField(ID: UUID(), Title: "Game background",
                         Description: "How the background of the game looks and acts.",
                         ControlTitle: "", Default: "Color" as Any,
                         Starting: "\(UserTheme!.BackgroundType)" as Any, FieldType: .StringList,
                         List: GroupData.EnumListToStringList(BackgroundTypes3D.allCases), Handler:
            {
                NewValue in
                let RawValue = NewValue as! String
                self.UserTheme!.BackgroundType = BackgroundTypes3D(rawValue: RawValue)!
        })
        BGGroup.AddField(ID: UUID(), Title: "Game background color",
                         Description: "Solid color for the game background.",
                         ControlTitle: "", Default: UIColor.red as Any,
                         Starting: ColorServer.ColorFrom(UserTheme!.BackgroundSolidColor) as Any, FieldType: .Color,
                         List: nil, Handler:
            {
                NewValue in
                let NewColor = NewValue as! UIColor
                let NewColorName = ColorServer.MakeColorName(From: NewColor)
                self.UserTheme!.BackgroundSolidColor = NewColorName!
        }
        )
        BGGroup.AddField(ID: UUID(), Title: "Solid color cycle time",
                         Description: "Time (in seconds) for the solid color background to cycle through 360° of hue. Set to 0 to disable.",
                         ControlTitle: "Seconds", Default: 0.0 as Any,
                         Starting: UserTheme!.BackgroundSolidColorCycleTime as Any, FieldType: .Double,
                         List: nil, Handler:
            {
                NewValue in
                let Cycle = NewValue as! Double
                self.UserTheme!.BackgroundSolidColorCycleTime = Cycle
        })
        BGGroup.AddField(ID: UUID(), Title: "Gradient background",
                         Description: "The gradient to use as the game view background.", ControlTitle: "",
                         Default: "(Red)@(0.0),(Black)@(1.0)" as Any,
                         Starting: UserTheme!.BackgroundGradientColor as Any,
                         FieldType: .Gradient, List: nil, Handler:
            {
                NewValue in
                self.UserTheme!.BackgroundGradientColor = NewValue as! String
        })
        BGGroup.AddField(ID: UUID(), Title: "Gradient cycle time",
                         Description: "Time (in seconds) for the colors in the gradient to cycle through 360° of hue. Set to 0 to disable.",
                         ControlTitle: "", Default: 0.0 as Any,
                         Starting: UserTheme!.BackgroundGradientCycleTime as Any, FieldType: .Double,
                         List: nil, Handler:
            {
                NewValue in
                self.UserTheme!.BackgroundGradientCycleTime = NewValue as! Double
        })
        BGGroup.AddField(ID: UUID(), Title: "Background image",
                         Description: "Image to use for the game view background.",
                         ControlTitle: "", Default: "IMG_0004.JPG",
                         Starting: UserTheme!.BackgroundImageName, FieldType: .Image,
                         List: nil, Handler:
            {
                NewValue in
                self.UserTheme!.BackgroundImageName = NewValue as! String
        })
        let DisableLiveView = UserDefaults.standard.bool(forKey: "RunningOnSimulator")
        var WarningTriggers: [String: String] = [String: String]()
        if UserDefaults.standard.bool(forKey: "RunningOnSimulator")
        {
            WarningTriggers["Rear"] = "Rear camera not available on simulator."
            WarningTriggers["Front"] = "Front camera not available on simulator."
        }
        BGGroup.AddField(ID: UUID(), Title: "Live background camera",
                         Description: "Camera to use for live view backgrounds. Valid only for those devices with cameras (eg, not simulators).",
                         ControlTitle: "", Default: "Rear", Starting: "Rear", FieldType: .StringList,
                         List: GroupData.EnumListToStringList(CameraLocations.allCases), Handler: nil,
                         DisableControl: DisableLiveView, Warnings: WarningTriggers)
        FieldTables.append(BGGroup)
        
        //Bucket attributes.
        let BucketGroup = GroupData("Bucket")
        BucketGroup.AddField(ID: UUID(), Title: "Show bucket grid",
                             Description: "Shows a grid in the bucket sized to fit piece blocks.",
                             ControlTitle: "Show grid", Default: true as Any,
                             Starting: UserTheme!.ShowBucketGrid as Any,
                             FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                self.UserTheme!.ShowBucketGrid = NewValue as! Bool
        })
        BucketGroup.AddField(ID: UUID(), Title: "Bucket grid color",
                             Description: "Color of the bucket grid (ignored if not showing)", ControlTitle: "",
                             Default: UIColor.gray as Any,
                             Starting: ColorServer.ColorFrom(UserTheme!.BucketGridColor) as Any,
                             FieldType: .Color, List: nil, Handler:
            {
                NewValue in
                let NewColor = NewValue as! UIColor
                let NewName = ColorServer.MakeColorName(From: NewColor)
                self.UserTheme!.BucketGridColor = NewName!
        })
        BucketGroup.AddField(ID: UUID(), Title: "Show bucket grid outline",
                             Description: "Draw an outline around the bucket grid.", ControlTitle: "Grid outline",
                             Default: true as Any, Starting: UserTheme!.ShowBucketGridOutline as Any,
                             FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                self.UserTheme!.ShowBucketGridOutline = NewValue as! Bool
        })
        BucketGroup.AddField(ID: UUID(), Title: "Outline color",
                             Description: "The color of the bucket grid outline (ignored if not showing)",
                             ControlTitle: "", Default: UIColor.red as Any,
                             Starting: ColorServer.ColorFrom(UserTheme!.BucketGridOutlineColor) as Any,
                             FieldType: .Color, List: nil, Handler:
            {
                NewValue in
                let NewColor = NewValue as! UIColor
                let NewName = ColorServer.MakeColorName(From: NewColor)
                self.UserTheme!.BucketGridOutlineColor = NewName!
        })
        BucketGroup.AddField(ID: UUID(), Title: "Rotate bucket between pieces",
                             Description: "Rotate the bucket (for certain games) between each piece.",
                             ControlTitle: "Rotate bucket", Default: true as Any,
                             Starting: UserTheme!.RotateBucket as Any, FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                self.UserTheme!.RotateBucket = NewValue as! Bool
        })
        BucketGroup.AddField(ID: UUID(), Title: "Rotation duration",
                             Description: "Duration of the rotation of the bucket for certain games.",
                             ControlTitle: "Seconds", Default: 0.25 as Any,
                             Starting: UserTheme!.RotationDuration as Any, FieldType: .Double, List: nil, Handler:
            {
                NewValue in
                self.UserTheme!.RotationDuration = NewValue as! Double
        })
        BucketGroup.AddField(ID: UUID(), Title: "Bucket rotation direction",
                             Description: "The rotation of the bucket when rotating (and for those games that support rotation).",
                             ControlTitle: "", Default: "Right",
                             Starting: "\(UserTheme!.RotatingBucketDirection)", FieldType: .StringList,
                             List: GroupData.EnumListToStringList(BucketRotationTypes.allCases), Handler:
            {
                NewValue in
                let RawValue = NewValue as! String
                self.UserTheme!.RotatingBucketDirection = BucketRotationTypes(rawValue: RawValue)!
        })
        BucketGroup.AddField(ID: UUID(), Title: "Rotate bucket grid",
                             Description: "Rotate the bucket's grid and outline along with the bucket when appropriate.",
                             ControlTitle: "Rotate grid", Default: true as Any,
                             Starting: UserTheme!.RotateBucketGrid as Any, FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                self.UserTheme!.RotateBucketGrid = NewValue as! Bool
        })
        BucketGroup.AddField(ID: UUID(), Title: "Fade bucket grid",
                             Description: "Fades the bucket grid soon after the game starts.", ControlTitle: "Fade bucket grid",
                             Default: false as Any, Starting: UserTheme!.FadeBucketGrid as Any,
                             FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                self.UserTheme!.FadeBucketGrid = NewValue as! Bool
        })
        BucketGroup.AddField(ID: UUID(), Title: "Fade bucket outline",
                             Description: "Fades the bucket grid ouline soon after the game starts.", ControlTitle: "Fade grid outline",
                             Default: false as Any, Starting: UserTheme!.FadeBucketOutline as Any,
                             FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                self.UserTheme!.FadeBucketOutline = NewValue as! Bool
        })
        FieldTables.append(BucketGroup)
        
        let ResetGroup = GroupData("Reset")
        let ResetField = GroupField(ID: UUID(), Title: "Reset settings",
                                    Description: "Reset all settings in the program. You will lose your changes.",
                                    ControlTitle: "Reset Settings",
                                    Starting: false as Any, Default: false as Any, FieldType: .Action,
                                    List: nil, Handler:
            {
                _ in
                self.HandleResetButtonPressed()
        }, DisableControl: false)
        ResetField.ActionBorderColor = UIColor.red
        ResetField.ActionButtonBackgroundColor = ColorServer.ColorFrom(ColorNames.CottonCandy)
        ResetField.ActionButtonTextColor = ColorServer.ColorFrom(ColorNames.Maroon)
        ResetGroup.AddField(ResetField)
        let ResetUserTheme = GroupField(ID: UUID(), Title: "Reset themes",
                                        Description: "Reset theme file in User Defaults. You will lose your changes.",
                                        ControlTitle: "Reset Theme",
                                        Starting: false as Any, Default: false as Any, FieldType: .Action,
                                        List: nil, Handler:
            {
                _ in
                UserDefaults.standard.set(ThemeManager3.RawTheme(), forKey: "UserTheme")
        }, DisableControl: false)
        ResetUserTheme.ActionBorderColor = UIColor.red
        ResetUserTheme.ActionButtonBackgroundColor = ColorServer.ColorFrom(ColorNames.CottonCandy)
        ResetUserTheme.ActionButtonTextColor = ColorServer.ColorFrom(ColorNames.Maroon)
        ResetGroup.AddField(ResetUserTheme)
        
        FieldTables.append(ResetGroup)
    }
}
