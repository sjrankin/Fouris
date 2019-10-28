//
//  PieceSelectorDialog.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Code for the piece selection dialog.
class PieceSelectorDialog: UIViewController, UITableViewDelegate, UITableViewDataSource, ThemeEditingProtocol
{
    /// Delegate that receives messages from this class.
    public weak var ThemeDelegate: ThemeEditingProtocol? = nil

    /// Currently selected table tag value.
    private let CurrentTable = 100
    /// Available pieces table tag value.
    private let AvailableTable = 200
    
    /// Initialize the UI.
    override public func viewDidLoad()
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
    
    /// Load all pieces into the `AllPieces` array.
    public func LoadAllPieces()
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
    
    /// Holds all pieces.
    private var AllPieces = [MetaPieces: [UUID]]()
    /// Holds the set of currently selected pieces.
    private var CurrentPieces = [UUID]()
    /// Table of piece categories arranged for sections in the table view.
    private var AllSections: [MetaPieces] = [.Standard, .NonStandard, .PiecesWithGaps, .Malicious, .Big]
    /// Map from sequence to piece group.
    private let SectionMap: [Int: MetaPieces] =
        [
            0: .Standard,
            1: .NonStandard,
            2: .PiecesWithGaps,
            3: .Malicious,
            4: .Big
    ]
    
    /// Called by the class owner to set the theme to edit.
    /// - Parameter Theme: Theme to edit.
    public func EditTheme(Theme: ThemeDescriptor2)
    {
        UserTheme = Theme
    }

    /// Called by the class owner to set the theme to edit.
    /// - Parameter Theme: Theme to edit.
    /// - Parameter PieceID: Not used.
    public func EditTheme(Theme: ThemeDescriptor2, PieceID: UUID)
    {
        UserTheme = Theme
    }
    
    /// Holds the current user theme.
    private var UserTheme: ThemeDescriptor2? = nil
    
    /// Not used in this class.
    public func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //Do nothing here in this class.
    }
    
    /// Returns the height of the cell view.
    /// - Parameter tableView: Not used.
    /// - Parameter heightForRowAt: Not used.
    /// - Returns: Height of all table cell views.
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return GamePieceCell.CellHeight
    }
    
    /// Returns section title values for the available piece table.
    /// - Parameter tableView: The table that wants section titles.
    /// - Parameter titleForHeaderInSection: The section index the returned title is for.
    /// - Returns: The section title for the specified section for the available piece table, nil for the user piece table.
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
    
    /// Returns the number of sections for the specified table.
    /// - Parameter in: The table whose number of sections is returned.
    /// - Returns: Number of sections for the specified table.
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
    
    /// Returns the number of rows in each section of the passed table.
    /// - Parameter tableView: The table view that wants to know the number of rows in a section.
    /// - Parameter numberOfRowsInSection: The section whose number of rows will be returned.
    /// - Returns: Number of rows for the specified section in the passed table.
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
    
    /// Returns a section metapiece.
    /// - Parameter AtIndex: The index of the meta piece to return.
    /// - Returns: Metapiece for the specified index. Nil if not found.
    private func GetSectionMetaPiece(AtIndex: Int) -> MetaPieces?
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
    
    /// Map from metapieces to color for pieces.
    private let FillMap: [MetaPieces: UIColor] =
        [
            MetaPieces.Standard: UIColor.green,
            MetaPieces.NonStandard: UIColor.cyan,
            MetaPieces.Big: UIColor.orange,
            MetaPieces.Malicious: UIColor.red,
            MetaPieces.PiecesWithGaps: UIColor.magenta
    ]
    
    /// The last selected piece.
    private var LastSelectedShape: UUID = UUID.Empty
    
    /// Handle table selection events. Updates UI elements.
    /// - Parameter tableView: The table where the selection occurred.
    /// - Parameter didSelectRowAt: The index of the selected item.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
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
    
    /// Handle table deselection events. Updates UI elements.
    /// - Parameter tableView: The table where the deselection occurred.
    /// - Parameter didSelectRowAt: The index of the deselected item.
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath)
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
    
    /// Returns a table cell view for the specified table, section, and row.
    /// - Parameter tableView: The table that wants a table cell.
    /// - Parameter cellForRowAt: Indicates which section/row to return a table view cell for.
    /// - Returns: Populated table view cell.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
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
    
    /// Update the warning message to let the user know more pieces are needed (or not, if a sufficient number of pieces have
    /// been added).
    /// - Parameter WithCount: Number of selected pieces.
    public func UpdateWarning(WithCount: Int)
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
    
    /// Handle moving the selected piece in the available pieces table to the current pieces table.
    /// - Parameter sender: Not used.
    @IBAction public func HandleMoveToCurrent(_ sender: Any)
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
    
    /// Handle moving a piece from the current table to the available pieces table.
    /// - Parameter sender: Not used.
    @IBAction public func HandleMoveToAvailable(_ sender: Any)
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
    
    /// Clear all pieces in the current piece table.
    /// - Parameter sender: Not used.
    @IBAction public func ClearCurrentPieceSet(_ sender: Any)
    {
        CurrentPieces.removeAll()
        CurrentPieceTable.reloadData()
        LoadAllPieces()
        PieceSourceTable.reloadData()
        UpdateWarning(WithCount: 0)
    }
    
    /// Instantiate the visuals editor to set the visual attributes of a piece.
    /// - Parameter coder: `NSCoder` instance.
    /// - Returns: `PieceEditorCode` instance.
    @IBSegueAction public func InstanstiateVisualEditor(_ coder: NSCoder) -> PieceEditorCode?
    {
        let Editor = PieceEditorCode(coder: coder)
        Editor?.ThemeDelegate = self
        if let SelectedRow = CurrentPieceTable.indexPathForSelectedRow
        {
            if let Cell = CurrentPieceTable.cellForRow(at: SelectedRow) as? GamePieceCell
            {
                Editor?.EditTheme(Theme: UserTheme!, PieceID: Cell.PieceID)
            }
        }
        return Editor
    }
    
    /// Instantiate the visuals editor to set the visual attributes of a piece.
    /// - Parameter coder: `NSCoder` instance.
    /// - Returns: `PieceEditorCode` instance.
    @IBSegueAction public func InstantiateVisualEditorForAvailable(_ coder: NSCoder) -> PieceEditorCode?
    {
        let Editor = PieceEditorCode(coder: coder)
        Editor?.ThemeDelegate = self
        if let SelectedRow = PieceSourceTable.indexPathForSelectedRow
        {
            if let Cell = PieceSourceTable.cellForRow(at: SelectedRow) as? GamePieceCell
            {
                print("Calling piece visual editor with piece ID: \(Cell.PieceID)")
                Editor?.EditTheme(Theme: UserTheme!, PieceID: Cell.PieceID)
            }
        }
        return Editor
    }
    
    /// Handle the OK button pressed. Notify the caller and close the dialog.
    /// - Parameter sender: Not used.
    @IBAction public func HandleOKPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: UserTheme!.ID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }

    /// Handle the cancel button pressed. Notify the caller and close the dialog.
    /// - Parameter sender: Not used.
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(false, ThemeID: UserTheme!.ID, PieceID: nil)
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
