//
//  ThemingController.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ThemingController: UIViewController, UITableViewDataSource, UITableViewDelegate, ThemeEditingProtocol
{

    
    weak var ThemeDelegate: ThemeEditingProtocol? = nil
    
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
    
    var ThemeID: UUID = UUID.Empty
    
    @IBSegueAction func InstantiateNewThemeEditor(_ coder: NSCoder) -> ThemeEditorController?
    {
        let Editor = ThemeEditorController(coder: coder)
        Editor?.ThemeDelegate = self
        EditTheme(ID: UUID.Empty)
        return Editor
    }
    
    @IBSegueAction func InstantiateThemeEditor(_ coder: NSCoder) -> ThemeEditorController?
    {
        let Editor = ThemeEditorController(coder: coder)
        Editor?.ThemeDelegate = self
        EditTheme(ID: ThemeID)
        return Editor
    }
    
    func EditTheme(ID: UUID)
    {
        //Right now, no one should call this as this is the originator of theme edits.
    }
    
    func EditTheme(ID: UUID, Piece: UUID)
    {
    }
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //Do something.
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
