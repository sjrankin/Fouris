//
//  TimerExtensions.swift
//  Fouris
//
//  Created by Stuart Rankin on 11/17/26.
//

import Foundation

/// Timer helpers.
extension Timer
{
    /// Creates a timer and adds it to the main run loop. Equivalent to `scheduledTimer`, which Swift marks as unavailable from
    /// asynchronous contexts, so main-actor tasks use this instead.
    /// - Parameters:
    ///   - timeInterval: Seconds between firings.
    ///   - target: Object that receives the selector call.
    ///   - selector: Method called when the timer fires.
    ///   - userInfo: Optional user information.
    ///   - repeats: If true, the timer repeats until invalidated.
    /// - Returns: The scheduled timer.
    @MainActor static func scheduledOnMainRunLoop(timeInterval: TimeInterval, target: Any, selector: Selector,
                                                  userInfo: Any?, repeats: Bool) -> Timer
    {
        let NewTimer = Timer(timeInterval: timeInterval, target: target, selector: selector, userInfo: userInfo, repeats: repeats)
        RunLoop.main.add(NewTimer, forMode: .common)
        return NewTimer
    }
}
