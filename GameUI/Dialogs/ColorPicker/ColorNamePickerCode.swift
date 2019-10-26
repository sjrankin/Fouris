//
//  ColorNamePickerCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/31/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Runs the UI for the color name picker. Color names are in a shallow heirerachy of a set of groups - each group has its own
/// set of colors. The user can select the group, then a color from the group.
class ColorNamePickerCode: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, ColorPickerProtocol
{
    /// The delegate to receive color-related messages.
    public weak var ColorDelegate: ColorPickerProtocol? = nil
    
    /// Current selected color.
    public var SelectedColor: UIColor!
    
    /// Initialize the UI.
    override public func viewDidLoad()
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
        ColorGroupColors = PredefinedColors.SortColorList(ColorGroupColors, By: ColorOrders.Name)
        ColorPickerView.delegate = self
        ColorPickerView.dataSource = self
        ColorPickerView.reloadAllComponents()
        if Settings.GetShowClosestColor()
        {
            SelectClosestColor(SelectedColor)
        }
    }
    
    /// List of color group names.
    private var ColorGroups: [String]!
    
    /// List of color group colors.
    public var ColorGroupColors: [PredefinedColor]!
    
    /// Select the closet color in the set of colors we are working with to the passed color. The UI will be updated to show the
    /// selected color.
    /// - Note: Close is defined by distantce in a three-dimensional color space. All colors here are in RGB colorspace regardless
    ///         of how they are defined.
    /// - Parameter Color: The color to search for.
    public func SelectClosestColor(_ Color: UIColor)
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
            ColorGroupColors = PredefinedColors.SortColorList(ColorGroupColors, By: ColorOrders.Name)
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
    
    /// Update the selected color UI with the passed color.
    /// - Parameter WithColor: The color to select.
    public func UpdateSelectedColor(WithColor: UIColor)
    {
        SelectedColor = WithColor
        ColorSample.backgroundColor = SelectedColor
        ColorSampleName.text = "not found in color list"
        UpdateColorValues(WithColor)
    }
    
    /// Update the selected color UI with the passed color.
    /// - Parameter WithColor: The predefined color to select.
    public func UpdateSelectedColor(WithColor: PredefinedColor)
    {
        SelectedColor = WithColor.Color
        ColorSample.backgroundColor = SelectedColor
        ColorSampleName.text = WithColor.ColorName
        UpdateColorValues(WithColor.Color)
    }
    
    /// Update text representations of the color.
    /// - Parameter Color: The color to display.
    public func UpdateColorValues(_ Color: UIColor)
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
    
    /// Returns the number of components in the picker view.
    /// - Returns: Two - one for the group and one for colors within the group.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 2
    }
    
    /// Returns the width for each component in the picker view.
    /// - Parameter pickerView: Not used.
    /// - Parameter widthForComponent: Indicates which component needs a width.
    /// - Returns: Value for the width of a component. The group component is 35% of the full picker width, and the color
    ///            component is 65% of the full picker width.
    public func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat
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
    
    /// Returns the number of rows in a component in the picker view.
    /// - Parameter pickerView: Not used.
    /// - Parameter numberOfRowsInComponent: Which component needs the number of rows.
    /// - Returns: The number of rows for the specified component.
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        if component == 0
        {
            return ColorGroups.count
        }
        return ColorGroupColors.count
    }
    
    /// Returns the contents of a row for a given component in the picker view.
    /// - Parameter pickerView: Not used.
    /// - Parameter titleForRow: The string for the component row.
    /// - Parameter forComponent: The component whose row we are returning a title.
    /// - Returns: Title for the given component and row.
    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
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
    
    /// Called when the user selects a row in the picker view. This is called when the user selects a new color group or
    /// new color within a group.
    /// - Parameter pickerView: Not used.
    /// - Parameter didSelectRow: The selected row.
    /// - Parameter inComponent: The selected component.
    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        if component == 0
        {
            ColorGroupColors = PredefinedColors.GetColorsIn(Group: ColorGroups[row])
            ColorGroupColors = PredefinedColors.SortColorList(ColorGroupColors, By: ColorOrders.Name)
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
    
    /// Tag sent by the caller.
    private var ParentTag: Any? = nil
    
    /// Called by the parent to set the color to edit.
    /// - Parameter Color: The original color.
    /// - Parameter Tag: The tag which this class will return to the caller when the dialog closes.
    public func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
        ParentTag = Tag
    }
    
    /// Not used in this class.
    public func EditedColor(_ Edited: UIColor?, Tag: Any?)
    {
        //Not used here.
    }
    
    /// Handle the OK button pressed. Notify the caller of a (possibly) new color. Close the dialog.
    /// - Parameter sender: Not used.
    @IBAction public func HandleOKPressed(_ sender: Any)
    {
        ColorDelegate?.EditedColor(SelectedColor, Tag: ParentTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the Cancel button pressed. Tell the caller the dialog was canceled. Close the dialog.
    /// - Parameter sender: Not used.
    @IBAction public func HandleCancelPressed(_ sender: Any)
    {
        ColorDelegate?.EditedColor(nil, Tag: ParentTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle changes to the nearest color switch.
    /// - Parameter sender: Not used.
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
