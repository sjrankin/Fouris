//
//  SCNGameText.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/20/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

/// Extends (slightly) the `SCNNode` class to wrap text to make displaying message in the game view more efficient.
class SCNGameText: SCNNode
{
    /// Initializer.
    /// - Parameter SourceGeometry: Source geometry for the node. Assumed to be created from an `SCNText` object.
    init(SourceGeometry: SCNGeometry)
    {
        super.init()
        self.geometry = SourceGeometry
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    public func ChangeText(To NewText: String, With Depth: CGFloat, TextColor: UIColor,
                           Specular: UIColor, Font: UIFont)
    {
        let TextGeo = SCNText(string: NewText, extrusionDepth: Depth)
        TextGeo.font = Font
        TextGeo.firstMaterial?.diffuse.contents = TextColor
        TextGeo.firstMaterial?.specular.contents = Specular
        TextGeo.flatness = 0.0
        self.geometry = TextGeo
    }
    
    public func ChangeTextEx(To NewText: NSAttributedString, With Depth: CGFloat, Specular: UIColor)
    {
        let TextGeo = SCNText(string: NewText, extrusionDepth: Depth)
        TextGeo.firstMaterial?.specular.contents = Specular
        TextGeo.flatness = 0.0
        self.geometry = TextGeo
    }
    
    public static func MakeGameText(_ SourceText: String, Font: UIFont, TextColor: UIColor = UIColor.white,
                                    Specular: UIColor = UIColor.white, Scale: CGFloat, Depth: CGFloat,
                                    Location: SCNVector3, LightMask: Int) -> SCNGameText
    {
        let TextGeo = SCNText(string: SourceText, extrusionDepth: Depth)
        TextGeo.font = Font
        TextGeo.firstMaterial?.diffuse.contents = TextColor
        TextGeo.firstMaterial?.specular.contents = Specular
        TextGeo.flatness = 0.0
        let Node = SCNGameText(SourceGeometry: TextGeo)
        Node.position = Location
        Node.categoryBitMask = LightMask
        Node.scale = SCNVector3(Scale, Scale, Scale)
        return Node
    }
    
    public static func MakeGameText(_ SourceText: NSAttributedString, Specular: UIColor = UIColor.white,
                                    Scale: CGFloat, Depth: CGFloat, Location: SCNVector3,
                                    LightMask: Int) -> SCNGameText
    {
        let TextGeo = SCNText(string: SourceText, extrusionDepth: Depth)
        TextGeo.firstMaterial?.specular.contents = Specular
        TextGeo.flatness = 0.0
        let Node = SCNGameText(SourceGeometry: TextGeo)
        Node.position = Location
        Node.categoryBitMask = LightMask
        Node.scale = SCNVector3(Scale, Scale, Scale)
        return Node
    }
    
    /// Create an attributed string.
    /// - Note: Attributes will be applied to the entire string.
    /// - Parameter RawText: The textual part of the attributed string.
    /// - Parameter Font: The font to use to generate the string.
    /// - Parameter Foreground: The text color.
    /// - Parameter Background: The background color. Defaults to `UIColor.clear`.
    /// - Parameter StrokeWidth: The width of the stroke. Internally changes this value to a positive value. If the result is `0.0`
    ///                          or lower, no strokes will be drawn.
    /// - Parameter StrokeColor: The color of the stroke.
    /// - Parameter HasShadow: If true, a shadow is added to the text. If false, no shadow is added. Default is `false`.
    public static func MakeAttributedString(_ RawText: String, Font: UIFont, Foreground: UIColor, Background: UIColor = UIColor.clear,
                                            StrokeWidth: Double, StrokeColor: UIColor, HasShadow: Bool = false) -> NSAttributedString
    {
        var Attributes = [NSAttributedString.Key: Any]()
        Attributes[.font] = Font as Any
        Attributes[.foregroundColor] = Foreground as Any
        Attributes[.backgroundColor] = Background as Any
        if abs(StrokeWidth) > 0.0
        {
        Attributes[.strokeColor] = StrokeColor as Any
        Attributes[.strokeWidth] = -abs(StrokeWidth)
        }
        if HasShadow
        {
            let Shadow = NSShadow()
            Shadow.shadowColor = UIColor.black.withAlphaComponent(0.5)
            Shadow.shadowOffset = CGSize(width: 5.0, height: 5.0)
            Shadow.shadowBlurRadius = 5.0
            Attributes[.shadow] = Shadow as Any
        }
        let AString = NSAttributedString(string: RawText, attributes: Attributes)
        return AString
    }
}
