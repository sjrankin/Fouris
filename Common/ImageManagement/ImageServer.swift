//
//  ImageServer.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/24/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

/// Serves images. The images are expected to live in the assets catalog in the project and are referred to
/// by name. Images are cached by name and resize value.
class ImageServer
{
    /// Contains the image cache for iOS.
    private static var ImageCache = [String: (CGSize, UIImage)]()
    
    /// Clear all items in the image cache.
    public static func ClearImageCache()
    {
        ImageCache.removeAll()
    }
    
    /// Return a named image at the requested size.
    ///
    /// - Parameters:
    ///   - ImageName: Name of the image.
    ///   - WithSize: Size of the image.
    /// - Returns: The image at the requested size or nil on error.
    public static func GetImage(_ ImageName: String, WithSize: CGSize) -> UIImage?
    {
        //See if the image is in the cache.
        if let (Size, CachedImage) = ImageCache[ImageName]
        {
            if Size == WithSize
            {
                return CachedImage
            }
        }
        if let Image = UIImage(named: ImageName)
        {
            UIGraphicsBeginImageContext(WithSize)
            Image.draw(in: CGRect(origin: CGPoint.zero, size: WithSize))
            let Final = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return Final
        }
        else
        {
            print("Did not find \(ImageName).")
            return nil
        }
    }
    
    /// Returns the size of a pre-rendered image.
    ///
    /// - Parameter ImageType: The type of image whose size is returned.
    /// - Returns: The size of the image (in pixels) of the image type.
    public static func GetRenderedImageSize(_ ImageType: GameImageTypes) -> CGSize
    {
        switch ImageType
        {
        case .PlayButton:
            return CGSize(width: 500, height: 100)
            
        case .StopButton:
            return CGSize(width: 500, height: 100)
            
        case .PauseButton:
            return CGSize(width: 500, height: 100)
            
        case .ResumeButton:
            return CGSize(width: 500, height: 100)
            
        case .Bucket10x20:
            return CGSize(width: 384, height: 672)
            
        case .GameOverText:
            return CGSize(width: 1236, height: 182)
            
        case .PausedText:
            return CGSize(width: 724, height: 179)
            
        case .PressPlayText:
            return CGSize(width: 1441, height: 188)
        }
    }
    
    /// Return the size of a pre-rendered image modified by the target view size and percent.
    ///
    /// - Parameters:
    ///   - ImageType: The type of image whose size is returned.
    ///   - TargetWidth: The width of the target view controller.
    ///   - TargetPercent: The percent of the width the image should fill. This determines the height of the image.
    /// - Returns: The final size of the rendered image (in pixels), adjusted for the target view size.
    public static func GetRenderedImageSizeRatio(_ ImageType: GameImageTypes, TargetWidth: CGFloat, TargetPercent: CGFloat) -> CGSize
    {
        let ImageSize = GetRenderedImageSize(ImageType)
        let FinalTargetWidth = CGFloat(TargetWidth) * TargetPercent
        let Ratio = FinalTargetWidth / ImageSize.width
        return CGSize(width: FinalTargetWidth, height: Ratio * ImageSize.height)
    }

    /// Return a named image.
    ///
    /// - Parameter named: Name of the image.
    /// - Returns: UIImage with the named image.
    public static func GetNamedImage(named: String) -> UIImage
    {
        return UIImage(named: named)!
    }
}

/// Types of in-game images.
///
/// - PlayButton: The play button text image.
/// - StopButton: The stop button text image.
/// - PauseButton: The pause button text image.
/// - ResumeButton: The resume button text image.
/// - Bucket10x20: The 10x20 bucket image.
/// - GameOverText: The game over text image.
/// - PausedText: The paused text image.
/// - PressPlayText: The press play to start text image.
enum GameImageTypes: Int, CaseIterable
{
    case PlayButton = 0
    case StopButton = 1
    case PauseButton = 2
    case ResumeButton = 4
    case Bucket10x20 = 5
    case GameOverText = 6
    case PausedText = 7
    case PressPlayText = 8
}
