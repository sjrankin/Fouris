//
//  GameLogicProtocol.swift
//  WackyTetris
//
//  Created by Stuart Rankin on 4/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

protocol GameLogicProtocol: AnyObject
{
    func PieceUpdated(ID: UUID)
    func DropFinalized(ID: UUID)
    func StoppedOutOfBounds(ID: UUID)
}
