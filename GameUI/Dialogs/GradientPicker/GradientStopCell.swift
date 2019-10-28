//
//  GradientStopCell.swift
//  Fouris
//  Adapted from BumpCamera.
//
//  Created by Stuart Rankin on 9/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// UI for a table view cell for a color stop for a gradient.
class GradientStopCell: UITableViewCell
{
    /// Cell height.
    public static var CellHeight: CGFloat = 50.0
    
    /// Required initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
    }
    
    /// Color sample view.
    private var ColorSample: UIView!
    /// Location label.
    private var LocationLabel: UILabel!
    
    /// Initializer. Sets up the UI.
    /// - Parameter style: Style of the table view cell.
    /// - Parameter reuseIdentifier: Identifier for table view cell reuse and caching.
    override init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
        
        let CurrentWidth = UIScreen.main.bounds.width
        
        let ColorRect = CGRect(x: 15, y: 5, width: CurrentWidth * 0.4, height: GradientStopCell.CellHeight - 10.0)
        ColorSample = UIView(frame: ColorRect)
        ColorSample.layer.cornerRadius = 5.0
        ColorSample.layer.borderWidth = 0.5
        ColorSample.layer.borderColor = UIColor.black.cgColor
        contentView.addSubview(ColorSample)
        
        let LabelRect = CGRect(x: CurrentWidth * 0.55, y: 10, width: 80.0, height: 30.0)
        LocationLabel = UILabel(frame: LabelRect)
        LocationLabel.textAlignment = .left
        LocationLabel.font = UIFont(name: "Courier", size: 22.0)
        contentView.addSubview(LocationLabel)
        
        self.accessoryType = .disclosureIndicator
        self.selectionStyle = .none
    }
    
    /// Initializes the table view cell with a color stop.
    /// - Parameter StopColor: The color for the color stop.
    /// - Parameter StopLocation: The (normalized) location of the color stop.
    public func SetData(StopColor: UIColor, StopLocation: Double)
    {
        ColorSample.backgroundColor = StopColor
        LocationLabel.text = "\(StopLocation.Round(To: 3))"
        _CellColor = StopColor
        _CellLocation = StopLocation
    }
    
    /// The color of the color stop.
    private var _CellColor = UIColor.black
    /// The location of the color stop.
    private var _CellLocation: Double = 0.0
    
    /// Returns the data in the cell.
    /// - Returns: Tuple of the color and the location.
    func CellData() -> (UIColor, Double)
    {
        return (_CellColor, _CellLocation)
    }
}
