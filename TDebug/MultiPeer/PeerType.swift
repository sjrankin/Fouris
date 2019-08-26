//
//  PeerType.swift
//  Fouris
//
//  Created by Stuart Rankin on 6/11/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Will contain peer information.
class PeerType
{
    /// Default initializer.
    init()
    {
    }
    
    /// Holds the peer-identified name.
    private var _PeerTitle: String = ""
    /// Get or set the peer-specified name for itself.
    public var PeerTitle: String
    {
        get
        {
            return _PeerTitle
        }
        set
        {
            _PeerTitle = newValue
        }
    }
    
    /// Holds the peer is a debugger flag.
    private var _PeerIsDebugger: Bool = false
    /// Get or set the peer is a debugger flag.
    public var PeerIsDebugger: Bool
    {
        get
        {
            return _PeerIsDebugger
        }
        set
        {
            _PeerIsDebugger = newValue
        }
    }
    
    /// Holds the peer's prefix.
    private var _PeerPrefixID: UUID? = nil
    /// Get or set the peer's prefix value.
    public var PeerPrefixID: UUID?
    {
        get
        {
            return _PeerPrefixID
        }
        set
        {
            _PeerPrefixID = newValue
        }
    }
}
