//
//  PieceVisualizerCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/6/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class PieceVisualizerCode: UIViewController, ThemeEditingProtocol
{
    weak var ThemeDelegate: ThemeEditingProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    func EditTheme(ID: UUID)
    {
        ThemeID = ID
    }
    
    func EditTheme(ID: UUID, Piece: UUID)
    {
        ThemeID = ID
    }
    
    var ThemeID: UUID = UUID.Empty
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        
    }
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: ThemeID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(false, ThemeID: ThemeID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
}
