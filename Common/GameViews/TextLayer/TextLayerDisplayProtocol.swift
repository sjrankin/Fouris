//
//  TextLayerDisplayProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol TextLayerDisplayProtocol: class
{
    /// Sets the controls to use to display text. Text is an attributed string displayed in a CATextLayer, so each text object
    /// needs to reside in a view Those views are passed in this function.
    /// - Parameter NextLabel: Container for the "Next" label.
    /// - Parameter NextPieceView: Container for the next game piece.
    /// - Parameter ScoreLabel: Container for the "Score" label.
    /// - Parameter CurrentScoreLabel: Container for the current score label.
    /// - Parameter HighScoreLabel: Container for the high score label.
    /// - Parameter GameOverLabel: Container for the "Game Over" label.
    /// - Parameter PressPlayLabel: Container for the "Press Play" label.
    /// - Parameter PauseLabel: Container for the "Pause" label.
    func SetControls(NextLabel: UIView?,
                     NextPieceView: UIView?,
                     ScoreLabel: UIView?,
                     CurrentScoreLabel: UIView?,
                     HighScoreLabel: UIView?,
                     GameOverLabel: UIView?,
                     PressPlayLabel: UIView?,
                     PauseLabel: UIView?)
    
    /// Show the next label. This is the "Next" string over the view of the next piece.
    /// - Parameter Duration: The number of seconds to fade in the text.
    func ShowNextLabel(Duration: Double?)
    
    /// Hide the next label. This is the "Next" string over the view of the next piece.
    /// - Parameter Duration: The number of seconds to fade out the text.
    func HideNextLabel(Duration: Double?)
    
    /// Show the score label. This is the "Score" string next to the actual score values.
    /// - Parameter Duration: The number of seconds to fade in the text.
    func ShowScoreLabel(Duration: Double?)
    
    /// Hide the score label. This is the "Score" string next to the actual score values.
    /// - Parameter Duration: The number of seconds to fade out the text.
    func HideScoreLabel(Duration: Double?)
    
    /// Show the next piece (after the current piece).
    /// - Parameter NextPiece: The next piece to show. Visualized by **PieceFactory**.
    /// - Parameter Duration: The number of seconds to fade in the image of the next piece.
    /// - Parameter AddShadow: If true, a shadow is added to the next piece. Defaults to true.
    func ShowNextPiece(_ NextPiece: Piece, Duration: Double?, AddShadow: Bool)
    
    /// Hide the next piece.
    /// - Parameter Duration: The number of seconds to fade out the image of the next piece.
    func HideNextPiece(Duration: Double?)
    
    /// Show the current score. Assumes the score label is visible.
    /// - Note: Score text layers are generated each time this function is called (because it doesn't make sense to cache
    ///         changeable text).
    /// - Parameter NewScore: Score to display.
    func ShowCurrentScore(NewScore: Int)
    
    /// Hide the current score value.
    func HideCurrentScore()
    
    /// Show the high score. Assumes the score label is visible.
    /// - Note: Score text layers are generated each time this function is called (because it doesn't make sense to cache
    ///         changeable text).
    /// - Parameter NewScore: High score to display.
    /// - Parameter Highlight: Determines if the text color is highlighted. Default is false.
    /// - Parameter HighlightColor: The color to use to highlight the text.
    /// - Parameter HighlightDuration: The duration of the highlight.
    func ShowHighScore(NewScore: Int, Highlight: Bool, HighlightColor: ColorNames, HighlightDuration: Double)
    
    /// Hide the high score.
    func HideHighScore()
    
    /// Show the "Pause" text.
    /// - Parameter Duration: The number of seconds to fade in the "Pause" text.
    func ShowPause(Duration: Double?)
    
    /// Hide the "Pause" text.
    /// - Parameter Duration: The number of seconds to fade out the "Pause" text.
    func HidePause(Duration: Double?)
    
    /// Show the "Press Play to Start" text.
    /// - Parameter Duration: The number of seconds to fade in the text.
    func ShowPressPlay(Duration: Double?)
    
    /// Hide the "Pres Play to Start" text.
    /// - Parameter Duration: The number of seconds to fade out the text.
    func HidePressPlay(Duration: Double?)
    
    /// Show the "Game Over" text.
    /// - Parameter Duration: Number of seconds to fade in the text.
    /// - Parameter HideAfter: Number of seconds to wait before automatically hiding the text. If nil, the text will not be
    ///                        automatically hidden. Default is nil.
    func ShowGameOver(Duration: Double?, HideAfter: Double?)
    
    /// Hide the "Game Over" text.
    /// - Parameter Duration: Number of seconds to fade out the "Game Over" text.
    /// - Parameter MovePressPlay: If true, the press play container is moved to its original location.
    func HideGameOver(Duration: Double?, MovePressPlay: Bool)
}

/// Types of label containers managed by this class.
/// - **NextLabel**: The "Next" label.
/// - **NextPiece**: The next piece to play.
/// - **ScoreLabel**: The "Score" label.
/// - **CurrentScore**: The current score value.
/// - **HighScore**: The high score value.
/// - **PressPlay**: The "Press Play to Start" label.
/// - **GameOver**: The "Game Over" label.
/// - **Paused**: The "Pause" label.
enum ContainerTypes: String, CaseIterable
{
    case NextLabel = "NextLabel"
    case NextPiece = "NextPiece"
    case ScoreLabel = "ScoreLabel"
    case CurrentScore = "CurrentScore"
    case HighScore = "HighScore"
    case PressPlay = "PressPlay"
    case GameOver = "GameOver"
    case Paused = "Paused"
}

/// Types of effects that can be applied to containers.
/// - Note: Effects are mutually exclusive.
/// - **None**: No effect.
/// - **Shadow**: Shadow effect.
/// - **Glow**: Glow effect.
enum ContainerEffects: String, CaseIterable
{
    case None = "None"
    case Shadow = "Shadow"
    case Glow = "Glow"
}
