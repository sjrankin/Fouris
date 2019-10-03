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
        GameTypeSegment.selectedSegmentIndex = 0
        PopulateTable(WithUser: true)
    }
    
    var StatData = [(String, Double?, Int?, String?)]()
    //Cubic isn't supported yet.
    let StatIndex =
        [
            BaseGameTypes.Standard: 0,
            BaseGameTypes.Rotating4: 1
    ]
    
    var CurrentGameTypeView: BaseGameTypes = .Standard
    
    func PopulateTable(WithUser: Bool)
    {
        StatData.removeAll()
        let Statistics = WithUser ? HistoryManager.GameHistory : HistoryManager.AIGameHistory
        for (GameType, _) in StatIndex
        {
            if GameType != CurrentGameTypeView
            {
                continue
            }
            StatData = [(String, Double?, Int?, String?)]()
            let GameCount: Int = (Statistics?.Games![GameType]!.GameCount)!
            let CumulativeScore: Int = (Statistics?.Games![GameType]!.CumulativeScore)!
            let CumulativeDuration: Int = (Statistics?.Games![GameType]!.Duration)!
            let CumulativePieces: Int = (Statistics?.Games![GameType]!.CumulativePieces)!
            StatData.append(("High Score", nil, (Statistics?.Games![GameType]!.HighScore)!, nil))
            StatData.append(("Game Count", nil, GameCount, nil))
            StatData.append(("Total Duration (seconds)", nil, CumulativeDuration, nil))
            StatData.append(("Total Completed Pieces", nil, CumulativePieces, nil))
            StatData.append(("Cumulative Score", nil, CumulativeScore, nil))
            if GameCount > 0
            {
                let PointsPerGame: Double = Double(CumulativeScore) / Double(GameCount)
                StatData.append(("Points per Game", PointsPerGame, nil, nil))
                let MeanGameTime: Double = Double(CumulativeDuration) / Double(GameCount)
                StatData.append(("Mean Game Duration (seconds)", MeanGameTime, nil, nil))
                let MeanGamePiece: Double = Double(CumulativePieces) / Double(GameCount)
                StatData.append(("Mean Pieces per Game", MeanGamePiece, nil, nil))
            }
            else
            {
                StatData.append(("Points per Game", nil, nil, "TBD"))
                StatData.append(("Mean Game Duration (seconds)", nil, nil, "TBD"))
                StatData.append(("Mean Pieces per Game", nil, nil, "TBD"))
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return StatData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let Cell = StatViewerTableCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "StatCell")
        let (Title, DValue, IValue, SValue) = StatData[indexPath.row]
        Cell.LoadData(Title: Title, DoubleValue: DValue, IntValue: IValue, StringValue: SValue,
                      ParentWidth: StatTable.bounds.size.width)
        return Cell
    }
    
    @IBAction func HandleStatSourceChanged(_ sender: Any)
    {
        PopulateTable(WithUser: ShowSegments.selectedSegmentIndex == 0)
        StatTable.reloadData()
    }
    
    @IBAction func HandleGameTypeChanged(_ sender: Any)
    {
        if GameTypeSegment.selectedSegmentIndex == 0
        {
            CurrentGameTypeView = .Standard
        }
        else
        {
            CurrentGameTypeView = .Rotating4
        }
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
        self.present(Alert, animated: true)
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
    @IBOutlet weak var GameTypeSegment: UISegmentedControl!
}
