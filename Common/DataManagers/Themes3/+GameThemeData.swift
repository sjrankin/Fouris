//
//  +GameThemeData.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

extension ThemeManager3
{
    /// Returns an XML document string for the default game theme.
    /// - Note: This is used due to a bug in saving data to the file store. Once that bug is resolved,
    ///         this data can be removed.
    public static func RawTheme() -> String
    {
        return
"""
        <?xml version="1.0" encoding="UTF-8"?>
        <Theme ID="49de21df-e1ce-448d-9a87-8db26b07e7ab" Name="User Theme" UserTheme="true">
        <Runtime MinimumVersion="1.0" MinimumBuild="0"/>
        <Game BucketShape="Classic"/>
        <Dates Created="2019-10-03" Edited="Not Edited"/>
        <Quality>
        <Antialiasing Mode="MultiSampling4X"/>
        </Quality>
        <Camera>
        <FieldOfView Angle="96"/>
        <Positions Location="0.0,0.0,15.0" Orientation="0.0,0.0,0.0,0.0"/>
        <Projection IsOrthographic="false" OrthographicScale="20.0"/>
        </Camera>
        <Lights>
        <DefaultLighting Use="false"/>
        <GameLight Type="omni">
        <Position Location="-10.0,15.0,40.0"/>
        <Light Color="White" Intensity="1000"/>
        </GameLight>
        <ControlLight Type="omni">
        <Position Location="-3.0,15.0,50.0"/>
        <Light Color="White" Intensity="1000"/>
        </ControlLight>
        </Lights>
        <Background Type="Color">
        <Color Color="Maroon" CycleDuration="0.0"/>
        <Gradient Definition="(Red)@(0.0),(Blue)@(1.0)" CycleDuration="0.0"/>
        <Image FileName="Not Set" FromCameraRoll="false"/>
        <LiveView Camera="Rear"/>
        </Background>
        <Bucket>
        <Material Specular="White" Diffuse="ReallyDarkGray"/>
        <Grid Show="true" Color="Gray" Fade="false"/>
        <Outline Show="true" Color="Red" Fade="false"/>
        <Rotation Enable="true" Direction="Right" Duration="0.3"/>
        <Destruction Method="Shrink" Duration="1.25"/>
        <GameOver ShowOff="true"/>
        </Bucket>
        <Board>
        <Show Method="FadeIn" Duration="0.25"/>
        <Hide Method="FadeOut" Duration="0.25"/>
        </Board>
        <Buttons>
        <AllButtons Hide="false"/>
        <UpButton Show="true"/>
        <FlyAwayButton Show="true"/>
        <DropDownButton Show="true"/>
        <FreezeButton Show="true"/>
        </Buttons>
        <Feedback>
        <Haptic Enable="false"/>
        </Feedback>
        <TextOverlay>
        <NextPiece Show="true" Rotate="true"/>
        </TextOverlay>
        <AI>
        <Controls ShowAIActions="true"/>
        <SneakPeek Count="1"/>
        </AI>
        <Timing>
        <AfterGameWaitDuration Seconds="15"/>
        <AutoStartInterval Seconds="60"/>
        </Timing>
        <Debug Enable="true">
        <Camera UserCanControl="false"/>
        <Statistics ShowStatistics="false"/>
        <Heartbeat Show="true" Interval="1.0"/>
        <GridLines>
        <BackgroundGrid Show="false" Color="#e0e0e0" Width="0.5"/>
        <CenterLines Show="false" Color="#ffffff" Width="2.0"/>
        </GridLines>
        <Rotating>
        <Center ChangeColorAfterRotation="true"/>
        </Rotating>
        </Debug>
        <Pieces>
        <Piece ID="f4510cca-262a-4018-bf29-04d703702d65"/>
        <Piece ID="b5bb59a5-b006-487b-a7b1-e0daf4a48810"/>
        <Piece ID="05463ade-1996-49e0-aae9-55cad6f8f605"/>
        <Piece ID="0f2709f0-b5ed-4ed9-b8c5-d65a1e1d69e8"/>
        <Piece ID="26e5dee4-0cc5-492f-ab31-b5b810863bf4"/>
        <Piece ID="69cc6259-93f2-438d-8a9f-e0e65ad6c841"/>
        <Piece ID="7c73c10c-86b3-406d-964e-f12abbf914cc"/>
        </Pieces>
        </Theme>

"""
    }
    
    /// Resets the user theme to the raw default value defined elsewhere in the class (see `RawTheme`).
    /// - Note: All user settings will be lost.
    public static func ResetUserTheme()
    {
        UserDefaults.standard.set(ThemeManager3.RawTheme(), forKey: "GameTheme")
    }
}
