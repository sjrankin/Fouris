//
//  CommonViewController+TDebugRecievedCommandHandling.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import UIKit

extension MainViewController
{
    func HandlePushedVersionInformation(_ RawData: String)
    {
        let (Name, OS, Version, Build, BuildTimeStamp, Copyright, BuildID, ProgramID) = MessageHelper.DecodeVersionInfo(RawData)
        print("Client name=\(Name), \(ProgramID), Intended OS: \(OS)")
        print("Client version data = \(Version), Build: \(Build), Build ID: \(BuildID).")
        print("Build time-stamp: \(BuildTimeStamp), Copyright: \(Copyright)")
    }
    
    func HandleDebuggerHandshake(_ RawData: String, Peer: MCPeerID)
    {
        let Command = MessageHelper.DecodeHandShakeCommand(RawData)
        var PostConnect1 = ""
        OperationQueue.main.addOperation
            {
                let ReturnMe = State.TransitionTo(NewState: Command)
                var ReturnState = ""
                switch Command
                {
                case .ConnectionClose:
                    break
                    
                case .ConnectionGranted:
                    print("Connected to debugger \(Peer.displayName)")
                    ReturnState = MessageHelper.MakeHandShake(ReturnMe)
                    PostConnect1 = MessageHelper.MakeSendVersionInfo()
                    
                case .ConnectionRefused:
                    print("Connection to \(Peer.displayName) refused.")
                    ReturnState = MessageHelper.MakeHandShake(ReturnMe)
                    
                case .Disconnected:
                    print("Disconnected from \(Peer.displayName).")
                    ReturnState = MessageHelper.MakeHandShake(ReturnMe)
                    
                case .DropAsClient:
                    print("Dropped as client by \(Peer.displayName).")
                    State.TransitionTo(NewState: .Disconnected)
                    
                case .RequestConnection:
                    break
                    
                case .Unknown:
                    break
                }
                
                if !ReturnState.isEmpty
                {
                    self.MPMgr.SendPreformatted(Message: ReturnState, To: Peer)
                    if !PostConnect1.isEmpty
                    {
                        self.MPMgr.SendPreformatted(Message: PostConnect1, To: Peer)
                    }
                }
                else
                {
                    print("Empty handshake return state.")
                }
        }
    }
    
    func SendClientCommandList(Peer: MCPeerID, CommandID: UUID)
    {
        let AllCommands = MessageHelper.MakeAllClientCommands(Commands: LocalCommands)
        let EncapsulatedReturn = MessageHelper.MakeEncapsulatedCommand(WithID: CommandID, Payload: AllCommands)
        MPMgr.SendPreformatted(Message: EncapsulatedReturn, To: Peer)
    }
    
    func GetDeviceName() -> String
    {
        var SysInfo = utsname()
        uname(&SysInfo)
        let Name = withUnsafePointer(to: &SysInfo.nodename.0)
        {
            ptr in
            return String(cString: ptr)
        }
        let Parts = Name.split(separator: ".")
        return String(Parts[0])
    }
    
    func DoEcho(Delay: Int, Message: String)
    {
        if EchoTimer != nil
        {
            EchoTimer.invalidate()
            EchoTimer = nil
        }
        MessageToEcho = Message
        EchoTimer = Timer.scheduledTimer(timeInterval: Double(Delay), target: self,
                                         selector: #selector(EchoSomething(_:)), userInfo: Message as Any?,
                                         repeats: false)
    }
    
    @objc func EchoSomething(_ Info: Any?)
    {
        let ReturnToSender = MessageToEcho
        let Message = MessageHelper.MakeMessage(WithType: .EchoReturn, ReturnToSender!, GetDeviceName())
        MPMgr.SendPreformatted(Message: Message, To: EchoBackTo)
    }
    
    func HandleEchoMessage(_ RawData: String, Peer: MCPeerID)
    {
        let (EchoMessage, _, Delay, _) = MessageHelper.DecodeEchoMessage(RawData)!
        let REchoMessage = String(EchoMessage.reversed())
        EchoBackTo = Peer
        OperationQueue.main.addOperation {
            self.DoEcho(Delay: Delay, Message: REchoMessage)
        }
    }
    
    func ExecuteCommandFromPeer(_ Command: ClientCommand, Peer: MCPeerID)
    {
        let SentCommand: ClientCommandIDs = Command.GetCommandType()!
        switch SentCommand
        {
        case ClientCommandIDs.ClientVersion:
            let VerInfo = MessageHelper.MakeSendVersionInfo()
            MPMgr.SendPreformatted(Message: VerInfo, To: Peer)
            
        case ClientCommandIDs.Reset:
            break
            
        case ClientCommandIDs.SendText:
            print("Text from \(Peer.displayName): \(Command.ParameterValues[0])")
            
        case ClientCommandIDs.ShutDown:
            break
        }
    }
    
    func HandleRecievedClientCommand(_ RawData: String, Peer: MCPeerID)
    {
        if let ExecuteMe = MessageHelper.DecodeClientCommand(RawData)
        {
            OperationQueue.main.addOperation
                {
                self.ExecuteCommandFromPeer(ExecuteMe, Peer: Peer)
            }
        }
    }
    
    func HandleBroadcastMessage(_ RawData: String, Peer: MCPeerID)
    {
        var ItemSource = "TDebug"
        var ItemMessage = ""
        if let (Source, Message) = MessageHelper.DecodeBroadcastCommand(RawData)
        {
            ItemSource = Source
            ItemMessage = "Broadcast[\(Source)]: \(Message)"
        }
        else
        {
            ItemMessage = "Error decoding broadcast message from \(Peer.displayName)"
        }
    }
}
