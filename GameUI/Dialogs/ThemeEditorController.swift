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
        SettingsBox.layer.borderColor = UIColor.black.cgColor
        SettingsBox.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        BackgroundView.layer.borderColor = UIColor.black.cgColor
        BackgroundView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        BucketSettingsView.layer.borderColor = UIColor.black.cgColor
        BucketSettingsView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        PiecesView.layer.borderColor = UIColor.black.cgColor
        PiecesView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        
        ShowBucketGridSwitch.isOn = UserTheme!.ShowBucketGrid
        ShowBucketBoundsSwitch.isOn = UserTheme!.ShowBucketGridOutline
    }
    
    func EditTheme(Theme: ThemeDescriptor2)
    {
        self.UserTheme = Theme
    }
    
    func EditTheme(Theme: ThemeDescriptor2, PieceID: UUID)
    {
        self.UserTheme = Theme
    }
    
    var UserTheme: ThemeDescriptor2? = nil

    var DefaultTheme: ThemeDescriptor2? = nil
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //do something here
    }
    
    // MARK: Dialog instantiations.
    
    @IBSegueAction func InstantiateGameBackground(_ coder: NSCoder) -> GameBackgroundDialog?
    {
        let GBack = GameBackgroundDialog(coder: coder)
        GBack?.ThemeDelegate = self
        GBack?.EditTheme(Theme: UserTheme!)
        return GBack
    }
    
    @IBSegueAction func InstantiatePieceSelection(_ coder: NSCoder) -> PieceSelectorDialog?
    {
        let PieceSelect = PieceSelectorDialog(coder: coder)
        PieceSelect?.ThemeDelegate = self
        PieceSelect?.EditTheme(Theme: UserTheme!)
        return PieceSelect
    }
    @IBSegueAction func InstantiateRawThemeEditor(_ coder: NSCoder) -> RawThemeViewerCode?
    {
        let Editor = RawThemeViewerCode(coder: coder)
        Editor?.ThemeDelegate = self
        Editor?.EditTheme(Theme: UserTheme!)
        return Editor
    }
    
    @IBSegueAction func InstantiateSettingsEditor(_ coder: NSCoder) -> SettingsControllerCode?
    {
        let Editor = SettingsControllerCode(coder: coder)
        return Editor
    }
    
    @IBSegueAction func InstantiateExporter(_ coder: NSCoder) -> ExportCode?
    {
        let Exporter = ExportCode(coder: coder)
        Exporter?.EditTheme(Theme: UserTheme!)
        return Exporter
    }
    
    // MARK: Bucket grid controls.
    
    @IBAction func HandleShowBucketGridChanged(_ sender: Any)
    {
        UserTheme!.ShowBucketGrid = ShowBucketGridSwitch.isOn
    }
    
    @IBAction func HandleShowBucketGridOutlineChanged(_ sender: Any)
    {
        UserTheme!.ShowBucketGridOutline = ShowBucketBoundsSwitch.isOn
    }
    
    // MARK: UI control handling.
    
    @IBAction func HandleCloseButtonPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: UserTheme!.ID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var SettingsBox: UIView!
    @IBOutlet weak var RawThemeViewButton: UIButton!
    @IBOutlet weak var PiecesView: UIView!
    @IBOutlet weak var BackgroundView: UIView!
    @IBOutlet weak var BucketSettingsView: UIView!
    @IBOutlet weak var ShowBucketBoundsSwitch: UISwitch!
    @IBOutlet weak var ShowBucketGridSwitch: UISwitch!
}
