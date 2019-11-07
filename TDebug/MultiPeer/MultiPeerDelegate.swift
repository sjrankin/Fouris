//
//  MultiPeerDelegate.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import MultipeerConnectivity

/// Delegate for communication between the MultiPeerManager class and whatever classes that us it.
protocol MultiPeerDelegate
{
    /// Notifies the receiver when a peer changes status (eg, connected or disconnected).
    ///
    /// - Parameters:
    ///   - Manager: The instance of the multipeer manager.
    ///   - ConnectedDevices: List of connected devices. Connected in this case means the device is
    ///                       advertising but not necessarily talking to us.
    ///   - Changed: The specific peer that changed.
    ///   - NewState: The new state of the peer that changed.
    func ConnectedDeviceChanged(Manager: MultiPeerManager, ConnectedDevices: [MCPeerID],
                                Changed: MCPeerID, NewState: MCSessionState)
    
    /// Notifies the receiver that data has been received by a peer.
    ///
    /// - Parameters:
    ///   - Manager: The instance of the multipeer manager.
    ///   - Peer: The peer that sent the data. The data sent is not from a stream or a resource.
    ///   - RawData: The raw data in string format.
    ///   - OverrideMessageType: If present, this message type overrides the contents of the
    ///                          message type in `RawData`.
    ///   - EncapsulatedID: If present, the encapsulted ID value to use as a return value.
    func ReceivedData(Manager: MultiPeerManager, Peer: MCPeerID, RawData: String,
                      OverrideMessageType: MessageTypes?, EncapsulatedID: UUID?)
    
    /// Notifies the receiver of data received asynchronously as part of a request from the client.
    ///
    /// - Parameters:
    ///   - Manager: The instance of the multipeer manager.
    ///   - Peer: The peer that sent the data. The data sent is not from a stream or a resource.
    ///   - CommandID: The ID of the command (but not the command ID). In other words, each encapsulated
    ///                message is sent with a unique ID so that the responder can use the same ID when
    ///                responding, allowing for synchronizing the response to the original request. This
    ///                is the unique ID that allows for that.
    ///   - RawData: The encapsulated message from the responder.
    func ReceivedAsyncData(Manager: MultiPeerManager, Peer: MCPeerID, CommandID: UUID, RawData: String)
}
