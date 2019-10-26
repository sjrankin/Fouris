//
//  MainButtonMenuCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Code to run the pop over dialog that functions as the main menu.
/// - Note: See [Popup Menu](https://stackoverflow.com/questions/4769169/iphone-popup-menu-like-ipad-popover/32295907#32295907)
class MainButtonMenuCode: UIViewController
{
    /// Delegate that gets the commands from the user.
    public weak var Delegate: PopOverProtocol? = nil
    
    /// UI initialization.
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        ControlView.layer.borderColor = UIColor.black.cgColor
        ControlView.layer.backgroundColor = UIColor.white.cgColor
    }
    
    /// Sets the play state for the Stop/Play and Resume/Pause buttons.
    /// - Parameter IsPlaying: The playing state.
    /// - Parameter IsPaused: The paused state.
    public func SetPlayState(IsPlaying: Bool, IsPaused: Bool)
    {
        _IsPlaying = IsPlaying
        _IsPaused = IsPaused
        let PlayTitle = IsPlaying ? "Stop" : "Play"
        let PauseTitle = IsPaused ? "Resume" : "Pause"
        SetLabels(ForPlay: PlayTitle, ForPause: PauseTitle)
    }
    
    /// Holds the playing state.
    private var _IsPlaying: Bool = false
    /// Holds the paused state.
    private var _IsPaused: Bool = false
    
    /// Set label titles for the play and pause buttons.
    /// - Parameter ForPlay: The text for the play menu.
    /// - Parameter ForPause: The text for the pause menu.
    public func SetLabels(ForPlay: String, ForPause: String)
    {
        PopOverPlayButton.setTitle(ForPlay, for: UIControl.State.normal)
        PopOverPauseButton.setTitle(ForPause, for: UIControl.State.normal)
    }
    
    /// Handle the about button pressed. Closes the dialog, resets the main button, and sends the appropriate command.
    /// - Parameter sender: Not used.
    @IBAction public func HandleAboutPressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.RunAbout)
        }
    }
    
    /// Handle the select game button pressed. Closes the dialog, resets the main button, and sends the appropriate command.
    /// - Parameter sender: Not used.
    @IBAction public func HandleSelectGamePressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.RunSelectGame)
        }
    }
    
    /// Handle the settings button pressed. Closes the dialog, resets the main button, and sends the appropriate command.
    /// - Parameter sender: Not used.
    @IBAction public func HandleSettingsPressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.RunSettings)
        }
    }
    
    /// Handle the attract button pressed. Closes the dialog, resets the main button, and sends the appropriate command.
    /// - Parameter sender: Not used.
    @IBAction public func HandleAttractPressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.RunInAttractMode)
        }
    }
    
    /// Handle the about camera pressed. Closes the dialog, resets the main button, and sends the appropriate command.
    /// - Parameter sender: Not used.
    @IBAction public func HandleCameraPressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.TakePicture)
        }
    }
    
    /// Handle the video button pressed. Closes the dialog, resets the main button, and sends the appropriate command.
    /// - Note: The receiver treats this button as a toggle button - the first press starts the video and the second
    ///         press stops the video.
    /// - Parameter sender: Not used.
    @IBAction public func HandleVideoPressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.MakeVideo)
        }
    }
    
    /// Handle the play button pressed. Closes the dialog, resets the main button, and sends the appropriate command.
    /// - Parameter sender: Not used.
    @IBAction public func HandlePlayPressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            let Command = self._IsPlaying ? PopOverCommands.StopPlaying : PopOverCommands.StartPlaying
            self.Delegate?.RunPopOverCommand(Command)
        }
    }
    
    /// Handle the pause button pressed. Closes the dialog, resets the main button, and sends the appropriate command.
    /// - Parameter sender: Not used.
    @IBAction public func HandlePausePressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            let Command = self._IsPaused ? PopOverCommands.ResumePlaying : PopOverCommands.PausePlaying
            self.Delegate?.RunPopOverCommand(Command)
        }
    }
    
    /// Handle the flame button pressed. Opens a debug menu. Adjusts the size of the main pop-over menu and adds new buttons.
    /// - Note: [Adjust Pop-Over Size](https://stackoverflow.com/questions/29449998/how-do-i-adjust-my-popover-to-the-size-of-the-content-in-my-tableview-in-swift)
    /// - Parameter sender: Not used.
    @IBAction public func HandleFlameButton(_ sender: Any)
    {
        if ShowingDebug
        {
            if ToggleRegionButton != nil
            {
                ButtonStack.removeArrangedSubview(ToggleRegionButton!)
                ToggleRegionButton?.removeFromSuperview()
                ToggleRegionButton = nil
            }
            if ToggleGridButton != nil
            {
                ButtonStack.removeArrangedSubview(ToggleGridButton!)
                ToggleGridButton?.removeFromSuperview()
                ToggleGridButton = nil
            }
            if GenerateBoardsButton != nil
            {
                ButtonStack.removeArrangedSubview(GenerateBoardsButton!)
                GenerateBoardsButton?.removeFromSuperview()
                GenerateBoardsButton = nil
            }
            self.preferredContentSize = CGSize(width: 300, height: 470)
            ShowingDebug = false
        }
        else
        {
            self.preferredContentSize = CGSize(width: 300, height: 600)
            ShowingDebug = true
            ToggleRegionButton = UIButton()
            ToggleRegionButton?.contentHorizontalAlignment = .left
            ToggleRegionButton?.setTitleColor(UIColor.systemRed, for: UIControl.State.normal)
            ToggleRegionButton?.titleLabel?.textColor = UIColor.systemRed
            ToggleRegionButton?.setTitle("Toggle Region", for: UIControl.State.normal)
            ToggleRegionButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30.0)
            ToggleRegionButton?.addTarget(self, action: #selector(HandleRegionButton(_:)), for: UIControl.Event.touchUpInside)
            var Index = ButtonStack.arrangedSubviews.count
            ButtonStack.insertArrangedSubview(ToggleRegionButton!, at: Index)
            
            ToggleGridButton = UIButton()
            ToggleGridButton?.contentHorizontalAlignment = .left
            ToggleGridButton?.setTitleColor(UIColor.systemRed, for: UIControl.State.normal)
            ToggleGridButton?.titleLabel?.textColor = UIColor.systemRed
            ToggleGridButton?.setTitle("Toggle Grid", for: UIControl.State.normal)
            ToggleGridButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30.0)
            ToggleGridButton?.addTarget(self, action: #selector(HandleGridButton(_:)), for: UIControl.Event.touchUpInside)
            Index = Index + 1
            ButtonStack.insertArrangedSubview(ToggleGridButton!, at: Index)
            
            GenerateBoardsButton = UIButton()
            GenerateBoardsButton?.contentHorizontalAlignment = .left
            GenerateBoardsButton?.setTitleColor(UIColor.systemRed, for: UIControl.State.normal)
            GenerateBoardsButton?.titleLabel?.textColor = UIColor.systemRed
            GenerateBoardsButton?.setTitle("Create Boards", for: UIControl.State.normal)
            GenerateBoardsButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30.0)
            GenerateBoardsButton?.addTarget(self, action: #selector(HandleBoardsButton(_:)), for: UIControl.Event.touchUpInside)
            Index = Index + 1
            ButtonStack.insertArrangedSubview(GenerateBoardsButton!, at: Index)
        }
    }
    
    /// The region button - created on the fly as needed.
    private var ToggleRegionButton: UIButton? = nil
    /// The toggle grid button - created on the fly as needed.
    private var ToggleGridButton: UIButton? = nil
    /// The create boards button - created on the fly as needed.
    private var GenerateBoardsButton: UIButton? = nil
    
    /// Handle the show debug region button pressed. Closes the dialog, resets the main button, and sends the appropriate command.
    /// - Parameter sender: Not used.
    @objc public func HandleRegionButton(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.ToggleRegions)
        }
    }
    
    /// Handle the debug grid button pressed. Closes the dialog, resets the main button, and sends the appropriate command.
    /// - Parameter sender: Not used.
    @objc public func HandleGridButton(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.ToggleGrid)
        }
    }
    
    /// Handle the generate boards button pressed. Closes the dialog, resets the main button, and sends the appropriate command.
    /// - Parameter sender: Not used.
    @objc public func HandleBoardsButton(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.CreateBoards)
        }
    }
    
    /// Holds the show debug flag.
    private var ShowingDebug = false
    
    /// Handle the close menu button.
    @IBAction public func HandleCloseMainMenu(_ sender: Any)
    {
        self.dismiss(animated: true)
    }
    
    /// Handle the view will disappear message. If we got this far, send a `.PopOverClosed` message.
    override public func viewWillDisappear(_ animated: Bool)
    {
        Delegate?.ResetMainButton()
        Delegate?.RunPopOverCommand(.PopOverClosed)
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var ButtonStack: UIStackView!
    @IBOutlet weak var PopOverPauseButton: UIButton!
    @IBOutlet weak var PopOverPlayButton: UIButton!
    @IBOutlet weak var ControlView: UIView!
}

