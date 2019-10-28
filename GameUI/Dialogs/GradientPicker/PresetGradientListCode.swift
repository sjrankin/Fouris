//
//  PresetGradientListCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Manages the preset gradient list UI.
class PresetGradientListCode: UIViewController, UITableViewDelegate, UITableViewDataSource,
    GradientPickerProtocol
{
    /// Delegate that receives messages from this class.
    public weak var GradientDelegate: GradientPickerProtocol? = nil
    
    /// Initialize the UI.
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        GradientTable.layer.borderColor = UIColor.black.cgColor
        LoadPresetGradients()
        GradientTable.reloadData()
    }
    
    /// Load preset gradients from the `GradientManager` into a local table.
    public func LoadPresetGradients()
    {
        PresetList.removeAll()
        for (_, Name, Definition) in GradientManager.GradientList
        {
            PresetList.append((Name, Definition))
        }
    }
    
    /// Holds the preset gradients to display.
    private var PresetList = [(String, String)]()
    
    /// Returns the number of items in the preset gradient list.
    /// - Parameter tableView: Not used.
    /// - Parameter numberOfRowsInSection: Not used.
    /// - Returns: Number of items in the preset gradient list.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return PresetList.count
    }
    
    /// Returns the height of each cell.
    /// - Parameter tableView: Not used.
    /// - Parameter heightForRowAt: Not used.
    /// - Returns: Height of each row.
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return PresetGradientCell.CellHeight
    }
    
    /// Returns a table view cell with one preset gradient.
    /// - Parameter tableView: Not used.
    /// - Parameter cellForRowAt: The index of the row whose data will be returned in a table view cell.
    /// - Returns: Table view cell with a preset gradient.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = PresetGradientCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "PresetGradient")
        Cell.LoadData(PresetList[indexPath.row], Vertical: VerticalGradientSwitch.isOn)
        return Cell
    }
    
    /// Handles selection events from the user.
    /// - Parameter tableView: Not used.
    /// - Parameter didSelectRowAt: The index of the selected row.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        SelectedGradient = PresetList[indexPath.row].1
        print("Selected gradient \(PresetList[indexPath.row].0)")
    }
    
    /// Holds the definition of the selected gradient. If nothing selected, this is an empty string.
    private var SelectedGradient: String = ""
    
    /// Not used in this class.
    public func EditedGradient(_ Edited: String?, Tag: Any?)
    {
        //Not used.
    }
    
    /// Called by the parent UI. We only care about `Tag` as no editing capabilities are in this UI.
    /// - Parameter Edited: Not used.
    /// - Parameter Tag: Arbitrary data sent by the caller. Returned when the dialog is closed.
    func GradientToEdit(_ Edited: String?, Tag: Any?)
    {
        GradientTag = Tag
    }
    
    /// Holds the tag value sent by the user.
    private var GradientTag: Any? = nil
    
    /// Not used in this class.
    public func SetStop(StopColorIndex: Int)
    {
        //Not used here.
    }
    
    /// Handle the OK button pressed. Send a message to the caller a new gradient is available. Close this dialog.
    /// - Parameter sender: Not used.
    @IBAction public func HandleOKPressed(_ sender: Any)
    {
        GradientDelegate?.EditedGradient(SelectedGradient, Tag: GradientTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the Cancel button pressed. Send a message to the caller that no gradient was chosen. Close this dialog.
    /// - Parameter sender: Not used.
    @IBAction public func HandleCancelPressed(_ sender: Any)
    {
        GradientDelegate?.EditedGradient(nil, Tag: GradientTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle changes to the gradient orientation. Redraws the sample gradient.
    /// - Parameter sender: Not used.
    @IBAction public func HandleGradientOrientationChanged(_ sender: Any)
    {
        GradientTable.reloadData()
    }
    
    /// Handle the sort gradient list button.
    /// - Parameter sender: Not used.
    @IBAction public func HandleSortGradientList(_ sender: Any)
    {
        if SortDirection
        {
            PresetList.sort(by: {$0.0 < $1.0})
        }
        else
        {
            PresetList.sort(by: {$0.0 > $1.0})
        }
        SortDirection = !SortDirection
        GradientTable.reloadData()
    }
    
    /// Direction to sort the preset gradient list.
    private var SortDirection = true
    
    @IBOutlet weak var VerticalGradientSwitch: UISwitch!
    @IBOutlet weak var GradientTable: UITableView!
}
