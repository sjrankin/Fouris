//
//  +AboutBox.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension View3D
{
    /// Show the about box.
    /// - Note: If the about box is already showing, no action is taken if this function is called.
    /// - Parameter FadeInduration: The amount of time in seconds to fade-in the box when it is initially shown.
    /// - Parameter HideAfter: If the user does not intervene, this is the number of seconds to wait before automatically
    ///                        hiding the about box.
    func ShowAboutBox(FadeInDuration: Double, HideAfter: Double)
    {
        if AboutBoxShowing
        {
            return
        }
        AboutBoxShowing = true
        
        let Light = SCNLight()
        Light.categoryBitMask = View3D.AboutLight
        Light.color = UIColor.white
        Light.type = .spot
        AboutLightNode = SCNNode()
        AboutLightNode?.light = Light
        AboutLightNode?.position = SCNVector3(0.0, 8.0, 30.0)
        self.scene?.rootNode.addChildNode(AboutLightNode!)
        let CircleDuration = 10.0
        let CircleRadius: CGFloat = 10.0
        let RoundMotion = SCNAction.customAction(duration: CircleDuration,
                                                 action:
            {
                Node, ElapsedTime in
                let Percent: CGFloat = ElapsedTime / CGFloat(CircleDuration)
                let Angle = 360.0 * Percent
                let Radian = Angle * CGFloat.pi / 180.0
                let NewX = 0.0 + (CircleRadius * cos(Radian))
                let NewY = 8.0 + (CircleRadius * sin(Radian))
                let NewLocation = SCNVector3(NewX, NewY, 50.0)
                self.AboutLightNode?.position = NewLocation
        })
        let CircleForever = SCNAction.repeatForever(RoundMotion)
        AboutLightNode?.runAction(CircleForever)
        
        let Box = SCNBox(width: 10.0, height: 4.0, length: 1.0, chamferRadius: 0.25)
        Box.firstMaterial?.diffuse.contents = UIColor.black
        Box.firstMaterial?.specular.contents = UIColor.white
        AboutBoxNode = SCNNode(geometry: Box)
        AboutBoxNode?.categoryBitMask = View3D.AboutLight
        AboutBoxNode?.position = SCNVector3(0.0, 0.0, 1.0)
        self.scene?.rootNode.addChildNode(AboutBoxNode!)
        
        let Title = SCNText(string: "Fouris", extrusionDepth: 3.0)
        Title.font = UIFont(name: "Futura", size: 16.0)
        Title.flatness = 0.0
        Title.firstMaterial?.diffuse.contents = UIColor.white
        Title.firstMaterial?.specular.contents = UIColor.white
        let TitleNode = SCNNode(geometry: Title)
        TitleNode.scale = SCNVector3(0.1, 0.1, 0.1)
        TitleNode.categoryBitMask = View3D.AboutLight
        TitleNode.position = SCNVector3(-2.0, -0.5, 1.0)
        AboutBoxNode?.addChildNode(TitleNode)
        
        let Ver = SCNText(string: Versioning.MakeVersionString(), extrusionDepth: 1.0)
        Ver.font = UIFont(name: "Futura", size: 10.0)
        Ver.flatness = 0.0
        Ver.firstMaterial?.diffuse.contents = UIColor.white
        Ver.firstMaterial?.specular.contents = UIColor.blue
        let VerNode = SCNNode(geometry: Ver)
        VerNode.scale = SCNVector3(0.09, 0.09, 0.09)
        VerNode.categoryBitMask = View3D.AboutLight
        VerNode.position = SCNVector3(-2.0, -1.5, 1.0)
        AboutBoxNode?.addChildNode(VerNode)
        
        let FadeIn = SCNAction.fadeIn(duration: FadeInDuration)
        AboutBoxNode?.runAction(FadeIn,
        completionHandler:
            {
                self.AboutBoxHideTimer = Timer.scheduledTimer(timeInterval: HideAfter, target: self,
                                                         selector: #selector(self.AutoHideAboutBox),
                                                         userInfo: nil, repeats: false)
        })
    }
    
    /// Hide the about box. Called by `ShowAboutBox` after a certain amount of time.
    @objc func AutoHideAboutBox()
    {
        HideAboutBox()
    }
    
    /// Hide the about box.
    /// - Note: If the about box is not visible, this function takes no action.
    /// - Parameter HideDuration: The number of seconds to take for the hide animation.
    func HideAboutBox(HideDuration: Double = 1.0)
    {
        if !AboutBoxShowing
        {
            return
        }
        AboutBoxHideTimer?.invalidate()
        AboutBoxHideTimer = nil
        AboutBoxShowing = false
        AboutBoxNode?.removeAllActions()
        let FadeOut = SCNAction.fadeOut(duration: HideDuration)
        let Remove = SCNAction.removeFromParentNode()
        let Sequence = SCNAction.sequence([FadeOut, Remove])
        AboutBoxNode?.runAction(Sequence,
                                completionHandler:
            {
                self.AboutBoxNode = nil
                self.AboutLightNode?.removeAllActions()
                self.AboutLightNode?.removeFromParentNode()
                self.AboutLightNode = nil
                self.Main?.VersionBoxDisappeared()
        })
    }
}
