//
//  PieceSelectorDialog.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PieceSelectorDialog: UIViewController, UITableViewDelegate, UITableViewDataSource, ThemeEditingProtocol
{
    weak var ThemeDelegate: ThemeEditingProtocol? = nil
    
    let CurrentTable = 100
    let AvailableTable = 200
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        PieceSourceTable.layer.borderColor = UIColor.black.cgColor
        PieceSourceTable.layer.cornerRadius = 5.0
        PieceSourceTable.layer.borderWidth = 0.5
        CurrentPieceTable.layer.borderColor = UIColor.black.cgColor
        CurrentPieceTable.layer.cornerRadius = 5.0
        CurrentPieceTable.layer.borderWidth = 0.5
        OKButton.isEnabled = true
        PieceCountWarning.isHidden = true
        LoadAllPieces()
        UpdateWarning(WithCount: 0)
    }
    
    func LoadAllPieces()
    {
        AllPieces.removeAll()
        AllPieces[.Standard] = [UUID]()
        AllPieces[.NonStandard] = [UUID]()
        AllPieces[.PiecesWithGaps] = [UUID]()
        AllPieces[.Malicious] = [UUID]()
        AllPieces[.Big] = [UUID]()
        for MetaPiece in AllSections
        {
            for PieceType in PieceFactory.MetaPieceMap[MetaPiece]!
            {
                let ID: UUID = PieceFactory.ShapeIDMap[PieceType]!
                if !CurrentPieces.contains(ID)
                {
                    AllPieces[MetaPiece]?.append(ID)
                }
            }
        }
    }
    
    var AllPieces = [MetaPieces: [UUID]]()
    var CurrentPieces = [UUID]()
    var AllSections: [MetaPieces] = [.Standard, .NonStandard, .PiecesWithGaps, .Malicious, .Big]
    let SectionMap: [Int: MetaPieces] =
        [
            0: .Standard,
            1: .NonStandard,
            2: .PiecesWithGaps,
            3: .Malicious,
            4: .Big
    ]
    
    func EditTheme(ID: UUID)
    {
        ThemeID = ID
    }
    
    func EditTheme(ID: UUID, PieceID: UUID)
    {
        ThemeID = ID
    }
    
    var ThemeID: UUID = UUID.Empty
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //Do nothing here in this class.
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return GamePieceCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        if tableView.tag == AvailableTable
        {
            switch section
            {
                case 0:
                    return "Standard"
                
                case 1:
                    return "Non-Standard"
                
                case 2:
                    return "Pieces with Gaps"
                
                case 3:
                    return "Malicious"
                
                case 4:
                    return "Big"
                
                default:
                    return nil
            }
        }
        else
        {
            return nil
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        switch tableView.tag
        {
            case CurrentTable:
                return 1
            
            case AvailableTable:
                return AllSections.count
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch tableView.tag
        {
            case CurrentTable:
                return CurrentPieces.count
            
            case AvailableTable:
                let SectionType = AllSections[section]
                let Count = AllPieces[SectionType]!.count
                return Count
            
            default:
                return 0
        }
    }
    
    func GetSectionMetaPiece(AtIndex: Int) -> MetaPieces?
    {
        var Index = 0
        for (Meta, _) in AllPieces
        {
            if Index == AtIndex
            {
                return Meta
            }
            Index = Index + 1
        }
        return nil
    }
    
    let FillMap: [MetaPieces: UIColor] =
        [
            MetaPieces.Standard: UIColor.green,
            MetaPieces.NonStandard: UIColor.cyan,
            MetaPieces.Big: UIColor.orange,
            MetaPieces.Malicious: UIColor.red,
            MetaPieces.PiecesWithGaps: UIColor.magenta
    ]
    
    var LastSelectedShape: UUID = UUID.Empty
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch tableView.tag
        {
            case CurrentTable:
                if CurrentPieceTable.indexPathForSelectedRow != nil
                {
                    CurrentEditVisualsButton.isEnabled = true
                    if let Cell = CurrentPieceTable.cellForRow(at: indexPath) as? GamePieceCell
                    {
                        LastSelectedShape = Cell.PieceID
                    }
                }
                else
                {
                    CurrentEditVisualsButton.isEnabled = false
                }
            
            default:
                break
        }
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
    {
        switch tableView.tag
        {
            case CurrentTable:
                if CurrentPieceTable.indexPathForSelectedRow != nil
                {
                    CurrentEditVisualsButton.isEnabled = true
                }
                else
                {
                    CurrentEditVisualsButton.isEnabled = false
                }
            
            default:
                break
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = GamePieceCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "GamePieceCell")
        var ID = UUID.Empty
        var SectionType: MetaPieces = .Standard
        var Shape = PieceShapes.Bar
        
        switch tableView.tag
        {
            case CurrentTable:
                ID = CurrentPieces[indexPath.row]
                Shape = PieceFactory.GetShapeForPiece(ID: ID)!
                SectionType = PieceFactory.GetMetaPieceFromShape(Shape)!
            
            case AvailableTable:
                SectionType = SectionMap[indexPath.section]!
                ID = AllPieces[SectionType]![indexPath.row]
                Shape = PieceFactory.GetShapeForPiece(ID: ID)!
            
            default:
                return UITableViewCell()
        }
        
        let Name = PieceFactory.PieceNameMap[Shape]
        let ScratchPiece = PieceFactory.CreateEphermeralPiece(Shape)
        let FillColor = FillMap[SectionType]
        let ShapeImage: UIImage? = PieceFactory.GetGenericView(ForPiece: ScratchPiece, UnitSize: 32.0, WithShadow: false, FillColor: FillColor!)
        Cell.LoadData(PieceImage: ShapeImage!, Name: Name!, ID: ID)
        if LastSelectedShape != UUID.Empty
        {
            if tableView.tag == CurrentTable
            {
            if ID == LastSelectedShape
            {
                tableView.selectRow(at: indexPath, animated: true, scrollPosition: UITableView.ScrollPosition.middle)
                UpdateWarning(WithCount: CurrentPieces.count)
            }
            }
        }
        return Cell
    }
    
    func UpdateWarning(WithCount: Int)
    {
        if WithCount < 4
        {
            OKButton.isEnabled = false
            PieceCountWarning.isHidden = false
        }
        else
        {
            OKButton.isEnabled = true
            PieceCountWarning.isHidden = true
        }
    }
    
    @IBAction func HandleMoveToCurrent(_ sender: Any)
    {
        if let SelectedRow = PieceSourceTable.indexPathForSelectedRow
        {
            if let Cell = PieceSourceTable.cellForRow(at: SelectedRow) as? GamePieceCell
            {
                if !CurrentPieces.contains(Cell.PieceID)
                {
                    CurrentEditVisualsButton.isEnabled = false
                    CurrentPieces.append(Cell.PieceID)
                    CurrentPieceTable.reloadData()
                    LoadAllPieces()
                    PieceSourceTable.reloadData()
                    UpdateWarning(WithCount: CurrentPieces.count)
                }
            }
        }
    }
    
    @IBAction func HandleMoveToAvailable(_ sender: Any)
    {
        if let SelectedRow = CurrentPieceTable.indexPathForSelectedRow
        {
            if let Cell = CurrentPieceTable.cellForRow(at: SelectedRow) as? GamePieceCell
            {
                CurrentEditVisualsButton.isEnabled = false
                let RemoveMe = Cell.PieceID
                CurrentPieces.removeAll(where: {$0 == RemoveMe})
                CurrentPieceTable.reloadData()
                LoadAllPieces()
                PieceSourceTable.reloadData()
                UpdateWarning(WithCount: CurrentPieces.count)
            }
        }
    }
    
    @IBAction func ClearCurrentPieceSet(_ sender: Any)
    {
        CurrentPieces.removeAll()
        CurrentPieceTable.reloadData()
        LoadAllPieces()
        PieceSourceTable.reloadData()
        UpdateWarning(WithCount: 0)
    }
    
    @IBSegueAction func InstanstiateVisualEditor(_ coder: NSCoder) -> PieceEditorCode?
    {
        let Editor = PieceEditorCode(coder: coder)
        Editor?.ThemeDelegate = self
        if let SelectedRow = CurrentPieceTable.indexPathForSelectedRow
        {
            if let Cell = CurrentPieceTable.cellForRow(at: SelectedRow) as? GamePieceCell
            {
                Editor?.EditTheme(ID: ThemeID, PieceID: Cell.PieceID)
            }
        }
        return Editor
    }
    
    @IBSegueAction func InstantiateVisualEditorForAvailable(_ coder: NSCoder) -> PieceEditorCode?
    {
        let Editor = PieceEditorCode(coder: coder)
        Editor?.ThemeDelegate = self
        if let SelectedRow = PieceSourceTable.indexPathForSelectedRow
        {
            if let Cell = PieceSourceTable.cellForRow(at: SelectedRow) as? GamePieceCell
            {
                Editor?.EditTheme(ID: ThemeID, PieceID: Cell.PieceID)
            }
        }
        return Editor
    }
    
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: ThemeID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(false, ThemeID: ThemeID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var AvailableEditVisualsButton: UIButton!
    @IBOutlet weak var ClearCurrentTableButton: UIButton!
    @IBOutlet weak var CurrentEditVisualsButton: UIButton!
    @IBOutlet weak var OKButton: UIButton!
    @IBOutlet weak var PieceCountWarning: UILabel!
    @IBOutlet weak var PieceSourceTable: UITableView!
    @IBOutlet weak var CurrentPieceTable: UITableView!
}
