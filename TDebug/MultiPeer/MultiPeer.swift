//
//  MultiPeer.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import MultipeerConnectivity

/// Class that manages multi-peer communications.
/// - Note:
///     - This class manages communications on an application-by-application basis, which means having multiple copies
///       of the class instantiated at one time does nothing more than confuse those applications trying to communicate
///       with the target app.
///     - [Multipeer-Connectivity](https://www.ralfebert.de/ios/tutorials/multipeer-connectivity/)
class MultiPeerManager: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate, MCSessionDelegate
{
    private let TDebugServiceType = "debug-sink"
    private let PeerID = MCPeerID(displayName: UIDevice.current.name)
    private let ServiceAdvertiser: MCNearbyServiceAdvertiser!
    private let ServiceBrower: MCNearbyServiceBrowser!
    var Delegate: MultiPeerDelegate? = nil
    var InstanceID: UUID = UUID()
    
    lazy var Session: MCSession =
        {
            let Session = MCSession(peer: self.PeerID, securityIdentity: nil, encryptionPreference: .required)
            Session.delegate = self
            return Session
    }()
    
    /// Initializer. Immediately starts advertising this instance as well as browse for nearby services of the same service type.
    override init()
    {
        ServiceAdvertiser = MCNearbyServiceAdvertiser(peer: PeerID, discoveryInfo: nil, serviceType: TDebugServiceType)
        ServiceBrower = MCNearbyServiceBrowser(peer: PeerID, serviceType: TDebugServiceType)
        super.init()
        ServiceAdvertiser.delegate = self
        ServiceAdvertiser.startAdvertisingPeer()
        ServiceBrower.delegate = self
        ServiceBrower.startBrowsingForPeers()
    }
    
    /// Deinitializer. Shutdown advertising and browsing.
    deinit
    {
        Shutdown()
    }
    
    func Shutdown()
    {
        print("Shutting down advertising peer.")
        ServiceAdvertiser.stopAdvertisingPeer()
        
        print("Shutting down peer browser.")
        ServiceBrower.stopBrowsingForPeers()
    }
    
    /// Get the Peer ID of the instance.
    public var SelfPeer: MCPeerID
    {
        get
        {
            return PeerID
        }
    }
    
    private var _IsDebugHost: Bool = false
    /// Get or set the debug host flag.
    public var IsDebugHost: Bool
    {
        get
        {
            return _IsDebugHost
        }
        set
        {
            _IsDebugHost = newValue
        }
    }
    
    /// Broadcast the passed message (internally wrapped into a properly formatted command) to all peers. This is a fast way to
    /// broadcast a string to all peers.
    ///
    /// - Parameter Message: The message to broadcast.
    func Broadcast(Message: String)
    {
        if Session.connectedPeers.count > 0
        {
            do
            {
                let EncodedMessage = MessageHelper.MakeMessage(Message, GetDeviceName())
                try Session.send(EncodedMessage.data(using: String.Encoding.utf8)!, toPeers: Session.connectedPeers, with: .reliable)
            }
            catch
            {
                print("Error broadcasting message: \(error.localizedDescription)")
            }
        }
    }
    
    /// Broadcast the pre-formatted message (which may be any message formatted with the `MessageHelper` class) to all peers.
    ///
    /// - Parameter Message: The properly formatted (use `MessageHelper` to format your command messages) message to send to all peers.
    func BroadcastPreformatted(Message: String)
    {
        if Session.connectedPeers.count > 0
        {
            do
            {
                try Session.send(Message.data(using: String.Encoding.utf8)!, toPeers: Session.connectedPeers, with: .reliable)
            }
            catch
            {
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    /// Send a string message to the specified peer. The internally wrapped message does not contain any commands other than
    /// "here's a string".
    ///
    /// - Parameters:
    ///   - Message: The message to send.
    ///   - To: The peer to send the message to.
    func Send(Message: String, To: MCPeerID)
    {
        do
        {
            let EncodedMessage = MessageHelper.MakeMessage(Message, GetDeviceName())
            try Session.send(EncodedMessage.data(using: String.Encoding.utf8)!, toPeers: [To], with: .reliable)
        }
        catch
        {
            print("Error broadcasting message to \(To.displayName): \(error.localizedDescription)")
        }
    }
    
    /// Send a pre-formatted (use `MessageHelper` to generate such messages) message (which may be any command available through
    /// `MessageHelper` to the specified peer.
    ///
    /// - Parameters:
    ///   - Message: The properly formatted message to send to the specified peer.
    ///   - To: The peer to send the message to.
    func SendPreformatted(Message: String, To: MCPeerID)
    {
        do
        {
            try Session.send(Message.data(using: String.Encoding.utf8)!, toPeers: [To], with: .reliable)
        }
        catch
        {
            print("Error sending message to \(To.displayName): \(error.localizedDescription)")
        }
    }
    
    /// Send a message to the specified client with an exepcted, asynchronous response to be returned at some point in the future.
    ///
    /// - Parameters:
    ///   - Message: Message to send to the client.
    ///   - To: The ID of the client/remote system to send the message to.
    /// - Returns: The ID of the message that was sent.
    func SendWithAsyncResponse(Message: String, To: MCPeerID) -> UUID
    {
        let MessageID = UUID()
        let Encapsulated = MessageHelper.MakeEncapsulatedCommand(WithID: MessageID, Payload: Message)
        do
        {
            try Session.send(Encapsulated.data(using: String.Encoding.utf8)!, toPeers: [To], with: .reliable)
        }
        catch
        {
            print("Error sending message to \(To.displayName): \(error.localizedDescription)")
        }
        return MessageID
    }
    
    /// Return the list of connected peers.
    ///
    /// - Parameter IncludingSelf: Include the self instance in the list.
    /// - Returns: List of connected peers. May change over time so call periodically.
    func GetPeerList(IncludingSelf: Bool = false) -> [MCPeerID]
    {
        var PeerList: [MCPeerID] = Session.connectedPeers
        if IncludingSelf
        {
            PeerList.append(SelfPeer)
        }
        return PeerList
    }
    
    /// Handles the advertising service did not start event.
    ///
    /// - Parameters:
    ///   - advertiser: The advertising server.
    ///   - error: The related error.
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error)
    {
        print("Error starting advertising service: \(error.localizedDescription)")
    }
    
    /// Handle the received invitation event from a peer.
    ///
    /// - Parameters:
    ///   - advertiser: The advertising server.
    ///   - peerID: The ID of the peer accepting the invitation.
    ///   - context: Not used.
    ///   - invitationHandler: Handles invitations.
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void)
    {
        print("Received invitation from \(peerID.displayName)")
        invitationHandler(true, Session)
    }
    
    /// Handles the nearby browser did not start error event.
    ///
    /// - Parameters:
    ///   - browser: The nearby peer browser service.
    ///   - error: The related error.
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error)
    {
        print("Error starting service browser: \(error.localizedDescription)")
    }
    
