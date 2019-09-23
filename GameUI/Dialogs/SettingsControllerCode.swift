//
//  SettingsControllerCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/23/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SettingsControllerCode: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
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
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var ShowCameraText: UILabel!
    @IBOutlet weak var ShowTopToolbarSwitch: UISwitch!
    @IBOutlet weak var ShowMotionControlsSwitch: UISwitch!
    @IBOutlet weak var ShowCameraSwitch: UISwitch!
    @IBOutlet weak var CameraControlBox: UIView!
    @IBOutlet weak var MotionControlsBox: UIView!
    @IBOutlet weak var TopToolbarBox: UIView!
}
