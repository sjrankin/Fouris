//
//  AITestDataUpdatedProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for notifying other classes when the AITestTable class has new data.
protocol AITestDataUpdatedProtocol: class
{
    /// Called when the AI Test Table has new data.
    func DataUpdated()
}