    /// Handles the found-a-peer event.
    /// - Note: **iPadOS 13 beta something or another has a bad version of Multipeer Connectivity. Until it is
    ///         known to work, do not run TDDebug on your Mac or the iPadOS app will crash.**
    /// - Parameters:
    ///   - browser: The nearby service browser.
    ///   - peerID: The ID of the peer that was found.
    ///   - info: Not used.
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?)
    {
        print("Found peer \(peerID.displayName) - inviting to session.")
        browser.invitePeer(peerID, to: Session, withContext: nil, timeout: 10)
        print("Peer invited - waiting for 10 seconds.")
    }
    
    /// Handle the lost a peer (probably because the app was shut down on the remote side) event.
    ///
    /// - Parameters:
    ///   - browser: The nearby peer browser service.
    ///   - peerID: The ID of the peer that was lost.
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID)
    {
        print("Lost peer \(peerID.displayName)")
    }
    
    /// Handle the some peer changed state event.
    ///
    /// - Parameters:
    ///   - session: The session for the peer.
    ///   - peerID: The ID of the peer.
    ///   - state: The peer's new state.
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState)
    {
        print("Peer \(peerID.displayName) changed state: \(state.rawValue)")
        OperationQueue.main.addOperation
            {
                self.Delegate?.ConnectedDeviceChanged(Manager: self, ConnectedDevices: self.Session.connectedPeers,
                                         Changed: peerID, NewState: state)
        }
    }
    
    /// Handle the received data from a session event.
    ///
    /// - Note: The recevied data is checked to see if it's encapsulated and if it is, will be returned via
    ///         the async response mechanism, eg, returned via the `ReceivedAsyncData` function. Otherwise, if
    ///         the command is non-asynchronous, it is returned via the `ReceivedData` function.
    ///
    /// - Parameters:
    ///   - session: The session for the peer.
    ///   - data: The data sent by the peer.
    ///   - peerID: The ID of the peer that sent the data.
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID)
    {
        let Message = String(data: data, encoding: .utf8)
        let Cmd = MessageHelper.GetMessageType(Message!)
        if Cmd == MessageTypes.IDEncapsulatedCommand
        {
            OperationQueue.main.addOperation
                {
                    if let (ID, EnMsg) = MessageHelper.DecodeEncapsulatedCommand(Message!)
                    {
                        self.Delegate?.ReceivedAsyncData(Manager: self, Peer: peerID, CommandID: ID, RawData: EnMsg)
                        return
                    }
            }
            
            self.Delegate?.ReceivedData(Manager: self, Peer: peerID, RawData: Message!,
                                        OverrideMessageType: nil, EncapsulatedID: nil)
        }
    }
    
    /// Handle the received input stream from a session event.
    ///
    /// - Parameters:
    ///   - session: The session for the peer.
    ///   - stream: The input stream from the peer.
    ///   - streamName: The name of the stream.
    ///   - peerID: The ID of the peer that started the input stream.
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String,
                 fromPeer peerID: MCPeerID)
    {
        print("Received stream data from \(peerID.displayName)")
    }
    
    /// Handle the started receiving a resource with a name event.
    ///
    /// - Parameters:
    ///   - session: The session for the peer.
    ///   - resourceName: The name of the resource.
    ///   - peerID: The ID of the peer that sent the resource.
    ///   - progress: A progress object.
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress)
    {
        print("Started receiving resource from \(peerID.displayName)")
    }
    
    /// Handle the ended receiving a resource with a name event.
    ///
    /// - Parameters:
    ///   - session: The session for the peer.
    ///   - resourceName: The name of the resource.
    ///   - peerID: The ID of the peer that sent the resource.
    ///   - localURL: Local URL.
    ///   - error: Error information if relevant.
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?)
    {
        print("Finished receiving resource from \(peerID.displayName)")
    }
    
    /// Returns the name of the current device. The name is the network name given to the device by the user.
    ///
    /// - Note: The name is cached to increase speed on the assumption the user won't rename the device while using
    ///         the app that is running this code.
    ///
    /// - Returns: Name of the device.
    func GetDeviceName() -> String
    {
        if let TheName = TheDeviceName
        {
            return TheName
        }
        var SysInfo = utsname()
        uname(&SysInfo)
        let Name = withUnsafePointer(to: &SysInfo.nodename.0)
        {
            ptr in
            return String(cString: ptr)
        }
        let Parts = Name.split(separator: ".")
        TheDeviceName = String(Parts[0])
        return TheDeviceName!
    }
    
    /// Cached device name.
    var TheDeviceName: String? = nil
}
