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
        StandardGames.append(("Classic", "Standard_Classic", StandardGameMap[.Classic]!))
        StandardGames.append(("Tall & Thin", "Standard_TallThin", StandardGameMap[.TallThin]!))
        StandardGames.append(("Short & Wide", "Standard_ShortWide", StandardGameMap[.ShortWide]!))
        StandardGames.append(("Big", "Standard_Big", StandardGameMap[.Big]!))
        StandardGames.append(("Small", "Standard_Small", StandardGameMap[.Small]!))
        
        RotatingGames.append(("Small Central Block", "Rotating_SmallCentralBlock", RotatingGameMap[.SmallCentralBlock]!))
        RotatingGames.append(("Medium Central Block", "Rotating_MediumCentralBlock", RotatingGameMap[.MediumCentralBlock]!))
        RotatingGames.append(("Large Central Block", "Rotating_BigCentralBlock", RotatingGameMap[.BigCentralBlock]!))
        RotatingGames.append(("Small Central Diamond", "Rotating_SmallCentralDiamond", RotatingGameMap[.SmallDiamond]!))
        RotatingGames.append(("Medium Central Diamond", "Rotating_MediumCentralDiamond", RotatingGameMap[.MediumDiamond]!))
        RotatingGames.append(("Large Central Diamond", "Rotating_BigCentralDiamond", RotatingGameMap[.BigDiamond]!))
        RotatingGames.append(("Corner Blocks", "Rotating_Corners", RotatingGameMap[.Corners]!))
        RotatingGames.append(("4 Central Brackets", "Rotating_Brackets4", RotatingGameMap[.Brackets4]!))
        RotatingGames.append(("2 Central Brackets", "Rotating_Brackets2", RotatingGameMap[.Brackets2]!))
        RotatingGames.append(("Central X", "Rotating_X", RotatingGameMap[.X]!))
        RotatingGames.append(("Central Plus", "Rotating_Plus", RotatingGameMap[.Plus]!))
        RotatingGames.append(("Empty", "Rotating_Empty", RotatingGameMap[.Empty]!))
        
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
                let (Title, ImageName, ID) = StandardGames[indexPath.row]
                Cell.Initialize(Title: Title, Image: UIImage(named: ImageName)!, ID: ID)
                return Cell
            
            case 1:
                let Cell = GameStyleTableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "StyleCell")
                let (Title, ImageName, ID) = RotatingGames[indexPath.row]
                Cell.Initialize(Title: Title, Image: UIImage(named: ImageName)!, ID: ID)
                return Cell
            
            case 2:
                return UITableViewCell()
            
            default:
                return UITableViewCell()
        }
    }
    
    var SelectedGameType: UUID = UUID.Empty
    var LastSelectedItem: Int = -1
    
    var StandardGames = [(String, String, UUID)]()
    var RotatingGames = [(String, String, UUID)]()
    var CubicGames = [(String, String, UUID)]()
    
    @IBAction func HandleBaseGameChanged(_ sender: Any)
    {
        LastSelectedItem = -1
        SelectedGameType = UUID.Empty
        GameStyleTableView.reloadData()
    }
    
    @IBOutlet weak var BaseGameSegment: UISegmentedControl!
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var GameStyleTableView: UITableView!
    
    let StandardGameMap: [StandardGameStyles: UUID] =
        [
            .Classic: UUID(uuidString: "13a6257a-ba5f-4aa6-b011-8c99f1736bde")!,
            .TallThin: UUID(uuidString: "0dfbc476-d2e1-49c8-8c03-5959a674ca7f")!,
            .ShortWide: UUID(uuidString: "02072d6c-4d84-4878-ba5e-3004649f3e4a")!,
            .Big: UUID(uuidString: "e9a1ccba-de94-4584-8600-0a5c86dbf275")!,
            .Small: UUID(uuidString: "166654f6-64f9-49bc-aee0-56632bb09431")!,
    ]
    
    let RotatingGameMap: [RotatingGameStyles: UUID] =
        [
            .SmallCentralBlock: UUID(uuidString: "4786d6ef-3f29-465f-ba32-88fa54836753")!,
            .MediumCentralBlock: UUID(uuidString: "581f1b14-4bec-4d47-aacd-d46bb2b4d42c")!,
            .BigCentralBlock: UUID(uuidString: "01d32275-37a8-43e2-8b04-ced15d71d286")!,
            .Corners: UUID(uuidString: "9bf3a3aa-bfb3-44e9-9410-9421d3a68c5d")!,
            .Brackets4: UUID(uuidString: "41dab19c-9d0d-4cb6-ab9e-5624db54df0f")!,
            .Brackets2: UUID(uuidString: "dc07f7b9-4bb6-40a7-b8b0-daaba5bf69b4")!,
            .SmallDiamond: UUID(uuidString: "820c3ecc-31bd-48dc-ab10-76b51489c2e2")!,
            .MediumDiamond: UUID(uuidString: "a8b97d71-0eb9-4560-980a-a30d45dc65c0")!,
            .BigDiamond: UUID(uuidString: "2fc831a2-8855-453e-8dbe-aab7bd51ec2e")!,
            .X: UUID(uuidString: "8a408229-2dfe-4596-ab2b-3fe889f119aa")!,
            .Plus: UUID(uuidString: "693c6f68-d458-4bbb-a2a1-261f59e7ca4e")!,
            .Empty: UUID(uuidString: "745c2d24-481c-4624-81fe-51241be37c75")!,
    ]
}

enum StandardGameStyles
{
    case Classic
    case TallThin
    case ShortWide
    case Big
    case Small
}

enum RotatingGameStyles
{
    case SmallCentralBlock
    case MediumCentralBlock
    case BigCentralBlock
    case Corners
    case Brackets4
    case Brackets2
    case SmallDiamond
    case MediumDiamond
    case BigDiamond
    case X
    case Plus
    case Empty
}
