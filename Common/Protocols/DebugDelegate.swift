//
//  DebugDelegate.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Interface for handling debug set up and commands. Mainly used by the Debug Controller Window.
protocol DebugDelegate: class
{
    /// Set the current AI scoring method.
    /// - Parameter Method: The scoring method.
    func SetAIScoring(Method: AIScoringMethods)
    
    /// Sets the default AI scoring method.
    /// - Parameter IsDefault: If true, use the default scoring method.
    func SetAIDefaultScoring(IsDefault: Bool)
    
    /// Sets the current metapiece group.
    /// - Parameter PieceGroups: Current metapiece group.
    func SetPieceGroups(PieceGroups: MetaPieces)
    
    /// Sets how to select random pieces from metapiece groups.
    /// - Parameter Method: Determines how to select random pieces.
    func SetPieceSelection(Method: PieceSelectionMethods)
    
    /// Get the current AI scoring method.
    /// - Returns: AI scoring method.
    func GetAIScoring() -> AIScoringMethods
    
    /// Get the default AI scoring method flag.
    /// - Returns: True if should use the default AI scoring method, false if not.
    func GetAIDefaultScoring() -> Bool
    
    /// Get the current metapiece group.
    /// - Returns: current metapiece group.
    func GetPieceGroups() -> MetaPieces
}

/// How to group pieces for random selection.
/// - Cumulative: All pieces from Standard to the selected metapiece type are included.
/// - Exclusive: Only the selected metapiece type is used.
/// - RandomInSequence: Select a random piece from each metapiece group, in sequence.
enum PieceSelectionMethods: Int, CaseIterable
{
    case Cumulative = 0
    case Exclusive = 1
    case RandomInSequence = 2
}
