//
//  DebugClient.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/11/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import UIKit

/// High-level routines to talk to the debugger (if present).
class DebugClient
{
    /// Initializer.
    /// - Parameter With: Reference to the multipeer manager class.
    public static func Initialize(With: MultiPeerManager, HostName: String)
    {
        MPMgr = With
        MPMgr?.IsDebugHost = false
        LocalHostName = HostName
    }
    
    /// Delegate.
    public static weak var Delegate: TDebugProtocol? = nil
    
    /// The local host name.
    private static var LocalHostName: String = "Tetris"
    
    /// Holds a reference to the multipeer manager.
    private static var MPMgr: MultiPeerManager? = nil
    
    /// Send a text message to be displayed in the debugger's log table.
    /// - Note: If `MPMgr` is nil and `SuppressMessageIfNoPeer` is false, the message is sent to the debug console. If
    ///         `MPMgr` if nil and `SuppressMessageIfNoPeer` is true, no message is sent anywhere.
    /// - Parameter Message: The message to send.
    /// - Parameter SuppressMessageIfNoPeer: If true, if no destination ID was set, no debug message is printed. If false,
    ///                                      if no destination ID was set, the message is sent to the debug console.
    public static func Send(_ Message: String, SuppressMessageIfNoPeer: Bool = false)
    {
        if MPMgr == nil
        {
            if !SuppressMessageIfNoPeer
            {
                print(Message)
            }
            return
        }
        if let Destination = DestinationID
        {
            let SendMe = MessageHelper.MakeMessage(Message, LocalHostName)
            MPMgr?.SendPreformatted(Message: SendMe, To: Destination)
        }
        else
        {
            if !SuppressMessageIfNoPeer
            {
                print(Message)
            }
        }
    }
    
    /// Send a text message to the debug console and to the remote debugger, if available.
    /// - Note: The message to the local debug console is printed unconditionally if compiled for DEBUG.
    /// - Parameter Message: The message to print and send.
    public static func Print(_ Message: String)
    {
        print(Message)
        if MPMgr == nil
        {
            return
        }
        if let Destination = DestinationID
        {
            let SendMe = MessageHelper.MakeMessage(Message, LocalHostName)
            MPMgr?.SendPreformatted(Message: SendMe, To: Destination)
        }
    }
    
    /// Holds the destination ID.
    private static var DestinationID: MCPeerID? = nil
    
    /// Set the destination ID.
    /// - Parameter DestID: The ID of the debugger destination.
    public static func SetDestinationID(_ DestID: MCPeerID)
    {
        DestinationID = DestID
        if MPMgr != nil
        {
            print("Setting connection state to TRUE")
            Delegate?.RemoteConnectionStateChanged(Connected: true)
        }
    }
    
    /// Resets the destination ID.
    /// - Note: Should be called if the debugger disconnects for any reason.
    public static func ResetDestinationID()
    {
        DestinationID = nil
        print("Setting connection state to FALSE")
        Delegate?.RemoteConnectionStateChanged(Connected: false)
    }
    
    /// Set an idiot light in the attached peer debugging using default colors.
    /// - Parameter Light: Determines which light to set.
    /// - Parameter Title: The text of the idiot light.
    public static func SetIdiotLight(_ Light: IdiotLights, Title: String)
    {
        SetIdiotLight(Light, Title: Title, FGColor: ColorNames.Black, BGColor: ColorNames.White)
    }
    
    /// Set an idiot light in the attached peer debugger.
    /// - Note: If there is no connection, the command will be enqueued until there is a connection, at
    ///         which point it will be sent.
    /// - Parameter Light: Determines which light to set. A1 is normally reserved by the debugger so
    ///                    trying to use it will normally fail silently.
    /// - Parameter Title: The text of the idiot light.
    /// - Parameter FGColor: The forground color of the idiot light.
    /// - Parameter BGColor: The background color of the idiot light.
    public static func SetIdiotLight(_ Light: IdiotLights, Title: String, FGColor: ColorNames, BGColor: ColorNames)
    {
        let Command = MessageHelper.MakeIdiotLightMessage(Address: Light.rawValue, Message: Title,
                                                          FGColor: FGColor, BGColor: BGColor)
        if let Destination = DestinationID
        {
            if MPMgr != nil
            {
                MPMgr?.SendPreformatted(Message: Command, To: Destination)
                return
            }
        }
        CommandQueue.Enqueue(Command)
    }
    
