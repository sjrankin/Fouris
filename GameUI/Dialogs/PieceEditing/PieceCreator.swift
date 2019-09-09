//
//  PieceCreator.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class PieceCreator: UIViewController, ThemeEditingProtocol, GridProtocol
{
    weak var ThemeDelegate: ThemeEditingProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        NewTheme = UUID()
        PieceGrid.layer.borderColor = UIColor.black.cgColor
        PieceGrid.backgroundColor = UIColor.black
        PieceGrid.GridDelegate = self
        SampleView.layer.borderColor = UIColor.black.cgColor
        SampleView.backgroundColor = ColorServer.ColorFrom(ColorNames.AzukiIro)
        SampleView.layer.cornerRadius = 5.0
        RotateXSwitch.isOn = false
        RotateYSwitch.isOn = false
        RotateZSwitch.isOn = false
    }
    
    var RotateX: Bool = false
    var RotateY: Bool = false
    var RotateZ: Bool = false
    
    func EditTheme(ID: UUID)
    {
        ThemeID = ID
    }
    
    var ThemeID = UUID.Empty
    
    var NewTheme = UUID.Empty
    
    func EditTheme(ID: UUID, Piece: UUID)
    {
        //Not used in this class.
    }
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //Not used in this class.
    }
    
    func ResetAllCells(ToSelection: Bool)
    {
        //Not used in this class.
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: ThemeID, PieceID: NewTheme)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(false, ThemeID: ThemeID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleResetGrid(_ sender: Any)
    {
        PieceGrid.ResetAllCells(ToSelection: false)
    }
    
    @IBAction func HandleRotateXChanged(_ sender: Any)
    {
        RotateX = !RotateX
    }
    
    @IBAction func HandleRotateYChanged(_ sender: Any)
    {
        RotateY = !RotateY
    }
    
    @IBAction func HandleRotateZChanged(_ sender: Any)
    {
        RotateZ = !RotateZ
    }
    
    // MARK: Grid protocol function implementations.
    
    func CellSelectionStateChanged(Column: Int, Row: Int, IsSelected: Bool)
    {
        print("Cell at \(Column),\(Row) has selection state \(IsSelected)")
    }
    
    func CellTapped(Column: Int, Row: Int, TapCount: Int)
    {
        print("Cell at \(Column),\(Row) was tapped \(TapCount) times")
    }
    
    func CellCountChanged(ColumnCount: Int, RowCount: Int)
    {
        print("New cell count: \(ColumnCount) columns, \(RowCount) rows.")
    }
    
    /// Not used in this class. Returns emtpy array.
    func PivotCellCoordinates() -> [(Int, Int)]
    {
        return [(Int, Int)]()
    }
    
    @IBOutlet weak var RotateZSwitch: UISwitch!
    @IBOutlet weak var RotateYSwitch: UISwitch!
    @IBOutlet weak var RotateXSwitch: UISwitch!
    @IBOutlet weak var SampleView: PieceViewer!
    @IBOutlet weak var PieceGrid: Grid!
}
