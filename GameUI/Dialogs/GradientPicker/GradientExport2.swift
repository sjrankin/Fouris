//
//  GradientExport2.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Export gradients via the sharing activity sheet. Gradients are converted to images then exported.
class GradientExport2: UIViewController, GradientPickerProtocol, UIActivityItemSource
{
    /// Not currently used.
    public weak var GradientDelegate: GradientPickerProtocol? = nil
    
    /// Initialize the UI.
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        GradientSample.layer.borderColor = UIColor.black.cgColor
        DrawSample()
    }
    
    /// Draw a sample to show the user what will be exported.
    public func DrawSample()
    {
        let IsVertical = OrientationSegment.selectedSegmentIndex == 0
        let ImageFrame = CGRect(x: 0, y: 0, width: GradientSample.frame.width, height: GradientSample.frame.height)
        let Sample = GradientManager.CreateGradientImage(From: GradientToExport, WithFrame: ImageFrame,
                                                     IsVertical: IsVertical)
        GradientSample.image = Sample
    }
    
    /// Not used in this class.
    func EditedGradient(_ Edited: String?, Tag: Any?)
    {
        //Not used.
    }
    
    /// Sets the gradient to export.
    /// - Warning: If `Edited` is nil, a fatal error is generated.
    /// - Parameter Edited: The gradient to export.
    /// - Parameter Tag: Not used.
    public func GradientToEdit(_ Edited: String?, Tag: Any?)
    {
        if let ExportMe = Edited
        {
            GradientToExport = ExportMe
        }
        else
        {
            fatalError("Invalid gradient for export.")
        }
    }
    
    /// Holds the gradient to export.
    public var GradientToExport: String = ""
    
    /// Not used in this class.
    public func SetStop(StopColorIndex: Int)
    {
        //Not used.
    }
    
    /// Handle changes to the orientation switch. The switch is read in `DrawSample` so all we need to do is call
    /// `DrawSample` from here.
    /// - Parameter sender: Not used.
    @IBAction public func HandleGradientOrientationChanged(_ sender: Any)
    {
        DrawSample()
    }
    
    /// Handle the user press of the export button by generating an image from the gradient and then running the activity view
    /// to have the user decide what to do with the resultant image.
    /// - Parameter sender: Not used.
    @IBAction public func HandleExportPressed(_ sender: Any)
    {
        let IsVertical = OrientationSegment.selectedSegmentIndex == 0
        let Width = Int(Double(pow(Double(2.0), Double(WidthSegment.selectedSegmentIndex + 8))))
        let Height = Int(Double(pow(Double(2.0), Double(HeightSegment.selectedSegmentIndex + 8))))
        let ImageFrame = CGRect(x: 0, y: 0, width: Width, height: Height)
        SaveMe = GradientManager.CreateGradientImage(From: GradientToExport, WithFrame: ImageFrame,
                                                     IsVertical: IsVertical)
        let Items: [Any] = [self]
        let ACV = UIActivityViewController(activityItems: Items, applicationActivities: nil)
        ACV.popoverPresentationController?.sourceView = self.view
        ACV.popoverPresentationController?.sourceRect = self.view.frame
        ACV.popoverPresentationController?.canOverlapSourceViewRect = true
        ACV.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        self.present(ACV, animated: true, completion: nil)
    }
    
    /// The image to export/save.
    public var SaveMe: UIImage? = nil
    
    /// Returns the subject line for possible use when exporting the gradient image.
    /// - Parameter activityViewController: Not used.
    /// - Parameter subjectForActivityType: Not used.
    /// - Returns: Subject line.
    public func activityViewController(_ activityViewController: UIActivityViewController,
                                       subjectForActivityType activityType: UIActivity.Type?) -> String
    {
        return "Fouris Exported Background Gradient"
    }
    
    /// Determines the type of object to export.
    /// - Parameter activityViewController: Not used.
    /// - Returns: Instance of the type to export. In our case, a `UIImage`.
    public func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any
    {
        return UIImage()
    }
    
    /// Returns the object to export (the type of which is determined in `activityViewControllerPlaceholderItem`.
    /// - Parameter activityViewController: Not used.
    /// - Parameter itemForActivityType: Determines how the user wants to export the image. In our case, we support
    ///                                  anything that accepts an image.
    /// - Returns: The image of the gradient.
    public func activityViewController(_ activityViewController: UIActivityViewController,
                                itemForActivityType activityType: UIActivity.ActivityType?) -> Any?
    {
        let Generated: UIImage = SaveMe!
        
        switch activityType!
        {
            case .postToTwitter:
                return Generated
            
            case .airDrop:
                return Generated
            
            case .copyToPasteboard:
                return Generated
            
            case .mail:
                return Generated
            
            case .message:
                return Generated
            
            case .postToFacebook:
                return Generated
            
            case .postToFlickr:
                return Generated
            
            case .postToTencentWeibo:
                return Generated
            
            case .postToTwitter:
                return Generated
            
            case .postToWeibo:
                return Generated
            
            case .print:
                return Generated
            
            case .markupAsPDF:
                return Generated
            
            case .saveToCameraRoll:
                return Generated
            
            default:
                return Generated
        }
    }
    
    /// Handle the close button.
    /// - Parameter sender: Not used.
    @IBAction public func HandleClosePressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var OrientationSegment: UISegmentedControl!
    @IBOutlet weak var WidthSegment: UISegmentedControl!
    @IBOutlet weak var HeightSegment: UISegmentedControl!
    @IBOutlet weak var GradientSample: UIImageView!
}
