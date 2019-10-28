//
//  GradientEditorCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Code to run the gradient editor.
class GradientEditorCode: UIViewController, GradientPickerProtocol,
    UITableViewDelegate, UITableViewDataSource 
{
    /// Local reference to user settings.
    private let _Settings = UserDefaults.standard
    /// Holds the original gradient.
    private var OriginalGradient: String = ""
    /// Holds the current gradient.
    private var CurrentGradient: String = ""
    /// Holds the caller's tag value.
    private var CallerTag: Any? = nil
    /// Holds the gradient orientation flag.
    private var IsVertical = true
    /// Holds the gradient color stop list.
    private var GradientStopList = [(UIColor, CGFloat)]()
    /// Delegate the receives messages from this class.
    public weak var GradientDelegate: GradientPickerProtocol? = nil
    
    /// Initialize the UI.
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        
        var Vertical: Bool = false
        var Reverse: Bool = false
        ControlView.layer.borderColor = UIColor.black.cgColor
        ControlView.layer.backgroundColor = UIColor.clear.cgColor
        OriginalGradient = CurrentGradient
        GradientStopList = GradientManager.ParseGradient(CurrentGradient, Vertical: &Vertical, Reverse: &Reverse)
        GradientView.backgroundColor = UIColor.black
        GradientView.layer.borderColor = UIColor.black.cgColor
        GradientView.layer.borderWidth = 0.5
        GradientView.layer.cornerRadius = 5.0
        GradientStopTable.delegate = self
        GradientStopTable.dataSource = self
        GradientStopTable.layer.borderColor = UIColor.black.cgColor
        GradientStopTable.layer.borderWidth = 0.5
        GradientStopTable.layer.cornerRadius = 5.0
        GradientStopTable.reloadData()
        let TapGesture = UITapGestureRecognizer(target: self, action: #selector(HandleSampleTap))
        GradientView.addGestureRecognizer(TapGesture)
        ShowSample(WithGradient: CurrentGradient)
    }
    
    /// Handle taps in the sample gradient. When the user taps in the sample, the orientation of the gradient changes.
    /// - Parameter TapGesture: Gesture information.
    @objc public func HandleSampleTap(TapGesture: UITapGestureRecognizer)
    {
        if TapGesture.state == .ended
        {
            IsVertical = !IsVertical
            ShowSample(WithGradient: CurrentGradient)
        }
    }
    
    /// Draw the sample gradient.
    /// - Parameter WithGradient: The gradient to draw.
    private func ShowSample(WithGradient: String)
    {
        if WithGradient.isEmpty
        {
            GradientView.image = nil
            GradientView.backgroundColor = UIColor.black
            GradientStopList.removeAll()
        }
        else
        {
            let SampleGradient = GradientManager.CreateGradientImage(From: WithGradient, WithFrame: GradientView.bounds,
                                                                     IsVertical: IsVertical, ReverseColors: false)
            GradientView.image = SampleGradient
            var Vertical: Bool = false
            var Reverse: Bool = false
            GradientStopList = GradientManager.ParseGradient(WithGradient, Vertical: &Vertical, Reverse: &Reverse)
        }
        GradientStopTable.reloadData()
    }
    
    /// Not used in this class.
    public func SetStop(StopColorIndex StopIndex: Int)
    {
        //Not used in this class.
    }
    
    /// Returned value from the color stop editor.
    /// - Parameter Edited: If true, a new color stop value. If false, the user canceled the color stop editor.
    /// - Parameter Tag: Tag value we sent to the editor.
    public func EditedGradient(_ Edited: String?, Tag: Any?)
    {
        //From the color stop editor.
        if let NewGradient = Edited
        {
            if let CallerTag = Tag as? String
            {
                switch CallerTag
                {
                    case "FromColorStopEditor":
                        CurrentGradient = NewGradient
                        ShowSample(WithGradient: CurrentGradient)
                    
                    case "FromPresetList":
                        CurrentGradient = NewGradient
                        ShowSample(WithGradient: CurrentGradient)
                    
                    default:
                        break
                }
            }
        }
    }
    
    /// Sets the gradient to edit. Called by the UI parent of this class (eg, the class that wants to edit a gradient).
    /// - Parameter EditMe: The gradient to edit. If nil, an empty gradient will be used.
    /// - Parameter Tag: The caller's tag value.
    public func GradientToEdit(_ EditMe: String?, Tag: Any?)
    {
        if let HasGradient = EditMe
        {
            CurrentGradient = HasGradient
        }
        else
        {
            CurrentGradient = ""
        }
        CallerTag = Tag
    }
    
    /// Handle the reverse gradient colors button. Colors are reversed but not color stop locations.
    /// - Parameter sender: Not used.
    @IBAction public func HandleReverseGradientButton(_ sender: Any)
    {
        CurrentGradient = GradientManager.ReverseColorLocations(CurrentGradient)
        ShowSample(WithGradient: CurrentGradient)
    }
    
    /// Handle the clear gradient button. The gradient is reset to empty.
    /// - Parameter sender: Not used.
    @IBAction public func HandleClearButton(_ sender: Any)
    {
        CurrentGradient = ""
        ShowSample(WithGradient: CurrentGradient)
    }
    
    /// Handle the reset gradient button. The gradient is reset to the original gradient sent to the editor.
    /// - Parameter sender: Not used.
    @IBAction public func HandleResetButton(_ sender: Any)
    {
        CurrentGradient = OriginalGradient
        ShowSample(WithGradient: CurrentGradient)
    }
    
    /// Handle the edit button. Used to manage iOS's built-in table view editing.
    /// - Parameter sender: Not used.
    @IBAction public func HandleEditButton(_ sender: Any)
    {
        GradientStopTable.setEditing(!GradientStopTable.isEditing, animated: true)
        if GradientStopTable.isEditing
        {
            EditButton.setTitle("Done", for: UIControl.State.normal)
        }
        else
        {
            EditButton.setTitle("Edit", for: UIControl.State.normal)
        }
        AddGradientStopButton.isEnabled = !GradientStopTable.isEditing
        ResetButton.isEnabled = !GradientStopTable.isEditing
        ReverseColorButton.isEnabled = !GradientStopTable.isEditing
        ClearButton.isEnabled = !GradientStopTable.isEditing
    }
    
    /// Run the preset gradient list dialog.
    /// - Parameter coder: `NSCoder` instance used to create the code to run the preset gradient UI.
    /// - Returns: `PresetGradientListCode` instance.
    @IBSegueAction public func InstantiatePresetsDialog(_ coder: NSCoder) -> PresetGradientListCode?
    {
        let Presets = PresetGradientListCode(coder: coder)
        Presets?.GradientDelegate = self
        Presets?.GradientToEdit("", Tag: "FromPresetList")
        return Presets
    }
    
    /// Handle the add button. Adds a new color stop.
    /// - Parameter sender: Not used.
    @IBAction public func HandleAddButton(_ sender: Any)
    {
        CurrentGradient = GradientManager.AddGradientStop(CurrentGradient, Color: UIColor.red, Location: 1.0)
        ShowSample(WithGradient: CurrentGradient)
        GradientStopTable.reloadData()
    }
    
    /// Returns the current number of gradient color stops in the current gradient.
    /// - Parameter tableView: Not used.
    /// - Parameter numberOfRowsInSection: Not used.
    /// - Returns: The number of color stops.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return GradientStopList.count
    }
    
    /// Returns a table view cell populated with a gradient stop.
    /// - Parameter tableView: Not used.
    /// - Parameter cellForRowAt: The index of the gradient stop to return.
    /// - Returns: Populated table view cell.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let (Color, Location) = GradientStopList[indexPath.row]
        let Cell = GradientStopCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "GradientCell")
        Cell.SetData(StopColor: Color, StopLocation: Double(Location))
        return Cell
    }
    
    /// Return the height of each table view cell.
    /// - Parameter tableView: Not used.
    /// - Parameter heightForRowAt: Not used.
    /// - Returns: The height of each row in the color stop table.
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return GradientStopCell.CellHeight
    }
    
    /// Returns **true** to let the OS know the table view cell can be moved. Appled to all table view cells.
    /// - Parameter tableView: Not used.
    /// - Parameter canMoveRowAt: Not used.
    /// - Returns: Flag to tell OS whether the cell can be moved.
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    /// Handle the move row notification from the table view. In our case, we merely swap the two gradients.
    /// - Parameter tableView: Not used.
    /// - Parameter moveRowAt: Source row. The row that is being moved.
    /// - Parameter to: Destination row. Where the row will be placed.
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        if let NewGradient = GradientManager.SwapGradientStops(CurrentGradient, Index1: sourceIndexPath.row,
                                                               Index2: destinationIndexPath.row)
        {
            CurrentGradient = NewGradient
            ShowSample(WithGradient: CurrentGradient)
        }
    }
    
    /// Handle editing commits. This function is used only for deletions of color gradient stops.
    /// - Parameter tableView: Not used.
    /// - Parameter commit: The action to take on the data.
    /// - Parameter forRowAt: The row to take the action on.
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            CurrentGradient = GradientManager.RemoveGradientStop(CurrentGradient, AtIndex: indexPath.row)!
            GradientStopTable.reloadData()
        }
    }
    
    /// Handle row selections for gradient color stops. When selected, run the gradient stop editor dialog.
    /// - Parameter tableView: Not used.
    /// - Parameter didSelectRowAt: The row index that was selected.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let Cell = GradientStopTable.cellForRow(at: indexPath) as? GradientStopCell
        {
            let (Color, Location) = Cell.CellData()
            SelectedIndex = indexPath.row
            ColorToEdit = Color
            LocationToEdit = Location
            
            performSegue(withIdentifier: "ToGradientStopEditor", sender: self)
        }
    }
    
    /// Handle instantiation of the gradient stop editor.
    /// - Parameter coder: `NSCoder` instance used to create a `GradientStopEditorCode` instance.
    /// - Returns: `GradientStopEditorCode` instance.
    @IBSegueAction public func HandleInstantiateGradientStopEditor(_ coder: NSCoder) -> GradientStopEditorCode?
    {
        let GSEditor = GradientStopEditorCode(coder: coder)
        GSEditor?.GradientDelegate = self
        GSEditor?.SetStop(StopColorIndex: SelectedIndex)
        GSEditor?.GradientToEdit(CurrentGradient, Tag: "FromColorStopEditor")
        return GSEditor
    }
    
    /// Handle instantiation of the gradient export code.
    /// - Parameter coder: `NSCoder` instance used to create a `GradientExport2` instance.
    /// - Returns: `GradientExport2` instance.
    @IBSegueAction public func HandleExportGradient2Instantiation(_ coder: NSCoder) -> GradientExport2?
    {
        let Export = GradientExport2(coder: coder)
        Export?.GradientDelegate = self
        Export?.GradientToEdit(CurrentGradient, Tag: "")
        return Export
    }
    
    /// Color to edit.
    private var ColorToEdit: UIColor = UIColor.black
    /// Location to edit.
    private var LocationToEdit: Double = 0.0
    /// Current selected color stop index.
    private var SelectedIndex: Int = -1
    
    /// Handle the OK button pressed. Send the new gradient to the caller and close this window.
    /// - Parameter sender: Not used.
    @IBAction public func HandleOKPressed(_ sender: Any)
    {
        GradientDelegate?.EditedGradient(CurrentGradient, Tag: CallerTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the cancel button pressed. Notify the caller of the cancellation and close this window.
    /// - Parameter sender: Not used.
    @IBAction public func HandleCancelPressed(_ sender: Any)
    {
        GradientDelegate?.EditedGradient(nil, Tag: CallerTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var ControlView: UIView!
    @IBOutlet weak var PresetsButton: UIButton!
    @IBOutlet weak var ClearButton: UIButton!
    @IBOutlet weak var ResetButton: UIButton!
    @IBOutlet weak var ReverseColorButton: UIButton!
    @IBOutlet weak var AddGradientStopButton: UIButton!
    @IBOutlet weak var EditButton: UIButton!
    @IBOutlet weak var GradientStopTable: UITableView!
    @IBOutlet weak var GradientView: UIImageView!
}
