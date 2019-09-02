//
//  ColorNamePickerCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/31/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ColorNamePickerCode: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ColorPickerProtocol
{
    public weak var ColorDelegate: ColorPickerProtocol? = nil
    var SelectedColor: UIColor!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        TopView.layer.backgroundColor = UIColor.clear.cgColor
        ValueView.layer.backgroundColor = UIColor.clear.cgColor
        ButtonView.layer.backgroundColor = UIColor.clear.cgColor
        ColorPickerView.backgroundColor = UIColor.clear
        
        NearestColorSwitch.isOn = Settings.GetShowClosestColor()
        ColorSample.layer.borderColor = UIColor.black.cgColor
        ColorSample.layer.borderWidth = 0.5
        ColorSample.layer.cornerRadius = 5.0
        UpdateSelectedColor(WithColor: UIColor.yellow)
        ColorGroups = PredefinedColors.GetColorGroupNames()
        ColorGroupColors = PredefinedColors.GetColorsIn(Group: ColorGroups[0])
        ColorGroupColors = PredefinedColors.SortColorList(ColorGroupColors, By: PredefinedColors.ColorOrders.Name)
        ColorPickerView.delegate = self
        ColorPickerView.dataSource = self
        ColorPickerView.reloadAllComponents()
        if Settings.GetShowClosestColor()
        {
            SelectClosestColor(SelectedColor)
        }
    }
    
    var ColorGroups: [String]!
    var ColorGroupColors: [PredefinedColor]!
    
    func SelectClosestColor(_ Color: UIColor)
    {
        var GroupCloseness = [String: (Int, Double)]()
        for GroupName in ColorGroups
        {
            let Colors = PredefinedColors.GetColorsIn(Group: GroupName)
            if let (Index, Distance) = PredefinedColors.GetClosestColorInEx(Group: Colors, ToColor: Color)
            {
                GroupCloseness[GroupName] = (Index, Distance)
            }
        }
        var ShortestIndex = Int.max
        var ShortestName = ""
        var ShortestDistance = Double.greatestFiniteMagnitude
        for (Name, Values) in GroupCloseness
        {
            if Values.1 < ShortestDistance
            {
                ShortestName = Name
                ShortestDistance = Values.1
                ShortestIndex = Values.0
            }
        }
        if let FullColor = PredefinedColors.GetColorIn(Group: ShortestName, At: ShortestIndex)
        {
            print("Closest color to \(Utility.ColorToString(Color)) is \(FullColor.ColorName) in \(ShortestName)")
            let GroupIndex = ColorGroups.firstIndex(of: ShortestName)
            ColorPickerView.selectRow(GroupIndex!, inComponent: 0, animated: true)
            ColorGroupColors = PredefinedColors.GetColorsIn(Group: ColorGroups[GroupIndex!])
            ColorGroupColors = PredefinedColors.SortColorList(ColorGroupColors, By: PredefinedColors.ColorOrders.Name)
            ColorPickerView.reloadComponent(1)
            var Index = 0
            for SomeColor in ColorGroupColors
            {
                if SomeColor.Color == Color
                {
                    ColorPickerView.selectRow(Index, inComponent: 1, animated: true)
                    UpdateSelectedColor(WithColor: SomeColor)
                }
                Index = Index + 1
            }
        }
    }
    
    func UpdateSelectedColor(WithColor: UIColor)
    {
        SelectedColor = WithColor
        ColorSample.backgroundColor = SelectedColor
        ColorSampleName.text = "not found in color list"
        UpdateColorValues(WithColor)
    }
    
    func UpdateSelectedColor(WithColor: PredefinedColor)
    {
        SelectedColor = WithColor.Color
        ColorSample.backgroundColor = SelectedColor
        ColorSampleName.text = WithColor.ColorName
        UpdateColorValues(WithColor.Color)
    }
    
    func UpdateColorValues(_ Color: UIColor)
    {
        var Red: CGFloat = 0.0
        var Green: CGFloat = 0.0
        var Blue: CGFloat = 0.0
        var NotUsed: CGFloat = 0.0
        Color.getRed(&Red, green: &Green, blue: &Blue, alpha: &NotUsed)
        let IRed = Int(Red * 255.0)
        let IGreen = Int(Green * 255.0)
        let IBlue = Int(Blue * 255.0)
        let RGBString = "\(IRed),\(IGreen),\(IBlue)"
        RGBout.text = RGBString
        let RedX = String(format: "%02x", IRed)
        let GreenX = String(format: "%02x", IGreen)
        let BlueX = String(format: "%02x", IBlue)
        let HexString = "0x\(RedX)\(GreenX)\(BlueX)"
        HexOut.text = HexString
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
    {
        let FullWidth = ColorPickerView.frame.width
        if component == 0
        {
            return FullWidth * 0.35
        }
        else
        {
            return FullWidth * 0.65
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if component == 0
        {
            return ColorGroups.count
        }
        return ColorGroupColors.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        if component == 0
        {
            return ColorGroups[row]
        }
        else
        {
            return ColorGroupColors[row].ColorName
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if component == 0
        {
            ColorGroupColors = PredefinedColors.GetColorsIn(Group: ColorGroups[row])
            ColorGroupColors = PredefinedColors.SortColorList(ColorGroupColors, By: PredefinedColors.ColorOrders.Name)
            pickerView.reloadComponent(1)
            if Settings.GetShowClosestColor()
            {
                let NewColorIndex = PredefinedColors.GetClosestColorIn(Group: ColorGroupColors, ToColor: SelectedColor)
                ColorPickerView.selectRow(NewColorIndex!, inComponent: 1, animated: true)
                UpdateSelectedColor(WithColor: ColorGroupColors[NewColorIndex!])
            }
        }
        else
        {
            let SelectedColor = ColorGroupColors[row]
            UpdateSelectedColor(WithColor: SelectedColor)
        }
    }
    
    private var ParentTag: Any? = nil
    
    func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
        ParentTag = Tag
    }
    
    func EditedColor(_ Edited: UIColor?, Tag: Any?)
    {
        //Not used here.
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        ColorDelegate?.EditedColor(SelectedColor, Tag: ParentTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        ColorDelegate?.EditedColor(nil, Tag: ParentTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleNearestColorSwitchChanged(_ sender: Any)
    {
        Settings.SetShowClosestColor(NewValue: NearestColorSwitch.isOn)
    }
    
    @IBOutlet weak var ButtonView: UIView!
    @IBOutlet weak var ValueView: UIView!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var ColorPickerView: UIPickerView!
    @IBOutlet weak var NearestColorSwitch: UISwitch!
    @IBOutlet weak var RGBout: UILabel!
    @IBOutlet weak var HexOut: UILabel!
    @IBOutlet weak var ColorSampleName: UILabel!
    @IBOutlet weak var ColorSample: UIView!
}
