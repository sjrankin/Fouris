//
//  ColorPickerCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/31/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ColorPickerCode: UIViewController, ColorPickerProtocol
{
    weak var ColorDelegate: ColorPickerProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        ColorDelegate?.EditedColor(nil, Tag: DelegateTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
        DelegateTag = Tag
    }
    
    private var DelegateTag: Any? = nil
    
    func EditedColor(_ Color: UIColor?, Tag: Any?)
    {
        //Should not be called.
    }
}
