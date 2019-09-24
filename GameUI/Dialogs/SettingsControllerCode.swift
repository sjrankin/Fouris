//
//  SettingsControllerCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/23/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SettingsControllerCode: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource
{

    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        LanguageBox.layer.borderColor = UIColor.black.cgColor
        LanguageBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
        
        CameraControlBox.layer.borderColor = UIColor.black.cgColor
        CameraControlBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
        CameraControlBox.frame = CGRect(x: CameraControlBox.frame.minX, y: CameraControlBox.frame.minY,
                                        width: CameraControlBox.frame.width, height: 128)
        MotionControlsBox.layer.borderColor = UIColor.black.cgColor
        MotionControlsBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
        MotionControlsBox.frame = CGRect(x: MotionControlsBox.frame.minX, y: MotionControlsBox.frame.minY,
                                        width: MotionControlsBox.frame.width, height: 128)
        TopToolbarBox.layer.borderColor = UIColor.black.cgColor
        TopToolbarBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
        TopToolbarBox.frame = CGRect(x: TopToolbarBox.frame.minX, y: TopToolbarBox.frame.minY,
                                         width: TopToolbarBox.frame.width, height: 128)
        
        ShowCameraSwitch.isOn = Settings.GetShowCameraControls()
        ShowMotionControlsSwitch.isOn = Settings.GetShowMotionControls()
        ShowTopToolbarSwitch.isOn = Settings.GetShowTopToolbar()
        SetCameraState()
        for LanguageName in SupportedLanguages.allCases
        {
            LanguageList.append("\(LanguageName)")
        }
        let CurrentLanguage = Settings.GetInterfaceLanguage()
        let LanguageString = "\(CurrentLanguage)"
        if let Index = LanguageList.firstIndex(of: LanguageString)
        {
            LanguagePicker.selectRow(Index, inComponent: 0, animated: true)
        }
        ColorNameLanguageSwitch.isOn = Settings.GetShowColorsInSourceLanguage()
    }
    
    var LanguageList = [String]()
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return SupportedLanguages.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return LanguageList[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        SelectedLanguage = LanguageList[row]
    }
    
    var SelectedLanguage = ""
    
    @IBAction func HandleSetLanguagePressed(_ sender: Any)
    {
        if let NewLanguage = SupportedLanguages(rawValue: SelectedLanguage)
        {
        Settings.SetInterfaceLanguage(NewValue: NewLanguage)
        }
    }
    
    func SetCameraState()
    {
        ShowCameraText.isEnabled = Settings.GetShowTopToolbar()
        ShowCameraSwitch.isEnabled = Settings.GetShowTopToolbar()
    }
    
    @IBAction func HandleCameraSwitchChanged(_ sender: Any)
    {
        Settings.SetShowCameraControls(NewValue: ShowCameraSwitch.isOn)
    }
    
    @IBAction func HandleMotionControlsSwitchChanged(_ sender: Any)
    {
        Settings.SetShowMotionControls(NewValue: ShowMotionControlsSwitch.isOn)
    }
    
    @IBAction func HandleTopToolbarSwitchChanged(_ sender: Any)
    {
        Settings.SetShowTopToolbar(NewValue: ShowTopToolbarSwitch.isOn)
        SetCameraState()
    }
    
    @IBAction func HandleColorNameLanguageSwitchChanged(_ sender: Any)
    {
        Settings.SetShowColorsInSourceLanguage(NewValue: ColorNameLanguageSwitch.isOn)
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var ColorNameLanguageSwitch: UISwitch!
    @IBOutlet weak var LanguagePicker: UIPickerView!
    @IBOutlet weak var LanguageBox: UIView!
    @IBOutlet weak var ShowCameraText: UILabel!
    @IBOutlet weak var ShowTopToolbarSwitch: UISwitch!
    @IBOutlet weak var ShowMotionControlsSwitch: UISwitch!
    @IBOutlet weak var ShowCameraSwitch: UISwitch!
    @IBOutlet weak var CameraControlBox: UIView!
    @IBOutlet weak var MotionControlsBox: UIView!
    @IBOutlet weak var TopToolbarBox: UIView!
}
