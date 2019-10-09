//
//  GradientExport2.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GradientExport2: UIViewController, GradientPickerProtocol, UIActivityItemSource
{
    weak var GradientDelegate: GradientPickerProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        GradientSample.layer.borderColor = UIColor.black.cgColor
        DrawSample()
    }
    
    func DrawSample()
    {
        let IsVertical = OrientationSegment.selectedSegmentIndex == 0
        let ImageFrame = CGRect(x: 0, y: 0, width: GradientSample.frame.width, height: GradientSample.frame.height)
        let Sample = GradientManager.CreateGradientImage(From: GradientToExport, WithFrame: ImageFrame,
                                                     IsVertical: IsVertical)
        GradientSample.image = Sample
    }
    
    func EditedGradient(_ Edited: String?, Tag: Any?)
    {
        //Not used.
    }
    
    func GradientToEdit(_ Edited: String?, Tag: Any?)
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
    
    var GradientToExport: String = ""
    
    func SetStop(StopColorIndex: Int)
    {
        //Not used.
    }
    
    @IBAction func HandleGradientOrientationChanged(_ sender: Any)
    {
        DrawSample()
    }
    
    @IBAction func HandleExportPressed(_ sender: Any)
    {
        let IsVertical = OrientationSegment.selectedSegmentIndex == 0
        let Width = Int(Double(pow(Double(2.0), Double(WidthSegment.selectedSegmentIndex + 8))))
        let Height = Int(Double(pow(Double(2.0), Double(HeightSegment.selectedSegmentIndex + 8))))
        print("Exporting image of size \(Width)x\(Height)")
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
    
    var SaveMe: UIImage? = nil
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.Type?) -> String
    {
        return "Fouris Exported Background Gradient"
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any
    {
        return UIImage()
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController,
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
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var OrientationSegment: UISegmentedControl!
    @IBOutlet weak var WidthSegment: UISegmentedControl!
    @IBOutlet weak var HeightSegment: UISegmentedControl!
    @IBOutlet weak var GradientSample: UIImageView!
}
