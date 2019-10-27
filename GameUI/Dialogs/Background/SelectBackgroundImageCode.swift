//
//  SelectBackgroundImageCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Code to run the select background image UI.
class SelectBackgroundImageCode: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    ThemeEditingProtocol
{
    /// Delegate to receive messages from this class.
    public weak var ThemeDelegate: ThemeEditingProtocol? = nil
    /// Holds the system image picker controller.
    public var ImagePicker: UIImagePickerController? = nil
    
    /// Initialize the UI.
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        if let UserBackgroundImage = FileIO.GetSampleImage()
        {
            ImageDisplay.image = UserBackgroundImage
        }
        else
        {
            ImageDisplay.image = UIImage(named: "DefaultImage")
        }
    }
    
    /// Theme to edit from the caller.
    /// - Parameter Theme: The theme to edit.
    public func EditTheme(Theme: ThemeDescriptor2)
    {
        UserTheme = Theme
    }
    
    /// Theme to edit from the caller.
    /// - Parameter Theme: The theme to edit.
    /// - Parameter PieceID: Not used.
    public func EditTheme(Theme: ThemeDescriptor2, PieceID: UUID)
    {
        UserTheme = Theme
    }
    
    /// Theme being edited.
    private var UserTheme: ThemeDescriptor2!
    
    /// Not used in this class.
    public func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //Not used in this class.
    }
    
    @IBOutlet weak var ImageDisplay: UIImageView!
    
    /// Handle the OK button pressed. Notify the caller of a new image. Close the dialog.
    /// - Parameter sender: Not used.
    @IBAction public func HandleOKPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: UserTheme.ID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the cancel button pressed. Notify the caller of the cancellation. Close the dialog.
    /// - Parameter sender: Not used.
    @IBAction public func HandleCancelPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(false, ThemeID: UserTheme.ID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the set default image command. Shows the abstract default image.
    /// - Parameter sender: Not used.
    @IBAction public func HandleSetDefaultImage(_ sender: Any)
    {
        ImageDisplay.image = UIImage(named: "DefaultImage")
    }
    
    /// Runs the system image picker.
    /// - Parameter sender: Not used.
    @IBAction public func HandleSelectFromPhotoRoll(_ sender: Any)
    {
        ImagePicker = UIImagePickerController()
        ImagePicker?.delegate = self
        ImagePicker?.allowsEditing = false
        ImagePicker?.sourceType = .photoLibrary
        present(ImagePicker!, animated: true, completion: nil)
    }
    
    /// Completion block for saving images to the photo roll. Will display an error message if the save was unsuccessful, and
    /// a "saved OK" message if there was no error.
    /// - Parameters:
    ///   - image: Not used.
    ///   - error: Error information for when errors occur.
    ///   - contextInfo: Not used.
    @objc public func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer)
    {
        if let SaveError = error
        {
            let Alert = UIAlertController(title: "Image Save Error", message: SaveError.localizedDescription, preferredStyle: .alert)
            Alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(Alert, animated: true)
        }
        else
        {
            let Alert = UIAlertController(title: "Sample Image Saved", message: "The sample image with current effect parameters has been saved to the photo roll.", preferredStyle: .alert)
            Alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(Alert, animated: true)
        }
    }
    
    /// Handle the image picker completion. On successful selection of a new image, the image will be saved to a special
    /// directory where it can be retrieved at will. The image will also be immediately used for the sample image. On error,
    /// an alert is shown to let the user know there was an issue.
    /// - Parameters:
    ///   - picker: The UIImagePickerController. Will be dismissed at end of function.
    ///   - info: Dictionary that contains the image (or not, if the user canceled).
    @objc public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let PickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            ImageDisplay.image = PickedImage
            let OK = FileIO.SaveImage(PickedImage)
            if !OK
            {
                print("Error saving image to image directory.")
            }
        }
        else
        {
            print("User canceled image picker.")
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
