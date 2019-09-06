//
//  ThemeEditingProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Protocol for editing themes.
protocol ThemeEditingProtocol: class
{
    /// Used to send to an editor the ID of the theme to edit.
    func EditTheme(ID: UUID)
    
    // Used to edit a piece in a theme.
    func EditTheme(ID: UUID, Piece: UUID)
    
    /// Used to send to a caller the results of editing a theme.
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
}
