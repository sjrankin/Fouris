//
//  StateProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

protocol StateProtocol: AnyObject
{
    func StateChanged(NewState: States, HandShake: HandShakeCommands)
}
