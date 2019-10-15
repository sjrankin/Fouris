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
        BaseGameSegment.selectedSegmentIndex = 0
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
        RotatingGames.append(("Corner Dots", "", .CornerDots))
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
        
        CubicGames.removeAll()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return GameStyleTableViewCell.CellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        let BaseGameIndex = BaseGameSegment.selectedSegmentIndex
        switch BaseGameIndex
        {
            case 0:
                return StandardGames.count
            
            case 1:
                return RotatingGames.count
            
            case 2:
                return CubicGames.count
            
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let BaseGameIndex = BaseGameSegment.selectedSegmentIndex
        switch BaseGameIndex
        {
            case 0:
                let Cell = GameStyleTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "StyleCell")
                let (Title, ImageName, SubType) = StandardGames[indexPath.row]
                Cell.Initialize(Title: Title, Image: UIImage(named: ImageName)!, SubType: SubType)
                return Cell
            
            case 1:
                let Cell = GameStyleTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "StyleCell")
                let (Title, ImageName, SubType) = RotatingGames[indexPath.row]
                if ImageName.isEmpty
                {
                    print("Found empty game type at \(indexPath.row)")
                    return Cell
                }
                Cell.Initialize(Title: Title, Image: UIImage(named: ImageName)!, SubType: SubType)
                return Cell
            
            case 2:
                return UITableViewCell()
            
            default:
                return UITableViewCell()
        }
    }
    
    var SelectedGameType: UUID = UUID.Empty
    var LastSelectedItem: Int = -1
    
    var StandardGames = [(String, String, CenterShapes)]()
    var RotatingGames = [(String, String, CenterShapes)]()
    var CubicGames = [(String, String, CenterShapes)]()
    
    @IBAction func HandleBaseGameChanged(_ sender: Any)
    {
        LastSelectedItem = -1
        SelectedGameType = UUID.Empty
        GameStyleTableView.reloadData()
    }
    
    @IBOutlet weak var BaseGameSegment: UISegmentedControl!
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        let BaseGame: BaseGameTypes = BaseGameSegment.selectedSegmentIndex == 0 ? .Standard : .Rotating4
        SelectorDelegate?.GameTypeChanged(DidChange: true, NewBaseType: BaseGame, GameSubType: .MediumCentralBlock)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        SelectorDelegate?.GameTypeChanged(DidChange: false, NewBaseType: nil, GameSubType: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var GameStyleTableView: UITableView!
}


