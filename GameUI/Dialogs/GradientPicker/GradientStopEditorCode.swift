//
//  GradientStopEditorCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/4/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Code to run the UI for editing a color stop.
class GradientStopEditorCode: UIViewController, ColorPickerProtocol, GradientPickerProtocol
{
    /// Delegate that receives messages from this class.
    public weak var GradientDelegate: GradientPickerProtocol? = nil
    
    /// Holds the vertical gradient flag.
    private var IsVertical: Bool = false
    
    /// Initialize the UI.
    override public func viewDidLoad()
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
    
    /// Update the UI when the layout changes.
    override public func viewDidLayoutSubviews()
    {
        UpdateUI()
    }
    
    /// Handle taps on the sample. When the user taps on the sample, the orientation of the gradient will change.
    /// - Parameter TapGesture: Tap information.
    @objc public func HandleTapOnSample(TapGesture: UITapGestureRecognizer)
    {
        if TapGesture.state == .ended
        {
            IsVertical = !IsVertical
            UpdateUI()
        }
    }
    
    /// Update the UI with new gradient information.
    private func UpdateUI()
    {
        CurrentColorSample.backgroundColor = StopColorToEdit
        let SampleGradient = GradientManager.ReplaceGradientStop(OriginalGradient, Color: StopColorToEdit, Location: CGFloat(StopLocationToEdit), AtIndex: StopIndex)
        let GradientImage = GradientManager.CreateGradientImage(From: SampleGradient!,
                                                                WithFrame: SampleView.bounds,
                                                                IsVertical: IsVertical, ReverseColors: false)
        SampleImage.image = GradientImage
    }
    
    /// Run the color picker.
    /// - Parameter coder: `NSCoder` instance used to create the color picker code instance.
    /// - Returns: `ColorPickerCode` instance.
    @IBSegueAction public func HandleColorPickerInstantiation(_ coder: NSCoder) -> ColorPickerCode?
    {
        let ColorPicker = ColorPickerCode(coder: coder)
        ColorPicker?.ColorDelegate = self
        ColorPicker?.ColorToEdit(StopColorToEdit, Tag: "StopColor")
        return ColorPicker
    }
    
    /// Not used in this class.
    public func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
        //Not used in this class.
    }
    
    /// Called by the color picker when it closes.
    /// - Parameter Color: If not nil, the new color from the color picker. If nil, the user canceled the color picker.
    /// - Parameter Tag: Tag value we sent to the color picker when it was invoked.
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
    
    /// Not used in this class.
    public func EditedGradient(_ Edited: String?, Tag: Any?)
    {
        //Not used in this class.
    }
    
    /// Called by the parent UI. Used to tell us the gradient to edit.
    /// - Parameter EditMe: The gradient to edit.
    /// - Parameter Tag: Arbitrary value sent by the caller.
    public func GradientToEdit(_ EditMe: String?, Tag: Any?)
    {
        OriginalGradient = EditMe == nil ? "" : EditMe!
        ParentTag = Tag
    }
    
    /// The original gradient from the caller.
    private var OriginalGradient: String = ""
    /// The tag value from the caller.
    private var ParentTag: Any?
    
    /// Sets the stop index of the color stop.
    /// - Parameter StopColorIndex: The index of the color stop in the full set of color stops.
    public func SetStop(StopColorIndex: Int)
    {
        StopIndex = StopColorIndex
    }
    
    /// Holds the color stop index.
    private var StopIndex = -1
    
    /// Update the gradient with a new color stop location.
    /// - Parameter WithLocation: The new location.
    private func UpdateGradient(WithLocation: Double)
    {
        StopLocationToEdit = WithLocation
        UpdateUI()
    }
    
    /// Update the gradient with a new color for the color stop.
    /// - Parameter WithColor: New color.
    private func UpdateGradient(WithColor: UIColor)
    {
        StopColorToEdit = WithColor
        UpdateUI()
    }
    
    /// Handle new text events from the text box. In this case, we have a new location value. Parse the value and apply it.
    /// - Parameter sender: Not used.
    @IBAction public func HandleNewTextLocation(_ sender: Any)
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
    
    /// Handle new slider location values. Apply the new value to the color stop.
    /// - Parameter sender: Not used.
    @IBAction public func HandleLocationSliderChanged(_ sender: Any)
    {
        let SliderValue = Double(LocationSlider.value / 1000.0)
        UpdateGradient(WithLocation: SliderValue)
        LocationText.text = "\(SliderValue.Round(To: 3))"
    }
    
    /// The original color stop color.
    private var OriginalColor: UIColor = UIColor.black
    /// The color stop color to edit.
    private var StopColorToEdit: UIColor = UIColor.black
    /// The original color stop location.
    private var OriginalLocation: Double = 0.0
    /// The color stop location to edit.
    private var StopLocationToEdit: Double = 0.0
    
    /// Handle the reset button. Reset the color and location to original values.
    /// - Parameter sender: Not used.
    @IBAction public func HandleResetPressed(_ sender: Any)
    {
        StopLocationToEdit = OriginalLocation
        StopColorToEdit = OriginalColor
        UpdateUI()
    }
    
    /// Handle the OK button pressed. Notify the caller of new values. Close the dialog.
    /// - Parameter sender: Not used.
    @IBAction public func HandleOKPressed(_ sender: Any)
    {
        let Final = GradientManager.ReplaceGradientStop(OriginalGradient, Color: StopColorToEdit,
                                                        Location: CGFloat(StopLocationToEdit),
                                                        AtIndex: StopIndex)
        GradientDelegate?.EditedGradient(Final, Tag: ParentTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the cancel button pressed. Notify the caller of the cancellation. Close the dialog.
    /// - Parameter sender: Not used.
    @IBAction public func HandleCancelPressed(_ sender: Any)
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
