//
//  PresetGradientListCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PresetGradientListCode: UIViewController, UITableViewDelegate, UITableViewDataSource,
    GradientPickerProtocol
{
    weak var GradientDelegate: GradientPickerProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        GradientTable.layer.borderColor = UIColor.black.cgColor
        LoadPresetGradients()
        GradientTable.reloadData()
    }
    
    func LoadPresetGradients()
    {
        PresetList.removeAll()
        for (_, Name, Definition) in GradientManager.GradientList
        {
            PresetList.append((Name, Definition))
        }
    }
    
    var PresetList = [(String, String)]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return PresetList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return PresetGradientCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = PresetGradientCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "PresetGradient")
        Cell.LoadData(PresetList[indexPath.row], Vertical: VerticalGradientSwitch.isOn)
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        SelectedGradient = PresetList[indexPath.row].1
        print("Selected gradient \(PresetList[indexPath.row].0)")
    }
    
    var SelectedGradient: String = ""
    
    func EditedGradient(_ Edited: String?, Tag: Any?)
    {
        //Not used.
    }
    
    func GradientToEdit(_ Edited: String?, Tag: Any?)
    {
        GradientTag = Tag
    }
    
    var GradientTag: Any? = nil
    
    func SetStop(StopColorIndex: Int)
    {
        //Not used here.
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        GradientDelegate?.EditedGradient(SelectedGradient, Tag: GradientTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        GradientDelegate?.EditedGradient(nil, Tag: GradientTag)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleGradientOrientationChanged(_ sender: Any)
    {
        GradientTable.reloadData()
    }
    
    @IBAction func HandleSortGradientList(_ sender: Any)
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
    
    var SortDirection = true
    
    @IBOutlet weak var VerticalGradientSwitch: UISwitch!
    @IBOutlet weak var GradientTable: UITableView!
}
