//
//  ThreeDProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/13/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit

protocol ThreeDProtocol: class
{
    func SetCameraData(FOV: CGFloat, Position: SCNVector3, Orientation: SCNVector4)
    func GetCameraData() -> (CGFloat, SCNVector3, SCNVector4)
    func SetLightData(Position: SCNVector3, LightingType: SCNLight.LightType, ColorName: String,
                      UseDefault: Bool)
    func GetLightData() -> (SCNVector3, SCNLight.LightType, String, Bool)
}
