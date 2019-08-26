//
//  +MainSlideInUI2.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Extension to **CommonViewController** to handle events and user interactions related to the slide in view.
extension MainViewController2: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        return UITableViewCell()
    }
    
    /// Initialize the visuals and content of the table used to display options.
    /// - Parameter Table: The UITableView to initialize.
    public func InitializeOptionTable(_ Table: UITableView)
    {
        Table.delegate = self
        Table.dataSource = self
        Table.layer.borderColor = UIColor.black.cgColor
        Table.layer.borderWidth = 1.0
        Table.layer.cornerRadius = 5.0
        Table.reloadData()
    }
}

