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
    /// Make a in-scene motion button.
    /// - Note: Depending on the device type, different button sizes and locations are used. This is determined at run time.
    /// - Parameter ForButton: Determines the button to create and add to the scene.
    /// - Parameter NodeText: If supplied the text to use for the node. If not supplied, default values are used.
    func MakeButton(ForButton: NodeButtons, NodeText: String? = nil)
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
                SphereNode.categoryBitMask = ControlLight
                let Torus = SCNTorus(ringRadius: 0.5, pipeRadius: 0.35)
                Torus.firstMaterial?.diffuse.contents = UIImage(named: "Checkerboard64")
                Torus.firstMaterial?.specular.contents = UIColor.white
                let TorusNode = SCNNode(geometry: Torus)
                TorusNode.categoryBitMask = ControlLight
                let Combined = SCNNode()
                Combined.addChildNode(SphereNode)
                Combined.addChildNode(TorusNode)
                MainButtonObject = Combined
                #else
                let Box = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
                Box.firstMaterial?.diffuse.contents = UIImage(named: "Checkerboard64")
                Box.firstMaterial?.specular.contents = UIColor.white
                MainButtonObject = SCNNode(geometry: Box)
                #endif
                MainButtonObject?.categoryBitMask = ControlLight
                let Around = CGFloat.pi / 180.0 * 360.0
                let Rotate = SCNAction.rotateBy(x: Around, y: Around, z: Around, duration: 15.0)
                let Forever = SCNAction.repeatForever(Rotate)
                MainButtonObject?.runAction(Forever)
                let FinalNode = SCNButtonNode.AddObjectButton(ForButton: .MainButton, SourceNode: MainButtonObject!,
                                                              Location: ButtonDictionary[ForButton]!.Location,
                                                              LightMask: ControlLight)
                FinalNode.SetBackgroundColor(Diffuse: UIColor.cyan)
                #if false
                FinalNode.castsShadow = true
                #endif
                self.scene?.rootNode.addChildNode(FinalNode)
            return
            
            case .FPSButton:
                let ButtonText = NodeText == nil ? "60.000" : NodeText!
                FinalNode = SCNButtonNode.AddTextButton(ForButton: .FPSButton, ButtonText, Font: ButtonFont,
                                                        Location: ButtonDictionary[ForButton]!.Location,
                                                        Color: ButtonDictionary[ForButton]!.Color,
                                                        Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                        ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                        LightMask: ControlLight, Depth: 0.0)
            
            case .PlayButton:
                                let ButtonText = NodeText == nil ? "Play" : NodeText!
                FinalNode = SCNButtonNode.AddTextButton(ForButton: .PlayButton, ButtonText, Font: ButtonFont,
                                                        Location: ButtonDictionary[ForButton]!.Location,
                                                        Color: ButtonDictionary[ForButton]!.Color,
                                                        Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                        ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                        LightMask: ControlLight, Depth: 2.0)
            
            case .PauseButton:
                                let ButtonText = NodeText == nil ? "Resume" : NodeText!
                FinalNode = SCNButtonNode.AddTextButton(ForButton: .PauseButton, ButtonText, Font: ButtonFont,
                                                        Location: ButtonDictionary[ForButton]!.Location,
                                                        Color: ButtonDictionary[ForButton]!.Color,
                                                        Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                        ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                        LightMask: ControlLight, Depth: 2.0)
            
            case .VideoButton:
                let OverrideFont = UIFont(name: "NotoEmoji", size: 40.0)!
                FinalNode = SCNButtonNode.AddUnicodeButton(ForButton: ForButton, 0x1f4f9, Font: OverrideFont,
                                                           Location: ButtonDictionary[ForButton]!.Location,
                                                           Color: ButtonDictionary[ForButton]!.Color,
                                                           Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                           ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                           LightMask: ControlLight)
            
            case .CameraButton:
                let OverrideFont = UIFont(name: "NotoEmoji", size: 40.0)!
                FinalNode = SCNButtonNode.AddUnicodeButton(ForButton: ForButton, 0x1f4f7, Font: OverrideFont,
                                                        Location: ButtonDictionary[ForButton]!.Location,
                                                        Color: ButtonDictionary[ForButton]!.Color,
                                                        Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                        ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                        LightMask: ControlLight)
            
            case .DownButton:
                FinalNode = SCNButtonNode.AddUnicodeButton(ForButton: ForButton, 0x25bc, Font: ButtonFont,
                                                           Location: ButtonDictionary[ForButton]!.Location,
                                                           Color: ButtonDictionary[ForButton]!.Color,
                                                           Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                           ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                           LightMask: ControlLight)
            
            case .DropDownButton:
                FinalNode = SCNButtonNode.AddUnicodeButton(ForButton: ForButton, 0x25bc, Font: ButtonFont,
                                                           Location: ButtonDictionary[ForButton]!.Location,
                                                           Color: ButtonDictionary[ForButton]!.Color,
                                                           Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                           ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                           LightMask: ControlLight)
            
            case .FlyAwayButton:
                FinalNode = SCNButtonNode.AddUnicodeButton(ForButton: ForButton, 0x25b2, Font: ButtonFont,
                                                           Location: ButtonDictionary[ForButton]!.Location,
                                                           Color: ButtonDictionary[ForButton]!.Color,
                                                           Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                           ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                           LightMask: ControlLight)
            
            case .FreezeButton:
                FinalNode = SCNButtonNode.AddTextButton(ForButton: ForButton, "❄︎", Font: ButtonFont,
                                                        Location: ButtonDictionary[ForButton]!.Location,
                                                        Color: ButtonDictionary[ForButton]!.Color,
                                                        Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                        ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                        LightMask: ControlLight)
            
            case .LeftButton:
                FinalNode = SCNButtonNode.AddUnicodeButton(ForButton: ForButton, 0x25c0, Font: ButtonFont,
                                                           Location: ButtonDictionary[ForButton]!.Location,
                                                           Color: ButtonDictionary[ForButton]!.Color,
                                                           Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                           ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                           LightMask: ControlLight)
            
            case .RightButton:
                FinalNode = SCNButtonNode.AddUnicodeButton(ForButton: ForButton, 0x25b6, Font: ButtonFont,
                                                           Location: ButtonDictionary[ForButton]!.Location,
                                                           Color: ButtonDictionary[ForButton]!.Color,
                                                           Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                           ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                           LightMask: ControlLight)
            
            case .RotateLeftButton:
                FinalNode = SCNButtonNode.AddTextButton(ForButton: ForButton, "↺", Font: ButtonFont,
                                                        Location: ButtonDictionary[ForButton]!.Location,
                                                        Color: ButtonDictionary[ForButton]!.Color,
                                                        Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                        ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                        LightMask: ControlLight)
            
            case .RotateRightButton:
                FinalNode = SCNButtonNode.AddTextButton(ForButton: ForButton, "↻", Font: ButtonFont,
                                                        Location: ButtonDictionary[ForButton]!.Location,
                                                        Color: ButtonDictionary[ForButton]!.Color,
                                                        Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                        ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                        LightMask: ControlLight)
            
            case .UpButton:
                FinalNode = SCNButtonNode.AddUnicodeButton(ForButton: ForButton, 0x25b2, Font: ButtonFont,
                                                           Location: ButtonDictionary[ForButton]!.Location,
                                                           Color: ButtonDictionary[ForButton]!.Color,
                                                           Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                           ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                           LightMask: ControlLight)
            
            case .HeartButton:
                FinalNode = SCNButtonNode.AddTextButton(ForButton: ForButton, "♥︎", Font: ButtonFont,
                                                        Location: ButtonDictionary[ForButton]!.Location,
                                                        Color: ButtonDictionary[ForButton]!.Color,
                                                        Highlight: ButtonDictionary[ForButton]!.Highlight,
                                                        ScaleFactor: ButtonDictionary[ForButton]!.Scale,
                                                        LightMask: ControlLight)
            
            default:
            return
        }
        
        ButtonList[ForButton] = FinalNode
        self.scene?.rootNode.addChildNode(FinalNode!)
    }
    
    /// Returns the parent node of the passed button node.
    /// - Parameter Of: The node whose parent will be returned.
    /// - Returns: The parent of the passed node. Nil if not found.
    func GetParentNode(Of: SCNButtonNode) -> SCNButtonNode?
    {
        for (_, Parent) in ButtonList
        {
            if Parent.childNode(withName: Of.name!, recursively: true) != nil
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
    func FlashButton(_ Button: NodeButtons, Duration: Double = 0.15)
    {
        if let Node = ButtonList[Button]
        {
            if let ShapeNode = Node.GetNodeWithTag(Value: "ShapeNode")
            {
                ShapeNode.Flash()
            }
        }
    }
    
    /// Unconditionally sets the button color to its normal color.
    /// - Parameter Button: The button whose color will be reset to normal.
    func SetButtonColorToNormal(Button: NodeButtons)
    {
        if let TheButton = ButtonList[Button]
        {
            if let ShapeNode = TheButton.GetNodeWithTag(Value: "ShapeNode")
            {
                let NormalColor = ButtonDictionary[Button]!.Color
                ShapeNode.SetButtonColor(NewColor: NormalColor)
            }
        }
    }
    
    /// Unconditionally sets the button color to its highlight color.
    /// - Paraemter Button: The button whose color will be set to highlight.
    func SetButtonColorToHighlight(Button: NodeButtons)
    {
        if let TheButton = ButtonList[Button]
        {
            if let ShapeNode = TheButton.GetNodeWithTag(Value: "ShapeNode")
            {
                let HighlightColor = ButtonDictionary[Button]!.Highlight
                ShapeNode.SetButtonColor(NewColor: HighlightColor)
            }
        }
    }
    
    func SetText(OnButton: NodeButtons, ToNextText: String)
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
    func ShowControls(With: [NodeButtons]? = nil)
    {
        //Remove some of the buttons first.
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
    func AppendButton(Which: NodeButtons)
    {
        if ButtonList.keys.contains(Which)
        {
            return
        }
        MakeButton(ForButton: Which)
    }
    
    /// Removes the specified button from the set of motion controls. If the button is not present, no action is taken.
    /// - Parameter Which: The button to remove.
    func RemoveButton(Which: NodeButtons)
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
    func DisableControl(Which: NodeButtons)
    {
        if ButtonList.keys.contains(Which)
        {
            ButtonList[Which]?.opacity = 0.0
            _DisabledControls.insert(Which)
        }
    }
    
    /// Enables a disabled. This means the control is removed from the `DisabledControls` set and its opacity
    /// is set to `1.0`.
    /// - Parameter Which: The node to enable.
    func EnableControl(Which: NodeButtons)
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
    func HideControls()
    {
        ShowControls(With: [])
    }
    
    /// Given a button type, return the button itself.
    /// - Parameter Which: The button type to return.
    /// - Returns: The button associated with the passed type on success, nil if not found (or not created for use yet).
    func GetButton(_ Which: NodeButtons) -> SCNButtonNode?
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
    func ChangeMainButtonTexture(To: UIImage)
    {
        MainButtonObject?.geometry?.firstMaterial?.diffuse.contents = To
    }
    
    /// Animate the extrusion depth of the button.
    /// - Parameter Which: The button whose extrusion depth will be animated.
    /// - Parameter ToHeight: The new height of the node.
    /// - Paremeter Duration: The duration of the animation.
    func AnimateExtrusion(_ Which: NodeButtons, ToHeight: CGFloat, Duration: Double = 0.25)
    {
        if let ButtonNode = ButtonList[Which]
        {
            if let ShapeNode = ButtonNode.GetNodeWithTag(Value: "ShapeNode")
            {
                if let STextGeo = ShapeNode.geometry as? SCNText
                {
                    UIView.animate(withDuration: Duration, animations:
                        {
                            STextGeo.extrusionDepth = ToHeight
                    })
                }
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
    func AnimateHeartbeat(IsHighlighted: Bool, Duration: Double,
                          Colors: (Highlighted: UIColor, Normal: UIColor),
                          Sizes: (Highlighted: CGFloat, Normal: CGFloat),
                          Extrusions: (Highlighted: CGFloat, Normal: CGFloat))
    {
        if let ButtonNode = ButtonList[.HeartButton]
        {
            if let ShapeNode = ButtonNode.GetNodeWithTag(Value: "ShapeNode")
            {
                let NewColor = IsHighlighted ? Colors.Highlighted : Colors.Normal
                let NewSize = IsHighlighted ? Sizes.Highlighted : Sizes.Normal
                let NewExtrusion = IsHighlighted ? Extrusions.Highlighted : Extrusions.Normal
                if let TextNode = ShapeNode.geometry as? SCNText
                {
                    TextNode.firstMaterial?.diffuse.contents = NewColor
                    UIView.animate(withDuration: Duration, animations:
                        {
                            TextNode.extrusionDepth = NewExtrusion
                    })
                    let ScaleAction = SCNAction.scale(to: NewSize, duration: Duration)
                    ShapeNode.runAction(ScaleAction)
                }
            }
        }
    }
}
