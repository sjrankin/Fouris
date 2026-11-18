//
//  GradientObserver.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/12/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol to observe changes in gradients.
protocol GradientObserver: AnyObject
{
    /// Called when a gradient is changed.
    /// - Parameter NewGradient: The new gradient definition.
    func GradientChanged(NewGradient: String)
}
