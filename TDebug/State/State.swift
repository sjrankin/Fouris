//
//  State.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Manages state for connections. Specifically used for when one peer tries to use
/// another peer as the debug dump.
class State
{
    /// Initialize the state.
    /// - Note: This function **must** be called prior to calling other functions in this
    ///         class. If this function is not called, a fatal error will result.
    /// - Parameter WithDelegate: Delegate that will receive state change notifications.
    public static func Initialize(WithDelegate: StateProtocol)
    {
        IsInitialized = true
        _CurrentState = .Available
        Delegate = WithDelegate
    }
    
    /// Holds the delegate for the state.
    private static weak var Delegate: StateProtocol? = nil
    
    /// Holds the initialized flag.
    private static var IsInitialized = false
    
    /// Attempts to transition to the new state.
    /// - Note: If `Initialize` is not called sometime prior to this call, this function will result in
    ///         a fatal error.
    /// - Parameter NewState: The new state to transition to.
    /// - Returns: The result of the transition request.
    @discardableResult public static func TransitionTo(NewState: HandShakeCommands) -> HandShakeCommands
    {
        if !IsInitialized
        {
            fatalError("State is not initialized.")
        }
        switch NewState
        {
        case .RequestConnection:
            if CurrentState == .Available
            {
                _CurrentState = .Unavailable
                LastHandShake = .ConnectionGranted
                Delegate?.StateChanged(NewState: .Unavailable, HandShake: .ConnectionGranted)
                return LastHandShake
            }
            else
            {
                LastHandShake = .ConnectionRefused
                Delegate?.StateChanged(NewState: _CurrentState, HandShake: .ConnectionRefused)
                return LastHandShake
            }
            
        case .ConnectionClose:
            _CurrentState = .Available
            LastHandShake = .Disconnected
            Delegate?.StateChanged(NewState: .Available, HandShake: .Disconnected)
            return .Disconnected
            
        default:
            break
        }
        
        LastHandShake = .Unknown
        Delegate?.StateChanged(NewState: _CurrentState, HandShake: .Unknown)
        return .Unknown
    }
    
    /// Holds the last handshake command.
    private static var LastHandShake: HandShakeCommands = .Unknown
    
    /// Holds the current state.
    private static var _CurrentState: States = .Available
    /// Returns the current state.
    /// - Note: If `Initialize` is not called when at sometime prior to this property,
    ///         a fatal error will occur.
    public static var CurrentState: States
    {
        get
        {
            if !IsInitialized
            {
                fatalError("State is not initialized.")
            }
            return _CurrentState
        }
    }
}

/// States supported.
/// - **Available**: State is available.
/// - **Unavilable**: State is unavailable.
enum States
{
    case Available
    case Unavailable
}
