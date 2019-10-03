//
//  MainViewController.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/26/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit
import MultipeerConnectivity
import UIKit
import ReplayKit

class MainViewController: UIViewController,
    UINavigationControllerDelegate,                     //Protocol for some system-level kits (such as saving photos).
    RPPreviewViewControllerDelegate,                    //Protocol for screen recording.
    GameUINotificationProtocol,                         //Protocol for communicating from the game engine (and everything below it) to the UI.
    GameAINotificationProtocol,                         //Protocol for communication from the game AI engine to the UI.
    MainDelegate,                                       //Protocol for exporting some functionality defined in this class.
    ControlProtocol,                                    //Protocol for receiving motion and other commands from the motion controller.
    DebugDelegate,                                      //Protocol for sending debug information to a local window.
    GameViewRequestProtocol,                            //Protocol for game views to request information from the controller.
    SmoothMotionProtocol,                               //Protocol for handling smooth motions.
    TDebugProtocol,                                     //Protocol for the debug client to talk to this class.
    StepperHelper,                                      //Protocol for the stepper to display data for the user.
    GameSelectorProtocol,                               //Protocol for selecting games.
    UITouchImageDelegate,                               //Protocol for touch image presses.
    SettingsChangedProtocol,                            //Protocol for receiving settings change notifications.
    ThemeUpdatedProtocol                                //Protocol for receiving updates to the theme.
{
    // MARK: Globals.
    
    /// 3D game view instance.
    var GameView3D: View3D? = nil
    
    /// Game logic instance.
    var Game: GameLogic!
    
    /// Theme manager.
    var Themes: ThemeManager!
    
    /// AI test data table.
    var AIData: AITestTable? = nil
    
    /// Currently playing flag.
    var CurrentlyPlaying: Bool = false
    
    /// Paused flag.
    var IsPaused: Bool = false
    
    /// In attract (eg, AI) mode.
    var InAttractMode: Bool = true
    
    /// The set of pieces to use.
    var GamePieces = [MetaPieces.Standard]
    
    #if false
    /// The current level the user is playing.
    var CurrentLevel = LevelTypes.ReallyEasy
    
    /// The current mode.
    var CurrentMode = ModeTypes.AttractMode
    #endif
    
    /// Multi-peer manager for debugging.
    var MPMgr: MultiPeerManager!
    
    /// Local commands for debugging.
    var LocalCommands: ClientCommands!
    
    /// Message handler for debugging.
    var MsgHandler: MessageHandler!
    
    /// Prefix for use with the TDebug program.
    var TDebugPrefix: UUID!
    
    // MARK: UI-required functions.
    
    /// Handle the viewDidLoad event.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        Versioning.PublishVersion(">")
        
        let _ = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(IncrementSeconds), userInfo: nil, repeats: true)
        
        #if true
        let BadgeCount = Versioning.Build
        let App = UIApplication.shared
        let NotCen = UNUserNotificationCenter.current()
        NotCen.requestAuthorization(options: [.badge, .alert, .sound], completionHandler:
            {
                (granted, error) in
                if granted
                {
                    OperationQueue.main.addOperation
                        {
                            App.registerForRemoteNotifications()
                            App.applicationIconBadgeNumber = BadgeCount
                    }
                }
                else
                {
                    print("Not authorized to display badges.")
                }
        }
        )
        #endif
        
        #if false
        State.Initialize(WithDelegate: self)
        TDebugPrefix = UUID()
        MPMgr = MultiPeerManager()
        MPMgr.Delegate = self
        let HostName = "iOS Tetris"
        DebugClient.Initialize(With: MPMgr, HostName: HostName)
        DebugClient.Delegate = self
        MsgHandler = MessageHandler(self)
        LocalCommands = ClientCommands()
        MessageHelper.Initialize(TDebugPrefix)
        DebugClient.SendPreformattedCommand(MessageHelper.MakeResetTDebugUICommand())
        #endif
        
        Settings.Initialize()
        PieceManager.Initialize()
        Themes = ThemeManager()
        Themes.Initialize()
        UserTheme = Themes.UserTheme
        Themes.SubscribeToChanges(Subscriber: "MainViewController", SubscribingObject: self)
        PieceVisualManager.Initialize()
        RecentlyUsedColors.Initialize(WithLimit: Settings.GetMostRecentlyUsedColorListCapacity())
        HistoryManager.Initialize()
        InitializeUI()
        AIData = AITestTable()
        
        CurrentBaseGameType = UserTheme!.GameType
        
        InitializeGameUI()
        setNeedsStatusBarAppearanceUpdate()
        
        Stepper.Delegate = self
    }
    
    /// Layout complete. Save certain information.
    override func viewDidLayoutSubviews()
    {
        OriginalGameViewBounds = GameViewContainer.bounds
        OrignalTopToolbarBounds = GameControlView.bounds
        OriginalMotionControlBounds = MotionControlView.bounds
        if !VersionShown
        {
            VersionShown = true
            if Settings.GetShowVersionBox()
            {
                VersionBoxShowing = true
                GameTextOverlay?.ShowVersionBox(WithString: Versioning.MakeSimpleVersionString())
            }
        }
    }
    
    /// Called when the version box disappears.
    func VersionBoxDisappeared()
    {
        VersionBoxShowing = false
    }
    
    /// Version box is showing flag.
    var VersionBoxShowing = true
    
    /// Prevents `viewDidLayoutSubviews` from showing more than one version box.
    var VersionShown = false
    
    /// Number of seconds the instance has been running.
    var InstanceSeconds: Int = 0
    
    /// Game instance second counter. Used to keep track of how long the program (not necessarily game) is running. If the proper
    /// settings are in place, the seconds are displayed in the UI.
    @objc func IncrementSeconds()
    {
        InstanceSeconds = InstanceSeconds + 1
        if Settings.ShowInstanceSeconds()
        {
            if FPSLabel.alpha > 0.0
            {
                FPSLabel.text = "\(InstanceSeconds)"
            }
        }
    }
    
    var UserTheme: ThemeDescriptor? = nil
    
    /// If the view is disappearing, save data as it may not come back.
    /// - Parameter animated: Passed to the super class.
    override func viewDidDisappear(_ animated: Bool)
    {
        Themes.SaveThemes()
        super.viewDidDisappear(animated)
    }
    
    /// Initialize the game view and game UI.
    func InitializeGameUI()
    {
        //Initialize buttons.
        EnableFreezeInPlaceButton(false)
        
        InitializeSlideIn()
        Game = GameLogic(BaseGame: CurrentBaseGameType, UserTheme: UserTheme!, EnableAI: false)
        Game.UIDelegate = self
        Game.AIDelegate = self
        
        //Initialize the 3D game viewer.
        GameView3D = GameUISurface3D
        GameView3D?.Initialize(With: Game!.GameBoard!, Theme: Themes, BaseType: CurrentBaseGameType)
        GameView3D?.Owner = self
        GameView3D?.SmoothMotionDelegate = self
        Smooth3D = GameView3D
        GameUISurface3D.layer.borderColor = UIColor.black.cgColor
        GameUISurface3D.layer.borderWidth = 1.0
        
        //Initialize the game text layer.
        TextLayerView.Initialize(With: UUID.Empty, LayerFrame: TextLayerView.frame)
        GameTextOverlay = TextOverlay(Device: UIDevice.current.userInterfaceIdiom)
        GameTextOverlay?.MainClassDelegate = self
        GameTextOverlay?.SetControls(NextLabel: NextPieceLabelView,
                                     ScoreLabel: ScoreLabelView,
                                     CurrentScoreLabel: CurrentScoreLabelView,
                                     HighScoreLabel: HighScoreLabelView,
                                     GameOverLabel: GameOverLabelView,
                                     PressPlayLabel: PressPlayLabelView,
                                     PauseLabel: PauseLabelView,
                                     PieceControl: NextPieceViewControl,
                                     VersionBox: TextVersionBox,
                                     VersionLabel: VersionTextLabel)
        NextPieceView.layer.backgroundColor = UIColor.clear.cgColor
        NextPieceView.layer.borderColor = UIColor.clear.cgColor
        GameTextOverlay?.ShowPressPlay(Duration: 0.7)
        GameTextOverlay?.HideNextLabel()
        
        //Initialize view backgrounds.
        GameControlView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.ReallyDarkGray)
        MotionControlView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.ReallyDarkGray)
        
        let AutoStartDuration = UserTheme!.AutoStartDuration
        let _ = Timer.scheduledTimer(timeInterval: AutoStartDuration, target: self,
                                     selector: #selector(AutoStartInAttractMode),
                                     userInfo: nil, repeats: false)
        
        InitializeGestures()
    }
    
    /// Sets the enable state of the freeze in place action button.
    /// - Note: This button is provided for certain games that need a way to freeze a piece in place that may not be near
    ///         near any other piece.
    /// - Parameter DoEnable: The enable flag for the button.
    func EnableFreezeInPlaceButton(_ DoEnable: Bool)
    {
        if DoEnable
        {
        GameUISurface3D?.AppendButton(Which: .FreezeButton)
        }
        else
        {
            GameUISurface3D?.RemoveButton(Which: .FreezeButton)
        }
        /*
        FreezeInPlaceButton.isUserInteractionEnabled = DoEnable
        FreezeInPlaceButton.isHidden = !DoEnable
 */
    }
    
    var GameTextOverlay: TextOverlay? = nil
    
    /// Initialize the non-game UI (things that are not directly related to the game board).
    func InitializeUI()
    {
        Settings.AddSubscriber(For: "Main", NewSubscriber: self)
        if Settings.ShowFPSInUI()
        {
            FPSLabel.text = ""
            FPSLabel.alpha = 1.0
            FPSLabel.isUserInteractionEnabled = true
        }
        else
        {
            FPSLabel.alpha = 0.0
            FPSLabel.isUserInteractionEnabled = false
        }
        let Tap = UITapGestureRecognizer(target: self, action: #selector(FPSTapped))
        Tap.numberOfTouchesRequired = 1
        FPSLabel.addGestureRecognizer(Tap)
        SlideInCameraControlBox.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.WhiteSmoke)
        SlideInCameraControlBox.layer.borderColor = UIColor.black.cgColor
        ShowCameraControls()
    }
    
    /// Handle taps on the FPS text display. This toggles the contents from frames/second to instance seconds.
    /// - Parameter Recognizer: The tap gesture recognizer.
    @objc func FPSTapped(Recognizer: UIGestureRecognizer)
    {
        if Recognizer.state == .ended
        {
            let OldShowSeconds = Settings.ShowInstanceSeconds()
            Settings.SetShowInstanceSeconds(NewValue: !OldShowSeconds)
        }
    }
    
    /// Set camera button visibility depending on the settings.
    func ShowCameraControls()
    {
        VideoButton.isHidden = !Settings.GetShowCameraControls()
        VideoButton.isUserInteractionEnabled = Settings.GetShowCameraControls()
        CameraButton.isHidden = !Settings.GetShowCameraControls()
        CameraButton.isUserInteractionEnabled = Settings.GetShowCameraControls()
        if Settings.GetShowCameraControls()
        {
            SlideInCameraControlBox.backgroundColor = ColorServer.ColorFrom(ColorNames.WhiteSmoke)
                    SlideInCameraControlBox.layer.borderColor = UIColor.black.cgColor
            SlideInCameraControlBox.alpha = 1.0
            SlideInCameraControlBox.isUserInteractionEnabled = true
        }
        else
        {
            SlideInCameraControlBox.alpha = 0.0
            SlideInCameraControlBox.isUserInteractionEnabled = false
        }
    }
    
    private var OriginalGameViewBounds: CGRect!
    
    private var OrignalTopToolbarBounds: CGRect!
    
    /// Set top toolbar visibility. Also sets the mode in which a long press at the top of the game view shows the slide-in menu.
    func ShowTopToolbar()
    {
        
    }
    
    private var OriginalMotionControlBounds: CGRect!
    
    /// Set motion control visibility.
    func ShowMotionControls()
    {
        let DoShow = Settings.GetShowMotionControls()
        if DoShow
        {
            print("Showing Motion Controls")
            print("  MotionControlView.frame=\((OriginalMotionControlBounds)!)")
            print("  GameView.frame=\((OriginalGameViewBounds)!)")
                        MotionControlView.isHidden = false
            MotionControlView.frame = OriginalMotionControlBounds
            GameViewContainer.frame = OriginalGameViewBounds
        }
        else
        {
            #if true
                        let NewGameHeight = GameViewContainer.frame.height + OriginalMotionControlBounds.height
            print("Hiding Motion Controls")
            print("  NewGameHeight=\(NewGameHeight)")
            let NewMotionControlFrame = CGRect(x: 0, y: self.MotionControlView.frame.height, width: self.MotionControlView.frame.width,
                                               height: 0)
            let NewGameViewFrame = CGRect(x: 0, y: self.OriginalGameViewBounds.height,
                                          width: self.OriginalGameViewBounds.width,
                                          height: NewGameHeight)
            print("  NewMotionControlFrame=\(NewMotionControlFrame)")
            print("  NewGameViewFrame=\(NewGameViewFrame)")
            UIView.animate(withDuration: 1.0,
                           animations:
                {
                    self.MotionControlView.frame = NewMotionControlFrame
                    self.GameViewContainer.frame = NewGameViewFrame
            }, completion:
                {
                    _ in
                    self.MotionControlView.frame = NewMotionControlFrame
                    self.GameViewContainer.frame = NewGameViewFrame
            })
            #else
            MotionControlView.isHidden = true
            MotionControlView.frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            let NewGameViewHeight = GameViewContainer.frame.height + OriginalMotionControlBounds.height
            GameViewContainer.frame = CGRect(x: 0, y: 0, width: GameViewContainer.frame.width, height: NewGameViewHeight)
            #endif
        }
    }
    
    /// Handle changed settings.
    /// - Parameter Field: The settings field that changed.
    /// - Parameter NewValue: The new value for the specified field.
    func SettingChanged(Field: SettingsFields, NewValue: Any)
    {
        //print("Setting \(Field) changed.")
        switch Field
        {
            case .ShowCameraControls:
                ShowCameraControls()
            
            case .ShowTopToolbar:
                ShowTopToolbar()
            
            case .ShowMotionControls:
                ShowMotionControls()
            
            case .ShowFPSInUI:
                let DoShowFPS = NewValue as! Bool
                if DoShowFPS
                {
                    FPSLabel.text = ""
                    FPSLabel.alpha = 1.0
                    FPSLabel.isUserInteractionEnabled = true
                }
                else
                {
                    FPSLabel.alpha = 0.0
                    FPSLabel.isUserInteractionEnabled = false
            }
            case .InterfaceLanguage:
                break
        }
    }
    
    /// Initialize gesture recognizers for piece motions.
    func InitializeGestures()
    {
        let TapGesture = UITapGestureRecognizer(target: self, action: #selector(HandleTap))
        TapGesture.numberOfTouchesRequired = 1
        GameUISurface3D.addGestureRecognizer(TapGesture)
        let SwipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(HandleSwipeUp))
        SwipeUpGesture.direction = .up
        GameUISurface3D.addGestureRecognizer(SwipeUpGesture)
        let SwipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(HandleSwipeDown))
        SwipeDownGesture.direction = .down
        GameUISurface3D.addGestureRecognizer(SwipeDownGesture)
        let SwipeLeftGesture = UISwipeGestureRecognizer(target: self, action: #selector(HandleSwipeLeft))
        SwipeLeftGesture.direction = .left
        GameUISurface3D.addGestureRecognizer(SwipeLeftGesture)
        let SwipeRightGesture = UISwipeGestureRecognizer(target: self, action: #selector(HandleSwipeRight))
        SwipeRightGesture.direction = .right
        GameUISurface3D.addGestureRecognizer(SwipeRightGesture)
    }
    
    /// Handle taps in the game view. Depending on where the tap is, the piece will move in the given direction.
    /// - Note: If the version box is showing (which should happen only when the game starts), tapping will remove the version box
    ///         and immediately return.
    /// - Parameter Recognizer: The tap gesture.
    @objc func HandleTap(Recognizer: UITapGestureRecognizer)
    {
        if Recognizer.state == .ended
        {
            if VersionBoxShowing
            {
                GameTextOverlay?.HideVersionBox(Duration: 0.2)
                return
            }
            let Location = Recognizer.location(in: GameUISurface3D)
            let Point = Recognizer.location(in: GameUISurface3D)
            let HitResults = GameUISurface3D.hitTest(Point, options: [:])
            if HitResults.count > 0
            {
                let Node = HitResults[0].node
                if let PressedNode = Node as? SCNButtonNode
                {
                    if let ParentNode = GameUISurface3D.GetParentNode(Of: PressedNode)
                    {
                        if let VNode = ParentNode.GetNodeWithTag(Value: "ShapeNode")
                        {
                            VNode.HighlightButton(ResetDuration: 0.1, Delay: 0.1)
                        }
                    }
                    switch PressedNode.ButtonType
                    {
                        case .DownButton:
                        HandleMoveDownPressed()
                        
                        case .DropDownButton:
                        HandleDropDownPressed()
                        
                        case .FlyAwayButton:
                        HandleUpAndAwayPressed()
                        
                        case .FreezeButton:
                        HandleFreezeInPlacePressed()
                        
                        case .LeftButton:
                        HandleMoveLeftPressed()
                        
                        case .RightButton:
                        HandleMoveRightPressed()
                        
                        case .RotateLeftButton:
                        HandleRotateLeftPressed()
                        
                        case .RotateRightButton:
                        HandleRotateRightPressed()
                        
                        case .UpButton:
                        HandleMoveUpPressed()
                    }
                }
                return
            }
            let TapMotion = TranslateTapToMotion(TapLocation: Location, SurfaceSize: GameUISurface3D!.bounds.size)
            switch TapMotion
            {
                case .Down:
                    AI_MoveDown()
                    MoveDown()
                
                case .Up:
                    AI_MoveUp()
                    MoveUp()
                
                case .Left:
                    AI_MoveLeft()
                    MoveLeft()
                
                case .Right:
                    AI_MoveRight()
                    MoveRight()
                
                default:
                    break
            }
        }
    }
    
    /// Converts a tap into a game-related motion. For example, a tap at the top of the screen will result in
    /// the piece moving up.
    /// - Parameter TapLocation: The location of the tap.
    /// - Parameter SurfaceSize: The size of the surface where taps are recognized.
    /// - Returns: The direction corresponding to the location of the tap.
    func TranslateTapToMotion(TapLocation: CGPoint, SurfaceSize: CGSize) -> Directions
    {
        let Offset: CGFloat = 0.15
        //Check left.
        if TapLocation.x <= SurfaceSize.width * Offset
        {
            if TapLocation.y >= SurfaceSize.height * Offset && TapLocation.y <= SurfaceSize.height * (1.0 - Offset)
            {
                return .Left
            }
        }
        //Check right.
        if TapLocation.x >= SurfaceSize.width * (1.0 - Offset)
        {
            if TapLocation.y >= SurfaceSize.height * Offset && TapLocation.y <= SurfaceSize.height * (1.0 - Offset)
            {
                return .Right
            }
        }
        //Check up.
        if TapLocation.y <= SurfaceSize.height * Offset
        {
            if TapLocation.x >= SurfaceSize.width * Offset && TapLocation.x <= SurfaceSize.width * (1.0 - Offset)
            {
                return .Up
            }
        }
        //Check down.
        if TapLocation.y >= SurfaceSize.height * (1.0 - Offset)
        {
            if TapLocation.x >= SurfaceSize.width * Offset && TapLocation.x <= SurfaceSize.width * (1.0 - Offset)
            {
                return .Up
            }
        }
        return .NoDirection
    }
    
    /// Handle swipe up gestures in the game view. This is the same as an up and away event.
    ///
    /// - Parameter sender: The swipe gesture.
    @objc func HandleSwipeUp(sender: UISwipeGestureRecognizer)
    {
        if sender.state == .ended
        {
            AI_MoveUpAndAway()
            MoveUpAndAway()
        }
    }
    
    /// Handle swipe down gestures in the game view. This is the same as a drop piece event.
    ///
    /// - Parameter sender: The swipe gesture.
    @objc func HandleSwipeDown(sender: UISwipeGestureRecognizer)
    {
        if sender.state == .ended
        {
            AI_DropDown()
            DropDown()
        }
    }
    
    /// Handle swipe left gestures in the game view. This is the same as a rotate left event.
    ///
    /// - Parameter sender: The swipe gesture.
    @objc func HandleSwipeLeft(sender: UISwipeGestureRecognizer)
    {
        if sender.state == .ended
        {
            AI_RotateLeft()
            RotateLeft()
        }
    }
    
    /// Handle swipe right gestures in the game view. This is the same as a rotate right event.
    ///
    /// - Parameter sender: The swipe gesture.
    @objc func HandleSwipeRight(sender: UISwipeGestureRecognizer)
    {
        if sender.state == .ended
        {
            AI_RotateRight()
            RotateRight()
        }
    }
    
    // MARK: Functions related to AI/attract mode and debugging.
    
    func ClearAndStartAI()
    {
        #if true
        DispatchQueue.main.sync
            {
                GameView3D?.DestroyMap3D(FromBoard: Game.GameBoard!, DestroyBy: UserTheme!.DestructionMethod, MaxDuration: 1.25)
        }
        HandleStartInAIMode()
        #else
        GameView3D?.DestroyMap3D(FromBoard: Game.GameBoard!, CalledFrom: "ClearAndStartAI",
                                 DestroyBy: .FadeAway, Completion: HandleStartInAIMode)
        #endif
    }
    
    /// Start playing in AI mode.
    func HandleStartInAIMode()
    {
        Game.StopGame()
        InAttractMode = true
        Game.AIScoringMethod = .OffsetMapping
        //3D setup
        //GameView3D?.DestroyMap3D(FromBoard: Game.GameBoard!, CalledFrom: "HandleStartInAIMode", DestroyBy: .FadeAway)
        GameView3D?.DrawMap3D(FromBoard: Game.GameBoard!, CalledFrom: "HandleStartInAIMode")
        Game!.SetPredeterminedOrder(UsePredeterminedOrder, FirstIs: .T)
        
        DebugClient.Send("Game \(GameCount) started in attract mode.")
        Game.StartGame(EnableAI: true, PieceCategories: [.Standard], UseFastAI: UseFastAI)
        DumpGameBoard(Game.GameBoard!)
        PlayStopButton.setTitle("Stop", for: .normal)
        ForceResume()
        
        DebugClient.SetIdiotLight(IdiotLights.B2, Title: "Playing", FGColor: ColorNames.WhiteSmoke, BGColor: ColorNames.PineGreen)
        DebugClient.SetIdiotLight(IdiotLights.A2, Title: "Attract Mode", FGColor: ColorNames.Blue, BGColor: ColorNames.WhiteSmoke)
    }
    
    // MARK: Game engine and related protocol-required functions.
    
    /// The game wants us to set the opacity of the specified piece.
    ///
    /// - Note: This is called when a piece is being thrown away.
    ///
    /// - Parameters:
    ///   - To: The new opacity/alpha level.
    ///   - ID: The ID of the piece whose alpha/opacity level will be set.
    func SetPieceOpacity(To: Double, ID: UUID)
    {
    }
    
    /// Sets the opacity of a 3D piece.
    /// - Parameter To: The new opacity/alpha level.
    /// - Parameter ID: The ID of the piece whose alpha/opacity level will be set.
    /// - Parameter Duration: Length of time to change the opacity.
    func SetPieceOpacity(To: Double, ID: UUID, Duration: Double)
    {
        GameView3D?.SetOpacity(OfID: ID, To: To, Duration: Duration)
    }
    
    /// Called when a piece is successfully moved.
    ///
    /// - Parameters:
    ///   - MovedPiece: The piece that moved.
    ///   - Direction: The direction the piece moved.
    ///   - Commanded: True if the piece was commanded to move, false if gravity caused the movement.
    func PieceMoved(_ MovedPiece: Piece, Direction: Directions, Commanded: Bool)
    {
    }
    
    /// Called when a piece is successfully moved in a 3D game.
    ///
    /// - Parameters:
    ///   - MovedPiece: The piece that moved.
    ///   - Direction: The direction the piece moved.
    ///   - Commanded: True if the piece was commanded to move, false if gravity caused the movement.
    func PieceMoved3D(_ MovedPiece: Piece, Direction: Directions, Commanded: Bool)
    {
        GameView3D?.DrawPiece3D(InBoard: Game!.GameBoard!, GamePiece: MovedPiece)
    }
    
    /// Number of games run in the current instance.
    var GameCount: Int = 1
    
    let LastGameDurationID = UUID()
    let LastGamePieceCountID = UUID()
    let MeanGameDurationID = UUID()
    let MeanGamePieceCountID = UUID()
    var CumulativePieceCount = 0
    var CumulativeGameDuration = 0.0
    
    /// The game has notified us that the game is over.
    ///
    /// - Note:
    ///   - The appropriate messages will be shown on the screen via the game view, not the UI.
    ///   - User game statistics will be saved.
    ///   - Game statistics will be saved to the AI cumulative data table (`AIData`).
    ///   - After a set amount of time, the "game over" text will be hidden.
    ///   - If the game was started in attract mode/AI mode, after a set amount of time, the game will restart in AI mode again.
    ///   - If the game was started in normal user mode, after a longer set amount of time with no action on the user's part,
    ///     the game will start in AI mode.
    func GameOver()
    {
        let GamePlayDuration = CACurrentMediaTime() - GamePlayStart
        let History = HistoryManager.GetHistory(InAttractMode)
        History?.Games![CurrentBaseGameType]!.AddDuration(NewDuration: Int(GamePlayDuration))
        History?.Games![CurrentBaseGameType]!.SetHighScore(NewScore: Game.HighScore)
        History?.Games![CurrentBaseGameType]!.AddScore(NewScore: Game.CurrentGameScore)
        HistoryManager.Save()
        PlayStopButton?.setTitle("Play", for: .normal)
        var GameDuration = Game.GameDuration()
        GameDuration = round(GameDuration)
        
        CumulativePieceCount = CumulativePieceCount + NewPieceCount
        CumulativeGameDuration = CumulativeGameDuration + GameDuration
        let PieceCountMsg = MessageHelper.MakeKVPMessage(ID: LastGamePieceCountID, Key: "Game Pieces", Value: "\(NewPieceCount)")
        DebugClient.SendPreformattedCommand(PieceCountMsg)
        let MeanPieceCountMsg = MessageHelper.MakeKVPMessage(ID: MeanGamePieceCountID, Key: "Mean Peices", Value: "\(CumulativePieceCount / GameCount)")
        DebugClient.SendPreformattedCommand(MeanPieceCountMsg)
        let GameDurationMsg = MessageHelper.MakeKVPMessage(ID: LastGameDurationID, Key: "Game Duration", Value: "\(GameDuration)")
        DebugClient.SendPreformattedCommand(GameDurationMsg)
        let MeanDurationMsg = MessageHelper.MakeKVPMessage(ID: MeanGameDurationID, Key: "Mean Duration", Value: "\(CumulativeGameDuration / Double(GameCount))")
        DebugClient.SendPreformattedCommand(MeanDurationMsg)
        
        NewPieceCount = 0
        GameCount = GameCount + 1
        DebugClient.SetIdiotLight(IdiotLights.B2, Title: "Game Over", FGColor: ColorNames.White, BGColor: ColorNames.Burgundy)
        
        GameTextOverlay?.ShowGameOver(Duration: 0.4, HideAfter: 10.0)
        GameTextOverlay?.ShowCurrentScore(NewScore: Game.CurrentGameScore)
        GameTextOverlay?.ShowHighScore(NewScore: Game.HighScore)
        GameTextOverlay?.HideNextLabel(Duration: 0.1)
        GameTextOverlay?.HideNextPiece(Duration: 0.1)
        GameTextOverlay?.ShowPressPlay(Duration: 0.5)
        
        StopAccumulating = true
        let MeanVal = AccumulatedFPS / Double(FPSSampleCount)
        if !Settings.ShowInstanceSeconds()
        {
            FPSLabel.text = "μ \(Convert.RoundToString(MeanVal, ToNearest: 0.001, CharCount: 6))"
        }
        
        if InAttractMode
        {
            let _ = Timer.scheduledTimer(timeInterval: 10.0, target: self,
                                         selector: #selector(AutoStartInAttractMode),
                                         userInfo: nil, repeats: false)
        }
        else
        {
            let _ = Timer.scheduledTimer(timeInterval: UserTheme!.AfterGameWaitDuration, target: self,
                                         selector: #selector(AutoStartInAttractMode),
                                         userInfo: nil, repeats: false)
        }
        let _ = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(HideGameOverText), userInfo: nil,
                                     repeats: false)
    }
    
    var CumulativeDuration: Double = 0.0
    var CumulativePieces: Double = 0.0
    
    /// Hides the game over text in the game view.
    @objc func HideGameOverText()
    {
        GameTextOverlay?.HideGameOver(Duration: 1.0)
    }
    
    /// Notice by the game that a piece stopped out of bounds (eg, sticking out the entrance of the bucket).
    ///
    /// - Parameter ID: ID of the piece that is out-of-bounds.
    func OutOfBounds(_ ID: UUID)
    {
        GameView3D?.PieceOutOfBounds(ID)
    }
    
    /// Notice by the game that a piece has started freezing. This does not preclude the event that the piece may unfreeze and
    /// move again.
    ///
    /// - Parameter ID: The ID of the piece that started freezing.
    func StartedFreezing(_ ID: UUID)
    {
    }
    
    /// Notice by the game that a piece that had started to freeze was moved and is no longer frozen.
    /// - Parameter ID: The ID of the piece that is no longer frozen.
    func StoppedFreezing(_ ID: UUID)
    {
    }
    
    /// Start playing in attract mode.
    @objc func AutoStartInAttractMode()
    {
        if Game.GameState == .Stopped
        {
            InAttractMode = true
            ClearAndPlay()
        }
        else
        {
            print("GameState is \(Game.GameState)")
        }
    }
    
    /// Notice from the game that its state changed.
    ///
    /// - Parameter NewState: The new game state.
    func GameStateChanged(NewState: GameStates)
    {
    }
    
    /// The contents of the map were updated. Update the views. Update game statistics.
    func MapUpdated()
    {
        let History = HistoryManager.GetHistory(InAttractMode)
        History?.Games![CurrentBaseGameType]!.IncrementPieceCount()
        switch CurrentBaseGameType
        {
            case .Standard:
                GameView3D?.DrawMap3D(FromBoard: Game.GameBoard!, CalledFrom: "MapUpdated")
            
            case .Rotating4:
                break
            
            case .Cubic:
                GameView3D?.DrawMap3D(FromBoard: Game.GameBoard!)
        }
        DumpGameBoard(Game.GameBoard!)
    }
    
    /// The active piece moved. Depending on whether we are in smooth mode or not, we do
    /// different things.
    func PieceUpdated(_ ThePiece: Piece, X: Int, Y: Int)
    {
        switch CurrentBaseGameType
        {
            case .Rotating4:
                GameView3D?.DrawPiece3D(InBoard: Game.GameBoard!, GamePiece: ThePiece)
            
            default:
                break
        }
        //GameView3D?.MovePieceSmoothly(ThePiece, ToOffsetX: CGFloat(X), ToOffsetY: CGFloat(Y), Duration: 0.35)
    }
    
    /// The specified piece froze. Draw the new map.
    /// - Note: The `.Rotating4` game rotation is finalized via a `DispatchQueue.main.asyncAfter` call to `RotateFinishFinalizing` and
    ///         not a completion handler on the `SCNAction.rotateBy` call in the game view because if the completion handler is slow
    ///         for some reason, animation stutters/stalls. If the code is moved out of the completion handler, the worst is it takes
    ///         a few seconds for a new piece to appear rather than stalling animation. Another benefit of doing things this way is
    ///         it makes it a lot easier to debug code issues in the game and not in the SDK.
    /// - Parameter ThePiece: The finalized piece.
    func PieceFinalized(_ ThePiece: Piece)
    {
        switch CurrentBaseGameType
        {
            case .Standard:
                break
            
            case .Rotating4:
                GameView3D?.MergePieceIntoBucket(ThePiece)
                GameView3D?.DrawMap3D(FromBoard: Game!.GameBoard!, CalledFrom: "PieceFinalized")
                
                if UserTheme!.RotateBucket
                {
                    switch UserTheme!.RotatingBucketDirection
                    {
                        case .Left:
                            Game!.GameBoard!.Map!.RotateMapLeft()
                            GameView3D?.RotateContentsLeft(Duration: UserTheme!.RotationDuration, Completed: {self.Nop()})
                        
                        case .Right:
                            Game!.GameBoard!.Map!.RotateMapRight()
                            GameView3D?.RotateContentsRight(Duration: UserTheme!.RotationDuration, Completed: {self.Nop()})//{self.RotateFinishFinalizing()})
                        
                        case .Random:
                            if Bool.random()
                            {
                                Game!.GameBoard!.Map!.RotateMapLeft()
                                GameView3D?.RotateContentsLeft(Duration: UserTheme!.RotationDuration, Completed: {self.Nop()})
                            }
                            else
                            {
                                Game!.GameBoard!.Map!.RotateMapRight()
                                GameView3D?.RotateContentsRight(Duration: UserTheme!.RotationDuration, Completed: {self.Nop()})
                        }
                        
                        case .None:
                            NoRotateFinishFinalizing()
                            return
                    }
                    //DispatchCalled = CACurrentMediaTime()
                    //print("RotateFinishFinalized dispatched, Duration=\(UserTheme!.RotationDuration)")
                    DispatchQueue.main.asyncAfter(deadline: .now() + UserTheme!.RotationDuration,
                                                  qos: .userInteractive,
                                                  execute: {self.RotateFinishFinalizing()})
                }
                else
                {
                    NoRotateFinishFinalizing()
            }
            
            case .Cubic:
                break
        }
    }
    
    //var DispatchCalled: Double = 0.0
    
    func Nop()
    {
        
    }
    
    private var CRotateIndex = 0
    private var RotateIndex = 0
    private let RightRotations: [Angles] = [.Angle270, .Angle180, .Angle90, .Angle0]
    private let LeftRotations: [Angles] = [.Angle90, .Angle180, .Angle270, .Angle0]
    
    /// Finish finalizing a piece when no rotation occurs.
    func NoRotateFinishFinalizing()
    {
        GameView3D?.DrawMap3D(FromBoard: Game!.GameBoard!, CalledFrom: "NoRotateFinishFinalizing")
        Game!.DoSpawnNewPiece()
    }
    
    /// Finish finalizing a piece when rotation occurs.
    func RotateFinishFinalizing()
    {
        //print("RotateFinishFinalized called \(CACurrentMediaTime() - DispatchCalled) seconds after dispatch")
        GameView3D?.ClearBucket()
        GameView3D?.DrawMap3D(FromBoard: Game!.GameBoard!, CalledFrom: "RotateFinishFinalizing")
        Game!.DoSpawnNewPiece()
    }
    
    /// Notice from the game that it has a new piece score.
    ///
    /// - Parameters:
    ///   - ID: The ID of the piece.
    ///   - Score: The new score for the piece.
    func FinalizedPieceScore(ID: UUID, Score: Int)
    {
    }
    
    /// Notice from the game that a piece was discarded.
    ///
    /// - Parameter ID: ID of the piece that was discarded.
    func PieceDiscarded(_ ID: UUID)
    {
    }
    
    /// Notice from the game that the piece intersected with a special item.
    ///
    /// - Parameters:
    ///   - Item: The type of item the piece intersected with.
    ///   - At: The location of the intersected item.
    ///   - ID: The ID of the piece.
    func PieceIntersectedWith(Item: PieceTypes, At: CGPoint, ID: UUID)
    {
    }
    
    /// Notice from the game that the piece intersected with a special item.
    ///
    /// - Note: To do: Figure out why this function exists over the non-"X" version.
    ///
    /// - Parameters:
    ///   - Item: The type of item the piece intersected with.
    ///   - At: The location of the intersected item.
    ///   - ID: The ID of the piece.
    func PieceIntersectedWithX(Item: UUID, At: CGPoint, ID: UUID)
    {
    }
    
    var NewPieceCount: Int = 0
    
    /// Notice from the game that a new piece started.
    ///
    /// - Parameter NewPiece: The new piece.
    func NewPieceStarted(_ NewPiece: Piece)
    {
        NewPieceCount = NewPieceCount + 1
    }
    
    /// Notice from the game that a row was deleted.
    ///
    /// - Parameter Row: The index of the deleted row.
    func DeletedRow(_ Row: Int)
    {
    }
    
    /// Notice from the game that a piece was block going in some direction.
    ///
    /// - Parameter ID: The ID of the block piece.
    func PieceBlocked(_ ID: UUID)
    {
    }
    
    /// Notice from the game that the piece successfully rotated.
    ///
    /// - Note: Not called for pieces that are rotationally symmetric.
    ///
    /// - Parameters:
    ///   - ID: ID of the piece that rotated.
    ///   - Direction: The direction the piece rotated.
    func PieceRotated(ID: UUID, Direction: Directions)
    {
    }
    
    /// Notice from the game that a piece was unable to rotate because it was blocked.
    ///
    /// - Parameters:
    ///   - ID: ID of the piece that failed rotation.
    ///   - Direction: The direction the piece tried to rotate.
    func PieceRotationFailure(ID: UUID, Direction: Directions)
    {
    }
    
    /// Notice from the game that the piece has a new score.
    ///
    /// - Parameters:
    ///   - For: ID of the piece with a new score.
    ///   - NewScore: The new score.
    func PieceScoreUpdated(For: UUID, NewScore: Int)
    {
    }
    
    /// Notice from the game that a new game score is available.
    ///
    /// - Note: The game score is shown in the game view, not the UI.
    ///
    /// - Parameter NewScore: The new game score.
    func NewGameScore(NewScore: Int)
    {
        let ScoreTitle = "Game Score\n\(NewScore)"
        DebugClient.SetIdiotLight(IdiotLights.B1, Title: ScoreTitle, FGColor: ColorNames.Black, BGColor: ColorNames.WhiteSmoke)
        GameTextOverlay?.ShowCurrentScore(NewScore: NewScore)
    }
    
    /// Notice from the game that a new high score is available.
    ///
    /// - Note: The high score is shown in the game view, not the UI.
    ///
    /// - Parameter HighScore: The new high score.
    func NewHighScore(HighScore: Int)
    {
        let ScoreTitle = "High Score\n\(HighScore)"
        DebugClient.SetIdiotLight(IdiotLights.C1, Title: ScoreTitle, FGColor: ColorNames.Black, BGColor: ColorNames.WhiteSmoke)
        GameTextOverlay?.ShowHighScore(NewScore: HighScore, Highlight: true,
                                       HighlightColor: ColorNames.Gold, HighlightDuration: 1.0)
        PreviousHighScore = HighScore
    }
    
    var PreviousHighScore = -1
    
    /// Notice from the game what the new next piece is.
    ///
    /// - Parameter Next: The next piece after the current piece.
    func NextPiece(_ Next: Piece)
    {
        //print("Next piece is \(Next.Shape)")
        GameTextOverlay?.ShowNextPiece(Next, Duration: 0.1)
    }
    
    /// Received a performance sample (eg, frames per second for the most recent second) from the game view.
    /// - Parameter FPS: Most recent frames per second (eg, the last second) from the game view.
    func PerformanceSample(FPS: Double)
    {
        if StopAccumulating
        {
            return
        }
        AccumulatedFPS = AccumulatedFPS + FPS
        FPSSampleCount = FPSSampleCount + 1
        //PieceFPS.append(FPS)
        let FPSS = Convert.RoundToString(FPS, ToNearest: 0.001, CharCount: 6)
        var FG = ColorNames.PineGreen
        var BG = ColorNames.PaleGoldenrod
        if FPS < 40.0
        {
            FG = ColorNames.Red
            BG = ColorNames.YellowPantone
        }
        DebugClient.SetIdiotLight(IdiotLights.C3, Title: "Frame Rate\n\(FPSS)", FGColor: FG, BGColor: BG)
        if Settings.ShowFPSInUI()
        {
            if !Settings.ShowInstanceSeconds()
            {
                FPSLabel.text = FPSS
            }
        }
    }
    
    var StopAccumulating: Bool = false
    var AccumulatedFPS: Double = 0.0
    var FPSSampleCount: Int = 0
    
    //var PieceFPS = [Double]()
    
    /// Notice from the game when a column is dropped during the collapse process.
    ///
    /// - Parameter Column: The column that was dropped.
    func ColumnDropped(Column: Int)
    {
    }
    
    /// TBD
    ///
    /// - Parameters:
    ///   - Column: TBD
    ///   - From: TBD
    ///   - ToTarget: TBD
    func DropColumn(Column: Int, From: Int, ToTarget: Int)
    {
    }
    
    /// Notice from the game that it is done compressing the board.
    ///
    /// - Note: The board is compressed when the game (the map, actually) sees full rows and removes them.
    ///
    /// - Parameter DidCompress: True if the board was actually compressed or false if there was nothing to compress.
    func BoardDoneCompressing(DidCompress: Bool)
    {
        if DidCompress
        {
            GameView3D?.DrawMap3D(FromBoard: Game.GameBoard!, CalledFrom: "BoardDoneCompressing")
        }
        if let Board = Game.GameBoard
        {
            DumpGameBoard(Board)
        }
    }
    
    // MARK: Control protocol functions.
    
    func FreezeInPlace()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .FreezeInPlace)
        }
    }
    
    /// Move the piece left.
    func MoveLeft()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .Left)
        }
    }
    
    /// Move the piece right.
    func MoveRight()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .Right)
        }
    }
    
    /// Move the piece down.
    func MoveDown()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .Down)
        }
    }
    
    /// Drop the piece down.
    func DropDown()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .DropDown)
        }
    }
    
    /// Move the piece up.
    func MoveUp()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .Up)
        }
    }
    
    /// Move the piece up and away (eg, discard it).
    func MoveUpAndAway()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .UpAndAway)
        }
    }
    
    /// Rotate the piece left.
    func RotateLeft()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .RotateLeft)
        }
    }
    
    /// Rotate the piece right.
    func RotateRight()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .RotateRight)
        }
    }
    
    /// Makes sure the game is paused. Takes no action if the game is already paused.
    public func ForcePause()
    {
        if IsPaused
        {
            return
        }
        Pause()
    }
    
    /// Make sure the game is not paused. Takes no action if the game is not paused.
    public func ForceResume()
    {
        if IsPaused
        {
            Pause()
        }
    }
    
    /// Pause the game.
    func Pause()
    {
        if IsPaused
        {
            IsPaused = false
            PauseResumeButton?.setTitle("Pause", for: .normal)
            SlideInPauseButton.setTitle("Pause", for: .normal)
            GameTextOverlay?.HidePause(Duration: 0.1)
            Game.ResumeGame()
            DebugClient.Send("Game resumed.")
            DebugClient.SetIdiotLight(IdiotLights.B2, Title: "Playing", FGColor: ColorNames.WhiteSmoke, BGColor: ColorNames.PineGreen)
        }
        else
        {
            IsPaused = true
            PauseResumeButton?.setTitle("Resume", for: .normal)
            SlideInPauseButton.setTitle("Resume", for: .normal)
            GameTextOverlay?.ShowPause(Duration: 0.1)
            Game.PauseGame()
            DebugClient.Send("Game paused.")
            DebugClient.SetIdiotLight(IdiotLights.B2, Title: "Paused", FGColor: ColorNames.PrussianBlue, BGColor: ColorNames.YellowPastel)
        }
    }
    
    /// Resume the game.
    ///
    /// - Note: Nothing is done here because `Pause` is used as a toggle for game state.
    func Resume()
    {
    }
    
    let GameCountID = UUID()
    
    var FirstPlay = true
    
    /// Clears the game board then starts a new game.
    /// - Note:
    ///   - The board is cleared in an animated fashion whose maximum duration is set in user settings.
    ///   - If the bucket is cleared visually, the pieces are removed with a duration no longer than that found in the
    ///     user settings (the key is `BucketDestructionDuration`). In this case, **Play** is called after an appropriate
    ///     delay to allow for the visuals to occur. Otherwise, **Play** is called immediately.
    ///   - If this is the first time this function is called in a given isntance, nothing is cleared and **Play** is called
    ///     immediately.
    func ClearAndPlay()
    {
        if FirstPlay
        {
            FirstPlay = false
            Play()
            return
        }
        var PlayDelay = 0.0
        if UserTheme!.AfterGameWaitDuration > 0.0
        {
            let Duration = UserTheme!.DestructionDuration
            //print("Destruction method: \(UserTheme!.DestructionMethod)")
            PlayDelay = Duration + 0.1
            if Thread.isMainThread
            {
                //If we're on the same thread as the UI, just call the function to clear the bucket.
                GameView3D?.DestroyMap3D(FromBoard: Game.GameBoard!, DestroyBy: UserTheme!.DestructionMethod, MaxDuration: Duration)
                perform(#selector(Play), with: nil, afterDelay: PlayDelay)
            }
            else
            {
                //If we're not on the same thread as the UI (such as being called by a background timer), run the function on
                //the main thread.
                DispatchQueue.main.sync
                    {
                        print("MainViewController.ClearAndPlay called from background thread.")
                        GameView3D?.DestroyMap3D(FromBoard: Game.GameBoard!, DestroyBy: UserTheme!.DestructionMethod, MaxDuration: Duration)
                        perform(#selector(self.Play), with: nil, afterDelay: PlayDelay)
                }
            }
        }
        else
        {
            //Nothing to do...
        }
    }
    
    var GamePlayStart: Double = 0.0
    
    /// Play the game, eg, start in normal user mode.
    @objc func Play()
    {
        GamePlayStart = CACurrentMediaTime()
        let History = HistoryManager.GetHistory(InAttractMode)
        History?.Games![CurrentBaseGameType]!.IncrementGameCount()
        ForceResume()
        StopAccumulating = false
        RotateIndex = 0
        DebugClient.SetIdiotLight(IdiotLights.B2, Title: "Playing", FGColor: ColorNames.WhiteSmoke, BGColor: ColorNames.PineGreen)
        let GameCountMsg = MessageHelper.MakeKVPMessage(ID: GameCountID, Key: "Game Count", Value: "\(GameCount)")
        DebugClient.SendPreformattedCommand(GameCountMsg)

        GameTextOverlay?.HideVersionBox(Duration: 0.2)
        GameTextOverlay?.HideGameOver(Duration: 0.0)
        GameTextOverlay?.HidePressPlay(Duration: 0.0)
        GameTextOverlay?.ShowNextLabel(Duration: 0.1)
        
        Game!.SetPredeterminedOrder(UsePredeterminedOrder, FirstIs: .T)
        
        GameDuration = CACurrentMediaTime()
        Game.StartGame(EnableAI: InAttractMode, PieceCategories: GamePieces, UseFastAI: UseFastAI)
        
        GameView3D?.DrawMap3D(FromBoard: Game.GameBoard!, CalledFrom: "Play")
        //GameView3D?.FadeBucketGrid()
        GameTextOverlay?.ShowCurrentScore(NewScore: 0)
        CurrentlyPlaying = true
        PlayStopButton?.setTitle("Stop", for: .normal)
        if !InAttractMode
        {
            DebugClient.SetIdiotLight(IdiotLights.A2, Title: "Normal Mode", FGColor: ColorNames.Black, BGColor: ColorNames.White)
        }
        #if false
        PieceFPS.removeAll()
        #endif
    }
    
    var GameDuration: Double = 0.0
    
    /// Show or hide the "Press Play to Start" (or equivalent) message in the game view.
    func ShowPressPlay(_ DoShow: Bool)
    {
        if DoShow
        {
            GameTextOverlay?.ShowPressPlay(Duration: 0.5)
        }
        else
        {
            GameTextOverlay?.HidePressPlay(Duration: 0.1)
        }
    }
    
    /// Stop the game. The user cannot resume once it the game is stopped.
    func Stop()
    {
        CurrentlyPlaying = false
        Game.StopGame()
        DebugClient.Send("Game \(GameCount) stopped by user.")
        NewPieceCount = 0
        GameCount = GameCount + 1
    }
    
    /// Not currently used.
    private var _Controller: ControlUIProtocol? = nil
    
    /// Not currently used.
    var Controller: ControlUIProtocol?
    {
        get
        {
            return _Controller
        }
        set
        {
            _Controller = newValue
        }
    }
    
    // MARK: Game-control related functions.
    
    #if true
    func HandleMoveLeftPressed()
{
    MoveLeft()
    }
    
    func HandleMoveRightPressed()
{
    MoveRight()
    }
    
    func HandleMoveUpPressed()
{
    MoveUp()
    }
    
    func HandleMoveDownPressed()
{
    MoveDown()
    }
    
    func HandleUpAndAwayPressed()
{
    MoveUpAndAway()
    }
    
    func HandleDropDownPressed()
{
    DropDown()
    }
    
    func HandleRotateLeftPressed()
{
    RotateRight()
    }
    
    func HandleRotateRightPressed()
{
    RotateLeft()
    }
    
    func HandleFreezeInPlacePressed()
{
    FreezeInPlace()
    }
    #else
    /// Handle the move left button pressed.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleMoveLeftPressed(_ sender: Any)
    {
        MoveLeft()
    }
    
    /// Handle the move right button pressed.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleMoveRightPressed(_ sender: Any)
    {
        MoveRight()
    }
    
    /// Handle the move up button pressed.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleMoveUpPressed(_ sender: Any)
    {
        MoveUp()
    }
    
    /// Handle the move up and away button pressed.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleUpAndAwayPressed(_ sender: Any)
    {
        MoveUpAndAway()
    }
    
    /// Handle the move down button pressed.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleMoveDownPressed(_ sender: Any)
    {
        MoveDown()
    }
    
    /// Handle the drop down button pressed.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleDropDownPressed(_ sender: Any)
    {
        DropDown()
    }
    
    /// Handle the rotate left button pressed.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleRotateLeftPressed(_ sender: Any)
    {
        //Even though the function is titled "HandleRotateLeftPressed", we will rotate the piece to the right due to
        //how the piece implemented rotations.
        RotateRight()
    }
    
    /// Handle the rotate right button pressed.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandleRotateRightPressed(_ sender: Any)
    {
        //Even though the function is titled "HandleRotateRightPressed", we will rotate the piece to the left due to
        //how the piece implemented rotations.
        RotateLeft()
    }
    
    /// Handle the freeze in place button pressed.
    /// - Note: This button is valid only in certain games.
    /// - Parameter sender: Not used.
    @IBAction func HandleFreezeInPlacePressed(_ sender: Any)
    {
        FreezeInPlace()
    }
    #endif
    
    /// Handle the play button pressed.
    ///
    /// - Note: The button's visuals will change depending on whether the game is in play or stopped.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandlePlayStopPressed(_ sender: Any)
    {
        if CurrentlyPlaying
        {
            Stop()
            GameTextOverlay?.ShowPressPlay(Duration: 0.5)
            PlayStopButton?.setTitle("Play", for: .normal)
            SlideInPlayButton.setTitle("Play", for: .normal)
        }
        else
        {
            InAttractMode = false
            Play()
            PlayStopButton?.setTitle("Stop", for: .normal)
            SlideInPlayButton.setTitle("Stop", for: .normal)
        }
    }
    
    /// Handle the pause button pressed.
    ///
    /// - Note: The button's visuals will change depending on whether the game is in paused or playing.
    ///
    /// - Parameter sender: Not used.
    @IBAction func HandlePauseResumePressed(_ sender: Any)
    {
        Pause()
    }
    
    // MARK: AI delegate functions.
    
    /// Someone wants a reference to the user theme.
    /// - Returns: Current user theme instance.
    func GetUserTheme() -> ThemeDescriptor?
    {
        return Themes.UserTheme
    }
    
    /// The AI delegate wants AI data.
    ///
    /// - Returns: A populated `AITestTable`.
    func GetAIData() -> AITestTable?
    {
        return AIData
    }
    
    /// Set a new user.
    ///
    /// - Parameter UserID: ID of the new user.
    func SetNewUser(_ UserID: UUID)
    {
    }
    
    // Mark: Game AI event protocol functions.
    
    /// AI is moving a piece upwards.
    func AI_MoveUp()
    {
        GameUISurface3D?.FlashButton(.UpButton)
        /*
        #if true
        UIView.animate(withDuration: 0.15,
                       animations:
            {
                self.MoveUpButton.tintColor = UIColor.yellow
        }, completion:
            {
                _ in
                self.MoveUpButton.tintColor = UIColor.white
        })
        #else
        MoveUpButton2.Highlight(WithImage: "UpArrowHighlighted48", ForSeconds: 0.15,
                                OriginalName: "UpArrow48")
        #endif
 */
    }
    
    /// AI is throwing a piece away.
    func AI_MoveUpAndAway()
    {
        GameUISurface3D?.FlashButton(.FlyAwayButton)
        /*
        #if true
        UIView.animate(withDuration: 0.15,
                       animations:
            {
                self.UpAndAwayButton.tintColor = UIColor.yellow
        }, completion:
            {
                _ in
                self.UpAndAwayButton.tintColor = UIColor.cyan
        })
        #else
        UpAndAwayButton2.Highlight(WithImage: "FlyAwayArrowHighlighted48", ForSeconds: 0.15,
                                   OriginalName: "FlyAwayArrow48")
        #endif
 */
    }
    
    /// AI is moving a piece downwards.
    func AI_MoveDown()
    {
        GameUISurface3D?.FlashButton(.DownButton)
        /*
        #if true
        UIView.animate(withDuration: 0.15,
                       animations:
            {
                self.MoveDownButton.tintColor = UIColor.yellow
        }, completion:
            {
                _ in
                self.MoveDownButton.tintColor = UIColor.white
        })
        #else
        MoveDownButton2.Highlight(WithImage: "DownArrowHighlighted48", ForSeconds: 0.15,
                                  OriginalName: "DownArrow48")
        #endif
 */
    }
    
    /// AI is dropping a piece downwards.
    func AI_DropDown()
    {
        GameUISurface3D?.FlashButton(.DropDownButton)
        /*
        #if true
        UIView.animate(withDuration: 0.15,
                       animations:
            {
                self.DropDownButton.tintColor = UIColor.yellow
        }, completion:
            {
                _ in
                self.DropDownButton.tintColor = UIColor.systemGreen
        })
        #else
        DropDownButton2.Highlight(WithImage: "DropDownArrowHighlighted48", ForSeconds: 0.15,
                                  OriginalName: "DropDownArrow48")
        #endif
 */
    }
    
    /// AI is moving a piece to the left.
    func AI_MoveLeft()
    {
        GameUISurface3D?.FlashButton(.LeftButton)
        /*
        #if true
        UIView.animate(withDuration: 0.15,
                       animations:
            {
                self.MoveLeftButton.tintColor = UIColor.yellow
        }, completion:
            {
                _ in
                self.MoveLeftButton.tintColor = UIColor.white
        })
        #else
        MoveLeftButton2.Highlight(WithImage: "LeftArrowHighlighted48", ForSeconds: 0.15,
                                  OriginalName: "LeftArrow48")
        #endif
 */
    }
    
    /// AI is moving a piece to the right.
    func AI_MoveRight()
    {
        GameUISurface3D?.FlashButton(.RightButton)
        /*
        #if true
        UIView.animate(withDuration: 0.15,
                       animations:
            {
                self.MoveRightButton.tintColor = UIColor.yellow
        }, completion:
            {
                _ in
                self.MoveRightButton.tintColor = UIColor.white
        }
        )
        #else
        MoveRightButton2.Highlight(WithImage: "RightArrowHighlighted48", ForSeconds: 0.15,
                                   OriginalName: "RightArrow48")
        #endif
 */
    }
    
    /// AI is rotating a piece clockwise.
    func AI_RotateRight()
    {
        GameUISurface3D?.FlashButton(.RotateRightButton)
        /*
        #if true
        UIView.animate(withDuration: 0.15,
                       animations:
            {
                self.RotateRightButton.tintColor = UIColor.yellow
        }, completion:
            {
                _ in
                self.RotateRightButton.tintColor = UIColor.white
        })
        #else
        RotateRightButton2.Highlight(WithImage: "RotateRightHighlighted48", ForSeconds: 0.15,
                                     OriginalName: "RotateRight48_2")
        #endif
 */
    }
    
    /// AI is rotating a piece counter-clockwise.
    func AI_RotateLeft()
    {
        GameUISurface3D?.FlashButton(.RotateLeftButton)
        /*
        #if true
        UIView.animate(withDuration: 0.15,
                       animations:
            {
                self.RotateRightButton.tintColor = UIColor.yellow
        }, completion:
            {
                _ in
                self.RotateRightButton.tintColor = UIColor.white
        })
        #else
        RotateLeftButton2.Highlight(WithImage: "RotateLeftHighlighted48", ForSeconds: 0.15,
                                    OriginalName: "RotateLeft48_2")
        #endif
 */
    }
    
    /// AI is freezing a piece into place.
    func AI_FreezeInPlace()
    {
        GameUISurface3D?.FlashButton(.FreezeButton)
        /*
        UIView.animate(withDuration: 0.15,
                       animations:
            {
                self.FreezeInPlaceButton.tintColor = UIColor.yellow
        }, completion:
            {
                _ in
                self.FreezeInPlaceButton.tintColor = UIColor.cyan
        })
 */
    }
    
    // MARK: Game view request functions.
    
    /// The game view wants us to redraw the board.
    func NeedRedraw()
    {
        GameView3D?.DrawMap3D(FromBoard: Game.GameBoard!, CalledFrom: "NeedRedraw")
    }
    
    func SendKVP(Name: String, Value: String, ID: UUID)
    {
    }
    
    // MARK: Smooth motion protocol function implementations.
    
    weak var Smooth3D: SmoothMotionProtocol? = nil
    weak var Smooth2D: SmoothMotionProtocol? = nil
    
    /// Move a piece smoothly to the specified location.
    /// - Parameter GamePiece: The piece to move.
    /// - Parameter ToOffsetX: Horizontal destination offset.
    /// - Parameter ToOffsetY: Vertical destination offset.
    func SmoothMove(_ GamePiece: Piece, ToOffsetX: Int, ToOffsetY: Int)
    {
        Smooth3D?.MovePieceSmoothly(GamePiece, ToOffsetX: CGFloat(ToOffsetX), ToOffsetY: CGFloat(ToOffsetY), Duration: 0.35)
    }
    
    /// Rotate a piece smoothly in the specified direction (implied by `Degrees`).
    /// - Paramater GamePiece: The piece to rotate.
    /// - Parameter Degrees: Number of degrees to rotate the piece by.
    /// - Parameter OnAxis: The axis to rotate the piece on. 2D games use the .X axis.
    func SmoothRotate(_ GamePiece: Piece, Degrees: CGFloat, OnAxis: RotationalAxes)
    {
        RotatePieceSmoothly(GamePiece, ByDegrees: Degrees, Duration: 0.35, OnAxis: OnAxis)
    }
    
    func MovePieceSmoothly(_ GamePiece: Piece, ToOffsetX: CGFloat, ToOffsetY: CGFloat, Duration: Double)
    {
        //Not used in this class.
        fatalError("I told you this function shouldn't be called here!")
    }
    
    /// Called when a smooth motion is completed.
    /// - Parameter For: The ID of the piece that moved smoothly.
    func SmoothMoveCompleted(For: UUID)
    {
        
    }
    
    func RotatePieceSmoothly(_ GamePiece: Piece, ByDegrees: CGFloat, Duration: Double, OnAxis: RotationalAxes)
    {
        //Not used in this class.
        fatalError("I told you this function shouldn't be called here!")
    }
    
    /// Called when a smooth rotation is completed.
    /// - Parameter For: The ID of the piece that rotated smoothly.
    func SmoothRotationCompleted(For: UUID)
    {
        
    }
    
    /// Called to create a game piece that can move smoothly.
    /// - Returns: ID of the piece to move smoothly.
    func CreateSmoothPiece() -> UUID
    {
        return UUID.Empty
    }
    
    /// Called when the game is done moving a piece smoothly, eg, when it freezes into place.
    /// - Parameter ID: The ID of the piece to clean up.
    func DoneWithSmoothPiece(_ ID: UUID)
    {
        
    }
    
    #if false
    // MARK: Game-level delegate functions.
    
    /// Returns the current level and mode.
    ///
    /// - Parameters:
    ///   - CurrentLevel: The level the game is currently playing in.
    ///   - CurrentMode: The mode the game is currently playing in.
    func GetLevelInformation(CurrentLevel: inout LevelTypes, CurrentMode: inout ModeTypes)
    {
        CurrentLevel = LevelTypes.ReallyEasy
        CurrentMode = ModeTypes.AttractMode
    }
    
    /// Handle new level selected from the level setting sheet.
    ///
    /// - Parameters:
    ///   - WasCanceled: Determines if the user pressed the cancel button - if so, `NewLevel` and `NewMode` are undefined.
    ///   - NewLevel: The new level if `WasCanceled` is false.
    ///   - NewMode: The new mode if `WasCanceled` is false.
    func LevelSelected(WasCanceled: Bool, NewLevel: LevelTypes?, NewMode: ModeTypes?)
    {
        
    }
    #endif
    
    // MARK: General-UI interactions.
    
    var ProposedNewGameType: BaseGameTypes = .Standard
    var CurrentBaseGameType: BaseGameTypes = .Standard
    
    var UsePredeterminedOrder: Bool = false
    
    var InDistractMode: Bool = false
    
    var UseFastAI: Bool = false
    
    var AttractTimer: Timer? = nil
    
    // MARK: General UI functions
    
    /// Returns the value needed to set a dark style status bar.
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    // MARK: Slide-in view functions.
    
    /// Handle the pressing of the main UI button. If the slide in view is already visible, hide it. If the slide in view is
    /// hidden, show it.
    /// - Parameter sender: Not used.
    @IBAction func HandleMainButtonPressed(_ sender: Any)
    {
        //Initialize the first use of the slide in view.
        if FirstSlideIn
        {
            FirstSlideIn = false
            GameViewContainer.bringSubviewToFront(MainSlideIn)
        }
        if MainSlideIn!.IsVisible
        {
            MainSlideIn?.HideMainSlideIn()
            UpdateMainButton(false)
        }
        else
        {
            MainSlideIn?.ShowMainSlideIn()
            UpdateMainButton(true)
        }
    }
    
    /// Update the main UI button by rotating it to indicate it has been pressed.
    /// - Parameter Opened: Determines the icon to show.
    private func UpdateMainButton(_ Opened: Bool)
    {
        let ImageName = Opened ? "cube" : "cube.fill"
        let ButtonImage = UIImage(systemName: ImageName)
        MainUIButton.setImage(ButtonImage, for: UIControl.State.normal)
    }
    
    /// Handle the restart game button in the slide in view.
    @IBAction func HandleSlideInRestartGamePressed(_ sender: Any)
    {
        MainSlideIn?.HideMainSlideIn()
        UpdateMainButton(false)
    }
    
    /// Handle the close button in the slide in view pressed by the user by closing the slide in view.
    /// - Parameter sender: Not used.
    @IBAction func HandleSlideInCloseButtonPressed(_ sender: Any)
    {
        MainSlideIn?.HideMainSlideIn()
        UpdateMainButton(false)
    }
    
    /// Handle the attract button in the slide in view pressed. Start a new game in attract mode (AI running).
    /// - Parameter sender: Not used.
    @IBAction func HandleSlideInAttractButtonPressed(_ sender: Any)
    {
        MainSlideIn?.HideMainSlideIn()
        UpdateMainButton(false)
        if AttractTimer != nil
        {
            //Need to invalidate the attract timer (if it's active) or bad things will happen
            //(specifically, pieces will get confused about which board they belong to, causing
            //crashes and fatal errors).
            AttractTimer?.invalidate()
            AttractTimer = nil
        }
        InAttractMode = true
        Stop()
        ClearAndPlay()
    }
    
    @IBAction func HandleSettingsSlideInButtonPressed(_ sender: Any)
    {
        ForcePause()
        MainSlideIn.HideMainSlideIn()
        UpdateMainButton(false)
        let Storyboard = UIStoryboard(name: "Theming", bundle: nil)
        if let Controller = Storyboard.instantiateViewController(withIdentifier: "MainThemeEditor") as? ThemeEditorController
        {
            Controller.EditTheme(Theme: Themes!.UserTheme, DefaultTheme: Themes!.DefaultTheme)
            self.present(Controller, animated: true, completion: nil)
        }
    }
    
    @IBSegueAction func InstantiateAboutDialog(_ coder: NSCoder) -> AboutDialogController?
    {
        ForcePause()
        MainSlideIn.HideMainSlideIn()
        UpdateMainButton(false)
        let About = AboutDialogController(coder: coder)
        return About
    }
    
    @IBSegueAction func InstantiateGameSelector(_ coder: NSCoder) -> SelectGameController?
    {
        ForcePause()
        MainSlideIn.HideMainSlideIn()
        UpdateMainButton(false)
        let Selector = SelectGameController(coder: coder)
        Selector?.SelectorDelegate = self
        return Selector
    }
    
    /// Called when the game selector dialog closes.
    /// - Parameter DidChange: If true, the game type or sub type or both changed.
    /// - Parameter NewBaseType: The new base type (or old one if only the `GameSubType` changed). If `DidChange` is false,
    ///                          this value will be nil.
    /// - Parameter GameSubType: The new sub type game (or old one if only the `NewBaseType` changed). If `DidChange` is false,
    ///                          this value will be nil.
    func GameTypeChanged(DidChange: Bool, NewBaseType: BaseGameTypes?, GameSubType: BaseGameSubTypes?)
    {
        print("At GameTypeChanged")
        if !DidChange
        {
            return
        }
        if let NewGameType = NewBaseType
        {
            print("NewGameType is \(NewGameType)")
            if NewGameType == CurrentBaseGameType
            {
                print("Game type is already set. No action taken.")
                return
            }
            SwitchGameType(BaseType: NewGameType, SubType: GameSubType!)
        }
    }
    
    /// Switch the game type here. The current game will be stopped and the UI reinitialized.
    /// - Parameter BaseType: The game base type to use.
    /// - Parameter SubType: The game sub type to use.
    func SwitchGameType(BaseType: BaseGameTypes, SubType: BaseGameSubTypes)
    {
        print("Switching game type to \(BaseType)")
        CurrentBaseGameType = BaseType
        UserTheme!.GameType = BaseType
        Stop()
        InitializeGameUI()
    }
    
    // MARK: Debug delegate functions and other debug code.
    
    /// Dump the game board as a text object.
    /// - Note: The game is dumped to a child window.
    /// - Parameters:
    ///   - Board: The board to dump.
    ///   - ShowGaps: If true, gaps are shown.
    func DumpGameBoard(_ Board: Board, ShowGaps: Bool = false)
    {
    }
    
    // MARK: AI Scoring for debugging.
    
    /// Set AI scoring method.
    ///
    /// - Note: Not current in use.
    ///
    /// - Parameter Method: The method to use to score with the AI.
    func SetAIScoring(Method: AIScoringMethods)
    {
        //Not used here.
    }
    
    /// Determines if the default scoring method should be used.
    ///
    /// - Note: Not current in use.
    ///
    /// - Parameter IsDefault: If true, use the default method.
    func SetAIDefaultScoring(IsDefault: Bool)
    {
        //Not used here.
    }
    
    /// Sets the valid piece groups to use by the AI.
    ///
    /// - Note: Not current in use.
    ///
    /// - Parameter PieceGroups: The piece groups to use.
    func SetPieceGroups(PieceGroups: MetaPieces)
    {
        //Not used here.
    }
    
    /// How to select pices.
    ///
    /// - Note: Not current in use.
    ///
    /// - Parameter Method: The method to use to select pieces.
    func SetPieceSelection(Method: PieceSelectionMethods)
    {
        //Not used here.
    }
    
    /// Returns the AI scoring to use.
    ///
    /// - Note: Defaults to `.OffsetMapping`.
    ///
    /// - Returns: The AI scoring to use.
    func GetAIScoring() -> AIScoringMethods
    {
        return .OffsetMapping
    }
    
    /// Return use the default scoring method flag.
    ///
    /// - Note: Always returns false.
    ///
    /// - Returns: Value indicating whether to use the default method or not.
    func GetAIDefaultScoring() -> Bool
    {
        return false
    }
    
    /// Returns the group of pieces to use by the AI.
    ///
    /// - Note: Always returns `.Standard`.
    ///
    /// - Returns: Piece group to use.
    func GetPieceGroups() -> MetaPieces
    {
        return .Standard
    }
    
    // MARK: Implementation of TDebugProtocol functions.
    
    /// Called when the connection state between us and the remote TDebug instance changes.
    /// - Parameter Connected: Will contain the connection state.
    func RemoteConnectionStateChanged(Connected: Bool)
    {
        print("Remote connection state: \(Connected)")
        if Connected
        {
            DebugClient.SendCommandQueue()
        }
    }
    
    // MARK: Implementation of StepperHelper protocol functions.
    
    /// Display information from a step. Control should not return until the user dismisses the UI element.
    /// - Parameter From: String describing where the step occurred.
    /// - Parameter Message: String from the step caller.
    /// - Parameter Stepped: Catagory of the step.
    func DisplayStep(From: String, Message: String, Stepped: Steps)
    {
        
    }
    
    // MARK: UITouchImage function implementations.
    
    /// Handle **UITouchImage** press actions.
    /// - Parameter sender: The **UITouchImage** control that was pressed.
    /// - Parameter PressedButton: The logical button that was pressed.
    func Touched(_ sender: UITouchImage, PressedButton: UIMotionButtons)
    {
        switch PressedButton
        {
            case .MoveLeft:
                MoveLeft()
            
            case .MoveRight:
                MoveRight()
            
            case .MoveDown:
                MoveDown()
            
            case .MoveUp:
                MoveUp()
            
            case .DropDown:
                DropDown()
            
            case .RotateLeft:
                RotateLeft()
            
            case .RotateRight:
                RotateRight()
            
            case .FlyAway:
                MoveUpAndAway()
            
            default:
                break
        }
    }
    
    // MARK: Media button handling.
    
    /// Handle the camera button press - save the current game view as an image (but not the entire screen).
    /// - Parameter sender: Not used.
    @IBAction func HandleCameraButtonPressed(_ sender: Any)
    {
        if let GameImage = GameViewContainer.AsImage()
        {
            UIImageWriteToSavedPhotosAlbum(GameImage,
                                           self,
                                           #selector(image(_:didFinishSavingWithError:contextInfo:)),
                                           nil)
        }
        else
        {
            print("Error getting image of GameView.")
        }
    }
    
    /// Callback from the system once the image is saved (or an error generated).
    /// - Parameter image: Not used.
    /// - Parameter didFinishSavingWithError: Error message (if nil, no error).
    /// - Parameter contextInfo: Not used.
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer)
    {
        if let SomeError = error
        {
            print("\(SomeError)")
        }
        else
        {
            if Settings.GetConfirmGameImageSave()
            {
                let Alert = UIAlertController(title: "Saved", message: "Game image save to the camera roll.", preferredStyle: UIAlertController.Style.alert)
                Alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(Alert, animated: true)
            }
        }
    }
    
    /// Handle the video button pressed. The user should press the button once to start recording, then press again to stop
    /// recording. This app does not have any access to the video.
    /// - Note:
    ///   - The video button acts as a toggle with the tint color of the button changing to show whether the screen is
    ///     being recorded (red in that case) or not (white when not recording).
    ///   - The entire screen is recorded as per standard ReplayKit functionality.
    /// - Parameter sender: Not used.
    @IBAction func HandleVideoButtonPressed(_ sender: Any)
    {
        MakingVideo = !MakingVideo
        VideoButton.tintColor = MakingVideo ? UIColor.systemRed : UIColor.white
        SlideInVideoButton.tintColor = MakingVideo ? UIColor.systemRed : UIColor.systemBlue
        if MakingVideo
        {
            let Recorder = RPScreenRecorder.shared()
            Recorder.startRecording
                {
                    (error) in
                    if let Error = error
                    {
                        print("\(Error.localizedDescription)")
                    }
            }
        }
        else
        {
            let Recorder = RPScreenRecorder.shared()
            Recorder.stopRecording(handler:
                {
                    PreviewController, error in
                    if let Error = error
                    {
                        print("\(Error.localizedDescription)")
                    }
                    if UIDevice.current.userInterfaceIdiom == .pad
                    {
                        PreviewController?.modalPresentationStyle = UIModalPresentationStyle.popover
                        PreviewController?.popoverPresentationController?.sourceRect = CGRect.zero
                        PreviewController?.popoverPresentationController?.sourceView = self.view
                    }
                    if PreviewController != nil
                    {
                        PreviewController?.previewControllerDelegate = self
                    }
                    self.present(PreviewController!, animated: true)
            })
        }
    }
    
    /// The ReplayKit view controller is done. Dismiss it.
    /// - Parameter previewController: The controller to dismiss.
    func previewControllerDidFinish(_ previewController: RPPreviewViewController)
    {
        previewController.dismiss(animated: true)
    }
    
    public var MakingVideo: Bool = false
    
    // MARK: Theme update protocol functions.
    
    /// Handle theme change notifications.
    /// - Note:
    ///    - This version of Fouris only supports a default theme and a user theme. Only the user theme reports changes at this time.
    ///    - By the time control gets here, the changed property can be accessed to get its new value.
    /// - Parameter ThemeName: The name of the theme in which a field changed.
    /// - Parameter Field: The field that changed
    func ThemeUpdated(ThemeName: String, Field: ThemeFields)
    {
        switch Field
        {
            default:
                print("Theme \(ThemeName) updated field \(Field)")
        }
    }
    
    // MARK: Flame button handling.
    
    @IBAction func HandleFlameButtonPressed(_ sender: Any)
    {
        let Button = sender as! UIButton
        if Settings.GetShowMotionControls()
        {
            Settings.SetShowMotionControls(NewValue: false)
            Button.tintColor = UIColor.red
        }
        else
        {
            Settings.SetShowMotionControls(NewValue: true)
            Button.tintColor = UIColor.orange
        }
    }
    
    // MARK: Variables used by +MainSlideInUI from within extensions.
    
    /// Stores the command list for the slide in menu/UI.
    var CommandList = [SlideInItem]()
    
    /// The first time the slider came into view flag. Used in **+MainSliderUI.swift**.
    var FirstSlideIn: Bool = true
    
    // MARK: Variables used by TDebug from within extensions.
    
    var EchoTimer: Timer!
    var EchoBackTo: MCPeerID!
    var MessageToEcho: String!
    var WaitingFor = [(UUID, MessageTypes)]()
    var DebugPeerID: MCPeerID? = nil
    var DebugPeerPrefix: UUID? = nil
    
    // MARK: Interface builder outlets.
    
    @IBOutlet weak var MainUIButton: UIButton!
    @IBOutlet weak var PlayStopButton: UIButton!
    @IBOutlet weak var PauseResumeButton: UIButton!
    @IBOutlet weak var GameUISurface3D: View3D!
    @IBOutlet weak var GameControlView: UIView!
    @IBOutlet weak var MotionControlView: UIView!
    @IBOutlet weak var GameViewContainer: UIView!
    @IBOutlet weak var TextLayerView: TextLayerManager!
    @IBOutlet weak var NextPieceLabelView: UIView!
    @IBOutlet weak var NextPieceView: UIView!
    @IBOutlet weak var NextPieceViewControl: PieceViewer!
    @IBOutlet weak var ScoreLabelView: UIView!
    @IBOutlet weak var CurrentScoreLabelView: UIView!
    @IBOutlet weak var HighScoreLabelView: UIView!
    @IBOutlet weak var PressPlayLabelView: UIView!
    @IBOutlet weak var GameOverLabelView: UIView!
    @IBOutlet weak var PauseLabelView: UIView!
    @IBOutlet weak var MainSlideIn: MainSlideInView2!
    @IBOutlet weak var SlideInAttractButton: UIButton!
    @IBOutlet weak var SlideInCloseButton: UIButton!
    @IBOutlet weak var TopOverlapView: UIView!
    #if false
    @IBOutlet weak var FreezeInPlaceButton: UIButton!
    @IBOutlet weak var SlideInSubView: UIView!
    @IBOutlet weak var MoveLeftButton: UIButton!
    @IBOutlet weak var MoveDownButton: UIButton!
    @IBOutlet weak var MoveUpButton: UIButton!
    @IBOutlet weak var RotateLeftButton: UIButton!
    @IBOutlet weak var MoveRightButton: UIButton!
    @IBOutlet weak var DropDownButton: UIButton!
    @IBOutlet weak var UpAndAwayButton: UIButton!
    @IBOutlet weak var RotateRightButton: UIButton!
    #endif
    @IBOutlet weak var VideoButton: UIButton!
    @IBOutlet weak var SlideInVideoButton: UIButton!
    @IBOutlet weak var CameraButton: UIButton!
        @IBOutlet weak var SlideInCameraButton: UIButton!
    @IBOutlet weak var FPSLabel: UILabel!
            @IBOutlet weak var SlideInCameraControlBox: UIView!
    @IBOutlet weak var SlideInPlayButton: UIButton!
    @IBOutlet weak var SlideInPauseButton: UIButton!
    @IBOutlet weak var TextVersionBox: UIView!
    @IBOutlet weak var VersionTextLabel: UILabel!
    
    // MARK: Enum mappings.
    
    let BaseGameToInt: [BaseGameTypes: Int] =
        [
            .Standard: 0,
            .Rotating4: 1,
            .Cubic: 2
    ]
    
    let IntToBaseGame: [Int: BaseGameTypes] =
        [
            0: .Standard,
            1: .Rotating4,
            2: .Cubic
    ]
}

