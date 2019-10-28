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

/// Code to run the UI that allows users to create their own pieces.
class PieceCreator: UIViewController, ThemeEditingProtocol, GridProtocol
{
    /// Delegate that receives messages from this class.
    public weak var ThemeDelegate: ThemeEditingProtocol? = nil
    
    /// Initialize the UI.
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        NewTheme = UUID()
        PieceGrid.layer.borderColor = UIColor.black.cgColor
        PieceGrid.backgroundColor = UIColor.black
        PieceGrid.GridDelegate = self
        SampleView.layer.borderColor = UIColor.black.cgColor
        SampleView.backgroundColor = ColorServer.ColorFrom(ColorNames.AzukiIro)
        SampleView.layer.cornerRadius = 5.0
        SampleView.DiffuseColor = UIColor.blue
        SampleView.SpecularColor = UIColor.cyan
        RotateXSwitch.isOn = false
        RotateYSwitch.isOn = false
        RotateZSwitch.isOn = false
    }
    
    /// Holds the rotate the sample on the X axis flag.
    private var RotateX: Bool = false
        /// Holds the rotate the sample on the Y axis flag.
    private var RotateY: Bool = false
        /// Holds the rotate the sample on the Z axis flag.
    private var RotateZ: Bool = false
    
    /// Called by the parent class.
    /// - Parameter Theme: The current theme.
    public func EditTheme(Theme: ThemeDescriptor2)
    {
        UserTheme = Theme
    }
    
    /// ID of the theme.
    private var ThemeID = UUID.Empty
    
    /// ID of the new theme.
    private var NewTheme = UUID.Empty
    
    /// User theme.
    var UserTheme: ThemeDescriptor2? = nil
    
    /// Called by the parent class.
    /// - Parameter Theme: The current theme.
    /// - PieceID: Not used.
    public func EditTheme(Theme: ThemeDescriptor2, PieceID: UUID)
    {
        UserTheme = Theme
    }
    
    /// Not used in this class.
    public func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //Not used in this class.
    }
    
    /// Not used in this class.
    public func ResetAllCells(ToSelection: Bool)
    {
        //Not used in this class.
    }
    
    /// Not used in this class.
    public func ResetAllPivotPoints()
    {
        //Not used in this class.
    }
    
    //Not used in this class.
    func GetPlotCoordinates(ForX: Int, ForY: Int) -> (Int, Int)?
    {
        return nil
    }
    
    /// Handle the OK button pressed. Notify the caller of the change.
    /// - Parameter sender: Not used.
    @IBAction public func HandleOKPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: ThemeID, PieceID: NewTheme)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the cancel button pressed. Notify the caller that nothing was changed.
    /// - Parameter sender: Not used.
    @IBAction public func HandleCancelPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(false, ThemeID: ThemeID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the reset grid button press. All currently selected/added cells are removed.
    /// - Parameter sender: Not used.
    @IBAction public func HandleResetGrid(_ sender: Any)
    {
        PieceGrid.ResetAllCells(ToSelection: false)
        PieceGrid.ResetAllPivotPoints()
        SelectedCells.removeAll()
        UpdateSample()
        HandleResetRotationsPressed(self)
    }
    
    /// Handle changes to the rotate sample on the X axis switch.
    /// - Parameter sender: Not used.
    @IBAction public func HandleRotateXChanged(_ sender: Any)
    {
        RotateX = !RotateX
        SampleView.RotatePiece(OnX: RotateX, OnY: RotateY, OnZ: RotateZ)
    }
    
    /// Handle changes to the rotate sample on the Y axis switch.
    /// - Parameter sender: Not used.
    @IBAction public func HandleRotateYChanged(_ sender: Any)
    {
        RotateY = !RotateY
        SampleView.RotatePiece(OnX: RotateX, OnY: RotateY, OnZ: RotateZ)
    }
    
    /// Handle changes to the rotate sample on the Z axis switch.
    /// - Parameter sender: Not used.
    @IBAction public func HandleRotateZChanged(_ sender: Any)
    {
        RotateZ = !RotateZ
        SampleView.RotatePiece(OnX: RotateX, OnY: RotateY, OnZ: RotateZ)
    }
    
    /// Handle the reset sample rotations.
    /// - Parameter sender: Not used.
    @IBAction public func HandleResetRotationsPressed(_ sender: Any)
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
    
    /// Update the sample.
    public func UpdateSample()
    {
        SampleView.Clear()
        for (X, Y) in SelectedCells
        {
            SampleView.AddBlockAt(X, Y)
        }
    }
    
    // MARK: Grid protocol function implementations.
    
    /// Holds a set of selected cells.
    public var SelectedCells = [(Int, Int)]()
    
    /// Determines if a cell at the specified coordinate is selected.
    /// - Parameter X: The X coordinate to check.
    /// - Parameter Y: The Y coordinate to check.
    /// - Returns: True if the cell is selected, false if not.
    public func IsSelectedAt(_ X: Int, _ Y: Int) -> Bool
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
    
    /// Handle selection state changes in the grid.
    /// - Parameter Column: The horizontal location of the changed cell.
    /// - Parameter Row: The vertical location of the changed cell.
    /// - Parameter IsSelected: The new selection state.
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
    
    /// Not currently used.
    func CellTapped(Column: Int, Row: Int, TapCount: Int)
    {
        //print("Cell at \(Column),\(Row) was tapped \(TapCount) times")
    }
    
    /// Not currently used.
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
