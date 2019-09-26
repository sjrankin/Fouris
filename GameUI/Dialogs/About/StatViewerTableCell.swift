//
//  StatViewerTableCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class StatViewerTableCell: UITableViewCell
{
    public static let CellHeight: CGFloat = 50.0
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    func PopulateUI(_ Width: CGFloat)
    {
        let TitleWidth = Width * 0.6
        let NumberWidth = Width * 0.4
        TitleLabel = UILabel(frame: CGRect(x: 10, y: 5, width: TitleWidth - 10, height: 40))
        TitleLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.bold)
        contentView.addSubview(TitleLabel)
        NumberValue = UILabel(frame: CGRect(x: TitleWidth + 10, y: 5,
                                            width: NumberWidth - 20, height: 40))
        NumberValue.textAlignment = .right
        NumberValue.font = UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.bold)
        NumberValue.textColor = ColorServer.ColorFrom(ColorNames.PrussianBlue)
        contentView.addSubview(NumberValue)
    }
    
    var TitleLabel: UILabel!
    var NumberValue: UILabel!
    
    public func LoadData(Title: String, DoubleValue: Double? = nil, IntValue: Int? = nil,
                         ParentWidth: CGFloat)
    {
        selectionStyle = .none
        PopulateUI(ParentWidth)
        TitleLabel.text = Title
        if let DVal = DoubleValue
        {
            NumberValue.text = "\(Utility.Round(DVal, ToPlaces: 3))"
        }
        if let IVal = IntValue
        {
            NumberValue.text = "\(IVal)"
        }
    }
}
