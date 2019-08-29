//
//  ThemeEditorController.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/29/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ThemeEditorController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ThemeNameTitle.text = "Some theme name here"
        DeleteThemeView.layer.borderColor = UIColor.red.cgColor
        BackgroundView.layer.borderColor = UIColor.black.cgColor
        BackgroundView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        BucketSettingsView.layer.borderColor = UIColor.black.cgColor
        BucketSettingsView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        ThemeNameView.layer.borderColor = UIColor.black.cgColor
        ThemeNameView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        PiecesView.layer.borderColor = UIColor.black.cgColor
        PiecesView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
    }
    
    @IBAction func HandleDeleteThemePressed(_ sender: Any)
    {
        let Title = "Delete <name>?"
        let Message = "Do you really want to delete the theme <name>? If you delete this theme, you cannot recover it."
        let Alert = UIAlertController(title: Title,
                                      message: Message,
                                      preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: HandleDeleteButtonSelection))
        Alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: HandleDeleteButtonSelection))
        self.present(Alert, animated: true)
    }
    
    @objc func HandleDeleteButtonSelection(Action: UIAlertAction)
    {
        switch Action.title
        {
            case "Yes":
                break
            
            case "No":
                return
            
            default:
                fatalError("Unexpected alert action encountered: \((Action.title)!)")
        }
    }
    
    @IBAction func HandleSaveButtonPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelButtonPressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var PiecesView: UIView!
    @IBOutlet weak var DeleteThemeView: UIView!
    @IBOutlet weak var BackgroundView: UIView!
    @IBOutlet weak var BucketSettingsView: UIView!
    @IBOutlet weak var ThemeNameView: UIView!
    @IBOutlet weak var ThemeNameTitle: UILabel!
    @IBOutlet weak var ShowBucketBoundsSwitch: UISwitch!
    @IBOutlet weak var ShowBucketGridSwitch: UISwitch!
    @IBOutlet weak var ThemeNameTextBox: UITextField!
    @IBOutlet weak var DeleteThemeButton: UIButton!
}
