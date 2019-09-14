//
//  TextOverlay.swift
//  Fouris
//
//  Created by Stuart Rankin on 8/19/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// iOS text overlay view implementation.
/// - Note:
///   - Most of the functions here can be called by various threads. For that reason, functions that access the UI
///     have the relevant code wrapped in `OperationQueue.main.addOperation` blocks to schedule the operation on the
///     main (UI) thread.
///   - This version of the source is for iOS.
class TextOverlay: TextLayerDisplayProtocol
{
    /// Initializer.
    /// - Parameter Device: The hardware idiom (eg, table or phone).
    init(Device: UIUserInterfaceIdiom)
    {
        Idiom = Device
    }
    
    /// Holds the UI idiom.
    private var Idiom: UIUserInterfaceIdiom = .phone
    
    /// Sets the controls to use to display text. Text is an attributed string displayed in a CATextLayer, so each text object
    /// needs to reside in a view (abstracted by the typealias **TextContainerType**). Those views are passed in this function.
    /// - Parameter NextLabel: Container for the "Next" label.
    /// - Parameter NextPieceView: Container for the next game piece.
    /// - Parameter ScoreLabel: Container for the "Score" label.
    /// - Parameter CurrentScoreLabel: Container for the current score label.
    /// - Parameter HighScoreLabel: Container for the high score label.
    /// - Parameter GameOverLabel: Container for the "Game Over" label.
    /// - Parameter PressPlayLabel: Container for the "Press Play" label.
    /// - Parameter PauseLabel: Container for the "Pause" label.
    /// - Parameter PieceControl: The piece view control.
    func SetControls(NextLabel: UIView?,
                     NextPieceView: UIView?,
                     ScoreLabel: UIView?,
                     CurrentScoreLabel: UIView?,
                     HighScoreLabel: UIView?,
                     GameOverLabel: UIView?,
                     PressPlayLabel: UIView?,
                     PauseLabel: UIView?,
                     PieceControl: PieceViewer?)
    {
        NextLabelContainer = NextLabel
        NextPieceContainer = NextPieceView
        ScoreLabelContainer = ScoreLabel
        CurrentScoreContainer = CurrentScoreLabel
        HighScoreContainer = HighScoreLabel
        GameOverContainer = GameOverLabel
        PressPlayContainer = PressPlayLabel
        PauseContainer = PauseLabel
        PieceViewControl = PieceControl
        //The views all have background colors in the interface builder so set everything to transparent here.
        NextLabelContainer?.layer.backgroundColor = UIColor.clear.cgColor
        NextPieceContainer?.layer.backgroundColor = UIColor.clear.cgColor
        ScoreLabelContainer?.layer.backgroundColor = UIColor.clear.cgColor
        CurrentScoreContainer?.layer.backgroundColor = UIColor.clear.cgColor
        HighScoreContainer?.layer.backgroundColor = UIColor.clear.cgColor
        GameOverContainer?.layer.backgroundColor = UIColor.clear.cgColor
        PressPlayContainer?.layer.backgroundColor = UIColor.clear.cgColor
        PauseContainer?.layer.backgroundColor = UIColor.clear.cgColor
        NextLabelContainer?.layer.zPosition = 10000
        NextPieceContainer?.layer.zPosition = 10000
        ScoreLabelContainer?.layer.zPosition = 10000
        CurrentScoreContainer?.layer.zPosition = 10000
        HighScoreContainer?.layer.zPosition = 10000
        GameOverContainer?.layer.zPosition = 10000
        PressPlayContainer?.layer.zPosition = 10001
        PauseContainer?.layer.zPosition = 10000
        
        PieceViewControl?.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.35)
        PieceViewControl?.layer.borderColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.35).cgColor
        PieceViewControl?.layer.cornerRadius = 5.0
        PieceViewControl?.layer.borderWidth = 0.5
        PieceViewControl?.BlockSize = 6
        PieceViewControl?.alpha = 0.0
        
        InitializeLabels()
    }
    
    var NextLabelContainer: UIView? = nil
    var NextPieceContainer: UIView? = nil
    var ScoreLabelContainer: UIView? = nil
    var CurrentScoreContainer: UIView? = nil
    var HighScoreContainer: UIView? = nil
    var GameOverContainer: UIView? = nil
    var PressPlayContainer: UIView? = nil
    var PauseContainer: UIView? = nil
    var PieceViewControl: PieceViewer? = nil
    
    private func InitializeLabels()
    {
        PopulateStringCache()
        ShowNextLabel()
        ShowScoreLabel()
    }
    
    /// Populate the cache of attributed strings for text that does not change.
    private func PopulateStringCache()
    {
        StringCache.removeAll()
        let NextFontSize: CGFloat = Idiom == .pad ? 40.0 : 30.0
        let NextFont = UIFont(name: "Avenir-Heavy", size: NextFontSize)
        let NextAttributes: [NSAttributedString.Key: Any] =
            [
                .font: NextFont as Any,
                .foregroundColor: ColorServer.ColorFrom(ColorNames.White) as Any,
                .strokeColor: ColorServer.ColorFrom(ColorNames.Black) as Any,
                .strokeWidth: -2 as Any
        ]
        let PrettyNextText = NSAttributedString(string: "Next", attributes: NextAttributes)
        StringCache[.NextLabel] = PrettyNextText
        
        let ScoreFontSize: CGFloat = Idiom == .pad ? 40.0 : 30.0
        let ScoreFont = UIFont(name: "Avenir-Heavy", size: ScoreFontSize)
        let ScoreAttributes: [NSAttributedString.Key: Any] =
            [
                .font: ScoreFont as Any,
                .foregroundColor: ColorServer.ColorFrom(ColorNames.White) as Any,
                .strokeColor: ColorServer.ColorFrom(ColorNames.Black) as Any,
                .strokeWidth: -2 as Any
        ]
        let PrettyScoreText = NSAttributedString(string: "Score", attributes: ScoreAttributes)
        StringCache[.ScoreLabel] = PrettyScoreText
        
        let PauseFontSize: CGFloat = Idiom == .pad ? 130.0 : 80.0
        let PauseFont = UIFont(name: "Avenir-Black", size: PauseFontSize)
        let PauseAttributes: [NSAttributedString.Key: Any] =
            [
                .font: PauseFont as Any,
                .foregroundColor: ColorServer.ColorFrom(ColorNames.AmaranthPurple) as Any,
                .strokeColor: ColorServer.ColorFrom(ColorNames.Black) as Any,
                .strokeWidth: -2 as Any
        ]
        let PrettyPauseText = NSAttributedString(string: "Paused", attributes: PauseAttributes)
        StringCache[.Paused] = PrettyPauseText
        
        let PressPlaySize: CGFloat = Idiom == .pad ? 75.0 : 35.0
        let PressPlayFont = UIFont(name: "Avenir-Heavy", size: PressPlaySize)
        let PressPlayAttributes: [NSAttributedString.Key: Any] =
            [
                .font: PressPlayFont as Any,
                .foregroundColor: ColorServer.ColorFrom(ColorNames.青20号) as Any,
                .strokeColor: ColorServer.ColorFrom(ColorNames.White) as Any,
                .strokeWidth: -2 as Any
        ]
        let PrettyPressPlayText = NSAttributedString(string: "Press Play to Start", attributes: PressPlayAttributes)
        StringCache[.PressPlay] = PrettyPressPlayText
        
        let GameOverSize: CGFloat = Idiom == .pad ? 100.0 : 50.0
        let GameOverFont = UIFont(name: "Avenir-Black", size: GameOverSize)
        let GameOverAttributes: [NSAttributedString.Key: Any] =
            [
                .font: GameOverFont as Any,
                .foregroundColor: ColorServer.ColorFrom(ColorNames.Citrine) as Any,
                .strokeColor: ColorServer.ColorFrom(ColorNames.Red) as Any,
                .strokeWidth: -4 as Any
        ]
        let PrettyGameOverText = NSAttributedString(string: "Game Over", attributes: GameOverAttributes)
        StringCache[.GameOver] = PrettyGameOverText
    }
    
    /// Holds cached attributed strings (so we don't have to continuously recreate them).
    private var StringCache = [ContainerTypes: NSAttributedString]()
    
    /// Returns the attributed string for the passed container type.
    /// - Parameter ForType: The container type whose attributed string will be returned.
    /// - Returns: Attributes string for the passed container type. Nil if not found.
    private func GetString(ForType: ContainerTypes) -> NSAttributedString?
    {
        return StringCache[ForType]
    }
    
    private var OriginalPressPlayFrame: CGRect? = nil
    
    /// Return a CATextLayer based on the parameter.
    /// - Note: This function is needed to allow for text that moves around in large NSViews (such as the "Press Play" text).
    /// - Parameter WithVerticalCentering: If true, an instance of **CATextLayer2** is returned. If false, an
    ///                                    instance of **CATextLayer** is returned.
    /// - Returns: The requested text layer type.
    private func MakeLayer(WithVerticalCentering: Bool) -> CATextLayer
    {
        return WithVerticalCentering ? CATextLayer2() : CATextLayer()
    }
    
    /// Create and return a text layer (either a `CATextLayer` or a `CATextLayer2` depending on whether the
    /// text will be vertically centered - see **CenterVertically**) with the passed text.
    /// - Parameter WithText: The attributed text to use to populate the CATextLayer (or CATextLayer2, depending
    ///                       on the parameters).
    /// - Parameter ContainerType: The type of container where the text will be used.
    /// - Parameter CenterVertically: Determines if the text is centered vertically. If true, **CATextLayer2** is
    ///                                 used. Otherwise, **CATextLayer** is used.
    /// - Parameter HorizontalAlignment: Determines horizontal alignment of the text within the **CATextLayer**.
    /// - Parameter LayerRect: The rectangle to use for the text layer.
    /// - Parameter Effect: Type of text effect.
    /// - Returns: `CATextLayer` (or `CATextLayer2`) for use in a UIView.
    private func GenerateObjectLayer(WithText: NSAttributedString, ContainerType: ContainerTypes,
                                     CenterVertically: Bool, HorizontalAlignment: CATextLayerAlignmentMode, LayerRect: CGRect,
                                     Effect: ContainerEffects) -> CATextLayer
    {
        let SomeLayer = MakeLayer(WithVerticalCentering: CenterVertically)
        SomeLayer.zPosition = 1000
        SomeLayer.name = ContainerType.rawValue
        SomeLayer.bounds = LayerRect
        SomeLayer.frame = LayerRect
        SomeLayer.alignmentMode = HorizontalAlignment
        SomeLayer.string = WithText
        switch Effect
        {
            case .None:
                break
            
            case .Glow:
                SomeLayer.shadowOpacity = .zero
                SomeLayer.shadowColor = ColorServer.ColorFrom(ColorNames.MistyRose).cgColor
                SomeLayer.shadowRadius = 20.0
                SomeLayer.shadowOpacity = 1.0
            
            case .Shadow:
                SomeLayer.shadowColor = ColorServer.ColorFrom(ColorNames.Black, WithAlpha: 0.6).cgColor
                SomeLayer.shadowOffset = CGSize(width: 5, height: 5)
                SomeLayer.shadowOpacity = 1.0
                SomeLayer.shadowRadius = 0.0
        }
        return SomeLayer
    }
    
    /// Create an object. This is a text layer that will live in the passed NSView.
    /// - Note: NSView has all sublayers removed before the new text layer is added.
    /// - Parameter SomeObject: The view in whicht he object will live.
    /// - Parameter AttributedText: Attributed text to display in the object.
    /// - Parameter ContainerType: The type of container to show.
    /// - Parameter HorizontalAlignment: The text's horizontal alignment.
    /// - Parameter Effect: Visual effect to apply to the conatiner. Defaults to **.None**.
    /// - Parameter WithVerticalCentering: If true, the overriden CATextLayer (**CATextLayer2**) is used with automatic
    ///                                    vertical centering. If false, a standard **CATextLayer** is used.
    private func CreateObject(_ SomeObject: UIView, AttributedText: NSAttributedString, ContainerType: ContainerTypes,
                              HorizontalAlignment: CATextLayerAlignmentMode, Effect: ContainerEffects = .None, WithVerticalCentering: Bool = true)
    {
        SomeObject.layer.sublayers?.removeAll()
        let SomeLayer = GenerateObjectLayer(WithText: AttributedText, ContainerType: ContainerType,
                                            CenterVertically: WithVerticalCentering, HorizontalAlignment: HorizontalAlignment,
                                            LayerRect: SomeObject.bounds, Effect: Effect)
        SomeObject.layer.addSublayer(SomeLayer)
    }
    
    /// Show an object. If the object does not yet exist, no action will be taken.
    /// - Parameter SomeObject: The view in whicht he object will live.
    /// - Parameter ContainerType: The type of container to show.
    /// - Parameter Duration: Duration of the appearance (runs an animation from alpha 0.0 to 1.0) in seconds.
    /// - Parameter CompletionHandler: Completion block to be called after the opacity has been changed.
    private func ShowObject(_ SomeObject: UIView, ContainerType: ContainerTypes, Duration: Double,
                            CompletionHandler: (() -> ())? = nil)
    {
        OperationQueue.main.addOperation
            {
                let Layer = self.GetContainerLayer(From: SomeObject, ContainerType: ContainerType)
                if Layer == nil
                {
                    //Nothing to do. Theoretically, we should never get here, but just in case, we'll return.
                    print("No layer container found for \(ContainerType) in ShowObject")
                    return
                }
                SomeObject.alpha = 1.0
                Layer?.zPosition = 10000
                UIView.animate(withDuration: Duration, delay: 0.0, options: [.allowUserInteraction],
                               animations:
                    {
                        Layer?.opacity = 1.0
                }, completion:
                    {
                        _ in
                        CompletionHandler?()
                })
        }
    }
    
    /// Count the number of sublayers in **InObject** that are of **WithType**.
    /// - Parameter InObject: The object (a UIVIew) that contains the sublayers to count.
    /// - Parameter WithType: The type of sublayer to count.
    /// - Returns: The number of sublayers of the specified type in **InObject**.
    private func CountLayers(InObject: UIView, WithType: ContainerTypes) -> Int
    {
        var Count = 0
        InObject.layer.sublayers?.forEach({if $0.name == WithType.rawValue {Count = Count + 1}})
        return Count
    }
    
    /// Hide the passed object by setting its alpha level to 0.0.
    /// - Note:
    ///   - If the specified container does not contain the expected layer, control is returned immediately. This is most
    ///     likely due to `HideObject` being called on a container that hasn't yet been constructed.
    ///   - See [Better iOS Animations with CATransation](https://medium.com/@joncardasis/better-ios-animations-with-catransaction-72a7425673a6)
    /// - Parameter SomeObject: The object to hide.
    /// - Parameter Duration: If this value is 0.0, the alpha level is set immediately. Otherwise, this is the number of
    ///                       seconds to animate the alpha level from its current value to 0.0.
    /// - Parameter ContainerType: The type of object container to hide.
    /// - Parameter CompletionHandler: Completion handler to execute once opacity has been set to 0.0.
    private func HideObject(_ SomeObject: UIView, Duration: Double, ContainerType: ContainerTypes,
                            CompletionHandler: (() -> ())? = nil)
    {
        OperationQueue.main.addOperation
            {
                let Layer = self.GetContainerLayer(From: SomeObject, ContainerType: ContainerType)
                if Layer == nil
                {
                    //Layer not found. Nothing to do.
                    print("No layer container found for \(ContainerType) in HideObject")
                    return
                }
                UIView.animate(withDuration: Duration, delay: 0.0, options: [.allowUserInteraction],
                               animations:
                    {
                        Layer?.opacity = 0.0
                }, completion:
                    {
                        _ in
                        Layer?.opacity = 0.0
                        CompletionHandler?()
                })
        }
    }
    
    /// Find and return the specified layer in the passed view.
    /// - Parameter From: The view searched for the specified layer.
    /// -
    private func GetContainerLayer(From: UIView, ContainerType: ContainerTypes) -> CALayer?
    {
        var Layer: CALayer? = nil
        From.layer.sublayers?.forEach({if $0.name == ContainerType.rawValue {Layer = $0}})
        return Layer
    }
    
    /// Show the next label. This is the "Next" string over the view of the next piece.
    /// - Parameter Duration: The number of seconds to fade in the text.
    func ShowNextLabel(Duration: Double? = nil)
    {
        let FinalDuration = Duration == nil ? 0.0 : Duration!
        let NextString = GetString(ForType: .NextLabel)
        if !NextLabelCreated
        {
            NextLabelCreated = true
            CreateObject(NextLabelContainer!, AttributedText: NextString!, ContainerType: .NextLabel,
                         HorizontalAlignment: .left)
        }
        ShowObject(NextLabelContainer!, ContainerType: .NextLabel, Duration: FinalDuration)
    }
    
    /// Next label created flag.
    var NextLabelCreated = false
    
    /// Hide the next label. This is the "Next" string over the view of the next piece.
    /// - Parameter Duration: The number of seconds to fade out the text.
    func HideNextLabel(Duration: Double? = nil)
    {
        let FinalDuration = Duration == nil ? 0.3 : Duration!
        HideObject(NextLabelContainer!, Duration: FinalDuration, ContainerType: .NextLabel)
    }
    
    /// Show the score label. This is the "Score" string next to the actual score values.
    /// - Parameter Duration: The number of seconds to fade in the text.
    func ShowScoreLabel(Duration: Double? = nil)
    {
        let FinalDuration = Duration == nil ? 0.0 : Duration!
        let ScoreString = GetString(ForType: .ScoreLabel)
        if !ScoreLabelCreated
        {
            ScoreLabelCreated = true
            CreateObject(ScoreLabelContainer!, AttributedText: ScoreString!, ContainerType: .ScoreLabel,
                         HorizontalAlignment: .right)
        }
        ShowObject(ScoreLabelContainer!, ContainerType: .ScoreLabel, Duration: FinalDuration)
    }
    
    /// Score label created flag.
    var ScoreLabelCreated = false
    
    /// Hide the score label. This is the "Score" string next to the actual score values.
    /// - Parameter Duration: The number of seconds to fade out the text.
    func HideScoreLabel(Duration: Double? = nil)
    {
        let FinalDuration = Duration == nil ? 0.3 : Duration!
        HideObject(ScoreLabelContainer!, Duration: FinalDuration, ContainerType: .ScoreLabel)
    }
    
    /// Show the next piece (after the current piece).
    /// - Parameter NextPiece: The next piece to show. Visualized by **PieceFactory**.
    /// - Parameter Duration: The number of seconds to fade in the image of the next piece.
    /// - Parameter AddShadow: If true, a shadow is added to the next piece. Defaults to true.
    func ShowNextPiece(_ NextPiece: Piece, Duration: Double? = nil, AddShadow: Bool = true)
    {
        OperationQueue.main.addOperation
            {
                #if true
                self.PieceViewControl?.Clear()
                self.PieceViewControl?.AddPiece(NextPiece)
                self.PieceViewControl?.RotatePiece(OnX: false, OnY: false, OnZ: true)
                let FinalDuration = Duration == nil ? 0.1 : Duration!
                UIView.animate(withDuration: FinalDuration, animations:
                    {
                        self.PieceViewControl!.alpha = 1.0
                }, completion:
                    {
                        _ in
                        self.PieceViewControl!.alpha = 1.0
                }
                )
                #else
                self.NextPieceContainer!.alpha = 1.0
                let VisualPiece: CAShapeLayer = PieceFactory.GetGenericView(ForPiece: NextPiece, WithShadow: true)
                self.NextPieceContainer?.layer.sublayers?.removeAll()
                let FinalDuration = Duration == nil ? 0.1 : Duration!
                VisualPiece.name = ContainerTypes.NextPiece.rawValue
                let YOffset = 5.0
                VisualPiece.bounds = VisualPiece.bounds.WithNewPosition(CGPoint(x: -5, y: YOffset))
                self.NextPieceContainer?.layer.addSublayer(VisualPiece)
                UIView.animate(withDuration: FinalDuration, animations:
                    {
                        VisualPiece.opacity = 1.0
                }, completion:
                    {
                        _ in
                        self.NextLabelContainer!.alpha = 1.0
                }
                )
                #endif
        }
    }
    
    /// Hide the next piece.
    /// - Parameter Duration: The number of seconds to fade out the image of the next piece.
    func HideNextPiece(Duration: Double? = nil)
    {
        OperationQueue.main.addOperation
            {
                //let VisualPiece = self.GetContainerLayer(From: self.NextPieceContainer!, ContainerType: .NextPiece)
                let FinalDuration = Duration == nil ? 0.3 : Duration!
                UIView.animate(withDuration: FinalDuration, animations:
                    {
                        self.PieceViewControl?.alpha = 0.0
                }, completion:
                    {
                        _ in
                        self.PieceViewControl!.alpha = 0.0
                }
                )
        }
    }
    
    /// Show the current score. Assumes the score label is visible.
    /// - Note: Score text layers are generated each time this function is called (because it doesn't make sense to cache
    ///         changeable text).
    /// - Parameter NewScore: Score to display.
    func ShowCurrentScore(NewScore: Int)
    {
        OperationQueue.main.addOperation
            {
                self.CurrentScoreContainer!.layer.sublayers?.removeAll()
                let CurrentScoreLayer = CATextLayer2()
                CurrentScoreLayer.name = "CurrentScore"
                CurrentScoreLayer.bounds = self.CurrentScoreContainer!.bounds
                CurrentScoreLayer.frame = self.CurrentScoreContainer!.bounds
                CurrentScoreLayer.alignmentMode = .left
                let FontSize: CGFloat = self.Idiom == .pad ? 40.0 : 30.0
                let Font = UIFont(name: "Avenir-Heavy", size: FontSize)
                let Attributes: [NSAttributedString.Key: Any] =
                    [
                        .font: Font as Any,
                        .foregroundColor: ColorServer.ColorFrom(ColorNames.White) as Any,
                        .strokeColor: ColorServer.ColorFrom(ColorNames.Black) as Any,
                        .strokeWidth: -2
                ]
                let PrettyNextText = NSAttributedString(string: "\(NewScore)", attributes: Attributes)
                CurrentScoreLayer.string = PrettyNextText
                self.CurrentScoreContainer!.layer.addSublayer(CurrentScoreLayer)
                self.CurrentScoreContainer!.alpha = 1.0
        }
    }
    
    /// Hide the current score value.
    func HideCurrentScore()
    {
        OperationQueue.main.addOperation
            {
                self.CurrentScoreContainer!.alpha = 0.0
        }
    }
    
    /// Show the high score. Assumes the score label is visible.
    /// - Note: Score text layers are generated each time this function is called (because it doesn't make sense to cache
    ///         changeable text).
    /// - Parameter NewScore: High score to display.
    /// - Parameter Highlight: Determines if the text color is highlighted. Default is false.
    /// - Parameter HighlightColor: The color to use to highlight the text.
    /// - Parameter HighlightDuration: The duration of the highlight.
    func ShowHighScore(NewScore: Int, Highlight: Bool = false, HighlightColor: ColorNames = .Gold, HighlightDuration: Double = 1.0)
    {
        LastHighScore = NewScore
        OperationQueue.main.addOperation
            {
                self.HighScoreContainer!.layer.sublayers?.removeAll()
                let FontSize: CGFloat = self.Idiom == .pad ? 40.0 : 30.0
                let Font = UIFont(name: "Avenir-Heavy", size: FontSize)
                let ForegroundColor = Highlight ? ColorServer.ColorFrom(HighlightColor) : ColorServer.ColorFrom(ColorNames.Cyan)
                let Attributes: [NSAttributedString.Key: Any] =
                    [
                        .font: Font as Any,
                        .foregroundColor: ForegroundColor as Any,
                        .strokeColor: ColorServer.ColorFrom(ColorNames.Black) as Any,
                        .strokeWidth: -2
                ]
                let PrettyHighScoreText = NSAttributedString(string: "\(NewScore)", attributes: Attributes)
                //HighScoreLayer.string = PrettyHighScoreText
                let HighScoreLayer = self.GenerateObjectLayer(WithText: PrettyHighScoreText, ContainerType: .HighScore, CenterVertically: true,
                                                              HorizontalAlignment: .left, LayerRect: self.HighScoreContainer!.bounds,
                                                              Effect: .None)
                
                if HighlightDuration > 0.0
                {
                    let _ = Timer.scheduledTimer(timeInterval: HighlightDuration, target: self, selector:
                        #selector(self.ResetHighScoreColor), userInfo: nil, repeats: false)
                }
                
                self.HighScoreContainer!.layer.addSublayer(HighScoreLayer)
                self.HighScoreContainer!.alpha = 1.0
        }
    }
    
    /// Holds the most recent high score value.
    var LastHighScore = -1
    
    /// The color
    var HighScoreResetColor = ColorNames.Cyan
    
    /// Resets the high score color to the value in **HighScoreResetColor**.
    @objc func ResetHighScoreColor()
    {
        OperationQueue.main.addOperation
            {
                self.HighScoreContainer!.layer.sublayers?.removeAll()
                let FontSize: CGFloat = self.Idiom == .pad ? 40.0 : 30.0
                let Font = UIFont(name: "Avenir-Heavy", size: FontSize)
                let ForegroundColor = ColorServer.ColorFrom(self.HighScoreResetColor)
                let Attributes: [NSAttributedString.Key: Any] =
                    [
                        .font: Font as Any,
                        .foregroundColor: ForegroundColor as Any,
                        .strokeColor: ColorServer.ColorFrom(ColorNames.Black) as Any,
                        .strokeWidth: -2
                ]
                let PrettyHighScoreText = NSAttributedString(string: "\(self.LastHighScore)", attributes: Attributes)
                let HighScoreLayer = self.GenerateObjectLayer(WithText: PrettyHighScoreText, ContainerType: .HighScore, CenterVertically: true,
                                                              HorizontalAlignment: .left, LayerRect: self.HighScoreContainer!.bounds,
                                                              Effect: .None)
                self.HighScoreContainer!.layer.addSublayer(HighScoreLayer)
                self.HighScoreContainer!.alpha = 1.0
        }
    }
    
    /// Hide the high score.
    func HideHighScore()
    {
        OperationQueue.main.addOperation
            {
                self.HighScoreContainer!.alpha = 0.0
        }
    }
    
    /// Show the "Pause" text.
    /// - Parameter Duration: The number of seconds to fade in the "Pause" text.
    func ShowPause(Duration: Double? = nil)
    {
        let FinalDuration = Duration == nil ? 0.0 : Duration!
        let PauseText = GetString(ForType: .Paused)
        if !PauseLabelCreated
        {
            PauseLabelCreated = true
            CreateObject(PauseContainer!, AttributedText: PauseText!, ContainerType: .Paused,
                         HorizontalAlignment: .center)
        }
        ShowObject(PauseContainer!, ContainerType: .Paused, Duration: FinalDuration)
    }
    
    /// Flag that indicates the pause label was created.
    var PauseLabelCreated = false
    
    /// Hide the "Pause" text.
    /// - Parameter Duration: The number of seconds to fade out the "Pause" text.
    func HidePause(Duration: Double? = nil)
    {
        let FinalDuration = Duration == nil ? 0.3 : Duration!
        HideObject(PauseContainer!, Duration: FinalDuration, ContainerType: .Paused)
    }
    
    /// Show the "Press Play to Start" text.
    /// - Parameter Duration: The number of seconds to fade in the text.
    func ShowPressPlay(Duration: Double? = nil)
    {
        let FinalDuration = Duration == nil ? 0.0 : Duration!
        let PressPlayText = GetString(ForType: .PressPlay)
        if !PressPlayLabelCreated
        {
            PressPlayLabelCreated = true
            CreateObject(PressPlayContainer!, AttributedText: PressPlayText!, ContainerType: .PressPlay,
                         HorizontalAlignment: .center, Effect: .Shadow, WithVerticalCentering: false)
            if let FinalLayer = GetContainerLayer(From: PressPlayContainer!, ContainerType: .PressPlay)
            {
                OriginalPressPlayFrame = FinalLayer.bounds
            }
        }
        else
        {
            if let FinalLayer = GetContainerLayer(From: PressPlayContainer!, ContainerType: .PressPlay)
            {
                FinalLayer.frame = OriginalPressPlayFrame!
            }
        }
        ShowObject(PressPlayContainer!, ContainerType: .PressPlay, Duration: FinalDuration)
    }
    
    /// Flag that indicates the press play text layer was created.
    var PressPlayLabelCreated = false
    
    /// Hide the "Pres Play to Start" text.
    /// - Parameter Duration: The number of seconds to fade out the text.
    func HidePressPlay(Duration: Double? = nil)
    {
        let FinalDuration = Duration == nil ? 0.3 : Duration!
        HideObject(PressPlayContainer!, Duration: FinalDuration, ContainerType: .PressPlay)
    }
    
    /// Moves the press play container from its current location to its original location.
    private func MovePressPlayContainer(ToY: Int)
    {
        if let PressPlayLayer = GetContainerLayer(From: PressPlayContainer!, ContainerType: .PressPlay)
        {
            let NewPosition = PressPlayLayer.frame.WithNewY(CGFloat(ToY))
            OperationQueue.main.addOperation
                {
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(1.0)
                    PressPlayLayer.frame = NewPosition
                    CATransaction.commit()
            }
        }
    }
    
    /// Show the "Game Over" text.
    /// - Parameter Duration: Number of seconds to fade in the text.
    /// - Parameter HideAfter: Number of seconds to wait before automatically hiding the text. If nil, the text will not be
    ///                        automatically hidden. Default is nil.
    func ShowGameOver(Duration: Double?, HideAfter: Double? = nil)
    {
        let FinalDuration = Duration == nil ? 0.0 : Duration!
        let GameOverString = GetString(ForType: .GameOver)
        if !GameOverLabelCreated
        {
            GameOverLabelCreated = true
            CreateObject(GameOverContainer!, AttributedText: GameOverString!, ContainerType: .GameOver,
                         HorizontalAlignment: .center, Effect: .Glow)
        }
        ShowObject(GameOverContainer!, ContainerType: .GameOver, Duration: FinalDuration)
    }
    
    /// Hide the "Game Over" text.
    /// - Parameter Duration: Number of seconds to fade out the "Game Over" text.
    /// - Parameter MovePressPlay: If true, the press play container is moved to its original location.
    func HideGameOver(Duration: Double? = nil, MovePressPlay: Bool = true)
    {
        let FinalDuration = Duration == nil ? 0.1 : Duration!
        if MovePressPlay
        {
            //let Middle = PressPlayContainer!.bounds.height / 2
            let Middle = OriginalPressPlayFrame!.minY + 180
            HideObject(GameOverContainer!, Duration: FinalDuration, ContainerType: .GameOver,
                       CompletionHandler: { self.MovePressPlayContainer(ToY: Int(Middle)) })
        }
        else
        {
            HideObject(GameOverContainer!, Duration: FinalDuration, ContainerType: .GameOver)
        }
    }
    
    /// Flag that indicates the game over label was created.
    private var GameOverLabelCreated = false
}
