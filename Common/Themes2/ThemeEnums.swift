//
//  ThemeEnums.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/17/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

enum LightTypes: String, CaseIterable
{
    case Ambient = "Ambient"
    case Directional = "Directional"
    case Omni = "Omni"
    case Spot = "Spot"
}

enum CameraLocations: String, CaseIterable
{
    case Rear = "Rear"
    case Front = "Front"
}
