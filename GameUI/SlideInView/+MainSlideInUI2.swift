//
//  +MainSlideInUI2.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Extension to **CommonViewController** to handle events and user interactions related to the slide in view.
extension MainViewController
{
    public func InitializeSlideIn()
    {
        SlideInSubView.layer.borderColor = ColorServer.CGColorFrom(ColorNames.ReallyDarkGray)
    }
}
