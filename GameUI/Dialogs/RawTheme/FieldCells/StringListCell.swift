//
//  StringListCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/17/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class StringListCell: FieldCell
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
        TextLabel = UILabel(frame: CGRect(x: ParentWidth - 100, y: 55, width: 80, height: 15))
        TextLabel.text = "Tap to change"
        TextLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.light)
        TextLabel.textAlignment = .right
        TextLabel.textColor = ColorServer.ColorFrom(ColorNames.ReallyDarkGray)
        contentView.addSubview(TextLabel)
        ValueLabel = UILabel(frame: CGRect(x: ParentWidth / 2.0, y: 5, width: (ParentWidth / 2.0) - 20.0, height: 65.0))
        ValueLabel.text = Current as? String
        ValueLabel.textColor = UIColor.blue
        ValueLabel.font = UIFont.systemFont(ofSize: 28.0, weight: UIFont.Weight.bold)
        ValueLabel.textAlignment = .right
        ValueLabel.isUserInteractionEnabled = true
        contentView.addSubview(ValueLabel)
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleTextTapped))
        Tap.numberOfTouchesRequired = 1
        ValueLabel.addGestureRecognizer(Tap)
    }
    
    @objc func HandleTextTapped(Recognizer: UIGestureRecognizer)
    {
        if Recognizer.state == .ended
        {
            var Message = StringListDescription.isEmpty ? "Select the value for the field." : StringListDescription
            let Alert = UIAlertController(title: "Select Option", message: Message, preferredStyle: UIAlertController.Style.alert)
            for Item in StringList
            {
                Alert.addAction(UIAlertAction(title: Item, style: UIAlertAction.Style.default, handler: NewSelection))
            }
            Alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
            Parent?.present(Alert, animated: true, completion: nil)
        }
    }
    
    @objc func NewSelection(Action: UIAlertAction)
    {
        for Item in StringList
        {
            if Item == Action.title
            {
                ValueLabel.text = Item
                Current = Item
                if let Handler = ChangeHandler
                {
                    Handler(Current as Any)
                    return
                }
                FieldDelegate?.EditedField(ID, NewValue: Current as Any, DefaultValue: Default as Any, FieldType: .StringList)
            }
        }
    }
    
    var ValueLabel: UILabel!
    var TextLabel: UILabel!
}
