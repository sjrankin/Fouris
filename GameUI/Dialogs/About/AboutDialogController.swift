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

/// Code to control the about dialog.
class AboutDialogController: UIViewController, UINavigationControllerDelegate
{
    /// Initialization of the UI.
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        AboutBox.layer.borderColor = UIColor.black.cgColor
        AboutBox.layer.borderWidth = 1.0
        AboutBox.layer.cornerRadius = 5.0
        AboutBox.backgroundColor = UIColor.clear
        AboutData.attributedText = Versioning.MakeAttributedVersionBlockEx(TextColor: UIColor.black, HeaderColor: UIColor(red: 0.1, green: 0.1, blue: 0.3),
                                                                           FontName: "Avenir-Medium", HeaderFontName: "Avenir",
                                                                           FontSize: 22.0)
        AboutData.backgroundColor = UIColor.clear
        PieceDisplay.layer.borderColor = UIColor.black.cgColor
        PieceDisplay.layer.borderWidth = 0.5
        PieceDisplay.layer.cornerRadius = 5.0
        PieceDisplay.isHidden = true
        let Tap = UITapGestureRecognizer(target: self, action: #selector(TitleTap))
        Tap.numberOfTapsRequired = 1
        TitleLabel.addGestureRecognizer(Tap)
        
        CameraButton.isUserInteractionEnabled = false
        CameraButton.alpha = 0.0
        VideoButton.isUserInteractionEnabled = false
        VideoButton.alpha = 0.0
    }
    
    /// Handle taps on the title. This is a not very hidden easter egg to display shapes flying around.
    @objc public func TitleTap(Recognizer: UIGestureRecognizer)
    {
        if Recognizer.state == .ended
        {
            ShowingDisplay = !ShowingDisplay
            PieceDisplay.isHidden = !ShowingDisplay
            if ShowingDisplay
            {
                PieceDisplay.Play(PieceCount: 400)
                CameraButton.isUserInteractionEnabled = true
                VideoButton.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.5, animations:
                    {
                        self.CameraButton.alpha = 1.0
                        self.VideoButton.alpha = 1.0
                }, completion:
                    {
                        _ in
                        self.CameraButton.alpha = 1.0
                        self.VideoButton.alpha = 1.0
                }
                )
            }
            else
            {
                PieceDisplay.StopVideo(Clear: true)
                PieceDisplay.Stop()
                CameraButton.isUserInteractionEnabled = false
                VideoButton.isUserInteractionEnabled = false
                UIView.animate(withDuration: 0.75, animations:
                    {
                        self.CameraButton.alpha = 0.0
                        self.VideoButton.alpha = 0.0
                }, completion:
                    {
                        _ in
                        self.CameraButton.alpha = 0.0
                        self.VideoButton.alpha = 0.0
                }
                )
            }
        }
    }
    
    /// Flag that determines if the easter egg is being shown.
    private var ShowingDisplay: Bool = false
    
    /// Reference to the about box.
    @IBOutlet public weak var AboutBox: UIView!
    /// Reference to the about data label.
    @IBOutlet public weak var AboutData: UILabel!
    
    /// Handle the close button. Close the dialog.
    /// - Parameter sender: Not used.
    @IBAction public func HandleCloseButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// Handle the camera button. Take a picture of the easter egg.
    /// - Parameter sender: Not used.
    @IBAction public func HandleCameraButtonPress(_ sender: Any)
    {
        let PieceImage = PieceDisplay.snapshot()
        UIImageWriteToSavedPhotosAlbum(PieceImage,
                                       self,
                                       #selector(image(_:didFinishSavingWithError:contextInfo:)),
                                       nil)
    }
    
    /// Handle the video button. Take a video of the screen.
    /// - Parameter sender: Not used.
    @IBAction public func HandleVideoButtonPress(_ sender: Any)
    {
        CreatingVideo = !CreatingVideo
        if CreatingVideo
        {
            PieceDisplay.StartVideo()
            VideoButton.tintColor = UIColor.systemRed
        }
        else
        {
            PieceDisplay.StopVideo()
            //PieceDisplay.SaveVideo()
            VideoButton.tintColor = UIColor.systemBlue
        }
    }
    
    /// Holds the creating video flag.
    private var CreatingVideo: Bool = false
    
    /// Delegate handler for saving an image.
    /// - Parameter image: The image that was saved.
    /// - Parameter didFinishSavingWithError: Error message if appropriate.
    /// - Parameter contextInfo: Not used.
    @objc public func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer)
    {
        if let SomeError = error
        {
            print("\(SomeError)")
        }
        else
        {
            let Alert = UIAlertController(title: "Saved", message: "Image save to the camera roll.", preferredStyle: UIAlertController.Style.alert)
            Alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(Alert, animated: true)
        }
    }
    
    @IBOutlet weak var VideoButton: UIButton!
    @IBOutlet weak var CameraButton: UIButton!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var PieceDisplay: FlyingPieces!
}
