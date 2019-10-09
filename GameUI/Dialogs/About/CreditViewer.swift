//
//  CreditViewer.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/8/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class CreditViewer: UIViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        AttributionBox.layer.borderColor = UIColor.black.cgColor
        AttributionBox.layer.backgroundColor = UIColor.clear.cgColor
        AttributionsViewer.text = ""
        var Final = ""
        for (Title, Text) in AttributeData.List
        {
            Final.append(Title + " " + Text + "\n")
        }
        AttributionsViewer.text = Final
    }
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var AttributionBox: UIView!
    @IBOutlet weak var AttributionsViewer: UITextView!
}
