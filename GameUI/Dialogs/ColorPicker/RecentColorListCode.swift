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
    /// Delegate that receives messages from this class.
    public weak var ColorDelegate: ColorPickerProtocol? = nil
    
    /// Initialize the UI.
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        RecentTable.layer.borderColor = UIColor.black.cgColor
        PopulateColorList()
        RecentTable.reloadData()
    }
    
    /// Populate the color list.
    private func PopulateColorList()
    {
        ColorList.removeAll()
        for (Color, ColorName) in RecentlyUsedColors.ColorList
        {
            let ColorValue = ColorServer.MakeHexString(From: Color)
            ColorList.append((Color, ColorName, ColorValue))
        }
    }
    
    /// Holds a list of colors to display.
    private var ColorList = [(UIColor, String, String)]()
    
    /// Handle the OK button pressed. Close the window.
        /// - Parameter sender: Not used.
    @IBAction public func HandleOKPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the cancel button pressed. Close the window.
        /// - Parameter sender: Not used.
    @IBAction public func HandleCancelPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the clear recent colors list button pressed.
    /// - Parameter sender: Not used.
    @IBAction public func HandleClearList(_ sender: Any)
    {
        RecentlyUsedColors.Clear()
        PopulateColorList()
        RecentTable.reloadData()
    }
    
    /// Returns the height of each cell in the table.
    /// - Parameter tableView: Not used.
    /// - Parameter heightForRowAt: Not used.
    /// - Returns: The height of each cell in the table.
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return RecentColorCell.CellHeight
    }
    
    /// Returns the number of colors in the recent color list.
    /// - Parameter tableView: Not used.
    /// - Parameter numberOfRowsInSection: Not used.
    /// - Returns: Number of colors in the recent color list.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return ColorList.count
    }
    
    /// Returns a populated table view cell with a recent color.
    /// - Parameter tableView: Not used.
    /// - Parameter cellForRowAt: Index of the recent color to use to populate the table view cell.
    /// - Returns: Table view cell with a recent color.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Width = tableView.bounds.size.width
        let Cell = RecentColorCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "Cell")
        let (Color, ColorName, ColorValue) = ColorList[indexPath.row]
        Cell.LoadData(Color: Color, Name: ColorName, Value: ColorValue, Width: Width)
        return Cell
    }
    
    /// Not currently used.
    public func ColorToEdit(_ Color: UIColor, Tag: Any?)
    {
    }
    
    /// Not currently used.
    public func EditedColor(_ Edited: UIColor?, Tag: Any?)
    {
    }
    
    @IBOutlet weak var RecentTable: UITableView!
}
