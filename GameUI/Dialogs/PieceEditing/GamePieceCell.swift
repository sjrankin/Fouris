//
//  GamePieceCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/4/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Game piece selection cell. Holds pieces to be selected.
class GamePieceCell: UITableViewCell
{
    /// Holds the height of all `GamePieceCell`s.
    public static let CellHeight: CGFloat = 60.0
    /// Width of the piece image.
    public static let ImageWidth: CGFloat = 50.0
    /// Height of the piece image.
    public static let ImageHeight: CGFloat = 50.0
    
    /// Required initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
    /// Initializer. Create the UI.
    /// - Parameter style: Table view cell style.
    /// - Parameter reuseIdentifier: Identifier for caching and reusing table view cells.
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        PieceView = UIImageView(frame: CGRect(x: 5, y: 5, width: GamePieceCell.ImageWidth, height: GamePieceCell.ImageHeight))
        PieceView.contentMode = .scaleAspectFit
        contentView.addSubview(PieceView)
        PieceLabel = UILabel(frame: CGRect(x: 65, y: 20, width: 200, height: 20))
        PieceLabel.font = UIFont.systemFont(ofSize: 20.0)
        contentView.addSubview(PieceLabel)
    }
    
    /// Holds the image in the cell view.
    private var PieceView: UIImageView!
    /// Holds the piece's name in the cell view.
    private var PieceLabel: UILabel!
    
    /// Load piece data into the view.
    /// - Parameter PieceImage: Image of the piece.
    /// - Parameter Name: Name of the piece.
    /// - Parameter ID: ID of the piece.
    public func LoadData(PieceImage: UIImage, Name: String, ID: UUID)
    {
        PieceLabel.text = Name
        PieceName = Name
        PieceID = ID
        PieceView.image = PieceImage
    }
    
    /// Holds the name of the piece.
    public var PieceName: String = ""
    /// Holds the ID of the piece.
    public var PieceID: UUID = UUID.Empty
}
