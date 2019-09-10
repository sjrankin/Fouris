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
    
    func ResetAllPivotPoints()
    {
        //Not used in this class.
    }
    
    //Not used in this class.
    func GetPlotCoordinates(ForX: Int, ForY: Int) -> (Int, Int)?
    {
        return nil
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
        PieceGrid.ResetAllPivotPoints()
        SelectedCells.removeAll()
        UpdateSample()
        HandleResetRotationsPressed(self)
    }
    
    @IBAction func HandleRotateXChanged(_ sender: Any)
    {
        RotateX = !RotateX
        SampleView.RotatePiece(OnX: RotateX, OnY: RotateY, OnZ: RotateZ)
    }
    
    @IBAction func HandleRotateYChanged(_ sender: Any)
    {
        RotateY = !RotateY
        SampleView.RotatePiece(OnX: RotateX, OnY: RotateY, OnZ: RotateZ)
    }
    
    @IBAction func HandleRotateZChanged(_ sender: Any)
    {
        RotateZ = !RotateZ
        SampleView.RotatePiece(OnX: RotateX, OnY: RotateY, OnZ: RotateZ)
    }
    
    @IBAction func HandleResetRotationsPressed(_ sender: Any)
    {
        RotateXSwitch.isOn = false
        RotateYSwitch.isOn = false
        RotateZSwitch.isOn = false
        RotateX = false
        RotateY = false
        RotateZ = false
        SampleView.RotatePiece(OnX: false, OnY: false, OnZ: false)
        SampleView.ResetRotations()
    }
    
    func UpdateSample()
    {
        SampleView.Clear()
        for (X, Y) in SelectedCells
        {
            SampleView.AddBlockAt(X, Y)
        }
    }
    
    // MARK: Grid protocol function implementations.
    
    var SelectedCells = [(Int, Int)]()
    
    func IsSelectedAt(_ X: Int, _ Y: Int) -> Bool
    {
        for (AtX, AtY) in SelectedCells
        {
            if AtX == X && AtY == Y
            {
                return true
            }
        }
        return false
    }
    
    func CellSelectionStateChanged(Column: Int, Row: Int, IsSelected: Bool)
    {
        if let (PlotX, PlotY) = PieceGrid.GetPlotCoordinates(ForX: Column, ForY: Row)
        {
            if IsSelected
            {
                if IsSelectedAt(PlotX, -PlotY)
                {
                    return
                }
                SelectedCells.append((PlotX, -PlotY))
            }
            else
            {
                if !IsSelectedAt(PlotX, -PlotY)
                {
                    return
                }
                SelectedCells = SelectedCells.filter({!($0.0 == PlotX && $0.1 == -PlotY)})
            }
        }
        UpdateSample()
    }
    
    func CellTapped(Column: Int, Row: Int, TapCount: Int)
    {
        //print("Cell at \(Column),\(Row) was tapped \(TapCount) times")
    }
    
    func CellCountChanged(ColumnCount: Int, RowCount: Int)
    {
        //print("New cell count: \(ColumnCount) columns, \(RowCount) rows.")
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
