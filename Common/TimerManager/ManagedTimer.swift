//
//  ManagedTimer.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/13/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ManagedTimer
{
    #if false
    typealias ManagedTimerHandler = () -> ()
    
    init(_ TimerID: UUID, Handler: (ManagedTimerHandler)?)
    {
        _ID = TimerID
    }
    
    private var LLTimer: Timer? = nil
    
    private var _TimerHandler: ManagedTimerHandler? = nil
    public var TimerHandler: ManagedTimerHandler?
    {
        get
        {
            return _TimerHandler
        }
        set
        {
            _TimerHandler = newValue
        }
    }
    
    private var _ID: UUID = UUID.Empty
    public var ID: UUID
    {
        get
        {
            return _ID
        }
    }
    
    public func Start(Duration: Double, Repeats: Bool)
    {
        LLTimer = Timer.scheduledTimer(timeInterval: Duration, target: self, selector: #selector(LLTimerHandler),
                                       userInfo: nil, repeats: Repeats)
    }
    
    public func Start(Duration: Double, Repeated: Bool, Handler: ManagedTimerHandler)
    {
        _TimerHandler = Handler
        Start(Duration: Duration, Repeats: Repeats)
    }
    
    @objc func LLTimerHandler()
    {
        Handler()
    }
    
    public func Stop()
    {
        LLTimer?.invalidate()
        LLTimer = nil
    }
    #endif
}
