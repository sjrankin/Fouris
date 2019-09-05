//
//  GradientStopEditorCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/4/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GradientStopEditorCode: UIViewController, ColorPickerProtocol, GradientPickerProtocol
{
    weak var GradientDelegate: GradientPickerProtocol? = nil
    
    var IsVertical: Bool = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        if StopIndex < 0
        {
            fatalError("Invalid gradient stop index - less than zero.")
        }
        else
        {
            let (Color, Location) = GradientManager.GradientStop(From: OriginalGradient, At: StopIndex)!
            StopColorToEdit = Color
            StopLocationToEdit = Double(Location)
        }
        
        SampleView.layer.borderColor = UIColor.black.cgColor
        CurrentColorSample.layer.borderColor = UIColor.black.cgColor
        
        LocationSlider.value = Float(StopLocationToEdit * 1000.0)
        LocationText.text = "\(StopLocationToEdit.Round(To: 3))"
        
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleTapOnSample))
        SampleView.addGestureRecognizer(Tap)
        
        UpdateUI()
    }
    
    override func viewDidLayoutSubviews()
    {
        UpdateUI()
    }
    
    @objc func HandleTapOnSample(TapGesture: UITapGestureRecognizer)
    {
        if TapGesture.state == .ended
        {
            IsVertical = !IsVertical
            UpdateUI()
        }
    }
    
    func UpdateUI()
    {
        CurrentColorSample.backgroundColor = StopColorToEdit
        let SampleGradient = GradientManager.ReplaceGradientStop(OriginalGradient, Color: StopColorToEdit, Location: CGFloat(StopLocationToEdit), AtIndex: StopIndex)
        let GradientImage = GradientManager.CreateGradientImage(From: SampleGradient!,
                                                                WithFrame: SampleView.bounds,
                                                                IsVertical: IsVertical, ReverseColors: false)
        SampleImage.image = GradientImage
    }
    
    @IBSegueAction func HandleColorPickerInstantiation(_ coder: NSCoder) -> ColorPickerCode?
    {
        let ColorPicker = ColorPickerCode(coder: coder)
        ColorPicker?.ColorDelegate = self
        ColorPicker?.ColorToEdit(StopColorToEdit, Tag: "StopColor")
        return ColorPicker
    }
    
    func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
        //Not used in this class.
    }
    
    func EditedColor(_ Color: UIColor?, Tag: Any?)
    {
        if let NewColor = Color
        {
            if let CallerTag = Tag as? String
            {
                if CallerTag == "StopColor"
                {
                    CurrentColorSample.backgroundColor = NewColor
                    UpdateGradient(WithColor: NewColor)
                    UpdateUI()
                }
            }
        }
    }
    
    func EditedGradient(_ Edited: String?, Tag: Any?)
    {
        //Not used in this class.
    }
    
    func GradientToEdit(_ EditMe: String?, Tag: Any?)
    {
        OriginalGradient = EditMe == nil ? "" : EditMe!
        ParentTag = Tag
    }
    
    var OriginalGradient: String = ""
    var ParentTag: Any?
    
    func SetStop(StopColorIndex: Int)
    {
        StopIndex = StopColorIndex
    }
    
    var StopIndex = -1
    
    func UpdateGradient(WithLocation: Double)
    {
        StopLocationToEdit = WithLocation
        UpdateUI()
    }
    
    func UpdateGradient(WithColor: UIColor)
    {
        StopColorToEdit = WithColor
        UpdateUI()
    }
    
    @IBAction func HandleNewTextLocation(_ sender: Any)
    {
        guard let Value = Double(LocationText.text!) else
        {
            LocationText.text = "0.5"
            LocationSlider.value = 500.0
            StopLocationToEdit = 0.5
            UpdateUI()
            return
        }
        let Position = Value.Clamp(0.0, 1.0)
        LocationSlider.value = Float(Position * 1000.0)
        StopLocationToEdit = Position
        UpdateUI()
    }
    
    @IBAction func HandleLocationSliderChanged(_ sender: Any)
    {
        let SliderValue = Double(LocationSlider.value / 1000.0)
        UpdateGradient(WithLocation: SliderValue)
        LocationText.text = "\(SliderValue.Round(To: 3))"
    }
    
    var OriginalColor: UIColor = UIColor.black
    var StopColorToEdit: UIColor = UIColor.black
    var OriginalLocation: Double = 0.0
    var StopLocationToEdit: Double = 0.0
    
    @IBAction func HandleResetPressed(_ sender: Any)
    {
        StopLocationToEdit = OriginalLocation
        StopColorToEdit = OriginalColor
        UpdateUI()
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        let Final = GradientManager.ReplaceGradientStop(OriginalGradient, Color: StopColorToEdit,
                                                        Location: CGFloat(StopLocationToEdit),
                                                        AtIndex: StopIndex)
        GradientDelegate?.EditedGradient(Final, Tag: ParentTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        GradientDelegate?.EditedGradient(nil, Tag: ParentTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var LocationSlider: UISlider!
    @IBOutlet weak var LocationText: UITextField!
    @IBOutlet weak var SampleView: UIView!
    @IBOutlet weak var SampleImage: UIImageView!
    @IBOutlet weak var CurrentColorSample: UIView!
}
