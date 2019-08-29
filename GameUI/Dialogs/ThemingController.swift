//
//  ThemingController.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ThemingController: UIViewController, UITableViewDataSource, UITableViewDelegate
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ThemeTable.layer.borderWidth = 0.5
        ThemeTable.layer.borderColor = UIColor.black.cgColor
        ThemeTable.layer.cornerRadius = 5.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return UITableViewCell()
    }
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var ThemeTable: UITableView!
}
