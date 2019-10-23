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
    
    //https://stackoverflow.com/questions/29449998/how-do-i-adjust-my-popover-to-the-size-of-the-content-in-my-tableview-in-swift
    @IBAction func HandleFlameButton(_ sender: Any)
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
    
    var ToggleRegionButton: UIButton? = nil
    var ToggleGridButton: UIButton? = nil
    var GenerateBoardsButton: UIButton? = nil
    
    @objc func HandleRegionButton(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.ToggleRegions)
        }
    }
    
    @objc func HandleGridButton(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.ToggleGrid)
        }
    }
    
    @objc func HandleBoardsButton(_ sender: Any)
    {
        self.dismiss(animated: true)
        {
            self.Delegate?.ResetMainButton()
            self.Delegate?.RunPopOverCommand(.CreateBoards)
        }
    }
    
    var ShowingDebug = false
    
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
    
    @IBOutlet weak var ButtonStack: UIStackView!
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
    case RunFlameAction = "RunFlameAction"
    case CreateBoards = "CreateBoards"
    case ToggleRegions = "ToggleRegions"
    case ToggleGrid = "ToggleGrid"
}
