//
//  +PopulateFields.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

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
                               Description: "How long to wait after start-up before attract mode starts on its own.",
                               ControlTitle: "Seconds", Default: 60.0 as Any,
                               Starting: Settings.GetAutoStartDuration() as Any, FieldType: .Double, List: nil, Handler:
            {
                NewValue in
                let NewDouble = NewValue as! Double
                Settings.SetAutoStartDuration(ToNewValue: NewDouble)
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
        SettingsGroup.AddField(ID: UUID(), Title: "AI sneak peak count",
                               Description: "Number of pieces ahead the AI looks at to determine the best location for the current piece.",
                               ControlTitle: "Look-ahead count", Default: 1 as Any,
                               Starting: Settings.GetAISneakPeakCount() as Any, FieldType: .Int, List: nil, Handler:
            {
                NewValue in
                let NewInt = NewValue as! Int
                Settings.SetAISneakPeakCount(To: NewInt)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Show AI commands",
                               Description: "Show AI actions on the UI as if it were pressing the buttons.",
                               ControlTitle: "Show AI actions", Default: true as Any,
                               Starting: Settings.ShowAIUICommands() as Any, FieldType: .Bool, List: nil, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetAIUICommands(Enable: NewBool)
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
        
        //Playing.
        let PlayGroup = GroupData2("Play")
        PlayGroup.AddField(ID: UUID(), Title: "Rotate bucket between pieces",
                           Description: "Rotate the bucket (for certain games) between each piece.",
                           ControlTitle: "Rotate bucket", Default: true as Any,
                           Starting: true as Any, FieldType: .Bool, List: nil, Handler: nil)
        PlayGroup.AddField(ID: UUID(), Title: "Rotation durations",
                           Description: "Duration of the rotation of the bucket for certain games.",
                           ControlTitle: "Seconds", Default: 0.25 as Any,
                           Starting: 0.25 as Any, FieldType: .Double, List: nil, Handler: nil)
        PlayGroup.AddField(ID: UUID(), Title: "Bucket rotates right",
                           Description: "Set on to rotate the bucket right (clockwise) for rotations (for certain games).",
                           ControlTitle: "Rotate right", Default: true as Any,
                           Starting: true as Any, FieldType: .Bool, List: nil, Handler: nil)
        PlayGroup.AddField(ID: UUID(), Title: "Rotate bucket grid",
                           Description: "Rotate the bucket's grid and outline along with the bucket when appropriate.",
                           ControlTitle: "Rotate grid", Default: true as Any,
                           Starting: true as Any, FieldType: .Bool, List: nil, Handler: nil)
        PlayGroup.AddField(ID: UUID(), Title: "Block destruction method",
                           Description: "The method to use to clear a block from the bucket at the end of the game.",
                           ControlTitle: "", Default: "FadeAway" as Any, Starting: "FadeAway" as Any, FieldType: .StringList,
                           List: GroupData2.EnumListToStringList(DestructionMethods.allCases), Handler: nil)
        FieldTables.append(PlayGroup)
    }
}
