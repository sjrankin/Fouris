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

class AboutDialogController: UIViewController, UINavigationControllerDelegate
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
        
        CameraButton.isUserInteractionEnabled = false
        CameraButton.alpha = 0.0
        VideoButton.isUserInteractionEnabled = false
        VideoButton.alpha = 0.0
    }
    
    @objc func TitleTap(Recognizer: UIGestureRecognizer)
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
    
    var ShowingDisplay: Bool = false
    
    @IBOutlet weak var AboutBox: UIView!
    @IBOutlet weak var AboutData: UILabel!
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func HandleCameraButtonPress(_ sender: Any)
    {
        let PieceImage = PieceDisplay.snapshot()
        UIImageWriteToSavedPhotosAlbum(PieceImage,
                                       self,
                                       #selector(image(_:didFinishSavingWithError:contextInfo:)),
                                       nil)
    }
    
    @IBAction func HandleVideoButtonPress(_ sender: Any)
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
    
    private var CreatingVideo: Bool = false
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer)
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
