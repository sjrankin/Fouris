//
//  StepperHelper.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/13/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol that should be implemented by the main UI class to display stepper information.
protocol StepperHelper: class
{
    /// Display information from a step. Control should not return until the user dismisses the UI element.
    /// - Parameter From: String describing where the step occurred.
    /// - Parameter Message: String from the step caller.
    /// - Parameter Stepped: Catagory of the step.
    func DisplayStep(From: String, Message: String, Stepped: Steps)
}
