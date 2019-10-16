//
//  SelectGameController.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SelectGameController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    weak var SelectorDelegate: GameSelectorProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        InitializeTables()
        GameStyleTableView.allowsMultipleSelection = false
        GameStyleTableView.allowsSelection = true
        GameStyleTableView.layer.borderColor = UIColor.black.cgColor
        GameStyleTableView.layer.borderWidth = 0.5
        GameStyleTableView.layer.cornerRadius = 5.0
        GameStyleTableView.delegate = self
        GameStyleTableView.dataSource = self
        GameStyleTableView.reloadData()
    }
    
    func InitializeTables()
    {
        StandardGames.append(("Classic", "Standard_Classic", .Classic))
        StandardGames.append(("Tall & Thin", "Standard_TallThin", .TallThin))
        StandardGames.append(("Short & Wide", "Standard_ShortWide", .ShortWide))
        StandardGames.append(("Big", "Standard_Big", .Big))
        StandardGames.append(("Small", "Standard_Small", .Small))
        StandardGames.append(("Square", "", .SquareBucket))
        StandardGames.append(("Giant", "Giant", .Giant))
        
        RotatingGames.append(("Center Dot", "Dot", .Dot))
        RotatingGames.append(("Small Central Block", "SmallSquare", .SmallSquare))
        RotatingGames.append(("Medium Central Block", "Square", .Square))
        RotatingGames.append(("Large Central Block", "BigSquare", .BigSquare))
        RotatingGames.append(("Four Small Squares", "FourSmallSquares", .FourSmallSquares))
        RotatingGames.append(("Small Central Rectangel", "SmallRectangle", .SmallRectangle))
        RotatingGames.append(("Medium Central Rectangle", "Rectangle", .Rectangle))
        RotatingGames.append(("Large Central Rectangle", "BigRectangle", .BigRectangle))
        RotatingGames.append(("Small Central Diamond", "SmallDiamond", .SmallDiamond))
        RotatingGames.append(("Medium Central Diamond", "Diamond", .Diamond))
        RotatingGames.append(("Large Central Diamond", "BigDiamond", .BigDiamond))
        RotatingGames.append(("Corner Brackets", "Corners", .Corners))
        RotatingGames.append(("Corner Dots", "CornerDots", .CornerDots))
        RotatingGames.append(("4 Central Brackets", "Bracket4", .Bracket4))
        RotatingGames.append(("2 Central Brackets", "Bracket2", .Bracket2))
        RotatingGames.append(("Diagonal Lines", "ShortDiagonals", .ShortDiagonals))
        RotatingGames.append(("Long Diagonal Lines", "LongDiagonals", .LongDiagonals))
        RotatingGames.append(("Four Border Lines", "FourLines", .FourLines))
        RotatingGames.append(("Parallel Lines", "ParallelLines", .ParallelLines))
        RotatingGames.append(("Horizontal Line", "HorizontalLine", .HorizontalLine))
        RotatingGames.append(("Two Perpendicular Lines", "Quadrant", .Quadrant))
        RotatingGames.append(("Central Plus", "Plus", .Plus))
        RotatingGames.append(("Empty", "Empty", .Empty))
        
        SemiRotatingGames.append(("One Opening with rotating pieces", "OneOpening", .OneOpening))
        
        CubicGames.removeAll()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return GameStyleTableViewCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section
        {
            case 0:
                return "Standard"
            
            case 1:
                return "Rotating"
            
            case 2:
                return "Semi-Rotating"
            
            case 3:
                return "Cubic"
            
            default:
                return ""
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
            case 0:
                return StandardGames.count
            
            case 1:
                return RotatingGames.count
            
            case 2:
                return SemiRotatingGames.count
            
            case 3:
                return CubicGames.count
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var Title: String = ""
        var ImageName: String = ""
        var BucketType: BucketShapes = .Classic
        switch indexPath.section
        {
            case 0:
                let (STitle, SImageName, SBucketType) = StandardGames[indexPath.row]
                Title = STitle
                ImageName = SImageName
                BucketType = SBucketType
            
            case 1:
                let (STitle, SImageName, SBucketType) = RotatingGames[indexPath.row]
                Title = STitle
                ImageName = SImageName
                BucketType = SBucketType
            
            case 2:
                let (STitle, SImageName, SBucketType) = SemiRotatingGames[indexPath.row]
                Title = STitle
                ImageName = SImageName
                BucketType = SBucketType
            
            case 3:
                let (STitle, SImageName, SBucketType) = CubicGames[indexPath.row]
                Title = STitle
                ImageName = SImageName
                BucketType = SBucketType
            
            default:
                fatalError("Unexpected section encountered: \(indexPath.section)")
            
        }
        
        if ImageName.isEmpty
        {
            return UITableViewCell()
        }
        let Cell = GameStyleTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "StyleCell")
        Cell.Initialize(Title: Title, Image: UIImage(named: ImageName)!, BucketShape: BucketType)
        return Cell
    }
    
    var SelectedGameType: UUID = UUID.Empty
    var LastSelectedItem: Int = -1
    
    var StandardGames = [(String, String, BucketShapes)]()
    var RotatingGames = [(String, String, BucketShapes)]()
    var SemiRotatingGames = [(String, String, BucketShapes)]()
    var CubicGames = [(String, String, BucketShapes)]()
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        if let Index = GameStyleTableView.indexPathForSelectedRow
        {
            var NewShape = BucketShapes.Classic
            switch Index.section
            {
                case 0:
                    NewShape = StandardGames[Index.row].2
                
                case 1:
                    NewShape = RotatingGames[Index.row].2
                
                case 2:
                    NewShape = SemiRotatingGames[Index.row].2
                
                case 3:
                    NewShape = CubicGames[Index.row].2
                
                default:
                    fatalError("Unexpected section found in HandleOKPressed.")
            }
            SelectorDelegate?.GameTypeChanged(DidChange: true, NewGameShape: NewShape)
            self.dismiss(animated: true, completion: nil)
        }
        else
        {
            SelectorDelegate?.GameTypeChanged(DidChange: false, NewGameShape: nil)
        }
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        SelectorDelegate?.GameTypeChanged(DidChange: false, NewGameShape: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var GameStyleTableView: UITableView!
}


