//
//  ThreeDProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/13/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit

/// Protocol for debugging View3D objects.
protocol ThreeDProtocol: class
{
    /// Set camera data.
    /// - Parameter FOV: New field of view.
    /// - Parameter Position: New camera position.
    /// - Parameter Orientation: New camera orientation.
    func SetCameraData(FOV: CGFloat, Position: SCNVector3, Orientation: SCNVector4)
    
    /// Return camera data.
    /// - Returns: Tuple with the field of view, position, and orientation.
    func GetCameraData() -> (CGFloat, SCNVector3, SCNVector4)
    
    /// Set the main game light.
    /// - Parameter Position: Position of the light.
    /// - Parameter LightingType: Type of light.
    /// - Parameter ColorName: Name of the light color.
    /// - Parameter UseDefault: Use default light.
    func SetLightData(Position: SCNVector3, LightingType: SCNLight.LightType, ColorName: String,
                      UseDefault: Bool)
    
    /// Returns game light information.
    /// - Returns: Tuple with the position, light type, color name, and use default camera flag.
    func GetLightData() -> (SCNVector3, SCNLight.LightType, String, Bool)
}
