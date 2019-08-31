//
//  GameBackgroundDialog.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GameBackgroundDialog: UIViewController, ColorPickerProtocol
{
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
        HandleBGChange(ToIndex: 0)
    }
    
    @IBAction func HandleBackgroundTypeChanged(_ sender: Any)
    {
        let BGType = BackgroundTypeSegment.selectedSegmentIndex
        HandleBGChange(ToIndex: BGType)
    }
    
    func HandleBGChange(ToIndex: Int)
    {
        switch ToIndex
        {
            case 0:
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
            
            case 1:
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
            
            case 2:
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
            
            case 3:
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
            
            default:
                fatalError("Encountered unexpected segment index \(ToIndex) in HandleBGChange.")
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
            self.present(Controller, animated: true, completion: nil)
            Controller.ColorToEdit(UIColor.black, Tag: "BGEditor")
        }
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
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
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
