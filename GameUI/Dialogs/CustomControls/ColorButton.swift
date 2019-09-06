//
//  ColorButton.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ColorButton: UIButton
{
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        self.setTitle("", for: .normal)
        self.backgroundColor = UIColor.clear
        ButtonColor = UIColor.green
    }
    
    private var _ButtonColor: UIColor = UIColor.white
    @IBInspectable var ButtonColor: UIColor
        {
        get
        {
            return _ButtonColor
        }
        set
        {
            _ButtonColor = newValue
            SetButtonColor(To: newValue)
            self.setNeedsLayout()
            self.setNeedsDisplay()
        }
    }
    
    func SetButtonColor(To: UIColor)
    {
        self.layer.cornerRadius = 5.0
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor.black.cgColor
        let Size = self.bounds.size
        print("ColorButton: Size=\(Size)")
        let ColorImage = UIImage(Color: To, Size: Size)
        self.setImage(ColorImage, for: .normal)
    }
}
