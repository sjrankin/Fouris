//
//  IntExtensions.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation

/// Int extensions.
extension Int
{
    /// Returns true if the instance value is divisible by 2, false i not.
    public var IsEven: Bool
    {
        return self.isMultiple(of: 2)
    }
}
