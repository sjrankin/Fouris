//
//  GameUINotificationProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/10/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Provides notifications of events from the abstract game engine to the concrete UI.
protocol GameUINotificationProtocol: class
{
    /// Called for game state changes.
    /// - Parameter NewState: New game state.
    func GameStateChanged(NewState: GameStates)
    
    /// Called every time the map is updated.
    func MapUpdated()
    
    /// Called every time an active piece's location changes.
    func PieceUpdated(_ ThePiece: Piece)
    
    /// Called when a piece is successfully moved.
    /// - Parameters:
    ///   - MovedPiece: The piece that moved.
    ///   - Direction: The direction the piece moved.
    ///   - Commanded: True if the piece was commanded to move, false if gravity caused the movement.
    func PieceMoved(_ MovedPiece: Piece, Direction: Directions, Commanded: Bool)
    
    /// Called when a piece is successfully moved when running a 3D game.
    /// - Parameters:
    ///   - MovedPiece: The piece that moved.
    ///   - Direction: The direction the piece moved.
    ///   - Commanded: True if the piece was commanded to move, false if gravity caused the movement.
    func PieceMoved3D(_ MovedPiece: Piece, Direction: Directions, Commanded: Bool)
    
    /// Called when a piece is frozen into place.
    /// - Parameter ThePiece: The piece that should be finalized - eg, it's been merged into the map
    ///                       and can no longer move.
    func PieceFinalized(_ ThePiece: Piece)
    
    /// Called when a piece is fully discarded from the board. (Usually in response to
    /// an up and away command.)
    /// - Parameter ID: ID of the discarded piece. By the time this function is called,
    ///                 the piece itself has been deleted and is no longer available. The
    ///                 passed ID is merely for reference purposes **and should not be used
    ///                 to control the game/board.**
    func PieceDiscarded(_ ID: UUID)
    
    /// Called when the final score is available for the finalized piece.
    /// - Parameters:
    ///   - ID: The ID of the piece that was finalized.
    ///   - Score: The current game score after the piece was finalized.
    func FinalizedPieceScore(ID: UUID, Score: Int)
    
    /// Called when a moving (or rotating piece) intersects with a special item in the bucket.
    /// - Parameters:
    ///   - Item: The special item that was intersected.
    ///   - At: The location of the special item.
    ///   - ID: The ID of the item that intersected the special button.
    func PieceIntersectedWith(Item: PieceTypes, At: CGPoint, ID: UUID)
    
    func PieceIntersectedWithX(Item: UUID, At: CGPoint, ID: UUID)

    /// Called when a game over condition is met.
    func GameOver()
    
    /// Called when a piece freezes in place out of bounds.
    /// - Parameter ID: The ID of the piece that froze out of bounds.
    func OutOfBounds(_ ID: UUID)
    
    /// Called when a piece starts to freeze but hasn't frozen yet.
    /// - Parameter ID: ID of the piece that started to freeze.
    func StartedFreezing(_ ID: UUID)
    
    /// Called when a piece that had started to freeze was moved and is no longer frozen.
    /// - Parameter ID: The ID of the piece that is no longer frozen.
    func StoppedFreezing(_ ID: UUID)
    
    /// Called when a new piece is started and placed on the board.
    /// - Parameter NewPiece: The new piece.
    func NewPieceStarted(_ NewPiece: Piece)
    
    /// Called when the board deletes a full row of items.
    /// - Parameter Row: The row's index in the bucket.
    func DeletedRow(_ Row: Int)
    
    /// Called when a piece is block from moving (or rotating).
    /// - Parameter ID: ID of the blocked piece.
    func PieceBlocked(_ ID: UUID)
    
    /// Called when the piece is rotated.
    /// - Parameters:
    ///   - ID: ID of the rotated piece.
    ///   - Direction: Direction the piece rotated in.
    func PieceRotated(ID: UUID, Direction: Directions)
    
    /// Called when a piece tried to rotate but failed.
    /// - Parameters:
    ///   - ID: ID of the piece that failed rotation.
    ///   - Direction: The rotational direction that was attempted.
    func PieceRotationFailure(ID: UUID, Direction: Directions)
    
    /// Called everytime a piece moves, as that may potentially change the piece's
    /// score.
    /// - Note: The score of a piece indicates the potential fit of a piece at the bottom of
    ///         the bucket with frozen, prior blocks in place.
    /// - Parameters:
    ///   - For: The ID of the piece.
    ///   - NewScore: The new score for the piece in its current location and orientation.
    func PieceScoreUpdated(For: UUID, NewScore: Int)
    
    /// Notifies the UI when the game score changes. Resets to 0 when new games are started.
    /// - Parameter NewScore: New game score.
    func NewGameScore(NewScore: Int)
    
    /// Notifies the UI when the high score changes. Notification occurs at each change,
    /// not at the end of the same.
    /// - Parameter HighScore: New high score value.
    func NewHighScore(HighScore: Int)

    /// Called when a new next piece is available.
    /// - Parameter Next: The next piece after the current piece.
    func NextPiece(_ Next: Piece)
    
    /// Called after the board is done compressing pieces after a row-clearing event. This
    /// is called after all rows have been removed and all columns have been dropped.
    /// - Parameter DidCompress: True if the board actually compressed, false if not.
    func BoardDoneCompressing(DidCompress: Bool)
    
    /// Set the opacity of the piece to the supplied value.
    /// - Note: This is intended to be used for special effects.
    /// - Parameters
    ///   - To: The new opacity/alpha level of the piece.
    ///   - ID: ID of the piece to set.
    func SetPieceOpacity(To: Double, ID: UUID)
    
    /// Set the opacity of the piece to the supplied value.
    /// - Note: This is intended to be used for special effects.
    /// - Parameters
    ///   - To: The new opacity/alpha level of the piece.
    ///   - ID: ID of the piece to set.
    ///   - Duration: The length of time to change the opacity.
    func SetPieceOpacity(To: Double, ID: UUID, Duration: Double)
    
    /// Move a piece smoothly to the specified location.
    /// - Parameter GamePiece: The piece to move.
    /// - Parameter ToOffsetX: Horizontal destination offset.
    /// - Parameter ToOffsetY: Vertical destination offset.
    func SmoothMove(_ GamePiece: Piece, ToOffsetX: Int, ToOffsetY: Int)
    
    /// Rotate a piece smoothly in the specified direction (implied by `Degrees`).
    /// - Paramater GamePiece: The piece to rotate.
    /// - Parameter Degrees: Number of degrees to rotate the piece by.
    /// - Parameter OnAxis: The axis to rotate the piece on. 2D games use the .X axis.
    func SmoothRotate(_ GamePiece: Piece, Degrees: CGFloat, OnAxis: RotationalAxes)
    
    /// Tells the receiver to start dropping down the piece very quickly by the provided
    /// number of units.
    /// - Note: It is expected that the receiver call `Piece.FreezeAfterDropDown` after motion is
    ///         completed.
    /// - Parameter DeltaY: Number of units to drop.
    /// - Parameter WithPiece: The piece to drop.
    func StartFastDrop(DeltaY: Int, WithPiece: Piece)
}
