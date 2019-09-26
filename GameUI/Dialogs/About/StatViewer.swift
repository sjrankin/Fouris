//
//  StatViewer.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class StatViewer: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        StatTable.layer.borderColor = UIColor.black.cgColor
        ShowSegments.selectedSegmentIndex = 0
        PopulateTable(WithUser: true)
    }
    
    var StatData = [BaseGameTypes: [(String, Double?, Int?)]]()
    //Cubic isn't supported yet.
    let StatIndex =
        [
            BaseGameTypes.Standard: 0,
            BaseGameTypes.Rotating4: 1
    ]
    let StatGameNames =
        [
            BaseGameTypes.Standard: "Standard Game",
            BaseGameTypes.Rotating4: "Rotating Game"
    ]
    
    func PopulateTable(WithUser: Bool)
    {
        StatData.removeAll()
        let Statistics = WithUser ? HistoryManager.GameRunHistory : HistoryManager.AIGameRunHistory
        for (GameType, _) in StatIndex
        {
            var SData = [(String, Double?, Int?)]()
            SData.append(("High Score", nil, Statistics?.GetHighScore(For: GameType)))
            SData.append(("Game Starts", nil, Statistics?.GetGameCount(For: GameType)))
            SData.append(("Total Duration (seconds)", nil, Statistics?.GetTotalGameSeconds(For: GameType)))
            SData.append(("Total completed pieces", nil, Statistics?.GetTotalPieceCount(For: GameType)))
            SData.append(("Cumulative score", nil, Statistics?.GetCumulativeScore(For: GameType)))
            if (Statistics?.GetGameCount(For: GameType))! > 0
            {
                let PointsPerGame: Double = Double((Statistics?.GetCumulativeScore(For: GameType))!) / Double((Statistics?.GetGameCount(For: GameType))!)
                SData.append(("Points per Game", PointsPerGame,nil))
                let MeanGameTime: Double = Double((Statistics?.GetTotalGameSeconds(For: GameType))!) / Double((Statistics?.GetGameCount(For: GameType))!)
                SData.append(("Mean Game Duration (seconds)", MeanGameTime, nil))
            }
            StatData[GameType] = SData
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        for (GameType, Index) in StatIndex
        {
            if Index == section
            {
                return StatData[GameType]!.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = StatViewerTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "StatCell")
        for (GameType, Index) in StatIndex
        {
            if Index == indexPath.section
            {
                let (Title, DValue, IValue) = StatData[GameType]![indexPath.row]
                Cell.LoadData(Title: Title, DoubleValue: DValue, IntValue: IValue, ParentWidth: StatTable.bounds.size.width)
            }
        }
        return Cell
    }
    
    @IBAction func HandleStatSourceChanged(_ sender: Any)
    {
        PopulateTable(WithUser: ShowSegments.selectedSegmentIndex == 0)
        StatTable.reloadData()
    }
    
    @IBAction func HandleResetPressed(_ sender: Any)
    {
        let Alert = UIAlertController(title: "Reset Statistics",
                                      message: "Really reset your statistics? All values, including high scores, will be reset to 0.",
                                      preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Reset", style: UIAlertAction.Style.destructive, handler: HandleReset))
        Alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil))
    }
    
    @objc func HandleReset(Action: UIAlertAction)
    {
        
    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var StatTable: UITableView!
    @IBOutlet weak var ShowSegments: UISegmentedControl!
}
