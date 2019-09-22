//
//  PieceEditorCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PieceEditorCode: UIViewController, ThemeEditingProtocol, ColorPickerProtocol
{
    weak var ThemeDelegate: ThemeEditingProtocol? = nil
    weak var ColorDelegate: ColorPickerProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        StyleVisuals()
    }
    
    func StyleVisuals()
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
        ActiveBlockView.SetBlockSizes(X: 20.0, Y: 20.0, Z: 20.0)
        ActiveBlockView.StartRotations()
        ActiveBlockView.ViewBackgroundColor = ColorServer.ColorFrom(ColorNames.AzukiIro)
        RetiredBlockView.Initialize()
        RetiredBlockView.SetBlockSizes(X: 20.0, Y: 20.0, Z: 20.0)
        RetiredBlockView.StartRotations()
        RetiredBlockView.ViewBackgroundColor = ColorServer.ColorFrom(ColorNames.AzukiIro)
        
        HandleActiveSurfaceTypeChanged(self)
        HandleRetiredSurfaceTypeChanged(self)
        
        let PieceShape = PieceFactory.GetShapeForPiece(ID: PieceID)!
        let ActualPiece = PieceFactory.CreateEphermeralPiece(PieceShape)
        ActiveSamplePiece.Initialize()
        ActiveSamplePiece.BlockSize = 3.0
        ActiveSamplePiece.SpecularColor = UIColor.yellow
        ActiveSamplePiece.DiffuseColor = UIColor.orange
        ActiveSamplePiece.Start()
        ActiveSamplePiece.AddPiece(ActualPiece)
        RetiredSamplePiece.Initialize()
        RetiredSamplePiece.SpecularColor = UIColor.red
        RetiredSamplePiece.DiffuseColor = UIColor.brown
        RetiredSamplePiece.Start()
        RetiredSamplePiece.AddPiece(ActualPiece)
        
        TitleBarTitle.text = "Piece Editor: \(PieceShape)"
    }
    
    func EditTheme(Theme: ThemeDescriptor, DefaultTheme: ThemeDescriptor)
    {
        fatalError("Caller needs to call EditTheme(ThemeDescriptor, UUID, ThemeDescriptor) instead.")
    }
    
    func EditTheme(Theme: ThemeDescriptor, PieceID: UUID, DefaultTheme: ThemeDescriptor)
    {
        UserTheme = Theme
        self.DefaultTheme = DefaultTheme
    }
    
    var ThemeID: UUID = UUID.Empty
    
    var PieceID: UUID = UUID.Empty
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        
    }
    
    var UserTheme: ThemeDescriptor? = nil
    var DefaultTheme: ThemeDescriptor? = nil
    
    func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
        //Not used in this class.
    }
    
    /// Handle Color changes. Update both the piece sample and the block sample.
    func EditedColor(_ Edited: UIColor?, Tag: Any?)
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
    
    @objc func HandleActiveShapeTap(Recognizer: UIGestureRecognizer)
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
    
    @objc func HandleActiveBlockShapeSelection(Action: UIAlertAction)
    {
        if let SelectedShape = ShapeMap[Action.title!]
        {
            ActiveBlockView.Shape = SelectedShape
            ActiveBlockView.StartRotations()
        }
    }
    
    /// Map between tile shape ID type and its title.
    let ShapeMap: [String: TileShapes3D] =
        [
            "Cube": .Cubic,
            "Rounded Cube": .RoundedCube,
            "Sphere": .Spherical,
            "Cone": .Cone,
            "Pyramid": .Pyramid,
            "Cylinder": .Cylinder,
            "Tube": .Tube,
            "Capsule": .Capsule,
            "Torus": .Torus,
            "Tetrahedron": .Tetrahedron
    ]
    
    @IBAction func HandleActiveTextureButtonPressed(_ sender: Any)
    {
    }
    
    @objc func HandleRetiredShapeTap(Recognizer: UIGestureRecognizer)
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
    
    @objc func HandleRetiredBlockShapeSelection(Action: UIAlertAction)
    {
        if let SelectedShape = ShapeMap[Action.title!]
        {
            RetiredBlockView.Shape = SelectedShape
            RetiredBlockView.StartRotations()
        }
    }
    
    @IBAction func HandleRetiredTextureButtonPressed(_ sender: Any)
    {
    }
    
    @IBAction func HandleActiveSurfaceTypeChanged(_ sender: Any)
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
    
    @IBAction func HandleRetiredSurfaceTypeChanged(_ sender: Any)
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
    
    @IBAction func HandleRotatePieceSegmentChanged(_ sender: Any)
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
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: ThemeID, PieceID: PieceID)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(false, ThemeID: ThemeID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: Instantiations.
    
    @IBSegueAction func InstantiateColorPickerForActiveDiffuseColor(_ coder: NSCoder) -> ColorPickerCode?
    {
        let Picker = ColorPickerCode(coder: coder)
        Picker?.ColorDelegate = self
        Picker?.ColorToEdit(UIColor.orange, Tag: "ActiveDiffuseColor")
        return Picker
    }
    
    @IBSegueAction func InstantiateColorPickerForActiveSpecularColor(_ coder: NSCoder) -> ColorPickerCode?
    {
        let Picker = ColorPickerCode(coder: coder)
        Picker?.ColorDelegate = self
        Picker?.ColorToEdit(UIColor.yellow, Tag: "ActiveSpecularColor")
        return Picker
    }
    
    @IBSegueAction func InstantiateColorPickerForRetiredDiffuseColor(_ coder: NSCoder) -> ColorPickerCode?
    {
        let Picker = ColorPickerCode(coder: coder)
        Picker?.ColorDelegate = self
        Picker?.ColorToEdit(UIColor.brown, Tag: "RetiredDiffuseColor")
        return Picker
    }
    
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
