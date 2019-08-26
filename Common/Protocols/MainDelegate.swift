//
//  File.swift
//  WackyDesktopTetris
//
//  Created by Stuart Rankin on 4/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol MainDelegate: class
{
    func GetAIData() -> AITestTable?
    func SetNewUser(_ UserID: UUID)
}
