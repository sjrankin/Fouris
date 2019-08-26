//
//  GameViewRequestProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/13/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Communication from a game view to the owning controller.
protocol GameViewRequestProtocol: class
{
    /// The game view requests a redraw.
    func NeedRedraw()
    
    /// Called when a smooth motion is completed.
    /// - Parameter For: The ID of the piece that moved smoothly.
    func SmoothMoveCompleted(For: UUID)
    
    /// Called when a smooth rotation is completed.
    /// - Parameter For: The ID of the piece that rotated smoothly.
    func SmoothRotationCompleted(For: UUID)
    
    /// Called by a client to tell the main program to send a KVP to TDebug.
    /// - Parameter Name: The key name.
    /// - Parameter Value: The value to display.
    /// - Parameter ID: The ID of the KVP.
    func SendKVP(Name: String, Value: String, ID: UUID)
    
    /// Called by the game view when it wants to let the UI know the current performance.
    func PerformanceSample(FPS: Double)
}
