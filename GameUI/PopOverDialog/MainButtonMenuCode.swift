//
//  MainButtonMenuCode.swift
//  Fouris
//
//  Created by Stuart Rankin on 10/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

//https://stackoverflow.com/questions/4769169/iphone-popup-menu-like-ipad-popover/32295907#32295907
class MainButtonMenuCode: UIViewController
{
    weak var Delegate: PopOverProtocol? = nil
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        ControlView.layer.borderColor = UIColor.black.cgColor
        ControlView.layer.backgroundColor = UIColor.white.cgColor
    }
    
    public func SetPlayState(IsPlaying: Bool, IsPaused: Bool)
    {
        _IsPlaying = IsPlaying
        _IsPaused = IsPaused
        let PlayTitle = IsPlaying ? "Stop" : "Play"
        let PauseTitle = IsPaused ? "Resume" : "Pause"
        SetLabels(ForPlay: PlayTitle, ForPause: PauseTitle)
    }
    
    private var _IsPlaying: Bool = false
    private var _IsPaused: Bool = false
    
    public func SetLabels(ForPlay: String, ForPause: String)
    {
        PopOverPlayButton.setTitle(ForPlay, for: UIControl.State.normal)
        PopOverPauseButton.setTitle(ForPause, for: UIControl.State.normal)
    }
    
    @IBAction func HandleAboutPressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.RunAbout)
        }
    }
    
    @IBAction func HandleSelectGamePressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.RunSelectGame)
        }
    }
    
    @IBAction func HandleSettingsPressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.RunSettings)
        }
    }
    
    @IBAction func HandleAttractPressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.RunInAttractMode)
        }
    }
    
    @IBAction func HandleCameraPressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.TakePicture)
        }
    }
    
    @IBAction func HandleVideoPressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.MakeVideo)
        }
    }
    
    @IBAction func HandlePlayPressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            let Command = self._IsPlaying ? PopOverCommands.StopPlaying : PopOverCommands.StartPlaying
            self.Delegate?.RunPopOverCommand(Command)
        }
    }
    
    @IBAction func HandlePausePressed(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            let Command = self._IsPaused ? PopOverCommands.ResumePlaying : PopOverCommands.PausePlaying
            self.Delegate?.RunPopOverCommand(Command)
        }
    }
    
    @IBAction func HandleCloseMainMenu(_ sender: Any)
    {
        self.dismiss(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        Delegate?.ResetMainButton()
        Delegate?.RunPopOverCommand(.PopOverClosed)
        super.viewWillDisappear(animated)
    }
    
    @IBOutlet weak var PopOverPauseButton: UIButton!
    @IBOutlet weak var PopOverPlayButton: UIButton!
    @IBOutlet weak var ControlView: UIView!
}

enum PopOverCommands: String, CaseIterable
{
    case PopOverClosed = "PopOverClosed"
    case RunSelectGame = "RunSelectGame"
    case RunAbout = "RunAbout"
    case RunSettings = "RunSettings"
    case RunInAttractMode = "RunInAttractMode"
    case StartPlaying = "StartPlaying"
    case StopPlaying = "StopPlaying"
    case PausePlaying = "PausePlaying"
    case ResumePlaying = "ResumePlaying"
    case TakePicture = "TakePicture"
    case MakeVideo = "MakeVideo"
}
