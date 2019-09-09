//
//  GameAINotificationProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/12/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol to handle AI events.
protocol GameAINotificationProtocol: class
{
    /// AI is moving a piece upwards.
    func AI_MoveUp()
    
    /// AI is throwing a piece away.
    func AI_MoveUpAndAway()
    
    /// AI is moving a piece downwards.
    func AI_MoveDown()
    
    /// AI is dropping a piece downwards.
    func AI_DropDown()
    
    /// AI is moving a piece to the left.
    func AI_MoveLeft()
    
    /// AI is moving a piece to the right.
    func AI_MoveRight()
    
    /// AI is rotating a piece clockwise.
    func AI_RotateRight()
    
    /// AI is rotating a piece counter-clockwise.
    func AI_RotateLeft()
    
    /// AI froze a piece into place.
    func AI_FreezeInPlace()
}
