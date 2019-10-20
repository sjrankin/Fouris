//
//  SCNButtonNode.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Wrapper around SCNNode to provide more context for buttons in the game view.
class SCNButtonNode: SCNNode
{
    /// Initializer.
    /// - Parameter TypeOfButton: The type of button we are.
    convenience init(_ TypeOfButton: NodeButtons)
    {
        self.init()
        _ButtonType = TypeOfButton
    }
    
    /// Default initializer.
    override init()
    {
        super.init()
    }
    
    /// Initializer.
    /// - Parameter geometry: The geometry of the node.
    init(geometry: SCNGeometry?)
    {
        super.init()
        self.geometry = geometry
    }
    
    /// Initializer.
    /// - Parameter geometry: The geometry of the node.
    /// - Parameter TypeOfButton: The type of button we are.
    init(geometry: SCNGeometry?, _ TypeOfButton: NodeButtons)
    {
        super.init()
        self.geometry = geometry
        _ButtonType = TypeOfButton
    }
    
    /// Initializer.
    /// - Parameter geometry: The geometry of the node.
    /// - Parameter TypeOfButton: The type of button we are.
    /// - Parameter ButtonColor: The color of the diffuse surface of the button. Not used until one of the highlight functions
    ///                          is called.
    init(geometry: SCNGeometry?, _ TypeOfButton: NodeButtons, ButtonColor: UIColor = UIColor.white)
    {
        super.init()
        self.geometry = geometry
        _ButtonType = TypeOfButton
        _ButtonColor = ButtonColor
    }
    
    /// Initializer.
    /// - Parameter geometry: The geometry of the node.
    /// - Parameter TypeOfButton: The type of button we are.
    /// - Parameter ButtonColor: The color of the diffuse surface of the button. Not used until one of the highlight functions
    ///                          is called.
    /// - Parameter HighlightColor: The color of a highlighted button (set to the diffuse surface). Not used until one of the
    ///                             highlight functions is called.
    init(geometry: SCNGeometry?, _ TypeOfButton: NodeButtons, ButtonColor: UIColor = UIColor.white,
         HighlightColor: UIColor = UIColor.yellow)
    {
        super.init()
        self.geometry = geometry
        _ButtonType = TypeOfButton
        _ButtonColor = ButtonColor
        _HighlightColor = HighlightColor
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Holds the default button color.
    private var _ButtonColor: UIColor = UIColor.white
    {
        didSet
        {
            self.geometry?.firstMaterial?.diffuse.contents = _ButtonColor
        }
    }
    /// Get or set the default button color.
    public var ButtonColor: UIColor
    {
        get
        {
            return _ButtonColor
        }
        set
        {
            _ButtonColor = newValue
        }
    }
    
    /// Holds the highlight color.
    private var _HighlightColor: UIColor = UIColor.yellow
    /// Get or set the highlight color.
    public var HighlightColor: UIColor
    {
        get
        {
            return _HighlightColor
        }
        set
        {
            _HighlightColor = newValue
        }
    }
    
    /// Holds the button type.
    private var _ButtonType: NodeButtons = .DownButton
    /// Get or set the button type.
    public var ButtonType: NodeButtons
    {
        get
        {
            return _ButtonType
        }
        set
        {
            _ButtonType = newValue
        }
    }
    
    /// Holds a tag value.
    private var _Tag: Any? = nil
    /// Get or set the tag value.
    public var Tag: Any?
    {
        get
        {
            return _Tag
        }
        set
        {
            _Tag = newValue
        }
    }
    
    /// Holds the string tag value.
    private var _StringTag: String = ""
    /// Get or set the string tag value.
    public var StringTag: String
    {
        get
        {
            return _StringTag
        }
        set
        {
            _StringTag = newValue
        }
    }
    
    /// Sets the button color to the specified color. Takes effect immediately.
    /// - Note: Will be overwritten if the caller calls `ButtonColor` or the other `SetButtonColor` functions.
    /// - Parameter NewColor: The color to set the geometry to.
    public func SetButtonColor(NewColor: UIColor)
    {
        self.geometry?.firstMaterial?.diffuse.contents = NewColor
    }
    
    /// Sets the button color to the specified color and resets the color after a specified amount of time.
    /// - Note:
    ///   - The total time from start to finish is `ResetDuration + Delay`.
    ///   - This function can change color from `NewColor` to `ResetColor` with no in-between colors by setting `ResetDuration`
    ///     to a very small value (or `0`) and `Delay` to how long to keep the `NewColor` in place.
    /// - Parameter NewColor: The color to use to draw the diffuse surface of the button.
    /// - Parameter ResetColor: The color to change to over a period of time. Assumed to be (not not necessary to be) the same
    ///                         as the `HighlightColor`.
    /// - Parameter ResetDuration: Amount of time for the color to change from `NewColor` to `ResetColor`, in seconds.
    /// - Parameter Delay: The amount of time to wait before changing the color.
    public func SetButtonColor(NewColor: UIColor, ResetColor: UIColor, ResetDuration: Double, Delay: Double = 0.15)
    {
        self.geometry?.firstMaterial?.diffuse.contents = NewColor
        let Duration = CGFloat(ResetDuration)
        //https://stackoverflow.com/questions/40472524/how-to-add-animations-to-change-sncnodes-color-scenekit/40473393
        let RDelta = NewColor.r - ResetColor.r
        let GDelta = NewColor.g - ResetColor.g
        let BDelta = NewColor.b - ResetColor.b
        let ColorChange = SCNAction.customAction(duration: ResetDuration,
                                                 action:
            {
                (XNode, Time) in
                let Percent: CGFloat = Time / CGFloat(Duration)
                let Red = abs(NewColor.r + (RDelta * Percent))
                let Green = abs(NewColor.g + (GDelta * Percent))
                let Blue = abs(NewColor.b + (BDelta * Percent))
                XNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: Red, green: Green, blue: Blue, alpha: 1.0)
        })
        let Wait = SCNAction.wait(duration: Delay)
        let Sequence = SCNAction.sequence([Wait, ColorChange])
        self.runAction(Sequence)
    }
    
