//
//  Vector3Cell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Vector3Cell: FieldCell
{
    override func DrawUI()
    {
        if !WasInitialized
        {
            return
        }
        CurrentValue = Current as? SCNVector3
        FieldLabel = UILabel(frame: CGRect(x: 5, y: 3, width: ParentWidth / 2, height: 69))
        contentView.addSubview(FieldLabel!)
        FieldLabel?.text = FieldTitle
        StyleTitle(FieldLabel!)
        let TextX: CGFloat = ParentWidth - 270
        let InputWidth: CGFloat = 75.0
        
        TextBoxX = UITextField(frame: CGRect(x: TextX, y: 15.0, width: InputWidth, height: 40.0)) 
        StyleTextBox(TextBoxX)
        TextBoxX.text = "\(CurrentValue.x)"
        TextBoxX.addTarget(self, action: #selector(HandleTextXChange), for: UIControl.Event.valueChanged)
        contentView.addSubview(TextBoxX)
        
        TextBoxY = UITextField(frame: CGRect(x: TextX + InputWidth + 5, y: 15, width: InputWidth, height: 40))
        StyleTextBox(TextBoxY)
        TextBoxY.text = "\(CurrentValue.y)"
        TextBoxY.addTarget(self, action: #selector(HandleTextYChange), for: UIControl.Event.valueChanged)
        contentView.addSubview(TextBoxY)
        
        TextBoxZ = UITextField(frame: CGRect(x: TextX + InputWidth + 5 + InputWidth + 5, y: 15, width: InputWidth, height: 40))
        StyleTextBox(TextBoxZ)
        TextBoxZ.text = "\(CurrentValue.z)"
        TextBoxZ.addTarget(self, action: #selector(HandleTextZChange), for: UIControl.Event.valueChanged)
        contentView.addSubview(TextBoxZ)
    }
    
    var CurrentValue: SCNVector3!
    var TextBoxX: UITextField!
    var TextBoxY: UITextField!
    var TextBoxZ: UITextField!
    
    @objc func HandleTextXChange(sender: UITextField)
    {
        let TextBox = sender
        if let Raw = TextBox.text
        {
            if let RawValue = Float(Raw)
            {
                Current = SCNVector3(RawValue, CurrentValue.y, CurrentValue.z)
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
    
    @objc func HandleTextYChange(sender: UITextField)
    {
        let TextBox = sender
        if let Raw = TextBox.text
        {
            if let RawValue = Float(Raw)
            {
                Current = SCNVector3(CurrentValue.x, RawValue, CurrentValue.z)
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
    
    @objc func HandleTextZChange(sender: UITextField)
    {
        let TextBox = sender
        if let Raw = TextBox.text
        {
            if let RawValue = Float(Raw)
            {
                Current = SCNVector3(CurrentValue.x, CurrentValue.y, RawValue)
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
