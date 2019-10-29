//
//  RawThemeViewerTitleCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Table view cell for theme/setting fields.
class RawThemeViewerTitleCell: UITableViewCell
{
    // The height of each field.
    public static let CellHeight: CGFloat = 50.0
    
    /// Required initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Initializer.
    /// - Parameter style: Table view cell style.
    /// - Parameter reuseIdentifier: Identifier for reusing table view cells.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    /// Draw the UI constrained by the passed width.
    /// - WithWidth: Width of the table view.
    public func DrawUI(WithWidth: CGFloat)
    {
        TitleLabel = UILabel(frame: CGRect(x: 20, y: 5, width: WithWidth - 50, height: 40))
        TitleLabel.text = CellTitle
        TitleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.medium)
        contentView.addSubview(TitleLabel)
    }
    
    /// The label for the title.
    private var TitleLabel: UILabel!
    
    /// Load data from teh caller.
    /// - Parameter Title: The title of the field.
    /// - Parameter ID: The ID of the field.
    /// - Parameter ParentWidth: The width of the table.
    public func Initialize(Title: String, ID: UUID, ParentWidth: CGFloat)
    {
        self.ParentWidth = ParentWidth
        CellID = ID
        CellTitle = Title
        DrawUI(WithWidth: ParentWidth)
    }

    /// Holds the width of teh parent table.
    public var ParentWidth: CGFloat!
    /// Holds the field ID.
    public var CellID: UUID!
    /// Holds the title text.
    public var CellTitle: String!
}
