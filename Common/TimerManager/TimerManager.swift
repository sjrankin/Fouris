//
//  File.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/13/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages timers.
class TimerManager
{
    /// Create a timer.
    /// - Returns: ID of a timer.
    func CreateTimer() -> UUID
    {
        let TimerID = UUID()
        return TimerID
    }
}
