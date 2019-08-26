//
//  TextLayerProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/20/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for the text layer to communicate with other classes.
protocol TextLayerProtocol: class
{
    /// Called when the text layer detects a double click.
    /// - Parameter At: The point where the double-click was detected in the text layer.
    func MouseDoubleClick(At: CGPoint)
}
