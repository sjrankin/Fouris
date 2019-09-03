//
//  PresetGradientCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PresetGradientCell: UITableViewCell
{
    public static let CellHeight: CGFloat = 80.0
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
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
    
    public var SampleView: UIView!
    public var CheckerLayer: CALayer!
    public var SampleGradient: CAGradientLayer!
    public var GradientNameLabel: UILabel!
    public var GradientName: String = ""
    public var GradientDefinition: String = ""
    
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
