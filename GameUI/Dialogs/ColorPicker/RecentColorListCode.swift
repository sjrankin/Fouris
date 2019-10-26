//
//  RecentColorListCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// The code to run the recent color list (which isn't really implemented yet).
class RecentColorListCode: UIViewController, UITableViewDelegate, UITableViewDataSource, ColorPickerProtocol
{
    public weak var ColorDelegate: ColorPickerProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        RecentTable.layer.borderColor = UIColor.black.cgColor
        PopulateColorList()
        RecentTable.reloadData()
    }
    
    private func PopulateColorList()
    {
        ColorList.removeAll()
        for (Color, ColorName) in RecentlyUsedColors.ColorList
        {
            let ColorValue = ColorServer.MakeHexString(From: Color)
            ColorList.append((Color, ColorName, ColorValue))
        }
    }
    
    private var ColorList = [(UIColor, String, String)]()
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleClearList(_ sender: Any)
    {
        RecentlyUsedColors.Clear()
        PopulateColorList()
        RecentTable.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return RecentColorCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ColorList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Width = tableView.bounds.size.width
        let Cell = RecentColorCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        let (Color, ColorName, ColorValue) = ColorList[indexPath.row]
        Cell.LoadData(Color: Color, Name: ColorName, Value: ColorValue, Width: Width)
        return Cell
    }
    
    func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
    }
    
    func EditedColor(_ Edited: UIColor?, Tag: Any?)
    {
    }
    
    @IBOutlet weak var RecentTable: UITableView!
}
