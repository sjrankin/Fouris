//
//  Coin.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/12/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Class that simulates a coin flip (for no other reason than why not?).
class Coin
{
    /// List of possible outcomes of a single coin flip.
    private static let Outcomes = [CoinFaces.Heads, CoinFaces.Tails]
    
    /// Flip the coin the specified number of times.
    ///
    /// - Parameter Times: Number of times to flip the coin. If a value less than 1 is passed,
    ///                    the coin will be flipped once. Default value is 1.
    /// - Returns: The value of the last coin flip.
    public static func Flip(_ Times: Int = 1) -> CoinFaces
    {
        var Result: CoinFaces? = nil
        let Count = Times < 1 ? 1: Times
        for _ in 0 ..< Count
        {
            Result = Outcomes.randomElement()
        }
        return Result!
    }
    
    /// Flip the coin the specified number of times and return the result of each flip.
    ///
    /// - Parameter Count: Number of times to flip the coin. If a value less than 1 is passed,
    ///                    the coin will be flipped once. Default value is 1.
    /// - Returns: The result of each coin flip in order of flip.
    public static func FlipTimes(Count: Int = 1) -> [CoinFaces]
    {
        var Result = [CoinFaces]()
        let TotalCount = Count < 1 ? 1: Count
        for _ in 0 ..< TotalCount
        {
            Result.append(Outcomes.randomElement()!)
        }
        return Result
    }
    
    /// Perform a skewed flip of the coin.
    ///
    /// - Parameters:
    ///   - To: The result that should occur `By` percent of the time.
    ///   - By: Percent of time that `To` should occur. If this value is less than 0 or greater than 1,
    ///         nil is returned.
    /// - Returns: Skewed coin flip.
    public static func SkewedFlip(To: CoinFaces, By: Double) -> CoinFaces?
    {
        if By < 0.0 || By > 1.0
        {
            return nil
        }
        let Rnd = Double.random(in: 0.0 ... 1.0)
        if Rnd >= By
        {
            return To
        }
        switch To
        {
        case .Heads:
            return .Tails
            
        case .Tails:
            return .Heads
        }
    }
}

enum CoinFaces: Int, CaseIterable
{
    case Heads = 0
    case Tails = 1
}
