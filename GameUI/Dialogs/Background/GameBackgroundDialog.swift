//
//  GameBackgroundDialog.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// The code that runs the game background selection dialog.
class GameBackgroundDialog: UIViewController, ColorPickerProtocol, GradientPickerProtocol, ThemeEditingProtocol
{
    /// Delegate that receives results of the dialog.
    public weak var ThemeDelegate: ThemeEditingProtocol? = nil
    /// Delegate that allows us to edit colors.
    public weak var ColorDelegate: ColorPickerProtocol? = nil
    
    /// UI initialization.
    override public func viewDidLoad()
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
        
        let ColorCycleTime = UserTheme!.BackgroundSolidColorCycleTime
        ColorCycleDuration.selectedSegmentIndex = CycleTimeToUI(CycleTime: ColorCycleTime)
        let GradientCycleTime = UserTheme!.BackgroundGradientCycleTime
        GradientCycleDuration.selectedSegmentIndex = CycleTimeToUI(CycleTime: GradientCycleTime)
        
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
        #if targetEnvironment(simulator)
            BackgroundTypeSegment.setEnabled(false, forSegmentAt: 3)
            LiveViewCameraSegment.isEnabled = false
            CameraText.isEnabled = false
            NotAvailableText.isHidden = false
            LiveViewTitle.isEnabled = false
        #else
        NotAvailableText.isHidden = true
        NotAvailableText.alpha = 0.0
        #endif
    }
    
    /// Converts an integer cycle time for colors or gradients into an index value for a segmented control.
    /// - Parameter CycleTime: The value to convert.
    /// - Returns: Index to use with a segmented control. Assumes all segmented controls used for cycle times have the same
    ///            number of segments.
    public func CycleTimeToUI(CycleTime: Double) -> Int
    {
        let ITime = Int(CycleTime)
        switch ITime
        {
            case 0:
            return 0
            
            case 15:
            return 1
            
            case 30:
            return 2
            
            case 60:
            return 3
            
            case 90:
            return 4
            
            case 300:
            return 5
            
            case 600:
            return 6
            
            default:
            return 3
        }
    }
    
    /// Converts a cycle time specified in the UI (via a segmented control) to an actual value the UI can use.
    /// - Parameter Index: The selected index from a segmented control.
    /// - Returns: Cycle time value for cycling through colors or gradients.
    public func UICycleTimeToSeconds(Index: Int) -> Double
    {
        switch Index
        {
            case 0:
                return 0.0
            
            case 1:
                return 15.0
            
            case 2:
                return 30.0
            
            case 3:
                return 60.0
            
            case 4:
                return 90.0
            
            case 5:
                return 300.0
            
            case 6:
                return 600.0
            
            default:
                return 0.0
        }
    }
    
    /// Handle changes to color cycle times segmented control.
    /// - Parameter sender: not used.
    @IBAction public func HandleColorCycleTimeChanged(_ sender: Any)
    {
        let Index = ColorCycleDuration.selectedSegmentIndex
        UserTheme!.BackgroundSolidColorCycleTime = UICycleTimeToSeconds(Index: Index)
        if UserTheme!.BackgroundSolidColorCycleTime == 0.0
        {
            ColorSample.EnableHueShifting = false
        }
        else
        {
            ColorSample.HueShiftDuration = UserTheme!.BackgroundSolidColorCycleTime
                        ColorSample.EnableHueShifting = true
        }
    }
    
    /// Handle changes to gradient cycle times segmented control.
    /// - Parameter sender: not used.
    @IBAction public func HandleGradientCycleTimeChanged(_ sender: Any)
    {
        let Index = GradientCycleDuration.selectedSegmentIndex
        UserTheme!.BackgroundGradientCycleTime = UICycleTimeToSeconds(Index: Index)
        if UserTheme!.BackgroundGradientCycleTime == 0.0
        {
            GradientSample.EnableHueShifting = false
        }
        else
        {
            GradientSample.HueShiftDuration = UserTheme!.BackgroundGradientCycleTime
            GradientSample.EnableHueShifting = true
        }
    }
    
    /// Called by the parent.
    /// - Parameter Theme: The theme being edited.
    public func EditTheme(Theme: ThemeDescriptor2)
    {
        UserTheme = Theme
    }

    /// Called by the parent.
    /// - Parameter Theme: The theme being edited.
    /// - Parameter PieceID: Not used.
    public func EditTheme(Theme: ThemeDescriptor2, PieceID: UUID)
    {
        UserTheme = Theme
    }
    
    /// Update the UI based on the selected background type.
    /// - Parameter BGType: The background type selected by the user.
    /// - Returns: A background type.
    public func UpdateBackgroundType(_ BGType: BackgroundTypes3D) -> BackgroundTypes3D
    {
        switch BGType
        {
            case .LiveView:
                #if targetEnvironment(simulator)
                return .Color
                #else
                return .LiveView
                #endif
            
            case .CALayer:
                return .Color
            
            case .Texture:
                return .Image
            
            default:
                return BGType
        }
    }
    
    /// Map from background types to UI segmented control indices. -1 indicates unimplemented types.
    private let BackgroundTypeToIndexMap: [BackgroundTypes3D: Int] =
        [
            .CALayer: -1,
            .Texture: -1,
            .Color: 0,
            .Gradient: 1,
            .Image: 2,
            .LiveView: 3
    ]
    
    /// Holds the current theme to edit.
    public var UserTheme: ThemeDescriptor2? = nil
    
    /// Not currently used.
    public func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //Do something...
    }
    
    /// Handle changes in the UI segmented control that determines the background type.
    @IBAction public func HandleBackgroundTypeChanged(_ sender: Any)
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
        UserTheme!.BackgroundType = BackgroundType
        HandleBGChange(ToType: BackgroundType)
    }
    
    /// Working background type.
    private var BackgroundType: BackgroundTypes3D = .Color
    
    /// Update the UI to reflect the currently selected background type.
    /// - Parameter ToType: The background type the UI will be set for.
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
                ColorCycleLabel.isEnabled = true
                ColorCycleDuration.isEnabled = true
                GradientCycleLabel.isEnabled = false
                GradientCycleDuration.isEnabled = false
            
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
                ColorCycleLabel.isEnabled = false
                ColorCycleDuration.isEnabled = false
                GradientCycleLabel.isEnabled = true
                GradientCycleDuration.isEnabled = true
            
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
                ColorCycleLabel.isEnabled = false
                ColorCycleDuration.isEnabled = false
                GradientCycleLabel.isEnabled = false
                GradientCycleDuration.isEnabled = false
            
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
                ColorCycleLabel.isEnabled = false
                ColorCycleDuration.isEnabled = false
                GradientCycleLabel.isEnabled = false
                GradientCycleDuration.isEnabled = false
            
            default:
                break
        }
    }
    
    @IBOutlet weak var LiveViewCameraSegment: UISegmentedControl!
    @IBOutlet weak var BackgroundTypeSegment: UISegmentedControl!
    
    /// Run the color editor for changing the background color.
    /// - Parameter sender: Not used.
    @IBAction public func HandleSelectColorPressed(_ sender: Any)
    {
        let Storyboard = UIStoryboard(name: "Theming", bundle: nil)
        if let Controller = Storyboard.instantiateViewController(withIdentifier: "ColorPicker") as? ColorPickerCode
        {
            Controller.ColorDelegate = self
            Controller.ColorToEdit(UIColor.black, Tag: "BGEditor")
            self.present(Controller, animated: true, completion: nil)
        }
    }
    
    /// Run the image selector for changing the background image.
    /// - Parameter coder: The `NSCoder` value used to instantiate the image selector.
    /// - Returns: Code to run the image selector.
    @IBSegueAction public func InstantiateImagePicker(_ coder: NSCoder) -> SelectBackgroundImageCode?
    {
        let Picker = SelectBackgroundImageCode(coder: coder)
        Picker?.ThemeDelegate = self
        Picker?.EditTheme(Theme: UserTheme!)
        return Picker
    }
    
    /// Run the color picker.
    /// - Parameter coder: The `NSCoder` value used to instantiate the color picker.
    /// - Returns: Code to run the color picker.
    @IBSegueAction public func InstantiateColorPicker(_ coder: NSCoder) -> ColorPickerCode?
    {
        let ColorPicker = ColorPickerCode(coder: coder)
        ColorPicker?.ColorDelegate = self
        let EditMe = ColorServer.ColorFrom(UserTheme!.BackgroundSolidColor)
        ColorPicker?.ColorToEdit(EditMe, Tag: "SolidColorPicker")
        return ColorPicker
    }
    
    /// Run the gradient editor.
    /// - Parameter coder: The `NSCoder` value used to instantiate the gradient editor.
    /// - Returns: Code to run the gradient editor.
    @IBSegueAction public func InstantiateGradientEditor(_ coder: NSCoder) -> GradientEditorCode?
    {
        let GradientEditor = GradientEditorCode(coder: coder)
        GradientEditor?.GradientDelegate = self
        GradientEditor?.GradientToEdit(UserTheme!.BackgroundGradientColor, Tag: "GradientColorPicker")
        return GradientEditor
    }
    
    /// Not implemented and not expected to be called.
    public func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
        //Should not be called.
    }
    
    /// Called by the color picker once the picker is closed.
    /// - Parameter Edited: If not nil, the new color selected by the user. If nil, the user canceled the color picker.
    /// - Parameter Tag: The tag value sent to the color picker by this instance.
    public func EditedColor(_ Edited: UIColor?, Tag: Any?)
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
    
    /// Called by the gradient editor once the editor is closed.
    /// - Parameter Edited: If not nil, the new gradiented selected/editor by the user. If nil, the editor was canceled by the user.
    /// - Parameter Tag: The tag value sent to the gradient editor by this instance.
    public func EditedGradient(_ Edited: String?, Tag: Any?)
    {
        if let RawTag = Tag as? String
        {
            if RawTag == "GradientColorPicker"
            {
                if let FinalEdit = Edited
                {
                GradientSample.GradientDescriptor = FinalEdit
                UserTheme!.BackgroundGradientColor = FinalEdit
                }
            }
        }
    }
    
    /// Forces a gradient to the passed vertical flag.
    /// - Parameter RawGradient: The gradient whose vertical flag is forced to the passed value.
    /// - Parameter VerticalFlag: The vertical flag the passed gradient will take on. True for vertical gradients, false for
    ///                           horizontal gradients.
    /// - Returns: Edited gradient.
    public func ForceVerticalGradient(_ RawGradient: String, VerticalFlag: Bool) -> String
    {
        var NotUsed: Bool = false
        var Reversed: Bool = false
        let Stops = GradientManager.ParseGradient(RawGradient, Vertical: &NotUsed, Reverse: &Reversed)
        let Final = GradientManager.AssembleGradient(Stops, IsVertical: VerticalFlag, Reverse: Reversed)
        return Final
    }
    
    /// Not used. Required by protocol.
    public func GradientToEdit(_ Edited: String?, Tag: Any?)
    {
        //Not used in this class.
    }
    
    /// Not used. Required by protocol.
    public func SetStop(StopColorIndex: Int)
    {
        //Not used in this class.
    }
    
    /// Handle the close button pressed. Update the caller with changes. Close the dialog.
    /// - Parameter sender: Not used.
    @IBAction public func HandleClosePressed(_ sender: Any)
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
    @IBOutlet weak var ColorCycleLabel: UILabel!
    @IBOutlet weak var GradientCycleLabel: UILabel!
    @IBOutlet weak var ColorCycleDuration: UISegmentedControl!
    @IBOutlet weak var GradientCycleDuration: UISegmentedControl!
}

