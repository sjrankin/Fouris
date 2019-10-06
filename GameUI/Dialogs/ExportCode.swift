//
//  ExportCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

class ExportCode: UIViewController, ThemeEditingProtocol
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ContentsViewer.text = ""
        ContentsTitle.isHidden = true
        ContentsBox.layer.borderColor = UIColor.black.cgColor
        HistoryTypeSegment.selectedSegmentIndex = 0
    }
    
    func EditTheme(Theme: ThemeDescriptor2)
    {
        UserTheme = Theme
    }
    
    func EditTheme(Theme: ThemeDescriptor2, PieceID: UUID)
    {
        UserTheme = Theme
    }
    
    func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //Not used in this class.
    }
    
    var UserTheme: ThemeDescriptor2? = nil
    
    @IBAction func HandleViewThemePressed(_ sender: Any)
    {
        ShowingHistory = false
        let ThemeString = UserTheme!.ToString()
        ContentsViewer.text = ThemeString
        ContentsTitle.text  = "Theme Contents"
        ContentsTitle.isHidden = false
    }
    
    @IBAction func HandleViewHistoryPressed(_ sender: Any)
    {
        ShowingHistory = true
        let HistoryIndex = HistoryTypeSegment.selectedSegmentIndex
        var HistoryDump = ""
        var Title = ""
        if HistoryIndex == 0
        {
            Title = "User Game Statistics"
            HistoryDump = HistoryManager.GameHistory!.ToString()
        }
        else
        {
            Title = "AI Game Statistics"
            HistoryDump = HistoryManager.AIGameHistory!.ToString()
        }
        ContentsViewer.text = HistoryDump
        ContentsTitle.text = Title
        ContentsTitle.isHidden = false
    }
    
    var ShowingHistory = false
    
    @IBAction func HandleExportThemeButton(_ sender: Any)
    {
    }
    
    @IBAction func HandleExportHistoryButton(_ sender: Any)
    {
    }
    
    @IBAction func HandleHistoryViewChanged(_ sender: Any)
    {
        if ShowingHistory
        {
            HandleViewHistoryPressed(sender)
        }
    }
    
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var HistoryTypeSegment: UISegmentedControl!
    @IBOutlet weak var ContentsBox: UIView!
    @IBOutlet weak var ContentsTitle: UILabel!
    @IBOutlet weak var ContentsViewer: UITextView!
}
