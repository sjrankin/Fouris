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
        ActiveDiffuseColorButton.layer.cornerRadius = 5.0
        ActiveDiffuseColorButton.layer.borderColor = UIColor.black.cgColor
        ActiveDiffuseColorButton.layer.borderWidth = 0.5
        ActiveDiffuseColorButton.clipsToBounds = true
        ActiveSpecularColorButton.layer.cornerRadius = 5.0
        ActiveSpecularColorButton.layer.borderColor = UIColor.black.cgColor
        ActiveSpecularColorButton.layer.borderWidth = 0.5
        ActiveSpecularColorButton.clipsToBounds = true
        RetiredDiffuseColorButton.layer.cornerRadius = 5.0
        RetiredDiffuseColorButton.layer.borderColor = UIColor.black.cgColor
        RetiredDiffuseColorButton.layer.borderWidth = 0.5
        RetiredDiffuseColorButton.clipsToBounds = true
        RetiredSpecularColorButton.layer.cornerRadius = 5.0
        RetiredSpecularColorButton.layer.borderColor = UIColor.black.cgColor
        RetiredSpecularColorButton.layer.borderWidth = 0.5
        RetiredSpecularColorButton.clipsToBounds = true
        
        HandleActiveSurfaceTypeChanged(self)
        HandleRetiredSurfaceTypeChanged(self)
    }
    
    func EditTheme(ID: UUID)
    {
        fatalError("Caller needs to call EditTheme(UUID, UUID) instead.")
    }
    
    func EditTheme(ID: UUID, Piece: UUID)
    {
        ThemeID = ID
        PieceID = Piece
    }
    
    var ThemeID: UUID = UUID.Empty
    
    var PieceID: UUID = UUID.Empty
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        
    }
    
    func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
        //Not used in this class.
    }
    
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
                    
                    case "ActiveSpecularColor":
                        ActiveSpecularColorButton.ButtonColor = EditedColor
                    
                    case "RetiredDiffuseColor":
                        RetiredDiffuseColorButton.ButtonColor = EditedColor
                    
                    case "RetiredSpecularColor":
                        RetiredSpecularColorButton.ButtonColor = EditedColor
                    
                    default:
                    break
                }
            }
        }
    }
    
    // MARK: Visual editing buttons.
    
    @IBAction func HandleActiveShapeButtonPressed(_ sender: Any)
    {
        let Alert = UIAlertController(title: "Select Dropping Block Shape",
                                      message: "Select the shape for all blocks in the dropping piece.",
                                      preferredStyle: .alert)
        Alert.addAction(UIAlertAction(title: "Cube", style: UIAlertAction.Style.default, handler: HandleActiveBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Rounded Cube", style: UIAlertAction.Style.default, handler: HandleActiveBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Sphere", style: UIAlertAction.Style.default, handler: HandleActiveBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Cone", style: UIAlertAction.Style.default, handler: HandleActiveBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Pyramid", style: UIAlertAction.Style.default, handler: HandleActiveBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Cylinder", style: UIAlertAction.Style.default, handler: HandleActiveBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Tube", style: UIAlertAction.Style.default, handler: HandleActiveBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Capsule", style: UIAlertAction.Style.default, handler: HandleActiveBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Torus", style: UIAlertAction.Style.default, handler: HandleActiveBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Tetrahedron", style: UIAlertAction.Style.default, handler: HandleActiveBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Dodecahedron", style: UIAlertAction.Style.default, handler: HandleActiveBlockShapeSelection))
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
        
    }
    
    @IBAction func HandleActiveTextureButtonPressed(_ sender: Any)
    {
    }
    
    @IBAction func HandleRetiredShapeButtonPressed(_ sender: Any)
    {
        let Alert = UIAlertController(title: "Select Retired Block Shape",
                                      message: "Select the shape for all blocks in the frozen piece.",
                                      preferredStyle: .alert)
        Alert.addAction(UIAlertAction(title: "Cube", style: UIAlertAction.Style.default, handler: HandleRetiredBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Rounded Cube", style: UIAlertAction.Style.default, handler: HandleRetiredBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Sphere", style: UIAlertAction.Style.default, handler: HandleRetiredBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Cone", style: UIAlertAction.Style.default, handler: HandleRetiredBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Pyramid", style: UIAlertAction.Style.default, handler: HandleRetiredBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Cylinder", style: UIAlertAction.Style.default, handler: HandleRetiredBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Tube", style: UIAlertAction.Style.default, handler: HandleRetiredBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Capsule", style: UIAlertAction.Style.default, handler: HandleRetiredBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Torus", style: UIAlertAction.Style.default, handler: HandleRetiredBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Tetrahedron", style: UIAlertAction.Style.default, handler: HandleRetiredBlockShapeSelection))
        Alert.addAction(UIAlertAction(title: "Dodecahedron", style: UIAlertAction.Style.default, handler: HandleRetiredBlockShapeSelection))
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
    
    // MARK: Flow control button handling.
    
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
    
    @IBOutlet weak var ActiveSurfaceTypeSegment: UISegmentedControl!
    @IBOutlet weak var ActiveTextureButton: UIButton!
    @IBOutlet weak var ActiveSpecularColorButton: ColorButton!
    @IBOutlet weak var ActiveDiffuseColorButton: ColorButton!
    @IBOutlet weak var ActiveShapeButton: UIButton!
    @IBOutlet weak var ActiveDiffuseColorText: UILabel!
    @IBOutlet weak var ActiveSpecularColorText: UILabel!
    @IBOutlet weak var ActiveTextureText: UILabel!
    
    @IBOutlet weak var RetiredSurfaceTypeSegment: UISegmentedControl!
    @IBOutlet weak var RetiredTextureButton: UIButton!
    @IBOutlet weak var RetiredSpecularColorButton: ColorButton!
    @IBOutlet weak var RetiredDiffuseColorButton: ColorButton!
    @IBOutlet weak var RetiredShapeButton: UIButton!
    @IBOutlet weak var RetiredDiffuseColorText: UILabel!
    @IBOutlet weak var RetiredSpecularColorText: UILabel!
    @IBOutlet weak var RetiredTextureText: UILabel!
}
