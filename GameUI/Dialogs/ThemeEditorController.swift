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
        BackgroundView.layer.borderColor = UIColor.black.cgColor
        BackgroundView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        BucketSettingsView.layer.borderColor = UIColor.black.cgColor
        BucketSettingsView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        PiecesView.layer.borderColor = UIColor.black.cgColor
        PiecesView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
    }
    
    func EditTheme(Theme: ThemeDescriptor, DefaultTheme: ThemeDescriptor)
    {
        self.UserTheme = Theme
        self.DefaultTheme = DefaultTheme
    }
    
    func EditTheme(Theme: ThemeDescriptor, PieceID: UUID, DefaultTheme: ThemeDescriptor)
    {
        self.UserTheme = Theme
        self.DefaultTheme = DefaultTheme
    }
    
    var UserTheme: ThemeDescriptor? = nil
    var DefaultTheme: ThemeDescriptor? = nil
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //do something here
    }
    
    @IBSegueAction func InstantiateGameBackground(_ coder: NSCoder) -> GameBackgroundDialog?
    {
        let GBack = GameBackgroundDialog(coder: coder)
        GBack?.ThemeDelegate = self
        GBack?.EditTheme(Theme: UserTheme!, DefaultTheme: DefaultTheme!)
        return GBack
    }
    
    @IBSegueAction func InstantiatePieceSelection(_ coder: NSCoder) -> PieceSelectorDialog?
    {
        let PieceSelect = PieceSelectorDialog(coder: coder)
        PieceSelect?.ThemeDelegate = self
        PieceSelect?.EditTheme(Theme: UserTheme!, DefaultTheme: DefaultTheme!)
        return PieceSelect
    }
    @IBSegueAction func InstantiateRawThemeEditor(_ coder: NSCoder) -> RawThemeViewerCode?
    {
        let Editor = RawThemeViewerCode(coder: coder)
        Editor?.ThemeDelegate = self
        Editor?.EditTheme(Theme: UserTheme!, DefaultTheme: DefaultTheme!)
        return Editor
    }
    
    @IBAction func HandleSaveButtonPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: UserTheme!.ID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelButtonPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(false, ThemeID: UserTheme!.ID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var RawThemeViewButton: UIButton!
    @IBOutlet weak var PiecesView: UIView!
    @IBOutlet weak var BackgroundView: UIView!
    @IBOutlet weak var BucketSettingsView: UIView!
    @IBOutlet weak var ShowBucketBoundsSwitch: UISwitch!
    @IBOutlet weak var ShowBucketGridSwitch: UISwitch!
}
