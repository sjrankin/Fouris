//
//  ArrayStatistics.swift
//  Fouris
//
//  Created by Stuart Rankin on 7/4/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Simple statistics with arrays of Doubles.
class Statistics
{
    /// Returns the median value of the passed array.
    /// - Parameter ArrayData: Array whose median value will be returned.
    /// - Returns: Median value of the passed array. Nil if the array is empty.
    public static func Median(_ ArrayData: Array<Double>) -> Double?
    {
        if ArrayData.count < 1
        {
            return nil
        }
        let Sorted = ArrayData.sorted()
        let Count = Sorted.count
        if Count % 2 == 0
        {
            let Middle = Count / 2
            return (Double(Sorted[Middle]) + Double(Sorted[Middle - 1])) / 2.0
        }
        return Double(Sorted[(Count - 1) / 2])
    }
    
    /// Returns the mean value of the passed array.
    /// - Parameter ArrayData: Array whose mean value will be returned.
    /// - Returns: Mean value of the passed array. Nil if the array is empty.
    public static func Mean(_ ArrayData: Array<Double>) -> Double?
    {
        if ArrayData.count < 1
        {
            return nil
        }
        return Double(ArrayData.reduce(0,+)) / Double(ArrayData.count)
    }
    
    /// Returns the standard deviation of the passed array.
    /// - Parameter ArrayData: Array whose standard deviation will be returned.
    /// - Returns: Standard deviation of the passed array. Nil if the array is empty.
    public static func StandardDeviation(_ ArrayData: Array<Double>) -> Double?
    {
        if ArrayData.count < 1
        {
            return nil
        }
        let Expression = NSExpression(forFunction: "stddev:", arguments: [NSExpression(forConstantValue: ArrayData)])
        let StdDev: Double = Expression.expressionValue(with: nil, context: nil) as! Double
        return StdDev
    }
}
