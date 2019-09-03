//
//  ColorPickerCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/31/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ColorPickerCode: UIViewController, ColorPickerProtocol
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
        SampleColorView.clipsToBounds = true
        let CheckerLayer = CALayer()
        CheckerLayer.name = "CheckerBoard"
        let CheckerImage = UIImage(named: "Checkerboard1024")?.cgImage
        CheckerLayer.frame = SampleColorView.bounds
        CheckerLayer.contents = CheckerImage
        CheckerLayer.zPosition = 0
        CheckerLayer.contentsGravity = CALayerContentsGravity.topLeft
        SampleColorView.layer.addSublayer(CheckerLayer)
        SampleColorLayer = CALayer()
        SampleColorLayer.frame = SampleColorView.bounds
        SampleColorLayer.isOpaque = false
        SampleColorLayer.zPosition = 100
        SampleColorLayer.backgroundColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
        SampleColorView.layer.addSublayer(SampleColorLayer)
        
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
        
        InitializeWithColor()
        InitializeSliders()
        UpdateColorspace()
    }
    
    func InitializeSliders()
    {
        ChannelAContainer.clipsToBounds = true
        let ChannelAGradient = GradientManager.GetGradient(.BlackRed)
        ChannelALayer = GradientManager.CreateGradientLayer(From: ChannelAGradient!, WithFrame: ChannelAContainer.bounds, IsVertical: false)
        ChannelALayer.zPosition = -100
        ChannelAContainer.layer.addSublayer(ChannelALayer)
        
        ChannelBContainer.clipsToBounds = true
        let ChannelBGradient = GradientManager.GetGradient(.BlackGreen)
        ChannelBLayer = GradientManager.CreateGradientLayer(From: ChannelBGradient!, WithFrame: ChannelBContainer.bounds, IsVertical: false)
        ChannelBLayer.zPosition = -100
        ChannelBContainer.layer.addSublayer(ChannelBLayer)
        
        ChannelCContainer.clipsToBounds = true
        let ChannelCGradient = GradientManager.GetGradient(.BlackBlue)
        ChannelCLayer = GradientManager.CreateGradientLayer(From: ChannelCGradient!, WithFrame: ChannelCContainer.bounds, IsVertical: false)
        ChannelCLayer.zPosition = -100
        ChannelCContainer.layer.addSublayer(ChannelCLayer)
        
        ChannelDContainer.clipsToBounds = true
        ChannelDContainer.isOpaque = false
        let CheckerLayer = CALayer()
        CheckerLayer.name = "CheckerBoard"
        let CheckerImage = UIImage(named: "Checkerboard1024")?.cgImage
        CheckerLayer.frame = ChannelDContainer.bounds
        CheckerLayer.contents = CheckerImage
        CheckerLayer.zPosition = -200
        CheckerLayer.contentsGravity = CALayerContentsGravity.topLeft
        ChannelDContainer.layer.addSublayer(CheckerLayer)
        let ChannelDGradient = GradientManager.GetGradient(.ClearWhite)
        ChannelDLayer = GradientManager.CreateGradientLayer(From: ChannelDGradient!, WithFrame: ChannelDContainer.bounds,
                                                            IsVertical: false)
        ChannelDLayer.isOpaque = false
        ChannelDLayer.zPosition = -100
        ChannelDContainer.layer.addSublayer(ChannelDLayer)
    }
    
    /// Contains the current colorspace.
    var WorkingColorspace = WorkingColorspaces.RGB
    
    var SampleColorLayer: CALayer!
    
    var ChannelALayer: CAGradientLayer!
    var ChannelBLayer: CAGradientLayer!
    var ChannelCLayer: CAGradientLayer!
    var ChannelDLayer: CAGradientLayer!
    
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
    
    /// Handle the cancel button press. Tell the color delegate nothing of interest happened.
    /// - Parameter sender: Not used.
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        ColorDelegate?.EditedColor(nil, Tag: DelegateTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the OK button press. Tell the color delegate the newly selected (or old if nothing changed) color.
    /// - Parameter sender: Not used.
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        ColorDelegate?.EditedColor(CurrentColor, Tag: DelegateTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Called by the color delegate implementing class to tell use what color to edit.
    /// - Parameter Color: The color to edit.
    /// - Parameter Tag: The tag to return to the caller. Unchanged by the color picker.
    func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
        DelegateTag = Tag
        SourceColor = Color
    }
    
    private var SourceColor: UIColor? = nil
    
    private var CurrentColor: UIColor? = nil
    
    private var DelegateTag: Any? = nil
    
    /// The user used another way to select a color and that particular view is letting us know the user is done.
    /// - Note:
    ///   - If **Color** is nil, no action is taken.
    ///   - If **Tag** is nil or not a string or not equal to one of the tag values sent by us, no action is taken.
    /// - Parameter Color: If non-nil, the color the user selected. If nil, the user canceled selection.
    /// - Parameter Tag: The tag sent to the other view controller and returned to us (with the expectation that no
    ///                  changes were made to it).
    func EditedColor(_ Color: UIColor?, Tag: Any?)
    {
        if let SomeColor = Color
        {
            if let SomeTag = Tag
            {
                if let SomeTagValue = SomeTag as? String
                {
                    if ["ColorFromNamePicker", "ColorFromColorChipSelector", "ColorFromRecentColors"].contains(SomeTagValue)
                    {
                        CurrentColor = SomeColor
                        UpdateColor(WithColor: CurrentColor!)
                        UpdateChannelsUI(WithColor: CurrentColor!, From: "EditedColor")
                        SetSliderPositions(WithColor: CurrentColor!)
                    }
                }
            }
        }
    }
    
    /// Update the UI for the current working colorspace (set elsewhere by the user).
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
    
    /// Set the UI for RGB (and possibly A). Channel values are all between 0 and 255.
    func SetRGB()
    {
        if ChannelALayer != nil
        {
            ChannelALayer.removeFromSuperlayer()
            ChannelALayer = nil
        }
        if ChannelBLayer != nil
        {
            ChannelBLayer.removeFromSuperlayer()
            ChannelBLayer = nil
        }
        if ChannelCLayer != nil
        {
            ChannelCLayer.removeFromSuperlayer()
            ChannelCLayer = nil
        }
        if ChannelDLayer != nil
        {
            ChannelDLayer.removeFromSuperlayer()
            ChannelDLayer = nil
        }
        
        let ChannelAGradient = GradientManager.GetGradient(.BlackRed)
        ChannelALayer = GradientManager.CreateGradientLayer(From: ChannelAGradient!, WithFrame: ChannelAContainer.bounds, IsVertical: false)
        ChannelALayer.zPosition = -100
        ChannelAContainer.layer.addSublayer(ChannelALayer)
        ChannelASlider.minimumTrackTintColor = UIColor.red
        
        ChannelBContainer.clipsToBounds = true
        let ChannelBGradient = GradientManager.GetGradient(.BlackGreen)
        ChannelBLayer = GradientManager.CreateGradientLayer(From: ChannelBGradient!, WithFrame: ChannelBContainer.bounds, IsVertical: false)
        ChannelBLayer.zPosition = -100
        ChannelBContainer.layer.addSublayer(ChannelBLayer)
        ChannelBSlider.minimumTrackTintColor = UIColor.green
        
        ChannelCContainer.clipsToBounds = true
        let ChannelCGradient = GradientManager.GetGradient(.BlackBlue)
        ChannelCLayer = GradientManager.CreateGradientLayer(From: ChannelCGradient!, WithFrame: ChannelCContainer.bounds, IsVertical: false)
        ChannelCLayer.zPosition = -100
        ChannelCContainer.layer.addSublayer(ChannelCLayer)
        ChannelCSlider.minimumTrackTintColor = UIColor.blue
        
        ShowChannelD(EnableAlpha, Fast: true)
        
        let CheckerLayer = CALayer()
        CheckerLayer.name = "CheckerBoard"
        let CheckerImage = UIImage(named: "Checkerboard1024")?.cgImage
        CheckerLayer.frame = ChannelDContainer.bounds
        CheckerLayer.contents = CheckerImage
        CheckerLayer.zPosition = -200
        CheckerLayer.contentsGravity = CALayerContentsGravity.topLeft
        ChannelDContainer.layer.addSublayer(CheckerLayer)
        let ChannelDGradient = GradientManager.GetGradient(.ClearWhite)
        ChannelDLayer = GradientManager.CreateGradientLayer(From: ChannelDGradient!, WithFrame: ChannelDContainer.bounds,
                                                            IsVertical: false)
        ChannelDLayer.isOpaque = false
        ChannelDLayer.zPosition = -100
        ChannelDContainer.layer.addSublayer(ChannelDLayer)
        ChannelDSlider.minimumTrackTintColor = UIColor.darkGray
        
        let Red = CurrentColor?.r
        let Green = CurrentColor?.g
        let Blue = CurrentColor?.b
        let Alpha = CurrentColor?.a
        ChannelALabel.text = "Red"
        ChannelASlider.value = Float(Red!)
        
        ChannelBLabel.text = "Green"
        ChannelBSlider.value = Float(Green!)
        
        ChannelCLabel.text = "Blue"
        ChannelCSlider.value = Float(Blue!)
        
        ChannelDLabel.text = "Alpha"
        ChannelDSlider.value = Float(Alpha!)
        
        EnableAlphaText.isEnabled = true
        EnableRGBAlphaSwitch.isEnabled = true
    }
    
    /// Set the UI for HSB. H channel values vary between 0 and 360 and S and B between 0.0 and 1.0.
    func SetHSB()
    {
        if ChannelALayer != nil
        {
            ChannelALayer.removeFromSuperlayer()
            ChannelALayer = nil
        }
        if ChannelBLayer != nil
        {
            ChannelBLayer.removeFromSuperlayer()
            ChannelBLayer = nil
        }
        if ChannelCLayer != nil
        {
            ChannelCLayer.removeFromSuperlayer()
            ChannelCLayer = nil
        }
        if ChannelDLayer != nil
        {
            ChannelDLayer.removeFromSuperlayer()
            ChannelDLayer = nil
        }
        
        let ChannelAGradient = GradientManager.GetGradient(.HueRange)
        ChannelALayer = GradientManager.CreateGradientLayer(From: ChannelAGradient!, WithFrame: ChannelAContainer.bounds, IsVertical: false)
        ChannelALayer.zPosition = -100
        ChannelAContainer.layer.addSublayer(ChannelALayer)
        ChannelASlider.minimumTrackTintColor = UIColor.black
        
        ChannelBContainer.clipsToBounds = true
        let ChannelBGradient = GradientManager.GetGradient(.BlackGray)
        ChannelBLayer = GradientManager.CreateGradientLayer(From: ChannelBGradient!, WithFrame: ChannelBContainer.bounds, IsVertical: false)
        ChannelBLayer.zPosition = -100
        ChannelBContainer.layer.addSublayer(ChannelBLayer)
        ChannelBSlider.minimumTrackTintColor = UIColor.darkGray
        
        ChannelCContainer.clipsToBounds = true
        let ChannelCGradient = GradientManager.GetGradient(.BlackWhite)
        ChannelCLayer = GradientManager.CreateGradientLayer(From: ChannelCGradient!, WithFrame: ChannelCContainer.bounds, IsVertical: false)
        ChannelCLayer.zPosition = -100
        ChannelCContainer.layer.addSublayer(ChannelCLayer)
        ChannelCSlider.minimumTrackTintColor = UIColor.white
        
        let (Hue, Saturation, Brightness) = ColorSpaceConverter.ToHSB(RGB: CurrentColor!)
        
        ChannelALabel.text = "Hue"
        ChannelASlider.value = Float(Hue)
        ChannelATextBox.text = "\(Int(Hue * 360.0))"
        
        ChannelBLabel.text = "Saturation"
        ChannelBSlider.value = Float(Saturation)
        ChannelBTextBox.text = "\(Utility.Round(Saturation, ToPlaces: 3))"
        
        ChannelCLabel.text = "Brightness"
        ChannelCSlider.value = Float(Brightness)
        ChannelCTextBox.text = "\(Utility.Round(Brightness, ToPlaces: 3))"
        
        ShowChannelD(false, Fast: true)
        
        EnableAlphaText.isEnabled = false
        EnableRGBAlphaSwitch.isEnabled = false
    }
    
        /// Set the UI for YUV. All channel values vary between 0.0 and 1.0.
    func SetYUV()
    {
        if ChannelALayer != nil
        {
            ChannelALayer.removeFromSuperlayer()
            ChannelALayer = nil
        }
        if ChannelBLayer != nil
        {
            ChannelBLayer.removeFromSuperlayer()
            ChannelBLayer = nil
        }
        if ChannelCLayer != nil
        {
            ChannelCLayer.removeFromSuperlayer()
            ChannelCLayer = nil
        }
        if ChannelDLayer != nil
        {
            ChannelDLayer.removeFromSuperlayer()
            ChannelDLayer = nil
        }
        
        let ChannelAGradient = GradientManager.GetGradient(.BlackGray)
        ChannelALayer = GradientManager.CreateGradientLayer(From: ChannelAGradient!, WithFrame: ChannelAContainer.bounds, IsVertical: false)
        ChannelALayer.zPosition = -100
        ChannelAContainer.layer.addSublayer(ChannelALayer)
        ChannelASlider.minimumTrackTintColor = UIColor.gray
        
        ChannelBContainer.clipsToBounds = true
        let ChannelBGradient = GradientManager.GetGradient(.BlackGray)
        ChannelBLayer = GradientManager.CreateGradientLayer(From: ChannelBGradient!, WithFrame: ChannelBContainer.bounds, IsVertical: false)
        ChannelBLayer.zPosition = -100
        ChannelBContainer.layer.addSublayer(ChannelBLayer)
        ChannelBSlider.minimumTrackTintColor = UIColor.gray
        
        ChannelCContainer.clipsToBounds = true
        let ChannelCGradient = GradientManager.GetGradient(.BlackGray)
        ChannelCLayer = GradientManager.CreateGradientLayer(From: ChannelCGradient!, WithFrame: ChannelCContainer.bounds, IsVertical: false)
        ChannelCLayer.zPosition = -100
        ChannelCContainer.layer.addSublayer(ChannelCLayer)
        ChannelCSlider.minimumTrackTintColor = UIColor.gray
        
        ShowChannelD(false, Fast: true)
        
        let (Y, U, V) = ColorSpaceConverter.ToYUV(RGB: CurrentColor!)
        
        ChannelALabel.text = "Y"
        ChannelASlider.value = Float(Y)
        ChannelATextBox.text = "\(Utility.Round(Y, ToPlaces: 3))"
        
        ChannelBLabel.text = "U"
        ChannelBSlider.value = Float(U)
        ChannelBTextBox.text = "\(Utility.Round(U, ToPlaces: 3))"
        
        ChannelCLabel.text = "V"
        ChannelCSlider.value = Float(V)
        ChannelCTextBox.text = "\(Utility.Round(V, ToPlaces: 3))"
        
        EnableAlphaText.isEnabled = false
        EnableRGBAlphaSwitch.isEnabled = false
    }
    
    /// Set the UI for CMYK. All channel values vary between 0.0 and 1.0.
    func SetCMYK()
    {
        if ChannelALayer != nil
        {
            ChannelALayer.removeFromSuperlayer()
            ChannelALayer = nil
        }
        if ChannelBLayer != nil
        {
            ChannelBLayer.removeFromSuperlayer()
            ChannelBLayer = nil
        }
        if ChannelCLayer != nil
        {
            ChannelCLayer.removeFromSuperlayer()
            ChannelCLayer = nil
        }
        if ChannelDLayer != nil
        {
            ChannelDLayer.removeFromSuperlayer()
            ChannelDLayer = nil
        }
        
        let ChannelAGradient = GradientManager.GetGradient(.BlackCyan)
        ChannelALayer = GradientManager.CreateGradientLayer(From: ChannelAGradient!, WithFrame: ChannelAContainer.bounds, IsVertical: false)
        ChannelALayer.zPosition = -100
        ChannelAContainer.layer.addSublayer(ChannelALayer)
        ChannelASlider.minimumTrackTintColor = UIColor.cyan
        
        ChannelBContainer.clipsToBounds = true
        let ChannelBGradient = GradientManager.GetGradient(.BlackMagenta)
        ChannelBLayer = GradientManager.CreateGradientLayer(From: ChannelBGradient!, WithFrame: ChannelBContainer.bounds, IsVertical: false)
        ChannelBLayer.zPosition = -100
        ChannelBContainer.layer.addSublayer(ChannelBLayer)
        ChannelBSlider.minimumTrackTintColor = UIColor.magenta
        
        ChannelCContainer.clipsToBounds = true
        let ChannelCGradient = GradientManager.GetGradient(.BlackYellow)
        ChannelCLayer = GradientManager.CreateGradientLayer(From: ChannelCGradient!, WithFrame: ChannelCContainer.bounds, IsVertical: false)
        ChannelCLayer.zPosition = -100
        ChannelCContainer.layer.addSublayer(ChannelCLayer)
        ChannelCSlider.minimumTrackTintColor = UIColor.yellow
        
        ShowChannelD(true, Fast: true)
        let ChannelDGradient = GradientManager.GetGradient(.WhiteBlack)
        ChannelDLayer = GradientManager.CreateGradientLayer(From: ChannelDGradient!, WithFrame: ChannelDContainer.bounds,
                                                            IsVertical: false)
        ChannelDLayer.isOpaque = true
        ChannelDLayer.zPosition = -100
        ChannelDContainer.layer.addSublayer(ChannelDLayer)
        ChannelDSlider.minimumTrackTintColor = UIColor.black
        
        let (C, M, Y, K) = ColorSpaceConverter.ToCMYK(RGB: CurrentColor!)
        
        ChannelALabel.text = "Cyan"
        ChannelASlider.value = Float(C)
        ChannelATextBox.text = "\(Utility.Round(C, ToPlaces: 3))"
        
        ChannelBLabel.text = "Magenta"
        ChannelBSlider.value = Float(M)
        ChannelBTextBox.text = "\(Utility.Round(M, ToPlaces: 3))"

        ChannelCLabel.text = "Yellow"
        ChannelCSlider.value = Float(Y)
        ChannelCTextBox.text = "\(Utility.Round(Y, ToPlaces: 3))"
        
        ChannelDLabel.text = "Black"
        ChannelDSlider.value = Float(K)
        ChannelDTextBox.text = "\(Utility.Round(K, ToPlaces: 3))"
        
        EnableAlphaText.isEnabled = false
        EnableRGBAlphaSwitch.isEnabled = false
    }
    
    func NewSliderValue(Name: String, NewValue: Double)
    {
        let rvalue: CGFloat = CGFloat(ChannelASlider.value)
        let gvalue: CGFloat = CGFloat(ChannelBSlider.value)
        let bvalue: CGFloat = CGFloat(ChannelCSlider.value)
        var avalue: CGFloat = 1.0
        switch WorkingColorspace
        {
            case .RGB:
                avalue = EnableAlpha ? CGFloat(ChannelDSlider.value) : 1.0
            
            case .CMYK:
                avalue = CGFloat(ChannelDSlider.value)
            
            default:
            break
        }
        var SampleColor = UIColor.red
        switch WorkingColorspace
        {
            case .RGB:
                SampleColor = UIColor(red: rvalue, green: gvalue, blue: bvalue, alpha: avalue)
            
            case .HSB:
                SampleColor = UIColor(hue: rvalue, saturation: gvalue, brightness: bvalue, alpha: 1.0)
            
            case .YUV:
                let Converted = ColorSpaceConverter.ToRGB(YUV: (Double(rvalue), Double(gvalue), Double(bvalue)))
                SampleColor = Converted
            
            case .CMYK:
                let Converted = ColorSpaceConverter.ToRGB(CMYK: (Double(rvalue), Double(gvalue), Double(bvalue), Double(avalue)))
                SampleColor = Converted
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
        var ColorFormat = ChannelFormats.RGB
        if EnableAlpha
        {
            ColorFormat = .ARGB
        }
        let ColorValue = ColorServer.MakeHexString(From: WithColor, Format: ColorFormat, Prefix: "#")
        ColorValueLabel.text = ColorValue
        let ColorNames = PredefinedColors.NamesFrom(FindColor: WithColor)
        let ColorName: String? = ColorNames.count > 0 ? ColorNames[0] : nil
        if let FinalColorName = ColorName
        {
            ColorNameLabel.text = FinalColorName
        }
        else
        {
            ColorNameLabel.text = ""
        }
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
        switch WorkingColorspace
        {
            case .RGB:
                let AValue = Int(255.0 * Utility.Round(WithColor.r, ToPlaces: 3))
                let BValue = Int(255.0 * Utility.Round(WithColor.g, ToPlaces: 3))
                let CValue = Int(255.0 * Utility.Round(WithColor.b, ToPlaces: 3))
                let DValue = Int(255.0 * Utility.Round(WithColor.a, ToPlaces: 3))
                ChannelATextBox.text = "\(AValue)"
                ChannelBTextBox.text = "\(BValue)"
                ChannelCTextBox.text = "\(CValue)"
                ChannelDTextBox.text = "\(DValue)"
            
            case .HSB:
                let (H, S, B) = ColorSpaceConverter.ToHSB(RGB: WithColor)
                let AValue = Int(360.0 * Utility.Round(H, ToPlaces: 3))
                let BValue = Utility.Round(S, ToPlaces: 3)
                let CValue = Utility.Round(B, ToPlaces: 3)
                ChannelATextBox.text = "\(AValue)"
                ChannelBTextBox.text = "\(BValue)"
                ChannelCTextBox.text = "\(CValue)"

            case .YUV:
                let (Y, U, V) = ColorSpaceConverter.ToYUV(RGB: WithColor)
                let AValue = Utility.Round(Y, ToPlaces: 3)
                let BValue = Utility.Round(U, ToPlaces: 3)
                let CValue = Utility.Round(V, ToPlaces: 3)
                ChannelATextBox.text = "\(AValue)"
                ChannelBTextBox.text = "\(BValue)"
                ChannelCTextBox.text = "\(CValue)"
            
            case .CMYK:
                let (C, M, Y, K) = ColorSpaceConverter.ToCMYK(RGB: WithColor)
                let AValue = Utility.Round(C, ToPlaces: 3)
                let BValue = Utility.Round(M, ToPlaces: 3)
                let CValue = Utility.Round(Y, ToPlaces: 3)
                let DValue = Utility.Round(K, ToPlaces: 3)
                ChannelATextBox.text = "\(AValue)"
                ChannelBTextBox.text = "\(BValue)"
                ChannelCTextBox.text = "\(CValue)"
                ChannelDTextBox.text = "\(DValue)"
        }

        SampleColorLayer.backgroundColor = WithColor.cgColor
    }
    
    @IBAction func HandleChannelASliderChanged(_ sender: Any)
    {
        let SliderValue: Double = Double(ChannelASlider.value)
        switch WorkingColorspace
        {
            case .RGB:
                let (A, _, G, B) = Utility.GetARGB(SourceColor: CurrentColor!)
                CurrentColor = UIColor(red: CGFloat(SliderValue), green: G, blue: B, alpha: A)
            
            case .HSB:
                let (_, S, B) = ColorSpaceConverter.ToHSB(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(HSB: (SliderValue, S, B))
            
            case .YUV:
                let (_, U, V) = ColorSpaceConverter.ToYUV(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(YUV: (SliderValue, U, V))
            
            case .CMYK:
                let (_, M, Y, K) = ColorSpaceConverter.ToCMYK(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(CMYK: (SliderValue, M, Y, K))
        }

        UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelASliderChanged")
        UpdateColor(WithColor: CurrentColor!)
    }
    
    @IBAction func HandleChannelBSliderChanged(_ sender: Any)
    {
        let SliderValue: Double = Double(ChannelBSlider.value)
        switch WorkingColorspace
        {
            case .RGB:
                let (A, R, _, B) = Utility.GetARGB(SourceColor: CurrentColor!)
                CurrentColor = UIColor(red: R, green: CGFloat(SliderValue), blue: B, alpha: A)
            
            case .HSB:
                let (H, _, B) = ColorSpaceConverter.ToHSB(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(HSB: (H, SliderValue, B))
            
            case .YUV:
                let (Y, _, V) = ColorSpaceConverter.ToYUV(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(YUV: (Y, SliderValue, V))
            
            case .CMYK:
                let (C, _, Y, K) = ColorSpaceConverter.ToCMYK(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(CMYK: (C, SliderValue, Y, K))
        }
        
        UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelBSliderChanged")
        UpdateColor(WithColor: CurrentColor!)
    }
    
    @IBAction func HandleChannelCSliderChanged(_ sender: Any)
    {
        let SliderValue: Double = Double(ChannelCSlider.value)
        switch WorkingColorspace
        {
            case .RGB:
                let (A, R, G, _) = Utility.GetARGB(SourceColor: CurrentColor!)
                CurrentColor = UIColor(red: R, green: G, blue: CGFloat(SliderValue), alpha: A)
            
            case .HSB:
                let (H, S, _) = ColorSpaceConverter.ToHSB(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(HSB: (H, S, SliderValue))
            
            case .YUV:
                let (Y, U, _) = ColorSpaceConverter.ToYUV(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(YUV: (Y, U, SliderValue))
            
            case .CMYK:
                let (C, M, _, K) = ColorSpaceConverter.ToCMYK(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(CMYK: (C, M, SliderValue, K))
        }
        
        UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelCSliderChanged")
        UpdateColor(WithColor: CurrentColor!)
    }
    
    @IBAction func HandleChannelDSliderChanged(_ sender: Any)
    {
        let SliderValue: Double = Double(ChannelDSlider.value)
        switch WorkingColorspace
        {
            case .RGB:
                let (_, R, G, B) = Utility.GetARGB(SourceColor: CurrentColor!)
                CurrentColor = UIColor(red: R, green: G, blue: B, alpha: CGFloat(SliderValue))
            
            case .CMYK:
                let (C, M, Y, _) = ColorSpaceConverter.ToCMYK(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(CMYK: (C, M, Y, SliderValue))
            
            default:
            return
        }
        
        UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelDSliderChanged")
        UpdateColor(WithColor: CurrentColor!)
    }
    
    /// Validate input from the user for a channel value.
    /// - Parameter Raw: Raw string (which may be nullable) from a text box.
    /// - Parameter Max: Maximum integer allowed.
    /// - Returns: Tuple in the form (converted integer value, forced string for errors). On error, the converted integer value
    ///            is set to the same as the force string value.
    func ValidateTextInput(_ Raw: String?, Max: Int = 255) -> (Int, String?)
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
                if IValue > Max
                {
                    return (Max, "\(Max)")
                }
                return (IValue, nil)
            }
            else
            {
                return (Max, "\(Max)")
            }
        }
        else
        {
            return (0, "0")
        }
    }
    
    /// Validate input from the user for a channel value. The value is assumed to be a normal value (eg, 0.0 to 1.0).
    /// - Parameter Raw: Raw string (which may be nullable) from a text box.
    /// - Returns: Tuple in the form (converted double value, forced string for errors). On error, the converted double value
    ///            is set to the same as the force string value.
    func ValidateNormalTextInput(_ Raw: String?) -> (Double, String?)
    {
        if let TestValue = Raw
        {
            if TestValue.isEmpty
            {
                return (0, "0")
            }
            if let DValue = Double(TestValue)
            {
                if DValue < 0
                {
                    return (0.0, "0.0")
                }
                if DValue > 1.0
                {
                    return (1.0, "1.0")
                }
                return (DValue, nil)
            }
            else
            {
                return (1.0, "1.0")
            }
        }
        else
        {
            return (0.0, "0.0")
        }
    }
    
    @IBAction func HandleChannelATextChanged(_ sender: Any)
    {
        switch WorkingColorspace
        {
            case .RGB:
                let (Value, ErrorValue) = ValidateTextInput(ChannelATextBox.text)
                if let ErrorValueText = ErrorValue
                {
                    ChannelATextBox.text = ErrorValueText
                }
                let NewRValue = CGFloat(Value / 255)
                let (A, _, G, B) = Utility.GetARGB(SourceColor: CurrentColor!)
                CurrentColor = UIColor(red: NewRValue, green: G, blue: B, alpha: A)
                UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelATextChanged")
                ChannelASlider.value = Float(NewRValue)
                UpdateColor(WithColor: CurrentColor!)
            
            case .HSB:
                let (Value, ErrorValue) = ValidateTextInput(ChannelATextBox.text, Max: 360)
                if let ErrorValueText = ErrorValue
                {
                    ChannelATextBox.text = ErrorValueText
                }
                let NewChannelAValue = CGFloat(Value / 360)
                let (_, S, B) = ColorSpaceConverter.ToHSB(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(HSB: (Double(NewChannelAValue), S, B))
                UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelATextChanged")
                ChannelASlider.value = Float(NewChannelAValue)
                UpdateColor(WithColor: CurrentColor!)
            
            case .YUV:
                let (Value, ErrorValue) = ValidateNormalTextInput(ChannelATextBox.text)
            if let ErrorValueText = ErrorValue
            {
                ChannelATextBox.text = ErrorValueText
            }
            let NewChannelAValue = Value
                let (_, U, V) = ColorSpaceConverter.ToYUV(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(YUV: (Double(NewChannelAValue), U, V))
                UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelATextChanged")
                ChannelASlider.value = Float(NewChannelAValue)
                UpdateColor(WithColor: CurrentColor!)
            
            case .CMYK:
                let (Value, ErrorValue) = ValidateNormalTextInput(ChannelATextBox.text)
                if let ErrorValueText = ErrorValue
                {
                    ChannelATextBox.text = ErrorValueText
                }
                let NewChannelAValue = Value
                let (_, M, Y, K) = ColorSpaceConverter.ToCMYK(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(CMYK: (Double(NewChannelAValue), M, Y, K))
                UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelATextChanged")
                ChannelASlider.value = Float(NewChannelAValue)
                UpdateColor(WithColor: CurrentColor!)
        }

    }
    
    @IBAction func HandleChannelBTextChanged(_ sender: Any)
    {
        switch WorkingColorspace
        {
            case .RGB:
                let (Value, ErrorValue) = ValidateTextInput(ChannelBTextBox.text)
                if let ErrorValueText = ErrorValue
                {
                    ChannelBTextBox.text = ErrorValueText
                }
                let NewGValue = CGFloat(Value / 255)
                let (A, R, _, B) = Utility.GetARGB(SourceColor: CurrentColor!)
                CurrentColor = UIColor(red: R, green: NewGValue, blue: B, alpha: A)
                UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelBTextChanged")
                ChannelBSlider.value = Float(NewGValue)
                UpdateColor(WithColor: CurrentColor!)
            
            case .HSB:
                let (Value, ErrorValue) = ValidateNormalTextInput(ChannelBTextBox.text)
                if let ErrorValueText = ErrorValue
                {
                    ChannelBTextBox.text = ErrorValueText
                }
                let NewChannelBValue = Value
                let (H, _, B) = ColorSpaceConverter.ToHSB(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(HSB: (H, Double(NewChannelBValue), B))
                UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelBTextChanged")
                ChannelBSlider.value = Float(NewChannelBValue)
                UpdateColor(WithColor: CurrentColor!)
            
            case .YUV:
                let (Value, ErrorValue) = ValidateNormalTextInput(ChannelBTextBox.text)
                if let ErrorValueText = ErrorValue
                {
                    ChannelBTextBox.text = ErrorValueText
                }
                let NewChannelBValue = Value
                let (Y, _, V) = ColorSpaceConverter.ToYUV(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(YUV: (Y, Double(NewChannelBValue), V))
                UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelBTextChanged")
                ChannelBSlider.value = Float(NewChannelBValue)
                UpdateColor(WithColor: CurrentColor!)
            
            case .CMYK:
                let (Value, ErrorValue) = ValidateNormalTextInput(ChannelBTextBox.text)
                if let ErrorValueText = ErrorValue
                {
                    ChannelBTextBox.text = ErrorValueText
                }
                let NewChannelBValue = Value
                let (C, _, Y, K) = ColorSpaceConverter.ToCMYK(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(CMYK: (C, Double(NewChannelBValue), Y, K))
                UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelBTextChanged")
                ChannelBSlider.value = Float(NewChannelBValue)
                UpdateColor(WithColor: CurrentColor!)
        }
    }
    
    @IBAction func HandleChannelCTextChanged(_ sender: Any)
    {
        switch WorkingColorspace
        {
            case .RGB:
                let (Value, ErrorValue) = ValidateTextInput(ChannelCTextBox.text)
                if let ErrorValueText = ErrorValue
                {
                    ChannelCTextBox.text = ErrorValueText
                }
                let NewBValue = CGFloat(Value / 255)
                let (A, R, G, _) = Utility.GetARGB(SourceColor: CurrentColor!)
                CurrentColor = UIColor(red: R, green: G, blue: NewBValue, alpha: A)
                UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelCTextChanged")
                ChannelCSlider.value = Float(NewBValue)
                UpdateColor(WithColor: CurrentColor!)
            
            case .HSB:
                let (Value, ErrorValue) = ValidateNormalTextInput(ChannelCTextBox.text)
                if let ErrorValueText = ErrorValue
                {
                    ChannelCTextBox.text = ErrorValueText
                }
                let NewChannelCValue = Value
                let (H, S, _) = ColorSpaceConverter.ToHSB(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(HSB: (H, S, Double(NewChannelCValue)))
                UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelCTextChanged")
                ChannelCSlider.value = Float(NewChannelCValue)
                UpdateColor(WithColor: CurrentColor!)
            
            case .YUV:
                let (Value, ErrorValue) = ValidateNormalTextInput(ChannelCTextBox.text)
                if let ErrorValueText = ErrorValue
                {
                    ChannelCTextBox.text = ErrorValueText
                }
                let NewChannelCValue = Value
                let (Y, U, _) = ColorSpaceConverter.ToYUV(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(YUV: (Y, U, Double(NewChannelCValue)))
                UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelCTextChanged")
                ChannelCSlider.value = Float(NewChannelCValue)
                UpdateColor(WithColor: CurrentColor!)
            
            case .CMYK:
                let (Value, ErrorValue) = ValidateNormalTextInput(ChannelCTextBox.text)
                if let ErrorValueText = ErrorValue
                {
                    ChannelCTextBox.text = ErrorValueText
                }
                let NewChannelCValue = Value
                let (C, M, _, K) = ColorSpaceConverter.ToCMYK(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(CMYK: (C, M, Double(NewChannelCValue), K))
                UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelCTextChanged")
                ChannelCSlider.value = Float(NewChannelCValue)
                UpdateColor(WithColor: CurrentColor!)
        }
    }
    
    @IBAction func HandleChannelDTextChanged(_ sender: Any)
    {
        switch WorkingColorspace
        {
            case .RGB:
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
                UpdateColor(WithColor: CurrentColor!)
            
            case .CMYK:
                let (Value, ErrorValue) = ValidateNormalTextInput(ChannelDTextBox.text)
                if let ErrorValueText = ErrorValue
                {
                    ChannelDTextBox.text = ErrorValueText
                }
                let NewChannelDValue = Value
                let (C, M, Y, _) = ColorSpaceConverter.ToCMYK(RGB: CurrentColor!)
                CurrentColor = ColorSpaceConverter.ToRGB(CMYK: (C, M, Y, Double(NewChannelDValue)))
                UpdateChannelsUI(WithColor: CurrentColor!, From: "HandleChannelDTextChanged")
                ChannelCSlider.value = Float(NewChannelDValue)
                UpdateColor(WithColor: CurrentColor!)
            
            default:
            break
        }
    }
    
    func ShowChannelD(_ DoShow: Bool, Fast: Bool)
    {
        let Duration = Fast ? 0.0 : 0.25
        UIView.animate(withDuration: Duration, animations:
            {
                self.ChannelDLabel.alpha = DoShow ? 1.0 : 0.0
                self.ChannelDContainer.alpha = DoShow ? 1.0 : 0.0
                self.ChannelDTextBox.alpha = DoShow ? 1.0 : 0.0
        },
                       completion:
            {
                _ in
                self.ChannelDLabel.isHidden = !DoShow
                self.ChannelDContainer.isHidden = !DoShow
                self.ChannelDContainer.isUserInteractionEnabled = DoShow
                self.ChannelDSlider.isUserInteractionEnabled = DoShow
                self.ChannelDTextBox.isHidden = !DoShow
                self.ChannelDTextBox.isUserInteractionEnabled = DoShow
        })
    }
    
    /// Handle changes to the Enable RGB switch.
    /// - Parameter sender: Not used.
    @IBAction func HandleEnableRGBAlphaChanged(_ sender: Any)
    {
        Settings.SetShowAlpha(NewValue: EnableRGBAlphaSwitch.isOn)
        if WorkingColorspace == .RGB
        {
            EnableAlpha = EnableRGBAlphaSwitch.isOn
            ShowChannelD(EnableAlpha, Fast: false)
        }
    }
    
    private var EnableAlpha = false
    
    @IBSegueAction func ColorNamePickerSegue(_ coder: NSCoder) -> ColorNamePickerCode?
    {
        let Picker = ColorNamePickerCode(coder: coder)
        Picker?.ColorDelegate = self
        Picker?.ColorToEdit(CurrentColor!, Tag: "ColorFromNamePicker")
        return Picker
    }
    
    @IBSegueAction func ColorChipSelectorSegue(_ coder: NSCoder) -> ColorChipSelectorCode?
    {
        let Selector = ColorChipSelectorCode(coder: coder)
        Selector?.ColorDelegate = self
        Selector?.ColorToEdit(CurrentColor!, Tag: "ColorFromColorChipSelector")
        return Selector
    }
    
    @IBSegueAction func RecentColorsSegue(_ coder: NSCoder) -> RecentColorListCode?
    {
        let RecentColor = RecentColorListCode(coder: coder)
        RecentColor?.ColorDelegate = self
        RecentColor?.ColorToEdit(CurrentColor!, Tag: "ColorFromRecentColors")
        return RecentColor
    }
    
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

/// Color space definitions for the color picker.
/// - **RGB**: Standard RGB colorspace.
/// - **HSB**: Standard (for Apple) HSB colorspace.
/// - **YUV**: YUV colorspace.
/// - **CMYK**: CMYK colorspace.
enum WorkingColorspaces: Int, CaseIterable
{
    case RGB = 0
    case HSB = 1
    case YUV = 2
    case CMYK = 3
}
