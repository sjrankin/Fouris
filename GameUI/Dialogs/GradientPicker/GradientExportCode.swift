//
//  GradientExportCode.swift
//  Fouris
//  Adapted from BumpCamera.
//
//  Created by Stuart Rankin on 9/3/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class GradientExportCode: UIViewController, UIActivityItemSource, GradientPickerProtocol
{
    weak var GradientDelegate: GradientPickerProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ControlView.layer.borderColor = UIColor.black.cgColor
        SampleView.layer.borderColor = UIColor.black.cgColor
        
        if !GradientToExport.isEmpty
        {
            ExportButton.isEnabled = true
            DrawSample()
        }
    }
    
    var GradientToExport: String = ""
    var SaveMe: UIImage? = nil

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
    
    func EditedGradient(_ Edited: String?, Tag: Any?)
    {
        //Not used in this class.
    }
    
    func GradientToEdit(_ Edited: String?, Tag: Any?)
    {
        if let TheGradient = Edited
        {
            GradientToExport = TheGradient
        }
    }
    
    func SetStop(StopColorIndex: Int)
    {
        //Not used in this class.
    }
    
    func DrawSample()
    {
        let IsVertical = OrientationSegment.selectedSegmentIndex == 0
        let Width = Int(SampleView.bounds.size.width)
        let Height = Int(SampleView.bounds.size.height)
        let ImageFrame = CGRect(x: 0, y: 0, width: Width, height: Height)
        let SampleImage = GradientManager.CreateGradientImage(From: GradientToExport, WithFrame: ImageFrame,
                                                              IsVertical: IsVertical)
        SampleView.image = SampleImage
    }
    
    @IBAction func HandleOrientationChanged(_ sender: Any)
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
        self.present(ACV, animated: true, completion: nil)

    }
    
    @IBAction func HandleClosePressed(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var ControlView: UIView!
    @IBOutlet weak var SampleView: UIImageView!
    @IBOutlet weak var OrientationSegment: UISegmentedControl!
    @IBOutlet weak var ExportButton: UIButton!
    @IBOutlet weak var WidthSegment: UISegmentedControl!
    @IBOutlet weak var HeightSegment: UISegmentedControl!
}
