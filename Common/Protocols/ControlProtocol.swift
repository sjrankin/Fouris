//
//  ControlProtocol.swift
//  WackyDesktopTetris
//
//  Created by Stuart Rankin on 4/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Control commands from the controller window.
///
/// - Note: Just because a command is sent does not mean the command can be executed.
protocol ControlProtocol: class
{
    /// Move the block left by one.
    func MoveLeft()
    
    /// Move the block right by one.
    func MoveRight()
    
    /// Move the block down by one.
    func MoveDown()
    
    /// Drop the block as far down as it can go.
    func DropDown()
    
    /// Move the block up by one.
    func MoveUp()
    
    /// Throw away the block.
    func MoveUpAndAway()
    
    /// Rotate the block left (counter-clockwise).
    func RotateLeft()
    
    /// Rotate the block right (clockwise).
    func RotateRight()
    
    /// Pause the game.
    func Pause()
    
    /// Resume the game after a pause.
    func Resume()
    
    /// Start a new game.
    func Play()
    
    /// Stop a current game.
    func Stop()
    
    // Freeze the piece where it is.
    func FreezeInPlace()
    
    /// Get or set the controller that implements the Control UI protocol.
    var Controller: ControlUIProtocol? {get set}
}
