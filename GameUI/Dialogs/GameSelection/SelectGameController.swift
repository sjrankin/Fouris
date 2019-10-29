//
//  SelectGameController.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Code to run the game selection UI.
class SelectGameController: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    /// Delegate that will receive messages.
    public weak var SelectorDelegate: GameSelectorProtocol? = nil
    
    /// Initialize the UI.
    override public func viewDidLoad()
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
    
    /// Initialize the tables.
    private func InitializeTables()
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
        RotatingGames.append(("Medium Central Block", "Square", .MediumSquare))
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
        RotatingGames.append(("Spanning Diagonal", "SpanningDiagonal", .SpanningDiagonal))
        RotatingGames.append(("Empty Center", "EmptyCenter", .EmptyCenter))
        RotatingGames.append(("Perpendicular Lines", "PerpendicularLines", .PerpendicularLines))
        RotatingGames.append(("Alternating Lines", "AlternatingDirections", .AlternatingDirections))
        RotatingGames.append(("Empty", "Empty", .Empty))
        RotatingGames.append(("Inside Out", "InsideOut", .InsideOut))
        
        SemiRotatingGames.append(("One Opening with rotating pieces", "OneOpening", .OneOpening))
        
        CubicGames.append(("Simple 3D", "", .Simple3D))
    }
    
    /// Returns the height of each table view cell.
    /// - Parameter tableView: Not used.
    /// - Parameter heightForRowAt: Not used.
    /// - Returns: The height of each row in the table.
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return GameStyleTableViewCell.CellHeight
    }
    
    /// Returns the section title for various game types.
    /// - Parameter tableView: Not used.
    /// - Parameter titleForHeaderInSection: Determines the section title to return.
    /// - Returns: Title for the specified section.
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String?
    {
        switch section
        {
            case 2:
                return "Standard"
            
            case 0:
                return "Rotating"
            
            case 1:
                return "Semi-Rotating"
            
            case 3:
                return "Cubic"
            
            default:
                return ""
        }
    }
    
    /// Returns the number of sections in the table.
    /// - Parameter tableView: Not used.
    /// - Returns: The number of sections in the table.
    public func numberOfSections(in tableView: UITableView) -> Int
    {
        return 4
    }
    
    /// Returns the number of rows in each section.
    /// - Parameter tableView: Not used.
    /// - Parameter numberOfRowsInSection: The section whose number of rows will be returned.
    /// - Returns: Number of rows in the specified section.
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch section
        {
            case 2:
                return StandardGames.count
            
            case 0:
                return RotatingGames.count
            
            case 1:
                return SemiRotatingGames.count
            
            case 3:
                return CubicGames.count
            
            default:
                return 0
        }
    }
    
    /// Returns a populated table view cell.
    /// - Parameter tableView: Not used.
    /// - Parameter cellForRowAt: The index and section of the cell to return.
    /// - Returns: Populated table view cell.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var Title: String = ""
        var ImageName: String = ""
        var BucketType: BucketShapes = .Classic
        switch indexPath.section
        {
            case 2:
                let (STitle, SImageName, SBucketType) = StandardGames[indexPath.row]
                Title = STitle
                ImageName = SImageName
                BucketType = SBucketType
            
            case 0:
                let (STitle, SImageName, SBucketType) = RotatingGames[indexPath.row]
                Title = STitle
                ImageName = SImageName
                BucketType = SBucketType
            
            case 1:
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
        
        var FinalImage: UIImage? = nil
        if ImageName.isEmpty
        {
            FinalImage = UIImage(named: "Printing")!
        }
        else
        {
            FinalImage = UIImage(named: ImageName)!
        }
        let Cell = GameStyleTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "StyleCell")
        Cell.Initialize(Title: Title, Image: FinalImage, BucketShape: BucketType)
        return Cell
    }
    
    /// Holds the selected game.
    private var SelectedGameType: UUID = UUID.Empty
    /// The last selected item.
    private var LastSelectedItem: Int = -1
    
    /// Table of standard games.
    private var StandardGames = [(String, String, BucketShapes)]()
    /// Table of rotating games.
    private var RotatingGames = [(String, String, BucketShapes)]()
    /// Table of semi-rotating games.
    private var SemiRotatingGames = [(String, String, BucketShapes)]()
    /// Table of cubic games.
    private var CubicGames = [(String, String, BucketShapes)]()
    
    /// Handle the OK button pressed. Send the new game type to the caller.
    /// - Warning: A fatal error is generated if an unexpected section is returned.
    /// - Parameter sender: Not used.
    @IBAction public func HandleOKPressed(_ sender: Any)
    {
        if let Index = GameStyleTableView.indexPathForSelectedRow
        {
            print("Selected game index: section: \(Index.section), row: \(Index.row)")
            var NewShape = BucketShapes.Classic
            switch Index.section
            {
                case 2:
                    NewShape = StandardGames[Index.row].2
                
                case 0:
                    NewShape = RotatingGames[Index.row].2
                
                case 1:
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
    
    /// Handle the cancel button pressed.
    /// - Parameger sender: Not used.
    @IBAction public func HandleCancelPressed(_ sender: Any)
    {
        SelectorDelegate?.GameTypeChanged(DidChange: false, NewGameShape: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var GameStyleTableView: UITableView!
}


