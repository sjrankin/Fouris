//
//  TDebugProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/21/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol for the DebugClient class to communicate with its instantiating class.
protocol TDebugProtocol: class
{
    /// Called when the connection status between this instance and the remote TDebug instance changes.
    /// - Parameter Connected: Will be true if there is a valid connection, false if not.
    func RemoteConnectionStateChanged(Connected: Bool)
}
