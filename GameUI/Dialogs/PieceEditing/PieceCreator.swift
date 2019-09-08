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
    }
    
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
    
    @IBOutlet weak var SampleView: SCNView!
    @IBOutlet weak var PieceGrid: Grid!
}
