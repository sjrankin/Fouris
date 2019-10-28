//
//  GameStyleTableViewCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Table view cell class for displaying game types for the purpose of selection.
class GameStyleTableViewCell: UITableViewCell
{
    /// The height of th cell.
    public static let CellHeight: CGFloat = 150.0
    /// Game image width.
    public let ImageWidth: CGFloat = 120.0
    /// Game image height.
    public let ImageHeight: CGFloat = 120.0
    
    /// Required initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Initializer. Create the UI.
    /// - Parameter style: Table view cell style.
    /// - Parameter reuseIdentifier. Identifier to use for caching table view cells.
    override init(style Style: UITableViewCell.CellStyle, reuseIdentifier ReuseIdentifier: String?)
    {
        super.init(style: Style, reuseIdentifier: ReuseIdentifier)
        GameTitle = UILabel(frame: CGRect(x: 160, y: (GameStyleTableViewCell.CellHeight / 2) - 10, width: 300, height: 30))
        GameTitle.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.medium)
        GameTitle.textAlignment = .left
        GameTitle.text = "Game Title"
        contentView.addSubview(GameTitle)
        GameImage = UIImageView(frame: CGRect(x: 20, y: 15, width: ImageWidth, height: ImageHeight))
        GameImage.image = nil
        contentView.addSubview(GameImage)
        MakeSelectionLayer()
    }
    
    /// Create a selection layer to indicate game style selection.
    /// - Note: This is needed because we want to give the user a chance to change his mind.
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
    
    /// Holds the selection layer.
    private var BorderLayer: CAShapeLayer!
    /// Holds the game image.
    private var GameImage: UIImageView!
    /// Holds the game title.
    private var GameTitle: UILabel!
    
    /// Initialize the contents of the table view cell.
    /// - Parameter Title: The title of the game.
    /// - Parameter Image: The game image. If nil is passed, no image is displayed
    /// - Parameter BucketShape: The internal bucket shape identifier.
    public func Initialize(Title: String, Image: UIImage?, BucketShape: BucketShapes)
    {
        GameTitle.text = Title
        if let ResizeMe = Image
        {
            GameImage.image = ResizeImage(ResizeMe)
        }
        GameShape = BucketShape
    }
    
    /// Resize the passed image to the expected size. See `ImageWidth` and `ImageHeight`.
    /// - SeeAlso: `ImageWidth`, `ImageHeight`.
    /// - Parameter Image: The image to resize.
    /// - Returns: Resized image.
    private func ResizeImage(_ Image: UIImage) -> UIImage
    {
        UIGraphicsBeginImageContext(CGSize(width: ImageWidth, height: ImageHeight))
        Image.draw(in: CGRect(x: 0, y: 0, width: ImageWidth, height: ImageHeight))
        let Resized = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Resized!
    }
    
    /// Holds the game shape.
    private var GameShape: BucketShapes = BucketShapes.Empty
    
    /// Returns the title of the cell.
    public func GetTitle() -> String
    {
        return GameTitle.text!
    }
    
    /// Show the selection state of the cell.
    /// - Note: Selection is controlled by the main game selection UI - we just respond to what they tell us to do.
    /// - Parameter AsSelected: Determines the selection state.
    private func ShowAsSelected(_ AsSelected: Bool)
    {
        BorderLayer.strokeColor = AsSelected ? UIColor.yellow.cgColor : UIColor.clear.cgColor
    }
    
    /// Holds the selection status.
    private var _IsSelected: Bool = false
    {
        didSet
        {
            ShowAsSelected(_IsSelected)
        }
    }
    /// Get or set the selection status.
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
