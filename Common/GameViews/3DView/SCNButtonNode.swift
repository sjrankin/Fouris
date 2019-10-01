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
        print("From=\(ColorServer.MakeHexString(From: HighlightColor)), To=\(ColorServer.MakeHexString(From: ButtonColor))")
        print("Deltas: red=\(RDelta), green=\(GDelta), blue=\(BDelta)")
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
                print("Red=\(Red), Green=\(Green), Blue=\(Blue)")
                XNode.geometry?.firstMaterial?.diffuse.contents = UIColor(red: Red, green: Green, blue: Blue, alpha: 1.0)
        })
        let Wait = SCNAction.wait(duration: Delay)
        let Sequence = SCNAction.sequence([Wait, ColorChange])
        self.runAction(Sequence)
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
}
