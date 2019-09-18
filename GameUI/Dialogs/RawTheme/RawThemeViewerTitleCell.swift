//
//  RawThemeViewerTitleCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/18/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class RawThemeViewerTitleCell: UITableViewCell
{
    public static let CellHeight: CGFloat = 50.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    func DrawUI(WithWidth: CGFloat)
    {
        TitleLabel = UILabel(frame: CGRect(x: 20, y: 5, width: WithWidth - 50, height: 40))
        TitleLabel.text = CellTitle
        TitleLabel.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.medium)
        contentView.addSubview(TitleLabel)
    }
    
    var TitleLabel: UILabel!
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    func Initialize(Title: String, ID: UUID, ParentWidth: CGFloat)
    {
        self.ParentWidth = ParentWidth
        CellID = ID
        CellTitle = Title
        DrawUI(WithWidth: ParentWidth)
    }

    public var ParentWidth: CGFloat!
    public var CellID: UUID!
    public var CellTitle: String!
}
