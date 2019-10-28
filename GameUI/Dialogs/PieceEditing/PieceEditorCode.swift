//
//  PieceEditorCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Code to run the UI for editing visuals of a piece.
class PieceEditorCode: UIViewController, ThemeEditingProtocol, ColorPickerProtocol
{
    /// Delegate that receives messages related to theme changes.
    public weak var ThemeDelegate: ThemeEditingProtocol? = nil
    /// Delegate that receives messages related to color changes.
    public weak var ColorDelegate: ColorPickerProtocol? = nil
    
    // MARK: - Initialization.
    
    /// Initialize the UI.
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        StyleVisuals()
        ScaleSlider.value = 90.0
        ScaleValueLabel.text = "90°"
    }
    
    /// Apply default attributes to the buttons and samples.
    private func StyleVisuals()
    {
        ActiveDiffuseColorButton.ButtonColor = UIColor.orange
        ActiveSpecularColorButton.ButtonColor = UIColor.yellow
        RetiredDiffuseColorButton.ButtonColor = UIColor.brown
        RetiredSpecularColorButton.ButtonColor = UIColor.red
        
        ActiveSamplePiece.layer.borderColor = UIColor.black.cgColor
        ActiveSamplePiece.backgroundColor = ColorServer.ColorFrom(ColorNames.AzukiIro)
        ActiveDiffuseColorButton.layer.cornerRadius = 5.0
        ActiveDiffuseColorButton.layer.borderColor = UIColor.black.cgColor
        ActiveDiffuseColorButton.layer.borderWidth = 0.5
        ActiveDiffuseColorButton.clipsToBounds = true
        ActiveSpecularColorButton.layer.cornerRadius = 5.0
        ActiveSpecularColorButton.layer.borderColor = UIColor.black.cgColor
        ActiveSpecularColorButton.layer.borderWidth = 0.5
        ActiveSpecularColorButton.clipsToBounds = true
        
        RetiredSamplePiece.layer.borderColor = UIColor.black.cgColor
        RetiredSamplePiece.backgroundColor = ColorServer.ColorFrom(ColorNames.AzukiIro)
        RetiredDiffuseColorButton.layer.cornerRadius = 5.0
        RetiredDiffuseColorButton.layer.borderColor = UIColor.black.cgColor
        RetiredDiffuseColorButton.layer.borderWidth = 0.5
        RetiredDiffuseColorButton.clipsToBounds = true
        RetiredSpecularColorButton.layer.cornerRadius = 5.0
        RetiredSpecularColorButton.layer.borderColor = UIColor.black.cgColor
        RetiredSpecularColorButton.layer.borderWidth = 0.5
        RetiredSpecularColorButton.clipsToBounds = true
        
        RotationSegment.selectedSegmentIndex = 0
        
        let ActiveShapeTap = UITapGestureRecognizer(target: self, action: #selector(HandleActiveShapeTap))
        ActiveBlockView.addGestureRecognizer(ActiveShapeTap)
        let RetiredShapeTap = UITapGestureRecognizer(target: self, action: #selector(HandleRetiredShapeTap))
        RetiredBlockView.addGestureRecognizer(RetiredShapeTap)
        
        //Sample block views for setting shapes of blocks in pieces - not to be confused with the piece sample views.
        ActiveBlockView.Initialize()
        ActiveBlockView.SetBlockSizes(X: 18.0, Y: 18.0, Z: 18.0)
        ActiveBlockView.StartRotations()
        ActiveBlockView.ViewBackgroundColor = ColorServer.ColorFrom(ColorNames.AzukiIro)
        RetiredBlockView.Initialize()
        RetiredBlockView.SetBlockSizes(X: 18.0, Y: 18.0, Z: 18.0)
        RetiredBlockView.StartRotations()
        RetiredBlockView.ViewBackgroundColor = ColorServer.ColorFrom(ColorNames.AzukiIro)
        
        HandleActiveSurfaceTypeChanged(self)
        HandleRetiredSurfaceTypeChanged(self)
        
        let PieceShape = PieceFactory.GetShapeForPiece(ID: PieceID)!
        let ActualPiece = PieceFactory.CreateEphermeralPiece(PieceShape)
        ActiveSamplePiece.Initialize()
        ActiveSamplePiece.BlockSize = 2.0
        ActiveSamplePiece.SpecularColor = UIColor.yellow
        ActiveSamplePiece.DiffuseColor = UIColor.orange
        ActiveSamplePiece.AutoAdjustBlockSize = true
        ActiveSamplePiece.Start()
        ActiveSamplePiece.AddPiece(ActualPiece)
        RetiredSamplePiece.Initialize()
        RetiredSamplePiece.BlockSize = 2.0
        RetiredSamplePiece.SpecularColor = UIColor.red
        RetiredSamplePiece.DiffuseColor = UIColor.brown
        RetiredSamplePiece.AutoAdjustBlockSize = true
        RetiredSamplePiece.Start()
        RetiredSamplePiece.AddPiece(ActualPiece)
        
        TitleBarTitle.text = "Visual Piece Editor: \(PieceShape)"
    }
    
    /// Called by the parent to set the theme.
    /// - Warning: The `EditTheme(ThemeDescriptor2:UUID)` variant *must* be called or a fatal error will be generated.
    public func EditTheme(Theme: ThemeDescriptor2)
    {
        fatalError("Caller needs to call EditTheme(ThemeDescriptor, UUID, ThemeDescriptor) instead.")
    }
    
    /// Called by the parent to set the theme and piece to edit.
    /// - Parameter Theme: The theme to edit.
    /// - Parameter PieceID: The ID to edit.
    public func EditTheme(Theme: ThemeDescriptor2, PieceID: UUID)
    {
        UserTheme = Theme
        self.PieceID = PieceID
    }
    
    /// Holds the ID of the theme.
    private var ThemeID: UUID = UUID.Empty
    
    /// Holds the ID of the piece.
    private var PieceID: UUID = UUID.Empty
    
    /// Not used in this class.
    public func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        
    }
    
    /// Holds the user theme.
    private var UserTheme: ThemeDescriptor2? = nil
    
    /// Not used in this class.
    func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
        //Not used in this class.
    }
    
    /// Handle Color changes. Update both the piece sample and the block sample.
    /// - Parameter Edited: If not nil, the edited color. If nil, take no action.
    /// - Parameter Tag: Returned tag value.
    public func EditedColor(_ Edited: UIColor?, Tag: Any?)
    {
        if let EditedColor = Edited
        {
            if let TagValue = Tag as? String
            {
                switch TagValue
                {
                    case "ActiveDiffuseColor":
                        ActiveDiffuseColorButton.ButtonColor = EditedColor
                        ActiveBlockView.DiffuseColor = EditedColor
                        ActiveSamplePiece.DiffuseColor = EditedColor
                    
                    case "ActiveSpecularColor":
                        ActiveSpecularColorButton.ButtonColor = EditedColor
                        ActiveBlockView.SpecularColor = EditedColor
                        ActiveSamplePiece.SpecularColor = EditedColor
                    
                    case "RetiredDiffuseColor":
                        RetiredDiffuseColorButton.ButtonColor = EditedColor
                        RetiredBlockView.DiffuseColor = EditedColor
                        RetiredSamplePiece.DiffuseColor = EditedColor
                    
                    case "RetiredSpecularColor":
                        RetiredSpecularColorButton.ButtonColor = EditedColor
                        RetiredBlockView.SpecularColor = EditedColor
                        RetiredSamplePiece.SpecularColor = EditedColor
                    
                    default:
                        break
                }
            }
        }
    }
    
    // MARK: Visual editing buttons.
    
    /// Handle the active shape tap. Show a list of available block shapes. Handle shape changes.
    /// - Parameter Recognizer: The gesture recognizer.
    @objc public func HandleActiveShapeTap(Recognizer: UIGestureRecognizer)
    {
        if Recognizer.state != .ended
        {
            return
        }
        let Alert = UIAlertController(title: "Select Dropping Block Shape",
                                      message: "Select the shape for all blocks in the dropping piece.",
                                      preferredStyle: .alert)
        for (Title, _) in ShapeMap
        {
            Alert.addAction(UIAlertAction(title: Title, style: UIAlertAction.Style.default, handler: HandleActiveBlockShapeSelection))
        }
        Alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        if let PopOver = Alert.popoverPresentationController
        {
            //https://medium.com/@nickmeehan/actionsheet-popover-on-ipad-in-swift-5768dfa82094
            PopOver.sourceView = self.view
            PopOver.permittedArrowDirections = []
            PopOver.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        }
        self.present(Alert, animated: true, completion: nil)
    }
    
    /// Handle the selection of a new active shape.
    /// - Parameter Action: Determines which shape was selected.
    @objc public func HandleActiveBlockShapeSelection(Action: UIAlertAction)
    {
        for (Name, Shape) in ShapeMap
        {
            if Name == Action.title!
            {
                ActiveBlockView.Shape = Shape
                ActiveBlockView.StartRotations()
                ActiveSamplePiece.Shape = Shape
            }
        }
    }
    
    /// Map between tile shape ID type and its title. This was converted from a dictionary to an array because Swift dictionaries
    /// are non-deterministic for order and order is important in this case.
    private let ShapeMap: [(String, TileShapes3D)] =
        [
            ("Cube", .Cubic),
            ("Rounded Cube", .RoundedCube),
            ("Sphere", .Spherical),
            ("Cone", .Cone),
            ("Pyramid", .Pyramid),
            ("Cylinder", .Cylinder),
            ("Tube", .Tube),
            ("Capsule", .Capsule),
            ("Torus", .Torus),
            ("Tetrahedron", .Tetrahedron),
            ("Hexagon", .Hexagon)
    ]
    
    /// Not currently implemented.
    @IBAction func HandleActiveTextureButtonPressed(_ sender: Any)
    {
    }
    
    /// Handle the retired shape tap. Show a list of available block shapes. Handle shape changes.
    /// - Parameter Recognizer: The gesture recognizer.
    @objc public func HandleRetiredShapeTap(Recognizer: UIGestureRecognizer)
    {
        if Recognizer.state != .ended
        {
            return
        }
        let Alert = UIAlertController(title: "Select Retired Block Shape",
                                      message: "Select the shape for all blocks in the frozen piece.",
                                      preferredStyle: .alert)
        for (Title, _) in ShapeMap
        {
            Alert.addAction(UIAlertAction(title: Title, style: UIAlertAction.Style.default, handler: HandleRetiredBlockShapeSelection))
        }
        Alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
        if let PopOver = Alert.popoverPresentationController
        {
            //https://medium.com/@nickmeehan/actionsheet-popover-on-ipad-in-swift-5768dfa82094
            PopOver.sourceView = self.view
            PopOver.permittedArrowDirections = []
            PopOver.sourceRect = CGRect(x: self.view.bounds.midX, y: self.view.bounds.midY, width: 0, height: 0)
        }
        self.present(Alert, animated: true, completion: nil)
    }
    
    /// Handle the selection of a new retired shape.
    /// - Parameter Action: Determines which shape was selected.
    @objc public func HandleRetiredBlockShapeSelection(Action: UIAlertAction)
    {
        for (Name, Shape) in ShapeMap
        {
            if Name == Action.title!
            {
                RetiredBlockView.Shape = Shape
                RetiredBlockView.StartRotations()
                RetiredSamplePiece.Shape = Shape
            }
        }
    }
    
    /// Not currently implemented.
    @IBAction public func HandleRetiredTextureButtonPressed(_ sender: Any)
    {
    }
    
    /// Handle surface type change for active blocks.
    /// - Parameter sender: Not used.
    @IBAction public func HandleActiveSurfaceTypeChanged(_ sender: Any)
    {
        let Index = ActiveSurfaceTypeSegment.selectedSegmentIndex
        let IsColor = Index == 0
        ActiveDiffuseColorButton.isEnabled = IsColor
        ActiveSpecularColorButton.isEnabled = IsColor
        ActiveDiffuseColorText.isEnabled = IsColor
        ActiveSpecularColorText.isEnabled = IsColor
        ActiveTextureButton.isEnabled = !IsColor
        ActiveTextureText.isEnabled = !IsColor
    }
    
    /// Handle surface type change for retired blocks.
    /// - Parameter sender: Not used.
    @IBAction public func HandleRetiredSurfaceTypeChanged(_ sender: Any)
    {
        let Index = RetiredSurfaceTypeSegment.selectedSegmentIndex
        let IsColor = Index == 0
        RetiredDiffuseColorButton.isEnabled = IsColor
        RetiredSpecularColorButton.isEnabled = IsColor
        RetiredDiffuseColorText.isEnabled = IsColor
        RetiredSpecularColorText.isEnabled = IsColor
        RetiredTextureButton.isEnabled = !IsColor
        RetiredTextureText.isEnabled = !IsColor
    }
    
    // MARK: Flow control UI and button handling.
    
    /// Handle the rotate sample style changed.
    /// - Parameter sender: Not used.
    @IBAction public func HandleRotatePieceSegmentChanged(_ sender: Any)
    {
        let RotationIndex = RotationSegment.selectedSegmentIndex
        switch RotationIndex
        {
            case 0:
                ActiveSamplePiece.ResetRotations()
                RetiredSamplePiece.ResetRotations()
            
            case 1:
                ActiveSamplePiece.RotatePiece(OnX: false, OnY: false, OnZ: true)
                RetiredSamplePiece.RotatePiece(OnX: false, OnY: false, OnZ: true)
            
            case 2:
                ActiveSamplePiece.RotatePiece(OnX: true, OnY: false, OnZ: true)
                RetiredSamplePiece.RotatePiece(OnX: true, OnY: false, OnZ: true)
            
            case 3:
                ActiveSamplePiece.RotatePiece(OnX: true, OnY: true, OnZ: true)
                RetiredSamplePiece.RotatePiece(OnX: true, OnY: true, OnZ: true)
            
            default:
                break
        }
    }
    
    /// Handle the OK button. Notify the user and close the dialog.
    /// - Parameter sender: Not used.
    @IBAction public func HandleOKPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: ThemeID, PieceID: PieceID)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the cancel button. Notify the user and close the dialog.
    /// - Parameter sender: Not used.
    @IBAction public func HandleCancelPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(false, ThemeID: ThemeID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the scale slider changed. Update the views.
    /// - Parameter sender: Not used.
    @IBAction public func HandleScaleSliderChanged(_ sender: Any)
    {
        let NewScale = ScaleSlider.value
        let DisplayValue: Int = Int(NewScale)
        if let Previous = PreviousScaleValue
        {
            if Previous == DisplayValue
            {
                return
            }
        }
        PreviousScaleValue = DisplayValue
                ScaleValueLabel.text = "\(DisplayValue)°"
        ActiveSamplePiece.SetFOV(CGFloat(DisplayValue))
        RetiredSamplePiece.SetFOV(CGFloat(DisplayValue))
    }
    
    /// Holds the previous scale value.
    private var PreviousScaleValue: Int? = nil
    
    // MARK: Instantiations.
    
    /// Instantiate the color picker for the active diffuse color.
    /// - Parameter coder: `NSColor` instance used to create a `ColorPickerCode` instance.
    /// - Returns: `ColorPickerCode` instance.
    @IBSegueAction func InstantiateColorPickerForActiveDiffuseColor(_ coder: NSCoder) -> ColorPickerCode?
    {
        let Picker = ColorPickerCode(coder: coder)
        Picker?.ColorDelegate = self
        Picker?.ColorToEdit(UIColor.orange, Tag: "ActiveDiffuseColor")
        return Picker
    }
    
    /// Instantiate the color picker for the active specular color.
    /// - Parameter coder: `NSColor` instance used to create a `ColorPickerCode` instance.
    /// - Returns: `ColorPickerCode` instance.
    @IBSegueAction func InstantiateColorPickerForActiveSpecularColor(_ coder: NSCoder) -> ColorPickerCode?
    {
        let Picker = ColorPickerCode(coder: coder)
        Picker?.ColorDelegate = self
        Picker?.ColorToEdit(UIColor.yellow, Tag: "ActiveSpecularColor")
        return Picker
    }
    
    /// Instantiate the color picker for the retired diffuse color.
    /// - Parameter coder: `NSColor` instance used to create a `ColorPickerCode` instance.
    /// - Returns: `ColorPickerCode` instance.
    @IBSegueAction func InstantiateColorPickerForRetiredDiffuseColor(_ coder: NSCoder) -> ColorPickerCode?
    {
        let Picker = ColorPickerCode(coder: coder)
        Picker?.ColorDelegate = self
        Picker?.ColorToEdit(UIColor.brown, Tag: "RetiredDiffuseColor")
        return Picker
    }
    
    /// Instantiate the color picker for the retired specular color.
    /// - Parameter coder: `NSColor` instance used to create a `ColorPickerCode` instance.
    /// - Returns: `ColorPickerCode` instance.
    @IBSegueAction func InstantiateColorPickerForRetiredSpecularColor(_ coder: NSCoder) -> ColorPickerCode?
    {
        let Picker = ColorPickerCode(coder: coder)
        Picker?.ColorDelegate = self
        Picker?.ColorToEdit(UIColor.red, Tag: "RetiredSpecularColor")
        return Picker
    }
    
    // MARK: Interface builder links.
    
    @IBOutlet weak var TitleBarTitle: UILabel!
    @IBOutlet weak var RotationSegment: UISegmentedControl!
    @IBOutlet weak var ScaleSlider: UISlider!
    @IBOutlet weak var ScaleValueLabel: UILabel!
    
    @IBOutlet weak var ActiveSamplePiece: PieceViewer!
    @IBOutlet weak var ActiveSurfaceTypeSegment: UISegmentedControl!
    @IBOutlet weak var ActiveTextureButton: UIButton!
    @IBOutlet weak var ActiveSpecularColorButton: ColorButton!
    @IBOutlet weak var ActiveDiffuseColorButton: ColorButton!
    @IBOutlet weak var ActiveDiffuseColorText: UILabel!
    @IBOutlet weak var ActiveSpecularColorText: UILabel!
    @IBOutlet weak var ActiveTextureText: UILabel!
    @IBOutlet weak var ActiveBlockView: BlockView!
    
    @IBOutlet weak var RetiredSamplePiece: PieceViewer!
    @IBOutlet weak var RetiredSurfaceTypeSegment: UISegmentedControl!
    @IBOutlet weak var RetiredTextureButton: UIButton!
    @IBOutlet weak var RetiredSpecularColorButton: ColorButton!
    @IBOutlet weak var RetiredDiffuseColorButton: ColorButton!
    @IBOutlet weak var RetiredDiffuseColorText: UILabel!
    @IBOutlet weak var RetiredSpecularColorText: UILabel!
    @IBOutlet weak var RetiredTextureText: UILabel!
    @IBOutlet weak var RetiredBlockView: BlockView!
}