/// Commands that may be sent from the pop-over menu to the main program.
enum PopOverCommands: String, CaseIterable
{
    /// Pop-over closed - usually sent because the user canceled the menu.
    case PopOverClosed = "PopOverClosed"
    /// Run the select game dialog.
    case RunSelectGame = "RunSelectGame"
    /// Run the about dialog.
    case RunAbout = "RunAbout"
    /// Run the settings dialog.
    case RunSettings = "RunSettings"
    /// Run Fouris in attract mode.
    case RunInAttractMode = "RunInAttractMode"
    /// Start playing Fouris.
    case StartPlaying = "StartPlaying"
    /// Stop playing Fouris.
    case StopPlaying = "StopPlaying"
    /// Pause playing Fouris.
    case PausePlaying = "PausePlaying"
    /// Resume playing Fouris.
    case ResumePlaying = "ResumePlaying"
    /// Take a picture of the game board.
    case TakePicture = "TakePicture"
    /// Make a video of the screen. (Command is a toggle so the first instance will start the video and the second instance
    /// will stop the video.)
    case MakeVideo = "MakeVideo"
    /// Run the flame action button (for one-off debug actions).
    case RunFlameAction = "RunFlameAction"
    /// Generate board images.
    case CreateBoards = "CreateBoards"
    /// Toggle debug region visibility.
    case ToggleRegions = "ToggleRegions"
    /// Toggle the background debug grid.
    case ToggleGrid = "ToggleGrid"
}
