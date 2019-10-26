//
//  RecentColorCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/1/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Table view cell for the recent color list UI.
class RecentColorCell: UITableViewCell
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
    /// - Parameter style: Style of the cell.
    /// - Parameter reuseIdentifier: Identifier for reusing table cell views.
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
    
    /// The color sample view.
    public var ColorSample: UIView!
    /// The color value view.
    public var ColorValue: UILabel!
    /// The color name view.
    public var ColorName: UILabel!
    
    /// Load the cell with data to display.
    /// - Parameter Color: The color to display.
    /// - Parameter Name: The color name.
    /// - Parameter Value: The color's numeric value.
    /// - Parameter Width: The width of the table.
    public func LoadData(Color: UIColor, Name: String, Value: String, Width: CGFloat)
    {
        CellColorName = Name
        CellColor = Color
        print("Parent width: Width")
        ColorSample.backgroundColor = Color
        ColorName.text = Name
        ColorValue.text = Value
    }
    
    /// The name of the color.
    public var CellColorName: String? = nil
    /// The color.
    public var CellColor: UIColor? = nil
}
