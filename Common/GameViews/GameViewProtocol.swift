//
//  GameViewProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/4/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol to control game views.
protocol GameViewProtocol: class
{
    /// Draw the background.
    func DrawBackground()
      
    /// Draw the 3D game view map. Includes moving pieces.
    /// - Parameter FromBoard: The board that contains the map to draw.
    /// - Parameter CalledFrom: Name of the caller. Used for debugging purposes only.
    func DrawMap3D(FromBoard: Board, CalledFrom: String)
    
    /// Visually clear the bucket of pieces.
    /// - Parameter FromBoard: *Not currently used*.
    /// - Parameter DestroyBy: Determines how to visually empty the bucket.
    /// - Parameter MaxDuration: Maxium length of time to empty the bucket.
    func DestroyMap3D(FromBoard: Board, DestroyBy: DestructionMethods, MaxDuration: Double)
    
    /// Hides the board with specified visual effects.
    /// - Parameter Method: The method to use to hide the board.
    /// - Parameter Duration: The amount of time from start to finish of the visual effect to hide
    ///                       the board, in seconds.
    func HideBoard(Method: HideBoardMethods, Duration: Double)
    
    /// Shows the board with specified visual effects.
    /// - Parameter Method: The method to use to show the board.
    /// - Parameter Duration: The amount of time from start to finish of the visual effect to show
    ///                       the board, in seconds.
    func ShowBoard(Method: ShowBoardMethods, Duration: Double)

    /// Sets the current board.
    ///
    /// - Parameter TheBoard: The currently playing board.
    func SetBoard(_ TheBoard: Board)
    
    /// Remove all retired and current blocks from the board.
    func EmptyMap()
    
    /// Handle layout completed events.
    func LayoutCompleted()
    
    /// Handle resize events.
    func Resized()
    
    /// Show or hide grid lines.
    /// - Parameter Show: Determines whether grid lines are shown or hidden.
    /// - Parameter WithUnitSize: Unit size to override the normally-calculated unit size.
    func DrawGridLines(_ Show: Bool, WithUnitSize: CGFloat?)
    
    /// Move the specified piece to the specified location on the game board.
    /// - Parameter ThePiece: The piece to move.
    /// - Parameter ToLocation: The location (in game board coordinates) where to move the piece.
    /// - Parameter Duration: Number of seconds to use for the move.
    /// - Parameter Completion: The completion handler for the move. Will supply the ID of the moved piece.
    func MovePiece(_ ThePiece: Piece, ToLocation: CGPoint, Duration: Double,
                   Completion: ((UUID) -> ())?)
    
    /// Rotate the specified piece to the specified angle.
    /// - Parameter ThePiece: The piece to rotate.
    /// - Parameter Degrees: The angle offset in degrees to rotate the piece.
    /// - Parameter Duration: The length of time in seconds to rotate the piece.
    /// - Parameter Completion: The completion handler for the rotation. Will supply the ID of the rotated piece.
    func RotatePiece(_ ThePiece: Piece, Degrees: Double, Duration: Double,
                     Completion: ((UUID) -> ())?)
    
    /// Draw the passed piece on a surface with the passed size.
    /// - Parameters:
    ///   - ThePiece: The piece to draw.
    ///   - SurfaceSize: The size of the surface where the drawing will be placed.
    func DrawPiece(_ ThePiece: Piece, SurfaceSize: CGSize)
    
    /// Called when the piece whose ID is passed freezes out of bounds.
    /// - Parameter ID: ID of the piece that froze out of bounds.
    func PieceOutOfBounds(_ ID: UUID)
    
    /// Called when a piece starts to freeze but isn't frozen.
    /// - Parameter ID: The piece that started to freeze.
    func StartedFreezing(_ ID: UUID)
    
    /// Called when a piece that had started to freeze is no longer frozen.
    /// - Parameter: ID: The piece that is no longer frozen.
    func StoppedFreezing(_ ID: UUID)
    
    /// Sets the opacity of the passed block type to the passed value.
    /// - Parameters:
    ///   - OfID: ID of the block type whose opacity will be set.
    ///   - To: The new opacity level.
    func SetOpacity(OfID: UUID, To: Double)
    
