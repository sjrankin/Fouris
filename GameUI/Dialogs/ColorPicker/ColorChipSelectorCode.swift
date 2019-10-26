//
//  ColorChipSelectorCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/31/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Not implemented yet.
class ColorChipSelectorCode: UIViewController, ColorPickerProtocol
{
    public weak var ColorDelegate: ColorPickerProtocol? = nil
    
    override public func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction public func HandleOKPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction public func HandleCancelPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction public func HandleSortPressed(_ sender: Any)
    {
    }
    
    public func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
    }
    
    public func EditedColor(_ Edited: UIColor?, Tag: Any?)
    {
    }
}
