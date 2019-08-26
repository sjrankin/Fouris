//
//  +MainSlideInUI.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/22/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Extension to **CommonViewController** to handle events and user interactions related to the slide in view.
extension MainViewController: UITableViewDelegate, UITableViewDataSource
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
    /*
    /// Handle the pressing of the main UI button. If the slide in view is already visible, hide it. If the slide in view is
    /// hidden, show it.
    /// - Parameter sender: Not used.
    @IBAction func HandleMainButtonPressed(_ sender: Any)
    {
        //Initialize the first use of the slide in view.
        if FirstSlideIn
        {
            FirstSlideIn = false
            GameView.bringSubviewToFront(MainSlideIn)
        }
        if MainSlideIn!.IsVisible
        {
            MainSlideIn?.HideMainSlideIn()
            UpdateMainButton(false)
        }
        else
        {
            MainSlideIn?.ShowMainSlideIn()
            UpdateMainButton(true)
        }
    }
    
    /// Update the main UI button by rotating it to indicate it has been pressed.
    /// - Parameter Opened: Determines the icon to show.
    private func UpdateMainButton(_ Opened: Bool)
    {
        let ImageName = Opened ? "InvertedCubeButton" : "CubeButton"
        MainUIButton.setImage(UIImage(named: ImageName), for: UIControl.State.normal)
    }
    
    /// Handle the close button in the slide in view pressed by the user by closing the slide in view.
    /// - Parameter sender: Not used.
    @IBAction func HandleSlideInCloseButtonPressed(_ sender: Any)
    {
        MainSlideIn?.HideMainSlideIn()
        UpdateMainButton(false)
    }
    
    /// Handle the attract button in the slide in view pressed. Start a new game in attract mode (AI running).
    /// - Parameter sender: Not used.
    @IBAction func HandleSlideInAttractButtonPressed(_ sender: Any)
    {
        MainSlideIn?.HideMainSlideIn()
        UpdateMainButton(false)
        if AttractTimer != nil
        {
            //Need to invalidate the attract timer (if it's active) or bad things will happen
            //(specifically, pieces will get confused about which board they belong to, causing
            //crashes and fatal errors).
            AttractTimer?.invalidate()
            AttractTimer = nil
        }
        InAttractMode = true
        Stop()
        ClearAndPlay()
    }
 */
}

