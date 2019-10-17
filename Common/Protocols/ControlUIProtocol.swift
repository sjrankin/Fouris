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
    
    /// Called when the app is terminating.
    func AppTerminating()
}


