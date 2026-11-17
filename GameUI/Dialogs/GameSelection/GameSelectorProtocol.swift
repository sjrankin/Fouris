//
//  GameSelectorProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/10/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol GameSelectorProtocol: AnyObject
{
    /// Called when the game selector dialog is closed.
    /// - Parameter DidChange: If true, the game shape changed. If false, the user closed the dialog with a the `Cancel` button.
    /// - Parameter NewGameShape: The new shape of the game.
    func GameTypeChanged(DidChange: Bool, NewGameShape: BucketShapes?)
}
