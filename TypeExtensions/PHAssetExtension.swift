//
//  PHAssetExtension.swift
//  Fouris
//
//  Created by Stuart Rankin on 9/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import Photos

/// Extensions for PHAssets.
extension PHAsset
{
    /// Returns the original file name from the instance asset.
    public var OriginalFileName: String?
    {
        return PHAssetResource.assetResources(for: self).first?.originalFilename
    }
}
