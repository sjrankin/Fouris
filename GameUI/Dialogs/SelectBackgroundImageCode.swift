//
//  SelectBackgroundImageCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SelectBackgroundImageCode: UIViewController, ThemeEditingProtocol
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
    
    var ThemeID: UUID = UUID.Empty
    
    func EditResults(_ Edited: Bool, ThemeID: UUID)
    {
        //Not used in this class.
    }
    
    @IBOutlet weak var ImageDisplay: UIImageView!
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: ThemeID)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(false, ThemeID: ThemeID)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleSetDefaultImage(_ sender: Any)
    {
        ImageDisplay.image = UIImage(named: "DefaultImage")
    }
    
    @IBAction func HandleSelectFromPhotoRoll(_ sender: Any)
    {
    }
}