    /// Send a preformatted command to the peer debugger. If there is no connection, the command is queued
    /// to be send at the next call if there is a valid connection (however, see `DoNotQueue`).
    /// - Note: If the command queue is *not* empty when this function is called, and a valid connection
    ///         exists, the command queue contents will be sent before the passed command.
    /// - Parameter Command: The command to send, formatted by the `MessageHelper` class.
    /// - Parameter DoNotQueue: If true, the command is not queued to be send when a connection becomes
    ///                         available. Defaults to false (meaning commands are queued).
    public static func SendPreformattedCommand(_ Command: String, DoNotQueue: Bool = false)
    {
        if MPMgr == nil
        {
            if !DoNotQueue
            {
                CommandQueue.Enqueue(Command)
                return
            }
            return
        }
        if let Destination = DestinationID
        {
            //If we're here and the command queue has something in it, we have a connection
            //so send the command queue commands first.
            while !CommandQueue.IsEmpty
            {
                let QCommand = CommandQueue.Dequeue()
                MPMgr?.SendPreformatted(Message: QCommand!, To: Destination)
            }
            //Now that the command queue is empty (or was empty when the function was entered),
            //send the command the caller wanted us to.
            MPMgr?.SendPreformatted(Message: Command, To: Destination)
        }
        else
        {
            CommandQueue.Enqueue(Command)
        }
    }
    
    /// Queue of unsent commands. Used from `SendPreformattedCommand` when there is no connection.
    static var CommandQueue = Queue<String>()
    
    /// Returns the number of commands queued for sending.
    /// - Returns: Number of commands in the command queue.
    public static func CommandQueueCount() -> Int
    {
        return CommandQueue.Count
    }
    
    /// Send all commands in the command queue to the TDebug instance.
    /// - Returns: True if a valid connection exists, false if not.
    @discardableResult public static func SendCommandQueue() -> Bool
    {
        if !HaveValidConnection()
        {
            return false
        }
        while !CommandQueue.IsEmpty
        {
            let Command = CommandQueue.Dequeue()
            MPMgr?.SendPreformatted(Message: Command!, To: DestinationID!)
        }
        return true
    }
    
    /// Determines if this instance has a valid connection with the remove TDebug instance.
    /// - Returns: True if a connection exists, false if not.
    public static func HaveValidConnection() -> Bool
    {
        if DestinationID == nil
        {
            return false
        }
        if MPMgr == nil
        {
            return false
        }
        return true
    }
    
    /// Send a fatal error message to the debugger.
    ///
    /// - Note: Control never returns from this function.
    ///
    /// - Parameter Message: The message to send to the debugger.
    public static func FatalError(_ Message: String) -> Never
    {
        Send("Fatal error: " + Message)
        fatalError(Message)
    }
    
    /// Send a fatal error message to the debugger.
    ///
    /// - Note: Control never returns from this function.
    ///
    /// - Parameter Message: The message to send to the debugger.
    /// - Parameter InFile: The file in which the fatal error occured.
    /// - Parameter InFunction: The function in which the fatal error occurred.
    /// - Parameter OnLine: The line (approximate) on which the fatal error occurred.
    public static func FatalError(_ Message: String, InFile: String, InFunction: String, OnLine: Int) -> Never
    {
        let FinalString = "Fatal error [File: \(InFile), Function: \(InFunction), Line: \(OnLine)]: \(Message)"
        Send(FinalString)
        fatalError(FinalString)
    }
}

/// Idiot lights in TDebug.
/// - **A1**: Usually not settable by clients (reserved by TDebug itself).
/// - **A2**: Top row middle.
/// - **A3**: Top row right.
/// - **B1**: Middle row left.
/// - **B2**: Middle row middle.
/// - **B3**: Middle row right.
/// - **C1**: Bottom row left.
/// - **C2**: Bottom row middle.
/// - **C3**: Bottom row right.
enum IdiotLights: String, CaseIterable
{
    case A1 = "A1"
    case A2 = "A2"
    case A3 = "A3"
    case B1 = "B1"
    case B2 = "B2"
    case B3 = "B3"
    case C1 = "C1"
    case C2 = "C2"
    case C3 = "C3"
}
