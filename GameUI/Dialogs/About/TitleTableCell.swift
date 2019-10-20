//
//  TitleTableCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class TitleTableCell: UITableViewCell
{
    public static let CellHeight: CGFloat = 50.0
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        TitleLabel = UILabel(frame: CGRect(x: 10, y: 5, width: 200, height: 40))
        contentView.addSubview(TitleLabel!)
        TitleLabel?.font = UIFont(name: "Futura", size: 18.0)
    }
    
    var TitleLabel: UILabel? = nil

    func Initialize(WithTitle: String, TableWidth: CGFloat)
    {
        TitleLabel?.frame = CGRect(x: 10, y: 5, width: TableWidth - 20, height: 40)
        TitleLabel?.text = WithTitle
        CellTitle = WithTitle
    }
    
    var CellTitle: String = ""
}
