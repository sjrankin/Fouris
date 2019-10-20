//
//  CreditViewer.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class CreditViewer: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    override func viewDidLoad()
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
    
    var TableTitleTable = [(Title: String, Text: String)]()
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return TitleTableCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return TableTitleTable.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = TitleTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "TitleTableCell")
        Cell.Initialize(WithTitle: TableTitleTable[indexPath.row].Title, TableWidth: TitleTable.bounds.width)
        return Cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        AttributionsViewer.text = TableTitleTable[indexPath.row].Text
    }
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var TitleTable: UITableView!
    @IBOutlet weak var AttributionBox: UIView!
    @IBOutlet weak var AttributionsViewer: UITextView!
}
