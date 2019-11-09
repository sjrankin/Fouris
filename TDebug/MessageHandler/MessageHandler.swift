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

/// Class that handles messages from the MultiPeer manager.
/// Programs that use this class must implement the functions in the `MessageHandlerDelegate`.
class MessageHandler
{
    /// Initializer.
    /// - Parameter WithDelegate: The delegate that recieves events from this class.
    init(_ WithDelegate: MessageHandlerDelegate?)
    {
        Delegate = WithDelegate
    }

    /// The delegate to receive data and commands from this class.
    weak public var Delegate: MessageHandlerDelegate? = nil
    
    /// Controls a remote idiot light.
    /// - Parameter Raw: Data that controls an idiot list.
    public func ControlIdiotLight(_ Raw: String)
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
    
    /// Process received data.
    /// - Note: Not currently used.
    public func Process(ReceivedData: String, Peer: MCPeerID, Manager: MultiPeerManager,
                 OverrideMessageType: MessageTypes? = nil, EncapsulatedID: UUID? = nil)
    {
        
    }
}
