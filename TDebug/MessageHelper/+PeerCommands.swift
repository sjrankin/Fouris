//
//  +PeerCommands.swift
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
    // MARK: Peer handling command encoding commands.
    
    /// Make a command to have a client return the peer's information.
    ///
    /// - Returns: Command string for retrieving the peer's information.
    public static func MakeGetPeerInformation() -> String
    {
        let P1 = "From=\((PrefixCode)!)"
        let Final = GenerateCommand(Command: .GetPeerType, Prefix: PrefixCode, Parts: [P1])
        return Final
    }
    
    /// Creates and returns a command that returns peer data.
    /// - Parameter IsDebugger: The peer-is-acting-as-a-debugger flag.
    /// - Parameter PrefixCode: The peer instance prefix code.
    /// - Parameter PeerName: The name of the peer.
    /// - Returns: String to send to the caller.
    public static func MakeGetPeerTypeReturn(IsDebugger: Bool, PrefixCode: UUID, PeerName: String) -> String
    {
        let P1 = "Debugger=\(IsDebugger)"
        let P2 = "PrefixCode=\(PrefixCode.uuidString)"
        let P3 = "Name=\(PeerName)"
        let Final = GenerateCommand(Command: .SendPeerType, Prefix: PrefixCode, Parts: [P1, P2, P3])
        return Final
    }
    
    // MARK: Peer handling command decoding.
    
    public static func DecodePeerTypeCommand(_ Raw: String) -> PeerType?
    {
        if Raw.isEmpty
        {
            return nil
        }
        let Params = GetParameters(From: Raw, ["Debugger", "PrefixCode", "Name"])
        var IsDebugger = false
        if let Dbgr = Params["Debugger"]
        {
            IsDebugger = Bool(Dbgr)!
        }
        var PrefixCode = UUID.Empty
        if let PfxCd = Params["PrefixCode"]
        {
            PrefixCode = UUID(uuidString: PfxCd)!
        }
        var PeerName = ""
        if let PName = Params["Name"]
        {
            PeerName = PName
        }
        let PType = PeerType()
        PType.PeerIsDebugger = IsDebugger
        PType.PeerPrefixID = PrefixCode
        PType.PeerTitle = PeerName
        return PType
    }
}
