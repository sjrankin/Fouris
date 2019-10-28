//
//  +Pause.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/28/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit

extension View3D
{
    /// Show a pause modal view with a message. Intended for debug use only.
    /// - Parameter With: The message to display.
    public func PauseView(With Message: String)
    {
        let Alert = UIAlertController(title: "View3D Paused", message: Message, preferredStyle: UIAlertController.Style.alert)
        Alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: nil))
        if let Parent = self.FindViewController()
        {
        Parent.present(Alert, animated: true, completion: nil)
        }
        else
        {
            print("Error finding parent controller.")
        }
    }
    
    /// Show a pause modal view with a (perhaps too) generic message. Intended for debug use only.
    public func PauseView()
    {
        PauseView(With: "View3D paused.")
    }
}
