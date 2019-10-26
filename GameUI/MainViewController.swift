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
    UIPopoverPresentationControllerDelegate,            //Protocol for popover presentations.
    GameUINotificationProtocol,                         //Protocol for communicating from the game engine (and everything below it) to the UI.
    GameAINotificationProtocol,                         //Protocol for communication from the game AI engine to the UI.
    MainDelegate,                                       //Protocol for exporting some functionality defined in this class.
    ControlProtocol,                                    //Protocol for receiving motion and other commands from the motion controller.
    DebugDelegate,                                      //Protocol for sending debug information to a local window.
    GameViewRequestProtocol,                            //Protocol for game views to request information from the controller.
    SmoothMotionProtocol,                               //Protocol for handling smooth motions.
    TDebugProtocol,                                     //Protocol for the debug client to talk to this class.
    StepperHelper,                                      //Protocol for the stepper to display data for the user.
    PopOverProtocol,                                    //Protocol for the communication from the pop-over menu to the main UI.
    GameSelectorProtocol,                               //Protocol for selecting games.
    SettingsChangedProtocol,                            //Protocol for receiving settings change notifications.
    ThemeUpdatedProtocol                                //Protocol for receiving updates to the theme.
{
    // MARK: - Globals.
    
    /// 3D game view instance.
    public var GameView3D: View3D? = nil
    
    /// Game logic instance.
    public var Game: GameLogic!
    
    /// Theme manager.
    public var Themes: ThemeManager3!
    
    /// AI test data table.
    public var AIData: AITestTable? = nil
    
    /// Currently playing flag.
    public var CurrentlyPlaying: Bool = false
    
    /// Paused flag.
    public var IsPaused: Bool = false
    
    /// In attract (eg, AI) mode.
    public var InAttractMode: Bool = true
    
    /// The set of pieces to use.
    public var GamePieces = [MetaPieces.Standard]
    
    /// Multi-peer manager for debugging.
    public var MPMgr: MultiPeerManager!
    
    /// Local commands for debugging.
    public var LocalCommands: ClientCommands!
    
    /// Message handler for debugging.
    public var MsgHandler: MessageHandler!
    
    /// Prefix for use with the TDebug program.
    public var TDebugPrefix: UUID!
    
    // MARK: - UI-required initialization functions.
    
    /// Handle the viewDidLoad event.
    override public func viewDidLoad()
    {
        super.viewDidLoad()
        
        #if false
        //Used to dump the fonts on the system, including those embedded with this application. The names are used to ensure
        //the font name is correct in the program. This code is needed only to ensure proper font name and should be commented
        //out after name verification.
        for Family in UIFont.familyNames
        {
            print(Family)
            for Names in UIFont.fontNames(forFamilyName: Family)
            {
                print("  \(Names)")
            }
        }
        #endif
        
        ActivityLog.Initialize()
        #if targetEnvironment(simulator)
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "Hardware", Source: "MainViewController", KVPs: [("Hardware","Simulator")], LogFileName: &NotUsed)
        #else
        var NotUsed: String? = nil
        let HardwareName = Platform.NiceModelName()
        let MetalName = Platform.MetalDeviceName()
        let RAM = Platform.RAMSize()
        let Total = RAM.0 + RAM.1
        ActivityLog.AddEntry(Title: "Hardware", Source: "MainViewController", KVPs: [("Device",HardwareName),("Metal",MetalName),("RAM","\(Total)")], LogFileName: &NotUsed)
        ActivityLog.AddEntry(Title: "Software", Source: "MainViewController", KVPs: [("OS", Platform.iOSVersion())], LogFileName: &NotUsed)
        #endif
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
                    print("Not authorized to display badges. (\((error?.localizedDescription)!))")
                }
        }
        )
        #endif
        
        #if false
        //Initialize the link with TDebug.
        //Right now, iOS 13 has a but with multi-peer networking so we need to comment this out.
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
        BoardManager.Initialize()
        PieceManager.Initialize()
        Themes = ThemeManager3()
        Themes.Initialize()
        UserTheme = Themes.UserTheme
        Themes.SubscribeToChanges(Subscriber: "MainViewController", SubscribingObject: self)
        PreviousGameShape = UserTheme!.BucketShape
        PieceVisualManager2.Initialize()
        RecentlyUsedColors.Initialize(WithLimit: Settings.GetMostRecentlyUsedColorListCapacity())
        HistoryManager.Initialize()
        
        InitializeUI()
        AIData = AITestTable()
        
        InitializeGameUI()
        setNeedsStatusBarAppearanceUpdate()
        
        Stepper.Delegate = self
    }
    
    /// Called when the version box disappears.
    public func VersionBoxDisappeared()
    {
        VersionBoxShowing = false
    }
    
    /// Version box is showing flag.
    private var VersionBoxShowing = true
    
    /// Prevents `viewDidLayoutSubviews` from showing more than one version box.
    public var VersionShown = false
    
    /// Number of seconds the instance has been running.
    public var InstanceSeconds: Int = 0
    
    /// Game instance second counter. Used to keep track of how long the program (not necessarily game) is running. If the proper
    /// settings are in place, the seconds are displayed in the UI.
    @objc public func IncrementSeconds()
    {
        InstanceSeconds = InstanceSeconds + 1
         if !Settings.ShowFPSInUI()
         {
            return
        }
        if Settings.ShowInstanceSeconds()
        {
            if (GameView3D?.IsDisabledButton(.FPSButton))!
            {
                GameView3D?.EnableControl(Which: .FPSButton)
            }
            GameView3D?.SetText(OnButton: .FPSButton, ToNextText: "\(InstanceSeconds)")
        }
    }
    
    /// User theme.
    public var UserTheme: ThemeDescriptor2? = nil
    
    /// If the view is disappearing, save data as it may not come back.
    /// - Parameter animated: Passed to the super class.
    override public func viewDidDisappear(_ animated: Bool)
    {
        Themes.SaveUserTheme()
        super.viewDidDisappear(animated)
    }
    
    /// Initialize the game view and game UI.
   public func InitializeGameUI()
    {
        //Initialize buttons.
        EnableFreezeInPlaceButton(false)
        
        Game = GameLogic(UserTheme: UserTheme!, EnableAI: false)
        Game.UIDelegate = self
        Game.AIDelegate = self
        
        //Initialize the 3D game viewer.
        GameView3D = GameUISurface3D
        GameView3D?.Main = self
        GameView3D?.Initialize(With: Game!.GameBoard!, Theme: Themes, BucketShape: UserTheme!.BucketShape) 
        GameView3D?.Owner = self
        GameView3D?.SmoothMotionDelegate = self
        Smooth3D = GameView3D
        
        //Initialize the game text layer.
        TextLayerView.Initialize(With: UUID.Empty, LayerFrame: TextLayerView.frame)
        GameTextOverlay = TextOverlay(Device: UIDevice.current.userInterfaceIdiom)
        GameTextOverlay?.MainClassDelegate = self
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            let InstanceWidth = self.view.bounds.width
            PressPlayLabelView.frame = CGRect(x: PressPlayLabelView.frame.minX,
                                              y: PressPlayLabelView.frame.minY,
                                              width: InstanceWidth,
                                              height: PressPlayLabelView.frame.height)
            NextPieceViewControl.frame = CGRect(x: 20,
                                                y: NextPieceViewControl.frame.minY,
                                                width: NextPieceViewControl.frame.width,
                                                height: NextPieceViewControl.frame.height)
            CurrentScoreLabelView.frame = CGRect(x: InstanceWidth - CurrentScoreLabelView.frame.width,
                                                 y: CurrentScoreLabelView.frame.minY,
                                                 width: CurrentScoreLabelView.frame.width,
                                                 height: CurrentScoreLabelView.frame.height)
            HighScoreLabelView.frame = CGRect(x: InstanceWidth - HighScoreLabelView.frame.width,
                                              y: HighScoreLabelView.frame.minY,
                                              width: HighScoreLabelView.frame.width,
                                              height: HighScoreLabelView.frame.height)
        }
        GameTextOverlay?.SetControls(CurrentScoreLabel: CurrentScoreLabelView,
                                     HighScoreLabel: HighScoreLabelView,
                                     GameOverLabel: GameOverLabelView,
                                     PressPlayLabel: PressPlayLabelView,
                                     PauseLabel: PauseLabelView,
                                     PieceControl: NextPieceViewControl)
        NextPieceView.layer.backgroundColor = UIColor.clear.cgColor
        NextPieceView.layer.borderColor = UIColor.clear.cgColor
        GameTextOverlay?.ShowPressPlay(Duration: 0.7)
        
        if VersionBoxNotYetShown
        {
            //Only show the version box once.
            VersionBoxNotYetShown = false
            VersionBoxShowing = true
            GameView3D?.ShowAboutBox(FadeInDuration: 0.02, HideAfter: 10.0)
        }
        
        let AutoStartDuration = UserTheme!.AutoStartDuration
        let _ = Timer.scheduledTimer(timeInterval: AutoStartDuration, target: self,
                                     selector: #selector(AutoStartInAttractMode),
                                     userInfo: nil, repeats: false)
        
        InitializeGestures()
        
        if UserTheme!.ShowHeartbeat
        {
            StartHeartbeat()
        }
        
        if Settings.GetShowCameraControls()
        {
            GameView3D?.EnableControl(Which: .VideoButton)
            GameView3D?.EnableControl(Which: .CameraButton)
        }
        else
        {
            GameView3D?.DisableControl(Which: .VideoButton)
            GameView3D?.DisableControl(Which: .CameraButton)
        }
    }
    
    private var VersionBoxNotYetShown: Bool = true
    
    /// Sets the enable state of the freeze in place action button.
    /// - Note: This button is provided for certain games that need a way to freeze a piece in place that may not be near
    ///         near any other piece.
    /// - Parameter DoEnable: The enable flag for the button.
    public func EnableFreezeInPlaceButton(_ DoEnable: Bool)
    {
        if DoEnable
        {
            GameUISurface3D?.AppendButton(Which: .FreezeButton)
        }
        else
        {
            GameUISurface3D?.RemoveButton(Which: .FreezeButton)
        }
    }
    
    /// Holds the text overlay.
    public var GameTextOverlay: TextOverlay? = nil
    
    /// Initialize the non-game UI (things that are not directly related to the game board).
    public func InitializeUI()
    {
        Settings.AddSubscriber(For: "Main", NewSubscriber: self)
        if Settings.ShowFPSInUI()
        {
            GameView3D?.SetText(OnButton: .FPSButton, ToNextText: "°")
        }
        else
        {
            GameView3D?.DisableControl(Which: .FPSButton)
        }
    }
    
    /// Set motion control visibility.
    public func ShowMotionControls()
    {
        let DoShow = Settings.GetShowMotionControls()
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "UI", Source: "MainViewController", KVPs: [("ShowMotionControls","\(DoShow)")],
                             LogFileName: &NotUsed)
        if DoShow
        {
            GameUISurface3D?.ShowControls()
        }
        else
        {
            GameUISurface3D?.HideControls()
        }
    }
    
    /// Handle changed settings.
    /// - Parameter Field: The settings field that changed.
    /// - Parameter NewValue: The new value for the specified field.
    public func SettingChanged(Field: SettingsFields, NewValue: Any)
    {
        switch Field
        {
            case .ShowCameraControls:
                if Settings.GetShowCameraControls()
                {
                    GameView3D?.EnableControl(Which: .VideoButton)
                    GameView3D?.EnableControl(Which: .CameraButton)
                }
                else
                {
                    GameView3D?.DisableControl(Which: .VideoButton)
                    GameView3D?.DisableControl(Which: .CameraButton)
            }
            
            case .ShowMotionControls:
                ShowMotionControls()
            
            case .ShowFPSInUI:
                let DoShowFPS = NewValue as! Bool
                if DoShowFPS
                {
                    GameView3D?.EnableControl(Which: .FPSButton)
                }
                else
                {
                    GameView3D?.DisableControl(Which: .FPSButton)
            }
            case .InterfaceLanguage:
                break
            
            default:
                break
        }
    }
    
    /// Initialize gesture recognizers for piece motions.
    public func InitializeGestures()
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
    
    /// Holds the menu showing flag.
    public var MenuShowing = false
    
    /// Handle taps in the game view. Depending on where the tap is, the piece will move in the given direction.
    /// - Note: If the version box is showing (which should happen only when the game starts), tapping will remove the version box.
    ///         In this case, if the user taps on a control (such as Play), the control will be executed as well after removing
    ///         the version box.
    /// - Parameter Recognizer: The tap gesture.
    @objc public func HandleTap(Recognizer: UITapGestureRecognizer)
    {
        if Recognizer.state == .ended
        {
            if VersionBoxShowing
            {
                GameView3D?.HideAboutBox(HideDuration: 0.2)
                //Do not return here but just drop through. This is because if the version box is showing and the user taps a
                //control, if we return here, the control tap will be ignored, frustrating the user. This way, we still close
                //the version box early when the user taps on the screen and execute the command as well, as the user expects.
            }
            let Location = Recognizer.location(in: GameUISurface3D)
            let Point = Recognizer.location(in: GameUISurface3D)
            let HitResults = GameUISurface3D.hitTest(Point, options: [.boundingBoxOnly: true])
            if HitResults.count > 0
            {
                let Node = HitResults[0].node
                if let PressedNode = Node as? SCNButtonNode
                {
                    if !PressedNode.IsPressable
                    {
                        return
                    }
                    if PressedNode.ShowPressed
                    {
                        PressedNode.HighlightButton(ResetDuration: 1.0, Delay: 0.1)
                    }
                    switch PressedNode.ButtonType
                    {
                        case .MainButton:
                            //This is handled elsewhere in this function.
                            break
                        
                        case .PlayButton:
                            HandlePlayStopPressed()
                        
                        case .PauseButton:
                            HandlePauseResumePressed()
                        
                        case .CameraButton:
                            SaveGameViewAsImage()
                        
                        case .VideoButton:
                            HandleScreenRecording()
                        
                        case .FPSButton:
                            let OldShowSeconds = Settings.ShowInstanceSeconds()
                            print("FPS shows seconds: \(!OldShowSeconds)")
                            Settings.SetShowInstanceSeconds(NewValue: !OldShowSeconds)
                        
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
                        
                        case .HeartButton:
                            break
                        
                        default:
                            break
                    }
                }
                else
                {
                    if Node.name != nil
                    {
                        if Node.name! == "MainButtonObject"
                        {
                            MenuShowing = !MenuShowing
                            if MenuShowing
                            {
                                GameView3D?.ChangeMainButtonTexture(To: UIImage(named: "Checkerboard64RedYellow")!)
                                ShowPopOverMenu()
                            }
                            else
                            {
                                GameView3D?.ChangeMainButtonTexture(To: UIImage(named: "Checkerboard64")!)
                            }
                        }
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
    public func TranslateTapToMotion(TapLocation: CGPoint, SurfaceSize: CGSize) -> Directions
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
    /// - Parameter sender: The swipe gesture.
    @objc public func HandleSwipeUp(sender: UISwipeGestureRecognizer)
    {
        if sender.state == .ended
        {
            AI_MoveUpAndAway()
            MoveUpAndAway()
        }
    }
    
    /// Handle swipe down gestures in the game view. This is the same as a drop piece event.
    /// - Parameter sender: The swipe gesture.
    @objc public func HandleSwipeDown(sender: UISwipeGestureRecognizer)
    {
        if sender.state == .ended
        {
            AI_DropDown()
            DropDown()
        }
    }
    
    /// Handle swipe left gestures in the game view. This is the same as a rotate left event.
    /// - Parameter sender: The swipe gesture.
    @objc public func HandleSwipeLeft(sender: UISwipeGestureRecognizer)
    {
        if sender.state == .ended
        {
            AI_RotateLeft()
            RotateLeft()
        }
    }
    
    /// Handle swipe right gestures in the game view. This is the same as a rotate right event.
    /// - Parameter sender: The swipe gesture.
    @objc public  func HandleSwipeRight(sender: UISwipeGestureRecognizer)
    {
        if sender.state == .ended
        {
            AI_RotateRight()
            RotateRight()
        }
    }
    
    // MARK: - Functions related to AI/attract mode and debugging.
    
    /// Clears the board and starts in AI mode.
    public func ClearAndStartAI()
    {
        DispatchQueue.main.sync
            {
                GameView3D?.DestroyMap3D(FromBoard: Game.GameBoard!, DestroyBy: UserTheme!.DestructionMethod, MaxDuration: 1.25)
        }
        HandleStartInAIMode()
    }
    
    /// Start playing in AI mode.
    public func HandleStartInAIMode()
    {
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "Game", Source: "MainViewController", KVPs: [("Message","Starting game in AI mode.")],
                             LogFileName: &NotUsed)
        Game.StopGame()
        InAttractMode = true
        Game.AIScoringMethod = .OffsetMapping
        GameView3D?.DrawMap3D(FromBoard: Game.GameBoard!, CalledFrom: "HandleStartInAIMode")
        
        DebugClient.Send("Game \(GameCount) started in attract mode.")
        Game.StartGame(EnableAI: true, PieceCategories: [.Standard], UseFastAI: UseFastAI)
        DumpGameBoard(Game.GameBoard!)
        GameView3D?.SetText(OnButton: .PlayButton, ToNextText: "Stop")
        ForceResume()
        
        DebugClient.SetIdiotLight(IdiotLights.B2, Title: "Playing", FGColor: ColorNames.WhiteSmoke, BGColor: ColorNames.PineGreen)
        DebugClient.SetIdiotLight(IdiotLights.A2, Title: "Attract Mode", FGColor: ColorNames.Blue, BGColor: ColorNames.WhiteSmoke)
    }
    
    // MARK: - Game engine and related protocol-required functions.
    
    /// The game wants us to set the opacity of the specified piece.
    ///
    /// - Note: This is called when a piece is being thrown away.
    ///
    /// - Parameters:
    ///   - To: The new opacity/alpha level.
    ///   - ID: The ID of the piece whose alpha/opacity level will be set.
    public func SetPieceOpacity(To: Double, ID: UUID)
    {
    }
    
    /// Sets the opacity of a 3D piece.
    /// - Parameter To: The new opacity/alpha level.
    /// - Parameter ID: The ID of the piece whose alpha/opacity level will be set.
    /// - Parameter Duration: Length of time to change the opacity.
    public func SetPieceOpacity(To: Double, ID: UUID, Duration: Double)
    {
        GameView3D?.SetOpacity(OfID: ID, To: To, Duration: Duration)
    }
    
    /// Called when a piece is successfully moved.
    ///
    /// - Parameters:
    ///   - MovedPiece: The piece that moved.
    ///   - Direction: The direction the piece moved.
    ///   - Commanded: True if the piece was commanded to move, false if gravity caused the movement.
    public func PieceMoved(_ MovedPiece: Piece, Direction: Directions, Commanded: Bool)
    {
    }
    
    /// Called when a piece is successfully moved in a 3D game.
    ///
    /// - Parameters:
    ///   - MovedPiece: The piece that moved.
    ///   - Direction: The direction the piece moved.
    ///   - Commanded: True if the piece was commanded to move, false if gravity caused the movement.
    public func PieceMoved3D(_ MovedPiece: Piece, Direction: Directions, Commanded: Bool)
    {
        GameView3D?.DrawPiece3D(InBoard: Game!.GameBoard!, GamePiece: MovedPiece)
    }
    
    /// Number of games run in the current instance.
    public var GameCount: Int = 1
    
    /// ID of the last game duration.
    public let LastGameDurationID = UUID()
    /// ID of the last game piece count.
    public let LastGamePieceCountID = UUID()
    /// ID of the mean game duration.
    public let MeanGameDurationID = UUID()
    /// ID of the mean game piece count.
    public let MeanGamePieceCountID = UUID()
    /// Cumulative piece count.
    public var CumulativePieceCount = 0
    /// Cumulative game duration.
    public var CumulativeGameDuration = 0.0
    /// Cumulative duration.
    public var CumulativeDuration: Double = 0.0
    /// Cumulative pieces.
    public var CumulativePieces: Double = 0.0
    
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
    public func GameOver()
    {
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "Game", Source: "MainViewController", KVPs: [("Message","Game over condition reached.")],
                             LogFileName: &NotUsed)
        let GamePlayDuration = CACurrentMediaTime() - GamePlayStart
        let History = HistoryManager.GetHistory(InAttractMode)
        #if false
        History?.Games![CurrentBaseGameType]!.AddDuration(NewDuration: Int(GamePlayDuration))
        History?.Games![CurrentBaseGameType]!.SetHighScore(NewScore: Game.HighScore)
        History?.Games![CurrentBaseGameType]!.AddScore(NewScore: Game.CurrentGameScore)
        #endif
        HistoryManager.Save()
        GameView3D?.SetText(OnButton: .PlayButton, ToNextText: "Play")
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
        GameTextOverlay?.HideNextPiece(Duration: 0.1)
        GameTextOverlay?.ShowPressPlay(Duration: 0.5)
        
        StopAccumulating = true
        let MeanVal = AccumulatedFPS / Double(FPSSampleCount)
        if !Settings.ShowInstanceSeconds()
        {
            let MeanFPSText = "μ \(Convert.RoundToString(MeanVal, ToNearest: 0.001, CharCount: 6))"
            GameView3D?.SetText(OnButton: .FPSButton, ToNextText: MeanFPSText)
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
        if UserTheme!.ShowOffAfterGameOver
        {
            GameView3D?.ShowOffRotations(Duration: 0.35, Delay: 1.0)
        }
    }
        
    /// Hides the game over text in the game view.
    @objc public func HideGameOverText()
    {
        GameTextOverlay?.HideGameOver(Duration: 1.0)
    }
    
    /// Notice by the game that a piece stopped out of bounds (eg, sticking out the entrance of the bucket).
    ///
    /// - Parameter ID: ID of the piece that is out-of-bounds.
    public func OutOfBounds(_ ID: UUID)
    {
        GameView3D?.PieceOutOfBounds(ID)
    }
    
    /// Notice by the game that a piece has started freezing. This does not preclude the event that the piece may unfreeze and
    /// move again.
    ///
    /// - Parameter ID: The ID of the piece that started freezing.
    public func StartedFreezing(_ ID: UUID)
    {
    }
    
    /// Notice by the game that a piece that had started to freeze was moved and is no longer frozen.
    /// - Parameter ID: The ID of the piece that is no longer frozen.
    public func StoppedFreezing(_ ID: UUID)
    {
    }
    
    /// Start playing in attract mode.
    @objc public func AutoStartInAttractMode()
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
    public func GameStateChanged(NewState: GameStates)
    {
    }
    
    /// The contents of the map were updated. Update the views. Update game statistics.
    public func MapUpdated()
    {
        let History = HistoryManager.GetHistory(InAttractMode)
        #if false
        History?.Games![CurrentBaseGameType]!.IncrementPieceCount()
        #endif
        let BoardClass = BoardData.GetBoardClass(For: UserTheme!.BucketShape)!
        switch BoardClass
        {
            case .Static:
                print("At MapUpdated")
                GameView3D?.DrawMap3D(FromBoard: Game.GameBoard!, CalledFrom: "MapUpdated")
            
            case .Rotatable:
                break
            
            case .ThreeDimensional:
                break
        }
        DumpGameBoard(Game.GameBoard!)
    }
    
    /// The active piece moved. Depending on whether we are in smooth mode or not, we do
    /// different things.
    public func PieceUpdated(_ ThePiece: Piece, X: Int, Y: Int)
    {
        let BoardClass = BoardData.GetBoardClass(For: UserTheme!.BucketShape)!
        switch BoardClass
        {
            case .Static:
                break
            
            case .Rotatable:
                GameView3D?.DrawPiece3D(InBoard: Game.GameBoard!, GamePiece: ThePiece)
            
            case .ThreeDimensional:
                break
        }
    }
    
    /// Start a fast drop motion.
    /// - Parameter DeltaY: How far to drop the piece.
    public func StartFastDrop(DeltaY: Int, WithPiece: Piece)
    {
        print("Started fast drop by \(DeltaY) points.")
        GameView3D?.MovePieceRelative(WithPiece: WithPiece, DeltaX: 0, DeltaY: -DeltaY, TotalDuration: 0.1,
                                      Completed:
            {
                MovedPiece in
                MovedPiece.FreezeAfterDropDown()
        })
    }
    
    /// The specified piece froze. Draw the new map.
    /// - Note: The `.Rotating4` game rotation is finalized via a `DispatchQueue.main.asyncAfter` call to `RotateFinishFinalizing` and
    ///         not a completion handler on the `SCNAction.rotateBy` call in the game view because if the completion handler is slow
    ///         for some reason, animation stutters/stalls. If the code is moved out of the completion handler, the worst is it takes
    ///         a few seconds for a new piece to appear rather than stalling animation. Another benefit of doing things this way is
    ///         it makes it a lot easier to debug code issues in the game and not in the SDK.
    /// - Parameter ThePiece: The finalized piece.
    public func PieceFinalized(_ ThePiece: Piece)
    {
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "Game", Source: "MainViewController", KVPs: [("Message","Piece finalized."),("PieceID",ThePiece.ID.uuidString)],
                             LogFileName: &NotUsed)
        let BoardClass = BoardData.GetBoardClass(For: UserTheme!.BucketShape)!
        switch BoardClass
        {
            case .Static:
                GameView3D?.MergePieceIntoBucket(ThePiece)
                GameView3D?.DrawMap3D(FromBoard: Game!.GameBoard!, CalledFrom: "PieceFinalized")
                break
            
            case .Rotatable:
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
            
            case .ThreeDimensional:
                break
        }
    }
    
    //var DispatchCalled: Double = 0.0
    
    /// Do nothing. Place holder for completion handler for rotating contents.
    public func Nop()
    {
        //Nothing here...
    }
    
    /// Not currently used.
    private var CRotateIndex = 0
    /// Not currently used.
    private var RotateIndex = 0
    /// Not currently used.
    private let RightRotations: [Angles] = [.Angle270, .Angle180, .Angle90, .Angle0]
    /// Not currently used.
    private let LeftRotations: [Angles] = [.Angle90, .Angle180, .Angle270, .Angle0]
    
    /// Finish finalizing a piece when no rotation occurs.
    public func NoRotateFinishFinalizing()
    {
        GameView3D?.DrawMap3D(FromBoard: Game!.GameBoard!, CalledFrom: "NoRotateFinishFinalizing")
        Game!.DoSpawnNewPiece()
    }
    
    /// Finish finalizing a piece when rotation occurs.
    public func RotateFinishFinalizing()
    {
        GameView3D?.ClearBucket()
        GameView3D?.DrawMap3D(FromBoard: Game!.GameBoard!, CalledFrom: "RotateFinishFinalizing")
        Game!.DoSpawnNewPiece()
    }
    
    /// Notice from the game that it has a new piece score.
    ///
    /// - Parameters:
    ///   - ID: The ID of the piece.
    ///   - Score: The new score for the piece.
    public func FinalizedPieceScore(ID: UUID, Score: Int)
    {
    }
    
    /// Notice from the game that a piece was discarded.
    ///
    /// - Parameter ID: ID of the piece that was discarded.
    public func PieceDiscarded(_ ID: UUID)
    {
    }
    
    /// Notice from the game that the piece intersected with a special item.
    ///
    /// - Parameters:
    ///   - Item: The type of item the piece intersected with.
    ///   - At: The location of the intersected item.
    ///   - ID: The ID of the piece.
    public func PieceIntersectedWith(Item: PieceTypes, At: CGPoint, ID: UUID)
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
    public func PieceIntersectedWithX(Item: UUID, At: CGPoint, ID: UUID)
    {
    }
    
    /// New piece count.
    public var NewPieceCount: Int = 0
    
    /// Notice from the game that a new piece started.
    /// - Parameter NewPiece: The new piece.
    public func NewPieceStarted(_ NewPiece: Piece)
    {
        NewPieceCount = NewPieceCount + 1
    }
    
    /// Notice from the game that a row was deleted.
    /// - Parameter Row: The index of the deleted row.
    public func DeletedRow(_ Row: Int)
    {
    }
    
    /// Notice from the game that a piece was block going in some direction.
    /// - Parameter ID: The ID of the block piece.
    public func PieceBlocked(_ ID: UUID)
    {
    }
    
    /// Notice from the game that the piece successfully rotated.
    /// - Note: Not called for pieces that are rotationally symmetric.
    /// - Parameters:
    ///   - ID: ID of the piece that rotated.
    ///   - Direction: The direction the piece rotated.
    public func PieceRotated(ID: UUID, Direction: Directions)
    {
    }
    
    /// Notice from the game that a piece was unable to rotate because it was blocked.
    /// - Parameters:
    ///   - ID: ID of the piece that failed rotation.
    ///   - Direction: The direction the piece tried to rotate.
    public func PieceRotationFailure(ID: UUID, Direction: Directions)
    {
    }
    
    /// Notice from the game that the piece has a new score.
    /// - Parameters:
    ///   - For: ID of the piece with a new score.
    ///   - NewScore: The new score.
    public func PieceScoreUpdated(For: UUID, NewScore: Int)
    {
    }
    
    /// Notice from the game that a new game score is available.
    /// - Note: The game score is shown in the game view, not the UI.
    /// - Parameter NewScore: The new game score.
    public func NewGameScore(NewScore: Int)
    {
        let ScoreTitle = "Game Score\n\(NewScore)"
        DebugClient.SetIdiotLight(IdiotLights.B1, Title: ScoreTitle, FGColor: ColorNames.Black, BGColor: ColorNames.WhiteSmoke)
        GameTextOverlay?.ShowCurrentScore(NewScore: NewScore)
    }
    
    /// Notice from the game that a new high score is available.
    /// - Note: The high score is shown in the game view, not the UI.
    /// - Parameter HighScore: The new high score.
    public func NewHighScore(HighScore: Int)
    {
        let ScoreTitle = "High Score\n\(HighScore)"
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "Game", Source: "MainView", KVPs: [("HighScore","\(HighScore)")], LogFileName: &NotUsed)
        DebugClient.SetIdiotLight(IdiotLights.C1, Title: ScoreTitle, FGColor: ColorNames.Black, BGColor: ColorNames.WhiteSmoke)
        GameTextOverlay?.ShowHighScore(NewScore: HighScore, Highlight: true,
                                       HighlightColor: ColorNames.Gold, HighlightDuration: 1.0)
        PreviousHighScore = HighScore
    }
    
    /// Previous high score value.
    public var PreviousHighScore = -1
    
    /// Notice from the game what the new next piece is.
    /// - Parameter Next: The next piece after the current piece.
    public func NextPiece(_ Next: Piece)
    {
        //print("Next piece is \(Next.Shape)")
        GameTextOverlay?.ShowNextPiece(Next, Duration: 0.1)
    }
    
    /// Received a performance sample (eg, frames per second for the most recent second) from the game view.
    /// - Parameter FPS: Most recent frames per second (eg, the last second) from the game view.
    public func PerformanceSample(FPS: Double)
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
                GameView3D?.SetText(OnButton: .FPSButton, ToNextText: FPSS)
            }
        }
    }
    
    /// Stop accumulating FPS values flag.
    private var StopAccumulating: Bool = false
    /// Accumulated FPS values.
    private var AccumulatedFPS: Double = 0.0
    /// Number of accumulated FPS values.
    private var FPSSampleCount: Int = 0
    
    //var PieceFPS = [Double]()
    
    /// Notice from the game that it is done compressing the board.
    /// - Note: The board is compressed when the game (the map, actually) sees full rows and removes them.
    /// - Parameter DidCompress: True if the board was actually compressed or false if there was nothing to compress.
    public func BoardDoneCompressing(DidCompress: Bool)
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
    
    // MARK: - Control protocol functions.
    
    /// Freeze the piece in place.
    public func FreezeInPlace()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .FreezeInPlace)
        }
    }
    
    /// Move the piece left.
    public func MoveLeft()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .Left)
        }
    }
    
    /// Move the piece right.
   public func MoveRight()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .Right)
        }
    }
    
    /// Move the piece down.
    public func MoveDown()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .Down)
        }
    }
    
    /// Drop the piece down.
    public func DropDown()
    {
        if let PieceID = Game.CurrentPiece
        {
            print("At DropDown in MainViewController")
            Game.HandleInputFor(ID: PieceID, Input: .DropDown)
        }
    }
    
    /// Move the piece up.
    public func MoveUp()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .Up)
        }
    }
    
    /// Move the piece up and away (eg, discard it).
    public func MoveUpAndAway()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .UpAndAway)
        }
    }
    
    /// Rotate the piece left.
    public func RotateLeft()
    {
        if let PieceID = Game.CurrentPiece
        {
            Game.HandleInputFor(ID: PieceID, Input: .RotateLeft)
        }
    }
    
    /// Rotate the piece right.
    public func RotateRight()
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
    public func Pause()
    {
        if IsPaused
        {
            var NotUsed: String? = nil
            ActivityLog.AddEntry(Title: "Game", Source: "MainViewController", KVPs: [("Message","Game resumed.")],
                                 LogFileName: &NotUsed)
            IsPaused = false
            GameView3D?.SetText(OnButton: .PauseButton, ToNextText: "Pause")
            GameTextOverlay?.HidePause(Duration: 0.1)
            Game.ResumeGame()
            DebugClient.Send("Game resumed.")
            DebugClient.SetIdiotLight(IdiotLights.B2, Title: "Playing", FGColor: ColorNames.WhiteSmoke, BGColor: ColorNames.PineGreen)
        }
        else
        {
            var NotUsed: String? = nil
            ActivityLog.AddEntry(Title: "Game", Source: "MainViewController", KVPs: [("Message","Game paused.")],
                                 LogFileName: &NotUsed)
            IsPaused = true
            GameView3D?.SetText(OnButton: .PauseButton, ToNextText: "Resume")
            GameTextOverlay?.ShowPause(Duration: 0.1)
            Game.PauseGame()
            DebugClient.Send("Game paused.")
            DebugClient.SetIdiotLight(IdiotLights.B2, Title: "Paused", FGColor: ColorNames.PrussianBlue, BGColor: ColorNames.YellowPastel)
        }
    }
    
    /// Resume the game.
    /// - Note: Nothing is done here because `Pause` is used as a toggle for game state.
    public func Resume()
    {
    }
    
    /// Game count ID.
    public let GameCountID = UUID()
    
    /// Holds the first play of the instance.
    private var FirstPlay = true
    
    /// Clears the game board then starts a new game.
    /// - Note:
    ///   - The board is cleared in an animated fashion whose maximum duration is set in user settings.
    ///   - If the bucket is cleared visually, the pieces are removed with a duration no longer than that found in the
    ///     user settings (the key is `BucketDestructionDuration`). In this case, **Play** is called after an appropriate
    ///     delay to allow for the visuals to occur. Otherwise, **Play** is called immediately.
    ///   - If this is the first time this function is called in a given isntance, nothing is cleared and **Play** is called
    ///     immediately.
    public func ClearAndPlay()
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
                if UserTheme!.ShowOffAfterGameOver
                {
                    GameView3D?.StopShowingOff()
                }
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
    
    //When game play first started.
    public var GamePlayStart: Double = 0.0
    
    /// Play the game, eg, start in normal user mode.
    @objc public func Play()
    {
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "Game", Source: "MainViewController", KVPs: [("Message","Starting game.")],
                             LogFileName: &NotUsed)
        GamePlayStart = CACurrentMediaTime()
        let History = HistoryManager.GetHistory(InAttractMode)
        #if false
        History?.Games![CurrentBaseGameType]!.IncrementGameCount()
        #endif
        ForceResume()
        StopAccumulating = false
        RotateIndex = 0
        DebugClient.SetIdiotLight(IdiotLights.B2, Title: "Playing", FGColor: ColorNames.WhiteSmoke, BGColor: ColorNames.PineGreen)
        let GameCountMsg = MessageHelper.MakeKVPMessage(ID: GameCountID, Key: "Game Count", Value: "\(GameCount)")
        DebugClient.SendPreformattedCommand(GameCountMsg)
        
        GameView3D?.HideAboutBox(HideDuration: 0.2)
        GameTextOverlay?.HideGameOver(Duration: 0.0)
        GameTextOverlay?.HidePressPlay(Duration: 0.0)
        
        Game!.SetPredeterminedOrder(UsePredeterminedOrder, FirstIs: .T)
        
        GameDuration = CACurrentMediaTime()
        Game.StartGame(EnableAI: InAttractMode, PieceCategories: GamePieces, UseFastAI: UseFastAI)
        
        GameView3D?.DrawMap3D(FromBoard: Game.GameBoard!, CalledFrom: "Play")
        GameTextOverlay?.ShowCurrentScore(NewScore: 0)
        CurrentlyPlaying = true
        GameView3D?.SetText(OnButton: .PlayButton, ToNextText: "Stop")
        if !InAttractMode
        {
            DebugClient.SetIdiotLight(IdiotLights.A2, Title: "Normal Mode", FGColor: ColorNames.Black, BGColor: ColorNames.White)
        }
    }
    
    /// Duration of the game.
    public var GameDuration: Double = 0.0
    
    /// Show or hide the "Press Play to Start" (or equivalent) message in the game view.
    public func ShowPressPlay(_ DoShow: Bool)
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
    public func Stop()
    {
        CurrentlyPlaying = false
        Game.StopGame()
        DebugClient.Send("Game \(GameCount) stopped by user.")
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "Game", Source: "MainView", KVPs: [("Message","Game stopped by user."),
                                                                       ("GameCount","\(GameCount)")], LogFileName: &NotUsed)
        NewPieceCount = 0
        GameCount = GameCount + 1
    }
    
    /// Not currently used.
    private var _Controller: ControlUIProtocol? = nil
    
    /// Not currently used.
    public var Controller: ControlUIProtocol?
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
    
    // MARK: - Game-control related functions.
    
    public func HandleMoveLeftPressed()
    {
        MoveLeft()
    }
    
    public func HandleMoveRightPressed()
    {
        MoveRight()
    }
    
    public func HandleMoveUpPressed()
    {
        MoveUp()
    }
    
    public func HandleMoveDownPressed()
    {
        MoveDown()
    }
    
    public func HandleUpAndAwayPressed()
    {
        MoveUpAndAway()
    }
    
    public func HandleDropDownPressed()
    {
        DropDown()
    }
    
    public func HandleRotateLeftPressed()
    {
        RotateRight()
    }
    
    public func HandleRotateRightPressed()
    {
        RotateLeft()
    }
    
    public func HandleFreezeInPlacePressed()
    {
        FreezeInPlace()
    }
    
    /// Handle the play button pressed.
    /// - Note: The button's visuals will change depending on whether the game is in play or stopped.
    public func HandlePlayStopPressed()
    {
        if CurrentlyPlaying
        {
            Stop()
            GameTextOverlay?.ShowPressPlay(Duration: 0.5)
            GameView3D?.SetText(OnButton: .PlayButton, ToNextText: "Play")
        }
        else
        {
            InAttractMode = false
            Play()
            GameView3D?.SetText(OnButton: .PlayButton, ToNextText: "Stop")
        }
    }
    
    /// Handle the pause button pressed.
    /// - Note: The button's visuals will change depending on whether the game is in paused or playing.
    public func HandlePauseResumePressed()
    {
        Pause()
    }
    
    // MARK: - AI delegate functions.
    
    /// Someone wants a reference to the user theme.
    /// - Returns: Current user theme instance.
    public func GetUserTheme() -> ThemeDescriptor2?
    {
        return Themes.UserTheme
    }
    
    /// The AI delegate wants AI data.
    ///
    /// - Returns: A populated `AITestTable`.
    public func GetAIData() -> AITestTable?
    {
        return AIData
    }
    
    /// Set a new user.
    ///
    /// - Parameter UserID: ID of the new user.
    public func SetNewUser(_ UserID: UUID)
    {
    }
    
    // Mark: Game AI event protocol functions.
    
    /// AI is moving a piece upwards.
    public func AI_MoveUp()
    {
        GameUISurface3D?.FlashButton(.UpButton)
    }
    
    /// AI is throwing a piece away.
    public func AI_MoveUpAndAway()
    {
        GameUISurface3D?.FlashButton(.FlyAwayButton)
    }
    
    /// AI is moving a piece downwards.
    public func AI_MoveDown()
    {
        GameUISurface3D?.FlashButton(.DownButton)
    }
    
    /// AI is dropping a piece downwards.
    public func AI_DropDown()
    {
        GameUISurface3D?.FlashButton(.DropDownButton)
    }
    
    /// AI is moving a piece to the left.
    public func AI_MoveLeft()
    {
        GameUISurface3D?.FlashButton(.LeftButton)
    }
    
    /// AI is moving a piece to the right.
    public func AI_MoveRight()
    {
        GameUISurface3D?.FlashButton(.RightButton)
    }
    
    /// AI is rotating a piece clockwise.
    public func AI_RotateRight()
    {
        GameUISurface3D?.FlashButton(.RotateRightButton)
    }
    
    /// AI is rotating a piece counter-clockwise.
    public func AI_RotateLeft()
    {
        GameUISurface3D?.FlashButton(.RotateLeftButton)
    }
    
    /// AI is freezing a piece into place.
    public func AI_FreezeInPlace()
    {
        GameUISurface3D?.FlashButton(.FreezeButton)
    }
    
    // MARK: - Game view request functions.
    
    /// The game view wants us to redraw the board.
    public func NeedRedraw()
    {
        GameView3D?.DrawMap3D(FromBoard: Game.GameBoard!, CalledFrom: "NeedRedraw")
    }
    
    public func SendKVP(Name: String, Value: String, ID: UUID)
    {
    }
    
    // MARK: - Smooth motion protocol function implementations.
    
    /// Delegate for smooth motion protocol.
    weak public var Smooth3D: SmoothMotionProtocol? = nil
