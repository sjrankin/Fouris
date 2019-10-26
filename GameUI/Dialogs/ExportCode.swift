//
//  ExportCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/5/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Code to handle the UI for exporting various objects.
/// - Note: Not fully implemented yet.
class ExportCode: UIViewController, ThemeEditingProtocol
{
    /// Initialize the UI.
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        ContentsViewer.text = ""
        ContentsTitle.isHidden = true
        ContentsBox.layer.borderColor = UIColor.black.cgColor
        HistoryTypeSegment.selectedSegmentIndex = 0
    }
    
    /// The Current theme.
    /// - Parameter Theme: The theme that the user has an option to export.
    public func EditTheme(Theme: ThemeDescriptor2)
    {
        UserTheme = Theme
    }

    /// The Current theme.
    /// - Parameter Theme: The theme that the user has an option to export.
    /// - Parameter PieceID: Not used.
    public func EditTheme(Theme: ThemeDescriptor2, PieceID: UUID)
    {
        UserTheme = Theme
    }
    
    /// Not used in this class.
    public func EditResults(_ Edited: Bool, ThemeID: UUID, PieceID: UUID?)
    {
        //Not used in this class.
    }
    
    /// Holds the theme to export.
    private var UserTheme: ThemeDescriptor2? = nil
    
    /// Dump the theme in xml format to a view.
    /// - Parameter sender: Not used.
    @IBAction public func HandleViewThemePressed(_ sender: Any)
    {
        ShowingVisuals = false
        ShowingHistory = false
        let ThemeString = UserTheme!.ToString()
        ContentsViewer.text = ThemeString
        ContentsTitle.text  = "Theme Contents"
        ContentsTitle.isHidden = false
    }
    
    /// Dump piece visuals in xml format to a view.
    /// - Parameter sender: Not used.
    @IBAction public func HandleViewVisualsPressed(_ sender: Any)
    {
        ShowingHistory = false
        ShowingVisuals = true
        let VisualIndex = VisualsSegment.selectedSegmentIndex
        var VisDump = ""
        var Title = ""
        if VisualIndex == 0
        {
            Title = "User-Defined Visuals"
            VisDump = PieceVisualManager2.UserVisuals!.ToString()
        }
        else
        {
            Title = "Default Visuals"
            VisDump = PieceVisualManager2.DefaultVisuals!.ToString()
        }
        ContentsViewer.text = VisDump
        ContentsTitle.text = Title
        ContentsTitle.isHidden = false
    }
    
    /// Dump history in xml format to a view.
    /// - Parameter sender: Not used.
    @IBAction public func HandleViewHistoryPressed(_ sender: Any)
    {
        ShowingVisuals = false
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
    
    /// Showing history flag.
    private var ShowingHistory = false
    /// Showing visuals flag.
    private var ShowingVisuals = false
    
    /// Export the current theme.
    /// - Parameter sender: Not used.
    @IBAction public func HandleExportThemeButton(_ sender: Any)
    {
    }
    
    /// Export the history data.
    /// - Parameter sender: Not used.
    @IBAction public func HandleExportHistoryButton(_ sender: Any)
    {
    }
    
    /// Export the visual theme.
    /// - Parameter sender: Not used.
    @IBAction public func HandleExportVisualsButton(_ sender: Any)
    {
    }
    
    /// Update which history is being viewed.
    /// - Parameter sender: Not used.
    @IBAction public func HandleHistoryViewChanged(_ sender: Any)
    {
        if ShowingHistory
        {
            HandleViewHistoryPressed(sender)
        }
    }
    
    /// Update which visuals are being viewed.
    /// - Parameter sender: Not used.
    @IBAction func HandleVisualViewChanged(_ sender: Any)
    {
        if ShowingVisuals
        {
            HandleViewVisualsPressed(sender)
        }
    }
    
    /// Close the dialog.
    /// - Parameter sender: Not used.
    @IBAction func HandleCloseButton(_ sender: Any)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var VisualsSegment: UISegmentedControl!
    @IBOutlet weak var HistoryTypeSegment: UISegmentedControl!
    @IBOutlet weak var ContentsBox: UIView!
    @IBOutlet weak var ContentsTitle: UILabel!
    @IBOutlet weak var ContentsViewer: UITextView!
}
