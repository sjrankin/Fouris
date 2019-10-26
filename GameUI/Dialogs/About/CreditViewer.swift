//
//  CreditViewer.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Displays credits and attributions.
class CreditViewer: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    /// Initialize the UI.
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        TitleTable.layer.borderColor = UIColor.black.cgColor
        AttributionBox.layer.borderColor = UIColor.black.cgColor
        AttributionBox.layer.backgroundColor = UIColor.clear.cgColor
        AttributionsViewer.text = ""
        for (Title, Text) in AttributeData.Table
        {
            TableTitleTable.append((Title,Text))
        }
        AttributionsViewer.text = ""
    }
    
    /// Table of titles.
    private var TableTitleTable = [(Title: String, Text: String)]()
    
    /// Returns the height for each row.
    /// - Parameter tableView: Not used.
    /// - Paraemter heightForRowAt: Not used.
    /// - Returns: Height for each row.
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return TitleTableCell.CellHeight
    }
    
    /// Retuns the number of rows in each section. In our case, we have only one section so this is quite straightforward.
    /// - Parameter tableView: Not used.
    /// - Parameter numberOfRowsInSection: Not used.
    /// - Returns: Number of rows in the table.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return TableTitleTable.count
    }
    
    /// Returns a table view cell for the specified row.
    /// - Parameter tableView: Not used.
    /// - Parameter cellForRowAt: Index of the table view cell data.
    /// - Returns: Populated table view cell.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = TitleTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "TitleTableCell")
        Cell.Initialize(WithTitle: TableTitleTable[indexPath.row].Title, TableWidth: TitleTable.bounds.width)
        return Cell
    }
    
    /// Handle table selection events. Show the text associated with the table title.
    /// - Parameter tableView: Not used.
    /// - Parameter didSelectRowAt: The row of the title table selected. Used to determine which text to display.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        AttributionsViewer.text = TableTitleTable[indexPath.row].Text
    }
    
    /// Handle the close button. Close the dialog.
    /// - Parameter sender: Not used.
    @IBAction public func HandleCloseButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var TitleTable: UITableView!
    @IBOutlet weak var AttributionBox: UIView!
    @IBOutlet weak var AttributionsViewer: UITextView!
}
