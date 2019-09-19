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

extension RawThemeViewerCode2
{
    func PopulateFields()
    {
        //Debug
        let DebugGroup = GroupData2("Debug")
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
                            ControlTitle: "Show statistics", Default: false as Any, Starting: false as Any,
                            FieldType: .Bool, List: nil, Handler: nil)
        DebugGroup.AddField(ID: UUID(), Title: "Camera control",
                            Description: "User can control camera position.",
                            ControlTitle: "User control", Default: false as Any, Starting: false as Any,
                            FieldType: .Bool, List: nil, Handler: nil)
        DebugGroup.AddField(ID: UUID(), Title: "Use default camera",
                            Description: "Use the built-in default SceneKit camera.",
                            ControlTitle: "Default camera", Default: false as Any, Starting: false as Any,
                            FieldType: .Bool, List: nil, Handler: nil)
        DebugGroup.AddField(ID: UUID(), Title: "Show background grid",
                            Description: "Shows a grid in the background.", ControlTitle: "Show grid",
                            Default: false as Any, Starting: false as Any,
                            FieldType: .Bool, List: nil, Handler: nil)
        FieldTables.append(DebugGroup)
        
        //Settings
        let SettingsGroup = GroupData2("Settings")
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
                               Starting: Settings.GetAutoStartDuration() as Any, FieldType: .Double, List: nil, Handler:
            {
                NewValue in
                let NewDouble = NewValue as! Double
                Settings.SetAutoStartDuration(ToNewValue: NewDouble)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Game over wait duration",
                               Description: "How long to wait between game over and starting a new game in attract mode.",
                               ControlTitle: "Seconds", Default: 15.0 as Any,
                               Starting: Settings.GetAfterGameWaitDuration() as Any, FieldType: .Double, List: nil, Handler:
            {
                NewValue in
                let NewDouble = NewValue as! Double
                Settings.SetAfterGameWaitDuration(NewValue: NewDouble)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Start with AI",
                               Description: "This setting appears to conflict with Auto-start wait duration. Will be remvoed.",
                               ControlTitle: "Start with AI", Default: false as Any,
                               Starting: Settings.GetStartWithAI() as Any, FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetStartWithAI(Enabled: NewBool)
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
        SettingsGroup.AddField(ID: UUID(), Title: "Enable vibrations",
                               Description: "Use vibrations for freeze events. Valid only for earlier devices.",
                               ControlTitle: "Use vibrations", Default: false as Any,
                               Starting: Settings.EnableVibrateFeedback() as Any, FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetVibrateFeedback(Enable: NewBool)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Enable haptic feedback",
                               Description: "Use haptic feedback for those devices that support it.",
                               ControlTitle: "Haptic feedback", Default: false as Any,
                               Starting: Settings.EnableHapticFeedback() as Any, FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetHapticFeedback(Enable: NewBool)
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
        FieldTables.append(SettingsGroup)
        
        //AI.
        let AIGroup = GroupData2("AI")
        AIGroup.AddField(ID: UUID(), Title: "AI sneak peak count",
                         Description: "Number of pieces ahead the AI looks at to determine the best location for the current piece.",
                         ControlTitle: "Look-ahead count", Default: 1 as Any,
                         Starting: Settings.GetAISneakPeakCount() as Any, FieldType: .Int, List: nil, Handler:
            {
                NewValue in
                let NewInt = NewValue as! Int
                Settings.SetAISneakPeakCount(To: NewInt)
        })
        AIGroup.AddField(ID: UUID(), Title: "Show AI commands",
                         Description: "Show AI actions on the UI as if it were pressing the buttons.",
                         ControlTitle: "Show AI actions", Default: true as Any,
                         Starting: Settings.ShowAIUICommands() as Any, FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetAIUICommands(Enable: NewBool)
        })
        FieldTables.append(AIGroup)
        
        //Playing.
        let PlayGroup = GroupData2("Play")
        PlayGroup.AddField(ID: UUID(), Title: "Show next piece",
                           Description: "Show the next queued piece during game play.",
                           ControlTitle: "Show next piece", Default: true as Any, Starting: true as Any,
                           FieldType: .Bool, List: nil, Handler: nil)
        PlayGroup.AddField(ID: UUID(), Title: "Block destruction method",
                           Description: "The method to use to clear a block from the bucket at the end of the game.",
                           ControlTitle: "", Default: "FadeAway" as Any, Starting: "FadeAway" as Any, FieldType: .StringList,
                           List: GroupData2.EnumListToStringList(DestructionMethods.allCases), Handler: nil)
        FieldTables.append(PlayGroup)
        
        //Game view.
        let GameGroup = GroupData2("Game View")
        GameGroup.AddField(ID: UUID(), Title: "Antialiasing mode",
                           Description: "The antialiasing mode for the game view. Anything higher than MultiSampling4X is ignored (not available on iOS).",
                           ControlTitle: "", Default: "MultiSampling4X" as Any, Starting: "MultiSampling4X" as Any, FieldType: .StringList,
                           List: GroupData2.EnumListToStringList(AntialiasingModes.allCases), Handler: nil)
        GameGroup.AddField(ID: UUID(), Title: "Field of view",
                           Description: "Field of view for the camera.",
                           ControlTitle: "Field of view", Default: 92.5 as Any, Starting: 92.5 as Any, FieldType: .Double,
                           List: nil, Handler: nil)
        GameGroup.AddField(ID: UUID(), Title: "Camera position",
                           Description: "The position of the camera in the game view scene.",
                           ControlTitle: "", Default: SCNVector3(-0.5, 2.0, 15.0) as Any, Starting: SCNVector3(-0.5, 2.0, 15.0) as Any,
                           FieldType: .Vector3, List: nil, Handler: nil)
        GameGroup.AddField(ID: UUID(), Title: "Camera orientation",
                           Description: "The orientation of the camera in the game view scene.",
                           ControlTitle: "", Default: SCNVector4(0.0, 0.0, 0.0, 0.0) as Any, Starting: SCNVector4(0.0, 0.0, 0.0, 0.0) as Any,
                           FieldType: .Vector4, List: nil, Handler: nil)
        GameGroup.AddField(ID: UUID(), Title: "Orthographic projection",
                           Description: "Sets the camera to orthographic projection. If off, perspective projection is used.",
                           ControlTitle: "Use orthographic", Default: false as Any, Starting: false as Any,
                           FieldType: .Bool, List: nil, Handler: nil)
        GameGroup.AddField(ID: UUID(), Title: "Light color",
                           Description: "The color of the light.",
                           ControlTitle: "", Default: UIColor.white as Any, Starting: UIColor.white as Any,
                           FieldType: .Color, List: nil, Handler: nil)
        GameGroup.AddField(ID: UUID(), Title: "Light type",
                           Description: "The type of light to use for the game view.",
                           ControlTitle: "", Default: "Omni" as Any, Starting: "Omni" as Any,
                           FieldType: .StringList, List: GroupData2.EnumListToStringList(LightTypes.allCases),
                           Handler: nil)
        GameGroup.AddField(ID: UUID(), Title: "Light position",
                           Description: "The position of the light in the game view scene.",
                           ControlTitle: "", Default: SCNVector3(-5.0, 15.0, 40.0) as Any, Starting: SCNVector3(-5.0, 15.0, 40.0) as Any,
                           FieldType: .Vector3, List: nil, Handler: nil)
        FieldTables.append(GameGroup)
        
        let BGGroup = GroupData2("Game Background")
        BGGroup.AddField(ID: UUID(), Title: "Game background",
                         Description: "How the background of the game looks and acts.",
                         ControlTitle: "", Default: "Color" as Any, Starting: "Color" as Any, FieldType: .StringList,
                         List: GroupData2.EnumListToStringList(BackgroundTypes3D.allCases), Handler: nil)
        BGGroup.AddField(ID: UUID(), Title: "Game background color",
                         Description: "Solid color for the game background.",
                         ControlTitle: "", Default: UIColor.red as Any, Starting: UIColor.red as Any, FieldType: .Color,
                         List: nil, Handler: nil)
        BGGroup.AddField(ID: UUID(), Title: "Solid color cycle time",
                         Description: "Time (in seconds) for the solid color background to cycle through 360° of hue. Set to 0 to disable.",
                         ControlTitle: "Seconds", Default: 0.0 as Any, Starting: 0.0 as Any, FieldType: .Double,
                         List: nil, Handler: nil)
        BGGroup.AddField(ID: UUID(), Title: "Gradient background",
                         Description: "The gradient to use as the game view background.", ControlTitle: "",
                         Default: "(Red)@(0.0),(Black)@(1.0)" as Any, Starting: "(Red)@(0.0),(Black)@(1.0)" as Any,
                         FieldType: .Gradient, List: nil, Handler: nil)
        BGGroup.AddField(ID: UUID(), Title: "Gradient cycle time",
                         Description: "Time (in seconds) for the colors in the gradient to cycle through 360° of hue. Set to 0 to disable.",
                         ControlTitle: "", Default: 0.0 as Any, Starting: 0.0 as Any, FieldType: .Double,
                         List: nil, Handler: nil)
        BGGroup.AddField(ID: UUID(), Title: "Background image",
                         Description: "Image to use for the game view background.",
                         ControlTitle: "", Default: "IMG_0004.JPG", Starting: "IMG_0004.JPG", FieldType: .Image,
                         List: nil, Handler: nil)
        BGGroup.AddField(ID: UUID(), Title: "Live background camera",
                         Description: "Camera to use for live view backgrounds. Valid only for those devices with cameras (eg, not simulators).",
                         ControlTitle: "", Default: "Rear", Starting: "Rear", FieldType: .StringList,
                         List: GroupData2.EnumListToStringList(CameraLocations.allCases), Handler: nil)
        FieldTables.append(BGGroup)
        
        //Bucket attributes.
        let BucketGroup = GroupData2("Bucket")
        BucketGroup.AddField(ID: UUID(), Title: "Show bucket grid",
                             Description: "Shows a grid in the bucket sized to fit piece blocks.",
                             ControlTitle: "Show grid", Default: true as Any, Starting: true as Any,
                             FieldType: .Bool, List: nil, Handler: nil)
        BucketGroup.AddField(ID: UUID(), Title: "Bucket grid color",
                             Description: "Color of the bucket grid (ignored if not showing)", ControlTitle: "",
                             Default: UIColor.gray as Any, Starting: UIColor.gray as Any,
                             FieldType: .Color, List: nil, Handler: nil)
        BucketGroup.AddField(ID: UUID(), Title: "Show bucket grid outline",
                             Description: "Draw an outline around the bucket grid.", ControlTitle: "Grid outline",
                             Default: true as Any, Starting: true as Any,
                             FieldType: .Bool, List: nil, Handler: nil)
        BucketGroup.AddField(ID: UUID(), Title: "Outline color",
                             Description: "The color of the bucket grid outline (ignored if not showing)",
                             ControlTitle: "", Default: UIColor.red as Any, Starting: UIColor.red as Any,
                             FieldType: .Color, List: nil, Handler: nil)
        BucketGroup.AddField(ID: UUID(), Title: "Rotate bucket between pieces",
                             Description: "Rotate the bucket (for certain games) between each piece.",
                             ControlTitle: "Rotate bucket", Default: true as Any,
                             Starting: true as Any, FieldType: .Bool, List: nil, Handler: nil)
        BucketGroup.AddField(ID: UUID(), Title: "Rotation durations",
                             Description: "Duration of the rotation of the bucket for certain games.",
                             ControlTitle: "Seconds", Default: 0.25 as Any,
                             Starting: 0.25 as Any, FieldType: .Double, List: nil, Handler: nil)
        BucketGroup.AddField(ID: UUID(), Title: "Bucket rotates right",
                             Description: "Set on to rotate the bucket right (clockwise) for rotations (for certain games).",
                             ControlTitle: "Rotate right", Default: true as Any,
                             Starting: true as Any, FieldType: .Bool, List: nil, Handler: nil)
        BucketGroup.AddField(ID: UUID(), Title: "Rotate bucket grid",
                             Description: "Rotate the bucket's grid and outline along with the bucket when appropriate.",
                             ControlTitle: "Rotate grid", Default: true as Any,
                             Starting: true as Any, FieldType: .Bool, List: nil, Handler: nil)
        BucketGroup.AddField(ID: UUID(), Title: "Fade bucket grid",
                             Description: "Fades the bucket grid soon after the game starts.", ControlTitle: "Fade bucket grid",
                             Default: false as Any, Starting: false as Any,
                             FieldType: .Bool, List: nil, Handler: nil)
        BucketGroup.AddField(ID: UUID(), Title: "Fade bucket outline",
                             Description: "Fades the bucket grid ouline soon after the game starts.", ControlTitle: "Fade grid outline",
                             Default: false as Any, Starting: false as Any,
                             FieldType: .Bool, List: nil, Handler: nil)
        FieldTables.append(BucketGroup)
    }
}
