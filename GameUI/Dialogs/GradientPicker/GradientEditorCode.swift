//
//  GradientEditorCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GradientEditorCode: UIViewController, GradientPickerProtocol,
    UITableViewDelegate, UITableViewDataSource 
{
    let _Settings = UserDefaults.standard
    var OriginalGradient: String = ""
    var CurrentGradient: String = ""
    var CallerTag: Any? = nil
    var IsVertical = true
    var GradientStopList = [(UIColor, CGFloat)]()
    weak var GradientDelegate: GradientPickerProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        var Vertical: Bool!
        var Reverse: Bool!
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
    
    @objc func HandleSampleTap(TapGesture: UITapGestureRecognizer)
    {
        if TapGesture.state == .ended
        {
            IsVertical = !IsVertical
            ShowSample(WithGradient: CurrentGradient)
        }
    }
    
    func ShowSample(WithGradient: String)
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
            var Vertical: Bool!
            var Reverse: Bool!
            GradientStopList = GradientManager.ParseGradient(WithGradient, Vertical: &Vertical, Reverse: &Reverse)
        }
        GradientStopTable.reloadData()
    }
    
    func SetStop(StopColorIndex StopIndex: Int)
    {
        //Not used in this class.
    }
    
    func EditedGradient(_ Edited: String?, Tag: Any?)
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
    
    func GradientToEdit(_ EditMe: String?, Tag: Any?)
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
    
    @IBAction func HandleReverseGradientButton(_ sender: Any)
    {
        CurrentGradient = GradientManager.ReverseColorLocations(CurrentGradient)
        ShowSample(WithGradient: CurrentGradient)
    }
    
    @IBAction func HandleClearButton(_ sender: Any)
    {
        CurrentGradient = ""
        ShowSample(WithGradient: CurrentGradient)
    }
    
    @IBAction func HandleResetButton(_ sender: Any)
    {
        CurrentGradient = OriginalGradient
        ShowSample(WithGradient: CurrentGradient)
    }
    
    @IBAction func HandleEditButton(_ sender: Any)
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
    
    @IBSegueAction func InstantiatePresetsDialog(_ coder: NSCoder) -> PresetGradientListCode?
    {
        let Presets = PresetGradientListCode(coder: coder)
        Presets?.GradientDelegate = self
        Presets?.GradientToEdit("", Tag: "FromPresetList")
        return Presets
    }
    
    @IBAction func HandleAddButton(_ sender: Any)
    {
        CurrentGradient = GradientManager.AddGradientStop(CurrentGradient, Color: UIColor.red, Location: 1.0)
        ShowSample(WithGradient: CurrentGradient)
        GradientStopTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return GradientStopList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let (Color, Location) = GradientStopList[indexPath.row]
        let Cell = GradientStopCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "GradientCell")
        Cell.SetData(StopColor: Color, StopLocation: Double(Location))
        return Cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return GradientStopCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath)
    {
        if let NewGradient = GradientManager.SwapGradientStops(CurrentGradient, Index1: sourceIndexPath.row,
                                                               Index2: destinationIndexPath.row)
        {
            CurrentGradient = NewGradient
            ShowSample(WithGradient: CurrentGradient)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        if editingStyle == .delete
        {
            CurrentGradient = GradientManager.RemoveGradientStop(CurrentGradient, AtIndex: indexPath.row)!
            GradientStopTable.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
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
    
    @IBSegueAction func HandleInstantiateGradientStopEditor(_ coder: NSCoder) -> GradientStopEditorCode?
    {
        let GSEditor = GradientStopEditorCode(coder: coder)
        GSEditor?.GradientDelegate = self
        GSEditor?.SetStop(StopColorIndex: SelectedIndex)
        GSEditor?.GradientToEdit(CurrentGradient, Tag: "FromColorStopEditor")
        return GSEditor
    }
    
    @IBSegueAction func HandleExportGradientInstantiation(_ coder: NSCoder) -> GradientExportCode?
    {
        let GExport = GradientExportCode(coder: coder)
        GExport?.GradientDelegate = self
        GExport?.GradientToEdit(CurrentGradient, Tag: "")
        return GExport
    }
    
    var ColorToEdit: UIColor = UIColor.black
    var LocationToEdit: Double = 0.0
    var SelectedIndex: Int = -1
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var PresetsButton: UIButton!
    @IBOutlet weak var ClearButton: UIButton!
    @IBOutlet weak var ResetButton: UIButton!
    @IBOutlet weak var ReverseColorButton: UIButton!
    @IBOutlet weak var AddGradientStopButton: UIButton!
    @IBOutlet weak var EditButton: UIButton!
    @IBOutlet weak var GradientStopTable: UITableView!
    @IBOutlet weak var GradientView: UIImageView!
}
