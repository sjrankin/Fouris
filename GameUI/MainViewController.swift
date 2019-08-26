//
//  MainViewController.swift
//  Fouris
//
//  Created by Stuart Rankin on 5/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import SceneKit
import MultipeerConnectivity
import UIKit

class MainViewController: UIViewController,
    GameUINotificationProtocol,                         //Protocol for communicating from the game engine (and everything below it) to the UI.
    GameAINotificationProtocol,                         //Protocol for communication from the game AI engine to the UI.
    MainDelegate,                                       //Protocol for exporting some functionality defined in this class.
    ControlProtocol,                                    //Protocol for receiving motion and other commands from the motion controller.
    DebugDelegate,                                      //Protocol for sending debug information to a local window.
    GameViewRequestProtocol,                            //Protocol for game views to request information from the controller.
    SmoothMotionProtocol,                               //Protocol for handling smooth motions.
    TDebugProtocol,                                     //Protocol for the debug client to talk to this class.
    StepperHelper,                                      //Protocol for the stepper to display data for the user.
    UITouchImageDelegate                                //Protocol for touch image presses.
{
    // MARK: Globals.
    
    /// 3D game view instance.
    var GameView3D: View3D? = nil
    
    /// Game logic instance.
    var Game: GameLogic!
    
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
    
    /// The current level the user is playing.
    var CurrentLevel = LevelTypes.ReallyEasy
    
    /// The current mode.
    var CurrentMode = ModeTypes.AttractMode
    
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
        
        Settings.Initialize()
        MasterPieceList.Initialize()
        LevelManager.Initialize()
        ThemeManager.Initialize()
        InitializeUI()
        AIData = AITestTable()
        
        CurrentBaseGameType = Settings.GetGameType()
        print("BaseGameType=\(CurrentBaseGameType)")
        
        InitializeGameUI()
        setNeedsStatusBarAppearanceUpdate()
        
        let HostOSName = "iOS"
        DebugClient.SetIdiotLight(IdiotLights.A3, Title: "Host OS: \(HostOSName)",
            FGColor: ColorNames.Black, BGColor: ColorNames.Cyan)
        
        Stepper.Delegate = self
        MoveLeftButton.Delegate = self
        MoveDownButton.Delegate = self
        RotateLeftButton.Delegate = self
        MoveUpButton.Delegate = self
        MoveRightButton.Delegate = self
        RotateRightButton.Delegate = self
        DropDownButton.Delegate = self
        UpAndAwayButton.Delegate = self
 }
    
    /// If the view is disappearing, save data as it may not come back.
    /// - Parameter animated: Passed to the super class.
    override func viewDidDisappear(_ animated: Bool)
    {
        Settings.SaveUserData()
        ThemeManager.SaveThemes()
        super.viewDidDisappear(animated)
    }
    
    /// Initialize the game view and game UI.
    ///
    /// - Note: When running under macOS, sometimes viewDidLayout (which calls this function) gets called multiple times,
    ///         meaning we may end up with multiple game views. To avoid this (for macOS only), we remove the game view
    ///         from the super layer before adding it back in.
    func InitializeGameUI()
    {
        InitializeOptionTable(MainSlideInOptionTable)
        print("Initializing game with \(CurrentBaseGameType)")
        Game = GameLogic(BaseGame: CurrentBaseGameType, EnableAI: false)
        Game.UIDelegate = self
        Game.AIDelegate = self
        
        //Initialize the 3D game viewer.
        GameView3D = GameUISurface3D
        GameView3D?.Initialize(With: Game!.GameBoard!, Theme: ThemeManager.GetDefault3DThemeID()!,
                               BaseType: CurrentBaseGameType)
        GameView3D?.Owner = self
        GameView3D?.SmoothMotionDelegate = self
        Smooth3D = GameView3D
        //GameUISurface3D.layer.cornerRadius = 5.0
        GameUISurface3D.layer.borderColor = UIColor.black.cgColor
        GameUISurface3D.layer.borderWidth = 1.0
        
        //Initialize the game text layer.
        GameTextOverlay = TextOverlay(Device: UIDevice.current.userInterfaceIdiom)
        GameTextOverlay?.SetControls(NextLabel: NextPieceLabelView,
                                     NextPieceView: NextPieceView,
                                     ScoreLabel: ScoreLabelView,
                                     CurrentScoreLabel: CurrentScoreLabelView,
                                     HighScoreLabel: HighScoreLabelView,
                                     GameOverLabel: GameOverLabelView,
                                     PressPlayLabel: PressPlayLabelView,
                                     PauseLabel: PauseLabelView)
        
        GameTextOverlay?.ShowPressPlay(Duration: 0.7)
        
        //Initialize view backgrounds.
        GameControlView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.ReallyDarkGray)
        MotionControlView.layer.backgroundColor = ColorServer.CGColorFrom(ColorNames.ReallyDarkGray)
        
        let AutoStartDuration = Settings.GetAutoStartDuration()
        let _ = Timer.scheduledTimer(timeInterval: AutoStartDuration, target: self,
                                     selector: #selector(AutoStartInAttractMode),
                                     userInfo: nil, repeats: false)
    }
    
    var GameTextOverlay: TextOverlay? = nil
    
    func InitializeUI()
    {
        InitializeGestures()
    }
    
    /// Initialize gesture recognizers for piece motions. Available only on iOS devices.
    func InitializeGestures()
    {
        let TapGesture = UITapGestureRecognizer(target: self, action: #selector(HandleTap))
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
    ///
    /// - Parameter sender: The tap gesture.
    @objc func HandleTap(sender: UITapGestureRecognizer)
    {
        if sender.state == .ended
        {
            let Location = sender.location(in: GameUISurface3D)
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
        GameView3D?.DestroyMap3D(FromBoard: Game.GameBoard!, CalledFrom: "ClearAndStartAI",
                                 DestroyBy: .FadeAway, Completion: HandleStartInAIMode)
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
        GameTextOverlay?.HideNextLabel(Duration: 0.5)
        GameTextOverlay?.HideNextPiece(Duration: 0.1)
        
        let UserIDString = UserDefaults.standard.string(forKey: "CurrentUserID")!
        let UserID = UUID(uuidString: UserIDString)!
        let User = Settings.GetUser(WithID: UserID)
        let Level = User?.GetLevel(LevelID: 0)
        Level?.GameCount = Level!.GameCount + 1
        if Level!.HighScore < Game.HighScore
        {
            Level!.HighScore = Game.HighScore
        }
        Level?.Duration = Level!.Duration + GameDuration
        Level?.CumulativeScore = Level!.CumulativeScore + Game.CurrentGameScore
        Level?.CumulativePieces = Level!.CumulativePieces + Game.PiecesInGame
        
        /*
        var BlockCount: Int = 0
        var ReachableCount: Int = 0
        let UnreachableCount = Game.GameBoard!.Map!.UnreachablePointCount(Reachable: &ReachableCount, Blocked: &BlockCount)
        AIData?.AddTest(Game.AI!.CurrentScoringMethod, Duration: GameDuration,
                        Score: Double(Game!.CurrentGameScore),
                        Pieces: Game!.PiecesInGame,
                        BucketSize: Game.GameBoard!.Map!.BucketSize,
                        Unreachable: UnreachableCount, Reachable: ReachableCount)
        */
        
        //        let Mean = Game!.GameDuration() / Double(Game!.PiecesInGame)
        CumulativeDuration = CumulativeDuration + Game!.GameDuration()
        CumulativePieces = CumulativePieces + Double(Game!.PiecesInGame)
        let Mean: Double = CumulativeDuration / CumulativePieces
        /*
        let DbgStr = "Game count: \(GameCount), Mean: \(Convert.RoundToString(Mean, ToNearest: 0.0001, CharCount: 7))"
        */
        let MeanS = Convert.RoundToString(Mean, ToNearest: 0.0001, CharCount: 7)
        var MinFPS = PieceFPS.min()
        if MinFPS == nil
        {
            MinFPS = 0.0
        }
        let MinFPSS = Convert.RoundToString(MinFPS!, ToNearest: 0.0001, CharCount: 7)
        var MaxFPS = PieceFPS.max()
        if MaxFPS == nil
        {
            MaxFPS = 0.0
        }
        let MaxFPSS = Convert.RoundToString(MaxFPS!, ToNearest: 0.0001, CharCount: 7)
        let Median = Statistics.Median(PieceFPS)!
        let MedianS = Convert.RoundToString(Median, ToNearest: 0.0001, CharCount: 7)
        let MeanFPS = Statistics.Mean(PieceFPS)!
        let MeanFPSS = Convert.RoundToString(MeanFPS, ToNearest: 0.0001, CharCount: 7)
        let stdev = Statistics.StandardDeviation(PieceFPS)!
        let stdevS = Convert.RoundToString(stdev, ToNearest: 0.0001, CharCount: 7)
        PieceFPS.removeAll()
        let DbgStr = "Game count: \(GameCount), Mean: " + MeanS + ", MinFPS: " + MinFPSS +
            ", MaxFPS: " + MaxFPSS + ", Median FPS: " + MedianS + ", Mean FPS: " + MeanFPSS +
        ", stddev: \(stdevS)"

        DebugClient.Send(DbgStr)
        //        DebugClient.Send("[\(GameCount)] Game piece count: \(Game!.PiecesInGame), Game duration: \(Game!.GameDuration()), Mean: \(Mean)")
        
        GameTextOverlay?.ShowPressPlay(Duration: 0.5)
        
        if InAttractMode
        {
            let _ = Timer.scheduledTimer(timeInterval: 10.0, target: self,
                                         selector: #selector(AutoStartInAttractMode),
                                         userInfo: nil, repeats: false)
        }
        else
        {
            //Eventually we need to change the time interval to something longer...
            let _ = Timer.scheduledTimer(timeInterval: 10.0, target: self,
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
    
    /// The contents of the map were updated. Update the views.
    func MapUpdated()
    {
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
    /// - Parameter ThePiece: The finalized piece.
    func PieceFinalized(_ ThePiece: Piece)
    {
        switch CurrentBaseGameType
        {
            case .Standard:
                break
            
            case .Rotating4:
                GameView3D?.DrawMap3D(FromBoard: Game!.GameBoard!, CalledFrom: "PieceFinalized")
                Game!.GameBoard!.Map!.RotateMapRight()
                if Settings.GetCanRotateBoard()
                {
                    GameView3D?.RotateContentsRight(Duration: 0.15, Completed: {self.RotateFinishFinalizing()})
                }
                else
                {
                    NoRotateFinishFinalizing()
                }
            
            case .Cubic:
                break
        }
    }
    
    /// Finish finalizing a piece when no rotation occurs.
    func NoRotateFinishFinalizing()
    {
        GameView3D?.DrawMap3D(FromBoard: Game!.GameBoard!, CalledFrom: "*NoRotateFinishFinalizing")
        Game!.DoSpawnNewPiece()
    }
    
    /// Finish finalizing a piece when rotation occurs.
    func RotateFinishFinalizing()
    {
        GameView3D?.ClearBucket()
        GameView3D?.DrawMap3D(FromBoard: Game!.GameBoard!, CalledFrom: "*RotateFinishFinalizing")
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
    
    func PerformanceSample(FPS: Double)
    {
        PieceFPS.append(FPS)
        let FPSS = Convert.RoundToString(FPS, ToNearest: 0.001, CharCount: 6)
        var FG = ColorNames.PineGreen
        var BG = ColorNames.PaleGoldenrod
        if FPS < 40.0
        {
            FG = ColorNames.Red
            BG = ColorNames.YellowPantone
        }
        DebugClient.SetIdiotLight(IdiotLights.C3, Title: "Frame Rate\n\(FPSS)", FGColor: FG, BGColor: BG)
    }
    
    var PieceFPS = [Double]()
    
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
    
    /// Pause the game.
    func Pause()
    {
        if IsPaused
        {
            IsPaused = false
            PauseResumeButton?.setTitle("Pause", for: .normal)
            GameTextOverlay?.HidePause(Duration: 0.1)
            Game.ResumeGame()
            DebugClient.Send("Game resumed.")
            DebugClient.SetIdiotLight(IdiotLights.B2, Title: "Playing", FGColor: ColorNames.WhiteSmoke, BGColor: ColorNames.PineGreen)
        }
        else
        {
            IsPaused = true
            PauseResumeButton?.setTitle("Resume", for: .normal)
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
    
    func ClearAndPlay()
    {
        GameView3D?.DestroyMap3D(FromBoard: Game.GameBoard!, CalledFrom: "ClearAndPlay", DestroyBy: .FadeAway,
        Completion: Play)
    }
    
    /// Play the game, eg, start in normal user mode.
    func Play()
    {
        DebugClient.SetIdiotLight(IdiotLights.B2, Title: "Playing", FGColor: ColorNames.WhiteSmoke, BGColor: ColorNames.PineGreen)
        let GameCountMsg = MessageHelper.MakeKVPMessage(ID: GameCountID, Key: "Game Count", Value: "\(GameCount)")
        DebugClient.SendPreformattedCommand(GameCountMsg)
        
        GameTextOverlay?.HideGameOver(Duration: 0.0)
        GameTextOverlay?.HidePressPlay(Duration: 0.0)
        GameTextOverlay?.ShowNextLabel(Duration: 0.1)
        
        Game!.SetPredeterminedOrder(UsePredeterminedOrder, FirstIs: .T)
        
        GameDuration = CACurrentMediaTime()
        Game.StartGame(EnableAI: InAttractMode, PieceCategories: GamePieces, UseFastAI: UseFastAI)

        GameView3D?.DrawMap3D(FromBoard: Game.GameBoard!, CalledFrom: "Play")
        GameTextOverlay?.ShowCurrentScore(NewScore: 0)
        CurrentlyPlaying = true
        PlayStopButton?.setTitle("Stop", for: .normal)
        if !InAttractMode
        {
            DebugClient.SetIdiotLight(IdiotLights.A2, Title: "Normal Mode", FGColor: ColorNames.Black, BGColor: ColorNames.White)
        }
        PieceFPS.removeAll()
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
    
    /*
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
    */
    
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
        }
        else
        {
            InAttractMode = false
            Play()
            PlayStopButton?.setTitle("Stop", for: .normal)
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
//        MoveUpButton.Highlight(WithImage: "UpArrowHighlighted", ForSeconds: 0.15, OriginalName: "UpArrow")
    }
    
    /// AI is throwing a piece away.
    func AI_MoveUpAndAway()
    {
//        UpAndAwayButton.Highlight(WithImage: "UpAwayArrowHighlighted", ForSeconds: 0.15, OriginalName: "UpAwayArrow")
    }
    
    /// AI is moving a piece downwards.
    func AI_MoveDown()
    {
//        MoveDownButton.Highlight(WithImage: "DownArrowHighlighted", ForSeconds: 0.15, OriginalName: "DownArrow")
    }
    
    /// AI is dropping a piece downwards.
    func AI_DropDown()
    {
//        DropDownButton.Highlight(WithImage: "DropDownArrowHighlighted", ForSeconds: 0.15, OriginalName: "DropDownArrow")
    }
    
    /// AI is moving a piece to the left.
    func AI_MoveLeft()
    {
//        MoveLeftButton.Highlight(WithImage: "LeftArrowHighlighted", ForSeconds: 0.15, OriginalName: "LeftArrow")
    }
    
    /// AI is moving a piece to the right.
    func AI_MoveRight()
    {
 //       MoveRightButton.Highlight(WithImage: "RightArrowHighlighted", ForSeconds: 0.15, OriginalName: "RightArrow")
    }
    
    /// AI is rotating a piece clockwise.
    func AI_RotateRight()
    {
//        RotateRightButton.Highlight(WithImage: "RotateRightArrowHighlighted", ForSeconds: 0.15, OriginalName: "RotateRightArrow")
    }
    
    /// AI is rotating a piece counter-clockwise.
    func AI_RotateLeft()
    {
 //       RotateLeftButton.Highlight(WithImage: "RotateLeftArrowHighlighted", ForSeconds: 0.15, OriginalName: "RotateLeftArrow")
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
    
    // MARK: General-UI interactions.
    
    /// The first time the slider came into view flag. Used in **+MainSliderUI.swift**.
       var FirstSlideIn: Bool = true
    
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
            GameView.bringSubviewToFront(MainSlideIn)
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
        let ImageName = Opened ? "InvertedCubeButton" : "CubeButton"
        MainUIButton.setImage(UIImage(named: ImageName), for: UIControl.State.normal)
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
    @IBOutlet weak var MoveLeftButton: UITouchImage!
    @IBOutlet weak var MoveRightButton: UITouchImage!
    @IBOutlet weak var MoveDownButton: UITouchImage!
    @IBOutlet weak var MoveUpButton: UITouchImage!
    @IBOutlet weak var RotateLeftButton: UITouchImage!
    @IBOutlet weak var DropDownButton: UITouchImage!
    @IBOutlet weak var UpAndAwayButton: UITouchImage!
    @IBOutlet weak var RotateRightButton: UITouchImage!
 
    @IBOutlet weak var MainSlideIn: MainSlideInView!
    @IBOutlet weak var MainSlideInOptionTable: UITableView!
    @IBOutlet weak var SlideInAttractButton: UIButton!
    @IBOutlet weak var SlideInCloseButton: UIButton!
    
    @IBOutlet weak var GameControlView: UIView!
    @IBOutlet weak var MotionControlView: UIView!
    @IBOutlet weak var GameView: UIView!
    @IBOutlet weak var GameUISurface3D: View3D!
    
    @IBOutlet weak var TextLayerView: UIView!
    @IBOutlet weak var NextPieceLabelView: UIView!
    @IBOutlet weak var NextPieceView: UIView!
    @IBOutlet weak var CurrentScoreLabelView: UIView!
    @IBOutlet weak var HighScoreLabelView: UIView!
    @IBOutlet weak var ScoreLabelView: UIView!
    @IBOutlet weak var PressPlayLabelView: UIView!
    @IBOutlet weak var GameOverLabelView: UIView!
    @IBOutlet weak var PauseLabelView: UIView!
    
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
