//
//  GameBackgroundDialog.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GameBackgroundDialog: UIViewController, ColorPickerProtocol, GradientPickerProtocol, ThemeEditingProtocol
{
    weak var ThemeDelegate: ThemeEditingProtocol? = nil
    weak var ColorDelegate: ColorPickerProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ImageBox.layer.borderColor = ColorServer.CGColorFrom(ColorNames.Black)
        ImageBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
        LiveViewBox.layer.borderColor = ColorServer.CGColorFrom(ColorNames.Black)
        LiveViewBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
        GradientColorBox.layer.borderColor = ColorServer.CGColorFrom(ColorNames.Black)
        GradientColorBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
        SolidColorBox.layer.borderColor = ColorServer.CGColorFrom(ColorNames.Black)
        SolidColorBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
        ColorSample.layer.borderColor = ColorServer.CGColorFrom(ColorNames.Black)
        ColorSample.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
        GradientSample.layer.borderColor = ColorServer.CGColorFrom(ColorNames.Black)
        GradientSample.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
        ImageSample.layer.borderColor = ColorServer.CGColorFrom(ColorNames.Black)
        ImageSample.backgroundColor = ColorServer.ColorFrom(ColorNames.Black)
        ImageViewer.image = UIImage(named: "DefaultImage")
        
        BackgroundType = UpdateBackgroundType(UserTheme!.BackgroundType)
        BackgroundTypeSegment.selectedSegmentIndex = BackgroundTypeToIndexMap[BackgroundType]!
        HandleBGChange(ToType: BackgroundType)
        GradientSample.GradientDescriptor = UserTheme!.BackgroundGradientColor
        if UserTheme!.BackgroundImageName.isEmpty
        {
            ImageViewer.image = UIImage(named: "DefaultImage")
        }
        else
        {
            ImageViewer.image = UIImage(named: UserTheme!.BackgroundImageName)
        }
        ColorSample.TopColor = ColorServer.ColorFrom(UserTheme!.BackgroundSolidColor)
        if UserTheme!.BackgroundLiveImageCamera == .Front
        {
            LiveViewCameraSegment.selectedSegmentIndex = 0
        }
        else
        {
            LiveViewCameraSegment.selectedSegmentIndex = 1
        }
        if UserDefaults.standard.bool(forKey: "RunningOnSimulator")
        {
            BackgroundTypeSegment.setEnabled(false, forSegmentAt: 3)
            LiveViewCameraSegment.isEnabled = false
            CameraText.isEnabled = false
            NotAvailableText.isHidden = false
            LiveViewTitle.isEnabled = false
        }
        
        var IsVertical: Bool = false
        var Reversed: Bool = false
        _ = GradientManager.ParseGradient(UserTheme!.BackgroundGradientColor, Vertical: &IsVertical, Reverse: &Reversed)
        VerticalGradientSwitch.isOn = IsVertical
    }
    
    func EditTheme(Theme: ThemeDescriptor, DefaultTheme: ThemeDescriptor)
    {
        UserTheme = Theme
        self.DefaultTheme = DefaultTheme
    }
    
    func EditTheme(Theme: ThemeDescriptor, PieceID: UUID, DefaultTheme: ThemeDescriptor)
    {
        UserTheme = Theme
        self.DefaultTheme = DefaultTheme
    }
    
    func UpdateBackgroundType(_ BGType: BackgroundTypes3D) -> BackgroundTypes3D
    {
        switch BGType
        {
            case .LiveView:
                if UserDefaults.standard.bool(forKey: "RunningOnSimulator")
                {
                    return .Color
                }
                return .LiveView
            
            case .CALayer:
                return .Color
            
            case .Texture:
                return .Image
            
            default:
                return BGType
        }
    }
    
    private let BackgroundTypeToIndexMap: [BackgroundTypes3D: Int] =
        [
            .CALayer: -1,
            .Texture: -1,
            .Color: 0,
            .Gradient: 1,
            .Image: 2,
            .LiveView: 3
    ]
    
    var UserTheme: ThemeDescriptor? = nil
    
    var DefaultTheme: ThemeDescriptor? = nil
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)  
    {
        //Do something...
    }
    
    @IBAction func HandleBackgroundTypeChanged(_ sender: Any)
    {
        let BGType = BackgroundTypeSegment.selectedSegmentIndex
        switch BGType
        {
            case 0:
                BackgroundType = .Color
            
            case 1:
                BackgroundType = .Gradient
            
            case 2:
                BackgroundType = .Image
            
            case 3:
                BackgroundType = .LiveView
            
            default:
                return
        }
        Settings.SetGameBackgroundType(NewValue: BGType)
        HandleBGChange(ToType: BackgroundType)
    }
    
    var BackgroundType: BackgroundTypes3D = .Color
    
    func HandleBGChange(ToType: BackgroundTypes3D)
    {
        switch ToType
        {
            case .Color:
                SolidColorTitle.textColor = ColorServer.ColorFrom(ColorNames.Black)
                GradientColorTitle.textColor = ColorServer.ColorFrom(ColorNames.DarkGray)
                ImageTitle.textColor = ColorServer.ColorFrom(ColorNames.DarkGray)
                LiveViewTitle.textColor = ColorServer.ColorFrom(ColorNames.DarkGray)
                SelectColorButton.isEnabled = true
                SelectGradientButton.isEnabled = false
                SelectImageButton.isEnabled = false
                LiveViewCameraSegment.isEnabled = false
                SolidColorBox.backgroundColor = ColorServer.ColorFrom(ColorNames.White)
                GradientColorBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
                ImageBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
                LiveViewBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
                VerticalGradientLabel.isEnabled = false
                VerticalGradientSwitch.isEnabled = false
            
            case .Gradient:
                SolidColorTitle.textColor = ColorServer.ColorFrom(ColorNames.DarkGray)
                GradientColorTitle.textColor = ColorServer.ColorFrom(ColorNames.Black)
                ImageTitle.textColor = ColorServer.ColorFrom(ColorNames.DarkGray)
                LiveViewTitle.textColor = ColorServer.ColorFrom(ColorNames.DarkGray)
                SelectColorButton.isEnabled = false
                SelectGradientButton.isEnabled = true
                SelectImageButton.isEnabled = false
                LiveViewCameraSegment.isEnabled = false
                SolidColorBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
                GradientColorBox.backgroundColor = ColorServer.ColorFrom(ColorNames.White)
                ImageBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
                LiveViewBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
                VerticalGradientLabel.isEnabled = true
                VerticalGradientSwitch.isEnabled = true
            
            case .Image:
                SolidColorTitle.textColor = ColorServer.ColorFrom(ColorNames.DarkGray)
                GradientColorTitle.textColor = ColorServer.ColorFrom(ColorNames.DarkGray)
                ImageTitle.textColor = ColorServer.ColorFrom(ColorNames.Black)
                LiveViewTitle.textColor = ColorServer.ColorFrom(ColorNames.DarkGray)
                SelectColorButton.isEnabled = false
                SelectGradientButton.isEnabled = false
                SelectImageButton.isEnabled = true
                LiveViewCameraSegment.isEnabled = false
                SolidColorBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
                GradientColorBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
                ImageBox.backgroundColor = ColorServer.ColorFrom(ColorNames.White)
                LiveViewBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
                VerticalGradientLabel.isEnabled = false
                VerticalGradientSwitch.isEnabled = false
            
            case .LiveView:
                SolidColorTitle.textColor = ColorServer.ColorFrom(ColorNames.DarkGray)
                GradientColorTitle.textColor = ColorServer.ColorFrom(ColorNames.DarkGray)
                ImageTitle.textColor = ColorServer.ColorFrom(ColorNames.DarkGray)
                LiveViewTitle.textColor = ColorServer.ColorFrom(ColorNames.Black)
                SelectColorButton.isEnabled = false
                SelectGradientButton.isEnabled = false
                SelectImageButton.isEnabled = false
                LiveViewCameraSegment.isEnabled = true
                SolidColorBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
                GradientColorBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
                ImageBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
                LiveViewBox.backgroundColor = ColorServer.ColorFrom(ColorNames.White)
                VerticalGradientLabel.isEnabled = false
                VerticalGradientSwitch.isEnabled = false
            
            default:
                break
        }
    }
    
    @IBOutlet weak var LiveViewCameraSegment: UISegmentedControl!
    @IBOutlet weak var BackgroundTypeSegment: UISegmentedControl!
    
    @IBAction func HandleSelectColorPressed(_ sender: Any)
    {
        let Storyboard = UIStoryboard(name: "Theming", bundle: nil)
        if let Controller = Storyboard.instantiateViewController(withIdentifier: "ColorPicker") as? ColorPickerCode
        {
            Controller.ColorDelegate = self
            Controller.ColorToEdit(UIColor.black, Tag: "BGEditor")
            self.present(Controller, animated: true, completion: nil)
        }
    }
    
    @IBSegueAction func InstantiateImagePicker(_ coder: NSCoder) -> SelectBackgroundImageCode?
    {
        let Picker = SelectBackgroundImageCode(coder: coder)
        Picker?.ThemeDelegate = self
        Picker?.EditTheme(Theme: UserTheme!, DefaultTheme: DefaultTheme!)
        return Picker
    }
    
    @IBSegueAction func InstantiateColorPicker(_ coder: NSCoder) -> ColorPickerCode?
    {
        let ColorPicker = ColorPickerCode(coder: coder)
        ColorPicker?.ColorDelegate = self
        let EditMe = ColorServer.ColorFrom(UserTheme!.BackgroundSolidColor)
        ColorPicker?.ColorToEdit(EditMe, Tag: "SolidColorPicker")
        return ColorPicker
    }
    
    @IBSegueAction func InstantiateGradientEditor(_ coder: NSCoder) -> GradientEditorCode?
    {
        let GradientEditor = GradientEditorCode(coder: coder)
        GradientEditor?.GradientDelegate = self
        GradientEditor?.GradientToEdit(UserTheme!.BackgroundGradientColor, Tag: "GradientColorPicker")
        return GradientEditor
    }
    
    func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
        //Should not be called.
    }
    
    func EditedColor(_ Edited: UIColor?, Tag: Any?)
    {
        if let RawTag = Tag as? String
        {
            if RawTag == "SolidColorPicker"
            {
                if let FinalColor = Edited
                {
                    ColorSample.TopColor = FinalColor
                    UserTheme!.BackgroundSolidColor = ColorServer.MakeColorName(From: FinalColor)!
                }
            }
        }
    }
    
    // MARK: Gradient protocol functions.
    
    func EditedGradient(_ Edited: String?, Tag: Any?)
    {
        if let RawTag = Tag as? String
        {
            if RawTag == "GradientColorPicker"
            {
                let IsVertical = VerticalGradientSwitch.isOn
                let Final = ForceVerticalGradient(Edited!, VerticalFlag: IsVertical)
                GradientSample.GradientDescriptor = Final
                UserTheme!.BackgroundGradientColor = Final
            }
        }
    }
    
    func ForceVerticalGradient(_ RawGradient: String, VerticalFlag: Bool) -> String
    {
        var NotUsed: Bool = false
        var Reversed: Bool = false
        let Stops = GradientManager.ParseGradient(RawGradient, Vertical: &NotUsed, Reverse: &Reversed)
        let Final = GradientManager.AssembleGradient(Stops, IsVertical: VerticalFlag, Reverse: Reversed)
        return Final
    }
    
    @IBAction func HandleVerticalSwitchChanged(_ sender: Any)
    {
        let VerticalSwitch = VerticalGradientSwitch.isOn
        let Final = ForceVerticalGradient(UserTheme!.BackgroundGradientColor, VerticalFlag: VerticalSwitch)
        UserTheme!.BackgroundGradientColor = Final
        GradientSample.GradientDescriptor = Final
    }
    
    func GradientToEdit(_ Edited: String?, Tag: Any?)
    {
        //Not used in this class.
    }
    
    func SetStop(StopColorIndex: Int)
    {
        //Not used in this class.
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: UserTheme!.ID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var NotAvailableText: UILabel!
    @IBOutlet weak var CameraText: UILabel!
    @IBOutlet weak var ImageViewer: UIImageView!
    @IBOutlet weak var LiveViewTitle: UILabel!
    @IBOutlet weak var ImageTitle: UILabel!
    @IBOutlet weak var GradientColorTitle: UILabel!
    @IBOutlet weak var SolidColorTitle: UILabel!
    @IBOutlet weak var SelectImageButton: UIButton!
    @IBOutlet weak var SelectGradientButton: UIButton!
    @IBOutlet weak var SelectColorButton: UIButton!
    @IBOutlet weak var ColorSample: ColorSwatchColor!
    @IBOutlet weak var GradientSample: GradientSwatch!
    @IBOutlet weak var ImageSample: UIView!
    @IBOutlet weak var ImageBox: UIView!
    @IBOutlet weak var LiveViewBox: UIView!
    @IBOutlet weak var GradientColorBox: UIView!
    @IBOutlet weak var SolidColorBox: UIView!
    @IBOutlet weak var VerticalGradientLabel: UILabel!
    @IBOutlet weak var VerticalGradientSwitch: UISwitch!
}

