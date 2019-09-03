//
//  GradientPickerProtocol.swift
//  Fouris
//  Adapted from BumpCamera.
//
//  Created by Stuart Rankin on 9/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol GradientPickerProtocol: class
{
    func EditedGradient(_ Edited: String?, Tag: Any?)
    
    func GradientToEdit(_ Edited: String?, Tag: Any?)
    
    func SetStop(StopColorIndex: Int)
}
