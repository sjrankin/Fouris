//
//  PieceBlockLocation.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds one block's location from the piece definition file.
class PieceBlockLocation
{
    /// Holds the block index.
    private var _Index: Int = 0
    /// Get or set the index of the block.
    public var Index: Int
    {
        get
        {
            return _Index
        }
        set
        {
            _Index = newValue
        }
    }
    
    /// Holds the coordinates of the block.
    private var _Coordinates: Point3D<Int> = Point3D<Int>(0, 0, 0) 
    /// Get or set the coordinates of the block.
    public var Coordinates: Point3D<Int>
    {
        get
        {
            return _Coordinates
        }
        set
        {
            _Coordinates = newValue
        }
    }
    
    /// Holds the block is origin flag.
    private var _IsOrigin: Bool = false
    /// Get or set the block origin flag.
    public var IsOrigin: Bool
    {
        get
        {
            return _IsOrigin
        }
        set
        {
            _IsOrigin = newValue
        }
    }
}


