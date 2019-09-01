//
//  RecentColorCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class RecentColorCell: UITableViewCell
{
    public static let CellHeight: CGFloat = 50.0
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        ColorSample = UIView()
        ColorSample.frame = CGRect(x: 10, y: 4, width: 80, height: 42)
        ColorSample.layer.borderColor = UIColor.black.cgColor
        ColorSample.layer.borderWidth = 0.5
        ColorSample.layer.cornerRadius = 5.0
        ColorSample.backgroundColor = UIColor.purple
        ColorSample.clipsToBounds = true
        let CheckerLayer = CALayer()
        let CheckerImage = UIImage(named: "Checkerboard1024")?.cgImage
        CheckerLayer.frame = ColorSample.bounds
        CheckerLayer.contents = CheckerImage
        CheckerLayer.zPosition = -100
        ColorSample.layer.addSublayer(CheckerLayer)
        ColorSample.layer.contentsGravity = CALayerContentsGravity.topLeft
        contentView.addSubview(ColorSample)
        
        ColorValue = UILabel()
        ColorValue.frame = CGRect(x: 100, y: 25, width: 40, height: 30)
        contentView.addSubview(ColorValue)
        
        ColorName = UILabel()
        ColorName.frame = CGRect(x: 150, y: 25, width: 100, height: 30)
        contentView.addSubview(ColorName)
    }
    
    var ColorSample: UIView!
    var ColorValue: UILabel!
    var ColorName: UILabel!
    
    public func LoadData(Color: UIColor, Name: String, Value: String, Width: CGFloat)
    {
        CellColorName = Name
        CellColor = Color
        print("Parent width: Width")
        ColorSample.backgroundColor = Color
        ColorName.text = Name
        ColorValue.text = Value
    }
    
    public var CellColorName: String? = nil
    public var CellColor: UIColor? = nil
}
