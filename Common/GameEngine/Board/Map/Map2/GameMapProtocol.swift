//
//  GameMapProtocol.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/21/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Protocol used to communicate from the game map and its consumers.
protocol GameMapProtocol: class
{
    /// Called when a node in the bucket was changed.
    /// - Note: Only called when individual nodes are changed. Other functions are provided
    ///         for mass changes.
    /// - Parameter X: The horizontal coordinate of the changed node.
    /// - Parameter Y: The vertical coordinate of the changed node.
    /// - Parameter Node: The new value at the location.
    func BucketChanged(X: Int, Y: Int, Node: MapNodes)
    
    /// Called when the entire map is rotated.
    /// - Parameter Right: If true, the map was rotated right (clockwise), otherwise, the
    ///                    map was rotated left (counterclockwise).
    func MapRotated(Right: Bool)
    
    /// Called when the contents of the bucket were rotated.
    /// - Parameter By180: If true, the contents were rotated by 180°.
    func BucketRotated(By180: Bool)
    
    /// Called when a row is deleted.
    /// - Parameter Row: The index of the row that was deleted.
    func RowDeleted(Row: Int)
    
    /// Called when the game map is reset.
    func GameMapReset()
}
