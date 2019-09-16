//
//  DoubleCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class DoubleCell: FieldCell
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
        let TextX = ParentWidth - 200
        TextBox = UITextField(frame: CGRect(x: TextX, y: 15, width: 170, height: 40))
        StyleTextBox(TextBox)
        contentView.addSubview(TextBox)
        TextBox.text = "\(Current as! Double)"
        TextBox.addTarget(self, action: #selector(HandleTextChange), for: UIControl.Event.valueChanged)
    }
    
    var TextBox: UITextField!
    
    @objc func HandleTextChange(sender: UITextField)
    {
        if let Raw = TextBox.text
        {
            if let RawValue = Double(Raw)
            {
                Current = RawValue
                if let Handler = ChangeHandler
                {
                    Handler(Current as Any)
                    return
                }
                FieldDelegate?.EditedField(ID, NewValue: Current as Any, DefaultValue: Default as Any, FieldType: FieldType)
            }
            else
            {
                TextBox.text = ""
            }
        }
    }
}
