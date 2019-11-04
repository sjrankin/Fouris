//
//  +TextButtons.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Contains functions for the creation and manipulation of text node buttons in the game view.
extension View3D
{
    /// Adds a background "layer" behind the top control buttons to clarify where the control region is.
    public func ShowControlButtonBackground()
    {
        let Box = SCNBox(width: 30.0, height: 4.0, length: 0.01, chamferRadius: 0.0)
        Box.firstMaterial?.diffuse.contents = UIColor.black.withAlphaComponent(0.75)
        Box.firstMaterial?.specular.contents = UIColor.white
        ControlBackground = SCNNode(geometry: Box)
        ControlBackground?.position = SCNVector3(0.0, 15.0, 0.5)
        self.scene?.rootNode.addChildNode(ControlBackground!)
    }
    
    /// Make a in-scene motion button.
    /// - Note: Depending on the device type, different button sizes and locations are used. This is determined at run time.
    /// - Parameter ForButton: Determines the button to create and add to the scene.
    /// - Parameter NodeText: If supplied the text to use for the node. If not supplied, default values are used.
    public func MakeButton(ForButton: NodeButtons, NodeText: String? = nil)
    {
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            ButtonDictionary = SmallButtonDictionary
        }
        else
        {
            ButtonDictionary = BigButtonDictionary
        }
        var ButtonFont = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.bold)
        if let Descriptor = ButtonFont.fontDescriptor.withDesign(.rounded)
        {
            ButtonFont = UIFont(descriptor: Descriptor, size: 32.0)
        }
        var FinalNode: SCNButtonNode!
        switch ForButton
        {
            case .MainButton:
                #if false
                let Sphere = SCNSphere(radius: 0.6)
                Sphere.firstMaterial?.diffuse.contents = UIImage(named: "Checkerboard64")
                Sphere.firstMaterial?.specular.contents = UIColor.white
                let SphereNode = SCNNode(geometry: Sphere)
                SphereNode.categoryBitMask = View3D.ControlLight
                let Torus = SCNTorus(ringRadius: 0.5, pipeRadius: 0.35)
                Torus.firstMaterial?.diffuse.contents = UIImage(named: "Checkerboard64")
                Torus.firstMaterial?.specular.contents = UIColor.white
                let TorusNode = SCNNode(geometry: Torus)
                TorusNode.categoryBitMask = View3D.ControlLight
                let Combined = SCNNode()
                Combined.addChildNode(SphereNode)
                Combined.addChildNode(TorusNode)
                MainButtonObject = Combined
                #else
                let Box = SCNBox(width: 0.85, height: 0.85, length: 0.85, chamferRadius: 0.0)
                Box.firstMaterial?.diffuse.contents = UIImage(named: "Checkerboard64")
                //Box.firstMaterial?.diffuse.contents = UIImage(named: "CircleArrayBlackWhite144")
                Box.firstMaterial?.specular.contents = UIColor.white
                MainButtonObject = SCNNode(geometry: Box)
                MainButtonObject?.name = "MainButtonObject"
                #endif
                MainButtonObject?.categoryBitMask = View3D.ControlLight
                let Around = CGFloat.pi / 180.0 * 360.0
                let Rotate = SCNAction.rotateBy(x: Around, y: Around, z: Around, duration: 30.0)
                let Forever = SCNAction.repeatForever(Rotate)
                MainButtonObject?.runAction(Forever)
                #if true
                let FinalNode = SCNButtonNode.MakeButton(ButtonType: .MainButton, SourceNode: MainButtonObject!,
                                                         Location: ButtonDictionary[ForButton]!.Location,
                                                         ScaleFactor: 1.0, LightMask: View3D.ControlLight)
                #else
                let FinalNode = SCNButtonNode.AddObjectButton(ForButton: .MainButton, SourceNode: MainButtonObject!,
                                                              Location: ButtonDictionary[ForButton]!.Location,
                                                              LightMask: View3D.ControlLight)
                FinalNode.SetBackgroundColor(Diffuse: UIColor.cyan)
                #endif
                #if false
                FinalNode.castsShadow = true
                #endif
                self.scene?.rootNode.addChildNode(FinalNode)
                return
            
            case .FPSButton:
                let ButtonText = NodeText == nil ? "60.000" : NodeText!
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .FPSButton, Text: ButtonText, CodePoint: 0, TextType: .String,
                                                     Location: ButtonDictionary[ForButton]!.Location, Depth: 2.0,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: ButtonFont, LightMask: View3D.ControlLight)
                FinalNode.ShowPressed = false
            
            case .PlayButton:
                let ButtonText = NodeText == nil ? "Play" : NodeText!
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .PlayButton, Text: ButtonText, CodePoint: 0, TextType: .String,
                                                     Location: ButtonDictionary[ForButton]!.Location, Depth: 1.0,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: ButtonFont, LightMask: View3D.ControlLight)
            
            case .PauseButton:
                let ButtonText = NodeText == nil ? "Pause" : NodeText!
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .PauseButton, Text: ButtonText, CodePoint: 0, TextType: .String,
                                                     Location: ButtonDictionary[ForButton]!.Location, Depth: 1.0,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: ButtonFont, LightMask: View3D.ControlLight)
            
            case .VideoButton:
                let OverrideFont = UIFont(name: "NotoEmoji", size: 40.0)!
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .VideoButton, Text: "", CodePoint: 0x1f4f9, TextType: .UnicodeCodePoint,
                                                     Location: ButtonDictionary[ForButton]!.Location, Depth: 1.0,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: OverrideFont, LightMask: View3D.ControlLight)
            
            case .CameraButton:
                let OverrideFont = UIFont(name: "NotoEmoji", size: 40.0)!
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .CameraButton, Text: "", CodePoint: 0x1f4f7, TextType: .UnicodeCodePoint,
                                                     Location: ButtonDictionary[ForButton]!.Location, Depth: 1.0,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: OverrideFont, LightMask: View3D.ControlLight)
            
            case .DownButton:
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .DownButton, Text: "", CodePoint: 0x25bc, TextType: .UnicodeCodePoint,
                                                     Location: ButtonDictionary[ForButton]!.Location,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: ButtonFont, LightMask: View3D.ControlLight)
            
            case .DropDownButton:
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .DropDownButton, Text: "", CodePoint: 0x25bc, TextType: .UnicodeCodePoint,
                                                     Location: ButtonDictionary[ForButton]!.Location,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: ButtonFont, LightMask: View3D.ControlLight)
            
            case .FlyAwayButton:
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .FlyAwayButton, Text: "", CodePoint: 0x25b2, TextType: .UnicodeCodePoint,
                                                     Location: ButtonDictionary[ForButton]!.Location,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: ButtonFont, LightMask: View3D.ControlLight)
            
            case .FreezeButton:
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .FreezeButton, Text: "❄︎", CodePoint: 0, TextType: .String,
                                                     Location: ButtonDictionary[ForButton]!.Location,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: ButtonFont, LightMask: View3D.ControlLight)
            
            case .LeftButton:
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .LeftButton, Text: "", CodePoint: 0x25c0, TextType: .UnicodeCodePoint,
                                                     Location: ButtonDictionary[ForButton]!.Location,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: ButtonFont, LightMask: View3D.ControlLight)
            
            case .RightButton:
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .RightButton, Text: "", CodePoint: 0x25b6, TextType: .UnicodeCodePoint,
                                                     Location: ButtonDictionary[ForButton]!.Location,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: ButtonFont, LightMask: View3D.ControlLight)
            
            case .RotateLeftButton:
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .RotateLeftButton, Text: "↺", CodePoint: 0, TextType: .String,
                                                     Location: ButtonDictionary[ForButton]!.Location,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: ButtonFont, LightMask: View3D.ControlLight)
            
            case .RotateRightButton:
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .RotateRightButton, Text: "↻", CodePoint: 0, TextType: .String,
                                                     Location: ButtonDictionary[ForButton]!.Location,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: ButtonFont, LightMask: View3D.ControlLight)
            
            case .UpButton:
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .UpButton, Text: "", CodePoint: 0x25b2, TextType: .UnicodeCodePoint,
                                                     Location: ButtonDictionary[ForButton]!.Location,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: ButtonFont, LightMask: View3D.ControlLight)
            
            case .HeartButton:
                FinalNode = SCNButtonNode.MakeButton(ButtonType: .HeartButton, Text: "♥︎", CodePoint: 0, TextType: .String,
                                                     Location: ButtonDictionary[ForButton]!.Location,
                                                     ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                     Color: ButtonDictionary[ForButton]!.Color,
                                                     Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                     Font: ButtonFont, LightMask: View3D.ControlLight)
            
            default:
                return
        }
        
        ButtonList[ForButton] = FinalNode
        self.scene?.rootNode.addChildNode(FinalNode!)
    }
    
    /// Returns the parent node of the passed button node.
    /// - Parameter Of: The node whose parent will be returned.
    /// - Returns: The parent of the passed node. Nil if not found.
    public func GetParentNode(Of Node: SCNButtonNode) -> SCNButtonNode?
    {
        if Node.parent == nil
        {
            return nil
        }
        if Node.name == nil
        {
            return nil
        }
        for (_, Parent) in ButtonList
        {
            
            if Parent.childNode(withName: Node.name!, recursively: true) != nil
            {
                return Parent
            }
        }
        return nil
    }
    
    /// Flash a button with its pre-set highlight color.
    /// - Note: "Flash" means showing the highlight color for a short amount of time to simulate a
    ///         button press by the AI.
    /// - Parameter Button: The button to flash.
    /// - Parameter Duration: How long to flash the button in seconds. Defaults to 0.15 seconds.
    public func FlashButton(_ Button: NodeButtons, Duration: Double = 0.15)
    {
        if let Node = ButtonList[Button]
        {
            Node.Flash()
        }
    }
    
    /// Unconditionally sets the button color to its normal color.
    /// - Parameter Button: The button whose color will be reset to normal.
    public func SetButtonColorToNormal(Button: NodeButtons)
    {
        if let TheButton = ButtonList[Button]
        {
            let NormalColor = ButtonDictionary[Button]!.Color
            TheButton.SetButtonColor(NewColor: NormalColor)
        }
    }
    
    /// Unconditionally sets the button color to its highlight color.
    /// - Paraemter Button: The button whose color will be set to highlight.
    public func SetButtonColorToHighlight(Button: NodeButtons)
    {
        if let TheButton = ButtonList[Button]
        {
            let HighlightColor = ButtonDictionary[Button]!.Highlight
            TheButton.SetButtonColor(NewColor: HighlightColor)
        }
    }
    
    /// Sets/changes the text on the specified button.
    /// - Parameter OnButton: The button whose text will change.
    /// - Parameter ToNextText: New text for the button.
    public func SetText(OnButton: NodeButtons, ToNextText: String)
    {
        if let TheButton = ButtonList[OnButton]
        {
            TheButton.removeFromParentNode()
            MakeButton(ForButton: OnButton, NodeText: ToNextText)
        }
    }
    
    /// Show game view controls.
    /// - Parameter Which: Array of buttons to show. If nil, all buttons are shown. Default is nil. Passing an empty array will
    ///                    remove all buttons.
    public func ShowControls(With: [NodeButtons]? = nil)
    {
        //Add the background if necessary.
        var FoundBackground = false
        self.scene?.rootNode.enumerateChildNodes
            {
                Node, _ in
                if Node == ControlBackground
                {
                    FoundBackground = true
                }
        }
        if !FoundBackground
        {
            ShowControlButtonBackground()
        }
        
        //Remove some of the buttons.
        for (_, Button) in ButtonList
        {
            if [.HeartButton, .MainButton, .FPSButton, .PlayButton, .PauseButton, .VideoButton, .CameraButton].contains(Button.ButtonType)
            {
                continue
            }
            Button.removeFromParentNode()
        }
        ButtonList.removeAll()
        
        if With == nil
        {
            MakeButton(ForButton: .MainButton)
            MakeButton(ForButton: .FPSButton)
            MakeButton(ForButton: .PlayButton)
            MakeButton(ForButton: .PauseButton)
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                MakeButton(ForButton: .VideoButton)
                MakeButton(ForButton: .CameraButton)
            }
            MakeButton(ForButton: .LeftButton)
            MakeButton(ForButton: .DownButton)
            MakeButton(ForButton: .RotateLeftButton)
            MakeButton(ForButton: .RightButton)
            MakeButton(ForButton: .RotateRightButton)
            MakeButton(ForButton: .UpButton)
            MakeButton(ForButton: .DropDownButton)
            MakeButton(ForButton: .FlyAwayButton)
            MakeButton(ForButton: .FreezeButton)
        }
        else
        {
            for SomeButton in With!
            {
                MakeButton(ForButton: SomeButton)
            }
        }
    }
    
    /// Adds the specified button to the set of motion controls. If the button is already present, no action is taken.
    /// - Parameter Which: The button to add.
    public func AppendButton(Which: NodeButtons)
    {
        if ButtonList.keys.contains(Which)
        {
            return
        }
        MakeButton(ForButton: Which)
    }
    
    /// Removes the specified button from the set of motion controls. If the button is not present, no action is taken.
    /// - Parameter Which: The button to remove.
    public func RemoveButton(Which: NodeButtons)
    {
        if ButtonList.keys.contains(Which)
        {
            ButtonList[Which]?.removeFromParentNode()
            ButtonList.removeValue(forKey: Which)
        }
    }
    
    /// Disables a control already in place. This means the control is added to the `DisabledControls` set and its opacity
    /// is set to `0.0`. The main class should call `IsDisabled` on each hit test success to see if the user pressed a disabled
    /// button.
    /// - Parameter Which: The node to disable.
    public func DisableControl(Which: NodeButtons)
    {
        if ButtonList.keys.contains(Which)
        {
            ButtonList[Which]?.opacity = 0.0
            _DisabledControls.insert(Which)
        }
        else
        {
            print("Did not find \(Which) to disable.")
        }
    }
    
    /// Enables a disabled. This means the control is removed from the `DisabledControls` set and its opacity
    /// is set to `1.0`.
    /// - Parameter Which: The node to enable.
    public func EnableControl(Which: NodeButtons)
    {
        if ButtonList.keys.contains(Which)
        {
            ButtonList[Which]?.opacity = 1.0
            _DisabledControls.remove(Which)
        }
    }
    
    /// Set of disabled controls/buttons.
    public var DisabledControls: Set<NodeButtons>
    {
        get
        {
            return _DisabledControls
        }
    }
    
    /// Determines if the passed button is enabled or disabled.
    /// - Returns: True if the passed button is disabled, false if is not.
    public func IsDisabledButton(_ Button: NodeButtons) -> Bool
    {
        return DisabledControls.contains(Button)
    }
    
    /// Hides all motion controls in the game surface and may optionally change the visual size
    /// of the bucket.
    public func HideControls()
    {
        ShowControls(With: [])
    }
    
    /// Given a button type, return the button itself.
    /// - Parameter Which: The button type to return.
    /// - Returns: The button associated with the passed type on success, nil if not found (or not created for use yet).
    public func GetButton(_ Which: NodeButtons) -> SCNButtonNode?
    {
        if let ButtonNode = ButtonList[Which]
        {
            if let ShapeNode = ButtonNode.GetNodeWithTag(Value: "ShapeNode")
            {
                return ShapeNode
            }
        }
        return nil
    }
    
    /// Change the main button's texture to the supplied image.
    /// - Parameter To: The new image to use for the texture.
    public func ChangeMainButtonTexture(To: UIImage)
    {
        MainButtonObject?.geometry?.firstMaterial?.diffuse.contents = To
    }
    
    /// Animate the extrusion depth of the button.
    /// - Parameter Which: The button whose extrusion depth will be animated.
    /// - Parameter ToHeight: The new height of the node.
    /// - Paremeter Duration: The duration of the animation.
    public func AnimateExtrusion(_ Which: NodeButtons, ToHeight: CGFloat, Duration: Double = 0.25)
    {
        if let ButtonNode = ButtonList[Which]
        {
            if let STextGeo = ButtonNode.geometry as? SCNText
            {
                UIView.animate(withDuration: Duration, animations:
                    {
                        STextGeo.extrusionDepth = ToHeight
                })
            }
        }
    }
    
    /// Sets the visual state of the heart button to indicate a regular heartbeat on the main UI thread.
    /// - Parameter IsHighlighted: Determines whether the heart button is highlighted or normal.
    /// - Parameter Duration: The duration of the animation for scaling and extrusion.
    /// - Parameter Colors: Set of colors for the highlight state and the normal state.
    /// - Parameter Sizes: Set of scale values for the highlight size and the normal size.
    /// - Parameter Extrusions: Set of extrusion values for the highlight extrusion depth and the normal
    ///                         extrusion depth.
    public func AnimateHeartbeat(IsHighlighted: Bool, Duration: Double,
                                 Colors: (Highlighted: UIColor, Normal: UIColor),
                                 Sizes: (Highlighted: CGFloat, Normal: CGFloat),
                                 Extrusions: (Highlighted: CGFloat, Normal: CGFloat))
    {
        if let ButtonNode = ButtonList[.HeartButton]
        {
            let NewColor = IsHighlighted ? Colors.Highlighted : Colors.Normal
            let NewSize = IsHighlighted ? Sizes.Highlighted : Sizes.Normal
            let NewExtrusion = IsHighlighted ? Extrusions.Highlighted : Extrusions.Normal
            if let TextNode = ButtonNode.geometry as? SCNText
            {
                TextNode.firstMaterial?.diffuse.contents = NewColor
                UIView.animate(withDuration: Duration, animations:
                    {
                        TextNode.extrusionDepth = NewExtrusion
                })
                let ScaleAction = SCNAction.scale(to: NewSize, duration: Duration)
                ButtonNode.runAction(ScaleAction)
            }
        }
    }
}
