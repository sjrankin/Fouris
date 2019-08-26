//
//  ControlUIProtocol.swift
//  WackyDesktopTetris
//
//  Created by Stuart Rankin on 4/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol to control some aspects of the UI of the controller window.
protocol ControlUIProtocol: class
{
    /// Handle game over events.
    ///
    /// - Parameters:
    ///   - FinalScore: Final game score.
    ///   - HighScore: Final high score.
    func GameOver(FinalScore: Int, HighScore: Int)
    
    /// Sets the next piece.
    ///
    /// - Parameter NextPiece: The next piece to play.
    func SetNextPiece(NextPiece: Piece)
    
    /// New high score value.
    ///
    /// - Parameter NewHighScore: The new high score.
    func SetHighScore(NewHighScore: Int)
    
    /// New game score value.
    ///
    /// - Parameter NewGameScore: The new game score.
    func SetGameScore(NewGameScore: Int)
    
    /// Shows and stars the visual indicator to the next game.
    ///
    /// - Parameter Seconds: Number of seconds between game over and the start of the new game.
    func StartNewGameIn(Seconds: Double)
    
    /// Enable all of the buttons in the passed button list. By implication, if the button is
    /// not in this list, it will be disabled.
    ///
    /// - Parameter EnableList: List of buttons to enable.
    func EnableButtons(EnableList: [EnableButtons])
    
    /// Called when the app is terminating.
    func AppTerminating()
}

/// List of buttons that may be enabled or disabled, depending on the game level, debug
/// level, etc.
///
/// - LeftButton: Move left button.
/// - RightButton: Move right button.
/// - DownButton: Move down button.
/// - DropButton: Drop block button.
/// - UpButton: Move up button.
/// - UpAndAwayButton: Move up and throw away button.
/// - RotateLeftButton: Rotate left button.
/// - RotateRightButton: Rotate right button.
enum EnableButtons: Int, CaseIterable
{
    case LeftButton = 100
    case RightButton = 101
    case DownButton = 102
    case DropButton = 103
    case UpButton = 104
    case UpAndAwayButton = 105
    case RotateLeftButton = 106
    case RotateRightButton = 107
}
