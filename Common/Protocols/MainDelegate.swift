//
//  File.swift
//  WackyDesktopTetris
//
//  Created by Stuart Rankin on 4/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol to communicate with the main class.
protocol MainDelegate: class
{
    /// Returns AI test data.
    func GetAIData() -> AITestTable?
    
    /// Not currently used.
    func SetNewUser(_ UserID: UUID)
    
    /// Not currently used.
    func GetUserTheme() -> ThemeDescriptor2?
    
    /// Called when the initial version box disappears.
    func VersionBoxDisappeared()
}
