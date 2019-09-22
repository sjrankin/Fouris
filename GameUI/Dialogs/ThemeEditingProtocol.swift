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
    /// - Parameter Theme: The theme to edit.
    /// - Parameter DefaultTheme: The default theme.
    func EditTheme(Theme: ThemeDescriptor, DefaultTheme: ThemeDescriptor)
    
    // Used to edit a piece in a theme.
    /// - Parameter Theme: The theme to edit.
    /// - Parameter PieceID: The piece shape ID to edit.
    /// - Parameter DefaultTheme: The default theme.
    func EditTheme(Theme: ThemeDescriptor, PieceID: UUID, DefaultTheme: ThemeDescriptor)
    
    /// Used to send to a caller the results of editing a theme.
    /// - Parameter Edited: If true, the theme (or piece) was edited. If false, the theme
    ///                     (or piece) was not edited.
    /// - Parameter ThemeID: The ID of the edited theme.
    /// - Parameter PieceID: The ID of the edited piece. May be nil depending on initial conditions.
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
}
