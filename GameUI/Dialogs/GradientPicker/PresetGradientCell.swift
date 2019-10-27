//
//  PresetGradientCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Holds information on a preset gradient for display as a table view cell.
class PresetGradientCell: UITableViewCell
{
    /// Get the height of each cell.
    public static let CellHeight: CGFloat = 80.0
    
    /// Required initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Initializer. Sets up the UI.
    /// - Parameter style: The table view cell style.
    /// - Parameter reuseIdentifier: ID of the cell for resuing table view cells.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        SampleView = UIView(frame: CGRect(x: 10, y: 5, width: 150, height: 70))
        SampleView.layer.borderColor = UIColor.black.cgColor
        SampleView.layer.borderWidth = 0.5
        SampleView.layer.cornerRadius = 5.0
        SampleView.clipsToBounds = true
        SampleView.isOpaque = false
        contentView.addSubview(SampleView)
        
        CheckerLayer = CALayer()
        let CheckerImage = UIImage(named: "Checkerboard1024")?.cgImage
        CheckerLayer.frame = SampleView.bounds
        CheckerLayer.contents = CheckerImage
        CheckerLayer.zPosition = -200
        CheckerLayer.contentsGravity = CALayerContentsGravity.topLeft
        SampleView.layer.addSublayer(CheckerLayer)
        
        GradientNameLabel = UILabel(frame: CGRect(x: 170, y: 20, width: 200, height: 30))
        GradientNameLabel.font = UIFont(name: "Avenir", size: 24.0)
        contentView.addSubview(GradientNameLabel)
    }
    
    /// The sample gradient view.
    public var SampleView: UIView!
    /// The checkerboard layer view for transparent colors.
    public var CheckerLayer: CALayer!
    /// The gradient layer.
    public var SampleGradient: CAGradientLayer!
    /// The gradient name label.
    public var GradientNameLabel: UILabel!
    /// The gradient name.
    public var GradientName: String = ""
    /// The gradient definition.
    public var GradientDefinition: String = ""
    
    /// Loads data on a specific gradient to display.
    /// - Parameter CellData: Tuple with the gradient name and definition.
    /// - Parameter Vertical: The vertical flag.
    public func LoadData(_ CellData: (String, String), Vertical: Bool)
    {
        GradientName = CellData.0
        GradientDefinition = CellData.1
        GradientNameLabel.text = GradientName
        SampleGradient = GradientManager.CreateGradientLayer(From: GradientDefinition, WithFrame: SampleView.bounds,
                                                             IsVertical: Vertical)
        SampleGradient.zPosition = -100
        SampleView.layer.addSublayer(SampleGradient)
    }
}
