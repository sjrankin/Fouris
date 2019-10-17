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
    /// Returns the bounding size of the passed node.
    /// - Parameter Node: The SCNNode whose bounding size will be returned.
    /// - Returns: Bounding size of the passed SCNNode.
    func GetNodeBoundingSize(_ Node: SCNNode) -> CGSize
    {
        let BoundingSize = Node.boundingBox
        let XSize = Double(BoundingSize.max.x - BoundingSize.min.x)
        let YSize = Double(BoundingSize.max.y - BoundingSize.min.y)
        return CGSize(width: XSize, height: YSize)
    }
    
    /// Add a text button with text created from a Unicode code point.
    /// - Parameter ForButton: The button type.
    /// - Parameter CodePoint: Unicode code point. This function uses the system font so if the system font does not support
    ///                        the given code point, an ugly symbol will be displayed instead.
    /// - Parameter Font: The font to use. This function assumes the font is the system font.
    /// - Parameter Location: Where to place the button.
    /// - Parameter Color: The standard button color - used as the diffuse material color.
    /// - Parameter Highlight: The highlight button color.
    /// - Parameter ScaleFactor: Used to scale the button.
    func AddUnicodeButton(ForButton: NodeButtons, _ CodePoint: Int, Font: UIFont, Location: SCNVector3,
                          Color: UIColor, Highlight: UIColor, ScaleFactor: Double = 0.1) -> SCNButtonNode
    {
        let UnicodeChar = UnicodeScalar(CodePoint)
        let UnicodeString = "\((UnicodeChar)!)"
        let SText = SCNText(string: UnicodeString, extrusionDepth: 2)
        SText.font = Font
        SText.flatness = 0
        SText.firstMaterial?.diffuse.contents = Color
        SText.firstMaterial?.specular.contents = UIColor.white
        let Node = SCNButtonNode(geometry: SText)
        Node.ButtonColor = Color
        Node.HighlightColor = Highlight
        Node.name = "\(ForButton)"
        Node.categoryBitMask = ControlLight
        Node.scale = SCNVector3(ScaleFactor, ScaleFactor, ScaleFactor)
        Node.StringTag = "ShapeNode"
        
        let SourceSize = GetNodeBoundingSize(Node)
        let BGBox = SCNBox(width: SourceSize.width, height: SourceSize.height, length: 0.001, chamferRadius: 0.0)
        BGBox.firstMaterial?.diffuse.contents = UIColor.clear
        BGBox.firstMaterial?.specular.contents = UIColor.clear
        let BGNode = SCNButtonNode(geometry: BGBox)
        let FinalWidth = SourceSize.width * 0.06
        let FinalHeight = SourceSize.height * 0.1
        BGNode.position = SCNVector3(FinalWidth, FinalHeight, -0.1)
        BGNode.scale = SCNVector3(ScaleFactor, ScaleFactor, ScaleFactor)
        BGNode.name = "\(ForButton)"
        BGNode.StringTag = "BackgroundNode"
        
        let FinalNode = SCNButtonNode()
        FinalNode.position = Location
        FinalNode.addChildNode(Node)
        FinalNode.addChildNode(BGNode)
        FinalNode.categoryBitMask = ControlLight
        FinalNode.StringTag = "ParentNode"
        return FinalNode
    }
    
    /// Add a text button with the passed text.
    /// - Parameter ForButton: The button type.
    /// - Parameter CodePoint: The text to use for the button
    /// - Parameter Font: The font to use. This function assumes the font is the system font.
    /// - Parameter Location: Where to place the button.
    /// - Parameter Color: The standard button color - used as the diffuse material color.
    /// - Parameter Highlight: The highlight button color.
    /// - Parameter ScaleFactor: Used to scale the button.
    func AddTextButton(ForButton: NodeButtons, _ Text: String, Font: UIFont, Location: SCNVector3,
                       Color: UIColor, Highlight: UIColor, ScaleFactor: Double = 0.1) -> SCNButtonNode
    {
        let SText = SCNText(string: Text, extrusionDepth: 2)
        SText.font = Font
        SText.flatness = 0
        SText.firstMaterial?.diffuse.contents = Color
        SText.firstMaterial?.specular.contents = UIColor.white
        let Node = SCNButtonNode(geometry: SText)
        Node.ButtonColor = Color
        Node.HighlightColor = Highlight
        Node.name = "\(ForButton)"
        Node.categoryBitMask = ControlLight
        Node.scale = SCNVector3(ScaleFactor, ScaleFactor, ScaleFactor)
        Node.StringTag = "ShapeNode"
        
        let SourceSize = GetNodeBoundingSize(Node)
        let BGBox = SCNBox(width: SourceSize.width, height: SourceSize.height, length: 0.001, chamferRadius: 0.0)
        BGBox.firstMaterial?.diffuse.contents = UIColor.clear
        BGBox.firstMaterial?.specular.contents = UIColor.clear
        let BGNode = SCNButtonNode(geometry: BGBox)
        let FinalWidth = SourceSize.width * 0.06
        let FinalHeight = SourceSize.height * 0.075
        BGNode.position = SCNVector3(FinalWidth, FinalHeight, -0.1)
        BGNode.scale = SCNVector3(ScaleFactor, ScaleFactor, ScaleFactor)
        BGNode.name = "\(ForButton)"
        BGNode.StringTag = "BackgroundNode"
        
        let FinalNode = SCNButtonNode()
        FinalNode.position = Location
        FinalNode.addChildNode(Node)
        FinalNode.addChildNode(BGNode)
        FinalNode.categoryBitMask = ControlLight
        FinalNode.StringTag = "ParentNode"
        return FinalNode
    }
    
    /// Make a in-scene motion button.
    /// - Parameter ForButton: Determines the button to create and add to the scene.
    func MakeButton(ForButton: NodeButtons)
    {
        var ButtonFont = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.bold)
        if let Descriptor = ButtonFont.fontDescriptor.withDesign(.rounded)
        {
            ButtonFont = UIFont(descriptor: Descriptor, size: 32.0)
        }
        var FinalNode: SCNButtonNode!
        switch ForButton
        {
            case .DownButton:
                FinalNode = AddUnicodeButton(ForButton: ForButton, 0x25bc, Font: ButtonFont,
                                             Location: ButtonDictionary[ForButton]!.Location,
                                             Color: ButtonDictionary[ForButton]!.Color,
                                             Highlight: ButtonDictionary[ForButton]!.Highlight,
                                             ScaleFactor: ButtonDictionary[ForButton]!.Scale)
            
            case .DropDownButton:
                FinalNode = AddUnicodeButton(ForButton: ForButton, 0x25bc, Font: ButtonFont,
                                             Location: ButtonDictionary[ForButton]!.Location,
                                             Color: ButtonDictionary[ForButton]!.Color,
                                             Highlight: ButtonDictionary[ForButton]!.Highlight,
                                             ScaleFactor: ButtonDictionary[ForButton]!.Scale)
            
            case .FlyAwayButton:
                FinalNode = AddUnicodeButton(ForButton: ForButton, 0x25b2, Font: ButtonFont,
                                             Location: ButtonDictionary[ForButton]!.Location,
                                             Color: ButtonDictionary[ForButton]!.Color,
                                             Highlight: ButtonDictionary[ForButton]!.Highlight,
                                             ScaleFactor: ButtonDictionary[ForButton]!.Scale)
            
            case .FreezeButton:
                FinalNode = AddTextButton(ForButton: ForButton, "❄︎", Font: ButtonFont,
                                          Location: ButtonDictionary[ForButton]!.Location,
                                          Color: ButtonDictionary[ForButton]!.Color,
                                          Highlight: ButtonDictionary[ForButton]!.Highlight,
                                          ScaleFactor: ButtonDictionary[ForButton]!.Scale)
            
            case .LeftButton:
                FinalNode = AddUnicodeButton(ForButton: ForButton, 0x25c0, Font: ButtonFont,
                                             Location: ButtonDictionary[ForButton]!.Location,
                                             Color: ButtonDictionary[ForButton]!.Color,
                                             Highlight: ButtonDictionary[ForButton]!.Highlight,
                                             ScaleFactor: ButtonDictionary[ForButton]!.Scale)
            
            case .RightButton:
                FinalNode = AddUnicodeButton(ForButton: ForButton, 0x25b6, Font: ButtonFont,
                                             Location: ButtonDictionary[ForButton]!.Location,
                                             Color: ButtonDictionary[ForButton]!.Color,
                                             Highlight: ButtonDictionary[ForButton]!.Highlight,
                                             ScaleFactor: ButtonDictionary[ForButton]!.Scale)
            
            case .RotateLeftButton:
                FinalNode = AddTextButton(ForButton: ForButton, "↺", Font: ButtonFont,
                                          Location: ButtonDictionary[ForButton]!.Location,
                                          Color: ButtonDictionary[ForButton]!.Color,
                                          Highlight: ButtonDictionary[ForButton]!.Highlight,
                                          ScaleFactor: ButtonDictionary[ForButton]!.Scale)
            
            case .RotateRightButton:
                FinalNode = AddTextButton(ForButton: ForButton, "↻", Font: ButtonFont,
                                          Location: ButtonDictionary[ForButton]!.Location,
                                          Color: ButtonDictionary[ForButton]!.Color,
                                          Highlight: ButtonDictionary[ForButton]!.Highlight,
                                          ScaleFactor: ButtonDictionary[ForButton]!.Scale)
            
            case .UpButton:
                FinalNode = AddUnicodeButton(ForButton: ForButton, 0x25b2, Font: ButtonFont,
                                             Location: ButtonDictionary[ForButton]!.Location,
                                             Color: ButtonDictionary[ForButton]!.Color,
                                             Highlight: ButtonDictionary[ForButton]!.Highlight,
                                             ScaleFactor: ButtonDictionary[ForButton]!.Scale)
            
            case .HeartButton:
                FinalNode = AddTextButton(ForButton: ForButton, "♥︎", Font: ButtonFont,
                                          Location: ButtonDictionary[ForButton]!.Location,
                                          Color: ButtonDictionary[ForButton]!.Color,
                                          Highlight: ButtonDictionary[ForButton]!.Highlight,
                                          ScaleFactor: ButtonDictionary[ForButton]!.Scale)
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
    
    /// Show game view controls.
    /// - Parameter Which: Array of buttons to show. If nil, all buttons are shown. Default is nil. Passing an empty array will
    ///                    remove all buttons.
    func ShowControls(With: [NodeButtons]? = nil)
    {
        //Remove all of the buttons first.
        for (_, Button) in ButtonList
        {
            if Button.ButtonType == .HeartButton
            {
                continue
            }
            Button.removeFromParentNode()
        }
        ButtonList.removeAll()
        
        if With == nil
        {
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
