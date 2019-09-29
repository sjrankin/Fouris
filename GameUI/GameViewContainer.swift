//
//  GameViewContainer.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GameViewContainer: UIView
{
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
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
