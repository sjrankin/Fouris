//
//  GameBackgroundDialog.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GameBackgroundDialog: UIViewController, ColorPickerProtocol, ThemeEditingProtocol
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
        BackgroundType = GameBackgroundTypes(rawValue: Settings.GetGameBackgroundType())!
        
        if UserDefaults.standard.bool(forKey: "RunningOnSimulator")
        {
            if BackgroundType == .LiveView
            {
                BackgroundType = .SolidColor
            }
            BackgroundTypeSegment.setEnabled(false, forSegmentAt: 3)
            LiveViewCameraSegment.isEnabled = false
            CameraText.isEnabled = false
            NotAvailableText.isHidden = false
        }
        else
        {
            NotAvailableText.isHidden = true
        }
        
        HandleBGChange(ToType: BackgroundType)
        switch BackgroundType
        {
            case .SolidColor:
                BackgroundTypeSegment.selectedSegmentIndex = 0
            
            case .GradientColor:
                BackgroundTypeSegment.selectedSegmentIndex = 1
            
            case .Image:
                BackgroundTypeSegment.selectedSegmentIndex = 2
            
            case .LiveView:
                BackgroundTypeSegment.selectedSegmentIndex = 3
        }
    }
    
    func EditTheme(ID: UUID)
    {
        ThemeID = ID
    }
    
    func EditTheme(ID: UUID, PieceID: UUID)
    {
        ThemeID = ID
    }
    
    var ThemeID: UUID = UUID.Empty
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)  
    {
        //Do something...
    }
    
    @IBAction func HandleBackgroundTypeChanged(_ sender: Any)
    {
        let BGType = BackgroundTypeSegment.selectedSegmentIndex
        BackgroundType = GameBackgroundTypes(rawValue: BGType)!
        Settings.SetGameBackgroundType(NewValue: BGType)
        HandleBGChange(ToType: BackgroundType)
    }
    
    var BackgroundType: GameBackgroundTypes = .SolidColor
    
    func HandleBGChange(ToType: GameBackgroundTypes)
    {
        switch ToType
        {
            case .SolidColor:
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
            
            case .GradientColor:
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
        Picker?.EditTheme(ID: ThemeID)
        return Picker
    }
    
    @IBSegueAction func InstantiateColorPicker(_ coder: NSCoder) -> ColorPickerCode?
    {
        let ColorPicker = ColorPickerCode(coder: coder)
        ColorPicker?.ColorDelegate = self
        ColorPicker?.ColorToEdit(UIColor.green, Tag: "SolidColorPicker")
        return ColorPicker
    }
    
    @IBSegueAction func InstantiateGradientEditor(_ coder: NSCoder) -> GradientEditorCode?
    {
        let GradientEditor = GradientEditorCode(coder: coder)
        return GradientEditor
    }
    
    func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
        //Should not be called.
    }
    
    func EditedColor(_ Edited: UIColor?, Tag: Any?)
    {
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: ThemeID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(false, ThemeID: ThemeID, PieceID: nil)
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
    @IBOutlet weak var ColorSample: UIView!
    @IBOutlet weak var GradientSample: UIView!
    @IBOutlet weak var ImageSample: UIView!
    @IBOutlet weak var ImageBox: UIView!
    @IBOutlet weak var LiveViewBox: UIView!
    @IBOutlet weak var GradientColorBox: UIView!
    @IBOutlet weak var SolidColorBox: UIView!
}

/// Background types for games.
/// - **SolidColor**: Solid color values.
/// - **GradientColor**: Gradent colors.
/// - **Image**: Images from the user.
/// - **LiveView**: Live view from the camera. If camera not available, this option is invalid.
enum GameBackgroundTypes: Int, CaseIterable
{
    case SolidColor = 0
    case GradientColor = 1
    case Image = 2
    case LiveView = 3
}
