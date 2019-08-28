//
//  SlideInItem.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Contains command names (eg, names the user can readily understand) for the slide-in menu.
class SlideInItem: UITableViewCell
{
    /// Height of each cell.
    public static let CellHeight: CGFloat = 50.0
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Initializer.
    /// - Parameter style: The TableView cell style.
    /// - Parameter reuseIdentifier: Identifer for cell reuse.
    override init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
        self.selectionStyle = .none
        self.accessoryType = .disclosureIndicator
        
        TitleBar = UILabel(frame: CGRect(x: 10, y: 1, width: 240, height: SlideInItem.CellHeight - 5))
        TitleBar.font = UIFont.boldSystemFont(ofSize: 24.0)
        TitleBar.text = "Command"
        contentView.addSubview(TitleBar)
    }
    
    /// The title control.
    var TitleBar: UILabel!
    
    /// Sets the command data for a given TableView cell.
    /// - Parameter CommandName: The user-visible command name.
    /// - Parameter ID: The ID that is actually used to switch on. In other words, this is what the program uses to decide
    ///                 which command the user selected. This is so different languages all behave the same way.
    func SetCommand(CommandName: String, ID: UUID)
    {
        TitleBar.text = CommandName
        Name = CommandName
                CommandID = ID
    }
    
    /// Holds the command ID to be queried by other classes when needed.
    public var CommandID: UUID = UUID.Empty
    
    /// Holds the command name, mostly for debug purposes.
    public var Name: String = ""
}
