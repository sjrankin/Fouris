//
//  MessageHandlerDelegate.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import MultipeerConnectivity

/// Protocol to communicate between the message handling class and the consumer of the messages.
protocol MessageHandlerDelegate: class
{
    /// Handle a received broadcast command.
    ///
    /// - Parameters:
    ///   - Handler: The message handler class that received the command and called this function.
    ///   - Peer: The peer that sent the message.
    ///   - Broadcast: The raw, encoded command.
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, Command Broadcast: String)
    
    /// Handle a received broadcast message to display.
    ///
    /// - Parameters:
    ///   - Handler: The message handler class that received the command and called this function.
    ///   - Peer: The peer that sent the message.
    ///   - Broadcast: The text message to display in the log.
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, Message Broadcast: String)
    
    /// Handle a received broadcast message to display.
    ///
    /// - Parameters:
    ///   - Handler: The message handler class that received the command and called this function.
    ///   - Peer: The peer that sent the message.
    ///   - Message: The message to put into the log.
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, Log Message: String)
    
    /// Handle receiving a set of version information.
    ///
    /// - Parameters:
    ///   - Handler: The message handler class that received the command and called this function.
    ///   - Peer: The peer that sent the message.
    ///   - VersionInformation: List of version information from the peer.
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, VersionInformation: [(String, String)])
    
    /// Handle received an echoed message.
    ///
    /// - Parameters:
    ///   - Handler: The message handler class that received the command and called this function.
    ///   - Peer: The peer that sent the message.
    ///   - Message: The message that was echoed back from the peer it was originally sent to.
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, EchoReturned Message: String)
    
    /// Handle an echo message command.
    ///
    /// - Parameters:
    ///   - Handler: The message handler class that received the command and called this function.
    ///   - Peer: The peer that sent the message.
    ///   - EchoMessage: The text to echo back to the peer.
    ///   - Seconds: Number of seconds to delay before echoing the text back.
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, EchoMessage: String, In Seconds: Double)
    
    /// Handle special command to execute on the host.
    ///
    /// - Parameters:
    ///   - Handler: The message handler class that received the command and called this function.
    ///   - Peer: The peer that sent the message.
    ///   - SpecialCommand: The command to execute.
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, SpecialCommand: SpecialCommands)
    
    /// Handle received KVP data for the KVP display.
    ///
    /// - Parameters:
    ///   - Handler: The message handler class that received the command and called this function.
    ///   - Peer: The peer that sent the message.
    ///   - KVPData: KVP data in the form (ID, Key, Value).
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, KVPData: (UUID, String, String))
    
    /// Handle a client command from a peer to be executed on this host.
    ///
    /// - Parameters:
    ///   - Handler: The message handler class that received the command and called this function.
    ///   - Peer: The peer that sent the message.
    ///   - Execute: The client command to execute.
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, Execute: ClientCommand)
    
    /// Handle a received broadcast message to display.
    ///
    /// - Parameters:
    ///   - Handler: The message handler class that received the command and called this function.
    ///   - Peer: The peer that sent the message.
    ///   - IdiotLightCommand: The idiot light command to execute.
    ///   - Address: The address of the idiot light in row column formate (eg, A1 or C2).
    ///   - Text: The text to place in the idiot light. Nil if no text to set.
    ///   - FGColor: The color of the text of the idiot light. Nil if no color specified.
    ///   - BGColor: The color of the background of the idiot light. Nil if no color specified.
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, IdiotLightCommand: IdiotLightCommands,
                 Address: String, Text: String?, FGColor: UIColor?, BGColor: UIColor?)
    
    /// Respond to a connection heartbeat received from a peer.
    ///
    /// - Parameters:
    ///   - Handler: The message handler class that received the command and called this function.
    ///   - Peer: The peer that sent the message.
    ///   - InSeconds: How long to wait before responding to the sender with our own heartbeat message.
    ///   - After: Fail after this number of seconds.
    ///   - SenderCumulativeCount: Number of heartbeats sent so far by the peer.
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, RespondToHeartBeat InSeconds: Double, Fail After: Double,
                 SenderCumulativeCount: Int)
    
    /// Respond to a request by a peer to return client commands.
    ///
    /// - Parameters:
    ///   - Handler: The message handler class that received the command and called this function.
    ///   - Peer: The peer that sent the message.
    ///   - ReturnClientCommands: Not used.
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, ReturnClientCommands: Any?)
    
    /// Respond to an asynchronous result return.
    ///
    /// - Parameters:
    ///   - Handler: The message handler class that received the command and called this function.
    ///   - Peer: The peer that sent the message.
    ///   - AsyncResultID: ID of the asynchronous result. Set when the asynchronous call is made to allow for tracking
    ///                    of results to calls.
    ///   - MessageType: The type of command that caused an asynchronous result.
    ///   - RawCommand: The raw returned command.
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, AsyncResultID: UUID,
                 MessageType: MessageTypes, RawCommand: String)
    
    /// Handle encapsulated commands.
    ///
    /// - Parameters:
    ///   - Handler: The message handler class that received the command and called this function.
    ///   - Peer: The peer that sent the message.
    ///   - EncapsulatedID: ID of the encapculated command.
    ///   - RawCommand: The raw, encapsulated command.
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, EncapsulatedID: UUID,
                 RawCommand: String)
}