/// Defines the base games available. Each base game may have one or more variants. For example, a .Standard game may
/// have various bucket sizes or obstructions.
/// - **Standard**: Standard Tetris game.
/// - **Rotating4**: Rotating square with falling pieces.
/// - **Cubic**: Three dimensional falling piece game.
enum BaseGameTypes: String, CaseIterable
{
    case Standard = "Standard"
    case Rotating4 = "Rotating4"
    case Cubic = "Cubic"
}

enum BaseGameSubTypes: String, CaseIterable
{
    //Standard games
    case Classic = "Classic"
    case TallThin = "TallThin"
    case ShortWide = "ShortWide"
    case Big = "Big"
    case Small = "Small"
    
    //Rotating games
    case SmallCentralBlock = "SmallCentralBlock"
    case MediumCentralBlock = "MediumCentralBlock"
    case LargeCentralBlock = "LargeCentralBlock"
    case SmallCentralDiamond = "SmallCentralDiamond"
    case MediumCentralDiamond = "MediumCentralDiamond"
    case LargeCentralDiamond = "LargeCentralDiamond"
    case Corners = "Corners"
    case CentralBrackets4 = "4CentralBrackets"
    case CentralBrackets2 = "2CentralBrackets"
    case Empty = "Empty"
}

extension UIView
{
    /// Return the view (and its sub-views) as an image.
    /// - Note: See [How to Convert a UIView to an Image](https://stackoverflow.com/questions/30696307/how-to-convert-a-uiview-to-an-image)
    /// - Returns: UIImage of the instance UIView. Nil on error.
    func AsImage() -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        let Image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Image!
    }
}
