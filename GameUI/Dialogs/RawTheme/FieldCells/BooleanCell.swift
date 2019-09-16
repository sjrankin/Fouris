//
//  BooleanCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class BooleanCell: FieldCell
{
    override func DrawUI()
    {
        if !WasInitialized
        {
            return
        }
        FieldLabel = UILabel(frame: CGRect(x: 5, y: 3, width: ParentWidth / 2, height: 69))
        contentView.addSubview(FieldLabel!)
        FieldLabel?.text = FieldTitle
        StyleTitle(FieldLabel!)
        let SwitchX = ParentWidth - 80
        let SwitchY = (FieldCell.FieldCellHeight / 2.0) - (31.0 / 2.0)
        Switch = UISwitch(frame: CGRect(x: SwitchX, y: SwitchY, width: 51, height: 31))
        contentView.addSubview(Switch)
        Switch.isOn = Current as! Bool
        Switch.addTarget(self, action: #selector(HandleSwitchChange), for: UIControl.Event.valueChanged)
    }
    
    var Switch: UISwitch!
    
    @objc func HandleSwitchChange(sender: UISwitch)
    {
        Current = Switch.isOn
        if let Handler = ChangeHandler
        {
            Handler(Current as Any)
            return
        }
        FieldDelegate?.EditedField(ID, NewValue: Switch.isOn, DefaultValue: Default as Any, FieldType: FieldType)
    }
}
