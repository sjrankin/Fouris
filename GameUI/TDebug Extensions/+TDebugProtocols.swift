//
//  CommonViewController+TDebugProtocols.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import UIKit

/// Extensions to CommonViewController for handling TDebug functionality.
extension MainViewController: MultiPeerDelegate, StateProtocol, MessageHandlerDelegate
{
    // MARK: Message handler delegate functions. (Not currently used.)
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, Command Broadcast: String)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, Message Broadcast: String)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, Log Message: String)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, VersionInformation: [(String, String)])
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, EchoReturned Message: String)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, EchoMessage: String, In Seconds: Double)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, SpecialCommand: SpecialCommands)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, KVPData: (UUID, String, String))
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, Execute: ClientCommand)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, IdiotLightCommand: IdiotLightCommands, Address: String,
                 Text: String?, FGColor: UIColor?, BGColor: UIColor?)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, RespondToHeartBeat InSeconds: Double, Fail After: Double,
                 SenderCumulativeCount: Int)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, ReturnClientCommands: Any?)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, AsyncResultID: UUID, MessageType: MessageTypes, RawCommand: String)
    {
    }
    
    func Message(_ Handler: MessageHandler, From Peer: MCPeerID, EncapsulatedID: UUID, RawCommand: String)
    {
    }
    
    // MARK: State protocol delegate functions.
    
    func StateChanged(NewState: States, HandShake: HandShakeCommands)
    {
    }
    
    // MARK: Multi-peer delegate functions.
    
    func ConnectedDeviceChanged(Manager: MultiPeerManager, ConnectedDevices: [MCPeerID], Changed: MCPeerID, NewState: MCSessionState)
    {
        let ChangedPeerName = Changed.displayName
        var NewStateName = ""
        switch NewState
        {
        case MCSessionState.notConnected:
            NewStateName = "Not Connected"
            if let DebuggerID = DebugPeerID
            {
                if DebuggerID == Changed
                {
                    print("Lost connection to debugger on \(Changed.displayName)")
                    DebugPeerID = nil
                    DebugPeerPrefix = nil
                    DebugClient.ResetDestinationID()
                }
            }
            
        case MCSessionState.connecting:
            NewStateName = "Connecting"
            
        case MCSessionState.connected:
            NewStateName = "Connected"
            let GetPeerInfoCmd = MessageHelper.MakeGetPeerInformation()
            MPMgr.SendPreformatted(Message: GetPeerInfoCmd, To: Changed)
            
        default:
            NewStateName = "undetermined"
        }
        print("Debug connection state with \(ChangedPeerName) is now \(NewStateName)")
    }
    
    /// Send our instance data to a remote peer.
    /// - Parameter RawData: Not used.
    /// - Parameter Peer: The peer that wants our data.
    func SendInstanceDataToPeer(_ RawData: String, Peer: MCPeerID)
    {
        let ReturnToPeer = MessageHelper.MakeGetPeerTypeReturn(IsDebugger: false, PrefixCode: TDebugPrefix, PeerName: "Wacky Tetris")
        MPMgr.SendPreformatted(Message: ReturnToPeer, To: Peer)
    }
    
    /// Handle instance data from a remote peer. We're mostly curious about this to see if the peer is a debug sink or not. If it
    /// is a debug sink, save the information for debugging use.
    /// - Parameter RawData: The raw data to decode.
    /// - Parameter Peer: The source of the raw data.
    func HandleRemotePeerData(_ RawData: String, Peer: MCPeerID)
    {
        let PeerData: PeerType = MessageHelper.DecodePeerTypeCommand(RawData)!
        if PeerData.PeerIsDebugger
        {
            print("Found debugger on \(Peer.displayName)")
            DebugPeerID = Peer
            DebugPeerPrefix = PeerData.PeerPrefixID!
            let TVInfo = MessageHelper.MakeSendVersionInfo()
            MPMgr?.SendPreformatted(Message: TVInfo, To: Peer)
            DebugClient.SetDestinationID(DebugPeerID!)
        }
    }
    
    func HandleDebuggerStateChanged(_ RawData: String, Peer: MCPeerID)
    {
        if let (DebuggerPrefix, DebuggerName, DebuggerState) = MessageHelper.DecodeDebuggerStateChanged(RawData)
        {
            print("Debugger on \(DebuggerName) state changed to \(DebuggerState), [Prefix: \(DebuggerPrefix)]")
        }
    }
    
    func ReceivedData(Manager: MultiPeerManager, Peer: MCPeerID, RawData: String, OverrideMessageType: MessageTypes? = nil,
                      EncapsulatedID: UUID? = nil)
    {
        var MessageType: MessageTypes = .Unknown
        var Payload = ""
        if let OverrideMe = OverrideMessageType
        {
            MessageType = OverrideMe
        }
        else
        {
            let MessageData = MessageHelper.GetMessageData(RawData)
            MessageType = MessageData.0
            Payload = MessageData.3
        }
        switch MessageType
        {
        case .HandShake:
            HandleDebuggerHandshake(Payload, Peer: Peer)
            
        case .GetPeerType:
            SendInstanceDataToPeer(Payload, Peer: Peer)
            
        case .SendPeerType:
            HandleRemotePeerData(Payload, Peer: Peer)
            
        case .GetAllClientCommands:
            SendClientCommandList(Peer: Peer, CommandID: EncapsulatedID!)
            
        case .PushVersionInformation:
            HandlePushedVersionInformation(Payload)
            
        case .EchoMessage:
            HandleEchoMessage(Payload, Peer: Peer)
            
        case .BroadcastMessage:
            HandleBroadcastMessage(Payload, Peer: Peer)
            
        case .SendCommandToClient:
            HandleRecievedClientCommand(Payload, Peer: Peer)
            
        case .DebuggerStateChanged:
            HandleDebuggerStateChanged(Payload, Peer: Peer)
            
        default:
            print("Unhandled message type: \(MessageType), Raw=\(RawData)")
        }
    }
    
    func ProcessAsyncResult(CommandID: UUID, Peer: MCPeerID, MessageType: MessageTypes, RawData: String)
    {
        WaitingFor.removeAll(where: {$0.0 == CommandID})
        print("RawData=\(RawData)")
    }
    
    func ReceivedAsyncData(Manager: MultiPeerManager, Peer: MCPeerID, CommandID: UUID, RawData: String)
    {
        print("Received async response from ID: \(CommandID).")
        for (ID, MessageType) in WaitingFor
        {
            if ID == CommandID
            {
                //Handle the asynchronous response here - be sure to return after handling it and to not
                //drop through the bottom of the loop.
                print("Found matching response for \(MessageType) command.")
                ProcessAsyncResult(CommandID: CommandID, Peer: Peer, MessageType: MessageType, RawData: RawData)
                return
            }
        }
        
        //If we're here, we most likely received an encapsulated command.
        if let MessageType = MessageHelper.MessageTypeFromString(RawData)
        {
            print("Bottom of ReceivedAsyncData: MessageType=\(MessageType), RawData=\(RawData)")
            ReceivedData(Manager: Manager, Peer: Peer, RawData: RawData,
                         OverrideMessageType: MessageType, EncapsulatedID: CommandID)
        }
        else
        {
            print("Unknown message type found: \(RawData)")
        }
    }
}

