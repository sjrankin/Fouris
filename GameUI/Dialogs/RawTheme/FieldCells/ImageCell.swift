//
//  ImageCell.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/17/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import Photos

class ImageCell: FieldCell, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PHPhotoLibraryChangeObserver
{
    func photoLibraryDidChange(_ changeInstance: PHChange)
    {
    }
    
    deinit
    {
        if UIDrawn
        {
            PHPhotoLibrary.shared().unregisterChangeObserver(self)
        }
    }
    
    override func DrawUI()
    {
        if !WasInitialized
        {
            return
        }
        
        PHPhotoLibrary.shared().register(self)
        FieldLabel = UILabel(frame: CGRect(x: 5, y: 3, width: ParentWidth / 2, height: 69))
        contentView.addSubview(FieldLabel!)
        FieldLabel?.text = FieldTitle
        StyleTitle(FieldLabel!)
        ImageView = UIImageView(frame: CGRect(x: ParentWidth - 80, y: 5, width: 65, height: 65))
        ImageView.contentMode = .scaleAspectFit
        if let NamedImage = GetNamedImage((Current as? String)!)
        {
        ImageView.image = NamedImage
        }
        contentView.addSubview(ImageView)
        let Tap = UITapGestureRecognizer(target: self, action: #selector(HandleImageTap))
        Tap.numberOfTapsRequired = 1
        ImageView.addGestureRecognizer(Tap)
        UIDrawn = true
    }
    
    var UIDrawn: Bool = false
    
    //https://stackoverflow.com/questions/27854937/ios8-photos-framework-how-to-get-the-nameor-filename-of-a-phasset
    func GetNamedImage(_ Name: String) -> UIImage?
    {
        let ImageAssets = PHAsset.fetchAssets(with: .image, options: nil)
        var Assets = [PHAsset]()
        for Index in 0 ..< ImageAssets.count
        {
            Assets.append(ImageAssets[Index])
            print("Image name \((ImageAssets[Index].OriginalFileName)!)")
        }
        var FoundName = false
        var FoundAsset: PHAsset!
        for Asset in Assets
        {
            if Asset.OriginalFileName == nil
            {
                continue
            }
            if Asset.OriginalFileName == Current as? String
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
        print("Found \((Current as? String)!)")
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
    
    @objc func HandleImageTap(Recognizer: UIGestureRecognizer)
    {
        if Recognizer.state == .ended
        {
            ImagePicker = UIImagePickerController()
            ImagePicker?.delegate = self
            ImagePicker?.allowsEditing = false
            ImagePicker?.sourceType = .photoLibrary
            Parent?.present(ImagePicker!, animated: true, completion: nil)
        }
    }
    
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        if let PickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        {
            ImageView.image = PickedImage
            let Assets = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset
            let AssetResources = PHAssetResource.assetResources(for: Assets!)
            ImageName = AssetResources.first!.originalFilename
            Current = ImageName
            if let Handler = ChangeHandler
            {
                Handler(Current as Any)
                return
            }
            FieldDelegate?.EditedField(ID, NewValue: Current as Any, DefaultValue: Default as Any, FieldType: FieldType)
        }
    }
    
    var ImagePicker: UIImagePickerController? = nil
    var ImageName: String!
    var ImageView: UIImageView!
}

extension PHAsset
{
    var OriginalFileName: String?
    {
        return PHAssetResource.assetResources(for: self).first?.originalFilename
    }
}
