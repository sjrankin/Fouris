//
//  SmoothMotionProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for classes that support smooth motion of pieces.
protocol SmoothMotionProtocol: class
{
    /// Move a piece smoothly.
    /// - Parameter GamePiece: The piece to move.
    /// - Parameter ToOffsetX: Horizontal offset value.
    /// - Parameter ToOffsetY: Vertical offset value.
    /// - Parameter Duration: The amount of time to move the piece.
    func MovePieceSmoothly(_ GamePiece: Piece, ToOffsetX: CGFloat, ToOffsetY: CGFloat, Duration: Double)
    
    /// Called by the class that smoothly moved a piece once the piece has completed motion.
    /// - Parameter For: The ID of the piece that was moved.
    func SmoothMoveCompleted(For: UUID)
    
    /// Rotate a piece smoothly.
    /// - Parameter GamePiece: The piece to rotate.
    /// - Parameter ByDegrees: The number of degrees to rotate the piece.
    /// - Parameter Duration: The amount of time to rotate the piece.
    /// - Parameter OnAxis: The axis to rotate by. Default value is .X. This parameter is ignored for non-3D game views.
    func RotatePieceSmoothly(_ GamePiece: Piece, ByDegrees: CGFloat, Duration: Double, OnAxis: RotationalAxes)
    
    /// Called by the class that smoothly rotated a piece once the piece has completed rotating.
    /// - Parameter For: The ID of the piece that was rotated.
    func SmoothRotationCompleted(For: UUID)
    
    /// Called to create a game piece that can move smoothly.
    /// - Returns: ID of the piece to move smoothly.
    func CreateSmoothPiece() -> UUID
    
    /// Called when the game is done moving a piece smoothly, eg, when it freezes into place.
    /// - Parameter ID: The ID of the piece to clean up.
    func DoneWithSmoothPiece(_ ID: UUID)
}

/// Describes valid rotational axes.
/// - **X**: X axis. This is the traditional rotational axis for Tetris.
/// - **Y**: Y axis. Rotation is vertical, eg, top to bottom.
/// - **Z**: Z axis. Rotation is perpendicular to the screen.
enum RotationalAxes: String, CaseIterable
{
    case X = "X"
    case Y = "Y"
    case Z = "Z"
}
