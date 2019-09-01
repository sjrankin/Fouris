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
        
        EnableAlpha = Settings.GetShowAlpha()
        EnableRGBAlphaSwitch.isOn = EnableAlpha
        WorkingColorspace = WorkingColorspaces(rawValue: Settings.GetColorPickerColorSpace())!
        
        SampleColorView.layer.borderWidth = 0.5
        SampleColorView.layer.borderColor = UIColor.black.cgColor
        SampleColorView.layer.cornerRadius = 5.0
        SampleColorView.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        ChannelALabel.text = "Red"
        ChannelBLabel.text = "Blue"
        ChannelCLabel.text = "Green"
        ChannelDLabel.text = "Alpha"
        
        ButtonView.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        ButtonView.layer.borderColor = UIColor.black.cgColor
        ColorspaceView.backgroundColor = UIColor.clear
        SampleView.backgroundColor = UIColor.clear
        TopView.backgroundColor = UIColor.clear
        
        let TitleBarGradient = GradientManager.GetGradient(.PistachioBlack)
        let TitleBarLayer = GradientManager.CreateGradientLayer(From: TitleBarGradient!, WithFrame: TitleBar.bounds,
                                                                IsVertical: false, ReverseColors: true)
        TitleBarLayer.name = "Gradient"
        TitleBarLayer.zPosition = -100
        TitleBar.layer.addSublayer(TitleBarLayer)
        
        ChannelASlider.minimumTrackTintColor = UIColor.red
        ChannelASlider.tintColor = UIColor.black
        ChannelBSlider.minimumTrackTintColor = UIColor.green
        ChannelBSlider.tintColor = UIColor.black
        ChannelCSlider.minimumTrackTintColor = UIColor.blue
        ChannelCSlider.tintColor = UIColor.black
        ChannelDSlider.minimumTrackTintColor = UIColor.darkGray
        ChannelDSlider.tintColor = UIColor.black
        
        InitializeWithColor()
    }
    
    var WorkingColorspace = WorkingColorspaces.RGB
    
    /// The controller finished layout-ing out subviews, which means the position and size of the subviews is
    /// finalized and we can tell our sliders to refresh themselves to make sure the gradients are filled
    /// correctly.
    override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        //InitializeWithColor()
        
        ChannelAContainer.clipsToBounds = true
        let ChannelAGradient = GradientManager.GetGradient(.BlackRed)
        let ChannelALayer = GradientManager.CreateGradientLayer(From: ChannelAGradient!, WithFrame: ChannelAContainer.bounds, IsVertical: false)
        ChannelALayer.name = "Gradient"
        ChannelALayer.zPosition = -100
        ChannelAContainer.layer.addSublayer(ChannelALayer)
        
        ChannelBContainer.clipsToBounds = true
        let ChannelBGradient = GradientManager.GetGradient(.BlackGreen)
        let ChannelBLayer = GradientManager.CreateGradientLayer(From: ChannelBGradient!, WithFrame: ChannelBContainer.bounds, IsVertical: false)
        ChannelBLayer.name = "Gradient"
        ChannelBLayer.zPosition = -100
        ChannelBContainer.layer.addSublayer(ChannelBLayer)
        
        ChannelCContainer.clipsToBounds = true
        let ChannelCGradient = GradientManager.GetGradient(.BlackBlue)
        let ChannelCLayer = GradientManager.CreateGradientLayer(From: ChannelCGradient!, WithFrame: ChannelCContainer.bounds, IsVertical: false)
        ChannelCLayer.name = "Gradient"
        ChannelCLayer.zPosition = -100
        ChannelCContainer.layer.addSublayer(ChannelCLayer)
        
        ChannelDContainer.clipsToBounds = true
        let ChannelDGradient = GradientManager.GetGradient(.BlackWhite)
        let ChannelDLayer = GradientManager.CreateGradientLayer(From: ChannelDGradient!, WithFrame: ChannelDContainer.bounds,
                                                                IsVertical: false)
        ChannelDLayer.name = "Gradient"
        ChannelDLayer.zPosition = -100
        ChannelDContainer.layer.addSublayer(ChannelDLayer)
        
        switch WorkingColorspace
        {
            case .RGB:
                ChannelDTextBox.isHidden = !EnableAlpha
                ChannelDTextBox.isUserInteractionEnabled = EnableAlpha
                ChannelDLabel.isHidden = !EnableAlpha
                ChannelDContainer.isHidden = !EnableAlpha
                ChannelDContainer.isUserInteractionEnabled = EnableAlpha
                ChannelDSlider.isUserInteractionEnabled = EnableAlpha
            
            case .HSB:
                ChannelDTextBox.isHidden = true
                ChannelDTextBox.isUserInteractionEnabled = false
                ChannelDLabel.isHidden = true
                ChannelDContainer.isHidden = true
                ChannelDContainer.isUserInteractionEnabled = false
                ChannelDSlider.isUserInteractionEnabled = false
            
            case .YUV:
                ChannelDTextBox.isHidden = true
                ChannelDTextBox.isUserInteractionEnabled = false
                ChannelDLabel.isHidden = true
                ChannelDContainer.isHidden = true
                ChannelDContainer.isUserInteractionEnabled = false
                ChannelDSlider.isUserInteractionEnabled = false
            
            case .CMYK:
                ChannelDTextBox.isHidden = false
                ChannelDTextBox.isUserInteractionEnabled = true
                ChannelDLabel.isHidden = false
                ChannelDContainer.isHidden = false
                ChannelDContainer.isUserInteractionEnabled = true
                ChannelDSlider.isUserInteractionEnabled = true
        }
    }
    
    func InitializeWithColor()
    {
        if SourceColor == nil
        {
            SourceColor = UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0)
        }
        CurrentColor = SourceColor
        UpdateColor(WithColor: SourceColor!)
        UpdateChannelsUI(WithColor: SourceColor!, From: "InitializeWithColor")
        SetSliderPositions(WithColor: SourceColor!)
        
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
        switch WorkingColorspace
        {
            case .RGB:
                SetRGB()
            
            case .HSB:
                SetHSB()
            
            case .YUV:
                SetYUV()
            
            case .CMYK:
                SetCMYK()
        }
    }
    
    func SetRGB()
    {
        let Red = CurrentColor?.r
        let Green = CurrentColor?.g
        let Blue = CurrentColor?.b
        let Alpha = CurrentColor?.a
        ChannelALabel.text = "Red"
        ChannelASlider.value = Float(Red!)//Float(1.0 - Double((Red)!))
        
        ChannelBLabel.text = "Green"
        ChannelBSlider.value = Float(Green!)//Float(1.0 - Double((Green)!))
        
        ChannelCLabel.text = "Blue"
        ChannelCSlider.value = Float(Blue!)//Float(1.0 - Double((Blue)!))
        
        ChannelDLabel.text = "Alpha"
        ChannelDSlider.value = Float(Alpha!)//Float(1.0 - Double((Alpha)!))
        
        EnableAlphaText.isEnabled = true
        EnableRGBAlphaSwitch.isEnabled = true
    }
    
    func SetHSB()
    {
        let Hue = (CurrentColor?.Hue)!
        let Saturation = (CurrentColor?.Saturation)!
        let Brightness = (CurrentColor?.Brightness)!
        ChannelALabel.text = "Saturation"
        ChannelASlider.value = Float(1.0 - Double(Saturation))
        
        ChannelBLabel.text = "Hue"
        ChannelBSlider.value = Float(Hue)
        
        ChannelCLabel.text = "Brightness"
        ChannelCSlider.value = Float(1.0 - Double(Brightness))
        
        EnableAlphaText.isEnabled = false
        EnableRGBAlphaSwitch.isEnabled = false
    }
    
    func SetYUV()
    {
        ChannelALabel.text = "Y"
        ChannelBLabel.text = "U"
        ChannelCLabel.text = "V"
        
        EnableAlphaText.isEnabled = false
        EnableRGBAlphaSwitch.isEnabled = false
    }
    
    func SetCMYK()
    {
        ChannelALabel.text = "Cyan"
        ChannelBLabel.text = "Magenta"
        ChannelCLabel.text = "Yellow"
        ChannelDLabel.text = "Black"
        
        EnableAlphaText.isEnabled = false
        EnableRGBAlphaSwitch.isEnabled = false
    }
    
    func NewSliderValue(Name: String, NewValue: Double)
    {
        //print("New slider value \(NewValue) from \(Name).")
        let rvalue: CGFloat = CGFloat(ChannelASlider.value)//CGFloat(1.0 - ChannelASlider.value)
        let gvalue: CGFloat = CGFloat(ChannelBSlider.value)//CGFloat(1.0 - ChannelBSlider.value)
        let bvalue: CGFloat = CGFloat(ChannelCSlider.value)//CGFloat(1.0 - ChannelCSlider.value)
        var avalue: CGFloat = 1.0
        if WorkingColorspace == .RGB
        {
            avalue = EnableAlpha ? /*CGFloat(1.0 - ChannelDSlider.value)*/ CGFloat(ChannelDSlider.value) : 1.0
        }
        else
        {
            avalue = 1.0
        }
        var SampleColor = UIColor.red
        switch WorkingColorspace
        {
            case .RGB:
                //RGB
                SampleColor = UIColor(red: rvalue, green: gvalue, blue: bvalue, alpha: avalue)
            
            case .HSB:
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
        WorkingColorspace = WorkingColorspaces(rawValue: ColorspaceSegment.selectedSegmentIndex)!
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
        switch WorkingColorspace
        {
            case .RGB:
                //RGB
                if ColorName == nil
                {
                    ColorNameLabel.text = "RGB" + Utility.ColorToString(WithColor, AsRGB: true, DeNormalize: true, IncludeAlpha: EnableAlpha)
                }
                else
                {
                    ColorNameLabel.text = ColorName
            }
            
            case .HSB:
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
    
    /// Set the slider positions with the specified color.
    /// - Parameter WithColor: The color to use that determine the slider positions.
    func SetSliderPositions(WithColor: UIColor)
    {
        ChannelASlider.value = Float(WithColor.r)
        ChannelBSlider.value = Float(WithColor.g)
        ChannelCSlider.value = Float(WithColor.b)
        if WorkingColorspace == .RGB
        {
            if EnableAlpha
            {
                ChannelDSlider.value = Float(WithColor.a)
            }
        }
        if WorkingColorspace == .CMYK
        {
            ChannelDSlider.value = Float(WithColor.a)
        }
    }
    
    func UpdateChannelsUI(WithColor: UIColor, From: String)
    {
        print("UpdateChannelsUI: R=\(Utility.Round(WithColor.r, ToPlaces: 3)), G=\(Utility.Round(WithColor.g, ToPlaces: 3)), B=\(Utility.Round(WithColor.b, ToPlaces: 3))")
        let AValue = Int(255.0 * Utility.Round(WithColor.r, ToPlaces: 3))
        let BValue = Int(255.0 * Utility.Round(WithColor.g, ToPlaces: 3))
        let CValue = Int(255.0 * Utility.Round(WithColor.b, ToPlaces: 3))
        let DValue = Int(255.0 * Utility.Round(WithColor.a, ToPlaces: 3))
        ChannelATextBox.text = "\(AValue)"
        ChannelBTextBox.text = "\(BValue)"
        ChannelCTextBox.text = "\(CValue)"
        ChannelDTextBox.text = "\(DValue)"
        SampleColorView.backgroundColor = WithColor
    }
    
    @IBAction func HandleChannelASliderChanged(_ sender: Any)
    {
        let SliderValue: CGFloat = CGFloat(ChannelASlider.value)
        let (_, _, G, B) = Utility.GetARGB(SourceColor: CurrentColor!)
        CurrentColor = UIColor(red: SliderValue, green: G, blue: B, alpha: 1.0)
        UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelASliderChanged")
    }
    
    @IBAction func HandleChannelBSliderChanged(_ sender: Any)
    {
        let SliderValue: CGFloat = CGFloat(ChannelBSlider.value)
        let (_, R, _, B) = Utility.GetARGB(SourceColor: CurrentColor!)
        CurrentColor = UIColor(red: R, green: SliderValue, blue: B, alpha: 1.0)
        UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelBSliderChanged")
    }
    
    @IBAction func HandleChannelCSliderChanged(_ sender: Any)
    {
        let SliderValue: CGFloat = CGFloat(ChannelCSlider.value)
        let (_, R, G, _) = Utility.GetARGB(SourceColor: CurrentColor!)
        CurrentColor = UIColor(red: R, green: G, blue: SliderValue, alpha: 1.0)
        UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelCSliderChanged")
    }
    
    @IBAction func HandleChannelDSliderChanged(_ sender: Any)
    {
        let SliderValue: CGFloat = CGFloat(ChannelDSlider.value)
        let (_, R, G, B) = Utility.GetARGB(SourceColor: CurrentColor!)
        CurrentColor = UIColor(red: R, green: G, blue: B, alpha: SliderValue)
        UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelDSliderChanged")
    }
    
    /// Validate input from the user for a channel value.
    /// - Parameter Raw: Raw string (which may be nullable) from a text box.
    /// - Returns: Tuple in the form (converted integer value, forced string for errors). On error, the converted integer value
    ///            is set to the same as the force string value.
    func ValidateTextInput(_ Raw: String?) -> (Int, String?)
    {
        if let TestValue = Raw
        {
            if TestValue.isEmpty
            {
                return (0, "0")
            }
            if let IValue = Int(TestValue)
            {
                if IValue < 0
                {
                    return (0, "0")
                }
                if IValue > 255
                {
                    return (255, "255")
                }
                return (IValue, nil)
            }
            else
            {
                return (255, "255")
            }
        }
        else
        {
            return (0, "0")
        }
    }
    
    @IBAction func HandleChannelATextChanged(_ sender: Any)
    {
        let (Value, ErrorValue) = ValidateTextInput(ChannelATextBox.text)
        if let ErrorValueText = ErrorValue
        {
            ChannelATextBox.text = ErrorValueText
        }
        let NewRValue = CGFloat(Value / 255)
        let (_, _, G, B) = Utility.GetARGB(SourceColor: CurrentColor!)
        CurrentColor = UIColor(red: NewRValue, green: G, blue: B, alpha: 1.0)
        UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelATextChanged")
        ChannelASlider.value = Float(NewRValue)
    }
    
    @IBAction func HandleChannelBTextChanged(_ sender: Any)
    {
        let (Value, ErrorValue) = ValidateTextInput(ChannelBTextBox.text)
        if let ErrorValueText = ErrorValue
        {
            ChannelBTextBox.text = ErrorValueText
        }
        let NewGValue = CGFloat(Value / 255)
        let (_, R, _, B) = Utility.GetARGB(SourceColor: CurrentColor!)
        CurrentColor = UIColor(red: R, green: NewGValue, blue: B, alpha: 1.0)
        UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelBTextChanged")
        ChannelBSlider.value = Float(NewGValue)
    }
    
    @IBAction func HandleChannelCTextChanged(_ sender: Any)
    {
        let (Value, ErrorValue) = ValidateTextInput(ChannelCTextBox.text)
        if let ErrorValueText = ErrorValue
        {
            ChannelCTextBox.text = ErrorValueText
        }
        let NewBValue = CGFloat(Value / 255)
        let (_, R, G, _) = Utility.GetARGB(SourceColor: CurrentColor!)
        CurrentColor = UIColor(red: R, green: G, blue: NewBValue, alpha: 1.0)
        UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelCTextChanged")
        ChannelCSlider.value = Float(NewBValue)
    }
    
    @IBAction func HandleChannelDTextChanged(_ sender: Any)
    {
        let (Value, ErrorValue) = ValidateTextInput(ChannelDTextBox.text)
        if let ErrorValueText = ErrorValue
        {
            ChannelDTextBox.text = ErrorValueText
        }
        let NewAValue = CGFloat(Value / 255)
        let (_, R, G, B) = Utility.GetARGB(SourceColor: CurrentColor!)
        CurrentColor = UIColor(red: R, green: G, blue: B, alpha: NewAValue)
        UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelDTextChanged")
        ChannelDSlider.value = Float(NewAValue)
    }
    
    @IBAction func HandleEnableRGBAlphaChanged(_ sender: Any)
    {
        Settings.SetShowAlpha(NewValue: EnableRGBAlphaSwitch.isOn)
        if WorkingColorspace == .RGB
        {
            EnableAlpha = EnableRGBAlphaSwitch.isOn
            ChannelDLabel.isHidden = !EnableAlpha
            ChannelDContainer.isHidden = !EnableAlpha
            ChannelDContainer.isUserInteractionEnabled = EnableAlpha
            ChannelDSlider.isUserInteractionEnabled = EnableAlpha
            ChannelDTextBox.isHidden = !EnableAlpha
            ChannelDTextBox.isUserInteractionEnabled = EnableAlpha
        }
    }
    
    private var EnableAlpha = false
    
    @IBOutlet weak var TitleBar: UIView!
    @IBOutlet weak var ChannelALabel: UILabel!
    @IBOutlet weak var ChannelAContainer: UIView!
    @IBOutlet weak var ChannelASlider: UISlider!
    @IBOutlet weak var ChannelATextBox: UITextField!
    @IBOutlet weak var ChannelBLabel: UILabel!
    @IBOutlet weak var ChannelBContainer: UIView!
    @IBOutlet weak var ChannelBSlider: UISlider!
    @IBOutlet weak var ChannelBTextBox: UITextField!
    @IBOutlet weak var ChannelCLabel: UILabel!
    @IBOutlet weak var ChannelCContainer: UIView!
    @IBOutlet weak var ChannelCSlider: UISlider!
    @IBOutlet weak var ChannelCTextBox: UITextField!
    @IBOutlet weak var ChannelDLabel: UILabel!
    @IBOutlet weak var ChannelDContainer: UIView!
    @IBOutlet weak var ChannelDSlider: UISlider!
    @IBOutlet weak var ChannelDTextBox: UITextField!
    
    @IBOutlet weak var EnableAlphaText: UILabel!
    @IBOutlet weak var EnableRGBAlphaSwitch: UISwitch!
    @IBOutlet weak var ButtonView: UIView!
    @IBOutlet weak var ColorspaceView: UIView!
    @IBOutlet weak var SampleView: UIView!
    @IBOutlet weak var TopView: UIView!
    @IBOutlet weak var SampleColorView: UIView!
    @IBOutlet weak var ColorNameLabel: UILabel!
    @IBOutlet weak var ColorValueLabel: UILabel!
    @IBOutlet weak var ColorspaceSegment: UISegmentedControl!
}

enum WorkingColorspaces: Int, CaseIterable
{
    case RGB = 0
    case HSB = 1
    case YUV = 2
    case CMYK = 3
}
