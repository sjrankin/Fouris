//
//  RawThemeViewerCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/16/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class RawThemeViewerCode: UIViewController, UITableViewDataSource, UITableViewDelegate, ThemeEditingProtocol, RawThemeFieldEditProtocol
{
    weak var ThemeDelegate: ThemeEditingProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ThemeDataTable.layer.borderColor = UIColor.black.cgColor
        CreateFieldTables()
    }
    
    func CreateFieldTables()
    {
        //Settings
        let SettingsGroup = GroupData("Settings")
        SettingsGroup.AddField(ID: UUID(), Title: "Confirm image save", Default: false as Any,
                               Starting: Settings.GetConfirmGameImageSave() as Any, FieldType: .Bool, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetConfirmGameImageSave(NewValue: NewBool)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Auto-start wait duration", Default: 60.0 as Any,
                               Starting: Settings.GetAutoStartDuration() as Any, FieldType: .Double, Handler:
            {
                NewValue in
                let NewDouble = NewValue as! Double
                Settings.SetAutoStartDuration(ToNewValue: NewDouble)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Use TDebug", Default: true, Starting: Settings.GetUseTDebug(),
                               FieldType: .Bool, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetUseTDebug(Enabled: NewBool)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Start with AI", Default: false as Any,
                               Starting: Settings.GetStartWithAI() as Any, FieldType: .Bool, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetStartWithAI(Enabled: NewBool)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Maximum same pieces", Default: 3, Starting: Settings.MaximumSamePieces(),
                               FieldType: .Int, Handler:
            {
                NewValue in
                let NewInt = NewValue as! Int
                Settings.SetMaximumSamePieces(ToValue: NewInt)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "AI sneak peak count", Default: 1 as Any,
                               Starting: Settings.GetAISneakPeakCount() as Any, FieldType: .Int, Handler:
            {
                NewValue in
                let NewInt = NewValue as! Int
                Settings.SetAISneakPeakCount(To: NewInt)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Show AI commands", Default: true as Any,
                               Starting: Settings.ShowAIUICommands() as Any, FieldType: .Bool, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetAIUICommands(Enable: NewBool)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Enable vibrations", Default: false as Any,
                               Starting: Settings.EnableVibrateFeedback() as Any, FieldType: .Bool, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetVibrateFeedback(Enable: NewBool)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Enable haptic feedback", Default: false as Any,
                               Starting: Settings.EnableHapticFeedback() as Any, FieldType: .Bool, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetHapticFeedback(Enable: NewBool)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Show alpha in color picker", Default: true as Any,
                               Starting: Settings.GetShowAlpha() as Any, FieldType: .Bool, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetShowAlpha(NewValue: NewBool)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Show closest color", Default: true as Any,
                               Starting: Settings.GetShowClosestColor() as Any, FieldType: .Bool, Handler:
            {
                NewValue in
                let NewBool = NewValue as! Bool
                Settings.SetShowClosestColor(NewValue: NewBool)
        })
        SettingsGroup.AddField(ID: UUID(), Title: "Game background type", Default: 0 as Any,
                               Starting: Settings.GetGameBackgroundType() as Any, FieldType: .Int, Handler:
            {
                NewValue in
                let NewInt = NewValue as! Int
                Settings.SetGameBackgroundType(NewValue: NewInt)
        })
        FieldTables.append(SettingsGroup)
        
        //Game view.
        let ViewGroup = GroupData("Game View")
        ViewGroup.AddField(ID: UUID(), Title: "Show rendering statistics", Default: false as Any, Starting: false as Any,
                           FieldType: .Bool)
        ViewGroup.AddField(ID: UUID(), Title: "Antialiasing mode", Default: 2 as Any, Starting: 2 as Any, FieldType: .Int)
        ViewGroup.AddField(ID: UUID(), Title: "Field of view", Default: 92.5 as Any, Starting: 92.5 as Any,
                           FieldType: .Double)
        ViewGroup.AddField(ID: UUID(), Title: "Camera position", Default: SCNVector3(-0.5, 2.0, 15.0) as Any,
                           Starting: SCNVector3(-0.5, 2.0, 15.0), FieldType: .Vector3)
        ViewGroup.AddField(ID: UUID(), Title: "Camera orientation", Default: SCNVector4(0.0, 0.0, 0.0, 0.0) as Any,
                           Starting: SCNVector4(0.0, 0.0, 0.0, 0.0), FieldType: .Vector4)
        ViewGroup.AddField(ID: UUID(), Title: "User can control camera", Default: false as Any, Starting: false as Any,
                           FieldType: .Bool)
        ViewGroup.AddField(ID: UUID(), Title: "Use default camera", Default: false as Any, Starting: false as Any, FieldType: .Bool)
        ViewGroup.AddField(ID: UUID(), Title: "Light color", Default: UIColor.white as Any, Starting: UIColor.white as Any,
                           FieldType: .Color)
        ViewGroup.AddField(ID: UUID(), Title: "Light type", Default: 0 as Any, Starting: 0 as Any, FieldType: .Int)
        ViewGroup.AddField(ID: UUID(), Title: "Light position", Default: SCNVector3(-5.0, 15.0, 40.0) as Any,
                           Starting: SCNVector3(-5.0, 15.0, 40.0) as Any, FieldType: .Vector3)
        ViewGroup.AddField(ID: UUID(), Title: "Show background grid", Default: false as Any, Starting: false as Any,
                           FieldType: .Bool)
        ViewGroup.AddField(ID: UUID(), Title: "Show bucket grid", Default: false as Any, Starting: false as Any,
                           FieldType: .Bool)
        ViewGroup.AddField(ID: UUID(), Title: "Show bucket grid outline", Default: false as Any, Starting: false as Any,
                           FieldType: .Bool)
        FieldTables.append(ViewGroup)
        
        ThemeDataTable.reloadData()
    }
    
    var FieldTables: [GroupData] = [GroupData]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return FieldTables[section].Fields.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        return FieldTables[section].HeaderTitle
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return FieldTables.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return FieldCell.FieldCellHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Width = ThemeDataTable.bounds.size.width
        let FieldData = FieldTables[indexPath.section].Fields[indexPath.row]
        var Cell: FieldCell? = nil
        switch FieldData.FieldType
        {
            case .Bool:
                Cell = BooleanCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "BoolCell")
                Cell?.FieldDelegate = self
                Cell?.Initialize(With: FieldData, ParentWidth: Width)
            
            case .Double:
                Cell = DoubleCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "DoubleCell")
                Cell?.FieldDelegate = self
                Cell?.Initialize(With: FieldData, ParentWidth: Width)
            
            case .Int:
                Cell = IntCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "IntCell")
                Cell?.FieldDelegate = self
                Cell?.Initialize(With: FieldData, ParentWidth: Width)
            
            case .String:
                Cell = StringCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "StringCell")
                Cell?.FieldDelegate = self
                Cell?.Initialize(With: FieldData, ParentWidth: Width)
            
            case .Color:
                Cell = ColorCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "ColorCell")
                Cell?.Parent = self
                Cell?.FieldDelegate = self
                Cell?.Initialize(With: FieldData, ParentWidth: Width)
            
            case .Gradient:
                return UITableViewCell()
            
            case .StringList:
                return UITableViewCell()
            
            case .UUID:
                return UITableViewCell()
            
            case .Vector3:
                Cell = Vector3Cell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Vector3Cell")
                Cell?.FieldDelegate = self
                Cell?.Initialize(With: FieldData, ParentWidth: Width)
            
            case .Vector4:
                Cell = Vector4Cell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Vector4Cell")
                Cell?.FieldDelegate = self
                Cell?.Initialize(With: FieldData, ParentWidth: Width)
            
            case .Enum:
            return UITableViewCell()
            
            case .none:
                return UITableViewCell()
        }
        
        Cell?.DrawUI()
        return Cell!
    }
    
    func EditTheme(ID: UUID)
    {
        //Not used here.
    }
    
    func EditTheme(ID: UUID, PieceID: UUID)
    {
        //Not used here.
    }
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //Not used here.
    }
    
    func EditedField(_ ID: UUID, NewValue: Any, DefaultValue: Any, FieldType: FieldTypes)
    {
        
    }
    
    var WasEdited: Bool = false
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        ThemeDelegate?.EditResults(WasEdited, ThemeID: UUID.Empty, PieceID: UUID.Empty)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var ThemeDataTable: UITableView!
}
