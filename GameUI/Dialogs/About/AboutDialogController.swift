//
//  AboutDialogController.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

class AboutDialogController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AboutBox.layer.borderColor = UIColor.black.cgColor
        AboutBox.layer.borderWidth = 1.0
        AboutBox.layer.cornerRadius = 5.0
        AboutBox.backgroundColor = UIColor.clear
        AboutData.attributedText = Versioning.MakeAttributedVersionBlockEx(TextColor: UIColor.black, HeaderColor: UIColor(red: 0.1, green: 0.1, blue: 0.3),
                                                                           FontName: "Avenir-Medium", HeaderFontName: "Avenir",
                                                                           FontSize: 24.0)
        AboutData.backgroundColor = UIColor.clear
        PieceDisplay.layer.borderColor = UIColor.black.cgColor
        PieceDisplay.layer.borderWidth = 0.5
        PieceDisplay.layer.cornerRadius = 5.0
        PieceDisplay.isHidden = true
        let Tap = UITapGestureRecognizer(target: self, action: #selector(TitleTap))
        Tap.numberOfTapsRequired = 1
        TitleLabel.addGestureRecognizer(Tap)
    }
    
    @objc func TitleTap(Recognizer: UIGestureRecognizer)
    {
        if Recognizer.state == .ended
        {
            ShowingDisplay = !ShowingDisplay
            PieceDisplay.isHidden = !ShowingDisplay
        }
    }
    
    var ShowingDisplay: Bool = false
    
    @IBOutlet weak var AboutBox: UIView!
    @IBOutlet weak var AboutData: UILabel!
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var PieceDisplay: SCNView!
}
