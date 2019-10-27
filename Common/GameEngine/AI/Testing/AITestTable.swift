//
//  AITestTable.swift
//  Fouris
//
//  Created by Stuart Rankin on 4/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Maintains AI test data.
class AITestTable
{
    /// Default initializer.
    init()
    {
    }
    
    /// Delegate for notifying other classes of data changes.
    weak var Delegate: AITestDataUpdatedProtocol? = nil
    
    /// Table of AI test data.
    var TestData = [(AIScoringMethods, AITestNode)]()
    
    /// Subscript operator to get the specified test data.
    /// - Parameter Index: Index of the test data to return. Nil return if the index if out of range.
    subscript(Index: Int) -> AITestNode?
    {
        get
        {
            if Index < 0 || Index > TestData.count - 1
            {
                return nil
            }
            return TestData[Index].1
        }
    }
    
    /// Return the number of test nodes in the test data table.
    public var Count: Int
    {
        get
        {
            return TestData.count
        }
    }
    
    /// Add a test node to the table.
    /// - Parameter Node: Test data node to add.
    public func AddTest(_ Node: AITestNode)
    {
        TestData.append((Node.ScoringType, Node))
        Delegate?.DataUpdated()
    }
    
    /// Add test data to the table.
    /// - Parameters:
    ///   - Method: The AI scoring method.
    ///   - Duration: Duration of the game in seconds.
    ///   - Score: Score of the game.
    ///   - Pieces: Number of pieces the game used.
    ///   - BucketSize: The size of the game bucket.
    ///   - Unreachable: The number of unreachable gaps at the end of the game.
    ///   - Reachable: The number of reachable gaps at the end of the game.
    public func AddTest(_ Method: AIScoringMethods, Duration: Double, Score: Double, Pieces: Int, BucketSize: CGSize,
                        Unreachable: Int, Reachable: Int)
    {
        AddTest(AITestNode(Method, Duration: Duration, Score: Score, Pieces: Pieces,
                           BucketSize: BucketSize, Unreachable: Unreachable, Reachable: Reachable))
    }
    
    /// Return all test nodes for the given AI scoring method.
    /// - Parameter Method: AI scoring method to return nodes for.
    /// - Returns: List of test nodes for the specified AI scoring method.
    public func GetNodesFor(Method: AIScoringMethods) -> [AITestNode]
    {
        var Results = [AITestNode]()
        for Test in TestData
        {
            if Test.0 == Method
            {
                Results.append(Test.1)
            }
        }
        return Results
    }
    
    /// Return mean data for the specified AI scoring method.
    /// - Parameter Method: Determines which means are returned.
    /// - Returns: Structure with the mean results. If no test nodes are available, nil is returned.
    public func MeanDataFor(Method: AIScoringMethods) -> MeanResults?
    {
        let Nodes = GetNodesFor(Method: Method)
        if Nodes.count < 1
        {
            return nil
        }
        var SumDuration = 0.0
        var SumPieces = 0.0
        var SumScore = 0.0
        var SumUnreachable = 0.0
        var SumReachable = 0.0
        for Node in Nodes
        {
            SumDuration = SumDuration + Node.RunDuration
            SumPieces = SumPieces + Double(Node.RunPieces)
            SumScore = SumScore + Double(Node.RunScore)
            SumUnreachable = SumUnreachable + Double(Node.UnreachableGapCount)
            SumReachable = SumReachable + Double(Node.ReachableGapCount)
        }
        let DCount = Double(Nodes.count)
        SumDuration = SumDuration / DCount
        SumPieces = SumPieces / DCount
        SumScore = SumScore / DCount
        SumUnreachable = SumUnreachable / DCount
        SumReachable = SumReachable / DCount
        let Results = MeanResults(TotalCount: Nodes.count, MeanDuration: SumDuration, MeanPieces: SumPieces,
                                  MeanScore: SumScore, MeanUnreachable: SumUnreachable, MeanReachable: SumReachable)
        return Results
    }
}

/// Holds mean test results on a per AI test scoring method basis.
public struct MeanResults
{
    /// Total test nodes/runs.
    let TotalCount: Int
    /// Mean duration of games in seconds.
    let MeanDuration: Double
    /// Mean number of pieces used in a game.
    let MeanPieces: Double
    /// Mean score per game.
    let MeanScore: Double
    /// Mean number of unreachable gaps at the end of a game.
    let MeanUnreachable: Double
    /// Mean number of reachable gaps at the end of a game.
    let MeanReachable: Double
}
