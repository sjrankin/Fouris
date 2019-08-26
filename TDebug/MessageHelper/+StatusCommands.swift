//
//  +StatusCommands.swift
//  TDDebug
//
//  Created by Stuart Rankin on 6/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import MultipeerConnectivity

extension MessageHelper
{
    // MARK: Status command encoding commands.
    
    public static func MakeDebuggerStateChangeMessage(Prefix: UUID, From: MCPeerID, NewDebugState: Bool) -> String
    {
        let P1 = "Prefix=\(Prefix)"
        let P2 = "Peer=\(From.displayName)"
        let P3 = "NewDebugState=\(NewDebugState)"
        let Final = GenerateCommand(Command: .DebuggerStateChanged, Prefix: Prefix, Parts: [P1, P2, P3])
        return Final
    }
    
    // MARK: Status command decoding.
    
    public static func DecodeDebuggerStateChanged(_ Raw: String) -> (UUID, String, Bool)?
    {
        let Params = GetParameters(From: Raw, ["Prefix", "Peer", "NewDebugState"])
        var Prefix: UUID = UUID.Empty
        if let Pfx = Params["Prefix"]
        {
            Prefix = UUID(uuidString: Pfx)!
        }
        var Peer = ""
        if let Pr = Params["Peer"]
        {
            Peer = Pr
        }
        var DebugState = false
        if let DbgState = Params["NewDebugState"]
        {
            DebugState = Bool(DbgState)!
        }
        return (Prefix, Peer, DebugState)
    }
}
