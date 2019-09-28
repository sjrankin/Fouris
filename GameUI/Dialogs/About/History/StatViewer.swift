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
    
    var StatData = [BaseGameTypes: [(String, Double?, Int?, String?)]]()
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
            var SData = [(String, Double?, Int?, String?)]()
            let GameCount: Int = (Statistics?.GetGameCount(For: GameType))!
            let CumulativeScore: Int = (Statistics?.GetCumulativeScore(For: GameType))!
            let CumulativeDuration: Int = (Statistics?.GetTotalGameSeconds(For: GameType))!
            let CumulativePieces: Int = (Statistics?.GetTotalPieceCount(For: GameType))!
            SData.append(("High Score", nil, Statistics?.GetHighScore(For: GameType), nil))
            SData.append(("Game Starts", nil, GameCount, nil))
            SData.append(("Total Duration (seconds)", nil, CumulativeDuration, nil))
            SData.append(("Total Completed Pieces", nil, CumulativePieces, nil))
            SData.append(("Cumulative Score", nil, CumulativeScore, nil))
            if GameCount > 0
            {
                let PointsPerGame: Double = Double(CumulativeScore) / Double(GameCount)
                SData.append(("Points per Game", PointsPerGame, nil, nil))
                let MeanGameTime: Double = Double(CumulativeDuration) / Double(GameCount)
                SData.append(("Mean Game Duration (seconds)", MeanGameTime, nil, nil))
                let MeanGamePiece: Double = Double(CumulativePieces) / Double(GameCount)
                SData.append(("Mean Pieces per Game", MeanGamePiece, nil, nil))
            }
            else
            {
                SData.append(("Points per Game", nil, nil, "TBD"))
                SData.append(("Mean Game Duration (seconds)", nil, nil, "TBD"))
                SData.append(("Mean Pieces per Game", nil, nil, "TBD"))
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
                let (Title, DValue, IValue, SValue) = StatData[GameType]![indexPath.row]
                Cell.LoadData(Title: Title, DoubleValue: DValue, IntValue: IValue, StringValue: SValue,
                              ParentWidth: StatTable.bounds.size.width)
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