//
//  Vector4Cell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class Vector4Cell: FieldCell
{
    override func DrawUI()
    {
        if !WasInitialized
        {
            return
        }
        CurrentValue = Current as? SCNVector4
        FieldLabel = UILabel(frame: CGRect(x: 5, y: 3, width: ParentWidth / 2, height: 69))
        contentView.addSubview(FieldLabel!)
        FieldLabel?.text = FieldTitle
        StyleTitle(FieldLabel!)
        let TextX: CGFloat = ParentWidth - 320
        let InputWidth: CGFloat = 70.0
        
        TextBoxX = UITextField(frame: CGRect(x: TextX, y: 15, width: InputWidth, height: 40))
        StyleTextBox(TextBoxX)
        TextBoxX.text = "\(CurrentValue.x)"
        TextBoxX.addTarget(self, action: #selector(HandleTextXChange), for: UIControl.Event.valueChanged)
        contentView.addSubview(TextBoxX)
        
        TextBoxY = UITextField(frame: CGRect(x: TextX + InputWidth + 5, y: 15, width: InputWidth, height: 40))
        StyleTextBox(TextBoxY)
        TextBoxY.text = "\(CurrentValue.y)"
        TextBoxY.addTarget(self, action: #selector(HandleTextYChange), for: UIControl.Event.valueChanged)
        contentView.addSubview(TextBoxY)
        
        TextBoxZ = UITextField(frame: CGRect(x: TextX + (InputWidth + 5) * 2.0, y: 15, width: InputWidth, height: 40))
        StyleTextBox(TextBoxZ)
        TextBoxZ.text = "\(CurrentValue.z)"
        TextBoxZ.addTarget(self, action: #selector(HandleTextZChange), for: UIControl.Event.valueChanged)
        contentView.addSubview(TextBoxZ)
        
        TextBoxW = UITextField(frame: CGRect(x: TextX + (InputWidth + 5) * 3.0, y: 15, width: InputWidth, height: 40))
        StyleTextBox(TextBoxW)
        TextBoxW.text = "\(CurrentValue.w)"
        TextBoxW.addTarget(self, action: #selector(HandleTextWChange), for: UIControl.Event.valueChanged)
        contentView.addSubview(TextBoxW)
    }
    
    var CurrentValue: SCNVector4!
    var TextBoxX: UITextField!
    var TextBoxY: UITextField!
    var TextBoxZ: UITextField!
    var TextBoxW: UITextField!
    
    @objc func HandleTextXChange(sender: UITextField)
    {
        let TextBox = sender
        if let Raw = TextBox.text
        {
            if let RawValue = Float(Raw)
            {
                Current = SCNVector4(RawValue, CurrentValue.y, CurrentValue.z, CurrentValue.w)
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
                Current = SCNVector4(CurrentValue.x, RawValue, CurrentValue.z, CurrentValue.w)
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
                Current = SCNVector4(CurrentValue.x, CurrentValue.y, RawValue, CurrentValue.w)
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
    
    @objc func HandleTextWChange(sender: UITextField)
    {
        let TextBox = sender
        if let Raw = TextBox.text
        {
            if let RawValue = Float(Raw)
            {
                Current = SCNVector4(CurrentValue.x, CurrentValue.y, CurrentValue.z, RawValue)
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
