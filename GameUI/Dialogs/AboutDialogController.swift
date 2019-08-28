//
//  AboutDialogController.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class AboutDialogController: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AboutBox.layer.borderColor = UIColor.black.cgColor
        AboutBox.layer.borderWidth = 1.0
        AboutBox.layer.cornerRadius = 5.0
        AboutData.text = Versioning.MakeVersionBlock()
    }
    
    @IBOutlet weak var AboutBox: UIView!
    @IBOutlet weak var AboutData: UILabel!
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
}
