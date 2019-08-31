//
//  ColorPickerCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/31/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ColorPickerCode: UIViewController, ColorPickerProtocol, GSliderProtocol
{
    weak var ColorDelegate: ColorPickerProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        SampleColorView.layer.borderWidth = 0.5
        SampleColorView.layer.borderColor = UIColor.black.cgColor
        SampleColorView.layer.cornerRadius = 5.0
        SampleColorView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        ChannelALabel.text = "Red"
        ChannelBLabel.text = "Blue"
        ChannelCLabel.text = "Green"
        
        ButtonView.backgroundColor = UIColor.clear
        ColorspaceView.backgroundColor = UIColor.clear
        SampleView.backgroundColor = UIColor.clear
        TopView.backgroundColor = UIColor.clear
        
        ChannelAContainer.backgroundColor = UIColor.red
        ChannelBContainer.backgroundColor = UIColor.green
        ChannelCContainer.backgroundColor = UIColor.blue
    }
    
    /// The controller finished layout-ing out subviews, which means the position and size of the subviews is
    /// finalized and we can tell our sliders to refresh themselves to make sure the gradients are filled
    /// correctly.
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        InitializeWithColor()
    }
    
    func InitializeWithColor()
    {
        if SourceColor == nil
        {
            SourceColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        UpdateColor(WithColor: SourceColor!)
        UpdateSliders(WithColor: SourceColor!)
        
        let Colorspace = Settings.GetColorPickerColorSpace()
        ColorspaceSegment.selectedSegmentIndex = Colorspace
        UpdateColorspace()
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
        SourceColor = Color
    }
    
    private var SourceColor: UIColor? = nil
    
    private var CurrentColor: UIColor? = nil
    
    private var DelegateTag: Any? = nil
    
    func EditedColor(_ Color: UIColor?, Tag: Any?)
    {
        //Should not be called.
    }
    
    func UpdateColorspace()
    {
        switch Settings.GetColorPickerColorSpace()
        {
            case 0:
                SetRGB()
            
            case 1:
                SetHSB()
            
            case 2:
                SetYUV()
            
            default:
                break
        }
    }
    
    func SetRGB()
    {
        let Red = CurrentColor?.r
        let Green = CurrentColor?.g
        let Blue = CurrentColor?.b
        ChannelALabel.text = "Red"
        ChannelASlider.value = Float(1.0 - Double((Red)!))
        
        ChannelBLabel.text = "Green"
        ChannelBSlider.value = Float(1.0 - Double((Green)!))
        
        ChannelCLabel.text = "Blue"
        ChannelCSlider.value = Float(1.0 - Double((Blue)!))
    }
    
    func SetHSB()
    {
        let Hue = (CurrentColor?.Hue)!
        let Saturation = (CurrentColor?.Saturation)!
        let Brightness = (CurrentColor?.Brightness)!
        ChannelALabel.text = "Sat."
        ChannelASlider.value = Float(1.0 - Double(Saturation))
        
        ChannelBLabel.text = "Hue"
        ChannelBSlider.value = Float(Hue)
        
        ChannelCLabel.text = "Bri."
        ChannelCSlider.value = Float(1.0 - Double(Brightness))
    }
    
    func SetYUV()
    {
        ChannelALabel.text = "Y"
        ChannelBLabel.text = "U"
        ChannelCLabel.text = "V"
    }
    
    func NewSliderValue(Name: String, NewValue: Double)
    {
        //print("New slider value \(NewValue) from \(Name).")
        let rvalue = CGFloat(1.0 - ChannelASlider.value)
        let gvalue = CGFloat(1.0 - ChannelBSlider.value)
        let bvalue = CGFloat(1.0 - ChannelCSlider.value)
        var SampleColor = UIColor.red
        switch Settings.GetColorPickerColorSpace()
        {
            case 0:
                //RGB
                SampleColor = UIColor(red: rvalue, green: gvalue, blue: bvalue, alpha: 1.0)
            
            case 1:
                //HSB
                SampleColor = UIColor(hue: 1.0 - gvalue, saturation: rvalue, brightness: bvalue, alpha: 1.0)
            
            default:
                break
        }
        
        UpdateColor(WithColor: SampleColor)
    }
    
    @IBAction func HandleColorspaceChanged(_ sender: Any)
    {
        Settings.SetColorPickerColorSpace(NewValue: ColorspaceSegment.selectedSegmentIndex)
        UpdateColorspace()
        UpdateColor(WithColor: CurrentColor!)
    }
    
    func UpdateColor(WithColor: UIColor)
    {
        CurrentColor = WithColor
        SampleColorView.backgroundColor = WithColor
        let ColorValue = "#" + String(format: "%02x", Int(WithColor.r * 255.0)) +
            String(format: "%02x", Int(WithColor.g * 255.0)) +
            String(format: "%02x", Int(WithColor.b * 255.0))
        ColorValueLabel.text = ColorValue
        var ColorNames = PredefinedColors.NamesFrom(FindColor: WithColor)
        let ColorName: String? = ColorNames.count > 0 ? ColorNames[0] : nil
        switch ColorspaceSegment.selectedSegmentIndex
        {
            case 0:
                //RGB
                if ColorName == nil
                {
                    ColorNameLabel.text = "RGB" + Utility.ColorToString(WithColor, AsRGB: true, DeNormalize: true, IncludeAlpha: false)
                }
                else
                {
                    ColorNameLabel.text = ColorName
            }
            
            case 1:
                //HSB
                if ColorName == nil
                {
                    ColorNameLabel.text = "HSB" + Utility.ColorToString(WithColor, AsRGB: false, DeNormalize: false)
                }
                else
                {
                    ColorNameLabel.text = ColorName
            }
            
            default:
                break
        }
    }
    
    func UpdateSliders(WithColor: UIColor)
    {
        print("UpdateSliders\(Utility.ColorToString(WithColor, AsRGB: true, DeNormalize: true, IncludeAlpha: false))")
        ChannelASlider.value = Float(WithColor.r)
        ChannelBSlider.value = Float(WithColor.g)
        ChannelCSlider.value = Float(WithColor.b)
    }

    @IBAction func HandleChannelASliderChanged(_ sender: Any)
    {
        print("Channel A = \(ChannelASlider.value)")
    }
    
    @IBAction func HandleChannelBSliderChanged(_ sender: Any)
    {
        print("Channel B = \(ChannelBSlider.value)")
    }

    @IBAction func HandleChannelCSliderChanged(_ sender: Any)
    {
        print("Channel C = \(ChannelCSlider.value)")
    }
    
    @IBOutlet weak var ChannelALabel: UILabel!
    @IBOutlet weak var ChannelAContainer: UIView!
    @IBOutlet weak var ChannelASlider: UISlider!
    @IBOutlet weak var ChannelBLabel: UILabel!
    @IBOutlet weak var ChannelBContainer: UIView!
    @IBOutlet weak var ChannelBSlider: UISlider!
    @IBOutlet weak var ChannelCLabel: UILabel!
    @IBOutlet weak var ChannelCContainer: UIView!
    @IBOutlet weak var ChannelCSlider: UISlider!

    @IBOutlet weak var ButtonView: UIView!
    @IBOutlet weak var ColorspaceView: UIView!
    @IBOutlet weak var SampleView: UIView!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var SampleColorView: UIView!
    @IBOutlet weak var ColorNameLabel: UILabel!
    @IBOutlet weak var ColorValueLabel: UILabel!
    @IBOutlet weak var ColorspaceSegment: UISegmentedControl!
}
