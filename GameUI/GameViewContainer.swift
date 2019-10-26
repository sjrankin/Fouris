//
//  GameViewContainer.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains the game view. Used to implement the `ParentSizeChangedProtocol`.
class GameViewContainer: UIView
{
    /// Initializer.
    /// - Parameter frame: The view's frame.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Set the bounds of the parent. Notifies all sub-views.
    override var bounds: CGRect
        {
        didSet
        {
            for View in self.subviews
            {
                let ChildView = View as? ParentSizeChangedProtocol
                ChildView?.NewParentSize(Bounds: self.bounds, Frame: self.frame)
            }
        }
    }
}
