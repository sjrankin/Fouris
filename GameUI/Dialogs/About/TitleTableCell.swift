//
//  TitleTableCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Table view cell for attribute data titles.
class TitleTableCell: UITableViewCell
{
    /// The height of each table cell.
    public static let CellHeight: CGFloat = 50.0
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// initializer.
    /// - Parameter style: Style of the table view cell.
    /// - Parameter reuseIdentifier: Identifier string for the reuse mechanism.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        TitleLabel = UILabel(frame: CGRect(x: 10, y: 5, width: 200, height: 40))
        contentView.addSubview(TitleLabel!)
        TitleLabel?.font = UIFont(name: "Futura", size: 18.0)
    }
    
    /// Title label.
    private var TitleLabel: UILabel? = nil

    /// Initialize the table view cell.
    /// - Parameter WithTitle: Title text.
    /// - Parameter TableWidth: Width of the table to ensure text does not look too ugly.
    public func Initialize(WithTitle: String, TableWidth: CGFloat)
    {
        TitleLabel?.frame = CGRect(x: 10, y: 5, width: TableWidth - 20, height: 40)
        TitleLabel?.text = WithTitle
        CellTitle = WithTitle
    }
    
    /// Holds the cell title.
    public var CellTitle: String = ""
}