    /// Sets the opacity of the passed block type to the passed value.
    /// - Parameter OfID: The ID of the block whose opacity will be set.
    /// - Parameter To: The new opacity level.
    /// - Parameter Duration: The amount of time to run the opacity change action.
    func SetOpacity(OfID: UUID, To: Double, Duration: Double)
    
    /// Rotates the contents of the game (but not UI or falling piece) by the specified number of degrees.
    /// - Parameter Right: If true, contents are rotated clockwise. Otherwise, counter-clockwise.
    /// - Parameter Duration: Number of seconds to take to rotate the contents.
    /// - Parameter Completed: Completion handler called at the end of the rotation.
    func RotateContents(Right: Bool, Duration: Double, Completed: @escaping (() -> ()))
    
    /// Rotates the contents of the game (but not UI or falling piece) by 90° left (counter-clockwise).
    /// - Parameter Duration: Number of seconds to take to rotate the contents.
    /// - Parameter Completed: Completion handler called at the end of the rotation.
    func RotateContentsLeft(Duration: Double, Completed: @escaping (() -> ()))
    
    /// Rotates the contents of the game (but not UI or falling piece) by 90° right (clockwise).
    /// - Parameter Duration: Number of seconds to take to rotate the contents.
    /// - Parameter Completed: Completion handler called at the end of the rotation.
    func RotateContentsRight(Duration: Double, Completed: @escaping (() -> ()))
    
    /// Refreshes the game view.
    func Refresh()
    
    /// Returns the frame rate from views that support reporting of frame rates. If a view
    /// does not support frame rates, nil is returned.
    /// - Returns: Most recent frame rate (taken at time of call) from views that support
    ///            frame rates.
    func FrameRate() -> Double?
    
    /// Sets the opacity level of the entire board to the specified value.
    /// - Parameter To: The new alpha/opacity level.
    /// - Parameter Duration: The duration of the opacity change.
    /// - Parameter Completed: Completion block.
    func SetBoardOpacity(To: Double, Duration: Double, Completed: (() -> ())?)
    
    /// Show controls in the game view.
    /// - Parameter Which: Array of buttons to show. If nil, all buttons are shown.
    func ShowControls(With: [NodeButtons]?)
    
    /// Adds the specified button to the set of motion controls. If the button is already present, no action is taken.
    /// - Parameter Which: The button to add.
    func AppendButton(Which: NodeButtons)
    
    /// Removes the specified button from the set of motion controls. If the button is not present, no action is taken.
    /// - Parameter Which: The button to remove.
    func RemoveButton(Which: NodeButtons)
    
    /// Hides all motion controls in the game surface and may optionally change the visual size
    /// of the bucket.
    func HideControls()
    
    /// Flash a button with its pre-set highlight color.
    /// - Note: "Flash" means showing the highlight color for a short amount of time to simulate a
    ///         button press by the AI.
    /// - Parameter Button: The button to flash.
    /// - Parameter Duration: How long to flash the button in seconds.
    func FlashButton(_ Button: NodeButtons, Duration: Double)
    
    /// Sets the heartbeat indicator visibility.
    /// - Parameter Show: Determines whether the heartbeat indicator is highlighted or not.
    func SetHeartbeatVisibility(Show: Bool)
    
    /// Changes the highlight state of the heartbeat indicator. Ignored if the heartbeat
    /// indicator is disabled.
    func ToggleHeartState()
    
    /// Perform a fast drop execution on the supplied piece.
    /// - Parameter WithPiece: The piece to drop quickly.
    /// - Parameter DeltaX: The relative number of grid points to move horizontally.
    /// - Parameter DeltaY: The relative number of grid points to move vertically.
    /// - Parameter TotalDuration: The amount of time to take to drop.
    /// - Parameter Completed: Completion block.
    func MovePieceRelative(WithPiece: Piece, DeltaX: Int, DeltaY: Int, TotalDuration: Double,
                           Completed: ((Piece)->())?)
}


