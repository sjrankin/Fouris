//
//  GamePieceCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/4/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GamePieceCell: UITableViewCell
{
    public static let CellHeight: CGFloat = 60.0
    public static let ImageWidth: CGFloat = 50.0
    public static let ImageHeight: CGFloat = 50.0
    
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
    }
    
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
    
    var PieceView: UIImageView!
    var PieceLabel: UILabel!
    
    func LoadData(PieceImage: UIImage, Name: String, ID: UUID)
    {
        PieceLabel.text = Name
        PieceName = Name
        PieceID = ID
        PieceView.image = PieceImage
    }
    
    public var PieceName: String = ""
    public var PieceID: UUID = UUID.Empty
}
