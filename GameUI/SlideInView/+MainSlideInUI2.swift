//
//  +MainSlideInUI2.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Extension to **CommonViewController** to handle events and user interactions related to the slide in view.
extension MainViewController2: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return CommandList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return CommandList[indexPath.row] as UITableViewCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return SlideInItem.CellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        if let Cell = tableView.cellForRow(at: indexPath) as? SlideInItem
        {
            HandleSlideInCommand(Cell.CommandID)
        }
    }
    
    /// Initialize the visuals and content of the table used to display options.
    /// - Parameter Table: The UITableView to initialize.
    public func InitializeOptionTable(_ Table: UITableView)
    {
        Table.layer.borderColor = UIColor.black.cgColor
        Table.layer.borderWidth = 1.0
        Table.layer.cornerRadius = 5.0
        AddCommands()
        Table.reloadData()
    }
    
    /// Add commands to the slide in menu/table.
    private func AddCommands()
    {
        let AboutItem = SlideInItem(style: UITableViewCell.CellStyle.default, reuseIdentifier: "AboutItemIdentifier")
        AboutItem.SetCommand(CommandName: "About", ID: CommandIDs[.AboutCommand]!)
        CommandList.append(AboutItem)
        
        let GameStyleItem = SlideInItem(style: UITableViewCell.CellStyle.default, reuseIdentifier: "SelectGame")
        GameStyleItem.SetCommand(CommandName: "Select Game", ID: CommandIDs[.SelectGameCommand]!)
        CommandList.append(GameStyleItem)
        
        let ThemeItem = SlideInItem(style: UITableViewCell.CellStyle.default, reuseIdentifier: "ThemeItem")
        ThemeItem.SetCommand(CommandName: "Themes", ID: CommandIDs[.ThemeCommand]!)
        CommandList.append(ThemeItem)
        
        let SettingsItem = SlideInItem(style: UITableViewCell.CellStyle.default, reuseIdentifier: "SettingsItem")
        SettingsItem.SetCommand(CommandName: "Settings", ID: CommandIDs[.SettingsCommand]!)
        CommandList.append(SettingsItem)
    }
}

/// Command tokens for slide-in UI commands.
/// - Note: The commands here are not necessarily in the same order as presented to the user.
/// - **NoCommand**: Default command which basically means the user selected something we don't recognize. This
///                  should never be sent but is here just in case...
/// - **AboutCommand**: Show the about dialog.
/// - **SelectGameCommand**: Select the game type and style.
/// - **SettingsCommand**: Run the general purpose settings dialog.
/// - **ThemeCommand**: Run the theme dialog.
enum SlideInCommands
{
    case NoCommand
    case AboutCommand
    case SelectGameCommand
    case SettingsCommand
    case ThemeCommand
}
