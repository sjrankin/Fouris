//
//  SelectBackgroundImageCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class SelectBackgroundImageCode: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
    ThemeEditingProtocol
{
    weak var ThemeDelegate: ThemeEditingProtocol? = nil
    var ImagePicker: UIImagePickerController? = nil
    
    override func viewDidLoad()
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
    
    func EditTheme(Theme: ThemeDescriptor2)
    {
        UserTheme = Theme
    }
    
    func EditTheme(Theme: ThemeDescriptor2, PieceID: UUID)
    {
        UserTheme = Theme
    }
    
    var UserTheme: ThemeDescriptor2!
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //Not used in this class.
    }
    
    @IBOutlet weak var ImageDisplay: UIImageView!
    
    @IBAction func HandleOKPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(true, ThemeID: UserTheme.ID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCancelPressed(_ sender: Any)
    {
        ThemeDelegate?.EditResults(false, ThemeID: UserTheme.ID, PieceID: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleSetDefaultImage(_ sender: Any)
    {
        ImageDisplay.image = UIImage(named: "DefaultImage")
    }
    
    @IBAction func HandleSelectFromPhotoRoll(_ sender: Any)
    {
        ImagePicker = UIImagePickerController()
        ImagePicker?.delegate = self
        ImagePicker?.allowsEditing = false
        ImagePicker?.sourceType = .photoLibrary
        present(ImagePicker!, animated: true, completion: nil)
    }
    
    /// Completion block for saving images to the photo roll. Will display an error message if the save was unsuccessful, and
    /// a "saved OK" message if there was no error.
    ///
    /// - Parameters:
    ///   - image: Not used.
    ///   - error: Error information for when errors occur.
    ///   - contextInfo: Not used.
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer)
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
    ///
    /// - Parameters:
    ///   - picker: The UIImagePickerController. Will be dismissed at end of function.
    ///   - info: Dictionary that contains the image (or not, if the user canceled).
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
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
