//
//  GameStyleTableViewCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GameStyleTableViewCell: UITableViewCell
{
    public static let CellHeight: CGFloat = 150.0
    let ImageWidth: CGFloat = 120.0
    let ImageHeight: CGFloat = 120.0
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    override init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
        GameTitle = UILabel(frame: CGRect(x: 160, y: GameStyleTableViewCell.CellHeight / 2, width: 300, height: 20))
        GameTitle.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.medium)
        GameTitle.textAlignment = .left
        GameTitle.text = "Game Title"
        contentView.addSubview(GameTitle)
        GameImage = UIImageView(frame: CGRect(x: 20, y: 15, width: ImageWidth, height: ImageHeight))
        GameImage.image = nil
        contentView.addSubview(GameImage)
        MakeSelectionLayer()
    }
    
    private func MakeSelectionLayer()
    {
        BorderLayer = CAShapeLayer()
        BorderLayer.strokeColor = UIColor.red.cgColor
        BorderLayer.lineWidth = 2.0
        BorderLayer.lineDashPattern = [2, 2]
        BorderLayer.frame = self.bounds
        BorderLayer.fillColor = nil
        BorderLayer.path = UIBezierPath(rect: self.bounds).cgPath
        BorderLayer.strokeColor = UIColor.clear.cgColor
        contentView.layer.addSublayer(BorderLayer)
    }
    
    var BorderLayer: CAShapeLayer!
    var GameImage: UIImageView!
    var GameTitle: UILabel!
    
    public func Initialize(Title: String, Image: UIImage, BucketShape: BucketShapes)
    {
        GameTitle.text = Title
        GameImage.image = ResizeImage(Image)
        GameShape = BucketShape
    }
    
    private func ResizeImage(_ Image: UIImage) -> UIImage
    {
        UIGraphicsBeginImageContext(CGSize(width: ImageWidth, height: ImageHeight))
        Image.draw(in: CGRect(x: 0, y: 0, width: ImageWidth, height: ImageHeight))
        let Resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Resized!
    }
    
    var GameShape: BucketShapes = BucketShapes.Empty
    
    func GetTitle() -> String
{
    return GameTitle.text!
    }
    
    private func ShowAsSelected(_ AsSelected: Bool)
    {
        BorderLayer.strokeColor = AsSelected ? UIColor.yellow.cgColor : UIColor.clear.cgColor
    }
    
    private var _IsSelected: Bool = false
    {
        didSet
        {
            ShowAsSelected(_IsSelected)
        }
    }
    public var IsSelected: Bool
    {
        get
        {
            return _IsSelected
        }
        set
        {
            _IsSelected = newValue
        }
    }
}
