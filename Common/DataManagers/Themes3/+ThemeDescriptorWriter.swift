//
//  +ThemeDescriptorWriter.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension ThemeDescriptor2
{
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
        
        Working.append(Spaces(4) + "<Game Base=" + Quoted(GameType.rawValue) +
            " SubType=" + Quoted(SubGameType.rawValue) + "/>\n")
        
        Working.append(Spaces(4) + "<Dates Created=" + Quoted(CreateDate) +
            " Edited=" + Quoted(DateFormatter.localizedString(from: Date(), dateStyle: .long, timeStyle: .long)) + "/>\n")
        
        Working.append(Spaces(4) + "<Quality>\n")
        Working.append(Spaces(8) + "<Antialiasing Mode=" + Quoted(AntialiasingMode.rawValue) + "/>\n")
        Working.append(Spaces(4) + "</Quality>\n")
        
        Working.append(Spaces(4) + "<Lights>\n")
        Working.append(Spaces(8) + "<DefaultLighting Use=" + Quoted("\(UseDefaultLighting)") + "/>\n")
        Working.append(Spaces(8) + "<GameLight Type=" + Quoted(LightType.rawValue) + ">\n")
        Working.append(Spaces(12) + "<Position Location=" +
            Quoted("\(LightPosition.x),\(LightPosition.y),\(LightPosition.z)") + "/>\n")
        Working.append(Spaces(12) + "<Light Color=" + Quoted(LightColor) +
            " Intensity=" + Quoted("\(LightIntensity)") + "/>\n")
        Working.append(Spaces(8) + "</GameLight>\n")
        Working.append(Spaces(8) + "<ControlLight Type=" + Quoted(ControlLightType.rawValue) + ">\n")
        Working.append(Spaces(12) + "<Position Location=" +
            Quoted("\(ControlLightPosition.x),\(ControlLightPosition.y),\(ControlLightPosition.z)") +
            "/>\n")
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
        
        Working.append(Spaces(4) + "<Background Type=" + Quoted(BackgroundType.rawValue) + ">\n")
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
        
        Working.append(Spaces(4) + "<Board>\n")
        Working.append(Spaces(8) + "<Show Method=" + Quoted(ShowBoardMethod.rawValue) +
            " Duration=" + Quoted("\(ShowBoardDuration)") + "/>\n")
        Working.append(Spaces(8) + "<Hide Method=" + Quoted(HideBoardMethod.rawValue) +
            " Duration=" + Quoted("\(HideBoardDuration)") + "/>\n")
        Working.append(Spaces(4) + "</Board>\n")
        
        Working.append(Spaces(4) + "<Buttons>\n")
        Working.append(Spaces(8) + "<AllButtons Hide=" + Quoted("\(HideAllButtons)") + "/>\n")
        Working.append(Spaces(8) + "<UpButton Show=" + Quoted("\(ShowUpButton)") + "/>\n")
        Working.append(Spaces(8) + "<FlyAwayButton Show=" + Quoted("\(ShowFlyAwayButton)") + "/>\n")
        Working.append(Spaces(8) + "<DropDownButton Show=" + Quoted("\(ShowDropDownButton)") + "/>\n")
        Working.append(Spaces(8) + "<FreezeButton Show=" + Quoted("\(ShowFreezeButton)") + "/>\n")
        Working.append(Spaces(4) + "</Buttons>\n")
        
        Working.append(Spaces(4) + "<Feedback>\n")
        Working.append(Spaces(8) + "<Haptic Enable=" + Quoted("\(UseHapticFeedback)") + "/>\n")
        Working.append(Spaces(4) + "</Feedback>\n")
        
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
        Working.append(Spaces(12) + "<CenterLines Show=" + Quoted("\(ShowCenterLines)") +
            " Color=" + Quoted(CenterLineColor) + " Width=" + Quoted("\(CenterLineWidth)") + "/>\n")
        Working.append(Spaces(8) + "</GridLines>\n")
        Working.append(Spaces(4) + "</Debug>\n")
        
        Working.append(Spaces(4) + "<Pieces>\n")
        for PieceID in PieceList
        {
            Working.append(Spaces(8) + "<Piece ID=" + Quoted(PieceID.uuidString) + "/>\n")
        }
        Working.append(Spaces(4) + "</Pieces>\n")
        
        Working.append("</Theme>")
        if AppendTerminalReturn
        {
            Working.append("\n")
        }
        
        return Working
    }
}
