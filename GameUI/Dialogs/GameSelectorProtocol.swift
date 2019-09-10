//
//  GameSelectorProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/10/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

protocol GameSelectorProtocol: class
{
    /// Called when the game selector dialog closes.
    /// - Parameter DidChange: If true, the game type or sub type or both changed.
    /// - Parameter NewBaseType: The new base type (or old one if only the `GameSubType` changed). If `DidChange` is false,
    ///                          this value will be nil.
    /// - Parameter GameSubType: The new sub type game (or old one if only the `NewBaseType` changed). If `DidChange` is false,
    ///                          this value will be nil.
    func GameTypeChanged(DidChange: Bool, NewBaseType: BaseGameTypes?, GameSubType: BaseGameSubTypes?)
}