    /// Sets the button color to the specified color and resets the color after a specified amount of time.
    /// - Note:
    ///   - The total time from start to finish is `ResetDuration + Delay`.
    ///   - This function can change color from `NewColor` to `HighlightColor` with no in-between colors by setting `ResetDuration`
    ///     to a very small value (or `0`) and `Delay` to how long to keep the `NewColor` in place.
    ///   - This function will use the default `HighlightColor` value unless it has been set to a different color.
    /// - Parameter NewColor: The color to use to draw the diffuse surface of the button.
    /// - Parameter ResetDuration: Amount of time for the color to change from `NewColor` to `HighlightColor`, in seconds.
    /// - Parameter Delay: The amount of time to wait before changing the color.
    public func SetColorButton(Highlight: UIColor, ResetDuration: Double, Delay: Double = 0.15)
    {
        self.geometry?.firstMaterial?.diffuse.contents = Highlight
        let Duration = CGFloat(ResetDuration)
        //https://stackoverflow.com/questions/40472524/how-to-add-animations-to-change-sncnodes-color-scenekit/40473393
        let RDelta = Highlight.r - ButtonColor.r
        let GDelta = Highlight.g - ButtonColor.g
        let BDelta = Highlight.b - ButtonColor.b
        let ColorChange = SCNAction.customAction(duration: ResetDuration,
                                                 action:
            {
                (XNode, Time) in
                let Percent: CGFloat = Time / CGFloat(Duration)
                let Red = abs(Highlight.r + (RDelta * Percent))
                let Green = abs(Highlight.g + (GDelta * Percent))
                let Blue = abs(Highlight.b + (BDelta * Percent))
                XNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: Red, green: Green, blue: Blue, alpha: 1.0)
        })
        let Wait = SCNAction.wait(duration: Delay)
        let Sequence = SCNAction.sequence([Wait, ColorChange])
        self.runAction(Sequence)
    }
    
    /// Sets the button color to the specified color and resets the color after a specified amount of time. This function uses the
    /// properties `ButtonColor` and `HighlightColor` as the source for the colors.
    /// - Note:
    ///   - The total time from start to finish is `ResetDuration + Delay`.
    ///   - This function can change color from `ButtonColor` to `HighlightColor` with no in-between colors by setting `ResetDuration`
    ///     to a very small value (or `0`) and `Delay` to how long to keep the `Button` in place.
    /// - Parameter ResetDuration: Amount of time for the color to change from `ButtonColor` to `HighlightColor`, in seconds.
    /// - Parameter Delay: The amount of time to wait before changing the color.
    public func HighlightButton(ResetDuration: Double, Delay: Double = 0.15)
    {
        self.geometry?.firstMaterial?.diffuse.contents = HighlightColor
        let Duration = CGFloat(ResetDuration)
        //https://stackoverflow.com/questions/40472524/how-to-add-animations-to-change-sncnodes-color-scenekit/40473393
        let RDelta = HighlightColor.r - ButtonColor.r
        let GDelta = HighlightColor.g - ButtonColor.g
        let BDelta = HighlightColor.b - ButtonColor.b
        //print("From=\(ColorServer.MakeHexString(From: HighlightColor)), To=\(ColorServer.MakeHexString(From: ButtonColor))")
        //print("Deltas: red=\(RDelta), green=\(GDelta), blue=\(BDelta)")
        let ColorChange = SCNAction.customAction(duration: ResetDuration,
                                                 action:
            {
                (XNode, Time) in
                let Percent: CGFloat = Time / CGFloat(Duration)
                var Red = self.HighlightColor.r + (RDelta * Percent)
                if RDelta < 0.0
                {
                    Red = abs(Red)
                }
                var Green = self.HighlightColor.g + (GDelta * Percent)
                if GDelta < 0.0
                {
                    Green = abs(Green)
                }
                var Blue = self.HighlightColor.b + (BDelta * Percent)
                if BDelta < 0.0
                {
                    Blue = abs(Blue)
                }
                //print("Red=\(Red), Green=\(Green), Blue=\(Blue)")
                XNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: Red, green: Green, blue: Blue, alpha: 1.0)
        })
        let Wait = SCNAction.wait(duration: Delay)
        let Sequence = SCNAction.sequence([Wait, ColorChange])
        self.runAction(Sequence)
    }
    
    /// Flash the button for the specified amount of time.
    /// - Note:
    ///   - The flash color is the `HighlightColor`. Once the duration has expired, the original
    ///     button color will be shown.
    ///   - No color transitions are performed.
    /// - Parameter FlashDuration: Number of seconds to flash the button. Defaults to 0.15 seconds.
    public func Flash(FlashDuration: Double = 0.15)
    {
        self.geometry?.firstMaterial?.diffuse.contents = HighlightColor
        DispatchQueue.main.asyncAfter(deadline: .now() + FlashDuration,
                                      execute:
            {
                self.geometry?.firstMaterial?.diffuse.contents = self.ButtonColor
        })
    }
    
    /// Flash the button for the specified amount of time.
    /// - Note:
    ///   - Once the duration has expired, the original button color will be shown.
    ///   - No color transitions are performed.
    /// - Parameter WithColor: The color to use to indicate the button is being flashed/highlighted.
    /// - Parameter FlashDuration: Number of seconds to flash the button. Defaults to 0.15 seconds.
    public func Flash(WithColor: UIColor, FlashDuration: Double = 0.15)
    {
        self.geometry?.firstMaterial?.diffuse.contents = WithColor
        DispatchQueue.main.asyncAfter(deadline: .now() + FlashDuration,
                                      execute:
            {
                self.geometry?.firstMaterial?.diffuse.contents = self.ButtonColor
        })
    }
    
    /// Find a child node of this node with the specified `StringTag` value.
    /// - Parameter Value: The value of the child node's `StringTag` property to look for.
    /// - Returns: First child node shows `StringTag` value is the same as `Value`. If none found, nil is returned.
    public func GetNodeWithTag(Value: String) -> SCNButtonNode?
    {
        var FoundNode: SCNButtonNode? = nil
        self.enumerateChildNodes(
            {
                (Node, _) in
                if let ChildNode = Node as? SCNButtonNode
                {
                    if ChildNode.StringTag == Value
                    {
                        FoundNode = ChildNode
                    }
                }
        })
        return FoundNode
    }
    
    /// Sets the color of the background node.
    /// - Note:
    ///   - Intended for debug use.
    ///   - The background node is the node that lets the user press in visual gaps of the button but still have the touch
    ///     registered as a press.
    /// - Parameter Diffuse: The diffuse color to use.
    /// - Parameter Specular: The specular color to use. Defaults to `UIColor.white`.
    public func SetBackgroundColor(Diffuse: UIColor, Specular: UIColor = UIColor.white)
    {
        enumerateChildNodes(
            {
                Node, _ in
                if let ButtonNode = Node as? SCNButtonNode
                {
                    if ButtonNode.StringTag == "BackgroundNode"
                    {
                        ButtonNode.geometry?.firstMaterial?.diffuse.contents = Diffuse
                        ButtonNode.geometry?.firstMaterial?.specular.contents = Specular
                    }
                }
            }
        )
    }
    
    // MARK: Static functions.
    
    /// Returns the bounding size of the passed node.
    /// - Parameter Node: The SCNNode whose bounding size will be returned.
    /// - Returns: Bounding size of the passed SCNNode.
    public static func GetNodeBoundingSize(_ Node: SCNNode) -> CGSize
    {
        let BoundingSize = Node.boundingBox
        let XSize = Double(BoundingSize.max.x - BoundingSize.min.x)
        let YSize = Double(BoundingSize.max.y - BoundingSize.min.y)
        return CGSize(width: XSize, height: YSize)
    }
    
    /// Create a button node with the passed source node.
    /// - Parameter ForButton: The butotn type.
    /// - Parameter SourceNode: The node to add to the button.
    /// - Parameter Location: Where to place the button.
    /// - Parameter ScaleFactor: Used to scale the button.
    /// - Parameter LightMask: The mask to use on the node that determines which light to use.
    public static func AddObjectButton(ForButton: NodeButtons, SourceNode: SCNNode, Location: SCNVector3,
                                       ScaleFactor: Double = 0.1, LightMask: Int) -> SCNButtonNode
    {
        let Node = SCNButtonNode()
        Node.name = "ShapeNode"
        Node.ButtonType = ForButton
        Node.addChildNode(SourceNode)
        
        let SourceSize = GetNodeBoundingSize(SourceNode)
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
        BGNode.ButtonType = ForButton
        BGNode.categoryBitMask = LightMask
        
        let FinalNode = SCNButtonNode()
        FinalNode.position = Location
        FinalNode.addChildNode(Node)
        FinalNode.addChildNode(BGNode)
        FinalNode.categoryBitMask = LightMask
        FinalNode.StringTag = "ParentNode"
        FinalNode.ButtonType = ForButton
        return FinalNode
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
    /// - Parameter LightMask: The mask to use on the node that determines which light to use.
    /// - Parameter Depth: Extrustion depth. Defaults to 2.0.
    public static func AddUnicodeButton(ForButton: NodeButtons, _ CodePoint: Int, Font: UIFont, Location: SCNVector3,
                                        Color: UIColor, Highlight: UIColor, ScaleFactor: Double = 0.1, LightMask: Int,
                                        Depth: CGFloat = 2.0) -> SCNButtonNode
    {
        let UnicodeChar = UnicodeScalar(CodePoint)
        let UnicodeString = "\((UnicodeChar)!)"
        let SText = SCNText(string: UnicodeString, extrusionDepth: Depth)
        SText.font = Font
        SText.flatness = 0
        SText.firstMaterial?.diffuse.contents = Color
        SText.firstMaterial?.specular.contents = UIColor.white
        let Node = SCNButtonNode(geometry: SText)
        Node.ButtonColor = Color
        Node.HighlightColor = Highlight
        Node.name = "\(ForButton)"
        Node.categoryBitMask = LightMask
        Node.scale = SCNVector3(ScaleFactor, ScaleFactor, ScaleFactor)
        Node.StringTag = "ShapeNode"
        Node.ButtonType = ForButton
        
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
        BGNode.ButtonType = ForButton
        
        let FinalNode = SCNButtonNode()
        FinalNode.position = Location
        FinalNode.addChildNode(Node)
        FinalNode.addChildNode(BGNode)
        FinalNode.categoryBitMask = LightMask
        FinalNode.StringTag = "ParentNode"
        FinalNode.ButtonType = ForButton
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
    /// - Parameter LightMask: The mask to use on the node that determines which light to use.
    /// - Parameter Depth: Extrustion depth. Defaults to 2.0.
    public static func AddTextButton(ForButton: NodeButtons, _ Text: String, Font: UIFont, Location: SCNVector3,
                                     Color: UIColor, Highlight: UIColor, ScaleFactor: Double = 0.1, LightMask: Int,
                                     Depth: CGFloat = 2.0) -> SCNButtonNode
    {
        let SText = SCNText(string: Text, extrusionDepth: Depth)
        SText.font = Font
        SText.flatness = 0
        SText.firstMaterial?.diffuse.contents = Color
        SText.firstMaterial?.specular.contents = UIColor.white
        let Node = SCNButtonNode(geometry: SText)
        Node.ButtonColor = Color
        Node.HighlightColor = Highlight
        Node.name = "\(ForButton)"
        Node.categoryBitMask = LightMask
        Node.scale = SCNVector3(ScaleFactor, ScaleFactor, ScaleFactor)
        Node.StringTag = "ShapeNode"
        Node.ButtonType = ForButton
        
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
        BGNode.ButtonType = ForButton
        
        let FinalNode = SCNButtonNode()
        FinalNode.position = Location
        FinalNode.addChildNode(Node)
        FinalNode.addChildNode(BGNode)
        FinalNode.categoryBitMask = LightMask
        FinalNode.StringTag = "ParentNode"
        FinalNode.ButtonType = ForButton
        return FinalNode
    }
}