//    weak public var Smooth2D: SmoothMotionProtocol? = nil
    
    /// Move a piece smoothly to the specified location.
    /// - Parameter GamePiece: The piece to move.
    /// - Parameter ToOffsetX: Horizontal destination offset.
    /// - Parameter ToOffsetY: Vertical destination offset.
    public func SmoothMove(_ GamePiece: Piece, ToOffsetX: Int, ToOffsetY: Int)
    {
        Smooth3D?.MovePieceSmoothly(GamePiece, ToOffsetX: CGFloat(ToOffsetX), ToOffsetY: CGFloat(ToOffsetY), Duration: 0.35)
    }
    
    /// Rotate a piece smoothly in the specified direction (implied by `Degrees`).
    /// - Paramater GamePiece: The piece to rotate.
    /// - Parameter Degrees: Number of degrees to rotate the piece by.
    /// - Parameter OnAxis: The axis to rotate the piece on. 2D games use the .X axis.
    public func SmoothRotate(_ GamePiece: Piece, Degrees: CGFloat, OnAxis: RotationalAxes)
    {
        RotatePieceSmoothly(GamePiece, ByDegrees: Degrees, Duration: 0.35, OnAxis: OnAxis)
    }
    
    /// Move a piece smoothing.
    /// - Warning: If called, this function will generate a fatal error.
    public func MovePieceSmoothly(_ GamePiece: Piece, ToOffsetX: CGFloat, ToOffsetY: CGFloat, Duration: Double)
    {
        //Not used in this class.
        fatalError("I told you this function shouldn't be called here!")
    }
    
    /// Called when a smooth motion is completed.
    /// - Parameter For: The ID of the piece that moved smoothly.
    public func SmoothMoveCompleted(For: UUID)
    {
        
    }
    
    /// Rotate a piece smoothly.
    /// - Warning: If called, this function will generate a fatal error.
    public func RotatePieceSmoothly(_ GamePiece: Piece, ByDegrees: CGFloat, Duration: Double, OnAxis: RotationalAxes)
    {
        //Not used in this class.
        fatalError("I told you this function shouldn't be called here!")
    }
    
    /// Called when a smooth rotation is completed.
    /// - Parameter For: The ID of the piece that rotated smoothly.
    public func SmoothRotationCompleted(For: UUID)
    {
        
    }
    
    /// Called to create a game piece that can move smoothly.
    /// - Returns: ID of the piece to move smoothly.
    public func CreateSmoothPiece() -> UUID
    {
        return UUID.Empty
    }
    
    /// Called when the game is done moving a piece smoothly, eg, when it freezes into place.
    /// - Parameter ID: The ID of the piece to clean up.
    public func DoneWithSmoothPiece(_ ID: UUID)
    {
        
    }
    
    // MARK: - General-UI interactions.
    
    /// Determines if a predetermined order of pieces will be used.
    private var UsePredeterminedOrder: Bool = false
    
    /// Determines if we are in distraction mode.
    public var InDistractMode: Bool = false
    
    /// Determiens if fast AI motions are used.
    public var UseFastAI: Bool = false
    
    /// The attract mode timer.
    private var AttractTimer: Timer? = nil
    
    // MARK: - General UI functions
    
    /// Returns the value needed to set a dark style status bar.
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    /// Handle game type changes from the user. Called from the game type selector dialog.
    /// - Note: If the new game shape is the same as the old game shape, no action will be taken.
    /// - Parameter DidChange: If true, the game type changed. We still need to see if it is different from the current game
    ///                        type. If false, the user canceled the game selection dialog.
    /// - Parameter NewGameShape: The new shape of the game. If nil, the user canceled the game selection dialog.
    public func GameTypeChanged(DidChange: Bool, NewGameShape: BucketShapes?)
    {
        if !DidChange
        {
            return
        }
        if PreviousGameShape == nil
        {
            PreviousGameShape = NewGameShape
        }
        else
        {
            if PreviousGameShape! == NewGameShape
            {
                return
            }
        }
        SwitchGameType(NewGameType: NewGameShape!)
    }
    
    /// Change to a new game type.
    /// - Parameter NewGameType: The new game/bucket type.
    public func SwitchGameType(NewGameType: BucketShapes)
    {
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "GameType", Source: "MainViewController", KVPs: [("GameType","\(NewGameType)")],
                             LogFileName: &NotUsed)
        UserTheme!.BucketShape = NewGameType
        Themes.SaveUserTheme()
        Stop()
        InitializeGameUI()
    }
    
    var PreviousGameShape: BucketShapes? = nil
    
    // MARK: - Debug delegate functions and other debug code.
    
    /// Dump the game board as a text object.
    /// - Note: The game is dumped to a child window.
    /// - Parameters:
    ///   - Board: The board to dump.
    ///   - ShowGaps: If true, gaps are shown.
    public func DumpGameBoard(_ Board: Board, ShowGaps: Bool = false)
    {
    }
    
    // MARK: - AI Scoring for debugging.
    
    /// Set AI scoring method.
    /// - Note: Not current in use.
    /// - Parameter Method: The method to use to score with the AI.
    public func SetAIScoring(Method: AIScoringMethods)
    {
        //Not used here.
    }
    
    /// Determines if the default scoring method should be used.
    /// - Note: Not current in use.
    /// - Parameter IsDefault: If true, use the default method.
    public func SetAIDefaultScoring(IsDefault: Bool)
    {
        //Not used here.
    }
    
    /// Sets the valid piece groups to use by the AI.
    /// - Note: Not current in use.
    /// - Parameter PieceGroups: The piece groups to use.
    public func SetPieceGroups(PieceGroups: MetaPieces)
    {
        //Not used here.
    }
    
    /// How to select pices.
    /// - Note: Not current in use.
    /// - Parameter Method: The method to use to select pieces.
    public func SetPieceSelection(Method: PieceSelectionMethods)
    {
        //Not used here.
    }
    
    /// Returns the AI scoring to use.
    /// - Note: Defaults to `.OffsetMapping`.
    /// - Returns: The AI scoring to use.
    public func GetAIScoring() -> AIScoringMethods
    {
        return .OffsetMapping
    }
    
    /// Return use the default scoring method flag.
    /// - Note: Always returns false.
    /// - Returns: Value indicating whether to use the default method or not.
    public func GetAIDefaultScoring() -> Bool
    {
        return false
    }
    
    /// Returns the group of pieces to use by the AI.
    /// - Note: Always returns `.Standard`.
    /// - Returns: Piece group to use.
    public func GetPieceGroups() -> MetaPieces
    {
        return .Standard
    }
    
    // MARK: - Implementation of TDebugProtocol functions.
    
    /// Called when the connection state between us and the remote TDebug instance changes.
    /// - Parameter Connected: Will contain the connection state.
    public func RemoteConnectionStateChanged(Connected: Bool)
    {
        print("Remote connection state: \(Connected)")
        if Connected
        {
            DebugClient.SendCommandQueue()
        }
    }
    
    // MARK: - Implementation of StepperHelper protocol functions.
    
    /// Display information from a step. Control should not return until the user dismisses the UI element.
    /// - Parameter From: String describing where the step occurred.
    /// - Parameter Message: String from the step caller.
    /// - Parameter Stepped: Catagory of the step.
    public func DisplayStep(From: String, Message: String, Stepped: Steps)
    {
        
    }
    
    // MARK: - Media button handling.
    
    /// Handle the camera button press - save the current game view as an image (but not the entire screen).
    public func SaveGameViewAsImage()
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
    @objc public func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer)
    {
        if let SomeError = error
        {
            print("\(SomeError)")
        }
        else
        {
            if Settings.GetConfirmGameImageSave()
            {
                var NotUsed: String? = nil
                ActivityLog.AddEntry(Title: "UI", Source: "MainViewController", KVPs: [("Message","Image saved to camera roll.")],
                                     LogFileName: &NotUsed)
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
    public func HandleScreenRecording()
    {
        MakingVideo = !MakingVideo
        if MakingVideo
        {
            GameView3D?.SetButtonColorToHighlight(Button: .VideoButton)
            let Recorder = RPScreenRecorder.shared()
            Recorder.startRecording
                {
                    (error) in
                    if let Error = error
                    {
                        print("\(Error.localizedDescription)")
                        self.GameView3D?.SetButtonColorToNormal(Button: .VideoButton)
                    }
            }
        }
        else
        {
            GameView3D?.SetButtonColorToNormal(Button: .VideoButton)
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
    public func previewControllerDidFinish(_ previewController: RPPreviewViewController)
    {
        var NotUsed: String? = nil
        ActivityLog.AddEntry(Title: "UI", Source: "MainViewController", KVPs: [("Message","Video saved to camera roll.")],
                             LogFileName: &NotUsed)
        previewController.dismiss(animated: true)
    }
    
    /// Holds the currently-making-a-video flag.
    public var MakingVideo: Bool = false
    
    // MARK: - Theme update protocol functions.
    
    /// Handle theme change notifications.
    /// - Note:
    ///    - This version of Fouris only supports a default theme and a user theme. Only the user theme reports changes at this time.
    ///    - By the time control gets here, the changed property can be accessed to get its new value.
    /// - Parameter ThemeName: The name of the theme in which a field changed.
    /// - Parameter Field: The field that changed
    public func ThemeUpdated(ThemeName: String, Field: ThemeFields)
    {
        switch Field
        {
            case .HeartbeatInterval:
                if UserTheme!.ShowHeartbeat
                {
                    HeartbeatTimer?.invalidate()
                    HeartbeatTimer = nil
                    StartHeartbeat()
            }
            
            case .ShowHeartbeat:
                let ShowHeartbeat = UserTheme!.ShowHeartbeat
                if ShowHeartbeat
                {
                    StartHeartbeat()
                }
                else
                {
                    StopHeartbeat()
            }
            
            default:
                print("Theme \(ThemeName) updated field \(Field)")
        }
    }
    
    /// Start the heartbeat indicator. It indicates the main UI thread and the game view threads are active and responsive.
    public func StartHeartbeat()
    {
        GameView3D?.SetHeartbeatVisibility(Show: true)
        HeartbeatTimer = Timer.scheduledTimer(timeInterval: UserTheme!.HeartbeatInterval,
                                              target: self, selector: #selector(HandleHeartbeat),
                                              userInfo: nil, repeats: true)
    }
    
    /// Stop the heartbeat indicate.
    public func StopHeartbeat()
    {
        GameView3D?.SetHeartbeatVisibility(Show: false)
        HeartbeatTimer?.invalidate()
        HeartbeatTimer = nil
    }
    
    /// Update the heartbeat indicator to indicate both the UI and the game view threads are active.
    @objc public func HandleHeartbeat()
    {
        OperationQueue.main.addOperation
            {
                if self.HeartbeatCount.isMultiple(of: 2)
                {
                    self.GameView3D?.AnimateHeartbeat(IsHighlighted: true, Duration: 0.15,
                                                      Colors: (Highlighted: UIColor.red,
                                                               Normal: ColorServer.ColorFrom(ColorNames.Plum)),
                                                      Sizes: (Highlighted: 0.053, Normal: 0.05),
                                                      Extrusions: (Highlighted: 4.0, Normal: 2.0))
                }
                else
                {
                    self.GameView3D?.AnimateHeartbeat(IsHighlighted: false, Duration: 0.15,
                                                      Colors: (Highlighted: UIColor.red,
                                                               Normal: ColorServer.ColorFrom(ColorNames.Plum)),
                                                      Sizes: (Highlighted: 0.053, Normal: 0.05),
                                                      Extrusions: (Highlighted: 4.0, Normal: 2.0))
                }
                self.HeartbeatCount = self.HeartbeatCount + 1
        }
    }
    
    /// Number of heartbeat counts.
    private var HeartbeatCount: Int = 0
    
    /// The heartbeat timer.
    private var HeartbeatTimer: Timer? = nil
    
    // MARK: - Pop-over main menu.
    
    /// Shows the pop-over menu. This menu (a pop-over view controller in reality) is invoked by the user pressing the main button
    /// in the game UI.
    public func ShowPopOverMenu()
    {
        if let PopController = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "MainButtonMenuUI") as? MainButtonMenuCode
        {
            PopController.modalPresentationStyle = UIModalPresentationStyle.popover
            PopController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.any
            PopController.popoverPresentationController?.delegate = self
            PopController.popoverPresentationController?.sourceView = GameView3D!
            PopController.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 20, width: 20, height: 20)
            PopController.Delegate = self
            self.present(PopController, animated: true, completion: nil)
        }
    }
    
    /// Receives the command the user invoked in the pop-over menu.
    /// - Note: Some commands may be sent from main menu sub-menus and passed through the main menu before it reaches us.
    /// - Parameter Command: The command to run.
    public func RunPopOverCommand(_ Command: PopOverCommands)
    {
        switch Command
        {
            case .MakeVideo:
                HandleScreenRecording()
            
            case .PausePlaying:
                HandlePauseResumePressed()
            
            case .ResumePlaying:
                HandlePauseResumePressed()
            
            case .RunAbout:
                if let AboutController = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "AboutDialog") as? AboutDialogController
                {
                    ForcePause()
                    self.present(AboutController, animated: true, completion: nil)
            }
            
            case .RunInAttractMode:
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
            
            case .RunSelectGame:
                if let SelectController = UIStoryboard(name: "MainStoryboard", bundle: nil).instantiateViewController(withIdentifier: "GameSelection") as? SelectGameController
                {
                    ForcePause()
                    SelectController.SelectorDelegate = self
                    self.present(SelectController, animated: true, completion: nil)
            }
            
            case .RunSettings:
                let Storyboard = UIStoryboard(name: "Theming", bundle: nil)
                if let Controller = Storyboard.instantiateViewController(withIdentifier: "MainThemeEditor") as? ThemeEditorController
                {
                    ForcePause()
                    Controller.EditTheme(Theme: Themes!.UserTheme!)
                    self.present(Controller, animated: true, completion: nil)
            }
            
            case .StartPlaying:
                HandlePlayStopPressed()
            
            case .StopPlaying:
                HandlePlayStopPressed()
            
            case .TakePicture:
                SaveGameViewAsImage()
            
            case .CreateBoards:
                GameView3D?.Debug("Dump Boards")
            
            case .ToggleRegions:
                if ShowingRegions
                {
                    ShowingRegions = false
                    GameView3D?.Debug("Hide Regions")
                }
                else
                {
                    ShowingRegions = true
                    GameView3D?.Debug("Show Regions")
            }
            
            case .ToggleGrid:
                if ShowingDebugGrid
                {
                    ShowingDebugGrid = false
                    GameView3D?.Debug("Hide Grid")
                }
                else
                {
                    ShowingDebugGrid = true
                    GameView3D?.Debug("Show Grid")
            }
            
            case .RunFlameAction:
                break
            
            case .PopOverClosed:
                break
        }
    }
    
    /// Holds the showing debug grid flag.
    public var ShowingDebugGrid: Bool = false
    /// Holds the showing debug regions flag.
    public var ShowingRegions: Bool = false
    
    /// Updates the main menu button to indicate whether it has been pressed or not.
    /// - Note: This functionality is not really needed but it was fun to change the texture on the node.
    /// - Parameter Opened: Determines the state of the the open indicator for the main menu button.
    private func UpdateMainButton(_ Opened: Bool)
    {
        if Opened
        {
            GameView3D?.ChangeMainButtonTexture(To: UIImage(named: "Checkerboard64RedYellow")!)
        }
        else
        {
            GameView3D?.ChangeMainButtonTexture(To: UIImage(named: "Checkerboard64")!)
        }
    }
    
    /// Reset the main button. Intended to be called from the pop-over menu.
    public func ResetMainButton()
    {
        UpdateMainButton(false)
    }
    
    /// Needed for the pop-over menu controller.
    /// - Parameter for: See Apple documentation.
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle
    {
        return UIModalPresentationStyle.none
    }
    
    // MARK: - Variables used by TDebug from within extensions.
    
    /// Timer for echoing messages to other peers.
    public var EchoTimer: Timer!
    /// The peer to echo to.
    public var EchoBackTo: MCPeerID!
    /// The message to echo.
    public var MessageToEcho: String!
    /// Array of what TDebug is waiting for.
    public var WaitingFor = [(UUID, MessageTypes)]()
    /// ID of the debug/logging peer.
    public var DebugPeerID: MCPeerID? = nil
    /// Prefix of the debug/logging peer.
    public var DebugPeerPrefix: UUID? = nil
    
    // MARK: - Interface builder outlets.
    
    @IBOutlet weak var GameUISurface3D: View3D!
    @IBOutlet weak var GameViewContainer: UIView!
    @IBOutlet weak var TextLayerView: TextLayerManager!
    @IBOutlet weak var NextPieceView: UIView!
    @IBOutlet weak var NextPieceViewControl: PieceViewer!
    @IBOutlet weak var CurrentScoreLabelView: UIView!
    @IBOutlet weak var HighScoreLabelView: UIView!
    @IBOutlet weak var PressPlayLabelView: UIView!
    @IBOutlet weak var GameOverLabelView: UIView!
    @IBOutlet weak var PauseLabelView: UIView!

}

extension UIView
{
    /// Return the view (and its sub-views) as an image.
    /// - Note: See [How to Convert a UIView to an Image](https://stackoverflow.com/questions/30696307/how-to-convert-a-uiview-to-an-image)
    /// - Returns: UIImage of the instance UIView. Nil on error.
    public func AsImage() -> UIImage?
    {
        UIGraphicsBeginImageContextWithOptions(self.frame.size, false, 0.0)
        self.drawHierarchy(in: self.bounds, afterScreenUpdates: false)
        let Image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return Image!
    }
}
