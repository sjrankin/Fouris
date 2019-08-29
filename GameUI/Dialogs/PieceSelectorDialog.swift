//
//  PieceSelectorDialog.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PieceSelectorDialog: UIViewController, UITableViewDelegate, UITableViewDataSource
{
    let CurrentTable = 100
    let AvailableTable = 200
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        PieceSourceTable.layer.borderColor = UIColor.black.cgColor
        PieceSourceTable.layer.cornerRadius = 5.0
        PieceSourceTable.layer.borderWidth = 0.5
        CurrentPieceTable.layer.borderColor = UIColor.black.cgColor
        CurrentPieceTable.layer.cornerRadius = 5.0
        CurrentPieceTable.layer.borderWidth = 0.5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return UITableViewCell()
    }
    
    @IBAction func HandleMoveToCurrent(_ sender: Any)
    {
    }
    
    @IBAction func HandleMoveToAvailable(_ sender: Any)
    {
    }
    
    @IBAction func ClearCurrentPieceSet(_ sender: Any)
    {
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var PieceSourceTable: UITableView!
    @IBOutlet weak var CurrentPieceTable: UITableView!
}
