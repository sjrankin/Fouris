//
//  ColorCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ColorCell: FieldCell, ColorPickerProtocol
{
    override func DrawUI()
    {
        if !WasInitialized
        {
            return
        }
        CurrentColor = Current as? UIColor
        FieldLabel = UILabel(frame: CGRect(x: 5, y: 3, width: ParentWidth / 2, height: 69))
        contentView.addSubview(FieldLabel!)
        FieldLabel?.text = FieldTitle
        StyleTitle(FieldLabel!)
        let ColorSwatchWidth: CGFloat = 150.0
        let ColorSwatchX: CGFloat = ParentWidth - (ColorSwatchWidth + 20)
        ColorSwatch = ColorSwatchColor(frame: CGRect(x: ColorSwatchX, y: 5.0, width: ColorSwatchWidth, height: 65.0))
        ColorSwatch.TopColor = CurrentColor
        contentView.addSubview(ColorSwatch)
        contentView.addSubview(ColorSwatch)
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleTapGesture))
        Tap.numberOfTapsRequired = 1
        self.addGestureRecognizer(Tap)
        let NameWidth: CGFloat = (ColorSwatchX + 5) - (ParentWidth / 2.0)
        ColorLabel = UILabel(frame: CGRect(x: (ParentWidth / 2) - 20.0, y: 3, width: NameWidth, height: 69))
        ColorLabel.textAlignment = .right
        contentView.addSubview(ColorLabel)
        let ColorNames = PredefinedColors.NamesFrom(FindColor: CurrentColor)
        let ColorName: String? = ColorNames.count > 0 ? ColorNames[0] : nil
        ColorLabel.text = ColorName == nil ? "" : ColorName!
    }
    
    var ColorSwatch: ColorSwatchColor!
    var CurrentColor: UIColor!
    var ColorLabel: UILabel!
    
    func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
        //Not used in this class.
    }
    
    func EditedColor(_ Edited: UIColor?, Tag: Any?)
    {
        if let ReturnedTag = Tag as? String
        {
            if ReturnedTag == "FromColorCell"
            {
                if let EditedColor = Edited
                {
                    CurrentColor = EditedColor
                    ColorSwatch.TopColor = EditedColor
                    let ColorNames = PredefinedColors.NamesFrom(FindColor: CurrentColor)
                    let ColorName: String? = ColorNames.count > 0 ? ColorNames[0] : nil
                    ColorLabel.text = ColorName == nil ? "" : ColorName!
                }
            }
        }
    }
    
    @objc func HandleTapGesture(Gesture: UIGestureRecognizer)
    {
        if Gesture.state == .ended
        {
            let ColorControllerUI = UIStoryboard(name: "Theming", bundle: nil)
            let ColorController = ColorControllerUI.instantiateViewController(identifier: "ColorPicker") as! ColorPickerCode
            ColorController.ColorDelegate = self
            ColorController.ColorToEdit(CurrentColor, Tag: "FromColorCell")
            Parent?.present(ColorController, animated: true, completion: nil)
        }
    }
}
