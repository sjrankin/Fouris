//
//  MessageHandler.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import UIKit


/// Class that handles messages from the MultiPeer manager. Source code compatible with iOS and macOS.
/// Programs that use this class must implement the functions in the `MessageHandlerDelegate`.
class MessageHandler
{
    init(_ WithDelegate: MessageHandlerDelegate?)
    {
        Delegate = WithDelegate
    }
    
    weak var Delegate: MessageHandlerDelegate? = nil
    
    func ControlIdiotLight(_ Raw: String)
    {
        let (Command, Address, Text, FGColor, BGColor) = MessageHelper.DecodeIdiotLightMessage(Raw)
        let FinalAddress = Address.uppercased()
        #if false
        OperationQueue.main.addOperation
            {
                switch Command
                {
                case .Disable:
                    self.Delegate?.Message(self, IdiotLightCommand: Command, Address: FinalAddress, Text: nil,
                                           FGColor: nil, BGColor: nil)
                    
                case .Enable:
                    self.Delegate?.Message(self, IdiotLightCommand: Command, Address: FinalAddress, Text: nil,
                                           FGColor: nil, BGColor: nil)
                    
                case .SetBGColor:
                    self.Delegate?.Message(self, IdiotLightCommand: Command, Address: FinalAddress, Text: nil,
                                           FGColor: nil, BGColor: BGColor)
                    
                case .SetFGColor:
                    self.Delegate?.Message(self, IdiotLightCommand: Command, Address: FinalAddress, Text: nil,
                                           FGColor: FGColor, BGColor: nil)
                    
                case .SetText:
                    self.Delegate?.Message(self, IdiotLightCommand: Command, Address: FinalAddress, Text: Text,
                                           FGColor: nil, BGColor:  nil)
                    
                case .Unknown:
                    print("Unknown idiot light command: \(Raw)")
                }
        }
        #endif
    }
    
    func Process(ReceivedData: String, Peer: MCPeerID, Manager: MultiPeerManager,
                 OverrideMessageType: MessageTypes? = nil, EncapsulatedID: UUID? = nil)
    {
        
    }
}
