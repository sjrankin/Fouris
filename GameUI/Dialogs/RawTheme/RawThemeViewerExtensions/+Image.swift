//
//  +Image.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import Photos

extension RawThemeViewerCode
{
    /// Populate the image selection view.
    /// - Parameter WithField: The group field to populate the view with.
    public func PopulateImageView(WithField: GroupField)
    {
        ImagePhotoRollButton.isEnabled = !WithField.DisableControl
        ImageProgramImagesButton.isEnabled = !WithField.DisableControl
        ImageDescription.layer.cornerRadius = 4.0
        ImageDescription.clipsToBounds = true
        
        ImageTitle.text = WithField.Title
        ImageDescription.text = WithField.Description
        
        if let ImageName = WithField.Starting as? String
        {
            if let TheImage = GetNamedImage(ImageName)
            {
                ImageViewer.image = TheImage
            }
        }
        else
        {
            ImageViewer.image = nil
        }
        
        CurrentField = WithField
        ShowViewType(WithField.FieldType)
        IntViewDirty.alpha = 0.0
    }
    
    /// Get the specified image from the photo roll.
    /// - Note: See [Get name from PHAsset](https://stackoverflow.com/questions/27854937/ios8-photos-framework-how-to-get-the-nameor-filename-of-a-phasset)
    /// - Parameter: Name of the image in the photo roll.
    /// - Returns: The named image on success, nil if the image was not found.
    func GetNamedImage(_ Name: String) -> UIImage?
    {
        let ImageAssets = PHAsset.fetchAssets(with: .image, options: nil)
        var Assets = [PHAsset]()
        for Index in 0 ..< ImageAssets.count
        {
            Assets.append(ImageAssets[Index])
        }
        var FoundName = false
        var FoundAsset: PHAsset!
        for Asset in Assets
        {
            if Asset.OriginalFileName == nil
            {
                continue
            }
            if Asset.OriginalFileName == Name 
            {
                FoundAsset = Asset
                FoundName = true
                break
            }
        }
        if !FoundName
        {
            return nil
        }
        print("Found \(Name)")
        print(" Size: \(FoundAsset.pixelWidth)x\(FoundAsset.pixelHeight)")
        var FinalImage: UIImage? = nil
        PHImageManager.default().requestImage(for: FoundAsset, targetSize: CGSize(width: FoundAsset.pixelWidth, height: FoundAsset.pixelHeight),
                                              contentMode: .aspectFit, options: nil, resultHandler:
            {
                (Image, Info) in
                FinalImage = Image
        })
        return FinalImage
    }
}
