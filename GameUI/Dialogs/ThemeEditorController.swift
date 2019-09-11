//
//  ThemeEditorController.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ThemeEditorController: UIViewController, ThemeEditingProtocol
{
    weak var ThemeDelegate: ThemeEditingProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ThemeNameTitle.text = "Some theme name here"
        BackgroundView.layer.borderColor = UIColor.black.cgColor
        BackgroundView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        BucketSettingsView.layer.borderColor = UIColor.black.cgColor
        BucketSettingsView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        ThemeNameView.layer.borderColor = UIColor.black.cgColor
        ThemeNameView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        PiecesView.layer.borderColor = UIColor.black.cgColor
        PiecesView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
    }
    
    func EditTheme(ID: UUID)
    {
        ThemeID = ID
    }
    
    func EditTheme(ID: UUID, PieceID: UUID)
    {
        ThemeID = ID
    }
    
    var ThemeID: UUID = UUID.Empty
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //do something here
    }
    
    @IBSegueAction func InstantiateGameBackground(_ coder: NSCoder) -> GameBackgroundDialog?
    {
        let GBack = GameBackgroundDialog(coder: coder)
        GBack?.ThemeDelegate = self
        GBack?.EditTheme(ID: ThemeID)
        return GBack
    }
    
    @IBSegueAction func InstantiatePieceSelection(_ coder: NSCoder) -> PieceSelectorDialog?
    {
        let PieceSelect = PieceSelectorDialog(coder: coder)
        PieceSelect?.ThemeDelegate = self
        PieceSelect?.EditTheme(ID: ThemeID) 
        return PieceSelect
    }
    
    @IBAction func HandleSaveButtonPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: ThemeID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelButtonPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(false, ThemeID: ThemeID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var PiecesView: UIView!
    @IBOutlet weak var BackgroundView: UIView!
    @IBOutlet weak var BucketSettingsView: UIView!
    @IBOutlet weak var ThemeNameView: UIView!
    @IBOutlet weak var ThemeNameTitle: UILabel!
    @IBOutlet weak var ShowBucketBoundsSwitch: UISwitch!
    @IBOutlet weak var ShowBucketGridSwitch: UISwitch!
    @IBOutlet weak var ThemeNameTextBox: UITextField!
}
